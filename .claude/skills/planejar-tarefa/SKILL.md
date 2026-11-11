---
name: planejar-tarefa
description: Use quando o usuário digitar /planejar-tarefa ou pedir para planejar, e também ANTES de começar tarefas complexas neste projeto — novo módulo ou bloco, mudança de interface/portas entre módulos, nova instrução ou extensão (M, CSRs, traps), mudança de temporização (pipeline, memória síncrona), mudança no mapa de memória/MMIO, ou qualquer tarefa que toque 3+ arquivos de RTL. NÃO usar para mudanças pequenas e claras (renomear, corrigir comentário, ajustar um teste, perguntas).
---

# Planejar antes de executar

Objetivo: chegar a um plano **aprovado pelo usuário**, sem dúvidas pendentes, antes de editar qualquer arquivo. Planejar é barato; refazer RTL, testbench e documentação é caro.

Regras gerais:
- **Não edite arquivos do projeto até o plano ser aprovado.** Ler código, rodar testbenches existentes e consultar docs é permitido (e necessário).
- O RTL é a fonte da verdade. Leia os módulos envolvidos antes de propor algo; não planeje de memória.
- Respeite o CLAUDE.md: nunca editar o `.xpr` (listar o que o usuário deve fazer no Vivado), comentários em português, cabeçalho/Doxygen, portas `_i`/`_o`, itens "fora do escopo por decisão" só entram se o usuário pedir.

## Passo 1 — Entender o pedido e o estado atual

1. Reescreva o objetivo em 1–2 frases e o critério de "pronto" (o que precisa funcionar e como será verificado).
2. Leia os arquivos envolvidos (`docs/ESPEC_RV32I.md` §5–§9 para controle, interfaces e ligações; os `.sv` afetados; os testbenches que os cobrem).
3. Rode os testbenches relacionados para saber o ponto de partida (`run_tb.ps1 <tbs>`). Se algo já falha, avise antes de continuar.

## Passo 2 — Levantar dúvidas

Liste tudo que não está definido pelo pedido nem pelo código. Para cada dúvida, traga 2–4 opções com a recomendada primeiro e o impacto de cada uma. Use a ferramenta de perguntas (até 4 por rodada; agrupe as relacionadas). Exemplos típicos neste projeto:

- Comportamento em casos de borda (instrução inválida, endereço fora da faixa, overflow, reset no meio da operação).
- Combinacional vs. registrado; em qual borda; o que o reset (que hoje só reinicia o PC e a instrução registrada) deve limpar.
- Encodings novos nos packages (`alu_op_t`, `branch_op_t`, `mem_*`) — manter a convenção dos branches (comparador dedicado na `execution`; `OP_CMP`/`OP_SLT`/`OP_SLTU` escolhem a comparação).
- Custo em FPGA vs. simplicidade (ex.: multiplicador em DSP vs. iterativo).
- Compatibilidade: o que pode quebrar em `tb_core`/`tb_program`/programas em `sw/apps`.

Não pergunte o que dá para descobrir lendo o código. Repita rodadas até não sobrar dúvida que afete o desenho.

## Passo 3 — Escrever o plano

Salve em `docs/planos/AAAA-MM-DD-<nome-curto>.md` (crie a pasta se não existir) e mostre um resumo no chat. Estrutura:

```markdown
# <Título>
Data: AAAA-MM-DD · Status: proposto | aprovado | concluído

## Objetivo e critério de pronto
## Decisões (dúvida → escolha → motivo)
## Arquitetura
- Blocos novos/alterados e onde ficam na hierarquia (top_core → core → ...)
- Diagrama de ligação (texto) com sinais novos
## Interfaces
| Módulo | Porta | Dir | Largura/tipo | Descrição |
## Controle
- Sinais/encodings novos no control_unit e nos packages; matriz por instrução afetada
## Temporização
- O que é combinacional, o que é registrado, efeito no caminho crítico
## Verificação (testbench primeiro)
- Casos novos em quais testbenches (ou testbench novo + linha no $Tests do run_tb.ps1)
- Casos de borda; o que deve FALHAR antes da implementação
## Arquivos
| Arquivo | Mudança |
## Passos de execução (ordem)
## Ações do usuário no Vivado
- Arquivos a adicionar/remover no .xpr (sem "Copy sources into project")
## Documentação a atualizar
- ESPEC_RV32I.md, DOCUMENTACAO_PROJETO.md, README.md, CLAUDE.md, skill rv32i-programas (se afetar software)
## Riscos e fora do escopo
```

Seções que não se aplicam: escreva "não se aplica" em vez de apagar, para mostrar que foram consideradas.

## Passo 4 — Aprovação

Peça aprovação explícita do plano (pergunta com opções: aprovar / ajustar / cancelar). Se o usuário ajustar, atualize o arquivo e peça de novo. Só com "aprovado" marque `Status: aprovado` e siga.

## Passo 5 — Executar o plano aprovado

1. **Testbench primeiro:** escreva/estenda os testes do plano e rode — confirme que falham pelo motivo esperado (a funcionalidade ainda não existe), não por erro de compilação.
2. Implemente na ordem dos passos do plano. Rode os testbenches afetados a cada passo relevante.
3. Ao final, rode a suíte completa (`run_tb.ps1`) e atualize a documentação listada.
4. Se surgir algo que o plano não previu e que muda o desenho (não um detalhe), **pare e pergunte** — registre a nova decisão no plano.
5. Marque `Status: concluído` e informe: o que foi feito, resultado dos testes, desvios do plano e as ações pendentes do usuário no Vivado.
