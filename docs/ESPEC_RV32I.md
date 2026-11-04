# Especificação RV32I monociclo — conforme o RTL

Versão alinhada ao RTL de `processador_riscV.srcs/sources_1/new/` (fonte da verdade).
Baseada na spec original do usuário (`especifica_o_t_cnica_definitiva_rv32i.md`), com
reset, controle, nomes de módulos e flags ajustados para o que o RTL implementa.
Se o RTL mudar, atualize este arquivo junto.

## 1. Escopo

- RV32I, 32 bits, endereçamento por byte, little-endian.
- **37 instruções** implementadas. `ECALL`, `EBREAK` e `FENCE` são NOP (sem CSRs, sem traps).
  Codificações inválidas de funct3/funct7 também viram NOP (sem escrita, PC avança).
- 32 registradores de 32 bits; `x0` sempre lê 0 e escritas nele são ignoradas.
- PC avança +4. Busca de instrução alinhada em palavra. Dados: byte/half/word alinhados
  (acesso desalinhado não é suportado e não gera trap).
- ABI: `ra`=x1, `sp`=x2, `gp`=x3, `tp`=x4, `t0-2`=x5-7, `s0/fp`=x8, `s1`=x9,
  `a0-1`=x10-11, `a2-7`=x12-17, `s2-11`=x18-27, `t3-6`=x28-31.

## 2. Clock e reset

- Um único clock `clk`, borda de subida.
- Elementos sequenciais: PC (`search`), instrução registrada (`instruction_memory`, leitura
  síncrona), escrita no `register_file`, escrita na RAM e registradores de saída MMIO
  (`data_memory`). Todo o resto é combinacional.
- Busca: o próximo PC (`search.pc_sel`) vai, na mesma borda, para o PC e para o endereço da
  `instruction_memory`, que registra a palavra desse endereço. Depois de cada borda a instrução
  é a do PC atual; continua uma instrução por ciclo, sem estágios. A leitura da ROM acontece
  no fim do ciclo anterior, assim que o próximo PC fica pronto.
- Pino da placa `CPU_RESETN` (ativo em nível **baixo**) entra em `top_core`, que **inverte**
  (`reset = ~CPU_RESETN`) e entrega ao `core` (porta `reset_i`) um reset **síncrono ativo em
  nível alto**; o `core` repassa `reset_i` sem alteração ao `search` (porta `reset_i`).
- O reset força o próximo PC a 0: na borda, o PC zera e a `instruction_memory` registra a
  palavra 0. Registradores, RAM e saídas MMIO não são resetados; eles partem dos valores de
  `initial` (zeros / arquivos `.mem`), que valem só na carga do FPGA. Na carga, o PC nasce 0 e
  a instrução registrada nasce com a palavra 0, então a placa parte sem apertar o reset.

## 3. Codificação (opcode / funct3 / funct7)

| Grupo | opcode (`opcode_pkg`) | Instruções (funct3) | funct7 |
| :-- | :-- | :-- | :-- |
| R | `0110011` `OPCODE_OP` | ADD/SUB 000, SLL 001, SLT 010, SLTU 011, XOR 100, SRL/SRA 101, OR 110, AND 111 | `0000000`; SUB/SRA `0100000` |
| I-ALU | `0010011` `OPCODE_OP_IMM` | ADDI 000, SLTI 010, SLTIU 011, XORI 100, ORI 110, ANDI 111, SLLI 001, SRLI/SRAI 101 | só shifts: `0000000`; SRAI `0100000` |
| Load | `0000011` `OPCODE_LOAD` | LB 000, LH 001, LW 010, LBU 100, LHU 101 | — |
| Store | `0100011` `OPCODE_STORE` | SB 000, SH 001, SW 010 | — |
| Branch | `1100011` `OPCODE_BRANCH` | BEQ 000, BNE 001, BLT 100, BGE 101, BLTU 110, BGEU 111 | — |
| JAL | `1101111` `OPCODE_JAL` | — | — |
| JALR | `1100111` `OPCODE_JALR` | 000 | — |
| LUI | `0110111` `OPCODE_LUI` | — | — |
| AUIPC | `0010111` `OPCODE_AUIPC` | — | — |
| (NOP) | `0001111` `OPCODE_MISC_MEM`, `1110011` `OPCODE_SYSTEM` | FENCE, ECALL, EBREAK | — |

Semântica: JAL/JALR escrevem `PC+4` em rd; alvo de JAL = `PC + imm`; alvo de JALR =
`(rs1 + imm) & ~1`; shifts usam `B[4:0]`; LUI `rd = imm` (imm já é `imm20<<12`);
AUIPC `rd = PC + imm`.

