# 11 — BRISC-V × TCC (diferenças pela leitura do código)

Núcleo analisado: configuração monociclo gerada pelo usuário no BRISC-V Explorer (`usuario_256/`,
a medida no `-Final`), com os patches de `patch/`. Arquivos citados são de `usuario_256/`, salvo
indicação.

## 1. Conjunto de instruções
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| RV32I implementadas corretamente (codificações válidas) | 37 (pela leitura; não verificadas aqui) | 37 (verificadas em testbench) |
| Faltam / NOP / erradas | nenhuma falta; ver "codificação inválida" | nenhuma |
| FENCE / ECALL / EBREAK | NOP (sem regWrite/memWrite, `control_unit.v:92-98`) | NOP |
| Instruções extras | nenhuma | nenhuma |
| Codificação inválida | **não vira NOP**: R/I com funct7 inexistente e JALR com funct3≠0 caem no `ADD` padrão e escrevem rd (`control_unit.v:92-94`, `125-152`) | NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não | não |
| Traps | não | não |
| CSRs | nenhum | nenhum |
| Desalinhado | sem trap; JALR zera bit 0 (`execution_unit.v:63`); store desalinhado usa máscara do byte base (`memory_issue.v:79-107`) | ignorado, sem trap |

## 3. Memórias
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | **unificada** (uma BRAM dual-port: porta 1 = busca, porta 2 = dados; `dual_port_BRAM_memory_subsystem.v:75-95`) | Harvard |
| IMEM: tamanho, tipo, leitura | 64 palavras = 256 B (`MEM_ADDRESS_BITS = 6`), compartilhada; **leitura síncrona** (`dual_port_BRAM.v:66-74`) | 4 KiB ROM em LUTs, combinacional + instrução registrada |
| IMEM: carregamento | original: só por testbench (escrita hierárquica); aqui `$readmemh` por faixa de byte (patch) | `$readmemh` |
| DMEM: tamanho, leitura/escrita | a mesma 256 B; leitura síncrona, escrita na subida com byte-enable | 1 KiB LUTRAM, leitura combinacional |
| DMEM: `.data` inicial | não há (endereço 0 é código); dados não carregados | `$readmemh` |
| Byte/halfword, sinal, byte enables | completos (`memory_issue.v`, `memory_receive.v`: LB/LH/LW/LBU/LHU, SB/SH/SW) | completos |
| Onde a síntese colocou | 4 RAMB18 (4 faixas 64×8) | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos | nenhum (topo só exporta o PC) | sim, `0x4000_0000` |

## 4. Reset
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Tipo, polaridade | síncrono, ativo alto | síncrono, ativo alto |
| O que zera | PC (`fetch_issue.v:52`) e x0 (`regFile.v:42-44`) | só o PC |
| Efeito na síntese | **sim**: o reset de `register_file[0]` impede LUTRAM ⇒ banco em 1024 FFs | nenhum |

## 5. Microarquitetura e caminho crítico
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato | **2** (busca síncrona: bolha a cada instrução via `i_mem_hazard`/`flush`, `hazard_detection_unit.v:42`, `fetch_receive.v:43`); load ≥ 3 (`d_mem_hazard`, `:45`); confirmado em xsim | 1 |
| Registradores além do PC | registradores de saída da BRAM e `i_mem/d_mem_address_out` (`dual_port_BRAM_memory_subsystem.v:97-102`) | instrução registrada |
| Bordas | só subida (os `negedge` são contadores de `$display`, podados) | só subida |
| Decisão de desvio | **pela ALU** (`ALU.v:59-64`), depois `ALU_result == 1` (`execution_unit.v:60`) | comparador dedicado |
| Alvo / PC+4 | somadores dedicados (branch/JAL no decode, JALR no execute) + PC+4 na ALU para JAL/JALR | somadores dedicados |
| Endereço da DMEM | resultado da ALU (sem somador dedicado) | somador dedicado |
| ALU | cadeia de `?:` com 15 operações; comparações com `<`/`>=` separadas | add/sub, shifter, SLT/SLTU pelo carry |
| Muxes | write-back 2 entradas; próximo PC: PC+4 / segura / alvo / 0 (`fetch_issue.v:54-59`) com alvo em mux de 3 | 2 entradas; reset / PC+4 / alvo |
| Banco de registradores | 32×32 **em FFs** (reset de x0), leitura assíncrona | LUTRAM, x0 por mux |
| Caminho crítico medido | `memory/i_mem_address_out_reg[3]` → CE de `register_file_reg[13][12]`, 20 níveis, 17,97 ns (rota 12,93): endereço da instrução → comparação de hazard/flush → decodificação → ALU → comparação de 32 bits de `d_mem_hazard` → `regWrite` → CE de 1024 FFs (fan-out alto) | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, módulos, linhas | Verilog-2001; 17 arquivos usados, ~2,2 mil linhas (muito cabeçalho e `$display`) | SystemVerilog |
| Verificação | testbench que roda um programa e testa x9 == 0 (`tb_BRISC_V256memoria.v`); sem riscv-tests no pacote | testbenches autoverificáveis + autoteste em C |
| Erros encontrados | (1) codificação inválida executa como ADD; (2) template de RAM com escrita *blocking* em dois `always` não sintetiza no Vivado (`dual_port_BRAM.v` original, Synth 8-2914); (3) memória unificada de 256 B: stores do programa sobrescrevem código; (4) topo exporta `PC = fetch_address_in << 1` (`BRISC_V256memoria.v`), valor sem sentido | — |

Nota: a versão do zip (`BRISC-V_single_cycle_base`, medição secundária) é Harvard, de leitura
assíncrona, com CPI = 1 e 1k palavras, mas o PC tem 10 bits (alcança 256 instruções) e a DMEM só faz LW/SW.

## O que explica a diferença de caminho crítico e área em relação ao TCC

O BRISC-V fica com 54,9 MHz contra 97,8 MHz e 1584 LUTs/1170 FFs contra 1266/98. Ele não registra
a instrução de forma útil: a BRAM síncrona entrega a palavra num registrador, mas o caminho a partir
do endereço registrado ainda atravessa a comparação de hazard e o flush, a decodificação, uma ALU
que também decide desvios (comparações com `<`/`>=` e depois `== 1`) e a comparação de 32 bits do
`d_mem_hazard`, que gera o `regWrite`. Esse sinal termina no CE de 1024 FFs. São 20 níveis, e 72%
do atraso é rota, puxada pelo fan-out do banco em FFs. O TCC tem comparador e somadores dedicados
e banco em LUTRAM, com 12 níveis. Na área, o banco em FFs (o reset de x0 impede LUTRAM) responde
pelos ~1000 FFs a mais e por ~600 LUTs de mux de leitura. Em compensação, a memória vai para 4 RAMB18,
enquanto o TCC gasta LUTs na ROM de 4 KiB e LUTRAM na DMEM. Com CPI = 2, o desempenho efetivo
equivale a ~27 MHz monociclo.
