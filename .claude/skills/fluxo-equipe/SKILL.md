---
name: fluxo-equipe
description: Use ao COMEÇAR um trabalho novo num repositório compartilhado (funcionalidade, correção, testes, experimento, documentação) para criar a branch antes de editar; e quando o usuário pedir para abrir pull request (PR), revisar o PR de um colega, fazer merge na branch principal, atualizar a branch com a principal, ver o estado dos PRs/branches ou limpar branches. Também quando digitar /fluxo-equipe. Segue o GitHub Flow (uma branch por trabalho, PR com revisão, branch apagada depois do merge), com as regras do perfil do projeto. Os commits em si ficam com a skill fazer-commit.
---

# Fluxo de trabalho em equipe (GitHub Flow)

**Antes de começar:** ler o `CLAUDE.md` do projeto. Da seção **"Perfil para as skills"** (modelo em
`modelos/CLAUDE-perfil.md`) usar `repositorio`, `equipe`, `comando_testes` e a subseção
**fluxo_equipe**:

| Campo | Padrão (se o perfil não disser) |
|---|---|
| `branch_principal` | a branch padrão do remoto (`gh repo view --json defaultBranchRef`) |
| `tipo_merge` | `merge` (merge commit: preserva todos os commits) — ou `squash` |
| `aprovacoes` | `1` |
| `quem_faz_merge` | qualquer integrante, depois da aprovação |
| `direto_na_principal` | nada (ex.: "sincronização do relatório `docs(relatorio)`") |
| `ci` | `nenhum` (testes rodam local e o resultado vai no PR) — ou o nome do *check* |
| `checklist_revisao` | correção, testes, clareza (o projeto pode acrescentar restrições próprias) |

Sem `gh` instalado/logado: fazer a parte de git e dar ao usuário o link para abrir o PR no site
(o `push -u` imprime). Repositório individual, sem colaboradores: perguntar se quer o fluxo.

## Regras

- A branch principal fica sempre funcionando. Ninguém commita direto nela, exceto o que estiver em
  `direto_na_principal`.
- **Trabalho novo = branch nova** `tipo/assunto`, criada a partir da principal atualizada, antes da
  primeira edição.
- Integração por PR com `aprovacoes` aprovações de outros integrantes (o GitHub não deixa o autor
  aprovar o próprio PR); merge pelo `tipo_merge`; branch apagada depois.

**merge commit × squash** (para explicar quando perguntarem): merge commit leva todos os commits da
branch para a principal — dá para reverter um passo só (`git revert <hash>`), usar `git bisect` e
ver o autor de cada commit; desfazer o PR inteiro é `git revert -m 1 <hash-do-merge>`. Squash deixa
um commit por PR — histórico mais curto e revert do PR inteiro mais simples, mas os passos
intermediários somem da principal.

## O que é "trabalho novo"

| Situação | Onde trabalhar |
|---|---|
| Pedido que vai alterar arquivos do repositório e não é continuação do assunto da branch atual | **Branch nova** (passo 1), sem perguntar; avisar o nome |
| Continuação ou ajuste do mesmo assunto; correção pedida na revisão | Branch atual |
| Item de `direto_na_principal` | Principal (passo 6) |
| Na dúvida | Perguntar: "continuo em `<branch>` ou abro uma branch nova?" |

Só ler, explicar, planejar ou rodar testes não exige branch: crie-a ao começar a editar.

**Nome:** `tipo/assunto` com os tipos do Conventional Commits, assunto curto em kebab-case, sem
acento: `feat/cadastro-usuario`, `fix/timeout-conexao`, `test/integracao-api`, `docs/readme-instalacao`.

## 1. Começar um trabalho novo

```bash
git status --short                      # pendências? ver abaixo
git fetch --prune origin
git branch -r; gh pr list --state open  # alguém já trabalha nisso?
git switch <principal>
git pull --no-rebase --no-edit origin <principal>
git switch -c tipo/assunto
```