## 4. Imediatos (`imm_gen`, por opcode)

- I (LOAD, OP_IMM, JALR e default): `{{20{i[31]}}, i[31:20]}`
- S (STORE): `{{20{i[31]}}, i[31:25], i[11:7]}`
- B (BRANCH): `{{19{i[31]}}, i[31], i[7], i[30:25], i[11:8], 1'b0}`
- U (LUI, AUIPC): `{i[31:12], 12'b0}`
- J (JAL): `{{11{i[31]}}, i[31], i[19:12], i[20], i[30:21], 1'b0}`

## 5. Controle (`control_unit`)

Não existe ALUOp de 2 bits nem um "ALU Control" separado: o `control_unit` decodifica
opcode/funct3/funct7 e gera direto todos os sinais abaixo.

### 5.1 Sinais

| Saída do `control_unit` | Tipo | Destino | Significado |
| :-- | :-- | :-- | :-- |
| `execution_alu_control_o` | `alu_op_t` | ALU | operação da ALU |
| `execution_control_alu_a_o` | 1 bit | execution | operando A: 0 = rs1, 1 = PC |
| `execution_control_alu_b_o` | 2 bits | execution | operando B: 00 = rs2, 01 = imm, 10 = PC+4 |
| `execution_branch_enable_o` | 1 bit | execution | instrução pode desviar o PC |
| `execution_branch_control_o` | `branch_op_t` | execution | tipo de desvio (abaixo) |
| `search_pc_write_o` | 1 bit | search | habilita atualizar PC (hoje sempre 1) |
| `data_memory_mem_write_o` | 1 bit | data_memory | escrita na memória (store) |
| `data_memory_mem_width_o` | `mem_width_t` | data_memory | BYTE `00`, HALF `01`, WORD `10` |
| `data_memory_mem_signed_o` | `mem_signed_t` | data_memory | UNSIGNED `0`, SIGNED `1` (loads) |
| `register_file_written_enable_o` | 1 bit | register_file | escreve rd |
| `write_back_mem_to_reg_o` | 1 bit | write_back | 0 = resultado ALU, 1 = dado da memória |

Não há `mem_read`: a leitura da `data_memory` é sempre combinacional e só é usada quando
`mem_to_reg = 1`.

Padrões (opcode desconhecido / NOP): ALU `OP_ADD`, A = rs1, B = rs2, sem desvio
(`OP_BCT`, enable 0), PC write 1, sem escrita em memória/registrador, WORD/UNSIGNED, ALU no WB.

### 5.2 `branch_op_t` (`branch_pkg`)

| Código | Nome | Desvia quando | Alvo |
| :-- | :-- | :-- | :-- |
| `00` | `OP_BCT` | comparação verdadeira | `(PC + imm) & ~1` |
| `01` | `OP_BCF` | comparação falsa | `(PC + imm) & ~1` |
| `10` | `OP_BIP` | sempre (JAL) | `(PC + imm) & ~1` |
| `11` | `OP_BIR` | sempre (JALR) | `(rs1 + imm) & ~1` |

A comparação vem de um comparador dedicado da `execution`, que compara `rs1` com `rs2` direto,
sem os muxes de operando nem a ALU. O `alu_op_t` do desvio só escolhe qual comparação usar:
`OP_SLT` → `$signed(rs1) < $signed(rs2)` (BLT/BGE), `OP_SLTU` → `rs1 < rs2` (BLTU/BGEU) e
qualquer outro, na prática `OP_CMP` → `rs1 == rs2` (BEQ/BNE).

### 5.3 Matriz por grupo

| Grupo | RegWr | A | B | MemWr | width / signed | MemToReg | `alu_op_t` | Branch en / op |
| :-- | :-: | :-: | :-: | :-: | :-- | :-: | :-- | :-- |
| R | 1 | rs1 | rs2 | 0 | — | 0 | conforme funct3/funct7 | 0 |
| I-ALU | 1 | rs1 | imm | 0 | — | 0 | conforme funct3 (shifts checam funct7) | 0 |
| Load | 1 | rs1 | imm | 0 | LB B/S, LH H/S, LW W, LBU B/U, LHU H/U | 1 | `OP_ADD` | 0 |
| Store | 0 | rs1 | imm | 1 | SB B, SH H, SW W | — | `OP_ADD` | 0 |
| BEQ / BNE | 0 | rs1 | rs2 | 0 | — | — | `OP_CMP` | 1 / BCT, BCF |
| BLT / BGE | 0 | rs1 | rs2 | 0 | — | — | `OP_SLT` | 1 / BCT, BCF |
| BLTU / BGEU | 0 | rs1 | rs2 | 0 | — | — | `OP_SLTU` | 1 / BCT, BCF |
| JAL | 1 | rs1 (ignorado) | PC+4 | 0 | — | 0 | `OP_PASS_B` | 1 / BIP |
| JALR | 1 | rs1 (ignorado) | PC+4 | 0 | — | 0 | `OP_PASS_B` | 1 / BIR |
| LUI | 1 | rs1 (ignorado) | imm | 0 | — | 0 | `OP_PASS_B` | 0 |
| AUIPC | 1 | PC | imm | 0 | — | 0 | `OP_ADD` | 0 |

