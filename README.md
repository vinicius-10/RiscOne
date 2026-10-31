# Processador RV32I — resumo do projeto

## Identidade

- **Tipo:** implementação didática de um processador RISC-V RV32I monociclo em SystemVerilog.
- **Placa-alvo:** Digilent Nexys A7-100T, FPGA Artix-7 `xc7a100tcsg324-1`.
- **Ferramenta do projeto:** Vivado 2025.2 (`processador_riscV.xpr`).
- **Top de implementação:** `top_core`.
- **Idioma predominante dos comentários:** português.

## Objetivo e comportamento

O projeto integra busca, decodificação, execução, acesso à memória e write-back em um datapath RV32I. O PC avança normalmente em 4 bytes ou recebe o destino de um desvio/salto. O core também conecta memória de dados a periféricos mapeados em memória (MMIO): switches, botões, LEDs, display de sete segmentos e linhas/colunas PMOD para teclado matricial.

O estado do PC, as escritas no banco de registradores e as escritas na RAM/MMIO são atualizados na borda de subida do clock. A leitura de instrução, operandos, RAM e entradas MMIO é combinacional.

## Arquitetura

```text
top_core (pinos da Nexys A7)
└── core (integração do datapath)
    ├── search ── instruction_memory
    ├── decoder
    │   ├── register_file
    │   ├── imm_gen
    │   └── control_unit
    ├── execution ── alu
    ├── data_memory (RAM + MMIO)
    └── write_back
```

### Responsabilidade dos módulos

| Módulo | Papel |
|---|---|
| `top_core` | Liga clock, reset, switches, botões, LEDs, display e sinais PMOD da placa ao core. |
| `core` | Conecta os estágios funcionais e distribui dados e controles. Parâmetros incluem largura, profundidade e arquivos de inicialização das memórias. |
| `search` | Mantém o PC, calcula `PC+4`, escolhe entre avanço sequencial e destino de desvio, e consulta a memória de instruções. |
| `instruction_memory` | Memória de instruções com leitura combinacional e inicialização por `$readmemh`; endereço é de byte e os bits baixos selecionam palavra alinhada. |
| `decoder` | Extrai campos `rd`, `rs1`, `rs2`, instancia o banco de registradores, o gerador de imediatos e a unidade de controle. |
| `control_unit` | Decodifica opcode/funct3/funct7 e gera controles da ALU, branches, memória, PC e write-back. |
| `register_file` | 32 registradores arquiteturais; `x0` é constante zero, duas leituras combinacionais e uma escrita síncrona. Não tem reset. |
| `imm_gen` | Monta e estende imediatos nos formatos I, S, B, U e J. |
| `execution` | Seleciona operandos da ALU, calcula resultado e destino/decisão de branch ou salto. |
| `alu` | Soma/subtração, lógica, comparação, deslocamentos e passagem do operando B. |
| `data_memory` | RAM byte-addressable, loads/stores de byte/halfword/word, extensão de sinal e MMIO. |
| `write_back` | Seleciona resultado da ALU ou dado da memória para gravar no banco de registradores. |

## ISA e operações declaradas

- **Inteiro registrador-registrador:** ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND.
- **Inteiro imediato:** ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI.
- **Loads:** LB, LH, LW, LBU, LHU.
- **Stores:** SB, SH, SW.
- **Branches:** BEQ, BNE, BLT, BGE, BLTU, BGEU.
- **Outras:** LUI, AUIPC, JAL, JALR.
- Opcode não suportado mantém controles padrão sem escrita em registrador/memória; o PC segue habilitado para avançar.

## Memórias e mapa MMIO

- Profundidade padrão de ambas as memórias: **1024 palavras**.
- Memória de instruções: `program_bytes.mem`.
- Memória de dados: `data.mem`.
- RAM de dados ocupa endereços baixos até `MEM_DEPTH * 4 - 1` (padrão: `0x0000_0FFF`). A organização interna é por bytes agrupados em palavras.
- Espaço MMIO é reconhecido quando `addr[31:28] == 4'h4` (base `0x4000_0000`); o offset do registrador vem de `addr[5:2]`.

