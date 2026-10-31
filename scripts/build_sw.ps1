<#
.SYNOPSIS
    Compila um programa C/assembly de sw/apps/<app> com o riscv-none-elf-gcc e gera
    program_bytes.mem (instrucoes) e data.mem (dados) no formato do $readmemh do core.

.EXAMPLE
    .\scripts\build_sw.ps1 selftest            # gera build/sw/selftest/*.mem
    .\scripts\build_sw.ps1 leds -Install       # tambem copia para sources_1/imports/new (sintese/GUI)
    .\scripts\build_sw.ps1 -List

.NOTES
    Saida em build/sw/<app>/ (ignorado pelo git):
      <app>.elf, <app>.map, <app>.lst (disassembly), program_bytes.mem, data.mem
    program_bytes.mem: uma palavra de 32 bits por linha (+ comentario com a instrucao).
    data.mem: um byte por token, em ordem de endereco (byte do endereco 0 primeiro).
    -Install guarda os .mem atuais em build/sw/_backup/<data-hora>/ antes de sobrescrever.
#>
param(
    [Parameter(Position = 0)]
    [string]$App,
    [switch]$Install,
    [switch]$List,
    [string]$Opt = '-Os',
    [string]$GccBin = $(if ($env:RISCV_GCC_BIN) { $env:RISCV_GCC_BIN } else { 'D:\ProgramFiles\xpack-riscv-none-elf-gcc-15.2.0-1\bin' })
)

$ErrorActionPreference = 'Stop'
$Root   = Split-Path -Parent $PSScriptRoot
$Common = Join-Path $Root 'sw\common'
$Apps   = Join-Path $Root 'sw\apps'
$MemDir = Join-Path $Root 'processador_riscV.srcs\sources_1\imports\new'
# Tamanho de cada memoria (MEM_DEPTH = 1024 palavras). Manter igual ao link.ld.
$MemBytes = 4096
$StackMargin = 256

if ($List -or -not $App) {
    Get-ChildItem $Apps -Directory | ForEach-Object Name
    if (-not $List) { Write-Error 'Informe o programa (pasta em sw/apps).' }
    exit 0
}

$AppDir = Join-Path $Apps $App
if (-not (Test-Path $AppDir)) { Write-Error "Programa nao encontrado: $AppDir (use -List)" }

$gcc     = Join-Path $GccBin 'riscv-none-elf-gcc.exe'
$objcopy = Join-Path $GccBin 'riscv-none-elf-objcopy.exe'
$objdump = Join-Path $GccBin 'riscv-none-elf-objdump.exe'
$nm      = Join-Path $GccBin 'riscv-none-elf-nm.exe'
if (-not (Test-Path $gcc)) { Write-Error "riscv-none-elf-gcc nao encontrado em $GccBin (ajuste -GccBin ou `$env:RISCV_GCC_BIN)" }

$Out = Join-Path $Root "build\sw\$App"
New-Item -ItemType Directory -Force $Out | Out-Null
$elf = Join-Path $Out "$App.elf"

function Run([string]$exe, [string[]]$a) {
    & $exe @a
    if ($LASTEXITCODE -ne 0) { Write-Error "falhou: $(Split-Path -Leaf $exe) $($a -join ' ')" }
}

# ---- compilacao + link -------------------------------------------------------
$srcs = @((Join-Path $Common 'crt0.S'), (Join-Path $Common 'libc_min.c')) +
        @(Get-ChildItem $AppDir -File -Include *.c, *.S, *.s -Recurse | ForEach-Object FullName)

$flags = @(
    '-march=rv32i', '-mabi=ilp32', $Opt, '-g', '-Wall', '-Wextra',
    '-ffreestanding', '-nostdlib', '-nostartfiles',
    '-msmall-data-limit=0',                 # sem .sdata/gp: tudo enderecado com lui/addi
    '-fno-tree-loop-distribute-patterns',   # impede o GCC de trocar o laco do memcpy por memcpy()
    '-ffunction-sections', '-fdata-sections',
    "-I$Common",
    '-T', (Join-Path $Common 'link.ld'),
    "-Wl,--gc-sections,--no-check-sections,-Map=$(Join-Path $Out "$App.map")",
    '-o', $elf
)
Run $gcc ($flags + $srcs + @('-lgcc'))

# ---- disassembly ---------------------------------------------------------------
& $objdump -d -S $elf | Set-Content -Encoding ascii (Join-Path $Out "$App.lst")

