# 08 — cdlavila / Paula Jr. & Della Colleta

## Trabalho

- **Repositório (RTL medido):** Carlos Daniel Londoño Avila (cdlavila), *Unicycle-Processor-RISC-V-RV32I*,
  projeto final da disciplina Arquitectura de Computadores (Prof. José Jaramillo, Universidad
  Tecnológica de Pereira), 2021. <https://github.com/cdlavila/unicycle-processor-risc-v-rv32i>,
  commit `8abdd2d414f32a8d84da491a6cfbe61a6ec9e816` (2021-08-18), licença MIT.
- **Artigo que adapta esse projeto como base:** Paula Jr. & Della Colleta, "Estudo e desenvolvimento
  de uma microarquitetura RISC-V baseado no ISA RV32I", Anais de Iniciação Científica da UNIFEI,
  VII Simpósio (2024/2025), DOI 10.29327/1626690.7-92. Alvo: Intel MAX 10; o artigo não publica
  números de área ou frequência. **O repositório não é dos autores do artigo.** O que se mede aqui é
  o RTL original do repositório, não a versão adaptada do artigo, que não está publicada.

## Núcleo

- **Microarquitetura:** monociclo de verdade (CPI = 1). Só o PC (`ProgramCounter`, `posedge clk`) e a
  escrita do banco de registradores são síncronos. IMEM e DMEM têm leitura combinacional, e a
  escrita da DMEM é **combinacional** (`always @(*)`, sensível a nível, sem clock).
