# Especificação e arquitetura — Processador RV32I

Este documento consolida os requisitos funcionais, a arquitetura, as decisões observáveis no RTL e a organização do projeto. Ele foi elaborado a partir dos arquivos presentes no workspace; não substitui a lógica SystemVerilog como fonte de verdade. Quando o código e comentários divergem, a implementação descrita é a do código e a divergência fica registrada em **Questões em aberto**.

## 1. Visão geral

- **Objetivo:** processador didático RV32I, monociclo, implementado em SystemVerilog.
- **Placa configurada:** Digilent Nexys A7-100T, FPGA Artix-7 `xc7a100tcsg324-1`.
- **Projeto Vivado:** `processador_riscV.xpr`, Vivado 2025.2; top de hardware `top_core`.
- **Largura de dados/endereço:** 32 bits (parâmetro `XLEN`).
- **Clock:** estado sequencial atualizado na borda de subida.
- **Idioma predominante dos comentários/documentos:** português.

## 2. Requisitos funcionais

### 2.1 Processador

O processador busca uma instrução de 32 bits, decodifica os campos e controles, lê até dois registradores, executa operação na ALU, acessa memória de dados quando necessário e seleciona o valor de write-back. Em fluxo sequencial, o PC avança quatro bytes; branch ou salto seleciona o endereço calculado.

O subconjunto de instruções que a unidade de controle declara implementar é:

- **R-type:** `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`.
- **I-type aritmético/lógico:** `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`.
- **Loads:** `LB`, `LH`, `LW`, `LBU`, `LHU`.
- **Stores:** `SB`, `SH`, `SW`. 
- **Branches:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`.
- **Outras:** `LUI`, `AUIPC`, `JAL`, `JALR`.

Opcode não reconhecido não gera escrita em registrador ou memória nem exceção/trap; o PC continua pelo caminho sequencial conforme o controle padrão. A decodificação é estrita: codificações inválidas dentro de um opcode conhecido também viram NOP — R-type com `funct7` diferente de `0000000`/`0100000` (ex.: `MUL` da extensão M), `SLLI`/`SRLI`/`SRAI` com `imm[11:5]` inválido, `JALR` com `funct3 ≠ 000`, e `funct3` sem instrução em loads/stores/branches. `ECALL`, `EBREAK` e `FENCE` executam como NOP.

### 2.2 Registradores e estado

- Banco arquitetural de 32 registradores, com `x0` sempre lido como zero e escrita em `x0` descartada.
- Duas portas de leitura combinacional e uma porta de escrita síncrona.
- O banco não tem reset; `x1`–`x31` começam em zero por um bloco `initial` (valor de inicialização na FPGA e ausência de `X` na simulação), mas o reset não os limpa.
- O reset ativo baixo da placa é invertido para gerar reset síncrono ativo alto do PC. O reset força o próximo PC a 0: o PC zera e a instrução registrada passa a ser a palavra 0. Nada mais é limpo.

### 2.3 Memórias

- Memória de instruções (ROM) de leitura combinacional, inicializada com `$readmemh`. O `search` a lê com o próximo PC e registra a instrução na mesma borda que o PC; o registrador nasce com a palavra 0, então a placa parte sem reset.
- Memória de dados organizada como bytes, com leitura combinacional e escrita na borda de subida.
- Acesso à RAM e ao MMIO suporta byte, halfword e word; loads suportam extensão com ou sem sinal. Em MMIO, `SB`/`SH` alteram apenas os bytes endereçados do registrador de saída e `LB`/`LBU`/`LH`/`LHU` extraem o byte/halfword endereçado (ex.: `LBU` em `0x4000_0011` retorna `io_in0[15:8]`, as chaves `[15:8]` na placa).
- Acessos halfword/word desalinhados não são suportados (sem trap): o halfword usa `addr[1]` e a word ignora `addr[1:0]`.
- Profundidades declaradas pelo core: 1024 palavras (4 KiB) na memória de instruções e 256 palavras (1 KiB, `0x000`–`0x3FF`) na RAM de dados. A RAM foi reduzida em 04/11/2026 porque a menor encurta o caminho do load; os programas usam ~500 B, contando a pilha.
- Arquivos configurados no core: `program_bytes.mem` e `data.mem`.

### 2.4 Entradas e saídas da placa

O top conecta switches, cinco botões, LEDs, display de sete segmentos e pinos PMOD. O core expõe, via MMIO na memória de dados, 4 saídas e 4 entradas genéricas de 32 bits, e o `top_core` define o que cada uma liga na placa (decisão de 03/11/2026: o core não depende dos periféricos da Nexys A7). As saídas são registradores inicializados em zero e atualizados sincronamente; são somente escrita (a leitura devolve 0), o que deixa a síntese remover os bits sem pino na placa; entradas são amostradas combinacionalmente.

| Endereço | Leitura | Escrita | Na placa |
|---|---|---|---|
| `0x4000_0000` | 0 (somente escrita) | `io_out0` | LEDs `[15:0]` |
| `0x4000_0004` | 0 (somente escrita) | `io_out1` | Display `[15:0]` |
| `0x4000_0008` | 0 (somente escrita) | `io_out2` | Colunas PMOD `[3:0]` |
| `0x4000_000C` | 0 (somente escrita) | `io_out3` | livre |
| `0x4000_0010` | `io_in0` | — | Switches `[15:0]` |
| `0x4000_0014` | `io_in1` | — | Botões `[4:0]` |
| `0x4000_0018` | `io_in2` | — | Linhas PMOD `[3:0]` |
| `0x4000_001C` | `io_in3` | — | livre (lê 0) |

O espaço MMIO é identificado por `addr[31:28] == 4'h4`; o offset do registrador usa `addr[5:2]`. A RAM ocupa os endereços baixos válidos, limitados pela profundidade parametrizada.

