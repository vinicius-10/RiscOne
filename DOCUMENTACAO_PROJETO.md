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

Opcode não reconhecido não gera escrita em registrador ou memória nem exceção/trap; o PC continua pelo caminho sequencial conforme o controle padrão.

### 2.2 Registradores e estado

- Banco arquitetural de 32 registradores, com `x0` sempre lido como zero e escrita em `x0` descartada.
- Duas portas de leitura combinacional e uma porta de escrita síncrona.
- O banco não tem reset; `x1`–`x31` não têm valor definido até que sejam escritos.
- O reset ativo baixo da placa é invertido para gerar reset síncrono ativo alto do PC. O reset zera somente o PC.

### 2.3 Memórias

- Memória de instruções de leitura combinacional, inicializada com `$readmemh`.
- Memória de dados organizada como bytes, com leitura combinacional e escrita na borda de subida.
- Acesso à RAM suporta byte, halfword e word; loads suportam extensão com ou sem sinal.
- Profundidade padrão declarada pelo core: 1024 palavras para cada memória.
- Arquivos configurados no core: `program_bytes.mem` e `data.mem`.

### 2.4 Entradas e saídas da placa

O top conecta switches, cinco botões, LEDs, display de sete segmentos e pinos PMOD. A memória de dados expõe esses periféricos via MMIO. As saídas de periférico são registradores inicializados em zero e atualizados sincronamente; entradas são amostradas combinacionalmente.

| Endereço | Leitura | Escrita |
|---|---|---|
| `0x4000_0000` | Estado dos LEDs | LEDs `[15:0]` |
| `0x4000_0004` | Switches `[15:0]` | — |
| `0x4000_0008` | Botões `[4:0]` | — |
| `0x4000_000C` | Estado do display `[15:0]` | Display `[15:0]` |
| `0x4000_0010` | Linhas PMOD `[3:0]` | Colunas PMOD `[3:0]` |

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
| `top_core` | Traduz os pinos da placa para os sinais do core e retorna LEDs, display e PMOD. |
| `core` | Integra PC/busca, decode, execução, memória e write-back; encaminha parâmetros de memória. |
| `search` | Mantém PC, produz `PC+4`, escolhe PC sequencial ou destino e consulta instrução. |
| `instruction_memory` | Armazena palavras de instrução e faz leitura combinacional do índice derivado do endereço. |
| `decoder` | Extrai `rd`, `rs1`, `rs2`; integra banco, imediato e unidade de controle. |
| `control_unit` | Decodifica opcode/funct3/funct7 e gera controles do datapath. |
| `register_file` | Implementa `x1`–`x31`, leituras combinacionais, escrita síncrona e `x0` constante. |
| `imm_gen` | Reconstrói e estende imediatos I, S, B, U e J. |
| `execution` | Seleciona operandos, aciona ALU e calcula decisão/endereço de branch ou salto. |
| `alu` | Aritmética, lógica, comparação, deslocamento e passagem de B. |
| `data_memory` | RAM byte-addressable, loads/stores e periféricos mapeados em memória. |
| `write_back` | Seleciona resultado da ALU ou dado lido da memória. |

### 3.1 Caminho de dados e temporização

Busca de instrução, leituras do banco, geração de imediato, lógica de controle, ALU, leitura de RAM/MMIO e seleção de write-back são combinacionais. PC, banco de registradores, RAM e registradores de saída MMIO atualizam na borda positiva do clock. Assim, o datapath executa uma instrução por ciclo conforme o estado combinacional entre bordas.

## 4. Decisões refletidas no código

Estas são decisões que podem ser observadas na implementação atual; não há histórico adicional de decisões além do estado deste workspace.

1. **Implementação monociclo:** etapas funcionais estão ligadas em um ciclo, com estado atualizado na borda de subida.
2. **Separação em módulos e packages:** enums de opcode, ALU, branch e memória são centralizados em packages SystemVerilog.
3. **`x0` constante sem célula física:** o array armazena apenas `x1`–`x31`.
4. **Reset limitado ao PC:** banco, RAM e saídas MMIO não são limpos pelo reset; periféricos têm inicialização `initial`.
5. **Memórias inicializadas por arquivo hexadecimal:** `$readmemh` e parâmetros de caminho permitem trocar as imagens.
6. **MMIO dentro da memória de dados:** periféricos compartilham o caminho de load/store através de decodificação de endereço.
7. **Falha de decode sem trap:** instrução não suportada recebe controles padrão e fluxo segue.
8. **Alinhamento de instrução:** instruções são palavras de 32 bits, indexadas com os bits `[1:0]` descartados.

## 5. Organização dos arquivos

```text
processador_riscV.xpr
README.md
DOCUMENTACAO_PROJETO.md
control_unit.tex
Texto_colado_corrigido.tex
processador_riscV.srcs/
├── sources_1/new/       # RTL SystemVerilog e packages
├── sources_1/imports/new/ # cópias importadas das imagens de memória
├── sim_1/new/           # testbenches e imagens de memória de simulação
├── sim_1/imports/new/   # cópias importadas de testbench
└── constrs_1/imports/constraints/
    └── Nexys-A7-100T-Master.xdc
processador_riscV.runs/  # scripts e resultados gerados pelo Vivado
processador_riscV.sim/   # artefatos gerados de simulação
processador_riscV.cache/ # cache gerado pelo Vivado
processador_riscV.hw/    # estado/artefatos do hardware do Vivado
processador_riscV.ip_user_files/ # arquivos auxiliares de IP/Vivado
```