- **HDL:** SystemVerilog, 13 módulos e o top `UnicycleProcessorRISCV` (`design.sv`, com `` `include ``).
- **IMEM:** `logic [7:0] Memory[1024]` = **1 KiB (256 instruções)**, inicializada por `$readmemh`, com
  bytes em ordem **big-endian** dentro da palavra (`{M[A], M[A+1], M[A+2], M[A+3]}`). Virou lógica (ROM em LUTs).
- **DMEM:** `logic [7:0] Memory[1024]` = **1 KiB**, endereçada por byte, com escrita combinacional. A síntese
  inferiu **8192 latches** (DataMemory: 8192 "FFs" = latches, 6558 LUTs). O Vivado avisa:
  "Non-clocked latch", 8214 pinos sem restrição de max delay. **Os caminhos de escrita na DMEM
  não são cronometrados**, então a Fmax medida não cobre a escrita da memória.
- **Banco de registradores:** `Matrix[32]` com 2 leituras assíncronas e escrita síncrona, em
  **LUTRAM** (48 LUTRAM), inicializado por `$readmemb("Registers.txt")`, que vem todo em zero.
- **Reset:** não existe. O PC parte de 0 pelo valor inicial da declaração.
- **Periféricos/MMIO:** nenhum (o top só tem `clk`).
- **ISA:** declara RV32I, mas sem FENCE/ECALL/EBREAK/CSR. Pela leitura do RTL (não simulado), há divergências
  que fazem o núcleo **não executar o RV32I corretamente**. Registradas sem correção:
  - `ControlUnit` sem `default` → latches nos sinais de controle para opcodes não tratados.
    Os opcodes de FENCE/SYSTEM aparecem no programa; a lógica de controle virou 20 mil LUTs, ver abaixo.
  - JALR com `RUWr = 0`: não grava o endereço de retorno em `rd`.
  - Imediato U = `{{11{I[31]}}, I[31:12], 1'b0}` (deslocado em 1, não em 12) → LUI/AUIPC erradas.
  - Leitura de palavra na DMEM usa `Memory[Address+3]` duas vezes (perde o byte 2).
  - Operandos `logic` sem sinal → SLT/SLTI/BLT/BGE comparam sem sinal, e `>>>` vira deslocamento lógico.
  - Deslocamentos usam o `B` inteiro (não `B[4:0]`) → SRAI (imediato 0x40x) devolve 0.
  - O IMEM big-endian é só o formato do arquivo do autor; o programa foi convertido para ele.

## Montagem

- **Top:** `wrapper/top_cmp.sv` (portas `clk`, `CPU_RESETN`, `led[15:0]`) instancia o núcleo direto
  no clock de 100 MHz. `CPU_RESETN` fica sem uso porque o núcleo não tem reset.
  LEDs = registrador de 16 bits carregado com o dado de store (`if (DMWr) led <= B[15:0]`), opção b das instruções.
- **Mudanças no RTL** (só `patch/design.sv`, uma cópia de `repo/design.sv`):
  1. Duas portas de saída acrescentadas ao top do núcleo (`DMWr_o = DMWr`, `DataWr_o = B`), sem
     mudança no datapath, para o wrapper observar o store.
  2. Linhas `` `include `` comentadas, com os 13 arquivos listados no `config.psd1`. Motivo: o
     `medir.ps1` passa `-include_dirs` ao `read_verilog`, e o Vivado 2025.2 não aceita essa opção
     (`ERROR: [Common 17-170] Unknown option '-include_dirs'`). Esse bug do `medir.ps1` está relatado ao coordenador.
  O resto do repositório foi usado sem alteração.
- **Programa:** `autoteste_placa` convertido por `scripts/converte.py` → `mem/Instructions.txt`
  (4 bytes big-endian por linha, **truncado em 256 das 389 instruções**, porque a IMEM tem 1 KiB) e
  `mem/Memory.txt` (68 bytes de dados + zeros até 1024 B, little-endian como a DMEM do autor).
  `repo/Registers.txt` foi usado como está. Com as divergências de ISA acima, o programa não roda
  corretamente, mas serve para a síntese otimizar a lógica para o conteúdo da ROM.
- **Restrições:** `constr.xdc` = `base.xdc` sem as chaves (não usadas).
- **Tempo limite:** a primeira `-Final` estourou o limite padrão de 60 min do `medir.ps1` no
  `route_design`. Ela foi repetida com `-TimeoutMin 240` (parâmetro do script, sem editá-lo) e o roteamento
  terminou com falha por congestionamento (ver Resultados).

## Resultados (`-Final`)

**A implementação NÃO concluiu: o design não é roteável no xc7a100t com as diretivas padrão.**
Na `-Final` (exclusiva, `-TimeoutMin 240`), os tempos foram: synth_design 6 min 32 s, opt_design 10 s,
place_design 1 min 54 s e **route_design 2 h 04 min 18 s** (CPU 12 h 55 min). Terminou com:

```
CRITICAL WARNING: [Route 35-162] 2903 signals failed to route due to routing congestion.
ERROR: [Route 35-2] Design is not legally routed. There are 2281 node overlaps.
```

Congestionamento efetivo nível 4–5. Pico de memória: 3179 MB. Como o `route_design` falhou, o
`medir.ps1` não gerou relatórios de implementação nem linha em `resultados.csv` (`build/final/` só
tem o `vivado.log`). A primeira tentativa, com o limite padrão de 60 min, estourou o tempo no roteamento.

Os números disponíveis são **só os da síntese** (`-SynthOnly`, `build/synth/resumo.txt`, estimativa pós-síntese):

```
cdlavila - unicycle-processor-risc-v-rv32i  |  tag synth  |  synth  |  472.8 s  |  pico 3188.375 MB
Timing: periodo 10 ns | WNS -7,995 | TNS -666,229 | violando 115/659 | WHS 0,366 | THS 0 | Fmax 55,6 MHz
Caminho critico: 17,566 ns (logica 4,648 / rota 12,918) niveis 22 (LUT2=2 LUT5=2 LUT6=11 MUXF7=4 MUXF8=2 RAMD32=1)
   de:   core/PC/Address_reg[3]_rep/C
   para: core/RU/Matrix_reg_r1_0_31_30_31/DP/I
Area: LUTs 32610 (logica 32562, LUTRAM 48) | FFs 8277 | latches 8214 | F7 4012 | F8 1710 | CARRY4 38 | Slices 0 | BRAM 0 | DSP 0 | IOB 17
Potencia: total 0,884 W | dinamica 0,784 W | estatica 0,1 W | Tj 29 C | confianca Low
Etapas: synth_design 00:07:09 | report_power 00:00:09
Warnings 115 | CRITICAL 0 | latches(log) 101 | pinos sem restricao de max delay: 8214 | regs sem clock: True
   TIMING-16 [Warning] Large setup violation: 115
   TIMING-18 [Warning] Missing input or output delay: 16
   TIMING-20 [Warning] Non-clocked latch: 1000
   LATCH-1 [Advisory] Existing latches in the design: 1
```

Hierarquia pós-síntese (`util_hier.rpt`): ControlUnit 20164 LUTs (+22 latches); DataMemory 6558 LUTs
+ 8192 latches; RegistersUnit 4882 LUTs (48 LUTRAM); ProgramCounter 982 LUTs (47 FFs, com réplicas);
wrapper 16 FFs (LEDs). Ficam de 32,6 a 33 mil LUTs, cerca de 51 % do xc7a100t (63.400 LUTs).
O congestionamento vem das 8192 latches da DMEM com multiplexação por byte (quatro portas de
leitura e quatro de escrita, com endereços `Address`, `Address+1`, `+2` e `+3`).

## Números publicados × medidos

Nem o artigo (MAX 10) nem o repositório publicam área ou frequência, então não há com o que comparar.

## Observações para a comparação

- **Não roteável:** não há números pós-implementação. Se entrar na tabela, use os números da síntese
  marcados como "pós-síntese, implementação falhou por congestionamento".
- **DMEM em latches (8192) com escrita combinacional:** a área fica muito inflada e os caminhos de
  escrita não são cronometrados. A Fmax só vale para os caminhos de registrador (PC → banco de registradores).
- **A lógica de controle ocupa 20 mil LUTs** (`ControlUnit` sem `default` + latches de controle +
  decodificação das enables das 8192 latches da DMEM, que a síntese agrupou na hierarquia de `CU`).
- **IMEM de 1 KiB:** o programa foi truncado em 256 instruções.
- **O núcleo não executa o RV32I corretamente** (JALR, LUI/AUIPC, LW, comparações com sinal, SRA/SRAI).
  É um trabalho de disciplina. Na tabela, convém marcar "ISA incompleta/incorreta".
- Não tem reset nem periféricos.
