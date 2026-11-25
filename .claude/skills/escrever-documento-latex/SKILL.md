---
name: escrever-documento-latex
description: Use ao escrever, revisar, corrigir ou compilar um documento acadêmico em LaTeX (TCC, relatório, artigo, monografia), local ou no Overleaf — seções/capítulos, resumo, siglas, figuras, tabelas, quadros, listagens, referências BibTeX —, ou quando o usuário pedir "revisar a seção X", "escrever a parte de Y", "colocar os resultados no documento", "compilar" ou "sincronizar o documento com o git". Corrige e completa sem trocar a voz nem a estrutura do autor, conferindo fatos nas fontes do projeto. Não usar para slides nem para código.
---

# Escrever e revisar documento acadêmico em LaTeX

**Antes de começar:** ler o `CLAUDE.md` do projeto, seção **"Perfil para as skills"** (modelo em
`modelos/CLAUDE-perfil.md`), campos do bloco `documento`: onde o documento vive (pasta local ou
projeto Overleaf), arquivos editáveis, arquivos só-sugestão, fontes de verdade, estilo, termos
estrangeiros, comando de compilação e avisos conhecidos. **Sem perfil, perguntar** onde está o
documento e o que pode ser editado antes de mexer em qualquer arquivo.

Normas ABNT e template da instituição: usar junto a skill `abnt-academico` (para UTFPR, o perfil
`references/utfpr.md`). Esta skill cuida de conteúdo, estilo do autor e fluxo de trabalho.

O texto é do **autor** (ou do grupo): o papel é corrigir e completar **sem trocar a voz nem a estrutura**.

## 0. O que pode ser editado

- **Editar:** só os arquivos listados como editáveis no perfil (normalmente os capítulos/seções).
- **Com permissão do usuário na conversa:** trecho de `\include`/`\input` do arquivo principal;
  acrescentar entrada nova ao `.bib` (nunca alterar/remover as existentes); acrescentar sigla;
  criar arquivo novo (figura, seção).
- **Só sugerir, nunca editar:** preâmbulo, classe (`.cls`), configurações, dados da capa, resumo e
  abstract (salvo se o perfil disser o contrário). A sugestão vai pronta para colar no resumo final:
  entrada BibTeX completa, linha da sigla, parágrafo, nome e conteúdo da figura que falta.
- **Overleaf** (via MCP `overleaf-mcp-rt`): o documento pode estar aberto por outra pessoa. Editar
  sempre com `overleaf_edit_doc` (troca pontual); nunca `overleaf_write_doc` (reescreve o arquivo
  inteiro) nem apagar entidades sem pedido explícito.
- Arquivos de exemplo do template que não estão incluídos: não editar; servem de consulta.
- Cópia local de um documento do Overleaf (espelho em git): somente leitura; muda só pela importação (seção 7).

## 1. Fontes de verdade (nunca escrever de memória)

Todo número, nome (função, sinal, módulo, arquivo, parâmetro), comportamento ou resultado descrito
no texto é conferido nas `fontes_de_verdade` do perfil, na ordem dada (tipicamente: código →
resultados de testes/medições → documentação técnica do projeto → enunciado/requisitos).

- Se o texto discorda do código, o código vence.
- **Nenhum número de desempenho/resultado sem arquivo de resultado que o sustente.**
- Informação que não existe em nenhuma fonte: **não inventar**. Marcar `\todo{o que falta}` (ou o
  marcador do perfil, ex.: `\textcolor{red}{[PENDENTE: ...]}`) e listar no resumo final.
- Se o perfil listar **armadilhas recorrentes** do projeto, conferir sempre que o assunto aparecer.

## 2. Modo revisão (padrão quando pedem para revisar/corrigir)

**Corrigir direto** (nos arquivos editáveis):
- ortografia, acentuação, concordância, pontuação, palavras coladas/trocadas;
- pessoa e tempo verbal (seção 3);
- erros técnicos contra as fontes da seção 1;
- LaTeX quebrado: `_ % & #` sem escape fora de `\texttt`, ambientes sem fechar, rótulos duplicados,
  `\ref`/`\cite` para algo inexistente;
- siglas, termos estrangeiros, figuras e tabelas fora do padrão da seção 4;
- notas soltas do autor no meio do texto ("colocar figura aqui", "explicar X"): resolver com `\ref`
  ou escrever o trecho se as fontes permitirem; senão, marcador de pendência.

**Preservar** (não mudar sem pedir): ordem das seções e das ideias, roteiro de explicação do autor,
exemplos, comparações e tabelas de resultados, conteúdo técnico correto escrito de outro jeito.
Reescrever só a frase necessária; parágrafo confuso pode ser reescrito mantendo as ideias e a ordem.

**Sugerir** (no resumo, sem aplicar): mudanças de estrutura (seção fora de lugar, subseção
desnecessária, trecho repetido, conteúdo que falta para cumprir os requisitos).

**Resumo final** (curto): (1) correções técnicas, uma por linha, com `arquivo:linha` e a fonte que
justifica; (2) sugestões de estrutura; (3) sugestões para arquivos não editáveis, prontas para
colar; (4) pendências marcadas. Ortografia não precisa ser listada uma a uma.

## 3. Estilo (padrão; o perfil pode ajustar)

- **Impessoal:** "optou-se", "foi implementado", "observa-se". Nada de "eu", "nós", "meu projeto".
- **Tempo verbal:** passado para o que foi feito; presente para como o sistema funciona; futuro só
  em trabalhos futuros. Texto vindo de uma fase anterior (proposta, TCC 1) é trazido para a
  perspectiva do trabalho concluído.