JAL/JALR gravam `PC+4` passando-o pela ALU (`OP_PASS_B` com B = PC+4); o alvo do salto é
calculado num somador separado dentro do `execution`.

## 6. ALU (`alu`, `alu_pkg::alu_op_t`)

| Código | Op | Resultado |
| :-- | :-- | :-- |
| `0000` | `OP_ADD` | A + B |
| `0001` | `OP_SUB` | A − B |
| `0010` | `OP_AND` | A & B |
| `0011` | `OP_OR` | A \| B |
| `0100` | `OP_XOR` | A ^ B |
| `0101` | `OP_SLL` | A << B[4:0] |
| `0110` | `OP_SRL` | A >> B[4:0] |
| `0111` | `OP_SRA` | $signed(A) >>> B[4:0] |
| `1000` | `OP_SLT` | 1 se A < B (com sinal), senão 0 |
| `1001` | `OP_SLTU` | 1 se A < B (sem sinal) = `~carry` de A + ~B + 1 |
| `1010` | `OP_PASS_B` | B |
| `1011` | `OP_CMP` | 0: não é calculado pela ALU; só escolhe a igualdade no comparador de desvio (§5.2) |

Saída: `alu_o` (resultado de 32 bits). A ALU não decide desvios: a condição vem do comparador
dedicado da `execution` (§5.2). SLT e SLTU continuam na ALU para SLT, SLTI, SLTU e SLTIU.

## 7. Hierarquia e interfaces dos módulos

```text
top_core          pinos da placa -> core; inverte CPU_RESETN (reset ativo alto para o core)
└── core          interliga o datapath; params XLEN, MEM_DEPTH, INSTR_MEM_FILE, DATA_MEM_FILE
    ├── search            PC + mux PC+4 / alvo de desvio
    │   └── instruction_memory
    ├── decoder           separa rd/rs1/rs2 da instrução
    │   ├── register_file
    │   ├── imm_gen
    │   └── control_unit
    ├── execution         muxes A/B, decisão e alvo de desvio
    │   └── alu
    ├── data_memory       RAM byte-endereçável + periféricos MMIO
    └── write_back        mux ALU / memória
```

Convenção: portas com `_i`/`_o`; saídas de controle levam o prefixo do bloco de destino.

