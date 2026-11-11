<#
.SYNOPSIS
    Sintetiza (e implementa) o top_core no Vivado em modo batch, sem usar nem alterar o .xpr,
    e resume timing e area. Ferramenta de medicao para otimizar o circuito.

.EXAMPLE
    .\scripts\synth.ps1                       # sintese + place + route, saida em build/synth/atual/
    .\scripts\synth.ps1 -Tag antes_regfile    # guarda numa pasta propria (comparar A/B)
    .\scripts\synth.ps1 -SynthOnly            # so sintese (rapido; timing apenas estimado)
    .\scripts\synth.ps1 -Tag teste -PhysOpt   # acrescenta phys_opt_design entre place e route
    .\scripts\synth.ps1 -Tag teste -PlaceDirective Explore -RouteDirective Explore   # diretivas da ferramenta
    .\scripts\synth.ps1 -Tag teste -MaxEffort # esforco maximo (= estrategia Performance_ExplorePostRoutePhysOpt
                                              #   da GUI com opt_design ExploreWithRemap)
    .\scripts\synth.ps1 -Compare              # tabela com o historico de execucoes
    .\scripts\synth.ps1 -Tag base -ParseOnly  # refaz o resumo de um run existente (sem Vivado)

.NOTES
    Le as fontes de sources_1/new e o XDC de constrs_1 diretamente (non-project mode).
    Saida em build/synth/<Tag>/ (ignorado pelo git):
      resumo.txt, timing.rpt (timing summary com 10 piores caminhos), paths.rpt (20 caminhos em
      tabela), util.rpt, util_hier.rpt (area por modulo), vivado.log
    Cada execucao acrescenta uma linha em build/synth/historico.csv.
    Codigo de saida: 0 se o timing fecha (WNS >= 0), 1 se viola, 2 se o Vivado falhou.
#>
param(
    [string]$Tag = 'atual',
    [switch]$SynthOnly,
    [switch]$PhysOpt,            # roda phys_opt_design depois do place (replicacao de fanout alto)
    [string]$SynthDirective = '', # -directive do synth_design (ex.: PerformanceOptimized)
    [string]$PlaceDirective = '', # -directive do place_design (ex.: Explore, ExtraTimingOpt)
    [string]$RouteDirective = '', # -directive do route_design (ex.: Explore)
    [switch]$MaxEffort,          # opt ExploreWithRemap, place/phys_opt/route Explore e phys_opt depois do route
    [switch]$Compare,
    [switch]$ParseOnly,          # rele os relatorios de build/synth/<Tag> sem rodar o Vivado
    # Programa carregado nas memorias. A sintese otimiza o core PARA ESSE PROGRAMA (a IMEM e
    # uma ROM conhecida): programa pequeno => logica nao usada e removida e o resultado nao
    # representa o processador. 'placa' = .mem de sources_1/imports/new (o que vai para a placa);
    # outro nome = sw/apps/<nome> compilado com build_sw.ps1.
    [string]$App = 'selftest',
    [string]$Part = 'xc7a100tcsg324-1',
    [string]$Top = 'top_core',
    [int]$TimeoutMin = 60,
    [string]$VivadoBin = $(if ($env:VIVADO_BIN) { $env:VIVADO_BIN } else { 'D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin' })
)

$ErrorActionPreference = 'Stop'
$Root   = Split-Path -Parent $PSScriptRoot
$Rtl    = Join-Path $Root 'processador_riscV.srcs\sources_1\new'
$MemDir = Join-Path $Root 'processador_riscV.srcs\sources_1\imports\new'
$Xdc    = Join-Path $Root 'processador_riscV.srcs\constrs_1\imports\constraints\Nexys-A7-100T-Master.xdc'
$Base   = Join-Path $Root 'build\synth'
$Hist   = Join-Path $Base 'historico.csv'

if ($Compare) {
    if (-not (Test-Path $Hist)) { Write-Host 'Sem historico ainda.'; exit 0 }
    Import-Csv $Hist | Format-Table -AutoSize
    exit 0
}