- **Abertura e ponte:** cada seção primária abre com um parágrafo anunciando o que vem; seções
  longas fecham ligando à próxima.
- **Justificar decisões:** toda escolha de projeto vem com o motivo e, quando houver, comparação
  com alternativas ou referência.
- **Siglas:** na primeira ocorrência, forma por extenso + sigla (pacote `acronym`: `\ac{}`; ou o
  formato do perfil); depois só a sigla; não redefinir sigla já definida.
- **Termos estrangeiros** em `\textit{}` (lista do perfil); nomes de código, arquivos, funções e
  sinais em `\texttt{}` com `\_`.
- **Números:** vírgula decimal e espaço inseparável com unidade (`9,55~ns`, `1,45~s`, `100~MHz`);
  negativos em modo matemático.
- **Citações:** `\citeonline{chave}` quando o autor é sujeito; `\cite{chave}` no fim da frase, antes
  do ponto. Afirmações sobre a literatura sempre citadas; fatos do próprio trabalho não. Só chaves
  que existem no `.bib`; fonte nova → sugerir a entrada BibTeX completa (DOI/URL conferidos) e
  deixar pendência até ser adicionada.
- Não repetir no desenvolvimento o que a fundamentação explicou: remeter com `Seção~\ref{...}`.

## 4. Padrões de LaTeX acadêmico (detalhes da norma/template na skill `abnt-academico`)

- **Remissão a seção:** "Seção~\ref{...}" (ABNT NBR 14724:2024 usa seções, não capítulos); evitar
  `\autoref` em `\chapter` quando ele imprimir "Capítulo".
- **Figura:** `\caption` acima, `\label{fig:...}`, `\includegraphics`, fonte abaixo (comando do
  template, ex.: `\fonte{...}`). Figura que ainda não existe: ambiente com marcador de pendência no
  lugar do `\includegraphics` e descrição no resumo do que ela deve mostrar.
- **Tabela** (dados numéricos, *booktabs*, sem bordas laterais): `\caption` acima, `\label{tab:...}`, fonte abaixo.
- **Quadro** (texto, bordas fechadas): ambiente do template (ex.: `tabframed`) e entrada na lista de ilustrações.
- **Listagem de código:** `lstlisting` com `language`, `caption` e `label={lst:...}`; trechos de
  1–5 linhas podem ficar sem legenda.
- Todo elemento é citado no texto **antes** de aparecer e comentado depois.
- Rótulos sem acento/cedilha, únicos. Prefixos: `cap:`, `sec:`, `sub:`, `fig:`, `tab:`, `quad:`, `lst:`, `eq:`.
- Não mexer no preâmbulo; pacote novo só por sugestão (e compatível com a versão do TeX Live do projeto).

## 5. Requisitos e estrutura do desenvolvimento

Se o perfil tiver um **mapa requisito → seção** (enunciado, edital, roteiro do orientador), ao
revisar o documento inteiro conferir item a item e listar no resumo o que ainda falta.

**Roteiro por bloco** (trabalhos técnicos: hardware, software, sistemas). Quando o desenvolvimento
descreve componentes (módulos de RTL, serviços, versões de um algoritmo), uma subseção por bloco,
na ordem do autor, cada uma **em parágrafos** seguindo:

1. função do bloco no sistema (1 parágrafo);
2. entradas e saídas com os nomes reais (texto; tabela se forem muitas);
3. funcionamento e decisões de projeto, com o motivo e comparações (alternativas, medições, literatura);
4. validação: teste/testbench usado, como os estímulos são aplicados, quantidade de casos e resultado.

Criar `\subsubsection`/`\paragraph` só quando o assunto pedir (vários tópicos longos); um tópico de
um ou dois parágrafos fica como parágrafo.

## 6. Compilar e conferir

- Local: o `comando_compilacao` do perfil; sem ele, a ferramenta
  `ferramentas/compilar-latex.ps1` do repositório desta skill (compila numa cópia em `build/`, sem
  sujar a pasta do documento, e resume erros, referências indefinidas, avisos do BibTeX/Biber e
  *overfull hbox*; aceita `-TexBin` para um TeX Live específico exigido pelo template).
  Overleaf: `overleaf_compile` no projeto do perfil.
- Template que exige uma versão específica do TeX Live (ex.: 2021): compilar localmente com ela
  antes da entrega, mesmo que o Overleaf use outra — o resultado pode diferir.
- Antes de encerrar uma edição: **0 erros** e nenhuma citação/referência indefinida nova; *overfull
  hbox* do trecho editado corrigido.
- Avisos conhecidos do template (lista do perfil) podem ser ignorados.
- Para ver o PDF: `Read` com `pages` (se houver renderizador de PDF) ou extrair texto (`pypdf`).

## 7. Cópia versionada (documento no Overleaf + repositório git)

Quando o perfil indicar `espelho_git`: o Overleaf é a fonte e o repositório guarda cópias.

```powershell
powershell -ExecutionPolicy Bypass -File <caminho>\importar-overleaf.ps1 -ProjetoId <id> -Destino <pasta> -Baixar
```

(ferramenta `ferramentas/importar-overleaf.ps1` do repositório desta skill: baixa o zip usando a
sessão salva pelo `overleaf-mcp-rt`, sem expor o cookie, e espelha na pasta, removendo o que foi
apagado no Overleaf). Conferir o `git status` mostrado e **commitar só quando o usuário pedir**.
Sugerir uma sincronização ao fim de uma sessão em que o documento mudou bastante.
