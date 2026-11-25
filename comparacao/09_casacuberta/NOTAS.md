# 09 — Casacuberta (RV32i-Verilog)

## Trabalho

- Autor: Casacuberta (GitHub `4a1c0`). TFG Enginyeria Informàtica, Universitat Autònoma de Barcelona (UAB), 2020.
  PDF: https://ddd.uab.cat/pub/tfg/2020/tfg_244100/TFG_GEI_Informe_Final.pdf
- Repositório: https://github.com/4a1c0/RV32i-Verilog, commit `99ec0f905897598863f064d414363952807314c6` (29/04/2020).
- Licença: o repositório não tem arquivo LICENSE.
- Ferramentas originais: Verilog, Icarus + Travis CI (testes), Quartus II 13.0.1, Cyclone III EP3C16 (DE0).

## Núcleo

- **Monociclo, CPI = 1**: o único registrador do caminho de dados é o PC (`core_program_counter.v`);
  a ROM (`progMem`) e a leitura da RAM (`dataMem`) são combinacionais, e a escrita no banco e na RAM
  ocorre na borda de subida. Um só domínio de clock (borda de subida), reset **assíncrono** ativo baixo.
- ISA: RV32I (sem FENCE/ECALL/EBREAK efetivos) + CSRs de contador `cycle/time/instret` (só CSRRS,
  timer de 64 bits; leitura de CSR registrada). Sem traps.
- Banco de registradores: 32×32 em FFs com reset assíncrono de todo o array (992 FFs; x0 fixo em 0
  na leitura) → não infere LUTRAM.
- IMEM (`progMem`): declarada com 1024 palavras, mas endereçada por `pc[9:0] >> 2` → só **256 palavras
  (1 KiB)** alcançáveis. Virou lógica (ROM em LUTs).
- DMEM (`dataMem`): 256 palavras × 32 bits (**1 KiB**), escrita por byte, leitura combinacional; o
  `always` zera o array inteiro no reset assíncrono → **memória em FFs** (8.192 FFs + ~2.300 LUTs de mux).
- Periféricos: nenhum no núcleo (o top da DE0 tinha LEDs/7 segmentos/PLL/debouncer).

## Montagem

- Top usado: `wrapper/top_cmp.v`, mesma ligação de `src/top.v` do autor (core + progMem + dataMem,
  parâmetros padrão, sem `CUSTOM_DEFINE`), clock direto de 100 MHz, `CPU_RESETN` direto no `rst_n`
  (o núcleo já é ativo baixo). LEDs = registrador de 16 bits carregado com `val_mem_data_write[15:0]`
  quando `we_mem_data` (opção b). Switches não usados (removidos do `constr.xdc`).
