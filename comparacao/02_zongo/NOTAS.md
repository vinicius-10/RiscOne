# 02 — Zongo, rv32i-core

## Trabalho

- Autor: Wendyam Clovis Dubois Zongo. Projeto independente (estudo pessoal), sem artigo nem DOI.
- Título: "RV32I Single-Cycle Core" (README do repositório), 2026.
- GitHub: https://github.com/WendyamZongo/rv32i-core
- Commit clonado (`git clone --depth 1`): `fbd1fb6119c22c95a4b0b2498a15dcc0d80e3686` (2026-10-21).
- Licença: MIT.

## Núcleo

- **Monociclo confirmado (CPI = 1):** o único registrador do caminho de dados é o PC (`pc.v`); IMEM
  com leitura combinacional (`assign inst = mem[addr[31:2]]`), banco de registradores e DMEM com
  leitura assíncrona e escrita em `posedge clk`. Uma instrução por borda, sem estágios nem stalls.
- ISA: RV32I, 31/37 instruções completas segundo o autor. A DMEM só faz acesso a palavra: `lb/lh/lbu/lhu/sb/sh`
  são decodificados como acessos de palavra (sem lanes de byte nem extensão de sinal). `fence/ecall/ebreak` = NOP.
- HDL: Verilog-2001, 10 módulos (`core, pc, imem, dmem, regFile, control, aluControl, imGen, alu, branch_unit`).
- Memórias (Harvard): IMEM 256 × 32 bits = 1 KiB, ROM combinacional por `$readmemh` → **LUTs**
  (119 LUTs de lógica); DMEM 256 × 32 bits = 1 KiB → **LUTRAM** (RAM256X1S × 32 = 128 LUTRAM), escrita síncrona e
  leitura assíncrona, sem conteúdo inicial. Os índices usam só `addr[9:2]` (o Vivado descarta `addr[31:10]`).
- Banco de registradores: 32 × 32 em **LUTRAM** (RAM32M, 2 portas de leitura assíncronas), `x0` forçado a 0 na leitura.
- Reset: síncrono, ativo alto, só no PC. Um único domínio de clock, todas as escritas na borda de subida.
- Periféricos: nenhum (sem MMIO/GPIO). O `core` expõe apenas `debug_pc` e `debug_result` (resultado da ALU).

## Montagem

- Top: `wrapper/top_cmp.sv` (o repositório não tem top de placa; o autor sintetizou o próprio `core`).
  Instancia `core` direto no `clk` de 100 MHz, `rst = ~CPU_RESETN`.
- LEDs: opção (c) das instruções — `led <= debug_result[15:0]` em registrador (16 FFs). O núcleo não tem
  MMIO e não expõe `write_mem`/`rs2_data`, então a opção (b) exigiria mudar o RTL do autor.
- `constr.xdc`: `base.xdc` sem as linhas de `switch` (o wrapper não usa chaves).
- Programa: `autoteste_placa` (`programa/prog_word.hex`), **truncado nas primeiras 256 das 389 instruções**
  (IMEM do autor = 256 palavras) → `mem/prog_256.hex`. A síntese otimiza a ROM para essas 256 palavras.
  O `.data` (68 B) **não** foi carregado: a `dmem.v` do autor não tem `$readmemh`/inicialização.
  O programa usa instruções de byte/halfword que este núcleo trata como palavra (não afeta a medição de área/timing).
- Mudanças no RTL do autor: só `patch/imem.v` — caminho do `$readmemh` trocado de
  `C:/Users/pc/Documents/RTL/programme.hex` para `prog_256.hex` (log: "read successfully"). Restante usado direto de `repo/rtl/`.
- Fora da medição: nada (o núcleo não tem periféricos). Testbenches e `constraints/timing.xdc` (50 MHz) não usados.

## Resultados (`-Final`, `build/final/resumo.txt`, 2026-11-25 09:54)

A primeira execução `-Final` (09:23, 172,3 s) foi **descartada**: rodou em paralelo com uma síntese órfã de
outro núcleo, fora da fila. Os números abaixo são só da segunda execução. (Timing e área saíram idênticos nas
duas; só o tempo de compilação mudou.)

