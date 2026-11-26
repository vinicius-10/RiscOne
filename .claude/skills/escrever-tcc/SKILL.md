---
name: escrever-tcc
description: Use ao escrever, revisar, corrigir ou compilar o TCC deste projeto (pasta tcc/, LaTeX com o modelo UTFPR/abnTeX2) — capítulos, resumo, siglas, figuras, tabelas, referências do main.bib, ou quando o usuário pedir para "revisar o capítulo X", "escrever a seção do módulo Y" ou "compilar o TCC". Não usar para os documentos técnicos em docs/*.md nem para comentários do RTL.
---

# Escrever e revisar o TCC

O TCC fica em `tcc/` (raiz `tcc/main.tex`, capítulos em `tcc/capitulos/`, siglas em `tcc/PreTexto/lista-acronimos.tex`, referências em `tcc/main.bib`). O texto é do autor: o papel aqui é corrigir e completar **sem trocar a voz nem a estrutura dele**.

## 0. O que pode ser editado (regra do autor)

- **Editar:** somente arquivos em `tcc/capitulos/`.
- **`tcc/main.tex`:** só o trecho que inclui capítulos (`\include{./capitulos/…}`), e **só depois de pedir permissão** ao usuário.
- **Todo o resto só se sugere, nunca se edita:** `main.bib`, `PreTexto/` (resumo, abstract, lista de siglas), `PosTexto/`, `variaveis.tex`, `configuracoes.tex`, `utfpr.cls`, preâmbulo do `main.tex`, `figuras/` (inclusive criar arquivo novo). A sugestão vai no resumo final já pronta para colar: a entrada BibTeX completa, a linha da sigla, o parágrafo do resumo, o nome e o conteúdo da figura que falta.

## 1. Fontes de verdade (nunca escrever de memória)

Todo nome de sinal, número, contagem de testes ou comportamento descrito no texto precisa ser conferido em, nesta ordem:

1. **RTL** (`processador_riscV.srcs/sources_1/new/*.sv`) e testbenches (`processador_riscV.srcs/sim_1/new/`): portas, nomes, comportamento. Rode `scripts/run_tb.ps1 <tb>` se precisar da contagem atual de testes.
2. `docs/ESPEC_RV32I.md`: codificações, sinais de controle, mapa de memória/MMIO.
3. `docs/TIMING.md`: WNS, Fmax, LUTs/FFs, caminho crítico de cada etapa. Números de timing só vêm daqui ou de `build/synth/`.
4. `docs/DOCUMENTACAO_PROJETO.md`: decisões e escopo (§8: sem traps, ECALL/EBREAK/FENCE são NOPs).

Se o texto discorda do RTL, o RTL vence. Se a informação não existe em nenhuma fonte, **não invente**: marque `\textcolor{red}{[PENDENTE: o que falta]}` e liste no resumo final.

Armadilhas recorrentes do rascunho (conferir sempre que o assunto aparecer):
- São **37** instruções executadas; ECALL, EBREAK e FENCE viram NOP, sem trap.
- Desvios condicionais não passam pela ALU nem usam flag: um **comparador dedicado** na `execution` compara rs1 com rs2 direto, numa única cadeia de *carry*, e a comparação é escolhida pelo `funct3` da instrução (`funct3[2]` = 0 igualdade BEQ/BNE, 1 "menor"; `funct3[1]` = 1 sem sinal BLTU/BGEU). `OP_BCT` desvia com a comparação verdadeira, `OP_BCF` com ela falsa. O `alu_op_t` que a CU ainda emite nos desvios (`OP_CMP`/`OP_SLT`/`OP_SLTU`) não é usado, e a ALU devolve 0 para `OP_CMP`.
- Entrada A da ALU: rs1 ou PC. Entrada B: rs2, imediato ou PC+4 (JAL/JALR gravam PC+4 via `OP_PASS_B`). O imediato já sai pronto do `imm_gen` (não é deslocado na execução).
- Endereço da memória de dados vem de um somador dedicado (rs1 + imm), não da ALU.
- Memória de dados: vetor 1-D de palavras de 32 bits inferido como LUTRAM (a matriz 2-D de bytes é a versão antiga).
- MMIO genérico: 4 saídas somente-escrita (`0x4000_0000`–`0x0C`) e 4 entradas (`0x4000_0010`–`0x1C`); o `top_core` liga às chaves, LEDs, botões, 7 segmentos e PMOD.
- Reset síncrono força o próximo PC a 0: o PC e a instrução registrada no `search` recomeçam do endereço 0. Banco de registradores e RAM não são zerados.

## 2. Modo revisão (padrão quando o usuário pede para revisar/corrigir)

**Corrigir direto nos `.tex` de `tcc/capitulos/`:**
- ortografia, acentuação, concordância, pontuação, palavras coladas/trocadas;
- pessoa e tempo verbal (ver §3);
- erros técnicos contra as fontes da §1 (nomes de portas, operandos, número de instruções etc.);
- LaTeX quebrado: `_`, `%`, `&`, `#` sem escape fora de `\texttt`, ambientes sem fechar, rótulos duplicados, `\ref`/`\cite` para algo inexistente;
- siglas, termos estrangeiros, figuras e tabelas fora do padrão da §4;
- notas do autor no meio do texto ("código X", "explicar sobre o carry4", "image"): resolva com `\ref` para o elemento certo ou escreva o trecho se as fontes permitirem; senão, troque por marcador `[PENDENTE: …]`.

**Preservar (não mudar sem pedir):**
- a ordem das seções e subseções e a ordem das ideias dentro delas;
- o roteiro de explicação do autor (ex.: explicar o somador completo pela soma decimal com "vai um" antes da tabela-verdade), exemplos, comparações e tabelas de resultados;
- conteúdo técnico correto, mesmo se escrito de forma diferente da que você escreveria.

Reescreva só a frase necessária. Um parágrafo confuso pode ser reescrito, mantendo as mesmas ideias na mesma ordem.

**Sugerir (no resumo, sem aplicar):** mudanças de estrutura — seção fora de lugar, subseção desnecessária, trecho repetido em outro capítulo, conteúdo que falta. Diga onde e por quê.

**Resumo final para o usuário** (curto): (1) correções técnicas, uma por linha, com `arquivo:linha` e a fonte que justifica; (2) sugestões de estrutura; (3) sugestões para arquivos fora de `capitulos/` (§0), prontas para colar; (4) pendências marcadas. Erros de ortografia não precisam ser listados um a um — basta dizer que foram corrigidos.

## 3. Estilo do autor (modelo: introdução e fundamentação teórica)

- **Impessoal**: "optou-se", "foi desenvolvido", "realizou-se", "observa-se". Nada de "eu", "nós", "meu projeto", "faço", "podemos".
- **Tempo verbal (TCC 2)**: passado para o que foi feito ("foi implementado"), presente para como o circuito funciona ("o módulo possui", "a ALU recebe"), futuro só para trabalhos futuros. Introdução, fundamentação, proposta, cronograma e conclusão vieram do TCC 1 e ainda estão no futuro/como proposta: ao revisá-los, trazer para a perspectiva do trabalho concluído. Resumo, abstract e `variaveis.tex` (`\goal`, `\course`) também estão como TCC 1, mas ficam fora de `capitulos/`: só sugerir o texto novo.
- **Abertura e ponte**: cada capítulo abre com um parágrafo que anuncia o que vem; seções longas fecham ligando à próxima ("Com o método de processamento definido, torna-se necessário…"). Conectivos do autor: "Adicionalmente", "Contudo", "Dessa forma", "Diante disso", "Nesse contexto", "Em contrapartida", "Assim".
- **Justificar decisões**: toda escolha de projeto vem com o motivo (caminho crítico, área, simplicidade, compatibilidade com o ciclo único) e, quando houver, com a comparação com outras implementações (`exem_*` no `main.bib`) ou com o livro.
- **Siglas**: na primeira ocorrência no texto todo, "Nome em português (SIGLA, do inglês \textit{Nome em inglês})"; depois, só a sigla. Não redefinir sigla já definida em capítulo anterior (procure com Grep). Sigla nova que ainda não está em `PreTexto/lista-acronimos.tex`: sugerir a linha (`SIGLA & \textit{Nome} \\`) para o autor inserir em ordem alfabética. Usar **ALU** (não ULA) e **CU**, como na fundamentação.
- **Termos estrangeiros** em `\textit{}` (\textit{clock}, \textit{pipeline}, \textit{testbench}, \textit{hardware}, \textit{software}, \textit{timing}, \textit{carry}, \textit{load}/\textit{store}). Nomes de módulos, sinais, arquivos e instruções em `\texttt{}` com `\_`.
- **Números**: vírgula decimal e espaço inseparável com a unidade (`9,551~ns`, `100~MHz`, `4~KiB`); negativos em modo matemático (`$-4{,}2$~ns`).
- **Citações**: `\citeonline{chave}` quando o autor é sujeito da frase ("Segundo \citeonline{x}, …"); `\cite{chave}` no fim da frase, antes do ponto. Afirmações sobre a literatura sempre citadas; fatos deste projeto não. Só use chaves que existem no `main.bib`; para fonte nova, sugira a entrada BibTeX completa (o autor adiciona) e, até lá, deixe `[PENDENTE: citar …]` no texto em vez de um `\cite` quebrado.
- Evitar repetir no desenvolvimento o que a fundamentação já explicou: remeter com `Seção~\ref{…}`.

## 4. Padrões do modelo UTFPR (abnTeX2)

- **Figura**: `\caption` acima, `\label{fig:…}`, `\includegraphics`, `\fonte{Autoria própria (2026)}` ou `\fonte{Adaptado de \citeonline{…}}` abaixo. Arquivos em `tcc/figuras/` (PDF), que só o autor cria: para figura que falta, deixe o ambiente `figure` com `[PENDENTE: figura de …]` no lugar do `\includegraphics` e descreva no resumo o que ela deve mostrar.
- **Tabela** (dados numéricos, laterais abertas, `booktabs`): `\caption` acima, `\label{tab:…}`, `\fonte{…}` abaixo — toda tabela precisa de `\fonte`.
- **Quadro** (conteúdo textual, bordas fechadas): ambiente `tabframed`, `\label{quad:…}` e a linha `\addcontentsline{loge}{tabframed}{…}` como no Quadro de extensões da fundamentação.
- **Listagem**: `\begin{lstlisting}[language=Verilog, caption={…}, label={lst:…}]` (estilo `estilo_tcc` já é o padrão). Trechos curtos (1–5 linhas) podem ficar sem legenda.
- Todo elemento é citado no texto **antes** de aparecer ("conforme a Tabela~\ref{tab:…}") e comentado depois — não deixar figura ou tabela solta.
- Rótulos sem acento/cedilha, únicos no documento. Prefixos: `cap:`, `sec:`, `sub:`, `subsub:`, `fig:`, `tab:`, `quad:`, `lst:`, `eq:`.
- Não editar o preâmbulo do `main.tex` (pacotes, cores, estilos): se um recurso exigir pacote novo, prefira resolver com o que já está carregado; senão, sugira. O modelo exige **TeX Live 2021** (Overleaf: Menu → TeX Live version → 2021 Legacy), então só pacotes existentes nessa versão.

## 5. Estrutura do capítulo de desenvolvimento

Uma seção (`\subsection`) por bloco do RTL, na ordem do rascunho: ALU, Busca, Execução, Memória de dados, Escrita, Decodificação (registradores, gerador de imediato, CU, montagem), Core, Top\_core, Programa teste, Otimização de \textit{timing} e de área. Cada bloco segue o roteiro do autor, **em parágrafos**:

1. função do bloco no processador (1 parágrafo);
2. entradas e saídas com os nomes reais das portas (texto; tabela se forem muitas, como na CU);
3. funcionamento e decisões de projeto, com o motivo e comparações (outras implementações, testes de \textit{timing});
4. validação: \textit{testbench} usado, como os estímulos são aplicados (borda de descida, verificação após a borda de subida), quantidade de testes e resultado.

Crie `\subsubsection`/`\paragraph` **só quando o assunto realmente pedir** (vários tópicos longos, como na CU); um tópico de um ou dois parágrafos fica como parágrafo. As seções de Memória de dados e Programa teste serão padronizadas para esse mesmo roteiro.

## 6. Compilar e conferir

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_tcc.ps1          # -> build/tcc/main.pdf + resumo de erros/avisos
powershell -ExecutionPolicy Bypass -File .\scripts\build_tcc.ps1 -Clean   # do zero (após mudar siglas, bib ou rótulos)
```

- TeX Live 2021 em `D:\ProgramFiles\texlive\2021` (fora do PATH; sobrescreva com `-TexBin` ou `$env:TEXLIVE_BIN`). O `minted` carregado no `main.tex` exige `-shell-escape` e Pygments — o script cuida disso.
- O script compila numa cópia em `build/tcc/` (ignorada pelo git): `tcc/` nunca recebe `.aux`/`.log`.
- Como no Overleaf, o PDF sai mesmo com erros (o script avisa "PDF gerado COM N ERRO(S)"); o trecho com erro pode sair deformado. As 13 mensagens "write is an unknown function" do BibTeX vêm do `abntex2-alf.bst` do modelo e podem ser ignoradas; "entry type … isn't style-file defined" vem de `@online` no `main.bib` (sugerir `@misc`, não editar).
- Antes de encerrar uma edição: **0 erros** e nenhuma referência/citação indefinida nova. Os `Overfull \hbox` de tabelas e linhas longas devem ser corrigidos quando forem do trecho editado.
- Para ver uma página do PDF, use a ferramenta Read com `pages` em `build/tcc/main.pdf`.

## 7. Git

Trabalho do TCC na branch de documentação (`ajuste-de-docuemntacao`). Commits com a skill `fazer-commit`, tipo `docs(tcc): …`. Nunca commitar `build/`.
