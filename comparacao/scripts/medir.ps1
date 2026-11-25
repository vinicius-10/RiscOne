<#
.SYNOPSIS
    Sintetiza + implementa um nucleo de terceiros nas MESMAS condicoes do scripts/synth.ps1 deste
    projeto (Vivado 2025.2 non-project, xc7a100tcsg324-1, maxThreads 8, diretivas padrao,
    clock de 10 ns) e acrescenta report_power. Gera resumo.txt e metricas.json.

.EXAMPLE
    .\comparacao\scripts\medir.ps1 -Dir comparacao\10_zongo -SynthOnly   # iteracao rapida
    .\comparacao\scripts\medir.ps1 -Dir comparacao\10_zongo -Final       # medicao oficial (exclusiva)

.NOTES
    <Dir>\config.psd1 descreve o projeto (caminhos relativos a <Dir>):
      @{
        Nome    = 'Zongo - rv32i-core'
        Top     = 'top_cmp'
        Fontes  = @('repo/rtl/alu.v', 'wrapper/top_cmp.sv')   # na ordem de compilacao; .v .sv .vhd
        Xdc     = @('constr.xdc')
        Mem     = @('programa/prog_word.hex')                  # copiados para o dir de execucao
        Include = @()                                          # diretorios de `include
        Define  = @()                                          # ex.: 'SYNTH=1'
        Vhdl2008 = $false
        Generics = @()                                         # ex.: 'MEM_FILE=prog.hex'
      }
    Concorrencia: no maximo 2 Vivado ao mesmo tempo (semaforo do Windows). -Final espera ate
    ser o UNICO Vivado deste fluxo rodando, para o tempo de compilacao ser comparavel.
    Saida: <Dir>\build\<Tag>\ ; -Final acrescenta uma linha em comparacao\resultados.csv.
#>
param(
    [Parameter(Mandatory)][string]$Dir,
    [string]$Tag = '',
    [switch]$SynthOnly,
    [switch]$Final,
    [string]$Part = 'xc7a100tcsg324-1',
    [int]$TimeoutMin = 60,
    [string]$VivadoBin = $(if ($env:VIVADO_BIN) { $env:VIVADO_BIN } else { 'D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin' })
)
$ErrorActionPreference = 'Stop'
$Dir = (Resolve-Path $Dir).Path
$CmpRoot = Split-Path -Parent $PSScriptRoot
$cfg = Import-PowerShellDataFile (Join-Path $Dir 'config.psd1')
if (-not $Tag) { $Tag = if ($Final) { 'final' } elseif ($SynthOnly) { 'synth' } else { 'teste' } }
$Out = Join-Path $Dir "build\$Tag"
New-Item -ItemType Directory -Force $Out | Out-Null
Get-ChildItem $Out -Force | Remove-Item -Recurse -Force

function Abs([string]$p) { $f = if ([IO.Path]::IsPathRooted($p)) { $p } else { Join-Path $Dir $p }; ((Resolve-Path $f).Path) -replace '\\', '/' }
foreach ($m in @($cfg.Mem)) { if ($m) { Copy-Item (Join-Path $Dir $m) $Out } }

