# 10_semi_edge — El-Helwani & Khalid (Semi-Edge RISC-V)

## Trabalho

- Autores: El-Helwani & Khalid — "LLM-Aided Design and Evaluation of a RISC-V Processor",
  IEEE Access, 2026, DOI 10.1109/ACCESS.2026.3705296.
- Repositório: https://github.com/majidale/Semi-Edge-RISC-V (canal "Semi Edge", material de
  tutorial). Commit clonado: `55039c5ee3503d1a5261951fe56438e9dbd312a8` (2025-09-16).
- Licença: **nenhuma** (sem arquivo LICENSE; a API do GitHub retorna `license: null`).
- Conteúdo: só o núcleo de referência, num único arquivo
  `RISCV_Single_Cycle/RISCV_Single_Cycle_Core.v` (+ `program.hex` de 47 palavras, programa em
  assembly, imagens e PDFs do livro/especificação). **As variantes geradas por LLM citadas no
  artigo NÃO estão no repositório** — nada a listar.

## Núcleo

- Microarquitetura: **monociclo** (CPI = 1). PC é o único registrador do caminho de controle;
  ROM de instruções de leitura combinacional (`assign instruction_out = Mem_Array[...]`),
  leitura da DMEM combinacional, escrita síncrona. Sem estágios.
- HDL: Verilog-2001. Um único clock, borda de subida. Reset síncrono ativo alto (`rst`).
- ISA: o README diz "todas as instruções RV32I" (37 listadas, sem FENCE/ECALL/EBREAK/CSR), mas
  pela leitura do RTL **a implementação está incompleta/incorreta** (é resultado, não consertei):
  - desvios: `pc_src = Branch & zero_flag` para os seis desvios — BNE, BLT, BGE, BLTU, BGEU
    não funcionam (BLT/BLTU desviam quando a comparação é *falsa*; BNE se comporta como BEQ);
  - JAL/JALR: o valor `PC+4` é calculado (`final_wb`) mas **não é ligado** ao banco de
    registradores (que recebe `wb_data`); JAL grava `rs1+rs2` (campos do imediato) em `rd`;
  - AUIPC: a ALU soma `rs1` + imediato (não o PC);
  - `final_wb` fica sem carga e é podado.
- Memórias:
  - IMEM: `reg [31:0] Mem_Array[0:1023]` (4 KiB), `$readmemh("program.hex")`, leitura
    combinacional indexada por `PC[11:2]` → ROM em LUTs.
  - DMEM: `reg [7:0] mem[0:4095]` (4 KiB, byte-endereçável), endereço de 32 bits sem corte
    (`mem[address+1]` etc.), escrita SB/SH/SW em até 4 bytes, leitura combinacional com 4 bytes
    independentes, e **reset síncrono que zera os 4096 bytes** num segundo bloco `always`
    (dois blocos escrevendo `mem`). O reset impede LUTRAM/BRAM → a DMEM vira **32.768 FFs**
    + muxes de leitura 4096:1 por byte. Não há `$readmemh` para dados.
- Banco de registradores: 32×32 em FFs (reset síncrono zera todos os registradores).
- Periféricos: nenhum. O top do autor (`RISCV_Top`) só tem `clk` e `rst`, sem saídas.

## Montagem

- Top: `wrapper/top_cmp.sv` → instancia `RISCV_Top` (núcleo + IMEM + DMEM do autor) direto no
  clock de 100 MHz; `rst = ~CPU_RESETN`.
- LEDs: opção (b) das instruções — registrador de 16 bits carregado com o dado de *store*
  (`if (MemWrite) led <= reg_read2[15:0]`).
- XDC: `constr.xdc` = `scripts/base.xdc` sem as chaves (`switch` não é usado).
- Programa: `comparacao/programa/prog_word.hex` copiado como `mem/program.hex` (mesmo formato
  do autor: uma palavra hex por linha). 389 instruções em IMEM de 1024 palavras → sem truncar.
  Os 68 bytes de dados **não foram carregados**: a DMEM do autor não tem inicialização (o reset
  a zera) — anotado.
- Mudanças no RTL (`patch/RISCV_Single_Cycle_Core.v`, cópia do original):
  1. `RISCV_Top` ganhou duas portas de saída, `dmem_we = MemWrite` e `dmem_wdata = reg_read2`
     (só fios, sem lógica nova), para o wrapper observar o store;
  2. removido o módulo `RISCV_Tb` (testbench, só de simulação).
  Nada mais foi alterado (inclusive os `$display` no `initial`, que o Vivado ignora).

## Resultados

**Não medido.** A execução `-Final` estourou o limite de 60 min ainda em `synth_design` (a DMEM de 4 KiB
virou 32.768 FFs por causa do reset que zera o array), e o processo foi encerrado. Sem números de
implementação; o núcleo também tem erros funcionais (desvios só pela flag de zero, JAL/JALR não gravam
PC+4, AUIPC soma rs1+imm), então não foi feita nova tentativa com limite maior.