## 3. Arquitetura atual

```text
top_core (interface dos pinos da Nexys A7)
└── core (integração do datapath monociclo)
    ├── search ── instruction_memory
    ├── decoder
    │   ├── register_file
    │   ├── imm_gen
    │   └── control_unit
    ├── execution ── alu
    ├── data_memory (RAM + MMIO)
    └── write_back
```

| Bloco | Responsabilidade |
|---|---|
| `top_core` | Inverte `CPU_RESETN` e liga os pinos da placa às entradas e saídas genéricas de 32 bits do core (LEDs, display, PMOD, switches, botões). |
| `core` | Integra PC/busca, decode, execução, memória e write-back; encaminha parâmetros de memória. |
| `search` | Mantém PC, produz `PC+4`, escolhe o próximo PC (reset, sequencial ou destino), lê a memória de instruções com ele e registra PC e instrução na mesma borda. |
| `instruction_memory` | Armazena palavras de instrução e faz leitura combinacional do índice derivado do endereço (o próximo PC). |
| `decoder` | Extrai `rd`, `rs1`, `rs2`; integra banco, imediato e unidade de controle. |
| `control_unit` | Decodifica opcode/funct3/funct7 e gera controles do datapath. |
| `register_file` | Implementa `x1`–`x31`, leituras combinacionais, escrita síncrona e `x0` constante. |
| `imm_gen` | Reconstrói e estende imediatos I, S, B, U e J. |
| `execution` | Seleciona operandos, aciona ALU, calcula o endereço de branch ou salto e decide os branches com um comparador dedicado (`rs1` × `rs2`). |
| `alu` | Aritmética, lógica, comparação (SLT/SLTU), deslocamento e passagem de B. |
| `data_memory` | RAM byte-addressable, loads/stores e periféricos mapeados em memória. |
| `write_back` | Seleciona resultado da ALU ou dado lido da memória. |

### 3.1 Caminho de dados e temporização

Leituras do banco, geração de imediato, lógica de controle, ALU, leitura de RAM/MMIO e seleção de write-back são combinacionais. PC, instrução registrada (ambos no `search`), banco de registradores, RAM e registradores de saída MMIO atualizam na borda positiva do clock. A memória de instruções é lida com o próximo PC, no fim do ciclo anterior, e o `search` registra a instrução na mesma borda que o PC. Assim, cada ciclo começa com a instrução pronta, e o datapath continua executando uma instrução por ciclo, sem estágios. Essa organização foi adotada em 04/11/2026 para tirar a leitura da ROM do início de todos os caminhos (ver `docs/TIMING.md`).