- Configuração de tamanho: escolhi a do `src/top.v`/CI (sem `CUSTOM_DEFINE`: IMEM 1 KiB útil, DMEM 1 KiB).
  O projeto Quartus da DE0 usava `CUSTOM_DEFINE` → `MEM_ADDR_WIDTH = 8`, IMEM e DMEM de 64 palavras (256 B),
  também em registradores (relatório Quartus: 0 bits de memória). O top da DE0 (PLL `altpll` de 1 MHz,
  debouncers, displays, clock por botão/10 Hz) não foi usado; os `altsyncram` (`prog.v`, `ram.v`) só
  entram com `` `define MEM``, que está desligado no próprio top da DE0.
- Programa: `autoteste_placa` (`comparacao/programa/prog_word.hex`) **truncado para as 256 primeiras
  instruções** (`mem/prog_256.hex`; o programa tem 389). Dados (`data_byte.hex`) **não** carregados: a
  DMEM do autor é zerada no reset e o `$readmemh` dele só existe dentro do reset (simulação).
- Mudanças no RTL (só para sintetizar):
  1. `patch/mem_prog.v`: o `always @(posedge clk or negedge rst_n)` zerava `progArray` no reset (e o
     `$readmemh` só existia nesse ramo, com `LOAD_MEMS`) → ROM constante 0 na síntese. Trocado por
     `initial` com `$readmemh("prog_256.hex", ...)`. `clk`/`rst_n` ficam sem uso.
  2. `patch/core/**` (cópia de `src/core`) + `patch/defines.vh`: `` `default_nettype none`` trocado por
     `` `default_nettype wire`` em todos os arquivos. Os módulos declaram portas `input x;` sem tipo de
     rede, o que o Vivado 2025.2 rejeita com `none` (erro Synth 8-6735/8-9844). Sem efeito na lógica.
  - `===`/`!==` e `$display` ficam como estão (o Vivado troca por `==`/ignora; warnings).
- Fora da medição: PLL, debouncers, displays e divisor de clock da DE0.

## Resultados (`-Final`, `build/final/resumo.txt`)

```
Casacuberta - RV32i-Verilog (core + progMem + dataMem)  |  tag final  |  route  |  322 s  |  pico 2519.418 MB
Timing: periodo 10 ns | WNS -9,571 | TNS -63118,664 | violando 16465/18597 | WHS 0,143 | THS 0 | Fmax 51,1 MHz
Caminho critico: 19,188 ns (logica 4,313 / rota 14,875) niveis 23 (CARRY4=6 LUT3=1 LUT4=2 LUT5=3 LUT6=9 MUXF7=1 MUXF8=1)
   de:   core_inst/program_counter_inst/pc_reg[2]/C
   para: core_inst/reg_file_inst/regFile_reg[11][30]/D
Area: LUTs 4986 (logica 4986, LUTRAM 0) | FFs 9339 | latches 0 | F7 1213 | F8 492 | CARRY4 48 | Slices 3146 | BRAM 0 | DSP 0 | IOB 18
Potencia: total 0,264 W | dinamica 0,166 W | estatica 0,098 W | Tj 26,2 C | confianca Medium
Etapas: synth_design 00:02:19 | opt_design 00:00:08 | place_design 00:01:17 | route_design 00:01:21
Warnings 42 | CRITICAL 0 | latches(log) 0 | pinos sem restricao de max delay: 0 | regs sem clock: False
```

- Tempo total 322 s; synth 139 s, opt 8 s, place 77 s, route 81 s.
- Caminho crítico: PC → ROM → decodificação → ALU → write-back no banco (típico de monociclo).
- Hierarquia (síntese): core 2.485 LUTs / 1.131 FFs (ROM + controle + ALU achatados em
  `program_counter_inst`, 1.811 LUTs; regFile 544 LUTs/992 FFs; CSR/timer 72 LUTs/107 FFs);
  dataMem 2.305 LUTs / 8.192 FFs; wrapper 16 FFs (LEDs). Sem poda indevida, sem latches.

## Números publicados pelo autor × medidos

- O repositório traz o relatório Quartus da DE0 (`Quartus/DE0_Demo/output_files`): 3.467 LEs, 2.306
  registradores, 0 bits de memória, Cyclone III EP3C16 — inclui PLL, debouncers, displays e memórias de
  64 palavras; o núcleo rodava a 1 MHz (sem Fmax relevante). Não comparável diretamente: outra família,
  memórias 4× menores e periféricos incluídos. Aqui a DMEM é 4× maior (1 KiB), daí os 9.339 FFs.

## Observações para a comparação

- **DMEM e banco de registradores em FFs** (reset de todo o array) — domina área (≈8.200 FFs e ≈2.300 LUTs
  só na DMEM) e congestiona a rota (77% do atraso crítico é rota).
- Programa truncado em 256 instruções (IMEM útil de 1 KiB); dados iniciais não carregados.
- Inclui CSRs de contador de 64 bits (não presentes no núcleo do TCC).
- Possível erro funcional observado na leitura (não verificado em simulação): em `core_execution_unit_br.v`,
  desvio condicional **não tomado** usa `offset = 0`, então `new_pc = pc` e o núcleo repetiria a mesma
  instrução indefinidamente. Não afeta a medição, mas o programa de autoteste não rodaria corretamente.
- Bug em `comparacao/scripts/medir.ps1`: com `Include` não vazio, gera `read_verilog -include_dirs`, opção
  que não existe (o certo é `-include_dirs` no `synth_design` ou `set_property include_dirs`). Contornado
  deixando `Include = @()` (os `` `include`` relativos resolvem pelo diretório do arquivo).
- O `medir.ps1` terminou com código 1 (timing violado), mas gerou todos os relatórios.
