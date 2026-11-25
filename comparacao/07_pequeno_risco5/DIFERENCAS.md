# Diferenças × núcleo do TCC — Pequeno-Risco-5 (JN513)

Análise feita só pela leitura do código (`repo/src/`, `patch/instruction_memory.v`). Os caminhos são relativos a `repo/src/`.

## 1. Conjunto de instruções

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente | **13** corretas: ADD, SUB, AND, OR, XOR, SLTU, ADDI, ANDI, ORI, XORI, SLTIU, SLLI, SRLI. Mais **8 parciais**: SLL, SRL, BEQ, BNE, BLTU, BGEU, LW, SW. | 37 (verificadas em testbench) |
| Lista das que faltam / viram NOP / estão erradas | **Ausentes:** JAL, JALR, LUI, AUIPC. A `Control_Unit` não tem `case` nem `default` para elas, então os latches repetem os sinais da instrução anterior (control_unit.v:12-63).<br>**Erradas:** SLT, SLTI, BLT e BGE comparam sem sinal (alu.v:25/37, operandos `wire` sem `signed`). SRA e SRAI viram deslocamento lógico (alu_control.v:30-34 e 79).<br>**Viram outra instrução:** LB, LH, LBU e LHU viram LW; SB e SH viram SW (funct3 ignorado).<br>**Parciais:** SLL e SRL deslocam pelos 32 bits de rs2, não por rs2[4:0] (alu.v:29/31). Os desvios só funcionam para a frente, porque o alvo usa `imm >> 1` lógico (core.v:23). LW e SW usam o resultado da ALU direto como índice de palavra, sem converter o endereço de byte (data_memory.v:18/32). | nenhuma |
| FENCE / ECALL / EBREAK | Não decodificados: os latches da `Control_Unit` repetem a instrução anterior, inclusive `reg_write`. Não são NOP. | NOP |
| Instruções extras além das 40 | nenhuma | nenhuma |
| Codificação inválida | **Opcode inválido:** repete os sinais de controle anteriores (latch). **funct inválido em R:** vira ADD (alu_control.v `default`). | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps | não | não |
| CSRs | nenhum (o imediato do opcode 1110011 existe, mas não é usado) | nenhum |
| Desvio/acesso desalinhado | Não se aplica: o PC e a DMEM são endereçados por palavra (PC+1, pc.v:24). | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard | Harvard (IMEM e DMEM separadas) |
| IMEM: tamanho, tipo, leitura | 1 KiB (256 palavras), ROM combinacional indexada pelo PC (em palavras). A saída não é registrada. | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento do programa | `$readmemh` em `initial`. O original carrega só as palavras 0–14; o patch carrega tudo. | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | 4 KiB (1024 × 32 bits); leitura combinacional, escrita na subida do clock, só palavra | 1 KiB LUTRAM; leitura combinacional, escrita na subida do clock |
| DMEM: carga do `.data` inicial | Nenhuma: o `initial` zera a RAM (data_memory.v:21-25). | `$readmemh` em `initial` (vai no bitstream) |
| Byte/halfword, extensão de sinal, byte enables | não | completos (LB/LH/LBU/LHU/SB/SH) |
| Onde a síntese colocou cada memória | ROM em LUTs (absorvida no PC, 1.717 LUTs); **DMEM em FFs** (32.768 FFs + 8.794 LUTs); banco de registradores em FFs | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos e mapa | Nenhum. Só a porta `leds = ~x15[7:0]`, que sai do banco de registradores (registers.v:231). | sim: `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |

## 4. Reset

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Síncrono/assíncrono, polaridade | síncrono, ativo alto (`CPU_RESETN` invertido no wrapper) | síncrono, ativo alto (`CPU_RESETN` invertido no top) |
| O que o reset zera | PC, os 32 registradores e **toda a DMEM** (laço em data_memory.v:27-30; a última palavra fica de fora porque o laço vai até `< MEMORY_SIZE/4-1`) | só o PC (a instrução registrada volta à do endereço 0) |
| Efeito na síntese | **Sim:** o reset de toda a RAM impede LUTRAM/BRAM, e a DMEM vira 32.768 FFs. O reset do banco de registradores também o deixa em FFs. | nenhum |

## 5. Microarquitetura e caminho crítico

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato | 1 (monociclo) | 1 |
| Registradores no caminho além do PC | nenhum | instrução registrada (tira a leitura da ROM do caminho) |
| Bordas de clock usadas | só subida (mais 10 latches de controle) | só subida |
| Decisão de desvio | pela ALU: flag zero `AND` branch (core.v:27); cada desvio escolhe uma operação da ALU | comparador dedicado rs1×rs2, fora da ALU |
| Alvo de desvio / PC+4 | somador dedicado `PC + (imm>>1)` (core.v:23); PC+1 dentro do `PC` | somadores dedicados |
| Endereço da DMEM | saída da ALU (rs1+imm na ALU), sem somador dedicado | somador dedicado rs1+imm; flags de região sem esperar o carry |
| ALU | AND, OR, ADD, SUB, SLT (sem sinal), NOR, SLL, SRL, XOR, ==, >=, implementados com os operadores `<`, `>=`, `<<` e `>>` do Verilog | add/sub, shifter, SLT/SLTU pelo carry |
| Mux de write-back / mux do próximo PC | write-back: 2 entradas (ALU × memória); próximo PC: reset / PC+1 / alvo | write-back: 2 entradas (ALU × memória); próximo PC: reset / PC+4 / alvo |
| Banco de registradores | 32×32 em FFs com reset, leitura por `case` (mux 32:1); **x0 pode ser escrito** (registers.v:194) | 32×32 LUTRAM, leitura assíncrona, x0 por mux |
| Caminho crítico medido | `PC_Register_reg_rep[1]` → `register0_reg[11]`, 17 níveis, 23,3 ns (lógica 3,9 / rota 19,5). Percorre PC → ROM → mux do banco → ALU → mux 1024:1 da DMEM em FFs → write-back → registrador. | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, nº de módulos, linhas de RTL | Verilog-2001, 10 módulos, 686 linhas | SystemVerilog |
| Testbench próprio / riscv-tests | 5 testbenches Icarus em `tests/`. `core_test.v` só gera VCD, sem verificação automática. Os `.S` de `software/` exercitam uma instrução cada. Não usa riscv-tests. | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | Latches na `Control_Unit` (sem `default`); desvios para trás quebrados (core.v:23); comparações com sinal feitas sem sinal; SRA lógico; x0 gravável; endereço de byte usado como índice de palavra; funct3 de load/store ignorado; reset/`initial` da DMEM sem a última palavra; `case` duplicado no imediato (immediate_generator.v, dois `7'b1100011` e dois `7'b0010011`) | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

A diferença vem quase toda da DMEM. O reset síncrono que zera a RAM inteira (data_memory.v:27-30) impede a inferência de LUTRAM/BRAM. Por isso os 4 KiB viram 32.768 FFs, e a leitura combinacional vira um mux 1024:1 de 32 bits: são 8.794 LUTs e a maior parte dos 4.657 F7 e 2.136 F8. Isso dá 11.878 LUTs e 33.818 FFs, contra 1.266 LUTs e 98 FFs no TCC.

Esse mux enorme e espalhado está em série no caminho crítico, depois do mux do banco de registradores (também em FFs) e da ALU. O endereço da DMEM sai da ALU, sem somador dedicado. O resultado são 17 níveis, com 83 % de rota (19,5 de 23,3 ns), e Fmax de 42,5 MHz contra 97,8 MHz no TCC.

Também falta a instrução registrada que o TCC usa: aqui o caminho começa no PC e atravessa a ROM. A área espalhada explica ainda a potência (1,18 W contra 0,146 W) e o tempo de compilação (758 s contra 110 s).

A comparação de área também é desigual a favor do TCC em funcionalidade: este núcleo não implementa JAL, JALR, LUI, AUIPC nem loads e stores de byte e halfword, e tem várias instruções semanticamente erradas.