Correspondência com a divisão clássica de módulos (Patterson & Hennessy): a "pc_unit" é o registrador de PC e o mux do próximo PC (PC+4/destino) dentro de `search`; o cálculo do destino (`PC+imm` ou `(rs1+imm) & ~1`) e a decisão de desvio ficam em `execution`. O registrador da instrução lembra o IR do processador multiciclo, mas aqui é atualizado em todo ciclo, junto com o PC.

```text
borda:  [PC] <= próximo PC        [instr] <= instruction_memory[próximo PC]

ciclo:  [instr] --> control_unit --> sinais de controle
          |  \----> imm_gen -------> imm
          \-------> register_file --> rs1, rs2
        execution: mux A/B + ALU ---------------> alu_result
                   comparador rs1 × rs2 --------> branch_taken, pc_branch
                   rs1 + imm (somador próprio) -> endereço --> data_memory (RAM / MMIO) --> dado lido
        write_back: alu_result | dado lido -----> register_file[rd] (na borda)
        próximo PC = reset ? 0 : (branch_taken ? pc_branch : PC+4) --> instruction_memory (lê a ROM)
```

### 3.2 Fluxo de dados por tipo de instrução

| Tipo | Entrada A da ALU | Entrada B da ALU | Operação | Memória | Valor escrito em `rd` | Próximo PC |
|---|---|---|---|---|---|---|
| R (`add`…`and`) | rs1 | rs2 | conforme funct3/funct7 | — | resultado da ALU | PC+4 |
| I aritm. (`addi`…`srai`) | rs1 | imm I | conforme funct3/imm[11:5] | — | resultado da ALU | PC+4 |
| Load (`lb`…`lhu`) | rs1 | imm I | ADD (endereço) | lê, largura/sinal por funct3 | dado da memória | PC+4 |
| Store (`sb`/`sh`/`sw`) | rs1 | imm S | ADD (endereço) | escreve rs2 (byte enables) | — | PC+4 |
| Branch (`beq`…`bgeu`) | rs1 | rs2 | CMP / SLT / SLTU (escolhe a comparação) | — | — | PC+imm B se condição, senão PC+4 |
| `lui` | — | imm U | PASS_B | — | imm U | PC+4 |
| `auipc` | PC | imm U | ADD | — | PC + imm U | PC+4 |
| `jal` | — | PC+4 | PASS_B | — | PC+4 | PC + imm J |
| `jalr` | — | PC+4 | PASS_B | — | PC+4 | (rs1 + imm I) & ~1 |

Nos branches, a condição vem do comparador dedicado da `execution`, que compara `rs1` com `rs2` direto (a ALU não participa). A operação (CMP / SLT / SLTU) só escolhe a comparação: igualdade, menor com sinal ou menor sem sinal. `OP_BCT` desvia com a comparação verdadeira e `OP_BCF` com ela falsa. Assim `beq`=CMP/BCT, `bne`=CMP/BCF, `blt`=SLT/BCT, `bge`=SLT/BCF, `bltu`=SLTU/BCT, `bgeu`=SLTU/BCF.

### 3.3 Tabela de controle (`control_unit`)

A matriz completa de sinais por instrução, os códigos de `alu_op_t`/`branch_op_t`, as interfaces dos módulos e as ligações do `core` estão em [ESPEC_RV32I.md](ESPEC_RV32I.md) (§5 a §8). Este arquivo não repete essas tabelas.

## 4. Decisões refletidas no código

Estas são decisões que podem ser observadas na implementação atual; não há histórico adicional de decisões além do estado deste workspace.

