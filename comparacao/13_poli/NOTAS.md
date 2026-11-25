# 13_poli — Poli, Saha, Zhai & McDonald-Maier (minimal-risc-v-cpu)

## Trabalho
- L. Poli, S. Saha, X. Zhai, K. D. McDonald-Maier, "Design and Implementation of a RISC V Processor
  on FPGA", IEEE MSN 2021 (Univ. of Essex), DOI 10.1109/MSN53354.2021.00037.
- GitHub: https://github.com/Ludini1/minimal-risc-v-cpu — commit `191b49608dc83c0159f4088eacfbe1981da48862`
  (3/ago/2021). **Sem arquivo de licença** no repositório.

## Núcleo
- **Monociclo (CPI = 1)** confirmado: PC é o único registrador de controle; IMEM (`assign` de
  array), leitura do banco de registradores e da DMEM são combinacionais; escritas no banco e na
  RAM de dados na borda de subida do mesmo ciclo. Sem estágios nem máquina de estados.
- ISA: **não é RV32I**. Subconjunto RV64I de 7 instruções: `ld`, `sd`, `add`, `sub`, `and`, `or`,
  `beq` (dados de 64 bits, sem instruções com imediato aritmético). x0 **não** é fixo em zero.
  PC conta em palavras (8 bits, +1 por instrução; desvio soma `offset<<1` ao índice de palavra).
- HDL: SystemVerilog. Reset assíncrono ativo alto (zera PC, os 32 registradores e a RAM inteira).
- Memórias (tamanhos do autor, mantidos): IMEM 256 × 32 bits (1 KiB, ROM `$readmemh`);
  DMEM = ROM 256 × 64 bits (`$readmemh`) + RAM 256 × 64 bits com reset assíncrono (logo, se
  existisse escrita, seria FF). Banco: 32 × 64 bits em FF (reset assíncrono).
- Periféricos: porta `debug` = `RF[31][15:0]` (LEDs na Basys 3). Divisor de clock para 1 Hz no top.

## Montagem
- `patch/top.sv`: cópia de `top.sv` com o `clock_divider` removido (`assign clk = clk_200M;`).
  Única mudança no RTL do autor.
- `wrapper/top_cmp.sv`: instancia `top` com `clk` de 100 MHz direto, `rst = ~CPU_RESETN`,
  `led = debug` (= RF[31][15:0], saída direta de FF — opção (a), saída própria do núcleo).
- `constr.xdc`: clk, CPU_RESETN e led[15:0] do `base.xdc`.
- Programa: **o do autor** (`instruction_memory.mem`, 6 instruções: `ld x1,32(x0)`; `add x31,x0,x1`;
  `add x0,x1,x2`; `add x1,x31,x2`; `add x1,x31,x2`; `beq x0,x0,-4` — laço de Fibonacci) e
  `data_memory.mem` do autor. O programa do TCC (RV32I) não executa neste núcleo.
- Fora: divisor de clock. Testbenches não usados.

## Resultados (`-Final`, build/final/resumo.txt)
```
Poli et al. - minimal-risc-v-cpu (RV64I 7 instr.)  |  tag final  |  route  |  178.8 s  |  pico 2072.484 MB
Timing: periodo 10 ns | WNS -0,33 | TNS -1,435 | violando 7/392 | WHS 0,238 | THS 0 | Fmax 96,8 MHz
Caminho critico: 10,404 ns (logica 5,283 / rota 5,121) niveis 24 (CARRY4=17 LUT4=2 LUT5=5)
   de:   core/program_counter/instruction_address_reg[6]/C
   para: core/program_counter/instruction_address_reg[5]/D
Area: LUTs 462 (logica 462, LUTRAM 0) | FFs 200 | latches 0 | F7 0 | F8 0 | CARRY4 40 | Slices 144 | BRAM 0 | DSP 0 | IOB 18
Potencia: total 0,105 W | dinamica 0,008 W | estatica 0,097 W | Tj 25,5 C | confianca Medium
Etapas: synth_design 00:01:59 | opt_design 00:00:07 | place_design 00:00:18 | route_design 00:00:22
Warnings 75 | CRITICAL 0 | latches(log) 0 | pinos sem restricao de max delay: 0 | regs sem clock: False
```
Hierarquia: program_counter 346 LUTs/8 FF (absorveu a IMEM-ROM e a decodificação, constantes),
ALU 43 LUTs, register_file 65 LUTs/192 FF. Caminho crítico PC → ROM → banco → somador/subtrator
de 64 bits (zero flag do `beq`) → PC.

## Publicado × medido
- Artigo: 322 LUTs, 229 FFs (Basys 3, Artix-7 35T, memórias "de 256 bits", programa Fibonacci de 6
  instruções); "100 MHz" só como clock usado, sem Fmax relatada.
- Aqui: 462 LUTs, 200 FFs, Fmax 96,8 MHz. Diferenças: outra versão do Vivado e outro dispositivo;
  o top do artigo tinha divisor de clock (≈28 FFs + contador, o que explica quase todo o 229 − 200);
  LUTs variam com a otimização das constantes da ROM.

## Observações para a comparação
- **Medição dominada pela poda**: com 6 instruções, só x0, x1 e x31 são escritos (3 × 64 = 192 FF);
  `sd` não ocorre, então a RAM de dados some; ROM de dados vira constante. Não é comparável a um
  núcleo medido com o programa de 37 instruções RV32I.
- Datapath de 64 bits, mas ISA mínima (7 instr.), sem imediatos/shifts/comparações/saltos.
- O `medir.ps1` retornou código de saída 1 em ambas as execuções (sintese e final) apesar de gerar
  resumo e linha no `resultados.csv` — aparentemente por WNS negativo/aviso; não investigado.
  Numa primeira tentativa (XDC meu sem `create_clock`), o script falhou com "Não é possível chamar
  um método em uma expressão de valor nulo" em vez de mensagem clara de "sem clock".
