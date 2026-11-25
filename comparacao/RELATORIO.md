# Comparação de núcleos RISC-V monociclo — mesmas condições do TCC

Data: 25/11/2026. Todos os núcleos foram sintetizados e implementados com o mesmo fluxo:

- **Vivado e placa:** Vivado 2025.2 non-project, xc7a100tcsg324-1 (Nexys A7-100T), `maxThreads 8`.
- **Etapas:** `synth_design` → `opt_design` → `place_design` → `route_design`, com as diretivas padrão.
- **Clock:** 100 MHz (10 ns) no pino E3, ligado direto ao núcleo, sem divisor nem PLL.
- **Programa na ROM:** o mesmo `autoteste_placa` (389 instruções, as 37 do RV32I), truncado quando a IMEM do autor é menor.
- **LEDs:** registrados com o dado de store (ou com o MMIO), para a síntese não podar o núcleo.
- **Execução final:** a medição `-Final` rodou com o Vivado sozinho na máquina, para que o tempo de compilação seja comparável.

Script em `scripts/medir.ps1`. Os detalhes de cada núcleo estão em `NN_*/NOTAS.md`, os relatórios do Vivado em `NN_*/build/final/` e os números brutos em `resultados.csv`.

**Fmax** = 1/(período mínimo) = 1000/(10 − WNS) MHz. A exceção é o caminho crítico de meio ciclo (06): nele o requisito é de 5 ns, então a Fmax vale 1000/(2·(5 − WNS)).

**Potência:** vem do `report_power` vetorless. O valor é estimado, não medido na placa. A parte estática (~0,097 W) é praticamente igual para todos, porque depende do dispositivo; para comparar núcleos, use a coluna da dinâmica.

## 1. Trabalhos

