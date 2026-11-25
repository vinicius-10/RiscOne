# 11 — BRISC-V (Bandara et al.)

## Trabalho

- Autores: Sahan Bandara, Alan Ehret, Donato Kava, Michel A. Kinsy (ASCS Lab, Boston University).
- "BRISC-V: An Open-Source Architecture Design Space Exploration Toolbox", ACM/SIGDA FPGA '19,
  DOI 10.1145/3289602.3293991 (arXiv 1908.09992).
- Código: não há repositório oficial no GitHub (procurei ASCS-Lab, bu-ascslab, BRISC-V e as contas
  do autor; só existe `sahanlb/Cache_Subsystem`). A fonte oficial é o site do ASCS Lab:
  - **medição principal**: configuração monociclo **gerada pelo usuário no BRISC-V Explorer**
    (https://ascslab.org/research/briscv/explorer/explorer.html), arquivos gerados pelo Explorer copiados para
    `usuario_256/` (originais intactos);
  - **medição secundária**: `briscv_processors.zip` da página de downloads
    (https://ascslab.org/research/briscv/downloads/briscv_processors.zip, sha256
    `368e3cb6…8243f2a666`), pasta `BRISC-V_single_cycle_base`, extraída em `repo/`.
- Sem hash de commit (download do site). Licença: MIT (cabeçalho de cada arquivo, © 2018/2019
  BRISC-V ASCS/ECE/BU).

## Núcleo medido (principal: Explorer, `usuario_256/`)

- Verilog, RV32I (sem FENCE/ECALL/CSR; loads/stores de byte/meia palavra com byte-enable).
  Reset síncrono ativo alto.
- Sem pipeline, mas **não é monociclo puro: CPI = 2**. A memória é BRAM de **leitura síncrona**
  (`dual_port_BRAM`): o PC é emitido num ciclo e a instrução chega no seguinte; o
  `hazard_detection_unit` detecta `issue_PC != fetch_address_in` e insere um NOP (`flush`) a cada
  instrução. Confirmado em simulação (xsim, 40 ciclos): toda instrução é seguida de uma bolha;
  loads ainda esperam o dado síncrono (`d_mem_hazard`), portanto ≥ 3 ciclos.
- Memória: `MEM_ADDRESS_BITS = 6` ⇒ **64 palavras × 4 B = 256 B**, e não 1 kB como o usuário
  descreveu (o nome "256memoria" corresponde a 256 bytes). É **unificada** (instrução e dados na
  mesma BRAM dual-port: porta 1 = busca, porta 2 = dados), em 4 faixas de byte de 64×8.
  Ficou em **4 RAMB18** (relatório: BRAM 2 em equivalentes de 36 Kb).
- Banco de registradores: `ram_style = "distributed"`, mas o reset de `register_file[0]` impede
  a LUTRAM ⇒ **1024 FFs** (32×32). Resultado, não corrigido.
- Sem periféricos (o topo só exporta o PC).

## Montagem

- `wrapper/top_cmp.sv`: reproduz a ligação do topo `BRISC_V256memoria` (single_cycle_core +
  memory_interface + dual_port_BRAM_memory_subsystem, mesmos parâmetros), porque o topo do autor
  só exporta o PC. Clock de 100 MHz direto, `CPU_RESETN` invertido, `start = 0`, `scan = 0`.
  LEDs = registrador de 16 bits carregado com o dado de store (`if (memory_write) led <= …`).
- Programa: `autoteste_placa`, **truncado às primeiras 64 instruções** (a memória só tem 64
  palavras), dividido em 4 imagens de byte (`mem/prog_b0..3.hex`, gerados por
  `mem/conv_lanes.py`). Dados (`data_*.hex`) não carregados: memória unificada, o endereço 0 é
  código. O programa não roda corretamente (o `crt0` zera .bss em 0x44–0x64, sobrescrevendo
  código), mas usa loads, stores, ALU, desvios e saltos, então nada é podado.
- Mudanças no RTL (cópias em `patch/`):
  1. `dual_port_BRAM.v`: parâmetro `INIT_FILE` + `$readmemh` (o autor só carrega pelo testbench,
     por hierarquia).
  2. `dual_port_BRAM.v`: escrita *blocking* (`ram[a] = d`) em dois `always` trocada por não
     bloqueante (`<=`, leitura read-first). O Vivado rejeita o original ("Synth 8-2914
     Unsupported RAM template"); também rejeitou a versão write-first. Sem efeito prático: a
     porta 1 nunca escreve e um store não lê a porta 2 no mesmo ciclo.
  3. `dual_port_BRAM_byte_en.v`: passa um `INIT_FILE` por faixa de byte.
- Poda verificada em `util_hier.rpt`: regFile 594 LUTs/1024 FFs, núcleo 698 LUTs, memória 4 RAMB18.

## Resultados `-Final` (`build/final/resumo.txt`)

```
tag final | route | 207.4 s | pico 2106.086 MB
Etapas: synth_design 00:00:35 | opt_design 00:00:11 | place_design 00:01:09 | route_design 00:01:19
Timing: periodo 10 ns | WNS -8,212 | TNS -12743,85 | violando 2185/2365 | WHS 0,181 | Fmax 54,9 MHz
Caminho critico: 17,967 ns (logica 5,039 / rota 12,928) niveis 20 (CARRY4=6 LUT2=1 LUT4=1 LUT5=1 LUT6=9 MUXF7=2)
   de: memory/i_mem_address_out_reg[3]/C  ->  para: core/ID/registers/register_file_reg[13][12]/CE
Area: LUTs 1584 (logica 1584, LUTRAM 0) | FFs 1170 | latches 0 | F7 301 | F8 2 | CARRY4 80 | Slices 554 | BRAM 2 (4 RAMB18) | DSP 0 | IOB 18
Potencia: total 0,16 W | dinamica 0,063 W | estatica 0,097 W
Warnings 153 | CRITICAL 0 | latches 0 (SYNTH-6: timing de RAM sub-ótimo, 4)
```

## Medição secundária (zip `BRISC-V_single_cycle_base`, só síntese)

`config_zip_base.psd1`, `wrapper/top_cmp_zip_base.sv`, `patch/zip_base_bsram.v`; resultado em
`build/zip_base_synth/` (para refazer, copie `config_zip_base.psd1` sobre `config.psd1`).
- Monociclo verdadeiro (CPI = 1): IMEM e DMEM separadas, `BSRAM` de leitura assíncrona,
  1024 palavras cada (`ADDRESS_BITS = 10`) — coincide com o artigo ("1k palavras, memória
  assíncrona"). Mas o PC tem 10 bits ⇒ só 256 instruções alcançáveis; DMEM endereçada por
  palavra com o endereço de byte, só LW/SW.
- IMEM sem `$readmemh` (carga pela interface ISP): acrescentado `INIT_FILE` (defparam no wrapper),
  ISP desligada. LEDs = `to_peripheral_data` (registrador do próprio núcleo, write-back de
  x9/x18–x25).
- Síntese: LUTs 2474 (lógica 1610, LUTRAM 864) | FFs 1017 (banco de registradores em FFs) |
  BRAM 0 | WNS -5,593 (Fmax estimada 64,1 MHz, pós-síntese, sem implementação).

## Publicado × medido

- Artigo (núcleo monociclo, Cyclone IV): 53.448 LE, 0 bits de BRAM (memórias de 1k palavras
  assíncronas em LEs), 29,0 MHz. A versão do zip corresponde a essa arquitetura.
- Aqui (configuração do Explorer): memória 16× menor (64 palavras unificadas) e em BRAM síncrona,
  daí poucas LUTs e nenhuma memória em lógica; Fmax 54,9 MHz, mas com CPI = 2 o desempenho
  equivale a ~27 MHz monociclo — próximo dos 29 MHz publicados.

## Observações para a comparação

- **Não é monociclo puro (CPI = 2)** na configuração principal; memória em BRAM síncrona,
  unificada, só 256 B; programa truncado em 64 instruções.
- Banco de registradores em FFs nas duas versões (reset de x0 impede LUTRAM).
- Se a intenção do usuário era 1 kB (256 palavras), o Explorer deveria gerar `MEM_ADDRESS_BITS = 8`;
  a configuração entregue tem 6.