| Módulo | Entradas | Saídas | Comportamento |
| :-- | :-- | :-- | :-- |
| `top_core` | `clk`, `CPU_RESETN`, `switch[15:0]`, `BTNC/U/L/R/D`, `JA[10:7]` (linhas) | `led[15:0]`, `c_7_segment[7:0]`, `a_7_segment[7:0]`, `JA[4:1]` (colunas) | `reset = ~CPU_RESETN` → `core.reset_i`; `io_in0 = {16'b0, switch}`, `io_in1 = {27'b0, BTND,BTNR,BTNL,BTNU,BTNC}`, `io_in2 = {28'b0, JA[10:7]}`, `io_in3 = 0`; `led = io_out0[15:0]`, `c_7_segment = io_out1[7:0]` (cátodos), `a_7_segment = io_out1[15:8]` (ânodos), `JA[4:1] = io_out2[3:0]`; `io_out3` sem ligação |
| `search` | `clk`, `reset_i`, `pc_write_i`, `pc_branch_i`, `new_pc_i` | `instr_o`, `pc_o`, `pc_next` | `pc_next = PC+4`; próximo PC `pc_sel = reset_i ? 0 : pc_write_i ? (pc_branch_i ? new_pc_i : pc_next) : PC`; na borda, PC = `pc_sel`. `pc_sel` também endereça a `instruction_memory`, então `instr_o` (registrada) é a instrução do PC atual |
| `instruction_memory` | `clk`, `addr_i` (próximo PC) | `instr_o` | ROM de palavras em LUTs (`rom_style = "distributed"`), carregada de `MEM_FILE`; leitura síncrona: na borda, `instr_o = mem[addr_i[..:2]]`; nasce com `mem[0]` |
| `decoder` | `clk`, `instruction_i`, `written_data_i` | `rs1_o`, `rs2_o`, `imm_o` + todas as saídas do `control_unit` | rd=`[11:7]`, rs1=`[19:15]`, rs2=`[24:20]` |
| `register_file` | `clk`, `written_enable_i`, `written_data_i`, `written_add_i`, `rs1_add_i`, `rs2_add_i` | `rs1_o`, `rs2_o` | leitura combinacional; escrita na borda se enable e rd≠0; x0 não existe no array |
| `imm_gen` | `instruction_i` | `imm_o` | §4 |
| `control_unit` | `instruction_i` | §5.1 | §5 |
| `execution` | `pc_next_i`, `pc_i`, `imm_i`, `reg_data1_i`, `reg_data2_i`, `alu_control_i`, `branch_control_i`, `branch_enable_i`, `control_alu_a`, `control_alu_b` | `alu_result_o`, `pc_branch_o`, `branch_taken_o`, `mem_addr_o`, `mem_io_o`, `mem_page0_o` | §5.2 (condição pelo comparador dedicado `rs1` × `rs2`); `pc_branch_o = (imm + base) & ~1`; `mem_addr_o = reg_data1_i + imm_i` (somador dedicado, independe da ALU e dos muxes A/B); `mem_io_o` = `mem_addr_o[31:28] == 4`, `mem_page0_o` = `mem_addr_o[31:12] == 0`, calculadas sem esperar o somador e exatas só com imediato de 12 bits (load/store; §9) |
| `alu` | `a_i`, `b_i`, `alu_op_i` | `alu_o` | §6 |
| `data_memory` | `clk`, `mem_write_i`, `mem_width_i`, `mem_signed_i`, `addr_i`, `addr_io_i`, `addr_page0_i`, `data_i`, `io_in0_i` … `io_in3_i` (32 bits) | `data_o`, `io_out0_o` … `io_out3_o` (32 bits) | §9 |
| `write_back` | `alu_result_i`, `mem_data_i`, `mem_to_reg_i` | `wb_data_o` | `mem_to_reg_i ? mem_data_i : alu_result_i` |

## 8. Ligações entre os blocos (`core`)

| Sinal no `core` | Origem | Destino(s) |
| :-- | :-- | :-- |
| `reset_i` | porta do `core` (`top_core`: `~CPU_RESETN`) | `search.reset_i` |
| `instruction` | `search.instr_o` | `decoder.instruction_i` |
| `pc` | `search.pc_o` | `execution.pc_i` |
| `pc_next` (PC+4) | `search.pc_next` | `execution.pc_next_i` |
| `rs1_data` | `decoder.rs1_o` | `execution.reg_data1_i` |
| `rs2_data` | `decoder.rs2_o` | `execution.reg_data2_i`, `data_memory.data_i` (dado do store) |
| `immediate` | `decoder.imm_o` | `execution.imm_i` |
| `alu_control` | `decoder.execution_alu_control_o` | `execution.alu_control_i` |
| `alu_a_select` / `alu_b_select` | `decoder.execution_control_alu_a_o` / `_b_o` | `execution.control_alu_a` / `control_alu_b` |
| `branch_enable` / `branch_control` | `decoder.execution_branch_enable_o` / `_control_o` | `execution.branch_enable_i` / `branch_control_i` |
| `pc_write_enable` | `decoder.search_pc_write_o` | `search.pc_write_i` |
| `branch_taken` | `execution.branch_taken_o` | `search.pc_branch_i` |
| `pc_branch` | `execution.pc_branch_o` | `search.new_pc_i` |
| `alu_result` | `execution.alu_result_o` | `write_back.alu_result_i` |
| `data_memory_addr` (rs1 + imm) | `execution.mem_addr_o` | `data_memory.addr_i` |
| `data_memory_addr_io` / `data_memory_addr_page0` | `execution.mem_io_o` / `mem_page0_o` | `data_memory.addr_io_i` / `addr_page0_i` |
| `data_memory_write_enable`, `_width`, `_signed` | `decoder.data_memory_mem_*_o` | `data_memory.mem_write_i`, `mem_width_i`, `mem_signed_i` |
| `data_memory_data` | `data_memory.data_o` | `write_back.mem_data_i` |
| `mem_to_reg` | `decoder.write_back_mem_to_reg_o` | `write_back.mem_to_reg_i` |
| `write_back_data` | `write_back.wb_data_o` | `decoder.written_data_i` → `register_file` |
| `register_write_enable` | `decoder.register_file_written_enable_o` | `register_file.written_enable_i` (interno ao decoder) |
| `io_in0_i` … `io_in3_i` / `io_out0_o` … `io_out3_o` | portas do `core` (ligadas aos pinos no `top_core`) | `data_memory` (MMIO) |