| Endereço base | Leitura | Escrita |
|---|---|---|
| `0x4000_0000` | Estado dos LEDs | Atualiza LEDs `[15:0]` |
| `0x4000_0004` | Switches `[15:0]` | — |
| `0x4000_0008` | Botões `[4:0]` | — |
| `0x4000_000C` | Estado do display | Atualiza display `[15:0]` |
| `0x4000_0010` | Linhas PMOD `[3:0]` | Atualiza colunas PMOD `[3:0]` |

As saídas MMIO são inicializadas em zero no bloco `initial`; entradas vêm diretamente dos pinos. Os arquivos de memória são carregados por `$readmemh` e ficam somente em `processador_riscV.srcs/sources_1/imports/new/` (cópia referenciada pelo projeto Vivado).

## Organização dos arquivos

- `processador_riscV.srcs/sources_1/new/`: RTL SystemVerilog e packages (`alu_pkg`, `branch_pkg`, `func3_pkg`, `func7_pkg`, `mem_pkg`, `opcode_pkg`).
- `processador_riscV.srcs/sim_1/new/`: testbenches de ALU, controle, memória, decoder, execução, busca, banco de registradores, write-back, sistema (`tb_core`) e programa C (`tb_program`).
- `processador_riscV.srcs/constrs_1/imports/constraints/Nexys-A7-100T-Master.xdc`: constraints da placa.
- `processador_riscV.runs/`: scripts e artefatos gerados de síntese/implementação. São saídas do Vivado, não a fonte principal do comportamento.
- `control_unit.tex` e `Texto_colado_corrigido.tex`: documentos LaTeX relacionados ao projeto; a descrição funcional principal também está nos comentários dos módulos RTL.

## Testes e evidência disponível

Há testbenches separados para os principais blocos (`tb_alu`, `tb_control_unit`, `tb_data_memory`, `tb_decoder`, `tb_execution`, `tb_instruction_fetch`, `tb_register_file`, `tb_write_back`). Há também o testbench de sistema `tb_core`, que executa no core um programa cobrindo as 37 instruções RV32I do escopo, MMIO e instruções inválidas, verificando cada instrução. Todos rodam com `scripts/run_tb.ps1` (9/9 passando em 30/10/2026). Síntese e validação na placa não foram verificadas.

## Pontos de atenção para manutenção

1. **Condição de branch depende do bit menos significativo:** `alu.alu_lsb_o` é `alu_o[0]` (bit 0 do resultado, não uma flag de zero). O controle usa `OP_CMP` (igualdade) para BEQ/BNE e SLT/SLTU para branches relacionais, então a decisão atual depende do LSB dos resultados de comparação. Alterações na codificação dessas operações devem preservar essa convenção ou substituir por flags explícitas.
2. **Alinhamento de destino:** `execution` zera somente o bit 0 do endereço de branch/jump. Imediatos B/J já incluem bit 0 zero; a implementação não zera explicitamente os bits `[1:0]`.
3. **Reset:** `CPU_RESETN` é ativo baixo na placa e invertido em `core`; o reset encaminhado a `search` é síncrono ativo alto e reinicia apenas o PC. Banco de registradores e RAM não são limpos pelo reset (o banco começa em zero por `initial`).
4. **Instruções inválidas/não suportadas:** a unidade de controle não sinaliza exceção/trap. A decodificação é estrita: opcodes desconhecidos e codificações inválidas (ex.: `funct7` da extensão M, `JALR` com `funct3 ≠ 000`) não escrevem nada e o fluxo sequencial continua.
5. **MMIO e acessos parciais:** a decodificação de MMIO usa `addr[5:2]` para escolher o registrador; byte/halfword usam a mesma seleção de bytes e extensão de sinal da RAM (`SB`/`SH` alteram só os bytes endereçados).
6. **Validação de hardware:** este documento descreve a RTL e a configuração encontrada no projeto. Não afirma que bitstream foi gerado nem que o comportamento foi validado na placa.

## Referência rápida para agentes de LLM

- Fonte de verdade funcional: `processador_riscV.srcs/sources_1/new/*.sv`.
- Começar leitura em: `top_core.sv` → `core.sv` → módulos do datapath.
- ISA-alvo: subconjunto descrito acima, em execução monociclo.
- Board/top configurados: Nexys A7-100T / `top_core`.
- Inicialização: `program_bytes.mem` e `data.mem`, via `$readmemh`.
- Tratar comentários de cabeçalho como documentação contextual; confirmar detalhes sensíveis diretamente na lógica SystemVerilog.
