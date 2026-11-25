# 09 — Casacuberta (RV32i-Verilog) × núcleo do TCC

Caminhos relativos a `repo/src/` (o `patch/` só troca `default_nettype` e a carga da ROM, sem mudar a lógica).

## 1. Conjunto de instruções

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente (pela leitura) | **25** | 37 (verificadas em testbench) |
| Lista das que faltam / viram NOP / estão erradas (com o motivo) | **BEQ, BNE, BLT, BGE, BLTU, BGEU**: quando o desvio não é tomado, `offset = 0` em vez de 4 (`core/core_execution_unit/core_execution_unit_br.v:63-66`), então o PC não muda e o núcleo repete o desvio para sempre. **LB, LH, LBU, LHU, SB, SH**: não usam `addr[1:0]`. O load pega sempre `[7:0]`/`[15:0]` da palavra (`core_execution_unit_lis.v:56-60`) e o store escreve sempre na lane 0 ou 0–1 (`core_control_unit.v:529,533`). Só funcionam em endereço múltiplo de 4. JALR não zera o bit 0 do alvo (`br.v:71`). Desvio pequeno, contado como certo. | nenhuma |
| FENCE / ECALL / EBREAK | NOP (FENCE sem sinais. ECALL/EBREAK escrevem em `rd` = x0, sem efeito) | NOP |
| **Instruções extras além das 40** — liste todas | Zicsr parcial. **CSRRS** em `cycle`, `cycleh`, `time`, `timeh`, `instret`, `instreth` (0xC00/C80/C01/C81/C02/C82), todos lendo o **mesmo** timer de 64 bits. CSRRW/CSRRC/CSRRWI/CSRRSI/CSRRCI são decodificados, mas o `crs_unit` não os executa: só gravam em `rd` o último valor registrado. Problemas no CSR: a leitura é registrada (`core_csr_unit.v:98`), então `rd` recebe o valor da operação CSR anterior. `csr_data_o = rs1` é o *índice* do registrador, não o valor (`core_control_unit.v:612`). A operação "set" faz AND (`core_csr_unit.v:101`). `timer_we_o` nunca volta a 0 depois da primeira escrita (`:100`). | nenhuma |
| Codificação inválida (funct3/funct7 inexistente) | Opcode inválido vira NOP (defaults). funct7 não é verificado: ADD/SRL etc. com funct7 qualquer executam, e só o bit 5 é testado. funct3 inválido de load/branch/store usa o default da operação. | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps (instrução ilegal, ECALL, desalinhamento) | não (só `$display`, ignorado na síntese) | não |
| CSRs (quais) | contadores cycle/time/instret (+H), apelidos de um timer de 64 bits. Só leitura útil (ver §1) | nenhum |
| Desvio/acesso desalinhado | ignorado, sem trap. JALR não zera o bit 0. Acesso a byte ou halfword fora da lane 0 dá resultado errado | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard (progMem e dataMem separadas) | Harvard |
| IMEM: tamanho, tipo, leitura | declarada com 1024 palavras. O endereço é `pc[9:0]>>2`, então só 256 palavras (1 KiB) são alcançáveis. Leitura combinacional, não registrada | 4 KiB ROM em LUTs, combinacional; palavra registrada no `search` |
| IMEM: carregamento do programa | original: zerada no reset assíncrono, com `$readmemh` dentro do reset (só simulação) → ROM 0 na síntese. Aqui: `initial $readmemh` (patch) | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | 256×32 (1 KiB). Leitura combinacional (retorna 0 durante store), escrita na subida com byte enables | 1 KiB LUTRAM; leitura combinacional, escrita na subida |
| DMEM: carga do `.data` inicial | não há (zerada no reset. `$readmemh` só no reset com `LOAD_MEMS`) | `$readmemh` em `initial` |
| Byte/halfword, extensão de sinal, byte enables | extensão de sinal ok, mas sem deslocamento por `addr[1:0]` (ver §1) | completos |
| Onde a síntese colocou cada memória | ROM em LUTs (dentro do núcleo). **DMEM em FFs** (8.192 FFs + 2.305 LUTs de mux). Banco em FFs (992). 0 LUTRAM, 0 BRAM | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos e mapa | nenhum no núcleo (o top da DE0 lia `addr == 0x14` para os LEDs, fora do núcleo) | `0x4000_0000`, 4 saídas + 4 entradas |

