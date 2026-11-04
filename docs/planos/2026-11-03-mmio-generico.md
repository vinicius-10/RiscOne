# E/S genérica de 32 bits no core (4 entradas e 4 saídas)
Data: 2026-11-03 · Status: concluído

**Resultado:** 10/10 testbenches (`tb_data_memory` com 26 casos novos de MMIO, 46 no total; `tb_core` com o mapa novo e casos de 32 bits; `tb_program` passa com `selftest` e `autoteste_placa`); `top_core` elabora sem erros. **Desvio do plano:** as saídas passaram a ser somente escrita, porque a leitura de volta custava 0,9 ns e 96 FFs (ver Decisões). Medição final `mmio_somente_escrita`: WNS −4,724 ns (67,9 MHz), 1676 LUTs, 67 FFs, contra a base −4,207 ns, 1801 LUTs, 99 FFs. A diferença de WNS está na faixa de variação de placement (~0,5 ns, ver TIMING.md).

## Objetivo e critério de pronto

Tirar do `core` e da `data_memory` os nomes e larguras dos periféricos da placa. O `core` passa a ter 4 entradas e 4 saídas genéricas de 32 bits. O `top_core` decide o que cada uma significa na Nexys A7 (chaves, botões, LEDs, 7 segmentos, PMOD).

Pronto quando:
- os 10 testbenches passam (`run_tb.ps1`), incluindo testes novos de MMIO no `tb_data_memory`;
- `top_core` elabora e as portas da placa (e o XDC) não mudam;
- `synth.ps1 -Tag mmio_generico -App placa` foi medido e comparado com `addr_dedicado` (−4,207 ns). Expectativa: WNS igual dentro do ruído (~0,3 ns); FFs 99 → ~191; LUTs +~50.

## Decisões

| Dúvida | Escolha | Motivo |
| :-- | :-- | :-- |
| Quantidade e largura | 4 entradas e 4 saídas, 32 bits cada, número fixo (sem parâmetro) | Pedido do usuário; sem configurabilidade especulativa |
| Mapa de endereços | saídas `out0..out3` em `0x00/04/08/0C` (L/E); entradas `in0..in3` em `0x10/14/18/1C` (L) | Mantém a leitura de volta das saídas, e os LEDs (`out0`) ficam em `0x4000_0000`, então o programa instalado na placa e o `asm_exemplo` continuam válidos |
| Offsets `addr[5:2]` de 8 a 15 | leem 0, escrita ignorada (como hoje) | Mesmo comportamento atual fora do mapa |
| Escrita em endereço de entrada | ignorada | Entrada só pode ser lida |
| Faixas de byte nas saídas | os 4 bytes graváveis (SB/SH/SW com o mesmo `we_byte`/`wdata` da RAM) | Hoje só os bytes 0–1 eram gravados, porque os registradores tinham 16 bits |
| `in3`/`out3` no `top_core` | livres: `in3 = 0`, `out3` sem ligação a pino | Reserva para um periférico futuro |
| Nomes das portas | `io_in0_i … io_in3_i`, `io_out0_o … io_out3_o` | Padrão `_i`/`_o`; fáceis de ver na GUI e de ligar no testbench |
| Software | `mmio.h` mantém `LEDS/SWITCHES/BUTTONS/SEG7` com os endereços novos e acrescenta `IO_OUT(n)`/`IO_IN(n)`; o PMOD vira `PMOD_COL` (E) e `PMOD_ROW` (L) | Os programas só precisam ser recompilados. O PMOD agora ocupa dois endereços |
| Reset | as saídas não são resetadas (`initial` em zero, como hoje) | Reset zera só o PC (decisão existente) |
| **Revisão na execução (03/11):** leitura das saídas | **somente escrita**: ler `0x00..0x0C` devolve 0 (substitui a leitura de volta da linha "Mapa de endereços") | Medição: com leitura de volta, WNS −5,083 ns (−0,9 ns, +96 FFs), porque os bits sem pino não podem ser podados; sem ela, igual à base. Nenhum programa lê as saídas. Decisão do usuário |

## Arquitetura

```text
top_core
├── io_in0 = {16'b0, switch}        led      = io_out0[15:0]
├── io_in1 = {27'b0, button}        seg7     = io_out1[15:0]  (cátodos [7:0], ânodos [15:8])
├── io_in2 = {28'b0, pmod_row}      pmod_col = io_out2[3:0]
├── io_in3 = 32'b0                  io_out3  sem ligação
└── core (io_in0..3_i → data_memory; data_memory → io_out0..3_o)
    └── data_memory: 4 registradores de saída de 32 bits + mux de leitura de 8 entradas
```

Mapa MMIO novo (base `0x4000_0000`, registrador por `addr[5:2]`):

| Endereço | Antes | Depois | Acesso |
| :-- | :-- | :-- | :-- |
| `0x4000_0000` | LEDs | `out0` (LEDs) | L/E |
| `0x4000_0004` | chaves | `out1` (7 segmentos) | L/E |
| `0x4000_0008` | botões | `out2` (colunas PMOD) | L/E |
| `0x4000_000C` | 7 segmentos | `out3` (livre) | L/E |
| `0x4000_0010` | PMOD (L: linhas, E: colunas) | `in0` (chaves) | L |
| `0x4000_0014` | — | `in1` (botões) | L |
| `0x4000_0018` | — | `in2` (linhas PMOD) | L |
| `0x4000_001C` | — | `in3` (livre, lê 0 na placa) | L |

## Interfaces

