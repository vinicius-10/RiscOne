# Diferenças × núcleo do TCC — 06 HarieshAnbalagan / RV32I (single_cycle_processor)

Arquivos citados: `repo/src/single_cycle_processor/*.sv`, salvo indicação. Números de `build/final/resumo.txt`.

## 1. Conjunto de instruções

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente (pela leitura) | **29**: as 10 R, as 9 I-ALU, os 6 desvios, JAL, JALR (sem zerar o bit 0), LUI e AUIPC. As 8 de memória não seguem o RV32I (ver a linha abaixo) | 37 (verificadas em testbench) |
| Lista das que faltam / viram NOP / estão erradas (com o motivo) | **LW/SW**: a DMEM usa o endereço de byte direto como índice de palavra (`DataMemory.sv:29,36`), então `lw x,4(x0)` lê a palavra 4 e não a 1. Só funcionam com endereços "em palavras" e com módulo 64. **LB/LH/LBU/LHU**: só estendem o byte/halfword baixo da palavra, sem deslocar por `addr[1:0]` (`LoadStoreUnit.sv:27`). **SB/SH**: o strobe é gerado (`LoadStoreUnit.sv:42`), mas a DMEM o ignora e grava a palavra inteira com zeros nos outros bytes (`DataMemory.sv:36`). **JALR**: não zera o bit 0 do alvo (`ProcessorCore.sv:64`) | nenhuma |
| FENCE / ECALL / EBREAK | NOP (sem escrita e PC+4) | NOP |
| **Instruções extras além das 40** | nenhuma | nenhuma |
| Codificação inválida (funct3/funct7 inexistente) | **Não é estrita.** No tipo R só o bit 30 do funct7 é examinado (`CoreControlUnit.sv:54`), então p. ex. MUL (funct7 = 0000001) vira ADD. Combinações R inválidas caem no `default` com `reg_write_enable = 1` e escrevem 0 em rd. Load com funct3 inválido vira LW. Store com funct3 inválido não tem `default` (`unique case`, valor indefinido). Desvio com funct3 inválido não desvia. Opcode inválido vira NOP | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps (instrução ilegal, ECALL, desalinhamento) | não | não |
| CSRs (quais) | nenhum | nenhum |
| Desvio/acesso desalinhado | ignorado, sem trap. O JALR nem zera o bit 0 | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard (IMEM e DMEM separadas, fora do `ProcessorCore`) | Harvard (IMEM e DMEM separadas) |
| IMEM: tamanho, tipo, leitura | **64 palavras (256 B)**, ROM combinacional indexada por `PC[31:2]`. **A instrução não é registrada** | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento do programa | `$readmemh("L_S_type.txt")` em `initial`. O programa medido foi truncado em 64 instruções | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | **64 palavras (256 B)**, indexada pelo endereço de byte; leitura combinacional, escrita na subida do clock | 1 KiB LUTRAM; leitura combinacional, escrita na subida do clock |
| DMEM: carga do `.data` inicial | `$readmemh("Data_Memory_Load.txt")` em `initial` | `$readmemh` em `initial` (vai no bitstream) |
| Byte/halfword, extensão de sinal, byte enables | Simplificados ou errados: a extensão de sinal existe, mas sem deslocar por `addr[1:0]`, e o byte enable é ignorado | completos (LB/LH/LBU/LHU/SB/SH) |
| Onde a síntese colocou cada memória | ROM em LUTs (dentro das 791 LUTs de lógica); DMEM em 32 LUTRAM (RAMS64E); banco em 44 LUTRAM (RAMD32) | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos e mapa | nenhum | sim: `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |

## 4. Reset

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Síncrono/assíncrono, polaridade | **assíncrono**, ativo alto (`posedge reset_i`); o wrapper inverte `CPU_RESETN` | síncrono, ativo alto (`CPU_RESETN` invertido no top) |
| O que o reset zera (PC, banco, DMEM, MMIO, outros) | só o PC | só o PC (a instrução registrada volta à do endereço 0) |
| Efeito na síntese (impede LUTRAM/BRAM?) | nenhum (PC em FDCE; banco e DMEM continuam em LUTRAM) | nenhum |

## 5. Microarquitetura e caminho crítico

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato (busca, load, store) | 1 | 1 |
| Registradores no caminho além do PC | nenhum: a leitura da ROM está dentro do ciclo | instrução registrada (tira a leitura da ROM do caminho) |
| Bordas de clock usadas | **subida** (PC, DMEM) e **descida** (escrita do banco, `RegisterFile.sv:33`) | só subida |
| Decisão de desvio | `ComparatorUnit` dedicado, rs1 × (rs2 ou imm), fora da ALU. Ele também calcula SLT/SLTU/SLTI/SLTIU | comparador dedicado rs1×rs2, fora da ALU |
| Alvo de desvio / PC+4 | **o alvo sai da ALU** (PC+imm, e rs1+imm no JALR); PC+4 tem somador dedicado | somadores dedicados |
| Endereço da DMEM | **saída da ALU** (`ProcessorCore.sv:149`), sem somador dedicado | somador dedicado rs1+imm; flags de região sem esperar o carry |
| ALU (operações, shifter, SLT/SLTU) | add, sub (dois somadores separados), and/or/xor e 3 shifters (`<<`, `>>`, `>>>`). SLT/SLTU ficam no comparador (`<` com e sem sinal) | add/sub, shifter, SLT/SLTU pelo carry |
| Mux de write-back / mux do próximo PC (nº de entradas) | write-back: **5 entradas** (DMEM, ALU, comparador, imediato, PC+4), mais um `default` com `'z` (`ProcessorCore.sv:162`); próximo PC: 2 entradas (ALU × PC+4), com o reset assíncrono no registrador | write-back: 2 entradas (ALU × memória); próximo PC: reset / PC+4 / alvo |
| Banco de registradores | 32×32 LUTRAM, leitura assíncrona, x0 por mux; **escrita na borda de descida** | 32×32 LUTRAM, leitura assíncrona, x0 por mux |
| Caminho crítico medido e por que é esse | `PC_reg[4]` (subida) → `regfile/register_reg_r2…/RAMC/I` (**descida**), 12 níveis (LUT2/4/5/6, RAMD32, RAMS64E), 12,23 ns (lógica 2,20 / rota 10,03) contra um **requisito de 5 ns**. WNS -7,721 ns. **Fmax real ≈ 39,3 MHz** (o script dá 56,4 MHz porque supõe ciclo inteiro). É o caminho do load: PC → ROM → banco (RAMD32) → ALU (rs1+imm) → DMEM (RAMS64E) → LSU → mux de write-back → escrita no banco, em meio período | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, nº de módulos, linhas de RTL | SystemVerilog; 9 módulos + 1 pacote (10 arquivos), 896 linhas com comentários | SystemVerilog |
| Testbench próprio / riscv-tests | `tb/` tem testes em assembly, `top.sv` e scripts Python (modelo de referência, regressão aleatória e diferencial). O `top.sv` usa portas do multiciclo (`retire_*`, `PC_if`) e não serve para o monociclo. Sem riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | (1) `.branch_o` em vez de `.comp_o` na instância do comparador (`ProcessorCore.sv:133`): não elabora. (2) `assign` procedural dentro de `always_comb` (`InstructionMemory.sv:27`, `DataMemory.sv:29`, `RegisterFile.sv:29-30`): o Vivado recusa. (3) DMEM indexada pelo endereço de byte. (4) Byte enable ignorado e LSU sem deslocamento por `addr[1:0]`. (5) JALR sem zerar o bit 0. (6) Decodificação R não estrita e escrita de 0 em rd para R inválida. (7) Case de store sem `default`. (8) `'z` interno no mux de write-back | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

