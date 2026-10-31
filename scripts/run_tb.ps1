<#
.SYNOPSIS
    Compila e simula testbenches do projeto com o xsim (fora da GUI do Vivado).

.EXAMPLE
    .\scripts\run_tb.ps1                 # roda todos
    .\scripts\run_tb.ps1 tb_alu tb_decoder
    .\scripts\run_tb.ps1 -List
    .\scripts\run_tb.ps1 tb_alu -ShowLog # mostra a saida completa da simulacao

.NOTES
    Saida de cada testbench em build/sim/<tb>/ (ignorado pelo git).
    Codigo de saida: 0 se todos passaram, 1 caso contrario.
#>
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Testbench,
    [switch]$List,
    [switch]$ShowLog,
    [int]$TimeoutSec = 120,
    [string]$VivadoBin = $(if ($env:VIVADO_BIN) { $env:VIVADO_BIN } else { 'D:\ProgramFiles\AMDVitis\2025.2\Vivado\bin' })
)

$ErrorActionPreference = 'Stop'
$Root  = Split-Path -Parent $PSScriptRoot
$Rtl   = Join-Path $Root 'processador_riscV.srcs\sources_1\new'
$Sim   = Join-Path $Root 'processador_riscV.srcs\sim_1\new'
$SimIm = Join-Path $Root 'processador_riscV.srcs\sim_1\imports\new'
$Build = Join-Path $Root 'build\sim'
# Imagens de memoria referenciadas pelo .xpr (sintese e simulacao).
$MemDir = Join-Path $Root 'processador_riscV.srcs\sources_1\imports\new'

$Pkgs = @('opcode_pkg', 'func3_pkg', 'func7_pkg', 'alu_pkg', 'branch_pkg', 'mem_pkg') |
    ForEach-Object { Join-Path $Rtl "$_.sv" }

# Fontes de cada testbench (alem dos packages). A ordem importa:
# DUT e submodulos antes do testbench.
function Src([string]$tbDir, [string]$tb, [string[]]$dut) {
    @($dut | ForEach-Object { Join-Path $Rtl "$_.sv" }) + @(Join-Path $tbDir "$tb.sv")
}
$Tests = [ordered]@{
    tb_alu               = Src $Sim   tb_alu               @('alu')
    tb_control_unit      = Src $SimIm tb_control_unit      @('control_unit')
    # Sistema completo: programa RV32I executado no core.
    tb_core              = Src $Sim   tb_core              @('alu', 'control_unit', 'imm_gen', 'register_file',
                                                             'decoder', 'execution', 'instruction_memory',
                                                             'search', 'data_memory', 'write_back', 'core')
    tb_data_memory       = Src $Sim   tb_data_memory       @('data_memory')
    tb_decoder           = Src $Sim   tb_decoder           @('register_file', 'imm_gen', 'control_unit', 'decoder')
    tb_execution         = Src $Sim   tb_execution         @('alu', 'execution')
    # tb_instruction_fetch define seu proprio modelo de instruction_memory.
    tb_instruction_fetch = Src $Sim   tb_instruction_fetch @('search')
    tb_register_file     = Src $Sim   tb_register_file     @('register_file')
    tb_write_back        = Src $SimIm tb_write_back        @('write_back')
    # Programa C (sw/apps/selftest) compilado com riscv-gcc e executado no core.
    tb_program           = Src $Sim   tb_program           @('alu', 'control_unit', 'imm_gen', 'register_file',
                                                             'decoder', 'execution', 'instruction_memory',
                                                             'search', 'data_memory', 'write_back', 'core')
}

# Testbenches que usam um programa compilado (scripts/build_sw.ps1) em vez dos
# .mem de sources_1/imports/new. O programa e recompilado antes de simular.
$Programs = @{
    tb_program = 'selftest'
}

if ($List) { $Tests.Keys; exit 0 }
if (-not $Testbench -or $Testbench -contains 'all') { $Testbench = @($Tests.Keys) }

foreach ($tb in $Testbench) {
    if (-not $Tests.Contains($tb)) { Write-Error "Testbench desconhecido: $tb (use -List)" }
}
foreach ($tool in 'xvlog', 'xelab', 'xsim') {
    if (-not (Test-Path (Join-Path $VivadoBin "$tool.bat"))) {
        Write-Error "$tool.bat nao encontrado em $VivadoBin (ajuste -VivadoBin ou `$env:VIVADO_BIN)"
    }
}

