---
name: fazer-commit
description: Use quando o usuário pedir para fazer commit, separar mudanças em vários commits, ou digitar /fazer-commit neste projeto. Examina o diff, separa as mudanças em commits lógicos, roda os testbenches quando há RTL/testbench, escreve mensagens Conventional Commits em português e executa git commit. NÃO usar para push, pull request, rebase, amend ou para só sugerir uma mensagem sem commitar.
---

# Fazer commits (Conventional Commits, em português)

Adaptada de [github/awesome-copilot `git-commit`](https://github.com/github/awesome-copilot/blob/main/skills/git-commit/SKILL.md) (MIT), com as regras deste projeto. Especificação: [Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/).

Só faça commit quando o usuário pedir. Não faça push, não abra PR e não reescreva histórico (`--amend`, `rebase`, `reset --hard`) sem pedido explícito.

## Formato

```text
<tipo>(<escopo>): <resumo>

<corpo>

<rodapé>
```

- **Tipo e escopo em inglês/identificador; resumo e corpo em português**, com acentos.
- Resumo: letra minúscula, sem ponto final, até 72 caracteres na primeira linha. Descreva a mudança, não a tarefa: `somador dedicado para o endereço da DMEM`, `corrige extensão de sinal do LH`.
- Corpo (opcional, recomendado para RTL): o que mudou e por quê; números antes → depois quando houver (WNS, Fmax, LUTs, FFs); resultado dos testes (`10/10 testbenches`). Linhas de até ~72 caracteres; listas com `-`.
- Rodapé: `BREAKING CHANGE: <o que quebra>` quando a mudança exige alterar programas ou ligações (mapa MMIO, portas do `core`, endereços), e a linha de coautoria pedida pelo sistema (`Co-Authored-By: ...`), se houver.

## Tipos

| Tipo | Quando |
| :-- | :-- |
| `feat` | funcionalidade nova (instrução, periférico, porta, script novo, app novo) |
| `fix` | correção de bug (lógica, encoding, teste errado, script quebrado) |
| `perf` | melhora de timing ou área sem mudar o comportamento |
| `refactor` | reorganização de código sem mudar o comportamento nem o timing de propósito |
| `test` | só testbenches (casos novos ou ajustados) |
| `docs` | só documentação: `docs/`, README, CLAUDE.md, comentários e Doxygen |
| `build` | scripts de build/simulação/síntese (`scripts/*.ps1`), `link.ld`, flags do gcc |
| `chore` | manutenção: `.gitignore`, configuração do Claude (`.claude/`), arquivos movidos |
| `style` | só formatação/espaços, sem mudar a lógica |
| `revert` | reverte um commit anterior (`revert: <resumo do original>`, corpo `Reverte <hash>.`) |

## Escopos

Use o nome da área afetada, sempre o mesmo para a mesma coisa:

- Módulos de RTL: `alu`, `control_unit`, `core`, `data_memory`, `decoder`, `execution`, `imm_gen`, `instruction_memory`, `register_file`, `search`, `top_core`, `write_back`, `pkg` (packages).
- Áreas transversais: `mmio` (mapa/periféricos), `timing` (medições, TIMING.md), `espec` (ESPEC_RV32I.md).
- Testes: `tb_<nome>` (ex.: `test(tb_core): ...`); vários testbenches → `tb`.
- Software: `sw` (comum) ou o nome do app (`selftest`, `autoteste_placa`, `leds`).
- Scripts: `run_tb`, `synth`, `build_sw`. Skills: `skills`. Planos: `planos`.
- Mudança que cruza várias áreas: escolha a principal (ex.: `feat(mmio)` para RTL + tb + sw + docs da mesma mudança).

## Como separar os commits

Um commit = uma mudança lógica que faz sentido sozinha e passa nos testes.

- **Juntos:** a mudança de RTL, os testbenches que a verificam, o software e as docs que ela obriga a atualizar, e o plano em `docs/planos/` (ex.: `feat(mmio)`).
- **Separados:** medições de timing/área (`docs(timing)`), docs ou skills sem relação com a mudança, ajustes de scripts, correções cosméticas encontradas no caminho, `.mem` instalados (`chore(sw)` ou junto do app, se for a mesma mudança).
- Se o diff tem trabalho de etapas diferentes (ex.: duas otimizações), faça um commit por etapa, na ordem em que foram feitas. Quando o mesmo arquivo tem mudanças de duas etapas e não dá para separar por arquivo, pergunte ao usuário se junta ou se separa montando a versão intermediária (`git hash-object -w` + `git update-index --cacheinfo`); nunca use `git add -p`/`-i` (são interativos).
- Mudanças que o usuário já tinha feito antes do pedido também entram, mas no commit da etapa a que pertencem; se não estiver claro, pergunte.

## Nunca colocar no commit (sem pedido explícito)

- `processador_riscV.xpr`: gerenciado pelo usuário na GUI. Se estiver modificado, pergunte se entra (e em qual commit) em vez de decidir.
- Saídas do Vivado e do build (`.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`, `build/`) — já estão no `.gitignore`; se aparecerem, avise.
- `sources_1/imports/new/*.mem`: só entram quando o usuário rodou `build_sw.ps1 -Install` de propósito.
- Arquivos não rastreados que você não criou (ex.: `schematic.sch`), locks do Excel (`~$*`), `.env`/credenciais: liste e pergunte.

## Fluxo

1. **Regras e histórico:** `git log --oneline -10` (manter o estilo dos commits recentes) e `git branch --show-current`. Se estiver na `main`, pergunte se deve criar uma branch antes.
2. **Ver as mudanças:** `git status --short`, `git diff --stat`, `git diff` (e `git diff --staged` se já houver algo no índice). Sem mudanças → avise e pare; nunca faça commit vazio.
3. **Planejar os commits:** agrupe os arquivos por mudança lógica (seção acima) e defina tipo, escopo e resumo de cada um.
4. **Testes (portão):** se algum commit inclui `sources_1/new/` ou `sim_1/new/`, rode `powershell -ExecutionPolicy Bypass -File .\scripts\run_tb.ps1` (via PowerShell, não Git Bash). Se `sw/` mudou, rode também `run_tb.ps1 tb_program -App <app>` para os apps afetados. Falhou → não faça commit; mostre o erro e pergunte. Falha de ambiente (ex.: "arquivo sendo usado por outro processo" no `xsim.dir`) → rode o testbench de novo antes de concluir que falhou. Commits só de docs/skills/scripts não exigem testes.
5. **Stage e commit, um por vez:**
   ```bash
   git add -- caminho/arquivo1 caminho/arquivo2
   git diff --staged --name-only          # conferir: só os arquivos desta mudança
   git commit -q -F - <<'EOF'
   feat(mmio): E/S genérica de 32 bits no core

   Corpo explicando o que e por quê.

   Co-Authored-By: ...
   EOF
   ```
   Em PowerShell, use `git commit -F <arquivo>` com o texto num arquivo temporário (no scratchpad) ou vários `-m`. Avisos `LF will be replaced by CRLF` são normais neste repositório.
6. **Conferir:** `git log --oneline -<n>` e `git status --short` (o que sobrou deve ser só o que ficou de fora de propósito).
7. **Relatar ao usuário:** lista dos commits (hash curto + primeira linha), o que ficou de fora e por quê, e que não houve push.

## Segurança

- Não altere a configuração do git (`git config`).
- Não use `--no-verify`. Se um hook falhar, o commit não acontece: corrija, faça o stage de novo e repita o mesmo `git commit` (sem `--amend`).
- Não use `--amend`, `rebase`, `reset --hard`, `push --force` nem `git history` sem pedido explícito.
