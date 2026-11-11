# Imediato dedicado para o endereço de load/store
Data: 2026-11-04 · Status: concluído (revertido pelo critério)

**Resultado:** implementado e testado (10/10 testbenches, `tb_program` com `autoteste_placa`; casos novos no `tb_decoder` e no `tb_execution`), mas **revertido**. `imm_mem` −3,614 ns e `imm_mem_explore` −3,626 ns, contra −3,470 / −3,469 da base (`alu_eq_direto`); +30 LUTs. O imediato saiu do caminho crítico, como previsto, mas o caminho do `rs1` (ROM → endereço do register_file → leitura da LUTRAM → somador) já chegava junto e passou a limitar. Ficaram só as correções de typo no Doxygen do `imm_gen` (`instuction_i`) e num comentário do `tb_decoder`.

## Objetivo e critério de pronto

O somador do endereço da memória de dados (`execution.mem_addr_o = rs1 + imm`) recebe hoje o imediato geral do `imm_gen`. Esse imediato escolhe entre os formatos I/S/B/U/J pelos 7 bits do opcode. No caminho crítico (`alu_eq_direto`, −3,470 ns) isso custa 2 níveis de LUT e uma rede com fanout 64 a 18 entre a ROM da IMEM e o somador:

```text
PC → ROM (3 níveis) → LUT5 (fanout 64) → LUT6 (imediato) → LUT3 + CARRY4 → endereço → RAM → ...
```

Loads e stores só usam os formatos I e S. Os 7 bits altos do imediato são iguais nos dois (`instr[31:25]`); só os 5 bits baixos mudam (I: `instr[24:20]`, S: `instr[11:7]`), e `instr[5]` separa LOAD (0) de STORE (1). Um imediato próprio para o endereço sai em 1 nível a partir da ROM:

```text
imm_mem = sext({instr[31:25], instr[5] ? instr[11:7] : instr[24:20]})
```

Pronto quando:
- os 10 testbenches passam. O `tb_decoder` confere `imm_mem_o` em loads e stores, incluindo um store com offset negativo em que as leituras I e S dão valores diferentes. O `tb_execution` mostra que `mem_addr_o` e as flags de região usam `imm_mem_i`, e não `imm_i`;
- a medição segue o critério da seção Decisões.

## Decisões

| Dúvida | Escolha | Motivo |
| :-- | :-- | :-- |
| Onde gerar o imediato novo | No `imm_gen` (saída `imm_mem_o`), repassado pelo `decoder` | É o módulo dos imediatos; o `decoder` só repassa, como já faz com `imm_o`. |
| Valor fora de load/store | Qualquer (o campo é lido como I ou S conforme `instr[5]`) | O endereço e as flags de região só são usados em load/store (`mem_write` só em STORE, `mem_to_reg` só em LOAD), como no plano `2026-11-04-regiao-sem-carry`. |
| Quem continua usando `imm_i` | ALU, alvo de desvio e tudo o que não for o endereço da DMEM | Mudança mínima: só o somador do endereço e as flags de região trocam de entrada. |
| Critério de manter | Medir com o placement padrão e com `Explore`. Manter se o melhor WNS for igual ou melhor que a base (−3,470 / −3,469 ns) e o caminho do imediato tiver encurtado; senão reverter | Decisão do usuário (04/11): o ganho esperado (≤0,5 ns) está no tamanho do ruído, e uma mudança estrutural correta acumula com as próximas. |

## Arquitetura

```text
core
├── decoder
│   └── imm_gen
│       ├── imm_o      (inalterado)      -> decoder.imm_o     -> execution.imm_i       (ALU, desvio)
│       └── NOVO imm_mem_o (I/S, 1 nível) -> decoder.imm_mem_o -> execution.imm_mem_i  (endereço da DMEM)
└── execution
    ├── mem_addr_o  = reg_data1_i + imm_mem_i            (antes: + imm_i)
    └── flags de região usam imm_mem_i[11] e imm_mem_i[11:0]   (antes: imm_i)
```

Sinal novo no `core`: `immediate_mem` (`decoder.imm_mem_o` → `execution.imm_mem_i`).

## Interfaces

| Módulo | Porta | Dir | Largura/tipo | Descrição |
| :-- | :-- | :-- | :-- | :-- |
| `imm_gen` | `imm_mem_o` | out | `[31:0]` | Imediato de load/store: `sext({instr[31:25], instr[5] ? instr[11:7] : instr[24:20]})`. Só é válido em LOAD/STORE. |
| `decoder` | `imm_mem_o` | out | `[XLEN-1:0]` | Repassa `imm_gen.imm_mem_o`. |
| `execution` | `imm_mem_i` | in | `[XLEN-1:0]` | Imediato do endereço de load/store; substitui `imm_i` no somador `mem_addr_o` e nas flags de região. |