| # | Autor(es) | Trabalho / artigo | Código | Commit |
| :-- | :-- | :-- | :-- | :-- |
| 00 | Este TCC | RiscOne (`top_core`) | — | — |
| 01 | Awais Asghar (NCDC) | Relatório de projeto “Single-Cycle RISC-V Processor” | [GitHub](https://github.com/Awais-Asghar/Single-Cycle-RISC-V-Processor-Implemented-on-FPGA) | c60e828 |
| 02 | W. C. D. Zongo | Projeto pessoal, sem artigo (2026) | [GitHub](https://github.com/WendyamZongo/rv32i-core) | fbd1fb6 |
| 03 | Mike Field (hamsternz) | Rudi-RV32I, hobby (doc. em PDF no repositório) | [GitHub](https://github.com/hamsternz/Rudi-RV32I) | f3d8bed |
| 04 | C. Shyam Sundhar (IIT Bhubaneswar) | Projeto acadêmico, sem artigo | [GitHub](https://github.com/shyamch06/RISC-V-Single-Cycle-Processor) | 2f8d204 |
| 05 | Kang & Choi (RISC-KC) | “basic_RV32s”, IEEE ISOCC 2025, DOI 10.1109/ISOCC66390.2025.11329889 | [GitHub](https://github.com/RISC-KC/basic_rv32s) | 672fe02 |
| 06 | Hariesh Anbalagan | Projeto educacional, sem artigo | [GitHub](https://github.com/HarieshAnbalagan/RV32I) | 35daf6c |
| 07 | Julio N. Avelar (JN513) | Pequeno-Risco-5, projeto pessoal | [GitHub](https://github.com/JN513/Pequeno-Risco-5) | 27b7a95 |
| 08 | C. D. Londoño Avila (UTP, 2021); base de Paula Jr. & Della Colleta (UNIFEI), DOI 10.29327/1626690.7-92 | Processador unicycle RV32I | [GitHub](https://github.com/cdlavila/unicycle-processor-risc-v-rv32i) | 8abdd2d |
| 09 | Casacuberta (4a1c0) | TFG, UAB 2020 ([PDF](https://ddd.uab.cat/pub/tfg/2020/tfg_244100/TFG_GEI_Informe_Final.pdf)) | [GitHub](https://github.com/4a1c0/RV32i-Verilog) | 99ec0f9 |
| 10 | El-Helwani & Khalid | “LLM-Aided Design and Evaluation of a RISC-V Processor”, IEEE Access 2026, DOI 10.1109/ACCESS.2026.3705296 | [GitHub](https://github.com/majidale/Semi-Edge-RISC-V) | 55039c5 |
| 11 | Bandara, Ehret, Kava & Kinsy (BU) | “BRISC-V”, ACM/SIGDA FPGA ’19, DOI 10.1145/3289602.3293991 | [BRISC-V Explorer](https://ascslab.org/research/briscv/explorer/explorer.html), sem GitHub | config. do usuário |
| 12 | Martin Schoeberl | “The Educational RISC-V Microprocessor Wildcat”, WOSET 2024 | [GitHub](https://github.com/schoeberl/wildcat) | 3594f0d |
| 13 | Poli et al. (Univ. of Essex) | “Minimal RISC-V CPU on FPGA”, IEEE MSN 2021, DOI 10.1109/MSN53354.2021.00037 | [GitHub](https://github.com/Ludini1/minimal-risc-v-cpu) | 191b496 |
| 14 | marslan6 | RV32I Processor Core, sem artigo | [GitHub](https://github.com/marslan6/Risc-V) | bf99a53 |

## 2. Timing (implementação completa, após o roteamento)

| # | Núcleo | Fmax (MHz) | WNS (ns) | TNS (ns) | Endpoints violando | WHS (ns) | Caminho crítico (ns): lógica / rota | Níveis | Origem → destino |
| :-- | :-- | --: | --: | --: | --: | --: | :-- | --: | :-- |
| 00 | **Este TCC** | **97,8** | −0,228 | −0,228 | 1 / 2.010 | 0,091 | 10,18: 2,66 / 7,51 | 12 | instrução registrada → instrução registrada |
| 13 | Poli ¹ | 96,8 | −0,330 | −1,4 | 7 | 0,238 | 10,40: 5,28 / 5,12 | 24 | PC → PC |
| 03 | Rudi-RV32I ² | 75,5 | −3,237 | −359,8 | 226 / 769 | 0,520 | 12,96: 4,97 / 8,00 | 12 | BRAM da ROM → banco de registradores |
| 02 | Zongo | 70,0 | −4,293 | −1.539,7 | 1.139 / 1.936 | 0,335 | 13,95: 2,77 / 11,18 | 14 | PC → banco de registradores |
| 04 | Shyam | 68,6 | −4,575 | −3.710,6 | 1.521 / 2.672 | 0,212 | 14,59: 5,55 / 9,04 | 28 | PC → PC |
| 01 | Asghar | 66,0 | −5,141 | −1.786,6 | 1.268 / 1.940 | 0,427 | 14,83: 3,86 / 10,97 | 17 | PC → banco de registradores |
| 05 | basic_rv32s | 62,7 | −5,959 | −12.370,6 | 5.222 / 5.238 | 0,536 | 15,65: 3,47 / 12,18 | 17 | PC → banco de registradores |
| 11 | BRISC-V ³ | 54,9 (≈27 efetivo) | −8,212 | −12.743,9 | 2.185 / 2.365 | 0,181 | 17,97: 5,04 / 12,93 | 20 | endereço da BRAM → banco de registradores |
| 09 | Casacuberta | 51,1 | −9,571 | −63.118,7 | 16.465 / 18.597 | 0,143 | 19,19: 4,31 / 14,88 | 23 | PC → banco de registradores |
| 07 | Pequeno-Risco-5 | 42,5 | −13,520 | −425.571,9 | 58.729 / 67.600 | 0,230 | 23,32: 3,86 / 19,46 | 17 | PC → banco de registradores |
| 06 | HarieshAnbalagan ⁴ | **39,3** | −7,721 | −983,5 | 310 / 924 | 0,476 | 12,23 em meio ciclo: 2,20 / 10,03 | 12 | PC → banco de registradores (escrita na borda de descida) |

¹ RV64I com 7 instruções e o programa do próprio autor (6 instruções). O núcleo foi quase todo podado, então **não é comparável**.
² Load em 2 ciclos (BRAM síncrona), então o CPI não é 1 estrito. A variante com a ponte de barramento registrada, fora do CSV, chega a 86,7 MHz com 119 FFs.
³ Configuração do usuário no Explorer. A memória é unificada em BRAM síncrona, então o **CPI é 2** (cada instrução é seguida de uma bolha), e o desempenho equivale a uns 27 MHz em monociclo.
⁴ O script calcula 56,4 MHz, mas o pior caminho termina na borda de descida (requisito de 5 ns). A Fmax real é 1000/(2·12,72) ≈ 39,3 MHz.

## 3. Área, potência e tempo de compilação

| # | Núcleo | LUTs | LUTRAM | FFs | Latches | F7 | F8 | CARRY4 | Slices | BRAM | DSP | IOB | Potência total / dinâmica (W) | Compilação (s): synth / opt / place / route | Pico de RAM (MB) |
| :-- | :-- | --: | --: | --: | --: | --: | --: | --: | --: | --: | --: | --: | :-- | :-- | --: |
| 00 | **Este TCC** | 1.266 | 172 | 98 | 0 | 144 | 33 | 42 | 358 | 0 | 0 | 63 ᵃ | 0,146 / 0,048 | **110**: 37 / 8 / 13 / 41 | 2.070 |
| 01 | Asghar | 1.374 | 172 | 48 | 0 | 114 | 57 | 59 | 376 | 0 | 0 | 18 | 0,147 / 0,049 | 166: 72 / 13 / 35 / 33 | 2.067 |
| 02 | Zongo | 1.176 | 172 | 48 | 0 | 114 | 57 | 58 | 326 | 0 | 0 | 18 | 0,200 / 0,102 | 136: 43 / 7 / 39 / 35 | 2.064 |
| 03 | Rudi-RV32I | 985 | 44 | 49 | 0 | 0 | 0 | 71 | 290 | 3 | 0 | 34 | 0,121 / 0,024 | 103: 38 / 8 / 20 / 25 | 2.069 |
| 04 | Shyam | 2.454 | 64 | 1.077 | 5 | 314 | 67 | 60 | 654 | 0 | 0 | 18 | 0,240 / 0,142 | 161: 45 / 7 / 48 / 48 | 2.086 |
| 05 | basic_rv32s | 1.984 | 556 | 108 | 58 | 351 | 129 | 48 | 587 | 0 | 0 | 18 | 0,127 / 0,030 | 132: 35 / 7 / 44 / 33 | 2.071 |
| 06 | HarieshAnbalagan | 867 | 76 | 48 | 0 | 0 | 0 | 42 | 261 | 0 | 0 | 18 | 0,132 / 0,035 | 119: 46 / 7 / 30 / 24 | 2.052 |
| 07 | Pequeno-Risco-5 | 11.878 | 0 | 33.818 | 10 | 4.657 | 2.136 | 25 | 11.816 | 0 | 0 | 18 | 1,179 / 1,079 | 758: 277 / 11 / 212 / 226 | 2.412 |
| 09 | Casacuberta | 4.986 | 0 | 9.339 | 0 | 1.213 | 492 | 48 | 3.146 | 0 | 0 | 18 | 0,264 / 0,166 | 322: 139 / 8 / 77 / 81 | 2.519 |
| 11 | BRISC-V | 1.584 | 0 | 1.170 | 0 | 301 | 2 | 80 | 554 | 2 (4 RAMB18) | 0 | 18 | 0,160 / 0,063 | 207: 35 / 11 / 69 / 79 | 2.106 |
| 13 | Poli ¹ | 462 | 0 | 200 | 0 | 0 | 0 | 40 | 144 | 0 | 0 | 18 | 0,105 / 0,008 | 179: 119 / 7 / 18 / 22 | 2.072 |

ᵃ O TCC tem mais IOB porque usa os periféricos reais da placa: 7 segmentos, botões e PMOD. Nos outros só há clock, reset, LEDs e chaves.
O tempo total inclui as etapas da tabela e mais a leitura dos fontes, os relatórios e o `report_power`.

## 4. Memórias, ISA e alertas

| # | Núcleo | CPI | IMEM / DMEM (onde ficaram) | Banco de registradores | Programa | Alertas |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| 00 | Este TCC | 1 | 4 KiB ROM em LUTs / 1 KiB LUTRAM + MMIO | LUTRAM | completo (389) | 37 instruções verificadas por testbench |
| 01 | Asghar | 1 | 256 palavras / LUTRAM | LUTRAM | truncado em 256 | sem mudanças no RTL; LUI provavelmente errado |
| 02 | Zongo | 1 | 256 palavras / LUTRAM | LUTRAM | truncado em 256 | 31/37 instruções; DMEM só por palavra; publicado 557 LUTs / ~82 MHz em Zynq -2 com programa de 11 instruções |
| 03 | Rudi-RV32I | 1, mas load em 2 ciclos | 4 KiB BRAM síncrona | LUTRAM | completo | publicado 67,8 / 80 MHz; periféricos de fora |
| 04 | Shyam | 1 | 128 palavras / — | FFs | truncado em 128 | funcionalmente incompleto; 5 latches; os ~221 MHz publicados medem o divisor/display |
| 05 | basic_rv32s | 1 | 4 KiB / 4 KiB em LUTRAM | LUTRAM | completo | 58 latches no controle |
| 06 | HarieshAnbalagan | 1 | 256 B / 256 B | LUTRAM | truncado em 64 | escrita na borda de descida; 2 patches de sintaxe |
| 07 | Pequeno-Risco-5 | 1 | 1 KiB / **4 KiB em FFs** | FFs | truncado em 256 | sem JAL/JALR/LUI/AUIPC; o reset da DMEM explode a área |
| 08 | cdlavila | 1 | 1 KiB / **1 KiB em latches** | FFs | truncado em 256 | **roteamento falhou** (ver §5) |
| 09 | Casacuberta | 1 | 1 KiB alcançável / **1 KiB em FFs** | FFs | truncado em 256 | CSRs de contador de 64 bits; desvio não tomado trava o PC (lendo o código) |
| 10 | Semi-Edge | 1 | 4 KiB / **4 KiB em FFs** | — | completo | **não medido** (ver §5) |
| 11 | BRISC-V | **2** | 64 palavras = 256 B **unificada** em BRAM síncrona | FFs | truncado em 64 | a config. do Explorer tem `MEM_ADDRESS_BITS = 6` (256 B, não 1 KiB); artigo: 53.448 LE / 29 MHz em Cyclone IV, arquitetura diferente |
| 13 | Poli | 1 | 256 × 32 / — | FFs | do autor | RV64I de 7 instruções; artigo: 322 LUTs / 229 FFs em Basys 3 |

## 5. Não medidos

| # | Núcleo | Motivo |
| :-- | :-- | :-- |
| 08 | cdlavila | A síntese terminou: 32.610 LUTs, 8.277 FFs (8.214 latches), ~55,6 MHz estimados, 0,88 W. O `route_design` falhou por congestionamento depois de 2 h 04 min (2.903 sinais não roteados). A DMEM virou 8.192 latches e a unidade de controle sem `default` ocupa ~20 mil LUTs. Pela leitura do RTL, executa várias instruções errado: JALR, LUI/AUIPC, LW, SLT/SRA. |
| 10 | Semi-Edge | A síntese passou de 60 min, com a DMEM de 4 KiB em 32.768 FFs. Há erros funcionais no RTL: os desvios só usam a flag de zero, JAL/JALR não gravam PC+4 e AUIPC soma rs1+imm. |
| 12 | Wildcat | Escrito em Chisel; gerar o Verilog exige JDK 17 + sbt, que não estão instalados. O autor publica ~11 MHz em Artix-7, com um programa de piscar LED e quase tudo podado. |
| 14 | marslan6 | O repositório só tem blocos soltos, sem um topo que forme o núcleo. |

Excluídos por não serem monociclo ou estarem incompletos: Risco-5 (multiciclo), insper-riscv (multiciclo), rvx (pipeline) e Anicvedi (só ALU e gerador de imediatos).

## 6. Leitura dos resultados

- **Fmax:** entre os núcleos RV32I comparáveis (programa RV32I, CPI = 1), o deste TCC tem a maior Fmax: 97,8 MHz, a 0,23 ns de fechar 100 MHz. O segundo é o Rudi, com 75,5 MHz e load em 2 ciclos. Entre os monociclos puros vêm depois Zongo (70,0) e Shyam (68,6). O único número parecido, o do Poli (96,8), vem de um núcleo de 7 instruções quase todo podado.
- **Por que o TCC é mais rápido:** nos outros núcleos o caminho crítico é PC → ROM → decodificação → ALU → escrita no banco, num único ciclo de 14 a 23 ns. No TCC, a instrução registrada no `search` (ROM endereçada pelo próximo PC) deixa a ROM em série só com a decisão do desvio, em paralelo com o caminho de dados; ele fica em 12 níveis e 10,2 ns. Ver `docs/COMPARACAO_NUCLEOS.md` §10.
- **Área:** o TCC está na mesma faixa dos núcleos com memórias em LUTRAM (Asghar, Zongo, basic_rv32s, com 1.176 a 1.984 LUTs), mesmo tendo IMEM de 4 KiB, o programa completo e MMIO. Tem 50 FFs a mais por causa da instrução registrada e dos registradores de MMIO.
- **Reset nas memórias:** os núcleos que zeram a memória ou o banco no reset (07, 08, 09, 10) perdem LUTRAM/BRAM e ficam de 5 a 30 vezes maiores. Também são mais lentos, gastam mais energia e demoram mais para compilar; dois nem chegaram ao fim.
- **Potência dinâmica:** o TCC gasta 0,048 W, junto com Asghar e BRISC-V. Rudi, Hariesh e basic_rv32s ficam abaixo (0,024 a 0,035 W), mas com programas truncados ou memórias em BRAM. Os núcleos com memória em FFs vão de 0,166 W a 1,08 W.
- **Tempo de compilação:** o TCC leva 110 s, o segundo menor depois do Rudi (103 s). Os outros RV32I comparáveis levam de 119 a 166 s, e os de memória em FFs, de 322 a 758 s (ou falham).
- **Números publicados:** nenhum dos números de Fmax publicados é comparável direto. Uns medem só o periférico (Shyam), outros usam outro FPGA (Zongo em Zynq -2, BRISC-V em Cyclone IV) ou um programa mínimo que deixa a síntese podar o núcleo (Zongo, Poli, Wildcat). Por isso refazer as medições com o mesmo programa e no mesmo fluxo era necessário.
