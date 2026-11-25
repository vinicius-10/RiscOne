# Diferenças — Asghar (01) × núcleo do TCC

Arquivos citados: `repo/Source Code/Modules/*.sv` (sem `patch/`). Só leitura de código.

## 1. Conjunto de instruções
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| RV32I corretas (pela leitura) | 35 de 37 | 37 (verificadas em testbench) |
| Faltam / erradas | **SLLI**: o `case (funct3)` do I-type não tem `3'b001` (`control_unit.sv:57-65`) → `alu_op = 1111`, ALU dá 0 e escreve 0 em rd. **LUI**: não liga `a_sel` nem zera o operando A (`control_unit.sv:107`; `top.sv:70`) → rd = x[bits 19:15] + imm em vez de imm | nenhuma |
| FENCE / ECALL / EBREAK | não decodificados → `default` sem escrita (efeito de NOP) | NOP |
| Instruções extras além das 40 | nenhuma | nenhuma |
| Codificação inválida | **não é NOP**: R/I-type com funct inválido escrevem 0 em rd (`control_unit.sv:50,65`); load com funct3 inválido escreve 0 (`data_mem.sv:57`); branch 010/011 e store inválido viram NOP | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps | não | não |
| CSRs | nenhum | nenhum |
| Desvio/acesso desalinhado | ignorado; JALR zera o bit 0 (`top.sv:99`); load/store desalinhado usa só os bits baixos | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard | Harvard |
| IMEM | 1 KiB (256 palavras; comentário diz "2KB"), ROM combinacional **não registrada** (`inst_mem.sv`) | 4 KiB ROM em LUTs; palavra registrada no `search` |
| IMEM: carregamento | `$readmemh("instructions.mem")` em `initial` | `$readmemh` em `initial` |
| DMEM | 1 KiB (256 palavras), leitura combinacional, escrita na subida | 1 KiB LUTRAM, idem |
| DMEM: `.data` inicial | `$readmemh("data_mem.mem")` em `initial` | `$readmemh` em `initial` |
| Byte/halfword, sinal, byte enables | completos (LB/LH/LBU/LHU/SB/SH/SW) | completos |
| Onde a síntese colocou | IMEM em LUTs (121), DMEM em LUTRAM (128), banco em LUTRAM (44) | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos | **nenhum**; índice `addr[31:2]` sem decodificar região (`data_mem.sv:19`) → só `addr[9:2]` conta, qualquer endereço faz alias na RAM | `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |

## 4. Reset
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Tipo, polaridade | síncrono, ativo alto (`program_counter.sv`) | síncrono, ativo alto |
| O que zera | só o PC; banco iniciado por `$readmemh("reg_init.mem")` (xi = i), não resetado | só o PC |
| Efeito na síntese | nenhum | nenhum |

## 5. Microarquitetura e caminho crítico
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI | 1 | 1 |
| Registradores além do PC | nenhum | instrução registrada |
| Bordas de clock | só subida | só subida |
| Decisão de desvio | comparador dedicado `branch_comp` (rs1×rs2), resultado entra na `control_unit` que gera `pc_src` | comparador dedicado, fora da ALU |
| Alvo de desvio / PC+4 | somadores dedicados `pc+imm`, `pc+4` e `rs1+imm` (JALR) (`top.sv:99,104`) | somadores dedicados |
| Endereço da DMEM | **saída da ALU** (`alu_result_out`) — sem somador dedicado | somador dedicado rs1+imm, flags de região sem esperar o carry |
| ALU | add, sub, sll, slt, sltu, xor, srl, sra, or, and; SLT/SLTU por comparadores `<` (`alu_logic.sv`) | add/sub, shifter, SLT/SLTU pelo carry |
| Mux write-back / próximo PC | write-back: 3 (ALU / memória / PC+4) (`top.sv:92`); próximo PC: 3 (PC+4 / PC+imm / JALR) + reset no registrador | 2; reset / PC+4 / alvo |
| Banco de registradores | 32×32 LUTRAM, leitura assíncrona, x0 por mux | 32×32 LUTRAM, x0 por mux |
| Caminho crítico medido | `pc_out_reg[7]` → banco (`reg_file_reg_r1_0_31_30_31`), 17 níveis, 14,83 ns (lógica 3,86 / rota 10,97): PC → ROM (LUT6+MUXF7/F8) → leitura do banco → ALU → DMEM LUTRAM → mux de load → write-back | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, módulos, linhas | SystemVerilog, 9 módulos, ~490 linhas | SystemVerilog |
| Testbench / riscv-tests | testbenches por módulo e de top (inspeção de forma de onda), sem riscv-tests | autoverificáveis + autoteste em C |
| Erros encontrados | SLLI e LUI errados; funct inválido escreve 0 em rd; sem decodificação de região na DMEM | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

O Asghar ficou em 66,0 MHz (14,83 ns, 17 níveis), contra 97,8 MHz do TCC. A diferença vem de dois pontos da
seção 5. Primeiro, a instrução não é registrada: a leitura da ROM (LUT6 + MUXF7/F8) fica em série com o resto
do ciclo, enquanto no TCC a busca começa num registrador. Segundo, o endereço da DMEM sai da própria ALU
(depois dos muxes de operando e do `case` de 10 operações), não de um somador dedicado `rs1+imm`. Assim, um
load atravessa ROM → banco → ALU → LUTRAM → mux de byte/sinal → mux de write-back de 3 entradas → banco. Quase
3/4 do atraso é roteamento (10,97 ns), sinal de um caminho longo e espalhado. Na área, os 1374 LUTs ficam
perto dos 1266 do TCC, mesmo com metade dos FFs (48 contra 98), IMEM de 1/4 do tamanho (programa truncado em 256
instruções) e sem MMIO. A ALU com comparadores `<` próprios e o shifter genérico, mais os somadores
extras do próximo PC, compensam essa economia. Todos estão achatados em `pc_inst` (979 LUTs).