Arquivos RTL principais em `sources_1/new/`: `top_core.sv`, `core.sv`, `search.sv`, `instruction_memory.sv`, `decoder.sv`, `control_unit.sv`, `register_file.sv`, `imm_gen.sv`, `execution.sv`, `alu.sv`, `data_memory.sv`, `write_back.sv` e packages `alu_pkg.sv`, `branch_pkg.sv`, `func3_pkg.sv`, `func7_pkg.sv`, `mem_pkg.sv`, `opcode_pkg.sv`.

Testbenches em `sim_1/new/`: `tb_alu.sv`, `tb_control_unit.sv`, `tb_data_memory.sv`, `tb_decoder.sv`, `tb_execution.sv`, `tb_instruction_fetch.sv`, `tb_register_file.sv`, `tb_write_back.sv`.

## 6. Convenções observadas no código

- RTL em **SystemVerilog** (`.sv`); interfaces usam `logic` e módulos combinacionais usam `always_comb`/`assign`.
- Estado sequencial usa `always_ff @(posedge clk)`.
- Sufixo `_i` indica entrada e `_o` indica saída; nomes de sinais procuram refletir o bloco proprietário, por exemplo `execution_alu_control_o`.
- Larguras configuráveis são parâmetros inteiros como `XLEN` e `MEM_DEPTH`; enums de controle usam tipos definidos em packages (`alu_op_t`, `branch_op_t`, `mem_width_t`, `mem_signed_t`).
- Imediatos são estendidos conforme formato da instrução; comentário, nomes e documentação predominam em português, ainda que identificadores RTL usem inglês.
- Testbenches aplicam estímulos e comparam resultados com valores esperados, reportando `[PASS]`/`[FAIL]` e contador de falhas.
- Arquivos `.runs`, `.sim`, `.cache` e demais saídas do Vivado são artefatos gerados; RTL em `sources_1/new/` é a referência funcional principal.

## 7. Validação registrada e limites

O repositório contém testbenches dos blocos principais e resultados/artefatos gerados pelo Vivado. A simples presença desses arquivos não prova que as simulações ou síntese atuais passaram. Esta documentação não executou simulação, síntese ou validação física na placa e não afirma que um bitstream funcional foi carregado.

## 8. Questões em aberto e divergências a confirmar

1. **Flag `zero_o`:** o nome sugere zero, mas a implementação atribui `alu_o[0]`. A ALU retorna comparações como `0` ou `1`; portanto branches consomem esse bit como condição. Deve-se preservar ou substituir por flags explícitas segundo a intenção do projeto.
2. **`SLTU`:** `cmp_sltu` vem do carry de uma subtração sem sinal, enquanto a condição padrão `a < b` costuma corresponder ao borrow. Confirmar com a intenção funcional e os vetores de teste.
3. **Alinhamento do destino:** `execution` limpa apenas o bit 0 (`& ~32'd1`), não os bits `[1:0]`. Imediatos B/J codificam bit 0 como zero; `JALR` pela ISA também requer limpeza do bit 0, mas o alinhamento final depende do endereço e da plataforma.
4. **Endereços da RAM:** comentário de `data_memory` cita faixa até `0x3FFF`, mas a validação efetiva usa `addr_i < MEM_DEPTH * 4` (4096 bytes com parâmetros padrão, até `0x0FFF`). A lógica é que vale.
5. **Loads/stores MMIO parciais:** saídas de periférico recebem campos baixos do dado e a leitura MMIO retorna palavra; verificar a semântica desejada para acessos de byte/halfword em MMIO.
6. **Parâmetros/caminhos de memória:** `core` usa defaults `.mem`, enquanto alguns cabeçalhos/comentários de `search`/`instruction_memory` mencionam `.hex`. As cópias atuais `.mem` estão em `sources_1/imports/new/` e `sim_1/new/`; resolver caminhos do `$readmemh` depende do diretório de execução/configuração do Vivado.
7. **Reset/estado inicial:** `x1`–`x31` não inicializados podem aparecer como `X` até serem escritos; apenas PC e saídas MMIO têm inicialização/reset descritos acima.
8. **Traps e instruções de sistema/barreira:** os opcodes aparecem no package, mas isso não significa implementação da classe; a unidade de controle declara apenas o subconjunto da seção 2.

## 9. Referência de manutenção

1. Começar por `top_core.sv` e `core.sv` para ver integração e sinais externos.
2. Seguir a instrução por `search` → `decoder` → `execution` → `data_memory`/`write_back` → `register_file`.
3. Consultar packages para os códigos simbólicos e a unidade de controle para as combinações de sinais.
4. Ao atualizar este resumo, conferir sempre o RTL e distinguir comportamento implementado de requisito pretendido.