## 4. Reset

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Síncrono/assíncrono, polaridade | **assíncrono, ativo baixo** (`rst_n`) | síncrono, ativo alto |
| O que o reset zera | PC, **todo o banco de registradores**, **toda a DMEM**, timer de 64 bits e registradores do CSR (e a ROM, no original) | só o PC |
| Efeito na síntese | **impede LUTRAM** no banco e na DMEM, que viram 9.184 FFs e muxes largos de leitura em LUTs/F7/F8 | nenhum |

## 5. Microarquitetura e caminho crítico

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato (busca, load, store) | 1 (mas um desvio não tomado trava o PC, ver §1) | 1 |
| Registradores no caminho além do PC | nenhum (a leitura de CSR é registrada, fora do caminho principal) | instrução registrada |
| Bordas de clock usadas | só subida | só subida |
| Decisão de desvio | **pela ALU**: SUB/SLT/SLTU e detecção de zero de 32 bits no resultado (`alu.v:47`). Depois um mux do offset e o somador `pc + offset` | comparador dedicado rs1×rs2 |
| Alvo de desvio / PC+4 | **um único somador** `pc + offset`, com offset ∈ {4, imm, 0} escolhido depois da ALU. O PC+4 do JAL/JALR sai do mesmo somador. O alvo do JALR sai da ALU | somadores dedicados |
| Endereço da DMEM | saída da ALU (`lis.v:45`), sem somador dedicado | somador dedicado rs1+imm |
| ALU (operações, shifter, SLT/SLTU) | add, sub, sll, srl, sra (`>>>`), slt/sltu por comparadores `<`, xor, or, and. Operandos por mux (rs1/PC × rs2/imm) | add/sub, shifter, SLT/SLTU pelo carry |
| Mux de write-back / mux do próximo PC (nº de entradas) | write-back: **4** (ALU, memória via LIS, PC+4, CSR). Próximo PC: 2 (`pc+offset` × saída da ALU) + reset assíncrono | 2; reset / PC+4 / alvo |
| Banco de registradores | 32×32 **em FFs** (reset de todo o array), leitura assíncrona, x0 por mux | 32×32 LUTRAM |
| Caminho crítico medido e por que é esse | `pc_reg[2]` → `regFile_reg[11][30]/D`, **23 níveis**, 19,19 ns (lógica 4,31 / rota 14,88). É o caminho monociclo inteiro: ROM → decodificação → leitura do banco em FFs (mux 32:1) → ALU → mux de write-back → escrita no banco. Para o load ainda entra o mux 256:1 da DMEM em FFs | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação

| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, nº de módulos, linhas de RTL | Verilog-2001. 12 módulos (core, controlUnit, programCounter, regFile, executionUnit, alu, lis, br, crs_unit, timer, progMem, dataMem). ≈1.260 linhas não vazias e não comentadas | SystemVerilog |
| Testbench próprio / riscv-tests | testbenches próprios em Icarus (`tb/arithmeticologic.v`, `branch.v`, `load_store.v`, `csr.v`) com Travis CI. Sem riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | desvio não tomado trava o PC (`br.v:63-66`); load/store de byte/halfword ignoram `addr[1:0]` (`lis.v:56-61`, `core_control_unit.v:529,533`); JALR não zera o bit 0 (`br.v:71`); CSR com leitura atrasada, índice no lugar do valor, AND no lugar de OR e `we` preso (`core_csr_unit.v:98-101`, `core_control_unit.v:612`); funct7 não verificado | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

Os 4.986 LUTs e 9.339 FFs (contra 1.266 LUTs e 98 FFs no TCC) vêm quase todos do **reset assíncrono
que zera arrays inteiros**. Esse reset impede LUTRAM, então a DMEM de 1 KiB vira 8.192 FFs mais cerca
de 2.300 LUTs de mux de leitura 256:1 (F7/F8), e o banco vira 992 FFs mais cerca de 540 LUTs. O núcleo
em si (ROM, controle, ALU, CSR/timer de 64 bits) fica em torno de 1.900 LUTs, próximo do TCC.
No tempo (51,1 MHz contra 97,8 MHz), o caminho crítico é o ciclo único inteiro e não tem a instrução
registrada do TCC: PC → ROM → decodificação → mux 32:1 do banco em FFs → ALU. A decisão de desvio
também depende da ALU, da detecção de zero de 32 bits e do somador único `pc + offset`, enquanto o TCC
usa comparador e somadores dedicados. O write-back tem 4 entradas. Com 23 níveis contra 12, e a
área espalhada pelos FFs da memória, **77% do atraso é rota** (14,9 ns). Esse congestionamento é
consequência direta das memórias em FFs.