## Controle

Não se aplica: nenhum sinal ou encoding novo; o `control_unit` não muda.

## Temporização

- Tudo combinacional, como hoje.
- Caminho do imediato até o somador: de ROM → LUT5 (fanout 64) → LUT6 para ROM → 1 LUT (que a síntese pode fundir com a LUT de propagação do somador). Saem 1 a 2 níveis e a rede de fanout alto.
- Limite: o `rs1` lido do register_file chega ao somador quase junto com o imediato (ROM → endereço do RF → leitura da LUTRAM). Por isso o ganho esperado no WNS é ≤0,5 ns. O caminho do imediato deve sumir dos piores, e o do `rs1` passa a dominar o load.
- Área: +5 LUTs (mux dos 5 bits baixos); o imediato geral continua igual.

## Verificação (testbench primeiro)

- **`tb_decoder`:** task `check_imm_mem` chamada nos testes de load/store existentes (LW −4, SW +16), mais:
  - `SW x2, -1(x1)`: o imediato S vale −1 (`0xFFFF_FFFF`), enquanto a leitura I do mesmo campo daria `0xFFFF_FFE2`. Isso detecta a seleção trocada;
  - `LB` com offset `0x7FF` (maior positivo).
- **`tb_execution`:** sinal `imm_mem_i` no DUT; os casos 35–49 passam a dirigir `imm_mem_i`. Num caso novo, `imm_i` recebe um valor diferente, para mostrar que o endereço e as flags não dependem de `imm_i`.
- **`tb_core` e `tb_program`:** não mudam. Já cobrem loads/stores com offsets positivos, negativos e cruzando fronteiras de região no core completo.
- **Falha esperada antes da implementação:** `tb_decoder` e `tb_execution` não elaboram (portas inexistentes).
- **Ponto de partida:** 10/10 com o RTL atual (`23832f4`).

## Arquivos

| Arquivo | Mudança |
| :-- | :-- |
| `sources_1/new/imm_gen.sv` | saída `imm_mem_o` + `@retval`; corrige o typo `instuction_i` no Doxygen |
| `sources_1/new/decoder.sv` | saída `imm_mem_o` ligada ao `imm_gen`; Doxygen |
| `sources_1/new/execution.sv` | entrada `imm_mem_i` no somador `mem_addr_o` e nas flags de região; Doxygen |
| `sources_1/new/core.sv` | sinal `immediate_mem` ligando `decoder` → `execution` |
| `sim_1/new/tb_decoder.sv` | porta nova, `check_imm_mem`, casos de load/store |
| `sim_1/new/tb_execution.sv` | porta nova; casos 35–49 com `imm_mem_i`; caso novo com `imm_i` diferente |
| `docs/ESPEC_RV32I.md` | §4 (imediatos: `imm_mem_o`), §7 (interfaces de `imm_gen`, `decoder`, `execution`), §8 (ligação), §9 (flags usam `imm_mem`) |
| `docs/TIMING.md` | medições e diagnóstico |
| `CLAUDE.md` | linha da `execution` na árvore de arquitetura (somador usa o imediato de load/store) |

`run_tb.ps1` não muda: os submódulos de cada testbench continuam os mesmos.

## Passos de execução

1. Estender `tb_decoder` e `tb_execution` e confirmar que falham na elaboração (portas).
2. Implementar `imm_gen`, `decoder`, `execution` e `core`.
3. `run_tb.ps1` completo e `tb_program -App autoteste_placa`.
4. Medir em paralelo: `synth.ps1 -Tag imm_mem -App placa` e `synth.ps1 -Tag imm_mem_explore -App placa -PlaceDirective Explore -RouteDirective Explore`.
5. Decidir pelo critério; atualizar ESPEC, TIMING.md e CLAUDE.md (ou reverter e registrar só no TIMING.md).

## Ações do usuário no Vivado

Não se aplica: nenhum arquivo novo ou movido.

## Documentação a atualizar

ESPEC_RV32I.md §4/§7/§8/§9, TIMING.md e CLAUDE.md. README e DOCUMENTACAO_PROJETO.md não descrevem esses fios (conferir no passo 5). A skill `rv32i-programas` não muda: o software não é afetado.

## Riscos e fora do escopo

- O ganho pode ficar inteiramente dentro do ruído; o critério acima decide.
- Fora do escopo: simplificar o `imm_gen` geral (decodificação com menos bits do opcode), reduzir a RAM de dados, MMCM. Pipeline e BRAM estão descartados (o core continua monociclo).
