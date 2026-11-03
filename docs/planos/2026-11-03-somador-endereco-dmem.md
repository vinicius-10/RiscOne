# Somador dedicado para o endereço da memória de dados
Data: 2026-11-03 · Status: concluído

**Resultado:** 10/10 testbenches (4 casos novos de `mem_addr_o` no `tb_execution`; `tb_program` passa com `selftest` e `autoteste_placa`). `addr_dedicado` × `base_completo`: WNS −7,625 → −4,207 ns (56,7 → 70,4 MHz), LUTs 1684 → 1801. Sem desvios do plano.

## Objetivo e critério de pronto

Tirar a decodificação do seletor da ALU-B, o mux da ALU-B e o mux final da ALU do caminho crítico de load/store. O endereço da `data_memory` passa a vir de um somador próprio `rs1 + imm`, em paralelo à ALU.

Pronto quando:
- os 10 testbenches passam (`run_tb.ps1`), com casos novos de `mem_addr_o` no `tb_execution`;
- `synth.ps1 -Tag addr_dedicado -App placa` mostra o WNS melhor que a base `base_completo` (−7,625 ns) além do ruído (~0,3 ns). Expectativa: ~−4,5 ns. Se não melhorar, reverte.

## Decisões

| Dúvida | Escolha | Motivo |
| :-- | :-- | :-- |
| Onde fica o somador | Na `execution` (nova saída `mem_addr_o`) | Já recebe `reg_data1_i` e `imm_i`; a `data_memory` não muda e o `tb_data_memory` continua igual. |
| Operação da ALU em loads/stores | Não muda (continua `OP_ADD` com imediato) | Mudança mínima. O `alu_result` de load/store deixa de ser usado (load escreve o dado da memória; store não escreve no register file), e a síntese remove o que ficar sem uso. |
| Endereço em instruções que não acessam memória | Fica `rs1 + imm` (antes era o resultado da ALU) | Sem efeito: escrita na RAM/MMIO só com `mem_write_i`, leitura sem efeito colateral, `data_o` só é usado com `mem_to_reg`. |

## Arquitetura

```text
core
├── execution
│   ├── alu (inalterada)                 -> alu_result_o -> write_back
│   ├── somador do desvio (inalterado)   -> pc_branch_o
│   └── NOVO: mem_addr = reg_data1_i + imm_i -> mem_addr_o -> data_memory.addr_i
└── data_memory (inalterada)
```

Sinal novo no `core`: `data_memory_addr` (saída `mem_addr_o` da `execution` → `addr_i` da `data_memory`). O `alu_result` continua indo só para o `write_back`.

## Interfaces

| Módulo | Porta | Dir | Largura/tipo | Descrição |
| :-- | :-- | :-- | :-- | :-- |
| `execution` | `mem_addr_o` | out | `[XLEN-1:0]` | Endereço de load/store: `reg_data1_i + imm_i` (combinacional). |

## Controle

Não se aplica: nenhum sinal ou encoding novo; o `control_unit` não muda.

## Temporização

- Tudo combinacional, como hoje.
- Caminho do load antes: PC → IMEM → decodificação do seletor da ALU-B → mux da ALU-B → somador/mux da ALU → DMEM → alinhamento → register file (18 níveis).
- Depois: PC → IMEM → (leitura do RF ‖ `imm_gen`) → somador dedicado → DMEM → alinhamento → register file. Saem ~3–4 níveis (estimativa de ~3 ns).
- Área: +1 somador de 32 bits (~8 CARRY4 / ~32 LUTs).

## Verificação (testbench primeiro)

- `tb_execution`: conectar `mem_addr_o` e checar `rs1 + imm` com imediato positivo, negativo (ex.: `0x100 + (-4) = 0xFC`), endereço MMIO (`0x4000_0000 + 0xC`) e estouro em 32 bits. Os casos são independentes da operação da ALU: checar também com `control_alu_b` ≠ imediato, mostrando que o endereço não depende do mux da ALU-B.
- Antes da implementação, o `tb_execution` não compila (a porta não existe). Para uma porta nova, é a falha esperada.
- `tb_core` e `tb_program` cobrem loads/stores no core completo (incluindo offsets negativos e MMIO) e não mudam.

## Arquivos

| Arquivo | Mudança |
| :-- | :-- |
| `sources_1/new/execution.sv` | porta `mem_addr_o` + `assign mem_addr_o = reg_data1_i + imm_i;` + Doxygen `@retval` |
| `sources_1/new/core.sv` | sinal `data_memory_addr`; `data_memory.addr_i` ligado a ele |
| `sim_1/new/tb_execution.sv` | casos de `mem_addr_o` |
| `docs/ESPEC_RV32I.md` | §7 (interface da `execution`) e §8 (ligação do endereço da DMEM) |
| `docs/TIMING.md` | medição antes → depois |

## Passos de execução

1. Estender o `tb_execution` e confirmar que falha (porta inexistente).
2. Implementar em `execution.sv` e `core.sv`.
3. `run_tb.ps1` completo.
4. `synth.ps1 -Tag addr_dedicado -App placa` e comparar com `base_completo`.
5. Manter ou reverter conforme o resultado; atualizar ESPEC e TIMING.md.

## Ações do usuário no Vivado

Não se aplica: nenhum arquivo novo ou movido.

## Documentação a atualizar

ESPEC_RV32I.md §7/§8, TIMING.md. README/DOCUMENTACAO/CLAUDE.md não descrevem esse fio (conferir no passo 5). A skill `rv32i-programas` não muda (software não é afetado).

## Riscos e fora do escopo

- Risco: o Vivado já pode estar fundindo parte dessa lógica; se o ganho ficar abaixo de ~0,3 ns, reverte.
- Fora do escopo: comparador de branch dedicado, simplificar o alinhamento de load, pipeline e clock por MMCM (próximas alavancas, uma de cada vez).
