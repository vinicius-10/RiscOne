# 03_rudi — Diferenças × núcleo do TCC

Variante analisada: a medida no `-Final`, **sem ponte registrada** (`bus_bridge_use_clk='0'`, `minimize_size='0'`).
Caminhos relativos a `repo/src/`. Nota: com a ponte registrada (`-Tag ponte`), o load leva 3 ciclos e o store 2,
com 86,7 MHz e 119 FFs.

## 1. Conjunto de instruções
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente (pela leitura) | 37: LUI, AUIPC, JAL, JALR, 6 desvios, 5 loads, 3 stores, 9 OP-IMM, 10 OP (`cpu/decode.vhd:186-500`). Não verifiquei em simulação aqui; o autor tem o `test_benches/tb_riscv.vhd` | 37 (verificadas em testbench) |
| Lista das que faltam / viram NOP / estão erradas (com o motivo) | nenhuma | nenhuma |
| FENCE / ECALL / EBREAK | NOP. Achado: os ramos de FENCE (`"0001111"`) e SYSTEM (`"1110011"`) estão aninhados por engano dentro do `case func7` do opcode OP (`cpu/decode.vhd:501,509`), então nunca casam como opcode. As três instruções caem no `when others` do opcode (`:526`) e ficam com os padrões: rd = x0, sem acesso ao barramento, PC+4. Os ramos também são só "TODO" | NOP |
| **Instruções extras além das 40** | nenhuma | nenhuma |
| Codificação inválida (funct3/funct7 inexistente) | vira NOP. Os padrões do decodificador são `out_rdest="00000"`, `bus_enable='0'` e desvio desabilitado (`decode.vhd:161-191`); só as combinações válidas sobrescrevem esses sinais | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Interrupção externa / timer | não (o `millis` é um periférico lido por MMIO, sem interrupção, e ficou fora da medição) | não |
| Traps (instrução ilegal, ECALL, desalinhamento) | não | não |
| CSRs (quais) | nenhum | nenhum |
| Desvio/acesso desalinhado | Sem trap. Todos os alvos de salto são mascarados com `AND x"FFFFFFFC"`, ou seja, zeram os bits 1 e 0 (`cpu/program_counter.vhd:91-96`); o ISA manda o JALR zerar só o bit 0. Acesso a dados desalinhado: a ponte desloca os dados e os bytes que passam da palavra se perdem; na leitura, os bits altos vêm zerados (README, `bus/bus_bridge.vhd:143-157, 233-241`) | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Organização | Harvard modificada. A busca tem porta própria na ROM; os dados passam por um barramento com `bus_bridge` e 3 janelas, e por ele também dá para ler a ROM | Harvard (IMEM e DMEM separadas) |
| IMEM: tamanho, tipo, leitura | 4 KiB (1024×32), ROM **síncrona** endereçada pelo `pc_next`, com a saída registrada na mesma borda do PC (`program_memory/program_memory.vhd:627-636`); só busca se `pc_next(31:12)=x"F0000"`. Tem uma 2ª porta de leitura pelo barramento, com stall de 1 ciclo | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento do programa | constante VHDL no inicializador do sinal (gerada por `c/gen_mem.sh`; aqui por `scripts_local/gera_mem.py` em `patch/`) | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | 4 KiB (1024×32) em BRAM. Leitura **síncrona** com `bus_busy` por 1 ciclo (`program_memory/ram_memory.vhd:57-66`); escrita na subida, com máscara por byte | 1 KiB LUTRAM; leitura combinacional, escrita na subida do clock |
| DMEM: carga do `.data` inicial | constante VHDL no inicializador (vai no bitstream) | `$readmemh` em `initial` (vai no bitstream) |
| Byte/halfword, extensão de sinal, byte enables | completos: a máscara de escrita é feita na ponte (`bus_bridge.vhd:155-176`) e a extensão no `cpu/sign_extender.vhd` | completos (LB/LH/LBU/LHU/SB/SH) |
| Onde a síntese colocou cada memória | 3 RAMB36: a ROM virou 2 blocos (um por porta) e a DMEM 1. Precisou de `rom_style="block"`; sem o atributo, a porta de busca ia para LUTs | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos e mapa | O autor tem UART, GPIO e contador de ms atrás de um `bus_expander` em `0xE000_0000`, com ROM em `0xF000_0000` e RAM em `0x1000_0000`. Na medição, só um MMIO mínimo do wrapper em `0x4000_0000` (LEDs/chaves) e a RAM em 0 | sim: `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |

## 4. Reset
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| Síncrono/assíncrono, polaridade | síncrono, ativo alto. É combinacional no decodificador: força `pc_mode = PC_RESET_STATE` (`cpu/decode.vhd:529-532`), e o próximo PC vira `0xF000_0000` | síncrono, ativo alto (`CPU_RESETN` invertido no top) |
| O que o reset zera (PC, banco, DMEM, MMIO, outros) | Só o próximo PC (vetor `0xF000_0000`). Achados: (a) o reset não anula a escrita no banco nem o store da instrução corrente (`decode.vhd:529-532` só mexe no `pc_mode`); (b) com `minimize_size='0'`, se a instrução corrente for um desvio tomado, `take_branch='1'` tem prioridade sobre o `PC_RESET_STATE` (`program_counter.vhd:90-91`). Nesse caso o reset só pega no ciclo seguinte | só o PC (a instrução registrada volta à do endereço 0) |
| Efeito na síntese (impede LUTRAM/BRAM?) | nenhum (banco em LUTRAM, memórias em BRAM) | nenhum |

## 5. Microarquitetura e caminho crítico
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| CPI de fato (busca, load, store) | busca 1; **load 2** (stall da BRAM via `bus_busy`); store 1. Com a ponte registrada, load 3 e store 2 | 1 |
| Registradores no caminho além do PC | registrador de saída da BRAM da IMEM (instrução); o registrador de saída da BRAM da DMEM (o load usa o 2º ciclo) | instrução registrada (tira a leitura da ROM do caminho) |
| Bordas de clock usadas | só subida | só subida |
| Decisão de desvio | comparador dedicado rs1×rs2 (`cpu/branch_test.vhd`, `=`, `<` com sinal e sem sinal), fora da ALU | comparador dedicado rs1×rs2, fora da ALU |
| Alvo de desvio / PC+4 | Com `minimize_size='0'`, somadores separados para PC+imm_B, PC+imm_J, rs1+imm e PC+4, com mux de 5 entradas (`program_counter.vhd:90-99`) | somadores dedicados |
| Endereço da DMEM | somador dedicado rs1+offset (`cpu/riscv_cpu.vhd:326`). Depois dele, a decodificação de janela da ponte (`(addr AND mask) = base` × 3) e o alinhamento por `addr(1:0)` ficam em série com o dado lido | somador dedicado rs1+imm; flags de região sem esperar o carry |
| ALU (operações, shifter, SLT/SLTU) | ALU: OR/AND/XOR/ADD/SUB/SLT/SLTU. O SLT/SLTU é um comparador `<` com o bit de sinal invertido no modo com sinal (`cpu/alu.vhd`). O shifter é um bloco separado (barrel shifter, `cpu/shifter.vhd`) | add/sub, shifter, SLT/SLTU pelo carry |
| Mux de write-back / mux do próximo PC (nº de entradas) | write-back com 4 entradas: ALU, shifter, PC+4 e memória (`cpu/result_bus_mux.vhd`). Próximo PC com 5: desvio, PC+4, JAL, JALR, reset; mais o hold quando `busy` | write-back: 2 entradas (ALU × memória); próximo PC: reset / PC+4 / alvo |
| Banco de registradores | 32×32 em LUTRAM **duplicado**, uma cópia por porta de leitura (`registers_1`/`_2`, `cpu/register_file.vhd`). A 3ª cópia, de depuração, é podada. Leitura assíncrona; x0 nunca é escrito (`write_port_addr /= "00000"`) | 32×32 LUTRAM, leitura assíncrona, x0 por mux |
| Caminho crítico medido | BRAM da IMEM (`instr_reg_reg/CLKARDCLK`) → `register_file` (`registers_2.../RAMA/I`), 12 níveis, 12,96 ns. Sequência: leitura do banco (RAMD32) → somador do endereço de load (3 CARRY4) → decodificação de janela e mux de leitura da ponte → alinhamento/extensão de sinal → mux de write-back → escrita no banco | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação
| Item | Este núcleo | TCC |
| :-- | :-- | :-- |
| HDL, nº de módulos, linhas de RTL | VHDL-93. 11 entidades na CPU + `bus_bridge` + 2 memórias, cerca de 2.370 linhas contando cabeçalhos (a ROM de teste pesa bastante) | SystemVerilog |
| Testbench próprio / riscv-tests | `test_benches/tb_riscv.vhd` (estímulo; não li como autoverificável), sem riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | (1) FENCE/SYSTEM aninhados no `case func7` do OP (`decode.vhd:501,509`); sem efeito prático, porque viram NOP de qualquer jeito. (2) O reset não bloqueia a escrita da instrução corrente, e um desvio tomado tem prioridade sobre o reset (`decode.vhd:529`, `program_counter.vhd:90`). (3) Os alvos de salto zeram os bits 1 e 0, não só o bit 0. (4) O acesso desalinhado perde bytes (documentado pelo autor) | — |

## O que explica a diferença de caminho crítico e área em relação ao TCC

O Rudi fecha a 75,5 MHz (12,96 ns), contra 97,8 MHz (10,18 ns) do TCC. O nível de lógica é o mesmo (12); o que pesa é a origem e o percurso:

- **Origem do caminho.** No Rudi ele começa na saída de uma BRAM, cujo clock-to-out é bem maior que o de um FF, e essa BRAM fica longe da lógica (7,996 ns de rota).
- **Percurso do load.** O caminho atravessa a lógica de barramento que o TCC não tem. Depois do somador rs1+offset vêm a decodificação de 3 janelas por máscara, o mux de leitura e o alinhamento por `addr(1:0)` na `bus_bridge`, e por fim o write-back de 4 entradas.
- **Estratégia do autor.** Ele aceita CPI > 1 nos loads (BRAM síncrona) e, para subir o clock, oferece a ponte registrada (86,7 MHz aqui, com load de 3 ciclos).
- **Área.** O Rudi tem menos LUTs (985 contra 1.266), porque as duas memórias de 4 KiB estão em 3 RAMB36, enquanto no TCC a ROM de 4 KiB ocupa centenas de LUTs e a DMEM fica em LUTRAM. O banco duplicado em LUTRAM (44 LUTRAM) e o PC com somadores separados (`minimize_size='0'`) acrescentam lógica, e os FFs ficam baixos (49) porque PC e LEDs são quase os únicos registradores fora das memórias.

Para comparar de forma justa, o custo das memórias deve ser contado em BRAM e em LUTs juntos, e o CPI de loads (2) deve entrar no desempenho efetivo.