**Caminho crítico (39,3 MHz contra 97,8 MHz):**
- O pior caminho é de meio ciclo. Com a escrita do banco na borda de descida, todo o caminho do load, de PC → ROM → banco → ALU → DMEM → LSU → write-back até a escrita no banco, precisa caber em 5 ns.
- Além disso, a leitura da ROM continua dentro do ciclo, porque não há instrução registrada.
- O endereço da DMEM sai do somador da ALU, depois do mux de operandos e do mux de operação, e não de um somador dedicado.
- O mux de write-back tem 5 entradas, contra 2 no TCC.
- O caminho tem 12 níveis, como o do TCC, mas 10 ns de rota, e precisa caber em metade do período. Por isso o atraso equivalente de ciclo inteiro fica em ≈ 25,4 ns.

**Área (867 LUTs e 48 FFs, contra 1266 LUTs e 98 FFs):**
- A ROM é 16× menor (64 palavras contra 1024) e a DMEM é 4× menor (256 B contra 1 KiB).
- Não há MMIO.
- Não há alinhamento de bytes nem byte enables reais.
- Não há somadores dedicados para o alvo de desvio e para o endereço da DMEM.
- Não há instrução registrada: são 32 FFs a menos (as 48 FFs são o PC e os 16 LEDs do wrapper).
- O programa medido foi truncado em 64 instruções.

A área menor vem, portanto, de memórias e funcionalidades menores, e não de uma organização mais eficiente.
