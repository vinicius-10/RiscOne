# 03_rudi — Rudi-RV32I (hamsternz)

## Trabalho

- Autor: Mike Field (hamsternz). Projeto de hobby "Rudi-RV32I", 2019/2020, sem artigo (README + `doc/Rudi-RV32i.pdf`).
- GitHub: https://github.com/hamsternz/Rudi-RV32I — commit clonado `f3d8bedecdb28088d5455285d8c296c55826deed` (2020-10-14). Licença MIT.

## Núcleo

- **Microarquitetura:** sem pipeline; cada instrução executa em um ciclo. A IMEM é BRAM síncrona endereçada
  pelo `pc_next` (o registrador de instrução é o registrador de saída da BRAM, carregado na mesma borda do PC —
  mesmo truque do núcleo do TCC), então busca + execução cabem em 1 ciclo.
  **CPI = 1 exceto loads:** a RAM de dados (e a leitura de dados da ROM) é BRAM síncrona e sinaliza `bus_busy`
  por 1 ciclo em toda leitura → **load = 2 ciclos**, store = 1, demais = 1 (sem a ponte registrada).
  Com a ponte registrada (`bus_bridge_use_clk='1'`): load = 3, store = 2.
  Classifico como monociclo com stall de 1 ciclo em loads (não é CPI = 1 estrito como o do TCC).
- ISA: RV32I (sem CSR/ECALL/FENCE úteis). HDL: VHDL-93.
- Memórias (do autor, mantidas): IMEM 1024×32 = 4 KiB (constante VHDL, BRAM, dual-port: busca + leitura de
  dados pelo barramento); DMEM `ram_memory` 1024×32 = 4 KiB em BRAM com escrita por byte.
- Banco de registradores: LUTRAM, duplicado (`registers_1`/`registers_2`, um por porta de leitura; a 3ª cópia de
  depuração é podada porque `debug_data` fica aberto). 32 bits × 32, x0 protegido na escrita.
- Reset: PC inicial `0xFFFFFFF0` por `initial`; o sinal `reset` leva o decodificador ao modo `PC_RESET_STATE`
  (próximo PC = vetor `0xF000_0000`).
- Periféricos do autor (UART 19200, GPIO, contador de ms, `bus_expander`): **fora** da medição.
- Opção `minimize_size`: medido com `'0'` (versão rápida/maior, a das linhas 67,8/80 MHz do README).

## Montagem

- Top: `wrapper/top_cmp.vhd` = cópia de `src/systems/top_level_expanded.vhd` sem `bus_expander` e periféricos:
  `riscv_cpu` + `bus_bridge` (`use_clk='0'`) + `program_memory` + `ram_memory`, clock direto de 100 MHz (sem a
  MMCM da Basys 3). `reset = not CPU_RESETN` (no autor era um shift register de power-on).
- Janelas do `bus_bridge` (só as constantes do top mudaram): RAM em `0x0000_0000/0xFFFFF000` (autor: `0x1000_0000`),
  ROM em `0xF000_0000` (igual), MMIO mínimo em `0x4000_0000/0xFFFFFFE0` no lugar do expander. MMIO do wrapper:
  escrita carrega `led[15:0]` (registrador, opção b das instruções), leitura devolve `x"0000" & switch`.
- Programa: `autoteste_placa` (389 palavras) e dados (17 palavras) gerados por `scripts_local/gera_mem.py`
  (`python -I`) em `patch/program_memory_tcc.vhd` e `patch/ram_memory_tcc.vhd`, cópias de
  `program_memory_test.vhd`/`ram_memory_test.vhd` do autor (os arquivos que o fluxo `syn/` dele usa) com o
  inicializador trocado; resto da ROM = 0 (no autor, `others` = ADDI).
  **O programa não roda corretamente no Rudi:** o código é ligado em 0, mas o reset vector/janela de busca do
  Rudi é `0xF000_0000` (desvios relativos funcionam; ponteiros de código absolutos não). Para a síntese só
  importa o conteúdo da ROM.
