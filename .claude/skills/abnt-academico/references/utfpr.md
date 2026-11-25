# Perfil UTFPR + LaTeX (adaptação local)

**Este perfil prevalece sobre os demais módulos** quando o trabalho é da UTFPR (princípio 1 do
`SKILL.md`: o manual da instituição manda). Conferido em 21 nov. 2026.

## 1. Normas adotadas pela UTFPR

Lista oficial da página "Trabalhos acadêmicos" das Bibliotecas UTFPR
(https://www.utfpr.edu.br/bibliotecas/trabalhos-academicos):

| Norma | Edição UTFPR | Diferença em relação ao resto da skill |
|---|---|---|
| NBR 6023 (referências) | **2018** | A skill segue 2025 → aplicar a seção 2 abaixo |
| NBR 6024 (numeração de seções) | 2012 | igual |
| NBR 6027 (sumário) | 2012 | igual |
| NBR 6028 (resumo) | 2021 | igual |
| NBR 6034 (índice) | 2004 | igual |
| NBR 10520 (citações) | 2023 | igual |
| NBR 14724 (trabalhos acadêmicos) | 2024 | igual |
| NBR 15287 (projeto de pesquisa) | 2025 | igual |

Normas **não listadas** pela UTFPR mas usadas pela skill (NBR 10719 relatório técnico, NBR 6022
artigo, NBR 12225 lombada, IBGE tabular): usar como complemento, sem contrariar o template.

Para conferir o texto oficial: a UTFPR dá acesso às normas pela plataforma GEDWeb
(https://webapp.utfpr.edu.br/bibservices/gedWeb).

## 2. Referências: NBR 6023:2018 em vez de 2025

O `referencias.md` foi escrito para a edição de 2025. Na UTFPR, **não aplicar** as novidades de
2025 abaixo; usar a forma de 2018. As diferenças são pequenas; em dúvida, mostre ao usuário as
duas formas e deixe a decisão com o professor/biblioteca.

| Ponto | 2025 (não usar na UTFPR) | 2018 (usar) |
|---|---|---|
| ISSN em coleção de periódico | complementar/opcional | elemento da descrição quando disponível |
| *ca.* (data aproximada) | em itálico: [*ca.* 2015] | sem itálico: [ca. 2015] |
| Título de série/coleção | em minúsculas | como na fonte (iniciais maiúsculas) |
| Evento sem cidade disponível | cidade pode ser omitida | usar [*S. l.*] |
| Documento online sem cidade | local pode ser omitido | usar [*S. l.*] |
| Jurisprudência | "julgado em" + data abreviada | data do julgamento sem "julgado em" |
| Podcast | entrevistado na posição de autor | entrevistado como responsabilidade secundária |

Mantidos nas duas edições (aplicar normalmente): destaque único no título (o template usa
**negrito**), "Disponível em:" + URL e "Acesso em:" + data para online, DOI no formato
https://doi.org/..., *In*, *et al.*, [*S. l.*], [*s. n.*] em itálico, e-localização (e03304) em
artigo eletrônico sem paginação.

Itens desta tabela vêm de guias de bibliotecas (UFU, ECA-USP) e de fonte secundária, não do texto
integral das normas. Antes de alterar uma referência por causa deles, confira na GEDWeb.

## 3. O documento é LaTeX (template `utfpr.cls`, Overleaf)

Esta seção vale quando o trabalho usa o **template LaTeX da UTFPR** (abnTeX2 + `utfpr.cls`,
versão 3.0, DACOM/UTFPR-CP), local ou no Overleaf (ex.: via MCP `overleaf-mcp-rt`). Nesses casos,
ignorar as instruções de Word/.docx/track changes do `SKILL.md`.

### O que a classe já faz sozinha: NÃO ajustar à mão
Margens (3/3/2/2), fonte e tamanhos, espaçamento 1,5, recuo de parágrafo (1,5 cm na UTFPR),
paginação, capa, folha de rosto, sumário, listas, formato das referências (via BibTeX
`abntex2-alf`) e das chamadas de citação (já em caixa mista, NBR 10520:2023).
Não inserir `\vspace`, `\setlength`, mudanças de fonte ou espaçamento para "corrigir" norma.

### Convenções de escrita no template
- **Citações** (pacote `abntex2cite`, sistema autor-data):
  - parentética: `\cite{chave}` → (Silva, 2020); com página: `\cite[p.~45]{chave}`;
  - narrativa: `\citeonline{chave}` → Silva (2020); `\citeonline[p.~45]{chave}`;
  - vários: `\cite{a,b}` → (Silva, 2020; Souza, 2021).
  - Nunca digitar a chamada à mão "(Silva, 2020)": ela não vincula à lista de referências.
- **Citação longa** (> 3 linhas): ambiente `citacao` (recuo 4 cm, tamanho menor, simples).
- **Referências**: entradas no `.bib`; só aparecem as citadas. Nomes com acento no campo
  AUTHOR via `{\'a}` etc. Entidade: `AUTHOR = {{ABNT}}`.
- **Seções**: `\chapter` gera a seção primária (CAIXA ALTA, negrito, página nova). No **texto**,
  chamar de "seção", nunca "capítulo" (NBR 14724:2024): escrever `Seção~\ref{cap:x}`;
  **não usar `\autoref` para `\chapter`**, porque imprime "Capítulo".
  Hierarquia UTFPR: primária CAIXA ALTA negrito; secundária negrito; terciária sem negrito;
  quaternária sublinhado; quinária itálico (a classe aplica).
- **Ilustrações**: legenda acima, fonte abaixo; na UTFPR legenda e fonte em negrito e
  centralizadas (a classe aplica). Ambientes: `figure`, `graph` (gráfico), `photograph`,
  `tabframed` (quadro), `table` (tabela, bordas laterais abertas), `sourcecode` (código).
  Para entrar na Lista de Ilustrações, cada um precisa de
  `\addcontentsline{loge}{figure}{\protect\numberline{\thefigure}Título}`
  (trocar `figure`/`\thefigure` pelo tipo: `graph`/`\thegraph`, `tabframed`/`\thetabframed`...).
- **Fonte de ilustração/tabela**: `\fonte{}` vazio → "Fonte: Autoria própria (ANO)." (forma
  UTFPR; não usar "elaborado pelo autor"). Com conteúdo: `\fonte{\citeonline{chave}}` ou
  `\fonte{Adaptado de \citeonline[p.~42]{chave}}`. **Não pôr ponto final**: a classe põe.
- **Siglas**: `\acro{SIGLA}{Forma longa}` em `PreTexto/lista-acronimos.tex`; no texto `\ac{SIGLA}`
  (1ª vez forma longa + sigla), `\acs{}` só sigla. Só entram na lista as usadas.
- **Palavras-chave** em `variaveis.tex`, acentos no formato antigo (`\'a`, `\c{c}`) por
  limitação do template; separação por ponto e vírgula é automática.
- `\advisor` não existe na classe (quebra a compilação).
- Pendências: `\todo{...}` (definido no projeto, aparece em vermelho).

### Fluxo para revisar um documento no Overleaf
1. `overleaf_get_project_tree` → identificar `main.tex` e capítulos incluídos.
2. Ler os `.tex` relevantes e o `.bib`.
3. Conferir: chamadas digitadas à mão, "capítulo" no texto, `\autoref` em `\chapter`,
   ilustração sem `\fonte` ou sem `\addcontentsline{loge}`, ponto final dentro de `\fonte{}`,
   entradas do `.bib` incompletas (campos faltando viram `[VERIFICAR]`), referências 2025
   (seção 2 acima).
4. Corrigir com `overleaf_edit_doc` (troca pontual; o documento é do grupo e pode estar aberto).
   Nunca reescrever o arquivo inteiro.
5. `overleaf_compile` e checar erros/avisos de citação indefinida.
6. Entregar o relatório no formato do `SKILL.md` (Premissas / Alterações / Pendências / Decidir).

### Sobre o script `conferir_citacoes.py`
No LaTeX, citação sem referência já aparece como aviso de compilação ("Citation undefined") e
referência não citada não é impressa, então o script é dispensável. Se quiser usá-lo, rode sobre
o texto extraído do PDF compilado (`overleaf_download_pdf` → extrair texto → `.txt`).

## 4. Trabalho de disciplina (não TCC)

Para relatórios de disciplina no template TCC: sem folha de aprovação, dedicatória,
agradecimentos, epígrafe, ficha catalográfica e licença Creative Commons (essas são exigências
de TCC/depósito na biblioteca). Natureza do trabalho: "Relatório técnico apresentado como
requisito parcial de avaliação da disciplina de X do curso Y da UTFPR". Se o professor der
regras próprias, elas prevalecem.
