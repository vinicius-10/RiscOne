# Diferenças — basic_rv32s RV32I37F (commit 672fe02) × TCC

Arquivos citados: `repo/RV32I/modules/` (sem prefixo); patches em `patch/modules/`.

## 1. Conjunto de instruções
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão corretas (leitura) | 32 de 37: LB/LH/LBU/LHU sem deslocamento e SLL/SRL/SRA (reg) erram em casos que o `autoteste_placa` usa | 37 (verificadas em testbench) |
| Faltam / NOP / erradas | **LB, LBU, LH, LHU**: leem sempre o byte/meia palavra baixo da palavra, ignoram `addr[1:0]` (Byte_Enable_Logic.v:23-37). **SLL/SRL/SRA**: deslocam por `rs2` inteiro, não `rs2[4:0]` (ALU.v:43,47,51; src_B = read_data2 em RV32I37F.v) → resultado 0 se rs2 ≥ 32. SW/SH desalinhados: máscara 0, não escrevem (Byte_Enable_Logic.v) | nenhuma |
| FENCE / ECALL / EBREAK | NOP (Control_Unit.v:232, 254-270: funct3=0 sem escrita) | NOP |
| Instruções extras além das 40 | nenhuma de fato. Os opcodes Zicsr (CSRRW…CSRRCI) são decodificados (Control_Unit.v:271-290, ALU_Controller.v:127-150), mas sem banco de CSR: `RF_WD_CSR` cai no `default` do mux de write-back → **escrevem 0 em rd** (RV32I37F.v, `case (register_file_write_data_select)`) | nenhuma |
| Codificação inválida | **não é NOP**: Control_Unit e Instruction_Decoder não têm `default` nem valores iniciais (Control_Unit.v:27-297, Instruction_Decoder.v:18-78) → latches mantêm os sinais da instrução anterior (pode repetir store/escrita). funct7 não é conferido (ex.: funct7≠0 em ADD vira ADD). Branch com funct3 010/011: `alu_op` em latch, `branch_taken`=0 | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps | não (`trapped`=0, `trap_target`=0 no top; saída `misaligned` da Byte_Enable_Logic desconectada) | não |
| CSRs | nenhum (ver item 1: instruções CSR escrevem 0) | nenhum |
| Desvio/acesso desalinhado | ignorado; o PC_Aligner zera os bits [1:0] de todo próximo PC (PC_Aligner.v) | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard | Harvard (IMEM e DMEM separadas) |
| IMEM | 1024×32 (4 KiB) ROM, leitura combinacional por `pc[31:2]`, sem registro | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento | original: atribuições `data[i] = …` no `initial`; patch: `$readmemh` | `$readmemh` em `initial` |
| DMEM | 1024×32 (4 KiB); leitura combinacional, escrita na subida com máscara (read-modify-write); endereço = `alu_result[11:2]`, sem decodificação (todo o espaço aliasa) | 1 KiB LUTRAM; leitura combinacional, escrita na subida |
| DMEM: `.data` inicial | original: zerada no `initial`; patch: `$readmemh` dos 68 B | `$readmemh` em `initial` |
| Byte/halfword | stores completos (SB/SH com máscara); **loads sem alinhamento** (ver item 1) | completos |
| Onde a síntese colocou | IMEM em LUTs (224), DMEM em LUTRAM (512 LUTRAM + 79 LUTs), banco em LUTRAM (44) | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos | nenhum | `0x4000_0000`, 4 saídas + 4 entradas |

## 4. Reset
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Tipo | assíncrono, ativo alto (Program_Counter.v:8) | síncrono, ativo alto |
| O que zera | só o PC | só o PC |
| Efeito na síntese | nenhum sobre memórias; reset assíncrono vindo direto do pino | nenhum |

## 5. Microarquitetura e caminho crítico
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI | 1 (busca, load e store) | 1 |
| Registradores além do PC | nenhum (só PC; mas há 58 latches transparentes no decodificador/controle) | instrução registrada |
| Bordas de clock | só subida | só subida |
| Decisão de desvio | pela ALU (SUB/SLT/SLTU) + `alu_zero` = resultado==0 (ALU.v:71, Branch_Logic.v) — em série com a ALU | comparador dedicado |
| Alvo de desvio / PC+4 | branch: somador `pc+imm` no PC_Controller; JAL/JALR: pela ALU; PC+4 dedicado | somadores dedicados |
| Endereço da DMEM | pela ALU (`alu_result`) | somador dedicado rs1+imm |
| ALU | 13 operações em um `case` (add, sub, and, or, xor, SLT/SLTU por comparação, 3 shifts de 32 bits, ABJ e BPA para CSR) | add/sub, shifter, SLT/SLTU pelo carry |
| Mux write-back / próximo PC | WB: 4 entradas + 0 (load, ALU, LUI=imm, PC+4); próximo PC: jump / branch / trap / PC+4 / stall + alinhador | WB 2 entradas; PC 3 |
| Banco de registradores | 32×32 LUTRAM, leitura assíncrona, x0 por mux | 32×32 LUTRAM, x0 por mux |
| Caminho crítico | `pc_reg[4]` → LUTRAM do banco (`registers_reg_r1_0_31_30_31`), 17 níveis (11 LUT6, 3 MUXF7, 1 MUXF8), 15,65 ns (rota 12,18). PC → ROM (MUXF7/F8) → decodificador/controle (latches) → leitura do banco → ALU → DMEM (LUTRAM) → byte enable → mux WB → escrita no banco | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, módulos, linhas | Verilog 2001, 15 módulos + top, ~1280 linhas (inclui o programa embutido na IMEM) | SystemVerilog |
| Verificação | testbench por módulo e `RV32I37F_tb.v` (Icarus, inspeção de waveform); sem riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados | loads sem alinhamento; shifts R por rs2 inteiro; latches por falta de `default` (Control_Unit, Instruction_Decoder, ALU_Controller) → opcode inválido repete a instrução anterior; CSR escreve 0 em rd; HEAD do repositório não elabora o 37F (módulos mudaram de portas) | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

O 37F tem 62,7 MHz (15,65 ns) contra 97,8 MHz (10,18 ns) do TCC. A causa principal é que não há
instrução registrada: o caminho começa no PC e passa por toda a ROM (árvore MUXF7/F8), pelo
decodificador e pela unidade de controle (latches transparentes no caminho), pela ALU (que também
calcula o endereço da DMEM e decide o desvio), pela leitura da DMEM e pelo mux de write-back até a
escrita no banco. São 17 níveis e 12 ns só de rota. No TCC, a ROM sai do caminho, e somadores e
comparador dedicados tiram o endereço da DMEM e o desvio de dentro da ALU. A área também é maior: 1984
contra 1266 LUTs. A DMEM é 4× maior (512 LUTRAM contra cerca de 128). A unidade de controle (655 LUTs)
e o ALU_Controller (201) incham por causa dos latches e da decodificação dos CSRs. Os 3 shifters de 32
bits por um operando completo e o PC_Controller, com o somador `pc+imm` e o mux de 5 vias (158 LUTs no
program_counter), também somam. A ROM de 4 KiB tem o mesmo tamanho da do TCC.