# Executa uma ferramenta do Vivado com stdout/stderr em arquivo e timeout.
function Invoke-Tool([string]$tool, [string[]]$toolArgs, [string]$dir, [string]$logName) {
    $out = Join-Path $dir "$logName.txt"
    $err = Join-Path $dir "$logName.err.txt"
    $quoted = $toolArgs | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }
    $p = Start-Process -FilePath (Join-Path $VivadoBin "$tool.bat") -ArgumentList $quoted `
        -WorkingDirectory $dir -NoNewWindow -PassThru `
        -RedirectStandardOutput $out -RedirectStandardError $err
    $null = $p.Handle  # sem isso o PowerShell 5.1 perde o ExitCode
    if (-not $p.WaitForExit($TimeoutSec * 1000)) {
        Get-Process xsimk, xsim -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        try { $p.Kill() } catch {}
        return @{ Ok = $false; Text = "TIMEOUT apos $TimeoutSec s"; Log = $out }
    }
    $text = (Get-Content $out -Raw -ErrorAction SilentlyContinue) + (Get-Content $err -Raw -ErrorAction SilentlyContinue)
    return @{ Ok = ($p.ExitCode -eq 0 -and $text -notmatch 'ERROR:'); Text = $text; Log = $out }
}

$results = @()
foreach ($tb in $Testbench) {
    $dir = Join-Path $Build $tb
    New-Item -ItemType Directory -Force $dir | Out-Null
    Get-ChildItem $dir -Force | Remove-Item -Recurse -Force
    Write-Host -NoNewline ("{0,-22} " -f $tb)
    $status = 'PASS'; $detail = ''; $r = $null

    # $readmemh resolve caminhos relativos ao diretorio de execucao.
    if ($Programs.Contains($tb)) {
        $app = $Programs[$tb]
        $log = Join-Path $dir 'build_sw.txt'
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build_sw.ps1') $app *> $log
        if ($LASTEXITCODE -ne 0) {
            $status = 'BUILD'; $detail = @{ Text = (Get-Content $log -Raw); Log = $log }
        } else {
            Copy-Item (Join-Path $Root "build\sw\$app\*.mem") $dir
        }
    } else {
        Copy-Item (Join-Path $MemDir '*.mem') $dir
    }

    if ($status -eq 'PASS') {
        $r = Invoke-Tool 'xvlog' (@('--sv', '--relax') + $Pkgs + $Tests[$tb]) $dir 'compile'
        if (-not $r.Ok) { $status = 'COMPILE'; $detail = $r }
        else {
            $r = Invoke-Tool 'xelab' @('--relax', '--debug', 'typical', $tb, '-s', "${tb}_sim") $dir 'elaborate'
            if (-not $r.Ok) { $status = 'ELAB'; $detail = $r }
            else {
                $r = Invoke-Tool 'xsim' @("${tb}_sim", '-R') $dir 'simulate'
                $passed = $r.Text -match 'PASSOU|STATUS: SUCCESS'
                $failed = $r.Text -match 'FALHOU|STATUS: FAILED|\[FAIL\]|\[ERRO'
                if (-not $r.Ok)                   { $status = 'SIM'; $detail = $r }
                elseif ($failed -or -not $passed) { $status = 'FAIL'; $detail = $r }
            }
        }
    }

    $color = if ($status -eq 'PASS') { 'Green' } else { 'Red' }
    Write-Host $status -ForegroundColor $color
    if ($detail) {
        # Mostra as linhas relevantes do erro/falha.
        $detail.Text -split "`r?`n" |
            Where-Object { $_ -match 'ERROR|FAIL|ERRO|FALHOU|TIMEOUT' } |
            Select-Object -First 15 | ForEach-Object { Write-Host "    $_" }
        Write-Host "    log: $($detail.Log)"
    }
    if ($ShowLog -and $r) { $r.Text }
    $results += [pscustomobject]@{ Testbench = $tb; Status = $status }
}

$failedCount = @($results | Where-Object Status -ne 'PASS').Count
Write-Host ''
Write-Host ("{0}/{1} testbenches passaram" -f ($results.Count - $failedCount), $results.Count) `
    -ForegroundColor $(if ($failedCount) { 'Red' } else { 'Green' })
exit [int]($failedCount -gt 0)
