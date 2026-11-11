# Decodificação de região da DMEM fora da cadeia de carry
Data: 2026-11-04 · Status: concluído

**Resultado:** 10/10 testbenches (casos 39–49 no `tb_execution`, 5000 vetores aleatórios; 10 instruções novas no `tb_core`; `tb_program` passa com `selftest` e `autoteste_placa`). `regiao_carry_sel` × `mmio_somente_escrita`: WNS −4,724 → −3,656 ns (67,9 → 73,2 MHz), LUTs 1676 → 1826 (acima da estimativa de +40–80). Teto (b) `regiao_rasa_teto`: −4,618 ns, sem ganho adicional. Sem desvios do plano; README e DOCUMENTACAO não precisaram mudar (o mapa de memória é o mesmo).

## Objetivo e critério de pronto

A `data_memory` só sabe se o acesso é RAM, MMIO ou fora do mapa depois que o carry do somador `rs1 + imm` chega ao bit 31. Essa decodificação é o ponto mais lento do caminho crítico (`mmio_somente_escrita`, −4,724 ns):

```text
PC → IMEM → imediato → somador (carry até o bit 22..31) → decodificação de região (3 LUTs, fanout 45)
   → mux RAM/MMIO → byte/sinal → write-back → register_file
```

A ideia é calcular as duas flags de região (`addr[31:28] == 4` e `addr[31:12] == 0`) **sem esperar o carry**. O comportamento continua exatamente o mesmo.

Pronto quando:
- os 10 testbenches passam (`run_tb.ps1`). O `tb_execution` ganha casos dirigidos e aleatórios das flags, o `tb_data_memory` passa a gerar as flags a partir do endereço e o `tb_core` ganha loads/stores que cruzam fronteiras de região;
- `synth.ps1 -Tag regiao_carry_sel -App placa` mostra o WNS melhor que `mmio_somente_escrita` (−4,724 ns) além do ruído (~0,5 ns). Expectativa: entre −3,0 e −3,3 ns. Se não melhorar além do ruído, reverte;
- a opção (b) é medida num worktree só como teto (`regiao_rasa_teto`) e não é mantida.

## Decisões

| Dúvida | Escolha | Motivo |
| :-- | :-- | :-- |
| Exata (a) ou simplificada (b) | (a) mantida; (b) medida só como teto | (a) não muda comportamento. O teto da (b) mostra quanto ainda sobraria com a decodificação mais rasa possível (decisão do usuário, 04/11). |
| Onde fica a lógica nova | `execution` gera as flags; a `data_memory` as recebe | Só a `execution` vê `rs1` e o imediato separados (decisão do usuário, 04/11). |
| Validade das flags | Exatas só com imediato de 12 bits estendido (`imm[31:11]` iguais), ou seja, loads e stores | `mem_write` só liga em STORE e `mem_to_reg` só em LOAD (`control_unit`). Nas outras instruções as flags podem diferir de `rs1 + imm`, mas ninguém as usa: não há escrita e `data_o` não chega ao register file. |
| `MEM_DEPTH` ≠ 1024 | `ram_addr_valid = addr_page0_i && (addr_i[11:0] < MEM_DEPTH*4)` e erro de elaboração se `MEM_DEPTH*4 > 4096` | Mantém o suporte atual a memórias menores (o termo extra só usa bits baixos, prontos cedo, e é constante 1 com 1024). Memórias maiores que 4 KiB exigiriam outra fronteira de página. |

## Arquitetura

Com imediato de 12 bits, `addr[31:12] = rs1[31:12] + (imm[11] ? −1 : 0) + c12`, onde `c12` é o carry de `rs1[11:0] + imm[11:0]`. Só há três valores possíveis:

| `imm[11]` | `c12` | `addr[31:12]` |
| :-: | :-: | :-- |
| 0 | 0 | `rs1[31:12]` |
| 0 | 1 | `rs1[31:12] + 1` |
| 1 | 0 | `rs1[31:12] − 1` |
| 1 | 1 | `rs1[31:12]` |

As flags dos três candidatos são calculadas em paralelo, só a partir de `rs1`. Depois, um mux 3:1 escolhe uma delas pelo par `{imm[11], c12}`. O carry só precisa atravessar 12 bits (3 CARRY4) em vez de 32 (8 CARRY4).

