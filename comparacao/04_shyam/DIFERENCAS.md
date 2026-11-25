# Diferenças × núcleo do TCC — 04 Shyam Sundhar (RISC-V-Single-Cycle-Processor)

Caminhos relativos a `repo/Design_Sources/`. Só leitura de código; números de `build/final/resumo.txt`.

## 1. Conjunto de instruções
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente (pela leitura) | 25 (10 R, 9 I-ALU, LW, SW, BEQ, BNE, JAL, LUI) | 37 (verificadas em testbench) |
| Lista das que faltam / viram NOP / estão erradas (com o motivo) | **BLT/BGE/BLTU/BGEU** nunca desviam: `pcsrc` só para funct3 000/001 (`controlunit.v:29-31`). **JALR**: alvo = `pc + imm` (`pc_target.v:5`; o caso 28 da ALU em `alu.v:49` nunca é selecionado). **AUIPC**: ALU faz `rd1 + imm` (`alu.v:55`, operando A é sempre `rd1`, `processor.v:27`). **LB/LH/LBU/LHU** = LW e **SB/SH** escrevem a palavra inteira (`data_memory.v:17,20`, sem funct3) | nenhuma |
| FENCE / ECALL / EBREAK | NOP (opcode cai no `default` de `main_decoder.v`, `regwrite=0`) | NOP |
| **Instruções extras além das 40** | nenhuma | nenhuma |
| Codificação inválida (funct3/funct7 inexistente) | **não é NOP**: `case` sem `default` em `alu_decoder.v:16` → latch mantém a operação anterior e `regwrite=1` grava o resultado | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps (instrução ilegal, ECALL, desalinhamento) | não | não |
| CSRs (quais) | nenhum | nenhum |
| Desvio/acesso desalinhado | ignorado; JALR nem zera o bit 0 (alvo vem de `pc_target`); DMEM ignora `addr[1:0]` | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard | Harvard (IMEM e DMEM separadas) |
| IMEM: tamanho, tipo, leitura | 512 B (128 palavras) ROM, combinacional, sem registrar a instrução | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento do programa | `$readmemh("program.mem")` em `initial` | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | 512 B (128 palavras); leitura combinacional, escrita na subida | 1 KiB LUTRAM; leitura combinacional, escrita na subida do clock |
| DMEM: carga do `.data` inicial | não há; `initial` zera tudo (programa medido sem `.data`) | `$readmemh` em `initial` (vai no bitstream) |
| Byte/halfword, extensão de sinal, byte enables | **não**: só palavra, sem byte enables | completos (LB/LH/LBU/LHU/SB/SH) |
| Onde a síntese colocou cada memória | ROM em LUTs (dentro de `pcflop`, 1678 LUTs), DMEM em LUTRAM (32 × RAM128X1S = 64 LUTs) | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos e mapa | não há MMIO; o top original lê `x1` por referência hierárquica (`processor.v:22`) para o display | sim: `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |

## 4. Reset
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Síncrono/assíncrono, polaridade | **assíncrono**, ativo alto (`pc_flop.v:6`) | síncrono, ativo alto (`CPU_RESETN` invertido no top) |
| O que o reset zera | só o PC (banco e DMEM zerados só por `initial`) | só o PC (a instrução registrada volta à do endereço 0) |
| Efeito na síntese (impede LUTRAM/BRAM?) | nenhum (o banco em FFs vem do próprio `reg_file`, ver §5) | nenhum |

## 5. Microarquitetura e caminho crítico
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato (busca, load, store) | 1 | 1 |
| Registradores no caminho além do PC | nenhum | instrução registrada (tira a leitura da ROM do caminho) |
| Bordas de clock usadas | só subida | só subida |
| Decisão de desvio | pela ALU: `zero = (aluresult == 0)` após `a - b`, só BEQ/BNE | comparador dedicado rs1×rs2, fora da ALU |
| Alvo de desvio / PC+4 | somadores dedicados (`pc_target`, `pc_plus4`) | somadores dedicados |
| Endereço da DMEM | saída da ALU (`processor.v:28`), sem somador dedicado | somador dedicado rs1+imm; flags de região sem esperar o carry |
| ALU (operações, shifter, SLT/SLTU) | `case` de 31 códigos de 6 bits com operações duplicadas (add em 0/10/25/26/30, etc.), shifter, SLT/SLTU por `<`; decodificador com 5 latches | add/sub, shifter, SLT/SLTU pelo carry |
| Mux de write-back / mux do próximo PC | write-back: 4 entradas (ALU / memória / PC+4 / imediato); próximo PC: 2 (PC+4 / alvo) | write-back: 2 entradas (ALU × memória); próximo PC: reset / PC+4 / alvo |
| Banco de registradores | 32×32 **em FFs** (1024 FFs + 512 LUTs), 3 portas de leitura (rs1, rs2, x1), x0 por mux | 32×32 LUTRAM, leitura assíncrona, x0 por mux |
| Caminho crítico medido | `pc_reg[4]` → `pc_reg[30]`, 28 níveis (14 CARRY4), 14,589 ns: PC → ROM → banco/imediato → ALU (`a - b`) → `zero` → `pcsrc` → somador do alvo → PC | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, nº de módulos, linhas de RTL | Verilog, 16 módulos de núcleo, ~540 linhas (sem divisor/display) | SystemVerilog |
| Testbench próprio / riscv-tests | 1 testbench (`Simulation_File/tb_topmodule.v`) que checa só a sequência de Fibonacci (10 valores); sem riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | desvios BLT/BGE/BLTU/BGEU, JALR, AUIPC, loads/stores parciais (§1); latch em `alu_decoder.v` (`case` sem `default`); referência hierárquica `processor.v:22` | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

O caminho crítico (14,589 ns, 28 níveis, 68,6 MHz × 97,8 MHz do TCC) sai do PC e volta ao PC passando
por tudo em série: leitura da ROM de 128 palavras (sem a instrução registrada que o TCC usa), leitura do
banco em FFs (mux de 32:1 em LUT6/MUXF7/MUXF8), mux do operando B, subtração na ALU, detecção de
`zero` sobre os 32 bits do resultado, `pcsrc` e só então o somador do alvo e o mux do PC. O TCC
tira a ROM do caminho registrando a instrução e decide o desvio num comparador dedicado em paralelo
com a ALU, então nem a ALU nem o detector de zero ficam em série com o próximo PC. Na área
(2454 LUTs / 1077 FFs × 1266 / 98 do TCC), pesam o banco de registradores em FFs (1024 FFs + 512 LUTs
de mux, contra LUTRAM no TCC), a ROM e a decodificação espalhadas por 1678 LUTs, a ALU com
operações duplicadas selecionadas por um código de 6 bits e o mux de write-back de 4 entradas. Mesmo
com IMEM/DMEM menores (512 B cada) e sem byte/halfword, o núcleo é maior e mais lento.