- Mudanças no RTL do autor:
  1. conteúdo das duas memórias (acima);
  2. `attribute rom_style of prog_memory : signal is "block"` em `patch/program_memory_tcc.vhd`. Sem ele, com o
     nosso programa (ROM 62% vazia) e a hierarquia achatada, o Vivado implementou a porta de busca em LUTs
     (473 LUTs + 124 F7 + 62 F8, 2 BRAM) — resultado em `build/synth_rom_lut/`. O atributo restaura a ROM em
     BRAM como no autor. Mesmo assim o Vivado não juntou as duas portas num único RAMB36 dual-port: a ROM virou
     **2 RAMB36** (uma por porta) → total 3 BRAM (autor: 2).
- O autor sintetiza com `-flatten_hierarchy none`; aqui é o padrão (`rebuilt`) do `medir.ps1`, por isso a
  hierarquia em `util_hier.rpt` mistura blocos (decoder/ALU/shifter aparecem dentro de `program_memory`,
  `register_file` e `program_counter`). Total do `riscv_cpu`+lógica absorvida é plausível; nada foi podado.

## Resultados `-Final` (variante primária: sem ponte registrada) — `build/final/resumo.txt`

| Item | Valor |
|---|---|
| Tempo total | 103,3 s (synth 38 s, opt 8 s, place 20 s, route 25 s) |
| WNS / TNS / violando | −3,237 ns / −359,788 ns / 226 de 769 endpoints |
| WHS | 0,52 ns |
| **Fmax** | **75,5 MHz** |
| Caminho crítico | 12,961 ns (lógica 4,965 / rota 7,996), 12 níveis (CARRY4=3 LUT4=3 LUT5=2 LUT6=3 RAMD32=1), `i_program_memory/instr_reg_reg/CLKARDCLK` (saída da BRAM de instrução) → `i_register_file/registers_2_reg.../RAMA/I` (escrita no banco) |
| LUTs | 985 (lógica 941, LUTRAM 44) |
| FFs | 49 (31 PC + 16 LEDs + 2) |
| F7 / F8 / CARRY4 | 0 / 0 / 71 |
| Slices | 290 |
| BRAM / DSP / IOB | 3 RAMB36 / 0 / 34 |
| Potência | 0,121 W (dinâmica 0,024, estática 0,097), confiança Low |
| Pico de memória | 2069 MB |
| Warnings / critical / latches | 95 / 0 / 0 |

Variante **com ponte registrada** (`-Tag ponte`, `bus_bridge_use_clk=1'b1`, não vai ao CSV; o nome no
`build/ponte/resumo.txt` ainda diz "sem ponte" porque o config é o mesmo): **86,7 MHz** (WNS −1,533),
984 LUTs (44 LUTRAM), 119 FFs, 3 BRAM, 113,9 s. Load = 3 ciclos, store = 2.

## Publicado × medido

| | Autor (Basys 3, -1, topo com UART/GPIO/ms) | Aqui (Nexys A7-100T, sem periféricos) |
|---|---|---|
| Sem ponte | 67,8 MHz, 1.108 LUTs, 307 FFs (CPU 781 LUTs, 31 FFs) | 75,5 MHz, 985 LUTs, 49 FFs |
| Com ponte | 80 MHz, 1.078 LUTs, 375 FFs (CPU 762 LUTs, 31 FFs) | 86,7 MHz, 984 LUTs, 119 FFs |

Diferenças: periféricos/expander do autor (~190 LUTs, ~270 FFs) ficaram de fora; o autor reporta a frequência
em que o timing fechou com restrição apertada (12,5/14,75 ns) enquanto aqui a Fmax sai do WNS a 10 ns; Vivado,
dispositivo e conteúdo da ROM diferentes; ROM em 2 BRAM aqui. A ordem de grandeza e o ganho da ponte (~+11–15%)
batem com o README.

## Observações para a comparação

- Não é CPI = 1 estrito: loads levam 2 ciclos (BRAM síncrona com stall). Busca de instrução em BRAM síncrona,
  mas sem ciclo extra (endereçada pelo `pc_next`).
- IMEM e DMEM em BRAM (4 KiB cada); a ROM ocupou 2 RAMB36 (precisa de `rom_style` para não ir a LUTs).
- Banco de registradores em LUTRAM duplicada (44–48 LUTRAM), daí poucos FFs.
- Programa do TCC carregado, mas não executaria corretamente (mapa de memória do Rudi diferente).