# ---- TCL: mesmo fluxo do scripts/synth.ps1 + report_power ----------------------------
$read = New-Object System.Collections.Generic.List[string]
$inc = @($cfg.Include | Where-Object { $_ } | ForEach-Object { Abs $_ })
$def = @($cfg.Define | Where-Object { $_ })
$vopts = ''
if ($inc.Count) { $vopts += " -include_dirs {$($inc -join ' ')}" }
if ($def.Count) { $vopts += " -define {$($def -join ' ')}" }
foreach ($s in $cfg.Fontes) {
    $a = Abs $s
    switch -Regex ($a) {
        '\.svh?$'      { $read.Add("read_verilog -sv [list {$a}]") }
        '\.vh?$'       { $read.Add("read_verilog [list {$a}]") }
        '\.vhdl?$'     { $read.Add($(if ($cfg.Vhdl2008) { "read_vhdl -vhdl2008 [list {$a}]" } else { "read_vhdl [list {$a}]" })) }
        default        { throw "extensao desconhecida: $a" }
    }
}
foreach ($x in @($cfg.Xdc)) { if ($x) { $read.Add("read_xdc [list {$(Abs $x)}]") } }
$gen = @($cfg.Generics | Where-Object { $_ })
$genOpt = if ($gen.Count) { ' ' + (($gen | ForEach-Object { "-generic $_" }) -join ' ') } else { '' }
$incOpt = if ($inc.Count) { " -include_dirs {$($inc -join ' ')}" } else { '' }
$defOpt = if ($def.Count) { ' ' + (($def | ForEach-Object { "-verilog_define $_" }) -join ' ') } else { '' }
$impl = if ($SynthOnly) { '' } else { "opt_design`nplace_design`nroute_design" }
$tcl = @"
set_param general.maxThreads 8
$($read -join "`n")
synth_design -top $($cfg.Top) -part $Part$genOpt$incOpt$defOpt
$impl
report_timing_summary -max_paths 10 -file timing.rpt
report_timing -max_paths 20 -nworst 1 -path_type summary -file paths.rpt
report_utilization -file util.rpt
report_utilization -hierarchical -hierarchical_depth 4 -file util_hier.rpt
report_power -file power.rpt
report_methodology -file methodology.rpt
report_clocks -file clocks.rpt
"@
Set-Content -Path (Join-Path $Out 'run.tcl') -Value $tcl -Encoding ascii

