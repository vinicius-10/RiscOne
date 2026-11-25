# Comparação com núcleos RISC-V monociclo de terceiros

Medição feita em 25/11/2026 no worktree `processador_riscV_comparacao` (branch `comparacao-artigos`,
pasta `comparacao/`). Lá ficam, para cada núcleo: o clone, os patches, o wrapper, os relatórios do Vivado
(`NN_*/build/final/`), o relatório de montagem (`NN_*/NOTAS.md`) e a análise de código (`NN_*/DIFERENCAS.md`).

## 1. Método

- **Mesmo fluxo para todos:** Vivado 2025.2 non-project, xc7a100tcsg324-1 (Nexys A7-100T), `maxThreads 8`,
  `synth_design` → `opt_design` → `place_design` → `route_design` com diretivas padrão (`comparacao/scripts/medir.ps1`).
- **Mesmo clock:** 100 MHz (10 ns) no pino E3, direto no núcleo. Os periféricos, divisores e PLLs dos autores ficaram de fora.
- **Mesmo programa:** `autoteste_placa` (389 instruções, as 37 do RV32I) na ROM de todos, truncado quando a IMEM do
  autor é menor. A síntese poda o núcleo conforme o conteúdo da ROM, então isso importa.
- **Wrapper padrão:** `clk`, `CPU_RESETN`, `led[15:0]` registrado com o dado de store (ou MMIO), para a síntese não
  podar o núcleo.
- **Fmax** = 1000/(10 − WNS). Exceção: se o pior caminho é de meio ciclo (escrita na borda de descida, requisito de
  5 ns), Fmax = 1000/(2·(5 − WNS)).
- **Potência:** `report_power` vetorless (estimada). A parte estática (~0,097 W) é do dispositivo e igual para todos;
  para comparar núcleos, use a dinâmica.
- **Medição exclusiva:** a execução final rodou com só um Vivado na máquina, para o tempo de compilação ser comparável.
- **Análise de diferenças:** só leitura do RTL, sem simulação. "Corretas" significa corretas pela leitura do código.

## 2. Trabalhos comparados