```text
core
├── execution
│   ├── somador rs1 + imm (inalterado)                 -> mem_addr_o       -> data_memory.addr_i
│   └── NOVO: flags dos candidatos rs1[31:12] − 1 / + 0 / + 1
│             escolhidas por {imm[11], c12}            -> mem_io_o         -> data_memory.addr_io_i
│                                                      -> mem_page0_o      -> data_memory.addr_page0_i
└── data_memory
    ├── is_io_space    = addr_io_i                      (antes: addr_i[31:28] == 4)
    └── ram_addr_valid = addr_page0_i && addr_i[11:0] < MEM_DEPTH*4   (antes: addr_i < MEM_DEPTH*4)
```

Sinais novos no `core`: `data_memory_addr_io` e `data_memory_addr_page0`. `addr_i[31:12]` deixa de ser usado na `data_memory` (a síntese remove a parte alta do somador). A porta continua com 32 bits, para não mudar a interface sem necessidade.

## Interfaces

| Módulo | Porta | Dir | Largura/tipo | Descrição |
| :-- | :-- | :-- | :-- | :-- |
| `execution` | `mem_io_o` | out | `logic` | `mem_addr_o[31:28] == 4'h4`, sem esperar o somador. Exata para imediato de 12 bits (load/store). |
| `execution` | `mem_page0_o` | out | `logic` | `mem_addr_o[31:12] == 0`, idem. |
| `data_memory` | `addr_io_i` | in | `logic` | Endereço no espaço de MMIO (substitui a comparação interna de `addr_i[31:28]`). |
| `data_memory` | `addr_page0_i` | in | `logic` | Endereço nos primeiros 4 KiB (substitui a comparação interna de `addr_i[31:12]`). |

## Controle

Não se aplica: nenhum sinal ou encoding novo; o `control_unit` não muda.

## Temporização

- Tudo combinacional, como hoje.
- Antes, as flags ficavam prontas depois de 8 CARRY4 mais 3 LUTs (cerca de 15,9 ns no relatório). Depois, ficam prontas no mais lento entre:
  - `c12` (3 CARRY4) seguido de 1 LUT de mux;
  - comparações de `rs1[31:12]` (2 níveis de LUT, em paralelo com o somador).

  Estimativa: as flags ficam prontas ~1,5–2 ns antes.
- Próximo gargalo provável: a leitura da LUTRAM (`addr[11:2]` → RAM → MUXF7/F8 → byte/sinal) ou o laço de desvio até o PC.
- Área: +3 comparações de 20 bits e 2 incrementadores sobre `rs1[31:12]` (que a síntese pode reduzir), menos a parte alta do somador. Estimativa líquida: +40 a +80 LUTs.

## Verificação (testbench primeiro)

- **`tb_execution`:** ligar `mem_io_o`/`mem_page0_o` e criar a task `check_mem_region`.
  - Casos dirigidos nas fronteiras:

    | rs1 | imm | Endereço | Região |
    | :-- | --: | :-- | :-- |
    | `0x0000_0FFC` | +4 | `0x1000` | fora |
    | `0x0000_1000` | −4 | `0xFFC` | RAM |
    | `0xFFFF_FFFC` | +4 | `0x0` | RAM (estouro) |
    | `0x0000_0000` | −4 | `0xFFFF_FFFC` | fora |
    | `0x3FFF_FFF0` | +0x10 | `0x4000_0000` | MMIO |
    | `0x4000_0000` | −4 | `0x3FFF_FFFC` | fora |
    | `0x4FFF_FFFC` | +4 | `0x5000_0000` | fora |
    | `0x5000_0004` | −8 | `0x4FFF_FFFC` | MMIO |
    | `0x4000_0010` | +0x7FF | `0x4000_080F` | MMIO |
    | `0x0000_0800` | −0x800 | `0x0` | RAM |

  - Laço aleatório de 5000 vetores: `rs1[31:12]` sorteado entre valores de fronteira (`0`, `1`, `0xFFFFF`, `0x3FFFF`, `0x40000`, `0x4FFFF`, `0x50000`) e valores livres; `rs1[11:0]` e o imediato de 12 bits livres. Cada vetor é comparado com a referência `rs1 + sext(imm)` e o laço gera uma linha `[PASS]`/`[FAIL]` com os primeiros erros.
