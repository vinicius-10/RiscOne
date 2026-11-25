# 05 — basic_rv32s RV32I37F (Kang & Choi)

## Trabalho

- Autores: Kang & Choi (RISC-KC). Artigo: "basic_RV32s", IEEE ISOCC 2025,
  DOI 10.1109/ISOCC66390.2025.11329889; arXiv 2510.15887.
- GitHub: https://github.com/RISC-KC/basic_rv32s — licença MIT.
- Commit medido: `672fe0239ddcf820df0ccff3e9263f37481b5dd7` (2025-03-16, "[Feat] Revise Data Memory so
  that it can be read without delay"), em `repo/`. É o **último commit que alterou `RV32I37F.v`** e o
  único estado em que o top do 37F e os módulos compartilhados estão consistentes.
- `repo_head/` = HEAD atual (`69f8f12`), só para referência: lá `RV32I37F.v` é o mesmo arquivo, mas os
  módulos compartilhados (`PC_Controller`, `Branch_Logic`, `Control_Unit`, `Data_Memory`,
  `Instruction_Memory`) evoluíram para o pipeline 46F_5SP e mudaram de portas → o 37F do HEAD **não
  elabora** (ex.: `PCController` não tem mais `branch_taken`/`imm`). As tags v1.0.0/v2.0.x também já
  têm os módulos novos.

## Núcleo

- **Monociclo confirmado (CPI = 1)**: só são sequenciais o PC (`posedge clk or posedge reset`), a
  escrita do banco de registradores e a escrita da DMEM; IMEM e DMEM são lidas combinacionalmente.
  Nenhum estágio/stall (pc_stall/trapped amarrados a 0 no top).
- ISA: RV32I sem FENCE/ECALL/EBREAK (37 instruções). Verilog 2001.
- IMEM: 1024 × 32 bits (4 KiB), `reg` com leitura combinacional → ROM em LUTs (224 LUTs).
- DMEM: 1024 × 32 bits (4 KiB), leitura combinacional, escrita síncrona com máscara
  (read-modify-write) → LUTRAM (512 LUTRAM). Endereço = `alu_result[11:2]` (sem decodificação: todo o
  espaço de 4 GiB aliasa na DMEM). Loads não deslocam pelo `addr[1:0]` (LB/LH leem sempre o byte/meia
  palavra baixa) — característica do autor, não corrigida.
- Banco de registradores: 32 × 32, 2 leituras assíncronas → LUTRAM (44 LUTRAM + 28 LUTs).
- Reset: assíncrono, ativo alto, só no PC. Sem periféricos/MMIO.
- **Latches**: 58 latches inferidos (Instruction_Decoder sem `default`; Control_Unit e ALU_Controller
  sem atribuição em todos os ramos). Resultado do RTL do autor, não corrigido.

## Montagem

- Top: `wrapper/top_cmp.sv` instancia `RV32I37F` no `clk` de 100 MHz; `reset = ~CPU_RESETN`.
  LEDs = registrador de 16 bits carregado com `data_memory_write_data[15:0]` quando `memory_write`
  (opção b; o núcleo não tem MMIO). Sem `switch` (constr.xdc = base.xdc sem as chaves).
- Programa: `autoteste_placa` (`mem/prog_word.hex`, 389 palavras, via `$readmemh` na IMEM de 1024
  palavras) e dados `mem/data_word.hex` (17 palavras no endereço 0 da DMEM). O programa não roda
  corretamente neste núcleo (as escritas em MMIO 0x4000_0000 aliasam na DMEM endereço 0; loads de
  byte/meia palavra desalinhados divergem), mas serve para fixar o conteúdo da ROM como nos demais.
- Mudanças (todas em `patch/`, cópias do commit acima):
  1. `patch/modules/Instruction_Memory.v`: programa de teste embutido do autor (`data[i] = ...`) trocado
     por `$readmemh("prog_word.hex", data)`.
  2. `patch/modules/Data_Memory.v`: após o laço que zera a memória, `$readmemh("data_word.hex", memory, 0, 16)`.
  3. `patch/modules/RV32I37F.v`: duas portas de saída de observação (`dbg_memory_write`,
     `dbg_data_memory_write_data`) ligadas por `assign` aos fios internos, para o wrapper.
  4. `patch/RV32I37F_flat.v`: gerado por `scripts/achatar.py` (meu) — expande os `` `include "modules/..." ``
     do top (cada arquivo uma vez, `patch/` antes de `repo/RV32I/`). Necessário porque o `medir.ps1`
     passa `-include_dirs` ao `read_verilog`, que **não aceita essa opção** (erro Common 17-170; bug do
     `medir.ps1`, não editado). Nenhuma lógica alterada.
- Ficou de fora: nada de periférico (o núcleo não tem).

## Resultados (`-Final`, build/final/resumo.txt)

```
Kang & Choi - basic_rv32s RV32I37F (monociclo)  |  tag final  |  route  |  132 s  |  pico 2070.703 MB
Timing: periodo 10 ns | WNS -5,959 | TNS -12370,617 | violando 5222/5238 | WHS 0,536 | THS 0 | Fmax 62,7 MHz
Caminho critico: 15,648 ns (logica 3,47 / rota 12,178) niveis 17 (LUT3=1 LUT6=11 MUXF7=3 MUXF8=1 RAMS64E=1)
   de:   core/program_counter/pc_reg[4]/C
   para: core/register_file/registers_reg_r1_0_31_30_31/DP/I
Area: LUTs 1984 (logica 1428, LUTRAM 556) | FFs 108 | latches 58 | F7 351 | F8 129 | CARRY4 48 | Slices 587 | BRAM 0 | DSP 0 | IOB 18
Potencia: total 0,127 W | dinamica 0,03 W | estatica 0,097 W | Tj 25,6 C | confianca Medium
Etapas: synth_design 00:00:35 | opt_design 00:00:07 | place_design 00:00:44 | route_design 00:00:33
Warnings 116 | CRITICAL 0 | latches(log) 16 | pinos sem restricao de max delay: 58 | regs sem clock: True
```

Por hierarquia (util_hier): control_unit 655 LUTs, data_memory 591 (512 LUTRAM), instruction_memory
224, alu_controller 201, program_counter 158, register_file 72 (44 LUTRAM). Núcleo íntegro (sem poda).
Os 108 "FFs" do relatório contam também os latches (só PC 32 + LEDs 16 são FFs de fato; o resto são
células de latch do decodificador/controle).

## Publicado pelo autor × medido

Os autores não sintetizaram o RV32I37F (README: "RV32I37F | - | - |"). Só publicaram o pipeline
RV32I46F_5SP: 3.010 LUTs, 2.383 FFs (README; o artigo cita 998 FFs) a 50 MHz em XC7A200T, Vivado 2024.2
com estratégias Flow_PerfOptimized_high / Performance_Explore. Não comparável diretamente.

## Observações para a comparação

- Monociclo de verdade (memórias combinacionais), como o do TCC.
- DMEM de 4 KiB (4× a do TCC) → ~512 LUTRAM a mais que o TCC na DMEM; IMEM do mesmo tamanho (4 KiB).
- 58 latches no decodificador/controle: inflam área e aparecem no caminho crítico (TIMING-20).
- Commit histórico (não o HEAD), pelo motivo acima.
