# 01 — Asghar: Single-Cycle RISC-V Processor Implemented on FPGA

## Trabalho

- Autor: Awais Asghar (NCDC, Paquistão). Relatório de projeto "Single-Cycle RISC-V Processor
  Implemented on FPGA" (`repo/Project Report.pdf`), 2025.
- GitHub: https://github.com/Awais-Asghar/Single-Cycle-RISC-V-Processor-Implemented-on-FPGA
- Commit clonado: `c60e828b3be8207070887369af67f97d0e853eef` (clone raso). Licença MIT.

## Núcleo

- **Monociclo confirmado (CPI = 1):** só o PC é registrador; IMEM e leitura da DMEM são
  combinacionais (`assign inst = memory[addr[31:2]]`, `dataR` em `always_comb`); escrita no banco
  e na DMEM na borda de subida do mesmo ciclo. Um único domínio de clock, só borda de subida.
- HDL: SystemVerilog. Alvo do autor: Nexys A7 (mesma placa), Vivado.
- ISA: o autor declara "RV32I completo". Lendo o RTL: FENCE/ECALL/EBREAK não são decodificados
  (caem no `default`, viram NOP). **LUI provavelmente errado:** usa `alu_in1 = reg_data1`
  (registrador apontado pelos bits 19:15 do imediato) + imm, em vez de 0 + imm. Não corrigido
  (medir, não consertar); não afeta área/timing de forma relevante.
- IMEM: 256 palavras = 1 KiB (o comentário diz "2KB"), ROM combinacional → virou LUTs (121).
- DMEM: 256 palavras = 1 KiB, leitura assíncrona, escrita síncrona por byte → LUTRAM (128 LUTs
  como memória). Indexada por `addr[31:2]` sem decodificação: só `addr[9:2]` é usado, então
  endereços de MMIO do nosso programa (0x4000_0000) fazem alias na RAM.
- Banco de registradores: 32×32, 2 leituras assíncronas → LUTRAM (44 LUTRAM + lógica), iniciado
  por `$readmemh("reg_init.mem")`, sem reset.
- Reset: síncrono, ativo alto, só no PC. Sem periféricos/MMIO.

## Montagem

- Top do autor (`top.sv`) já é limpo (núcleo + IMEM + DMEM, sem divisor de clock), mas não tem
  LEDs; usado dentro de `wrapper/top_cmp.sv`: `clk` direto, `reset = ~CPU_RESETN`.
- LEDs (opção c, o top não expõe o dado de store nem tem MMIO):
  `if (reg_write_en) led <= alu_result_out[15:0];` — registrador de 16 bits.
- `constr.xdc` = `base.xdc` sem as chaves (o núcleo não tem entradas).
- Programa: `programa/prog_word.hex` **truncado nas primeiras 256 das 389 instruções** (IMEM do
  autor tem 256 palavras) → `mem/instructions.mem`; `programa/data_word.hex` → `mem/data_mem.mem`
  (nomes que o `$readmemh` do autor espera). `reg_init.mem` do próprio repositório.
- **Nenhuma mudança no RTL do autor.** `patch/` não foi usado.
- `src/` é uma junção (junction) para `repo/Source Code/`: o `medir.ps1` falha com caminhos com
  espaço (`read_verilog -sv {.../Source Code/...}` → "File '.../repo/Source' does not exist").
- Poda verificada (`util_hier.rpt`): rf 149 LUTs, dmem 130, imem 121; ALU, decodificador, imm_gen
  e comparador foram achatados dentro de `pc_inst` (979 LUTs). FFs = 32 (PC) + 16 (LEDs).

## Resultados (`build/final/resumo.txt`, execução -Final)

```
Asghar - Single-Cycle RISC-V (top)  |  tag final  |  route  |  166.3 s  |  pico 2066.863 MB
Timing: periodo 10 ns | WNS -5,141 | TNS -1786,617 | violando 1268/1940 | WHS 0,427 | THS 0 | Fmax 66 MHz
Caminho critico: 14,827 ns (logica 3,858 / rota 10,969) niveis 17 (CARRY4=1 LUT2=1 LUT6=9 MUXF7=2 MUXF8=2 RAMD32=1 RAMS64E=1)
   de:   core/pc_inst/pc_out_reg[7]/C
   para: core/rf/reg_file_reg_r1_0_31_30_31/DP/I
Area: LUTs 1374 (logica 1202, LUTRAM 172) | FFs 48 | latches 0 | F7 114 | F8 57 | CARRY4 59 | Slices 376 | BRAM 0 | DSP 0 | IOB 18
Potencia: total 0,147 W | dinamica 0,049 W | estatica 0,097 W | Tj 25,7 C | confianca Medium
Etapas: synth_design 00:01:12 | opt_design 00:00:13 | place_design 00:00:35 | route_design 00:00:33
Warnings 72 | CRITICAL 0 | latches(log) 0 | pinos sem restricao de max delay: 0 | regs sem clock: False
   TIMING-16 [Warning] Large setup violation: 695
   TIMING-18 [Warning] Missing input or output delay: 17
```

Caminho crítico: PC → IMEM (ROM em LUTs/MUXF) → banco → ALU → DMEM (LUTRAM) → write-back →
banco de registradores (load completo em um ciclo).

## Publicado × medido

- O autor diz "deployed ... without timing violations", sem frequência nem área. Aqui, a 100 MHz,
  **não fecha timing** (WNS −5,1 ns, Fmax ≈ 66 MHz). Provável que o autor tenha usado clock mais
  lento/divisor ou uma restrição diferente; o repositório não traz XDC.

## Observações para a comparação

- Programa truncado (256/389 instruções) → a ROM tem menos conteúdo que a do TCC (4 KiB, 389
  instr.); a área de IMEM fica um pouco subestimada em relação a um programa completo.
- Sem MMIO/periféricos (o TCC inclui MMIO); LEDs via registrador do resultado da ALU.
- Memórias: IMEM em LUTs, DMEM e banco em LUTRAM — mesmo estilo do TCC; nada em BRAM ou FFs.
- Bug funcional provável no LUI e ausência de FENCE/ECALL/EBREAK (não afetam a medição).