- **`tb_data_memory`:** ligar as entradas novas com `assign addr_io_i = addr_i[31:28] == 4'h4;` e `assign addr_page0_i = addr_i[31:12] == 0;`. O testbench passa a fazer o papel da decodificação de referência, e os 46 testes atuais ficam iguais.
- **`tb_core`:** loads e stores que cruzam fronteiras pelo imediato, cobrindo a ligação no core completo:
  - `sw`/`lw` em `-4(x)` com `x = 0x1000` → RAM `0xFFC`;
  - `lw` em `0x20(x)` com `x = 0x3FFF_FFF0` → `in0`;
  - `sw` em `0x10(x)` com `x = 0x3FFF_FFF0` → `out0`;
  - `lw` em `-4(x12)` com `x12 = 0x4000_0000` → lê 0;
  - `lw` em `4(x)` com `x = 0xFFC` → `0x1000`, lê 0.

  Esses casos passam também antes da implementação: servem de guarda de regressão.
- **Falha esperada antes da implementação:** `tb_execution` e `tb_data_memory` não compilam (portas inexistentes). É a falha esperada para portas novas. `tb_program` (selftest) e `autoteste_placa` não mudam.

## Arquivos

| Arquivo | Mudança |
| :-- | :-- |
| `sources_1/new/execution.sv` | portas `mem_io_o`/`mem_page0_o`, carry `c12`, flags dos 3 candidatos e mux; Doxygen `@retval` |
| `sources_1/new/data_memory.sv` | entradas `addr_io_i`/`addr_page0_i`; `is_io_space`/`ram_addr_valid` passam a usá-las; checagem de `MEM_DEPTH*4 <= 4096`; Doxygen `@param` |
| `sources_1/new/core.sv` | sinais `data_memory_addr_io`/`data_memory_addr_page0` ligando as duas |
| `sim_1/new/tb_execution.sv` | portas novas, `check_mem_region`, casos dirigidos e laço aleatório |
| `sim_1/new/tb_data_memory.sv` | portas novas geradas a partir de `addr_i` |
| `sim_1/new/tb_core.sv` | loads/stores cruzando fronteiras |
| `docs/ESPEC_RV32I.md` | §7 (interfaces da `execution`/`data_memory`), §8 (ligações), §9 (decodificação) |
| `docs/TIMING.md` | `regiao_carry_sel` e `regiao_rasa_teto` com diagnóstico |
| `CLAUDE.md` | linha da `execution` na árvore de arquitetura (flags de região) |

`run_tb.ps1` não muda: os submódulos de cada testbench continuam os mesmos.

## Passos de execução

1. Estender `tb_execution`, `tb_data_memory` e `tb_core`. Rodar e confirmar que os dois primeiros falham na compilação (portas) e que o `tb_core` passa.
2. Implementar `execution.sv`, `data_memory.sv` e `core.sv`.
3. `run_tb.ps1` completo.
4. Em paralelo, em segundo plano:
   - `synth.ps1 -Tag regiao_carry_sel -App placa` no repositório;
   - num worktree a partir de `HEAD`, aplicar só a (b) (`is_io_space = addr_i[30]`, `ram_addr_valid = 1` na leitura, escrita na RAM só com `~addr_i[30]`) e rodar `synth.ps1 -Tag regiao_rasa_teto -App placa`. Remover o worktree depois.
5. Comparar com `mmio_somente_escrita`. Manter (a) se ganhar > 0,5 ns; senão reverter.
6. Atualizar ESPEC, TIMING.md e CLAUDE.md; marcar este plano como concluído.

## Ações do usuário no Vivado

Não se aplica: nenhum arquivo novo ou movido.

## Documentação a atualizar

ESPEC_RV32I.md §7/§8/§9, TIMING.md e CLAUDE.md (árvore de arquitetura). README e DOCUMENTACAO_PROJETO.md não descrevem esses fios (conferir no passo 6). A skill `rv32i-programas` não muda: o mapa de memória visto pelo software é o mesmo.

## Riscos e fora do escopo

- O Vivado pode refazer a lógica e anular parte do ganho. A decisão de manter vem só da medição.
- Novas portas carregam uma suposição (imediato de 12 bits). Fica documentada no Doxygen da `execution` e no ESPEC; se no futuro outro formato de instrução acessar a DMEM, as flags precisam ser revistas.
- Fora do escopo: reordenar a seleção de byte/sinal antes do mux de região, opções de ferramenta (`phys_opt_design`, `Explore`), pipeline e MMCM. São as próximas alavancas, uma de cada vez.
