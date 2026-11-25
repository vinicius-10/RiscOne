# 06 — HarieshAnbalagan / RV32I (single_cycle_processor)

## Trabalho

- Autor: Hariesh Anbalagan. Projeto hobby/educacional, sem artigo associado.
- GitHub: https://github.com/HarieshAnbalagan/RV32I — commit `35daf6c1bfc4a36af53a1b453eb6ddbf6e575f26` (clone raso, 2026-09-06).
- Licença: GPL-3.0-only.
- O autor não publica números de síntese.

## Núcleo

- **Monociclo (CPI = 1), confirmado:** o único registrador do núcleo é o PC (`always_ff @(posedge clk, posedge reset)`).
  A IMEM e a leitura da DMEM são combinacionais, e a instrução não é registrada. Medido só `src/single_cycle_processor/`
  (o repositório também tem um multiciclo/pipeline em outra pasta, que ficou de fora).
- ISA: RV32I sem CSRs. FENCE e ECALL/EBREAK são NOPs. Tem um `ComparatorUnit` dedicado para desvios e SLT/SLTU, separado da ALU,
  como no núcleo do TCC. O JALR não zera o bit 0 do alvo.
- Loads e stores de byte/meia palavra são **simplificados**:
  - a `LoadAndStoreUnit` só estende o byte/halfword baixo da palavra, sem deslocar por `addr[1:0]`;
  - o strobe de escrita é gerado, mas a `DataMemory` o ignora (escreve a palavra inteira);
  - a `DataMemory` indexa `data[address_i]` com o **endereço de byte usado direto como índice de palavra** (`address_i[31:0]`).
- HDL: SystemVerilog (pacote `risc_v_32_i_pkg.sv`).
- Memórias do autor (tamanhos mantidos):
  - IMEM: 64 palavras (256 B), ROM combinacional, sintetizada em LUTs.
  - DMEM: 64 palavras (256 B), leitura assíncrona e escrita na borda de subida, sintetizada em LUTRAM (32 LUTs, RAMS64E).
- Banco de registradores: 32×32 com 2 leituras assíncronas, em LUTRAM (44 LUTs). **A escrita é na borda de descida**
  (`always_ff @(negedge clk)`).
- Reset: assíncrono, ativo alto, só no PC. Não há periféricos nem MMIO.

## Montagem

- O `tb/top.sv` do repositório é testbench (e com portas do multiciclo), então foi escrito `wrapper/top_cmp.sv`:
  - instancia `ProcessorCore`, `InstructionMemory` e `DataMemory` do autor, com o clock de 100 MHz direto;
  - `reset_i = ~CPU_RESETN`;
  - `led[15:0]` é um registrador carregado com `write_data[15:0]` quando há store (opção b das instruções).
- XDC: `comparacao/scripts/base.xdc` sem as chaves (o wrapper não tem `switch`).
- Programa: `autoteste_placa` (`prog_word.hex`) **truncado nas 64 primeiras instruções** (de 389), porque a IMEM do autor tem
  64 palavras.
  - Esse trecho usa só 14 das 33 combinações opcode/funct3 do programa completo. Faltam, entre outras, LUI, SLT/SLTU, os shifts,
    XOR/OR e boa parte dos desvios.
  - O decodificador continua inteiro (a ROM não é constante), mas a lógica que depende do conteúdo da ROM muda.
  - O programa foi gravado como `mem/L_S_type.txt`, o nome que o `$readmemh` do autor já usa.
  - Os dados (`data_word.hex`, 17 palavras) foram gravados como `mem/Data_Memory_Load.txt`.
  - O programa **não roda corretamente** neste núcleo: além do truncamento, a DMEM é indexada por byte e os loads e stores
    de byte/meia palavra são simplificados. Isso não importa para a medição de área e timing.
- Mudanças no RTL (cópias em `patch/`, só para sintetizar):
  1. `ProcessorCore.sv`: a instância de `ComparatorUnit` usava a porta inexistente `.branch_o`, trocada por `.comp_o`
     (erro de elaboração no Vivado).
  2. `InstructionMemory.sv`, `DataMemory.sv` e `RegisterFile.sv`: removida a palavra `assign` de dentro de `always_comb`.
     O Vivado rejeita o assign procedural (`[Synth 8-27] procedural assign not supported`), e a semântica é a mesma.
- Ficou de fora: nada além do testbench (o autor não tem periféricos).

## Resultados (`-Final`, `build/final/resumo.txt`)

```
Tempo total 118,9 s | synth 46 s | opt 7 s | place 30 s | route 24 s | pico 2052 MB
WNS -7,721 ns | TNS -983,459 ns | endpoints violando 310/924 | WHS 0,476 ns | THS 0
Fmax (script, 1000/(10-WNS)) 56,4 MHz
Caminho crítico 12,227 ns (lógica 2,198 / rota 10,029), 12 níveis (LUT2=1 LUT4=2 LUT5=2 LUT6=5 RAMD32=1 RAMS64E=1)
  de PrCore/PC_reg[4]/C (subida) para PrCore/regfile/register_reg_r2_0_31_18_23/RAMC/I (DESCIDA), requisito 5 ns
LUTs 867 (lógica 791, LUTRAM 76) | FFs 48 | F7 0 | F8 0 | CARRY4 42 | Slices 261 | BRAM 0 | DSP 0 | IOB 18
Potência total 0,132 W | dinâmica 0,035 W | estática 0,097 W | Tj 25,6 C | confiança Medium
Warnings 36 | critical warnings 0 | latches 0
```

- Hierarquia (`util_hier.rpt`): PrCore 834 LUTs, regfile 729 (inclui lógica absorvida do decodificador, do imediato e dos muxes,
  já que a hierarquia foi achatada em parte), ALU 61, topo 16 FFs (LEDs). As FFs são 32 do PC e 16 dos LEDs.
  Não houve poda do núcleo.
- **Atenção à Fmax:** o caminho crítico termina na escrita do banco de registradores, que é na borda de **descida**, então o
  requisito é de meio período (5 ns). A fórmula `1000/(10 − WNS)` do script supõe ciclo inteiro e dá 56,4 MHz, o que superestima.
  Com duty de 50 %, o período mínimo é 2 × (5 + 7,721) = 25,44 ns, o que dá uma **Fmax real de cerca de 39,3 MHz**.
- O `medir.ps1` sai com código 1 quando WNS < 0. É o comportamento previsto (linha `exit [int]($wns -lt 0)`), não falha.

## Números publicados × medidos

O autor não publica números de síntese, então não há com o que comparar.

## Observações para a comparação

- As memórias são bem menores que as do TCC: IMEM de 256 B contra 4 KiB e DMEM de 256 B contra 1 KiB. A ROM menor reduz LUTs e
  atraso no caminho PC → instrução.
- O programa ficou truncado em 64 instruções (14 de 33 formas de instrução).
- A escrita do banco de registradores na borda de descida cria um caminho de meio ciclo. Por isso a Fmax comparável é
  cerca de 39 MHz, e não 56,4 MHz.
- Não há MMIO/periféricos e os loads/stores de byte/meia palavra são simplificados. Isso dá menos lógica que o núcleo do TCC
  (que tem alinhamento por byte e MMIO).
- `reg_data` tem `default` = `'z` (tristate interno); o Vivado o resolveu sem latch.
