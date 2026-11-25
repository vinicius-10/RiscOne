# 02 — Zongo (rv32i-core) × TCC: diferenças pelo código

Arquivos citados em `repo/rtl/` (commit `fbd1fb6`). Números de `build/final/resumo.txt`.

## 1. Conjunto de instruções

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente | 31 (o autor declara o mesmo) | 37 (verificadas em testbench) |
| Faltam / viram NOP / erradas | LB, LH, LBU, LHU, SB, SH executam como LW/SW: `control.v` decodifica só o opcode (`control.v:54`, `:61`), a DMEM só tem acesso de palavra (`dmem.v:29`, `:32`). SB/SH sobrescrevem a palavra inteira e LB/LH não fazem extensão de sinal | nenhuma |
| FENCE / ECALL / EBREAK | NOP (caem no `default` de `control.v:102`) | NOP |
| Instruções extras além das 40 | nenhuma | nenhuma |
| Codificação inválida | **não é estrita:** só opcode desconhecido vira NOP. funct7 inválido em R/I-shift executa (só `inst[30]` é olhado, `aluControl.v:35`, `:40`); funct3 de JALR, loads e stores é ignorado; branch com funct3 010/011 = não desvia | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps | não | não |
| CSRs | nenhum | nenhum |
| Desvio/acesso desalinhado | ignorado, sem trap; JAL/JALR zeram o bit 0 (`core.v:187`); acesso à DMEM usa `addr[31:2]` (os bits baixos são descartados) | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard | Harvard |
| IMEM: tamanho, tipo, leitura | 1 KiB (256 × 32, `imem.v:27`), ROM em LUTs, combinacional e **sem registrador** (`imem.v:40`) | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento | `$readmemh` em `initial` (caminho absoluto do autor; trocado em `patch/imem.v`) | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | 1 KiB (256 × 32) LUTRAM; leitura combinacional, escrita na subida | 1 KiB LUTRAM; leitura combinacional, escrita na subida |
| DMEM: carga do `.data` | nenhuma (`dmem.v` não tem `initial`) | `$readmemh` em `initial` |
| Byte/halfword, extensão de sinal, byte enables | não (só palavra) | completos |
| Onde a síntese colocou | IMEM: 119 LUTs; DMEM: 128 LUTRAM (RAM256X1S × 32); banco: 44 LUTRAM | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos | nenhum; só as portas `debug_pc`/`debug_result` | sim: `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |
| Endereçamento | índice `addr[31:2]` sem decodificação de faixa: endereços ≥ 1 KiB fazem alias (a síntese usa só `addr[9:2]`) | região RAM / MMIO decodificada |

## 4. Reset

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Síncrono/assíncrono, polaridade | síncrono, ativo alto (`pc.v`); o wrapper inverte `CPU_RESETN` | síncrono, ativo alto |
| O que zera | só o PC | só o PC (a instrução registrada volta à do endereço 0) |
| Efeito na síntese | nenhum | nenhum |

## 5. Microarquitetura e caminho crítico

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato | 1 | 1 |
| Registradores além do PC | nenhum (no wrapper, só os 16 FFs dos LEDs) | instrução registrada |
| Bordas de clock | só subida | só subida |
| Decisão de desvio | `branch_unit` dedicado rs1×rs2, fora da ALU | comparador dedicado rs1×rs2, fora da ALU |
| Alvo de desvio / PC+4 | somadores dedicados (`core.v:67-68`); o alvo de JAL/JALR sai da **ALU** (`core.v:187`) | somadores dedicados |
| Endereço da DMEM | **resultado da ALU** (`core.v:156`): o mux de 10 operações fica em série no endereço | somador dedicado rs1+imm; flags de região sem esperar o carry |
| ALU | 10 operações (add, sub, and, or, xor, sll, srl, sra, slt, sltu), comparações com `<` | add/sub, shifter, SLT/SLTU pelo carry |
| Mux write-back / próximo PC | write-back: 3 entradas (ALU / memória / PC+4, `core.v:175`); próximo PC: reset / ALU (jump) / PC+imm / PC+4 | write-back 2 entradas; próximo PC: reset / PC+4 / alvo |
| Banco de registradores | 32×32 LUTRAM (RAM32M), leitura assíncrona, x0 por mux (`regFile.v:31-32`) | 32×32 LUTRAM, leitura assíncrona, x0 por mux |
| Caminho crítico medido | `pc_reg[5]` → banco (`regs_reg_r2_..._30_31`), 14 níveis, 13,95 ns (lógica 2,77 / rota 11,18): PC → ROM (MUXF7/F8) → leitura do banco → ALU → endereço da DMEM (RAMS64E) → mux de write-back → escrita no banco | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, módulos, linhas | Verilog-2001, 10 módulos, 622 linhas em `rtl/` (com os cabeçalhos do Vivado) | SystemVerilog |
| Testbench / riscv-tests | 10 testbenches autoverificáveis (154 vetores, segundo o README) + programa de soma de 11 instruções; sem riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | (1) LB/LH/LBU/LHU/SB/SH tratadas como palavra (declarado pelo autor); (2) decodificação não estrita de funct3/funct7 (seção 1); (3) DMEM e IMEM sem checagem de faixa (alias acima de 1 KiB) | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

O Zongo mediu 13,95 ns / 70,0 MHz contra 10,18 ns do TCC. O motivo principal é não registrar a instrução. O caminho
do Zongo começa no PC e atravessa a leitura da ROM, com 2 MUXF7 e 2 MUXF8. Depois passam pela leitura do banco,
pela ALU completa (que também gera o endereço da DMEM), pela leitura da LUTRAM da DMEM e pelo mux de write-back de 3 entradas,
até chegar à escrita no banco. São 14 níveis, e 11,2 ns são de rota. No TCC, a instrução registrada tira a ROM do
caminho e o endereço da DMEM sai de um somador dedicado, sem passar pelo mux da ALU. A área do Zongo é menor:
1176 LUTs e 48 FFs, contra 1266 LUTs e 98 FFs do TCC. As razões são a falta de lanes de byte/halfword (sem byte
enables nem extensão de sinal), a falta de MMIO, a decodificação não estrita e a ROM 4× menor (119 LUTs, com o programa
truncado em 256 das 389 instruções). Os 32 FFs a menos vêm de não registrar a instrução. Do outro lado, o Zongo tem
custos que o TCC não tem: o comparador de desvio e a ALU calculam `<` separadamente, e a ALU tem um mux de 10
operações. Esses custos não compensam o que falta, então a comparação de área favorece o Zongo por ele cobrir menos
da ISA, não por ser mais eficiente.
