# 04 — Shyam Sundhar: RISC-V Single-Cycle Processor (RV32I)

## Trabalho

- Autor: Cherukuri Shyam Sundhar (ECE, IIT Bhubaneswar). Projeto pessoal/acadêmico, sem artigo.
- GitHub: https://github.com/shyamch06/RISC-V-Single-Cycle-Processor
- Commit clonado: `2f8d20453204248a0c98b7dc25a07947df545b0b` (2026-09-27). Licença MIT.
- Placa original: Basys 3 (XC7A35T), demonstração de Fibonacci no display de 7 segmentos.

## Núcleo

- **Monociclo confirmado (CPI = 1):** um único registrador de PC (`pc_flop`), IMEM e DMEM com
  leitura combinacional, banco e DMEM escritos na borda de subida. Sem estágios.
- HDL: Verilog. ISA: RV32I parcial (sem FENCE/ECALL/EBREAK/CSR). Defeitos funcionais vistos na
  leitura (não corrigidos, só registrados):
  - desvios: `controlunit` só toma o desvio para funct3 000/001 (BEQ/BNE); BLT/BGE/BLTU/BGEU
    nunca desviam;
  - JALR: o alvo é `pc + imm` (`pc_target`), não `rs1 + imm`;
  - AUIPC: a ALU soma `rs1 + imm` (operando A é sempre `rd1`), não `pc + imm`;
  - loads/stores só de palavra (sem byte/halfword, sem extensão de sinal);
  - `alu_decoder` tem `case` incompleto em `always @(*)` → **5 latches** em `alucntrl`.
- IMEM: `reg [31:0] mem[127:0]` (128 palavras = 512 B), `$readmemh("program.mem")`, ROM
  assíncrona → sintetizada em LUTs (aparece dentro de `pcflop` no relatório hierárquico).
- DMEM: `reg [31:0] datamem[127:0]` (128 palavras = 512 B), escrita síncrona, leitura
  assíncrona, só palavra → **LUTRAM** (32 × RAM128X1S = 64 LUTs). Inicializada com zeros.
- Banco de registradores: 32 × 32 com 3 portas de leitura (rs1, rs2 e `x1` para o display) →
  **inferido em FFs** (1024 FFs + 512 LUTs de mux).
- Reset: assíncrono ativo alto, só no PC.
- Periféricos do top original: divisor de clock (100 MHz → ~1 Hz), BCD (double dabble),
  multiplexação de display e 7 segmentos. Ficaram de fora.

## Montagem

- Top: `wrapper/top_cmp.sv` instancia `processor` direto no `clk` de 100 MHz;
  `reset = ~CPU_RESETN`. Sem divisor, BCD nem display.
- LEDs: o núcleo não tem MMIO e não expõe `memwrite`/dado de store → opção (c):
  `led <= result[15:0]` (dado de write-back, depende do banco) a cada borda, por registrador.
  `switch` declarado mas sem uso.
- Programa: `autoteste_placa` (`comparacao/programa/prog_word.hex`) **truncado para as 128
  primeiras palavras** (de 389) em `mem/program.mem`, porque a IMEM do autor tem 128 palavras.
  Os 68 B de dados não foram carregados (a DMEM do autor não tem `$readmemh`; inicia em zero).
- RTL do autor: **nenhuma mudança** (todos os arquivos lidos de `repo/`).
- XDC: `constr.xdc` = cópia de `comparacao/scripts/base.xdc`.
- Variante informativa (`variante_x1/`, só `-Tag variante`, não oficial): `processor.v` com
  `assign fib_value = x1;` no lugar da referência hierárquica `rfile.register_mem[1]` (o Vivado
  avisa que ela impede a inferência de memória). Resultado: banco **continua em 1024 FFs**,
  1523 LUTs, WNS −5,395 ns (65 MHz). Ou seja, a referência hierárquica não é a causa dos FFs; a
  diferença de LUTs entre as duas rodadas é variação de otimização da ROM, não do banco.

## Resultados (`build/final/resumo.txt`, execução `-Final`)

```
tag final | route | 161.2 s | pico 2086.301 MB
Timing: periodo 10 ns | WNS -4,575 | TNS -3710,625 | violando 1521/2672 | WHS 0,212 | THS 0 | Fmax 68,6 MHz
Caminho critico: 14,589 ns (logica 5,547 / rota 9,042) niveis 28 (CARRY4=14 LUT2=1 LUT3=1 LUT4=2 LUT5=1 LUT6=6 MUXF7=2 MUXF8=1)
   de:   risc/pcflop/pc_reg[4]/C
   para: risc/pcflop/pc_reg[30]/D
Area: LUTs 2454 (logica 2390, LUTRAM 64) | FFs 1077 | latches 5 | F7 314 | F8 67 | CARRY4 60 | Slices 654 | BRAM 0 | DSP 0 | IOB 18
Potencia: total 0,24 W | dinamica 0,142 W | estatica 0,098 W | Tj 26,1 C | confianca Medium
Etapas: synth_design 00:00:45 | opt_design 00:00:07 | place_design 00:00:48 | route_design 00:00:48
Warnings 67 | CRITICAL 0 | latches(log) 1 | pinos sem restricao de max delay: 5 | regs sem clock: True
```

Distribuição (`util_hier.rpt`): `pcflop` (PC + ROM da IMEM) 1678 LUTs / 32 FFs; `rfile` 512 LUTs /
1024 FFs; `cunit` 168 LUTs / 5 latches; `dmem` 64 LUTRAM; top 16 FFs (LEDs). ALU, extensor e
muxes foram achatados dentro de `processor`. Nada foi podado indevidamente.

Caminho crítico: PC → ROM → decodificação/imediato → banco → ALU → DMEM → mux de resultado / alvo
de desvio → PC (14 CARRY4 em série: somador da ALU, comparação `zero` e somador de alvo).

## Publicado × medido

| Métrica | Publicado (XC7A35T, top com divisor/display) | Medido aqui |
|---|---|---|
| LUTs | 845 | 2454 |
| FFs | 470 | 1077 |
| WNS @100 MHz | +5,466 ns ("~221 MHz") | −4,575 ns (68,6 MHz) |

Por que diferem:
- No top original o núcleo roda em `clkout`, gerado por um FF do divisor e **sem
  `create_generated_clock`**; os caminhos do núcleo provavelmente não foram analisados no clock
  de 100 MHz, e o WNS publicado reflete divisor/display. "~221 MHz" não é a Fmax do núcleo.
- O programa do autor tem 6 instruções (Fibonacci em x1–x3): a síntese poda quase todo o
  banco, a ROM e a ALU. Com o `autoteste_placa` (128 palavras) o núcleo inteiro é exercitado.
- Os FFs publicados incluem o divisor (27) e o display.

## Observações para a comparação

- Monociclo real, mas **funcionalmente incompleto** (BLT/BGE/BLTU/BGEU, JALR, AUIPC errados;
  só LW/SW). O programa não rodaria corretamente; os números são de área/timing apenas.
- **Programa truncado** em 128 de 389 instruções; IMEM e DMEM de 512 B cada (menores que as
  4 KiB / 1 KiB deste TCC).
- Banco de registradores em FFs (1024) e 5 latches no decodificador da ALU (resultado do RTL do
  autor, não corrigido).