1. **Implementação monociclo:** etapas funcionais estão ligadas em um ciclo, com estado atualizado na borda de subida.
2. **Separação em módulos e packages:** enums de opcode, ALU, branch e memória são centralizados em packages SystemVerilog.
3. **`x0` constante sem célula física:** o array armazena apenas `x1`–`x31`.
4. **Reset limitado ao PC:** o reset leva o próximo PC a 0, e com ele o PC e a instrução registrada voltam ao endereço 0. Banco, RAM e saídas MMIO não são limpos pelo reset; banco e periféricos têm inicialização `initial` em zero.
5. **Memórias inicializadas por arquivo hexadecimal:** `$readmemh` e parâmetros de caminho permitem trocar as imagens.
6. **MMIO dentro da memória de dados:** periféricos compartilham o caminho de load/store através de decodificação de endereço.
7. **Falha de decode sem trap:** instrução não suportada recebe controles padrão e fluxo segue.
8. **Alinhamento de instrução:** instruções são palavras de 32 bits, indexadas com os bits `[1:0]` descartados.
9. **Instrução registrada com o próximo PC (04/11/2026):** a ROM é lida com o próximo PC e a instrução fica num registrador do `search`, atualizado na mesma borda que o PC. Continua monociclo; a leitura da ROM sai do início de todos os caminhos de timing. O registrador fica no `search`, e não dentro da `instruction_memory`, porque dentro dela o Vivado só evitava a BRAM com `rom_style = "distributed"`, que deu ~0,5 ns pior.
10. **Comparador de desvio dedicado (04/11/2026):** os branches comparam `rs1` com `rs2` direto na `execution`, sem os muxes de operando nem a ALU. O próximo PC deixa de esperar a decodificação da operação da ALU.
11. **RAM de dados de 1 KiB (04/11/2026):** a RAM tem 256 palavras, contra 1024 da memória de instruções. Isso reduz o fanout do endereço e tira o mux das 4 faixas de LUTRAM do caminho do load.

## 5. Organização dos arquivos

```text
processador_riscV.xpr
README.md
CLAUDE.md                # guia para o Claude Code
docs/
├── ESPEC_RV32I.md       # spec RV32I alinhada ao RTL (controle, interfaces, ligações)
└── DOCUMENTACAO_PROJETO.md # requisitos, decisões, validação e questões em aberto
scripts/run_tb.ps1       # roda os testbenches no xsim
scripts/build_sw.ps1     # compila sw/apps/<app> com riscv-gcc -> program_bytes.mem / data.mem
sw/
├── common/             # crt0.S, link.ld, mmio.h, libc_min.c
└── apps/               # selftest (autoteste em C, roda no tb_program), leds (demo da placa)
processador_riscV.srcs/
├── sources_1/new/       # RTL SystemVerilog e packages
├── sources_1/imports/new/ # cópias importadas das imagens de memória
├── sim_1/new/           # todos os testbenches
└── constrs_1/imports/constraints/
    └── Nexys-A7-100T-Master.xdc
processador_riscV.runs/  # scripts e resultados gerados pelo Vivado
processador_riscV.sim/   # artefatos gerados de simulação
processador_riscV.cache/ # cache gerado pelo Vivado
processador_riscV.hw/    # estado/artefatos do hardware do Vivado
processador_riscV.ip_user_files/ # arquivos auxiliares de IP/Vivado
```

Arquivos RTL principais em `sources_1/new/`: `top_core.sv`, `core.sv`, `search.sv`, `instruction_memory.sv`, `decoder.sv`, `control_unit.sv`, `register_file.sv`, `imm_gen.sv`, `execution.sv`, `alu.sv`, `data_memory.sv`, `write_back.sv` e packages `alu_pkg.sv`, `branch_pkg.sv`, `func3_pkg.sv`, `func7_pkg.sv`, `mem_pkg.sv`, `opcode_pkg.sv`.

Testbenches em `sim_1/new/`: `tb_core.sv` (sistema completo), `tb_program.sv` (programa C compilado), `tb_alu.sv`, `tb_data_memory.sv`, `tb_decoder.sv`, `tb_execution.sv`, `tb_instruction_fetch.sv`, `tb_register_file.sv`, `tb_control_unit.sv`, `tb_write_back.sv`.

## 6. Convenções observadas no código

- RTL em **SystemVerilog** (`.sv`); interfaces usam `logic` e módulos combinacionais usam `always_comb`/`assign`.
- Estado sequencial usa `always_ff @(posedge clk)`.
- Sufixo `_i` indica entrada e `_o` indica saída; nomes de sinais procuram refletir o bloco proprietário, por exemplo `execution_alu_control_o`.
- Larguras configuráveis são parâmetros inteiros como `XLEN`, `INSTR_MEM_DEPTH` e `DATA_MEM_DEPTH`; enums de controle usam tipos definidos em packages (`alu_op_t`, `branch_op_t`, `mem_width_t`, `mem_signed_t`).
- Imediatos são estendidos conforme formato da instrução; comentário, nomes e documentação predominam em português, ainda que identificadores RTL usem inglês.
- Testbenches aplicam estímulos e comparam resultados com valores esperados, reportando `[PASS]`/`[FAIL]` e contador de falhas.
- Arquivos `.runs`, `.sim`, `.cache` e demais saídas do Vivado são artefatos gerados; RTL em `sources_1/new/` é a referência funcional principal.