# Mapa endereco -> "instrucao" (e nome da funcao na primeira instrucao).
$asm = @{}; $label = $null
foreach ($l in (& $objdump -d $elf)) {
    if ($l -match '^[0-9a-f]+ <(.+)>:$') { $label = $Matches[1]; continue }
    if ($l -match '^\s*([0-9a-f]+):\s+[0-9a-f]{8}\s+(.+)$') {
        $addr = [Convert]::ToUInt32($Matches[1], 16)
        # Tira "<simbolo+off>": IMEM e DMEM comecam em 0, entao o objdump
        # rotularia alvos de branch com nomes de variaveis.
        $txt  = ($Matches[2] -replace ' ?<[^>]+>', '' -replace '\s+', ' ').Trim()
        if ($label) { $txt = "<$label> $txt"; $label = $null }
        $asm[$addr] = $txt
    }
}

# ---- binarios por memoria --------------------------------------------------------
$textBin = Join-Path $Out 'text.bin'
$dataBin = Join-Path $Out 'data.bin'
Run $objcopy @('-O', 'binary', '-j', '.text', $elf, $textBin)
Run $objcopy @('-O', 'binary', '-j', '.rodata', '-j', '.data', $elf, $dataBin)

$text = [IO.File]::ReadAllBytes($textBin)
$data = if (Test-Path $dataBin) { [IO.File]::ReadAllBytes($dataBin) } else { [byte[]]@() }

# Fim da .bss (dados + bss precisam caber deixando espaco para a pilha).
$bssEnd = 0
foreach ($l in (& $nm $elf)) {
    if ($l -match '^([0-9a-f]+) \S __bss_end$') { $bssEnd = [Convert]::ToUInt32($Matches[1], 16) }
}

if ($text.Length -gt $MemBytes) { Write-Error "codigo ($($text.Length) B) nao cabe na IMEM ($MemBytes B)" }
if ($bssEnd -gt $MemBytes - $StackMargin) {
    Write-Error "dados+bss ate 0x$('{0:X}' -f $bssEnd) deixam menos de $StackMargin B para a pilha (DMEM = $MemBytes B)"
}

# ---- program_bytes.mem: uma palavra por linha ------------------------------------
$pad = (4 - $text.Length % 4) % 4
if ($pad) { $text = $text + (New-Object byte[] $pad) }
$imem = New-Object System.Collections.Generic.List[string]
$imem.Add("// $App - gerado por scripts/build_sw.ps1 (nao editar a mao)")
for ($i = 0; $i -lt $text.Length; $i += 4) {
    $w = [BitConverter]::ToUInt32($text, $i)
    $c = if ($asm.ContainsKey([uint32]$i)) { $asm[[uint32]$i] } else { '' }
    $imem.Add(('{0:x8} // {1:x4}: {2}' -f $w, $i, $c))
}

# ---- data.mem: um byte por token, 4 por linha, em ordem de endereco --------------
$pad = (4 - $data.Length % 4) % 4
if ($pad) { $data = $data + (New-Object byte[] $pad) }
if ($data.Length -eq 0) { $data = New-Object byte[] 4 }   # $readmemh reclama de arquivo vazio
$dmem = New-Object System.Collections.Generic.List[string]
$dmem.Add("// $App - gerado por scripts/build_sw.ps1 (nao editar a mao)")
for ($i = 0; $i -lt $data.Length; $i += 4) {
    $dmem.Add(('{0:x2} {1:x2} {2:x2} {3:x2} // {4:x4}' -f $data[$i], $data[$i + 1], $data[$i + 2], $data[$i + 3], $i))
}

$enc = New-Object System.Text.ASCIIEncoding
[IO.File]::WriteAllLines((Join-Path $Out 'program_bytes.mem'), $imem, $enc)
[IO.File]::WriteAllLines((Join-Path $Out 'data.mem'), $dmem, $enc)
Remove-Item $textBin, $dataBin -ErrorAction SilentlyContinue

Write-Host ("{0}: codigo {1} B / {2} B, dados {3} B, dados+bss ate 0x{4:X} (pilha a partir de 0x{5:X})" -f `
    $App, $text.Length, $MemBytes, $data.Length, $bssEnd, $MemBytes)
Write-Host "saida: $Out"

if ($Install) {
    $bk = Join-Path $Root ("build\sw\_backup\" + (Get-Date -Format 'yyyyMMdd_HHmmss'))
    New-Item -ItemType Directory -Force $bk | Out-Null
    Copy-Item (Join-Path $MemDir '*.mem') $bk
    Copy-Item (Join-Path $Out 'program_bytes.mem'), (Join-Path $Out 'data.mem') $MemDir -Force
    Write-Host "instalado em $MemDir (anteriores em $bk)"
}