| Módulo | Porta | Dir | Largura/tipo | Descrição |
| :-- | :-- | :-- | :-- | :-- |
| `core`, `data_memory` | `io_in0_i` … `io_in3_i` | in | `[31:0]` | Entradas genéricas, lidas em `0x4000_0010 + 4k` |
| `core`, `data_memory` | `io_out0_o` … `io_out3_o` | out | `[31:0]` | Registradores de saída, escritos e lidos em `0x4000_0000 + 4k` |
| `core`, `data_memory` | `switch_i`, `button_i`, `pmod_row_i`, `led_o`, `seg7_o`, `pmod_col_o` | — | — | **removidas** |
| `top_core` | pinos da placa | — | — | sem mudança (XDC intacto) |

## Controle

Não se aplica: `control_unit` e packages não mudam.

## Temporização

- Saídas continuam registradas na borda de subida; leitura das entradas e das saídas continua combinacional.
- O mux de leitura do MMIO passa de 5 para 8 entradas de 32 bits. Ele depende de `addr[5:2]` (bits baixos do somador, prontos cedo) e de valores estáveis, então deve ficar fora do caminho crítico, que espera `addr[31:28]` (`is_io_space`).
- Área: as saídas eram 36 FFs (16 + 16 + 4) e passam a 128. Os bits sem pino no `top_core` não são removidos, porque o software pode lê-los de volta. As entradas sem ligação viram constante 0 e somem na síntese.

## Verificação (testbench primeiro)

- `tb_data_memory` (hoje não liga o MMIO): ligar as 8 portas e acrescentar:
  - `SW` em `out0..out3` com padrões de 32 bits diferentes, checando a porta e a leitura de volta por `LW`;
  - `SB` no byte 3 e `SH` na metade alta de uma saída (só esses bytes mudam);
  - `LW` das 4 entradas com valores de 32 bits; `LB`/`LBU`/`LH`/`LHU` no byte 3 / metade alta de uma entrada (extensão de sinal com bit 31 = 1);
  - escrita em `0x4000_0010` (entrada) e em `0x4000_0020` (offset 8) não muda nenhuma saída nem a RAM; leitura de `0x4000_0020` dá 0;
  - escrita em MMIO não altera a RAM no mesmo índice de palavra.
- `tb_core`: novas portas; seção MMIO com os endereços novos (LEDs em 0, 7 segmentos em 4, colunas PMOD em 8, chaves em 0x10); caso novo: `SW` de 32 bits em `out3` + leitura de volta, e `LB` no byte 3 de `in3` (o tb dirige `in3` com bit 31 = 1).
- `tb_program`: novas portas (só a ligação e a impressão dos LEDs).
- Antes da implementação, o `tb_data_memory` e o `tb_core` não compilam, porque as portas não existem. Para uma mudança de portas, é a falha esperada.
- `build_sw.ps1 leds` precisa compilar com o `mmio.h` novo.

## Arquivos

| Arquivo | Mudança |
| :-- | :-- |
| `sources_1/new/data_memory.sv` | portas novas; 4 registradores de 32 bits com escrita por faixa de byte; mux de leitura de 8 entradas; Doxygen |
| `sources_1/new/core.sv` | portas novas repassadas à `data_memory`; Doxygen |
| `sources_1/new/top_core.sv` | ligação dos pinos às portas genéricas; `in3 = 0`; `out3` sem ligação |
| `sim_1/new/tb_data_memory.sv` | testes de MMIO |
| `sim_1/new/tb_core.sv` | portas, endereços MMIO e casos de 32 bits |
| `sim_1/new/tb_program.sv` | portas |
| `sw/common/mmio.h` | endereços novos, `PMOD_COL`/`PMOD_ROW`, `IO_OUT(n)`/`IO_IN(n)` |
| `docs/ESPEC_RV32I.md` | §7 (interfaces) e §9 (mapa MMIO) |
| `README.md`, `docs/DOCUMENTACAO_PROJETO.md`, `CLAUDE.md` | mapa MMIO e descrição do `top_core` |
| `.claude/skills/rv32i-programas/SKILL.md` | tabela de memória |
| `docs/TIMING.md` | medição antes → depois |

## Passos de execução

1. Estender `tb_data_memory` e `tb_core`; confirmar que falham por portas inexistentes.
2. `data_memory.sv` → `core.sv` → `top_core.sv`; ajustar `tb_program`.
3. `mmio.h`; `build_sw.ps1 leds` e `tb_program` (`selftest` e `autoteste_placa`).
4. `run_tb.ps1` completo e elaboração do `top_core`.
5. `synth.ps1 -Tag mmio_generico -App placa`, comparar com `addr_dedicado`.
6. Atualizar a documentação e marcar o plano como concluído.

## Ações do usuário no Vivado

Não se aplica: nenhum arquivo novo ou movido, e as portas do `top_core` e o XDC não mudam. O `.mem` instalado na placa (`autoteste_placa`) só escreve nos LEDs em `0x4000_0000`, então continua válido sem reinstalar.

## Documentação a atualizar

ESPEC §7/§9, README (mapa MMIO), DOCUMENTACAO_PROJETO (mapa MMIO e papel do `top_core`), CLAUDE.md (linha do MMIO), skill `rv32i-programas` (tabela de memória), TIMING.md.

## Riscos e fora do escopo

- Programas compilados antes desta mudança que leiam chaves/botões ou escrevam no 7 segmentos/PMOD (por exemplo um `.mem` antigo do `leds`) passam a acessar os endereços errados. É preciso recompilar.
- ~+92 FFs pela leitura de volta dos 32 bits das saídas. Se o WNS piorar além do ruído, avalio e reporto antes de manter.
- Fora do escopo: ligar `in3`/`out3` a periféricos (RGB, JB) e mudar a decodificação de região (`addr[31:28]`).