| Métrica | Valor |
|---|---|
| Tempo total | **136,4 s** (synth 0:43, opt 0:07, place 0:39, route 0:35) |
| Pico de memória | 2063,7 MB |
| WNS / TNS | **−4,293 ns** / −1539,735 ns |
| Endpoints violando | 1139 / 1936 |
| WHS / THS | +0,335 ns / 0 |
| **Fmax** | **70,0 MHz** (1000 / (10 + 4,293)) |
| Caminho crítico | 13,953 ns (lógica 2,771 / rota 11,182), 14 níveis (LUT4=1 LUT5=2 LUT6=6 MUXF7=2 MUXF8=2 RAMS64E=1) |
| Origem → destino | `u_core/u_pc/pc_reg[5]/C` → `u_core/u_regfile/regs_reg_r2_0_31_30_31__0/DP/I` (PC → IMEM → regfile → ALU → DMEM → write-back) |
| LUTs | **1176** (lógica 1004, LUTRAM 172) |
| FFs | **48** (32 PC + 16 do registrador de LEDs do wrapper) |
| F7 / F8 / CARRY4 | 114 / 57 / 58 |
| Slices | 326 |
| BRAM / DSP / IOB | 0 / 0 / 18 |
| Potência | total **0,200 W**, dinâmica 0,102 W, estática 0,097 W, Tj 25,9 °C (confiança Medium) |
| Warnings / critical | 65 / 0 (portas `addr` não usadas em imem/dmem, TIMING-16/18) |
| Latches | 0 |

Hierarquia (`util_hier.rpt`): `u_regfile` 172 LUTs (44 LUTRAM), `u_dmem` 128 (128 LUTRAM), `u_imem` 119,
`u_pc` 756 — a ALU, decodificação, imediatos, comparador de desvio e muxes foram achatados pela síntese dentro de `u_pc`.
Nada foi podado indevidamente.

## Publicado pelo autor × medido aqui

| | Autor (XC7Z020-2, Vivado 2018.3, restrição 50 MHz) | Aqui (XC7A100T-1, Vivado 2025.2, 100 MHz) |
|---|---|---|
| LUTs | 557 (381 lógica + 176 LUTRAM) | 1176 (1004 + 172) |
| FFs | 32 | 48 (32 + 16 do wrapper) |
| BRAM | 0 | 0 |
| Caminho crítico | 12,081 ns (~82 MHz) | 13,953 ns (70,0 MHz) |

Por que diferem:
- **Programa na ROM:** o autor mediu com o seu programa de teste de 11 instruções (`sw/programme.hex`); a ROM de
  256 palavras quase vazia vira poucas LUTs. Aqui a IMEM tem 256 palavras reais do `autoteste_placa`
  (119 LUTs só na ROM) e, como a decodificação depende do conteúdo da ROM, muito mais lógica sobrevive
  (todos os opcodes/funct3 aparecem). É a principal causa das ~620 LUTs a mais.
- **Dispositivo e grau de velocidade:** Zynq -2 é mais rápido que Artix-7 -1; além disso, com o programa pequeno o
  caminho PC → ROM → regfile é bem mais curto. Restrição de 50 MHz (autor) × 100 MHz (aqui) também muda o esforço
  de place/route.
- **FFs:** os 16 a mais são o registrador de LEDs do wrapper.
- LUTRAM: 176 (síntese) → 172 após `opt_design` (4 LUTRAM do banco de registradores removidas).

## Observações para a comparação

- Monociclo de verdade (memórias combinacionais/assíncronas, CPI = 1).
- **Programa truncado** em 256 de 389 instruções; `.data` não carregado (DMEM sem inicialização).
- Núcleo **sem lanes de byte/halfword** (31/37 instruções), sem MMIO: área e caminho crítico menores que um RV32I
  completo com periféricos (não há mux/extensão de sinal na leitura da DMEM nem decodificação de endereço de I/O).
- IMEM e DMEM de 1 KiB cada (o TCC tem IMEM 4 KiB + DMEM 1 KiB): IMEM 4× menor.
- LEDs pela opção (c) (`debug_result`), não por escrita na memória.
- Caminho crítico dominado por roteamento (11,2 de 14,0 ns).