## 7. Validação registrada e limites

O repositório contém testbenches dos blocos principais e o testbench de sistema `tb_core`, todos executáveis com `scripts/run_tb.ps1` (9/9 passando em 30/10/2026, xsim 2025.2).

`tb_core` monta no próprio testbench um programa que cobre as 37 instruções do escopo, acessos MMIO de byte/halfword/word e instruções inválidas (`MUL`, `SLLI` com `imm[11:5]` inválido, `JALR` com `funct3 ≠ 000`, `ECALL`, `FENCE`). Ele verifica, instrução a instrução, o registrador destino, a RAM, as saídas MMIO e o próximo PC. Palavras logo após desvios tomados são armadilhas que falham se executadas.

Síntese, implementação e validação física na placa não foram verificadas por esta documentação.

## 8. Decisões de escopo e questões resolvidas

Não há questões em aberto no momento. Os itens abaixo registram o que foi decidido; não são bugs a corrigir.

### 8.1 Fora do escopo por decisão (31/10/2026)

Por enquanto **não serão implementados** traps nem tratamento de desalinhamento. Podem ser revistos no futuro; se forem, exigem CSRs (`mtvec`, `mepc`, `mcause`, `mtval`) e um caminho de exceção no `search`/`execution`.

1. **Traps/exceções:** não há CSRs, interrupções nem traps. `ECALL`, `EBREAK` e `FENCE` executam como NOP. Instruções inválidas ou não suportadas (opcode desconhecido, `funct3`/`funct7` inválidos, extensão M) também viram NOP: não escrevem nada e o PC avança.
2. **Alvo de salto desalinhado:** `execution` zera só o bit 0 do alvo (como a ISA exige para `JALR`). Alvos com bit 1 em 1 não geram `instruction-address-misaligned`; a memória de instruções descarta `addr[1:0]`.
3. **Load/store desalinhado:** halfword/word em endereço não alinhado não é suportado e não gera trap; o resultado é o da seleção de bytes da palavra alinhada. O software deve garantir alinhamento (o GCC já faz isso para dados com tipos naturais).

### 8.2 Resolvidas

1. **Flag `alu_lsb_o` (antes `zero_o`):** era `alu_o[0]`, não uma flag de resultado zero, e servia de condição dos branches. Em 04/11/2026 a condição passou para um comparador dedicado na `execution` (`rs1` × `rs2`, escolhido pelo `alu_op_t` do branch). A porta saiu da ALU, junto com o cálculo do `OP_CMP`.
2. **`SLTU`:** `~carry` de `a + ~b + 1` está correto; coberto por `tb_alu` e `tb_core`.
3. **Faixa da RAM:** vale `addr_i < MEM_DEPTH * 4`, ou seja, até `0x03FF` com a RAM de 1 KiB do core; o comentário do `data_memory` foi corrigido.
4. **Loads/stores MMIO parciais:** byte/halfword em MMIO usam as mesmas lanes e extensão de sinal da RAM (seção 2.3).
5. **Caminhos de memória:** os `.mem` ficam só em `sources_1/imports/new/`; o `$readmemh` resolve caminhos relativos ao diretório de execução.
6. **Reset/estado inicial:** `x1`–`x31` começam em zero por `initial`; o reset leva o próximo PC a 0 (PC = 0 e instrução registrada = palavra 0). Na carga do FPGA, a instrução registrada já nasce com a palavra 0.

## 9. Referência de manutenção

1. Começar por `top_core.sv` e `core.sv` para ver integração e sinais externos.
2. Seguir a instrução por `search` → `decoder` → `execution` → `data_memory`/`write_back` → `register_file`.
3. Consultar packages para os códigos simbólicos e a unidade de controle para as combinações de sinais.
4. Ao atualizar este resumo, conferir sempre o RTL e distinguir comportamento implementado de requisito pretendido.