- Já existe branch/PR de outra pessoa sobre o mesmo assunto: pare e pergunte.
- Mudanças não commitadas do trabalho novo vão junto com `git switch -c`. De outro assunto:
  pergunte antes; não use `git stash` sem avisar.
- Avise o nome da branch e o commit de origem. Ela vai para o remoto no primeiro commit (`push -u`).

## 2. Durante o trabalho

- Commits pela `fazer-commit` (envio automático para a branch).
- Quando a principal andar (`git log --oneline HEAD..origin/<principal>`):
  `git merge --no-edit origin/<principal>`, rodar `comando_testes`, enviar. Nunca rebase de branch
  já enviada sem pedido. Conflitos: seção "Resolver conflitos" da `fazer-commit`.
- Não commitar na branch de outra pessoa sem combinado.

## 3. Abrir o PR

Quando o usuário pedir. Antes: tudo commitado e enviado; branch atualizada com a principal; testes
passando. Mostrar título e descrição ao usuário antes de criar (o PR sai no nome dele).

```bash
gh pr create --base <principal> --head <branch> --title "<tipo>(<escopo>): <resumo>" \
  --body-file <arquivo-temporario> [--reviewer <login>] [--draft]
```

Descrição: **O que muda** (2–5 itens), **Como foi testado** (comando → resultado), **Para a
revisão** (onde olhar, o que ficou para depois) e, em trabalho acadêmico, **Uso de IA**; mais a
linha de atribuição pedida pelo sistema, se houver. `--reviewer` só com login indicado pelo usuário.
Depois, dar o link e lembrar quantas aprovações faltam.

## 4. Revisar o PR de um colega

`gh pr view <n>`, `gh pr diff <n>`, `gh pr checks <n>`; `gh pr checkout <n>` para rodar os testes
(depois `git switch -`). Conferir correção, testes e `checklist_revisao`. Mostrar os achados ao
usuário (arquivo:linha, problema, sugestão). **Publicar a revisão e aprovar são atos do usuário:**
só com pedido explícito, mostrando o texto antes (`gh pr review <n> --comment|--request-changes|--approve`).

## 5. Fazer o merge

Só quando o usuário pedir. Conferir
`gh pr view <n> --json reviewDecision,mergeable,mergeStateStatus,statusCheckRollup`:
aprovado, sem conflito, *checks* (ou testes locais) passando. Conflito → passo 2, depois conferir de novo.

```bash
gh pr merge <n> --<tipo_merge> --delete-branch
git switch <principal> && git pull --no-rebase --no-edit origin <principal>
git branch -d <branch>     # se ainda existir local
```

Nunca `--admin` (pula a revisão) nem outro método de merge sem pedido explícito.

## 6. Exceções direto na principal

Working tree limpa → `git switch <principal>` → `pull` → mudança → commit e envio pela
`fazer-commit` → voltar (`git switch -`). Push recusado por proteção (`GH006`): criar branch e PR;
não contornar a proteção.

## 7. Estado e limpeza

`git branch -vv`, `gh pr status`, `gh pr list`. Limpeza: `git fetch --prune` e `git branch -d` nas
branches de `git branch --merged <principal>`. Nunca `-D` nem apagar branch remota de outra pessoa
sem pedido.

## Proteção da branch principal

Configuração que acompanha o fluxo (aplicar só com pedido do usuário — vale para todos): exigir PR
com `aprovacoes` aprovações; administradores fora da regra se houver `direto_na_principal`; só o
`tipo_merge` habilitado; apagar branch depois do merge; com `ci`, exigir o *check*. Aprovação só
conta de quem tem escrita: colaboradores precisam ter aceitado o convite
(`gh api repos/<dono>/<repo>/invitations`), senão nenhum PR consegue ser aprovado.

## Segurança

- Nunca `push --force`, rebase de branch já enviada, `reset --hard` ou `--amend` sem pedido.
- Nunca aprovar, comentar, fechar ou fazer merge de PR sem pedido explícito.
- Nunca alterar configurações do repositório (proteção, métodos de merge, colaboradores) sem pedido.
- Não apagar branch de outra pessoa nem commitar nela sem combinado.