| # | Autor(es) | Trabalho | Código (commit) |
| :-- | :-- | :-- | :-- |
| 00 | Este TCC | RiscOne (`top_core`) | — |
| 01 | Awais Asghar (NCDC) | Relatório de projeto “Single-Cycle RISC-V Processor” | [GitHub](https://github.com/Awais-Asghar/Single-Cycle-RISC-V-Processor-Implemented-on-FPGA) (c60e828) |
| 02 | W. C. D. Zongo | Projeto pessoal, 2026, sem artigo | [GitHub](https://github.com/WendyamZongo/rv32i-core) (fbd1fb6) |
| 03 | Mike Field (hamsternz) | Rudi-RV32I, hobby, 2020 | [GitHub](https://github.com/hamsternz/Rudi-RV32I) (f3d8bed) |
| 04 | C. Shyam Sundhar (IIT Bhubaneswar) | Projeto acadêmico, sem artigo | [GitHub](https://github.com/shyamch06/RISC-V-Single-Cycle-Processor) (2f8d204) |
| 05 | Kang & Choi (RISC-KC) | “basic_RV32s”, IEEE ISOCC 2025, DOI 10.1109/ISOCC66390.2025.11329889 | [GitHub](https://github.com/RISC-KC/basic_rv32s) (672fe02, RV32I37F) |
| 06 | Hariesh Anbalagan | Projeto educacional, sem artigo | [GitHub](https://github.com/HarieshAnbalagan/RV32I) (35daf6c) |
| 07 | Julio N. Avelar (JN513) | Pequeno-Risco-5, projeto pessoal | [GitHub](https://github.com/JN513/Pequeno-Risco-5) (27b7a95) |
| 09 | Casacuberta (4a1c0) | TFG, UAB, 2020 ([PDF](https://ddd.uab.cat/pub/tfg/2020/tfg_244100/TFG_GEI_Informe_Final.pdf)) | [GitHub](https://github.com/4a1c0/RV32i-Verilog) (99ec0f9) |
| 11 | Bandara, Ehret, Kava & Kinsy (BU) | “BRISC-V”, ACM/SIGDA FPGA ’19, DOI 10.1145/3289602.3293991 | [BRISC-V Explorer](https://ascslab.org/research/briscv/explorer/explorer.html) (configuração monociclo gerada pelo usuário) |

Ficaram fora das tabelas (detalhes na §9): 08 cdlavila, 10 Semi-Edge, 12 Wildcat, 13 Poli e 14 marslan6.

## 3. Timing (após o roteamento)

| # | Núcleo | Fmax (MHz) | WNS (ns) | TNS (ns) | Endpoints violando | WHS (ns) | Caminho crítico (ns): total / lógica / rota | Níveis | Origem → destino |
| :-- | :-- | --: | --: | --: | --: | --: | :-- | --: | :-- |
| 00 | **Este TCC** | **97,8** | −0,228 | −0,2 | 1 / 2.010 | 0,091 | 10,18 / 2,66 / 7,51 | 12 | instrução registrada → instrução registrada |
| 03 | Rudi-RV32I | 75,5 ¹ | −3,237 | −359,8 | 226 / 769 | 0,520 | 12,96 / 4,97 / 8,00 | 12 | BRAM da ROM → banco |
| 02 | Zongo | 70,0 | −4,293 | −1.539,7 | 1.139 / 1.936 | 0,335 | 13,95 / 2,77 / 11,18 | 14 | PC → banco |
| 04 | Shyam | 68,6 | −4,575 | −3.710,6 | 1.521 / 2.672 | 0,212 | 14,59 / 5,55 / 9,04 | 28 | PC → PC |
| 01 | Asghar | 66,0 | −5,141 | −1.786,6 | 1.268 / 1.940 | 0,427 | 14,83 / 3,86 / 10,97 | 17 | PC → banco |
| 05 | basic_rv32s | 62,7 | −5,959 | −12.370,6 | 5.222 / 5.238 | 0,536 | 15,65 / 3,47 / 12,18 | 17 | PC → banco |
| 11 | BRISC-V | 54,9 (≈27 efetivo ²) | −8,212 | −12.743,9 | 2.185 / 2.365 | 0,181 | 17,97 / 5,04 / 12,93 | 20 | endereço da BRAM → CE do banco |
| 09 | Casacuberta | 51,1 | −9,571 | −63.118,7 | 16.465 / 18.597 | 0,143 | 19,19 / 4,31 / 14,88 | 23 | PC → banco |
| 07 | Pequeno-Risco-5 | 42,5 | −13,520 | −425.571,9 | 58.729 / 67.600 | 0,230 | 23,32 / 3,86 / 19,46 | 17 | PC → banco |
| 06 | HarieshAnbalagan | 39,3 ³ | −7,721 | −983,5 | 310 / 924 | 0,476 | 12,23 / 2,20 / 10,03 em meio ciclo | 12 | PC → banco (borda de descida) |

¹ Load em 2 ciclos (BRAM síncrona). A variante com a ponte de barramento registrada chega a 86,7 MHz e 119 FFs, com load em 3 ciclos.
² CPI = 2 (memória unificada em BRAM síncrona, uma bolha a cada instrução).
³ O pior caminho tem requisito de 5 ns. A fórmula de ciclo inteiro daria 56,4 MHz, o que está errado.

## 4. Área, potência e tempo de compilação

| # | Núcleo | LUTs | LUTRAM | FFs | Latches | F7 | F8 | CARRY4 | Slices | BRAM | IOB | Potência total / dinâmica (W) | Compilação (s): total = synth / opt / place / route | Pico de RAM (MB) |
| :-- | :-- | --: | --: | --: | --: | --: | --: | --: | --: | --: | --: | :-- | :-- | --: |
| 00 | **Este TCC** | 1.266 | 172 | 98 | 0 | 144 | 33 | 42 | 358 | 0 | 63 ⁴ | 0,146 / 0,048 | **110** = 37 / 8 / 13 / 41 | 2.070 |
| 01 | Asghar | 1.374 | 172 | 48 | 0 | 114 | 57 | 59 | 376 | 0 | 18 | 0,147 / 0,049 | 166 = 72 / 13 / 35 / 33 | 2.067 |
| 02 | Zongo | 1.176 | 172 | 48 | 0 | 114 | 57 | 58 | 326 | 0 | 18 | 0,200 / 0,102 | 136 = 43 / 7 / 39 / 35 | 2.064 |
| 03 | Rudi-RV32I | 985 | 44 | 49 | 0 | 0 | 0 | 71 | 290 | 3 | 34 | 0,121 / 0,024 | 103 = 38 / 8 / 20 / 25 | 2.069 |
| 04 | Shyam | 2.454 | 64 | 1.077 | 5 | 314 | 67 | 60 | 654 | 0 | 18 | 0,240 / 0,142 | 161 = 45 / 7 / 48 / 48 | 2.086 |
| 05 | basic_rv32s | 1.984 | 556 | 108 | 58 | 351 | 129 | 48 | 587 | 0 | 18 | 0,127 / 0,030 | 132 = 35 / 7 / 44 / 33 | 2.071 |
| 06 | HarieshAnbalagan | 867 | 76 | 48 | 0 | 0 | 0 | 42 | 261 | 0 | 18 | 0,132 / 0,035 | 119 = 46 / 7 / 30 / 24 | 2.052 |
| 07 | Pequeno-Risco-5 | 11.878 | 0 | 33.818 | 10 | 4.657 | 2.136 | 25 | 11.816 | 0 | 18 | 1,179 / 1,079 | 758 = 277 / 11 / 212 / 226 | 2.412 |
| 09 | Casacuberta | 4.986 | 0 | 9.339 | 0 | 1.213 | 492 | 48 | 3.146 | 0 | 18 | 0,264 / 0,166 | 322 = 139 / 8 / 77 / 81 | 2.519 |
| 11 | BRISC-V | 1.584 | 0 | 1.170 | 0 | 301 | 2 | 80 | 554 | 2 (4 RAMB18) | 18 | 0,160 / 0,063 | 207 = 35 / 11 / 69 / 79 | 2.106 |

Nenhum núcleo usou DSP. O total inclui também a leitura dos fontes, os relatórios e o `report_power`.
⁴ O TCC tem mais IOB porque mapeia os periféricos reais da placa (7 segmentos, botões, PMOD).

## 5. Conjunto de instruções

Referência: 40 instruções = 37 RV32I + FENCE, ECALL, EBREAK.

| # | Núcleo | RV32I corretas | Erradas ou ausentes | FENCE / ECALL / EBREAK | Extras além das 40 | Codificação inválida |
| :-- | :-- | :-: | :-- | :-- | :-- | :-- |
| 00 | **Este TCC** | **37** (testbench) | — | NOP | nenhuma | NOP (estrita) |
| 01 | Asghar | 35 | SLLI (escreve 0), LUI (soma rs1) | NOP | nenhuma | escreve 0 em rd |
| 02 | Zongo | 31 | LB/LH/LBU/LHU/SB/SH operam como palavra | NOP | nenhuma | executa (só `inst[30]` é examinado) |
| 03 | Rudi-RV32I | 37 | — (alvos de salto zeram os bits 1 e 0) | NOP | nenhuma | NOP |
| 04 | Shyam | 25 | BLT/BGE/BLTU/BGEU nunca desviam; JALR (alvo PC+imm); AUIPC (rs1+imm); loads e stores de byte/halfword como palavra | NOP | nenhuma | repete a operação anterior (latch) e escreve |
| 05 | basic_rv32s | 32 | LB/LH/LBU/LHU sem `addr[1:0]`; SLL/SRL/SRA por `rs2` inteiro | NOP | Zicsr decodificado sem banco de CSR (escreve 0 em rd) | repete os sinais anteriores (58 latches) |
| 06 | HarieshAnbalagan | 29 | os 8 loads e stores (endereço de byte usado como índice de palavra, byte enable ignorado); JALR não zera o bit 0 | NOP | nenhuma | R inválida escreve 0 (MUL vira ADD) |
| 07 | Pequeno-Risco-5 | 13 (+8 parciais) | sem JAL/JALR/LUI/AUIPC; SLT/SLTI/BLT/BGE sem sinal; SRA lógico; byte/halfword como palavra; desvios só para a frente; x0 gravável | repetem a instrução anterior | nenhuma | repete os sinais anteriores (latch) |
| 09 | Casacuberta | 25 | os 6 desvios (não tomado trava o PC); LB/LH/LBU/LHU/SB/SH sem `addr[1:0]`; JALR não zera o bit 0 | NOP | CSRRS nos contadores cycle/time/instret (+H), com erros; demais Zicsr sem efeito | executa (funct7 não é verificado) |
| 11 | BRISC-V | 37 | — | NOP | nenhuma | executa como ADD |

## 6. Interrupções, traps e CSRs

| # | Núcleo | Interrupção | Traps | CSRs | Desvio / acesso desalinhado |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 00 | **Este TCC** | não | não | nenhum | sem trap; JALR zera o bit 0 |
| 01 | Asghar | não | não | nenhum | sem trap; JALR zera o bit 0 |
| 02 | Zongo | não | não | nenhum | sem trap; JAL/JALR zeram o bit 0 |
| 03 | Rudi-RV32I | não | não | nenhum | sem trap; alvos zeram os bits 1 e 0; desalinhado perde bytes |
| 04 | Shyam | não | não | nenhum | sem trap; JALR não zera o bit 0 |
| 05 | basic_rv32s | não | não (saída `misaligned` desconectada) | nenhum | todo PC zera os bits 1 e 0 |
| 06 | HarieshAnbalagan | não | não | nenhum | JALR não zera o bit 0 |
| 07 | Pequeno-Risco-5 | não | não | nenhum | PC e DMEM endereçados por palavra |
| 09 | Casacuberta | não | não | contadores cycle/time/instret | JALR não zera o bit 0 |
| 11 | BRISC-V | não | não | nenhum | sem trap; JALR zera o bit 0 |

Nenhum núcleo comparado implementa interrupções ou traps.

## 7. Memórias e reset

| # | Núcleo | Organização | IMEM | Carga do programa | DMEM | Carga do `.data` | Byte/halfword | Onde ficou (IMEM / DMEM / banco) | MMIO | Reset: tipo — o que zera | Efeito do reset na síntese |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| 00 | **Este TCC** | Harvard | 4 KiB, combinacional + instrução registrada | `$readmemh` | 1 KiB, leitura comb. | `$readmemh` | completos | LUTs / LUTRAM / LUTRAM | sim (4 + 4 regs) | síncrono alto — só o PC | nenhum |
| 01 | Asghar | Harvard | 1 KiB, comb. | `$readmemh` | 1 KiB, comb. | `$readmemh` | completos | LUTs / LUTRAM / LUTRAM | não (alias) | síncrono alto — só o PC | nenhum |
| 02 | Zongo | Harvard | 1 KiB, comb. | `$readmemh` | 1 KiB, comb. | não há | só palavra | LUTs / LUTRAM / LUTRAM | não (alias) | síncrono alto — só o PC | nenhum |
| 03 | Rudi-RV32I | Harvard modificada (barramento) | 4 KiB, **BRAM síncrona** | constante VHDL | 4 KiB, **BRAM síncrona** | constante VHDL | completos | BRAM / BRAM / LUTRAM duplicado | sim (do autor; fora da medição) | síncrono alto — só o PC (não bloqueia a escrita corrente) | nenhum |
| 04 | Shyam | Harvard | 512 B, comb. | `$readmemh` | 512 B, comb. | não há (zerada) | só palavra | LUTs / LUTRAM / **FFs** | não | assíncrono alto — só o PC | nenhum (banco em FFs pelo estilo do código) |
| 05 | basic_rv32s | Harvard | 4 KiB, comb. | `initial` (patch: `$readmemh`) | 4 KiB, comb. | zerada (patch: `$readmemh`) | stores completos; loads sem alinhamento | LUTs / LUTRAM / LUTRAM | não (alias) | assíncrono alto — só o PC | nenhum |
| 06 | HarieshAnbalagan | Harvard | 256 B, comb. | `$readmemh` | 256 B, comb. | `$readmemh` | errados | LUTs / LUTRAM / LUTRAM | não | assíncrono alto — só o PC | nenhum |
| 07 | Pequeno-Risco-5 | Harvard | 1 KiB, comb. | `$readmemh` | 4 KiB, comb. | não há (zerada) | só palavra | LUTs / **FFs (32.768)** / **FFs** | não | síncrono alto — PC, banco e **toda a DMEM** | **impede LUTRAM** |
| 09 | Casacuberta | Harvard | 1 KiB alcançável, comb. | reset (patch: `initial`) | 1 KiB, comb. | não há (zerada) | sem `addr[1:0]` | LUTs / **FFs (8.192)** / **FFs** | não | **assíncrono baixo** — PC, banco, **toda a DMEM**, timer | **impede LUTRAM** |
| 11 | BRISC-V | **unificada** | 256 B compartilhados, **BRAM síncrona** | só testbench (patch: `$readmemh`) | os mesmos 256 B | não há (endereço 0 é código) | completos | BRAM (4 RAMB18) / idem / **FFs** | não | síncrono alto — PC e x0 | o reset de x0 **impede LUTRAM no banco** |

O reset dos núcleos 07 e 09 **zera** a DMEM (e o banco), não restaura o conteúdo inicial: um laço escreve 0 em
cada palavra (`data_memory.v` do 07; `mem_data.v` do 09, que só recarrega o arquivo com `$readmemh` dentro do reset
em simulação, com `LOAD_MEMS`). O conteúdo do `.mem` só volta reconfigurando a FPGA. No 11, o reset só zera x0, que já
deveria ser 0.

## 8. Microarquitetura e caminho crítico

| # | Núcleo | CPI | Registrador além do PC | Bordas | Decisão de desvio | Endereço da DMEM | Mux de write-back | Banco de registradores | Por que o caminho crítico é esse |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-: | :-- | :-- |
| 00 | **Este TCC** | 1 | instrução | subida | comparador dedicado | somador dedicado rs1+imm | 2 | LUTRAM | a ROM continua no ciclo, mas só em série com a decisão do desvio (instrução → banco → comparador → próximo PC → ROM → instrução); o caminho de dados (ALU → DMEM → write-back) corre em paralelo |
| 01 | Asghar | 1 | — | subida | comparador dedicado | ALU | 3 | LUTRAM | ROM + banco + ALU + DMEM + write-back em série |
| 02 | Zongo | 1 | — | subida | comparador dedicado | ALU | 3 | LUTRAM | idem; alvo de JAL/JALR também sai da ALU |
| 03 | Rudi-RV32I | 1 (load 2) | saída da BRAM | subida | comparador dedicado | somador dedicado | 4 | LUTRAM ×2 | começa na saída da BRAM (clock-to-out alto) e atravessa a decodificação de janelas e o alinhamento da `bus_bridge` |
| 04 | Shyam | 1 | — | subida | ALU + detector de zero | ALU | 4 | **FFs** | PC → ROM → banco → ALU → zero → somador do alvo → PC (28 níveis) |
| 05 | basic_rv32s | 1 | — (58 latches) | subida | ALU + zero | ALU | 4 | LUTRAM | ROM → controle com latches → ALU → DMEM → write-back |
| 06 | HarieshAnbalagan | 1 | — | **subida e descida** | comparador dedicado | ALU | 5 | LUTRAM (escrita na descida) | caminho do load inteiro em **meio ciclo** |
| 07 | Pequeno-Risco-5 | 1 | — | subida | ALU + zero | ALU | 2 | **FFs** | mux 1024:1 da DMEM em FFs em série; 83 % rota |
| 09 | Casacuberta | 1 ⁵ | — | subida | ALU + zero | ALU | 4 | **FFs** | ciclo inteiro com o mux 32:1 do banco e o 256:1 da DMEM em FFs; 77 % rota |
| 11 | BRISC-V | **2** (load ≥ 3) | saída da BRAM | subida | ALU | ALU | 2 | **FFs** | hazard/flush → decodificação → ALU → comparação de 32 bits do `d_mem_hazard` → CE de 1.024 FFs |

⁵ Um desvio não tomado trava o PC.

## 9. Fora das tabelas

| # | Núcleo | Motivo |
| :-- | :-- | :-- |
| 08 | cdlavila (base de Paula Jr. & Della Colleta, UNIFEI, DOI 10.29327/1626690.7-92) | Só a síntese terminou (32.610 LUTs, 8.214 latches, ~55,6 MHz estimados). O roteamento falhou por congestionamento depois de 2 h, por causa da DMEM em latches. |
| 10 | Semi-Edge (El-Helwani & Khalid, IEEE Access 2026, DOI 10.1109/ACCESS.2026.3705296) | A síntese passou de 60 min (DMEM de 4 KiB em 32.768 FFs). O RTL tem erros funcionais. |
| 12 | Wildcat (Schoeberl, WOSET 2024) | Chisel; gerar o Verilog exige JDK 17 + sbt, que não estão instalados. |
| 13 | Poli et al. (IEEE MSN 2021, DOI 10.1109/MSN53354.2021.00037) | RV64I de 7 instruções. Mediu 96,8 MHz, 462 LUTs e 200 FFs com o programa do autor, mas o núcleo quase todo foi podado: não é comparável. |
| 14 | marslan6 | O repositório só tem blocos soltos, sem um topo que forme o núcleo. |

Excluídos antes da medição, por não serem monociclo ou estarem incompletos: Risco-5 (multiciclo), insper-riscv
(multiciclo), rvx (pipeline) e Anicvedi (só ALU e gerador de imediatos).

## 10. Conclusões

- **Frequência:** o TCC tem a maior Fmax entre os comparados (97,8 MHz, a 0,23 ns de fechar 100 MHz). O segundo
  é o Rudi (75,5 MHz), que aceita load em 2 ciclos; entre os monociclos puros, o melhor é o Zongo (70,0 MHz).
- **Por que o TCC é mais rápido** (§8): fora o Rudi e o BRISC-V, que registram a instrução na saída de
  uma BRAM síncrona e por isso perdem o CPI = 1, nenhum outro registra a instrução. Neles o caminho crítico
  começa no PC e atravessa a ROM, e 8 dos 9 usam a ALU para o endereço da DMEM e 5 deles também para decidir o
  desvio. O TCC usa instrução registrada, comparador de desvio e somador de endereço dedicados, e o write-back de 2
  entradas. Com isso fica em 12 níveis e 10,18 ns. Só o Rudi e o Hariesh também têm 12 níveis, mas o caminho do
  Rudi começa na saída de uma BRAM (clock-to-out maior, 12,96 ns) e o do Hariesh precisa caber em meio ciclo. Os
  outros 7 vão de 14 a 28 níveis.
- **A instrução registrada não é um estágio de pipeline.** A ROM é endereçada pelo *próximo* PC, e a instrução é
  registrada na mesma borda que o PC, então o registrador sempre guarda `ROM[PC]`, a instrução do ciclo corrente.
  A leitura da ROM continua dentro do ciclo: o caminho crítico medido é instrução → banco (LUTRAM) → comparador →
  `branch_taken` → mux do próximo PC → ROM → instrução. O ganho é tirar a ROM de *série* com o caminho de dados
  (ALU → DMEM → write-back), que passa a correr em paralelo com ela. É a mesma ideia de uma ROM síncrona endereçada
  pelo próximo PC, que o Rudi também usa com BRAM; custa 32 FFs e mantém o CPI = 1 em todas as instruções.
- **Reset nas memórias** (§7): os núcleos que zeram o banco ou a DMEM no reset (07, 09, 11 no banco) perdem a
  LUTRAM. A área cresce até 30×, e a potência, o tempo de compilação e o roteamento pioram junto. O TCC só reseta o PC.
- **Área:** o TCC (1.266 LUTs) está no meio da faixa dos núcleos com DMEM e banco em LUTRAM, que vai de 867 a
  1.984 LUTs (Hariesh, Zongo, Asghar e basic_rv32s), mesmo com IMEM de 4 KiB, o programa completo, MMIO e as 37
  instruções corretas. Os dois desse grupo que ficaram menores, Hariesh (867) e Zongo (1.176), cobrem menos: sem
  byte/halfword corretos nem MMIO, e com IMEM 4× (Zongo) a 16× (Hariesh) menor. O Rudi (985) fica abaixo porque as
  memórias estão em BRAM.
- **Corretude** (§5): só o TCC, o Rudi e o BRISC-V executam as 37 instruções pela leitura do código. Só o TCC e o
  Rudi tratam a codificação inválida como NOP.
- **Números publicados pelos autores** não são comparáveis direto: outro FPGA (Zongo em Zynq, BRISC-V em Cyclone IV),
  um programa mínimo que deixa a síntese podar o núcleo (Zongo, Poli, Wildcat) ou a medição só do periférico (Shyam).