Fluxo de um ciclo:

```text
[instr] ─► decoder ─┬─ rs1/rs2/imm ─► execution ─┬─ rs1+imm ───► data_memory ─┐
   ▲                └─ controle ────►            │                              ▼
   │                                             └─ ALU ─► alu_result ─────► write_back ─► register_file (borda)
   └─ search: pc_sel = branch_taken ? pc_branch : PC+4 ◄── execution
              na borda: PC ← pc_sel e [instr] ← instruction_memory[pc_sel]
```

## 9. Memória de dados e MMIO (`data_memory`)

- RAM: `MEM_DEPTH` palavras × 4 bytes (`0 .. MEM_DEPTH*4-1`), carregada de `DATA_MEM_FILE`
  (um byte por token hex). Leitura combinacional; escrita na borda com byte-enable
  (SB: `0001 << addr[1:0]`; SH: `0011`/`1100` por `addr[1]`; SW: `1111`).
- Loads: escolhe byte por `addr[1:0]` ou half por `addr[1]` e estende conforme `mem_signed_i`.
- Endereço fora da RAM (e fora do MMIO) lê 0 e ignora escrita.
- Decodificação de região: as comparações dos bits altos chegam prontas da `execution`
  (`addr_io_i` = `addr[31:28] == 4'h4`, `addr_page0_i` = `addr[31:12] == 0`). Com imediato de
  12 bits, `addr[31:12]` só pode ser `rs1[31:12]` − 1, + 0 ou + 1 (escolhido por `imm[11]` e pelo
  carry do bit 11), então as flags não esperam o carry chegar ao bit 31. RAM válida =
  `addr_page0_i && addr[11:0] < MEM_DEPTH*4`; por isso `MEM_DEPTH*4` não pode passar de 4096
  (erro de elaboração).
- MMIO: `addr[31:28] == 4'h4`, registrador escolhido por `addr[5:2]`. Mesmas lanes de byte e
  extensão de sinal da RAM.
- 4 saídas e 4 entradas genéricas de 32 bits; o que cada uma liga na placa é definido no
  `top_core`. Saídas: registradores (`initial` em zero, sem reset), escritos por faixa de byte,
  somente escrita (a leitura devolve 0, para a síntese remover os bits sem pino). Entradas: lidas
  combinacionalmente; escrita nelas é ignorada. Offsets
  `addr[5:2]` de 8 a 15 leem 0 e ignoram escrita.

| Endereço | Registrador | Acesso | Na Nexys A7 (`top_core`) |
| :-- | :-- | :-- | :-- |
| `0x4000_0000` | `io_out0_o[31:0]` | E (lê 0) | LEDs `[15:0]` |
| `0x4000_0004` | `io_out1_o[31:0]` | E (lê 0) | 7 segmentos: `[7:0]` cátodos, `[15:8]` ânodos |
| `0x4000_0008` | `io_out2_o[31:0]` | E (lê 0) | colunas do PMOD `[3:0]` |
| `0x4000_000C` | `io_out3_o[31:0]` | E (lê 0) | livre |
| `0x4000_0010` | `io_in0_i[31:0]` | L | chaves `[15:0]` |
| `0x4000_0014` | `io_in1_i[31:0]` | L | botões `{BTND,BTNR,BTNL,BTNU,BTNC}` |
| `0x4000_0018` | `io_in2_i[31:0]` | L | linhas do PMOD `[3:0]` |
| `0x4000_001C` | `io_in3_i[31:0]` | L | livre (lê 0) |

## 10. Fora do escopo (decisão de 31/10/2026, pode ser revista)

- Sem CSRs, interrupções ou traps; `ECALL`/`EBREAK`/`FENCE` e instruções inválidas são NOP.
- Só o bit 0 do alvo de JAL/JALR/branch é zerado; alvo desalinhado em palavra não gera trap.
- Acessos half/word desalinhados não são suportados e não geram trap.

Detalhes em `DOCUMENTACAO_PROJETO.md` §8.1.
