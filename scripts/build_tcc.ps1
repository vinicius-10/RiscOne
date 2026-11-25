<#
.SYNOPSIS
    Compila o TCC (tcc/main.tex) com pdfLaTeX do TeX Live 2021, fora do Overleaf.

.EXAMPLE
    .\scripts\build_tcc.ps1            # compila e mostra resumo de erros/avisos
    .\scripts\build_tcc.ps1 -Clean     # apaga build/tcc antes (recompila do zero)
    .\scripts\build_tcc.ps1 -ShowLog   # lista todos os avisos (padrao: so os 15 primeiros de cada tipo)

.NOTES
    Copia tcc/ para build/tcc (ignorado pelo git) e compila la, para nao
    sujar tcc/ com auxiliares. PDF final: build/tcc/main.pdf.
    Sequencia: pdflatex -> bibtex -> makeglossaries/makeindex -> pdflatex x2.
    -shell-escape e Pygments sao exigidos pelo pacote minted (carregado no main.tex).
    Codigo de saida: 0 se o PDF foi gerado sem erros, 1 caso contrario.
#>
param(
    [switch]$Clean,
    [switch]$ShowLog,
    [string]$TexBin = $(if ($env:TEXLIVE_BIN) { $env:TEXLIVE_BIN } else { 'D:\ProgramFiles\texlive\2021\bin\win32' })
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Src  = Join-Path $Root 'tcc'
$Out  = Join-Path $Root 'build\tcc'

if (-not (Test-Path (Join-Path $TexBin 'pdflatex.exe'))) {
    Write-Error "pdflatex nao encontrado em $TexBin (use -TexBin ou `$env:TEXLIVE_BIN)."
}

# pygmentize (minted): procura a pasta Scripts ao lado do site-packages do Pygments.
$pyPath = $null
try {
    $site = (& python -c "import pygments,os;print(os.path.dirname(os.path.dirname(pygments.__file__)))" 2>$null)
    if ($site) {
        foreach ($cand in @((Join-Path (Split-Path $site) 'Scripts'), (Join-Path (Split-Path (Split-Path $site)) 'Scripts'))) {
            if (Test-Path (Join-Path $cand 'pygmentize.exe')) { $pyPath = $cand; break }
        }
    }
} catch {}
if (-not $pyPath) { Write-Warning 'pygmentize nao encontrado (python -m pip install --user pygments); minted vai falhar.' }

if ($Clean -and (Test-Path $Out)) { Remove-Item -Recurse -Force $Out }
New-Item -ItemType Directory -Force $Out | Out-Null
Copy-Item -Path (Join-Path $Src '*') -Destination $Out -Recurse -Force

$env:PATH = ((@($TexBin, $pyPath) | Where-Object { $_ }) -join ';') + ';' + $env:PATH

Push-Location $Out
try {
    function Run([string]$exe, [string[]]$argv, [string]$log) {
        # PowerShell 5.1 transforma stderr de programa nativo em erro; o resultado vem do codigo de saida.
        $ErrorActionPreference = 'Continue'
        & (Join-Path $TexBin "$exe.exe") @argv *> $log
        return $LASTEXITCODE
    }
    $tex = @('-shell-escape', '-interaction=nonstopmode', '-file-line-error', 'main.tex')

    Write-Host '[1/5] pdflatex'
    Run pdflatex $tex 'run1.txt' | Out-Null
    Write-Host '[2/5] bibtex'
    Run bibtex @('main') 'bibtex.txt' | Out-Null
    Write-Host '[3/5] glossarios e indices'
    if ((Test-Path 'main.glo') -or (Test-Path 'main.acn')) { Run makeglossaries @('main') 'glossaries.txt' | Out-Null }
    if (Test-Path 'main.idx') { Run makeindex @('main') 'makeindex.txt' | Out-Null }
    if (Test-Path 'main.nlo') { Run makeindex @('main.nlo', '-s', 'nomencl.ist', '-o', 'main.nls') 'nomencl.txt' | Out-Null }
    Write-Host '[4/5] pdflatex'
    Run pdflatex $tex 'run2.txt' | Out-Null
    Write-Host '[5/5] pdflatex'
    $rc = Run pdflatex $tex 'run3.txt'

    # Resumo a partir do log final.
    $log = Get-Content 'main.log' -Encoding Default
    $max = if ($ShowLog) { [int]::MaxValue } else { 15 }
    $errors = $log | Select-String -Pattern '^(\./)?[^:\s]+\.tex:\d+:|^! ' | Select-Object -ExpandProperty Line -Unique
    $undef  = $log | Select-String -Pattern '^LaTeX Warning: (Reference|Citation) ' | Select-Object -ExpandProperty Line -Unique
    $over   = $log | Select-String -Pattern '^Overfull \\hbox' | Select-Object -ExpandProperty Line
    $bibW   = Get-Content 'bibtex.txt' -ErrorAction SilentlyContinue | Select-String -Pattern '^Warning--|error message' | Select-Object -ExpandProperty Line

    $pdf = Join-Path $Out 'main.pdf'
    $m = $log | Select-String -Pattern 'Output written on main\.pdf \((\d+) pages' | Select-Object -First 1
    $pages = if ($m) { $m.Matches[0].Groups[1].Value } else { '?' }

    function Show([string]$title, $lines) {
        $n = @($lines).Count
        if ($n -eq 0) { return }
        Write-Host "`n$title ($n):"
        $lines | Select-Object -First $max | ForEach-Object { Write-Host "  $_" }
        if ($n -gt $max) { Write-Host "  ... (-ShowLog para ver todos)" }
    }
    Show 'ERROS' $errors
    Show 'Referencias/citacoes indefinidas' $undef
    Show 'Avisos do BibTeX' $bibW
    Show 'Overfull hbox (linha saindo da margem)' $over

    $ok = ($rc -eq 0) -and (@($errors).Count -eq 0) -and (Test-Path $pdf)
    Write-Host ''
    if ($ok) { Write-Host "PDF OK: $pdf ($pages paginas)" -ForegroundColor Green }
    elseif ($m) {
        # Como no Overleaf, o modo nonstop gera o PDF mesmo com erros; o trecho com erro pode sair errado.
        Write-Host "PDF gerado COM $(@($errors).Count) ERRO(S): $pdf ($pages paginas). Logs em $Out" -ForegroundColor Yellow
    }
    else     { Write-Host "FALHOU sem gerar PDF (pdflatex rc=$rc). Logs em $Out (main.log, run*.txt)" -ForegroundColor Red }
    exit $(if ($ok) { 0 } else { 1 })
}
finally {
    Pop-Location
}