# ---- concorrencia ----------------------------------------------------------------------
$slots = New-Object System.Threading.Semaphore(2, 2, 'Local\tcc_cmp_vivado_slots')
$held = 0; $mtx = $null
try {
    if ($Final) {
        $mtx = New-Object System.Threading.Mutex($false, 'Local\tcc_cmp_vivado_final')
        Write-Host 'Aguardando vez para medicao final (exclusiva)...'
        try { [void]$mtx.WaitOne() } catch [System.Threading.AbandonedMutexException] {}
        [void]$slots.WaitOne(); $held++; [void]$slots.WaitOne(); $held++
    } else {
        Write-Host 'Aguardando slot de Vivado...'
        [void]$slots.WaitOne(); $held++
    }
    $etapa = if ($SynthOnly) { 'sintese' } else { 'sintese + place + route' }
    Write-Host "Vivado ($etapa) em $Out ..."
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $p = Start-Process -FilePath (Join-Path $VivadoBin 'vivado.bat') `
        -ArgumentList '-mode', 'batch', '-nojournal', '-log', 'vivado.log', '-source', 'run.tcl' `
        -WorkingDirectory $Out -NoNewWindow -PassThru `
        -RedirectStandardOutput (Join-Path $Out 'stdout.txt') -RedirectStandardError (Join-Path $Out 'stderr.txt')
    $null = $p.Handle
    if (-not $p.WaitForExit($TimeoutMin * 60 * 1000)) {
        # vivado.bat -> vivado.exe -> ajudantes de sintese paralela: mata a arvore inteira.
        & taskkill /T /F /PID $p.Id *> $null
        Write-Host "TIMEOUT apos $TimeoutMin min"; exit 2
    }
    $sw.Stop()
} finally {
    while ($held -gt 0) { [void]$slots.Release(); $held-- }
    if ($mtx) { try { $mtx.ReleaseMutex() } catch {} }
}

$log = @(Get-Content (Join-Path $Out 'vivado.log') -ErrorAction SilentlyContinue)
$timingFile = Join-Path $Out 'timing.rpt'
if ($p.ExitCode -ne 0 -or -not (Test-Path $timingFile)) {
    Write-Host "Vivado falhou (codigo $($p.ExitCode)). Erros:"
    $log | Where-Object { $_ -match '^ERROR' } | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
    Write-Host "  log: $(Join-Path $Out 'vivado.log')"
    exit 2
}

# ---- timing ------------------------------------------------------------------------------
$t = @(Get-Content $timingFile)
$period = $null
foreach ($l in $t) { if ($l -match '^\S+\s+\{[\d.\s]+\}\s+([\d.]+)\s+[\d.]+\s*$') { $period = [double]$Matches[1]; break } }
$i = [array]::FindIndex([string[]]$t, [Predicate[string]]{ param($x) $x -match 'Design Timing Summary' })
while ($i -ge 0 -and $i -lt $t.Count -and $t[$i] -notmatch '^\s+-?[\d.]+\s+-?[\d.]+\s+\d+') { $i++ }
$v = ($t[$i].Trim() -split '\s+')
$wns = [double]$v[0]; $tns = [double]$v[1]; $failEp = [int]$v[2]; $totEp = [int]$v[3]
$whs = [double]$v[4]; $ths = [double]$v[5]; $failHold = [int]$v[6]
$fmax = if ($period) { [math]::Round(1000 / ($period - $wns), 1) } else { $null }
$noClock = [bool]($t | Where-Object { $_ -match 'There are \d+ register/latch pins with no clock' -and $_ -notmatch 'There are 0 ' })
$unconst = ($t | Where-Object { $_ -match 'There are (\d+) pins? that are not constrained for maximum delay' } | ForEach-Object { if ($_ -match 'There are (\d+)') { [int]$Matches[1] } } | Select-Object -First 1)

$crit = [ordered]@{}; $inMax = $false
foreach ($l in $t) {
    if ($l -match '^Max Delay Paths') { $inMax = $true; continue }
    if (-not $inMax) { continue }
    if ($l -match '^Min Delay Paths') { break }
    if ($l -match '^Slack.*?:\s+(-?[\d.]+)ns' -and -not $crit.Contains('Slack')) { $crit.Slack = [double]$Matches[1] }
    elseif ($l -match '^\s+Source:\s+(\S+)' -and -not $crit.Contains('Origem')) { $crit.Origem = $Matches[1] }
    elseif ($l -match '^\s+Destination:\s+(\S+)' -and -not $crit.Contains('Destino')) { $crit.Destino = $Matches[1] }
    elseif ($l -match '^\s+Data Path Delay:\s+([\d.]+)ns\s+\(logic ([\d.]+)ns.*route ([\d.]+)ns' -and -not $crit.Contains('Atraso')) {
        $crit.Atraso = [double]$Matches[1]; $crit.Logica = [double]$Matches[2]; $crit.Roteamento = [double]$Matches[3]
    }
    elseif ($l -match '^\s+Logic Levels:\s+(\d+)\s*(\(.*\))?' -and -not $crit.Contains('Niveis')) { $crit.Niveis = "$($Matches[1]) $($Matches[2])".Trim() }
}

# ---- area ----------------------------------------------------------------------------------
$u = @(Get-Content (Join-Path $Out 'util.rpt'))
function UtilVal([string]$name) {
    foreach ($l in $u) { if ($l -match "^\|\s*$([regex]::Escape($name))\*?\s*\|\s*([\d.]+)") { return [double]$Matches[1] } }
    return 0
}
$area = [ordered]@{
    LUTs = UtilVal 'Slice LUTs'; LUT_logica = UtilVal 'LUT as Logic'; LUTRAM = UtilVal 'LUT as Memory'
    FFs = UtilVal 'Slice Registers'; Latches = UtilVal 'Register as Latch'
    F7 = UtilVal 'F7 Muxes'; F8 = UtilVal 'F8 Muxes'; CARRY4 = 0; Slices = UtilVal 'Slice'
    BRAM = UtilVal 'Block RAM Tile'; DSP = UtilVal 'DSPs'; IOB = UtilVal 'Bonded IOB'; BUFG = UtilVal 'BUFGCTRL'
}
foreach ($l in $u) { if ($l -match '^\|\s*CARRY4\s*\|\s*(\d+)') { $area.CARRY4 = [int]$Matches[1] } }

# ---- potencia (report_power, vetorless, toggle padrao) --------------------------------------
$pw = [ordered]@{ Total_W = $null; Dinamica_W = $null; Estatica_W = $null; Tj_C = $null; Confianca = $null }
$pf = Join-Path $Out 'power.rpt'
if (Test-Path $pf) {
    foreach ($l in Get-Content $pf) {
        if ($l -match '^\|\s*Total On-Chip Power \(W\)\s*\|\s*([\d.]+)') { $pw.Total_W = [double]$Matches[1] }
        elseif ($l -match '^\|\s*Dynamic \(W\)\s*\|\s*([\d.]+)') { $pw.Dinamica_W = [double]$Matches[1] }
        elseif ($l -match '^\|\s*Device Static \(W\)\s*\|\s*([\d.]+)') { $pw.Estatica_W = [double]$Matches[1] }
        elseif ($l -match '^\|\s*Junction Temperature \(C\)\s*\|\s*([\d.]+)') { $pw.Tj_C = [double]$Matches[1] }
        elseif ($l -match '^\|\s*Confidence Level\s*\|\s*(\w+)') { $pw.Confianca = $Matches[1] }
    }
}
$pwDet = [ordered]@{}
if (Test-Path $pf) {
    $inOn = $false
    foreach ($l in Get-Content $pf) {
        if ($l -match '^1\.1 On-Chip Components') { $inOn = $true; continue }
        if ($inOn -and $l -match '^\d\.\d ') { break }
        if ($inOn -and $l -match '^\|\s*([A-Za-z/ ]+?)\s*\|\s*([\d.<]+)\s*\|') { $pwDet[$Matches[1]] = $Matches[2] }
    }
}

# ---- tempos por etapa e memoria (vivado.log) ------------------------------------------------
$etapas = [ordered]@{}
foreach ($l in $log) {
    if ($l -match '^(synth_design|opt_design|place_design|route_design|report_power): Time \(s\): cpu = ([\d:]+) ; elapsed = ([\d:]+) \. Memory \(MB\): peak = ([\d.]+)') {
        $etapas[$Matches[1]] = [ordered]@{ cpu = $Matches[2]; elapsed = $Matches[3]; peak_MB = [double]$Matches[4] }
    }
}
$peak = ($etapas.Values | ForEach-Object { $_.peak_MB } | Measure-Object -Maximum).Maximum
$warn = @($log | Where-Object { $_ -match '^WARNING' }).Count
$critWarn = @($log | Where-Object { $_ -match '^CRITICAL WARNING' })
$latchLog = @($log | Where-Object { $_ -match 'Synth 8-327|inferring latch' }).Count
$ramInfer = @($log | Where-Object { $_ -match 'Synth 8-(3971|4767|5583|6904|7030|7052)|RAM .* implemented|Distributed RAM|Block RAM' } | Select-Object -First 10)

$meth = @()
$mf = Join-Path $Out 'methodology.rpt'
if (Test-Path $mf) { foreach ($l in Get-Content $mf) { if ($l -match '^\|\s*([A-Z]+-\d+)\s*\|\s*([\w ]+?)\s*\|\s*(.+?)\s*\|\s*(\d+)\s*\|') { $meth += "$($Matches[1]) [$($Matches[2])] $($Matches[3]): $($Matches[4])" } } }

$m = [ordered]@{
    Nome = $cfg.Nome; Pasta = Split-Path $Dir -Leaf; Tag = $Tag; Data = (Get-Date -Format 'yyyy-MM-dd HH:mm')
    Etapa = $(if ($SynthOnly) { 'synth' } else { 'route' }); Final = [bool]$Final; Part = $Part; Top = $cfg.Top
    Tempo_total_s = [math]::Round($sw.Elapsed.TotalSeconds, 1)
    Periodo_ns = $period; WNS_ns = $wns; TNS_ns = $tns; Endpoints_violando = $failEp; Endpoints_total = $totEp
    WHS_ns = $whs; THS_ns = $ths; Hold_violando = $failHold; Fmax_MHz = $fmax
    Pinos_sem_restricao_max = $unconst; Registradores_sem_clock = $noClock
    Caminho_critico = $crit; Area = $area; Potencia = $pw; Potencia_componentes = $pwDet
    Etapas = $etapas; Memoria_pico_MB = $peak
    Warnings = $warn; Critical_warnings = $critWarn.Count; Latches_log = $latchLog
    Methodology = $meth; Inferencia_memoria = $ramInfer
}
($m | ConvertTo-Json -Depth 6) | Set-Content -Path (Join-Path $Out 'metricas.json') -Encoding utf8

$r = New-Object System.Collections.Generic.List[string]
$r.Add("$($cfg.Nome)  |  tag $Tag  |  $($m.Etapa)  |  $($m.Tempo_total_s) s  |  pico $peak MB")
$r.Add(('Timing: periodo {0} ns | WNS {1} | TNS {2} | violando {3}/{4} | WHS {5} | THS {6} | Fmax {7} MHz' -f $period, $wns, $tns, $failEp, $totEp, $whs, $ths, $fmax))
$r.Add(('Caminho critico: {0} ns (logica {1} / rota {2}) niveis {3}' -f $crit.Atraso, $crit.Logica, $crit.Roteamento, $crit.Niveis))
$r.Add("   de:   $($crit.Origem)"); $r.Add("   para: $($crit.Destino)")
$r.Add(('Area: LUTs {0} (logica {1}, LUTRAM {2}) | FFs {3} | latches {4} | F7 {5} | F8 {6} | CARRY4 {7} | Slices {8} | BRAM {9} | DSP {10} | IOB {11}' -f $area.LUTs, $area.LUT_logica, $area.LUTRAM, $area.FFs, $area.Latches, $area.F7, $area.F8, $area.CARRY4, $area.Slices, $area.BRAM, $area.DSP, $area.IOB))
$r.Add(('Potencia: total {0} W | dinamica {1} W | estatica {2} W | Tj {3} C | confianca {4}' -f $pw.Total_W, $pw.Dinamica_W, $pw.Estatica_W, $pw.Tj_C, $pw.Confianca))
$r.Add('Etapas: ' + (($etapas.Keys | ForEach-Object { "$_ $($etapas[$_].elapsed)" }) -join ' | '))
$r.Add("Warnings $warn | CRITICAL $($critWarn.Count) | latches(log) $latchLog | pinos sem restricao de max delay: $unconst | regs sem clock: $noClock")
foreach ($x in $meth) { $r.Add("   $x") }
foreach ($x in $critWarn | Select-Object -First 5) { $r.Add("   $x") }
[IO.File]::WriteAllLines((Join-Path $Out 'resumo.txt'), $r, (New-Object System.Text.UTF8Encoding $false))
$r | ForEach-Object { Write-Host $_ }

if ($Final) {
    $row = [pscustomobject]@{
        Data = $m.Data; Pasta = $m.Pasta; Nome = $m.Nome; Tempo_s = $m.Tempo_total_s
        WNS = $wns; TNS = $tns; Violando = $failEp; WHS = $whs; Fmax_MHz = $fmax; Caminho_ns = $crit.Atraso; Niveis = $crit.Niveis
        LUTs = $area.LUTs; LUTRAM = $area.LUTRAM; FFs = $area.FFs; F7 = $area.F7; F8 = $area.F8; CARRY4 = $area.CARRY4
        Slices = $area.Slices; BRAM = $area.BRAM; DSP = $area.DSP; IOB = $area.IOB
        P_total_W = $pw.Total_W; P_dyn_W = $pw.Dinamica_W; P_stat_W = $pw.Estatica_W; Pico_MB = $peak
    }
    $row | Export-Csv -Path (Join-Path $CmpRoot 'resultados.csv') -Append -NoTypeInformation -Encoding UTF8
}
exit [int]($wns -lt 0)