# Ordem: packages antes dos modulos que os importam.
$Pkgs = 'opcode_pkg', 'func3_pkg', 'func7_pkg', 'alu_pkg', 'branch_pkg', 'mem_pkg'
$Mods = 'alu', 'control_unit', 'imm_gen', 'register_file', 'decoder', 'execution',
        'instruction_memory', 'search', 'data_memory', 'write_back', 'core', 'top_core'
$Srcs = @($Pkgs + $Mods | ForEach-Object { (Join-Path $Rtl "$_.sv") -replace '\\', '/' })

$Out = Join-Path $Base $Tag
$sw = [Diagnostics.Stopwatch]::StartNew()
if ($ParseOnly) {
    if (-not (Test-Path (Join-Path $Out 'timing.rpt'))) { Write-Error "Nada para reler em $Out" }
    $p = [pscustomobject]@{ ExitCode = 0 }
} else {
New-Item -ItemType Directory -Force $Out | Out-Null
Get-ChildItem $Out -Force | Remove-Item -Recurse -Force
# $readmemh resolve caminhos relativos ao diretorio de execucao do Vivado.
if ($App -eq 'placa') {
    Copy-Item (Join-Path $MemDir '*.mem') $Out
} else {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build_sw.ps1') $App *> (Join-Path $Out 'build_sw.txt')
    if ($LASTEXITCODE -ne 0) { Write-Error "build_sw.ps1 $App falhou (ver $(Join-Path $Out 'build_sw.txt'))" }
    Copy-Item (Join-Path $Root "build\sw\$App\*.mem") $Out
}
Set-Content -Path (Join-Path $Out 'app.txt') -Value $App -Encoding ascii

# Esforco maximo: o phys_opt depois do route e o que mais rende (replica e reposiciona
# celulas dos caminhos criticos ja roteados).
$optDirective = ''
$postRoutePhysOpt = ''
if ($MaxEffort) {
    $optDirective = 'ExploreWithRemap'
    if (-not $PlaceDirective) { $PlaceDirective = 'Explore' }
    if (-not $RouteDirective) { $RouteDirective = 'Explore' }
    $postRoutePhysOpt = 'phys_opt_design -directive Explore'
}
$physOptCmd = if ($MaxEffort) { 'phys_opt_design -directive Explore' } elseif ($PhysOpt) { 'phys_opt_design' } else { '' }
function Directive([string]$d) { if ($d) { " -directive $d" } else { '' } }
$impl = if ($SynthOnly) { '' } else { @"
opt_design$(Directive $optDirective)
place_design$(Directive $PlaceDirective)
$physOptCmd
route_design$(Directive $RouteDirective)
$postRoutePhysOpt
"@ }

$tcl = @"
set_param general.maxThreads 8
read_verilog -sv {$($Srcs -join ' ')}
read_xdc {$($Xdc -replace '\\', '/')}
synth_design -top $Top -part $Part$(Directive $SynthDirective)
$impl
report_timing_summary -max_paths 10 -file timing.rpt
report_timing -max_paths 20 -nworst 1 -path_type summary -file paths.rpt
report_utilization -file util.rpt
report_utilization -hierarchical -hierarchical_depth 4 -file util_hier.rpt
report_methodology -file methodology.rpt
"@
Set-Content -Path (Join-Path $Out 'run.tcl') -Value $tcl -Encoding ascii

$etapa = if ($SynthOnly) { 'sintese' } else { 'sintese + place + route' }
Write-Host "Vivado ($etapa) em $Out ..."
$p = Start-Process -FilePath (Join-Path $VivadoBin 'vivado.bat') `
    -ArgumentList '-mode', 'batch', '-nojournal', '-log', 'vivado.log', '-source', 'run.tcl' `
    -WorkingDirectory $Out -NoNewWindow -PassThru `
    -RedirectStandardOutput (Join-Path $Out 'stdout.txt') -RedirectStandardError (Join-Path $Out 'stderr.txt')
$null = $p.Handle
if (-not $p.WaitForExit($TimeoutMin * 60 * 1000)) {
    try { $p.Kill() } catch {}
    Write-Host "TIMEOUT apos $TimeoutMin min" -ForegroundColor Red; exit 2
}
}
$sw.Stop()
if ($ParseOnly) {
    $SynthOnly = -not (Select-String -Path (Join-Path $Out 'run.tcl') -Pattern 'route_design' -Quiet)
    $MaxEffort = [bool](Select-String -Path (Join-Path $Out 'run.tcl') -Pattern 'ExploreWithRemap' -Quiet)
}

$log = Get-Content (Join-Path $Out 'vivado.log') -ErrorAction SilentlyContinue
$timingFile = Join-Path $Out 'timing.rpt'
if ($p.ExitCode -ne 0 -or -not (Test-Path $timingFile)) {
    Write-Host "Vivado falhou (codigo $($p.ExitCode)). Erros:" -ForegroundColor Red
    $log | Where-Object { $_ -match '^ERROR' } | Select-Object -First 15 | ForEach-Object { Write-Host "  $_" }
    Write-Host "  log: $(Join-Path $Out 'vivado.log')"
    exit 2
}

# ---- timing ---------------------------------------------------------------------
$t = Get-Content $timingFile
$period = $null
foreach ($l in $t) { if ($l -match '^\S+\s+\{[\d.\s]+\}\s+([\d.]+)\s+[\d.]+\s*$') { $period = [double]$Matches[1]; break } }
# Primeira linha numerica depois do cabecalho "Design Timing Summary".
$i = [array]::FindIndex([string[]]$t, [Predicate[string]]{ param($x) $x -match 'Design Timing Summary' })
while ($i -lt $t.Count -and $t[$i] -notmatch '^\s+-?[\d.]+\s+-?[\d.]+\s+\d+') { $i++ }
$vals = ($t[$i].Trim() -split '\s+')
$wns = [double]$vals[0]; $tns = [double]$vals[1]; $failEp = [int]$vals[2]; $whs = [double]$vals[4]
$fmax = if ($period) { [math]::Round(1000 / ($period - $wns), 1) } else { $null }

# Piores caminhos de setup (bloco "Max Delay Paths").
$paths = @(); $cur = $null; $inMax = $false
foreach ($l in $t) {
    if ($l -match '^Max Delay Paths') { $inMax = $true; continue }
    if ($l -match '^Min Delay Paths') { $inMax = $false }
    if (-not $inMax) { continue }
    if ($l -match '^Slack.*?:\s+(-?[\d.]+)ns') { $cur = [ordered]@{ Slack = [double]$Matches[1] }; $paths += $cur }
    elseif ($cur -and $l -match '^\s+Source:\s+(\S+)') { $cur.Origem = $Matches[1] }
    elseif ($cur -and $l -match '^\s+Destination:\s+(\S+)') { $cur.Destino = $Matches[1] }
    elseif ($cur -and $l -match '^\s+Data Path Delay:\s+([\d.]+)ns\s+\(logic ([\d.]+)ns.*route ([\d.]+)ns') {
        $cur.Atraso = [double]$Matches[1]; $cur.Logica = [double]$Matches[2]; $cur.Roteamento = [double]$Matches[3]
    }
    elseif ($cur -and $l -match '^\s+Logic Levels:\s+(\d+)\s*(\(.*\))?') { $cur.Niveis = "$($Matches[1]) $($Matches[2])" }
}

# ---- area -------------------------------------------------------------------------
$u = Get-Content (Join-Path $Out 'util.rpt')
function UtilVal([string]$name) {
    foreach ($l in $u) { if ($l -match "^\|\s*$([regex]::Escape($name))\s*\|\s*([\d.]+)") { return $Matches[1] } }
    return '0'
}
$luts = UtilVal 'Slice LUTs'; if ($luts -eq '0') { $luts = UtilVal 'Slice LUTs*' }
$lutram = UtilVal 'LUT as Memory'
$ffs  = UtilVal 'Slice Registers'
$bram = UtilVal 'Block RAM Tile'
$dsp  = UtilVal 'DSPs'
$f7   = UtilVal 'F7 Muxes'
$f8   = UtilVal 'F8 Muxes'

# Latches inferidos e avisos criticos (no log da sintese).
$latches  = @($log | Where-Object { $_ -match 'Synth 8-327|inferring latch' })
$critWarn = @($log | Where-Object { $_ -match '^CRITICAL WARNING' })

# Regras violadas no report_methodology (tabela "| ID | Severity | Description | Violations |").
$meth = @()
$methFile = Join-Path $Out 'methodology.rpt'
if (Test-Path $methFile) {
    foreach ($l in Get-Content $methFile) {
        if ($l -match '^\|\s*([A-Z]+-\d+)\s*\|\s*([\w ]+?)\s*\|\s*(.+?)\s*\|\s*(\d+)\s*\|') {
            $meth += [pscustomobject]@{ Id = $Matches[1]; Sev = $Matches[2]; Desc = $Matches[3]; N = [int]$Matches[4] }
        }
    }
}

# ---- resumo -------------------------------------------------------------------------
$etapaRpt = if ($SynthOnly) { 'pos-sintese (estimativa, sem roteamento)' } elseif ($MaxEffort) { 'pos-roteamento, esforco maximo' } else { 'pos-roteamento' }
$r = New-Object System.Collections.Generic.List[string]
$appUsed = if (Test-Path (Join-Path $Out 'app.txt')) { (Get-Content (Join-Path $Out 'app.txt')).Trim() } else { 'placa' }
$r.Add("Tag: $Tag  |  programa: $appUsed  |  $etapaRpt  |  $([math]::Round($sw.Elapsed.TotalMinutes,1)) min")
$r.Add(('Timing: periodo {0} ns | WNS {1} ns | TNS {2} ns | endpoints violando {3} | WHS {4} ns | Fmax estimada {5} MHz' -f $period, $wns, $tns, $failEp, $whs, $fmax))
$r.Add("Area: LUTs $luts (LUTRAM $lutram) | FFs $ffs | BRAM $bram | DSP $dsp | F7 $f7 | F8 $f8")
$r.Add("Latches inferidos: $($latches.Count) | CRITICAL WARNINGs: $($critWarn.Count)")
if (Test-Path $methFile) {
    $r.Add("Methodology: $($meth.Count) regras violadas (ver methodology.rpt)")
    foreach ($m in $meth) { $r.Add(("   {0} [{1}] {2}: {3}" -f $m.Id, $m.Sev, $m.Desc, $m.N)) }
}
$r.Add('')
$r.Add('Piores caminhos (setup):')
$n = 0
foreach ($pp in $paths | Select-Object -First 5) {
    $n++
    $r.Add(('{0}. slack {1} ns | atraso {2} ns (logica {3} / roteamento {4}) | niveis {5}' -f $n, $pp.Slack, $pp.Atraso, $pp.Logica, $pp.Roteamento, $pp.Niveis))
    $r.Add("   de:   $($pp.Origem)")
    $r.Add("   para: $($pp.Destino)")
}
foreach ($l in $latches | Select-Object -First 5) { $r.Add("LATCH: $l") }
foreach ($l in $critWarn | Select-Object -First 5) { $r.Add("$l") }
$r.Add('')
$r.Add('Area por modulo: util_hier.rpt | caminhos: timing.rpt, paths.rpt | log: vivado.log')

[IO.File]::WriteAllLines((Join-Path $Out 'resumo.txt'), $r, (New-Object System.Text.UTF8Encoding $false))
$r | ForEach-Object { Write-Host $_ }

# ---- historico ------------------------------------------------------------------------
$row = [pscustomobject]@{
    Data = (Get-Date -Format 'yyyy-MM-dd HH:mm'); Tag = $Tag; Programa = $appUsed; Etapa =$(if ($SynthOnly) { 'synth' } elseif ($MaxEffort) { 'route-max' } else { 'route' })
    WNS = $wns; TNS = $tns; Fmax_MHz = $fmax; LUTs = $luts; FFs = $ffs; BRAM = $bram; DSP = $dsp; Latches = $latches.Count
}
$row | Export-Csv -Path $Hist -Append -NoTypeInformation -Encoding UTF8

exit [int]($wns -lt 0)
