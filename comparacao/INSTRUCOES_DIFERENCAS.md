# Análise de diferenças × núcleo do TCC (só leitura de código)

Tarefa: ler o RTL do seu núcleo (em `repo/`, e `patch/` se houver) e o do TCC
(`D:\valuc\vivado\projects\processador_riscV_comparacao\processador_riscV.srcs\sources_1\new\`, se precisar
conferir algo; a coluna TCC abaixo já está preenchida) e gravar `NN_*/DIFERENCAS.md` com as tabelas 1–6,
colunas **Item | Este núcleo | TCC**. Responda pelo código (cite arquivo:linha quando for um achado).

Regras: **não rode Vivado nem simulação**; não execute nada do repositório; não edite nada fora do
`DIFERENCAS.md`; seja econômico em tokens. Resposta final ao coordenador: 3–5 linhas.

## 1. Conjunto de instruções (as 40 de referência = 37 RV32I + FENCE, ECALL, EBREAK)
| Item | TCC |
| :-- | :-- |
| Quantas das 37 RV32I estão implementadas corretamente (pela leitura) | 37 (verificadas em testbench) |
| Lista das que faltam / viram NOP / estão erradas (com o motivo) | nenhuma |
| FENCE / ECALL / EBREAK | NOP |
| **Instruções extras além das 40** (M, CSR/Zicsr, contadores, MRET, customizadas…) — liste todas | nenhuma |
| Codificação inválida (funct3/funct7 inexistente) | vira NOP (decodificação estrita) |

## 2. Interrupções, exceções e traps
| Item | TCC |
| :-- | :-- |
| Interrupção externa / timer | não |
| Traps (instrução ilegal, ECALL, desalinhamento) | não |
| CSRs (quais) | nenhum |
| Desvio/acesso desalinhado | ignorado, sem trap (JALR zera só o bit 0) |

## 3. Memórias
| Item | TCC |
| :-- | :-- |
| Organização | Harvard (IMEM e DMEM separadas) |
| IMEM: tamanho, tipo, leitura | 4 KiB ROM em LUTs, combinacional; a palavra é registrada no `search` |
| IMEM: carregamento do programa | `$readmemh` em `initial` |
| DMEM: tamanho, leitura / escrita | 1 KiB LUTRAM; leitura combinacional, escrita na subida do clock |
| DMEM: carga do `.data` inicial | `$readmemh` em `initial` (vai no bitstream) |
| Byte/halfword, extensão de sinal, byte enables | completos (LB/LH/LBU/LHU/SB/SH) |
| Onde a síntese colocou cada memória (ver `build/final/util*.rpt`) | ROM em LUTs, DMEM em LUTRAM |
| MMIO / periféricos e mapa | sim: `0x4000_0000`, 4 saídas + 4 entradas de 32 bits |

## 4. Reset
| Item | TCC |
| :-- | :-- |
| Síncrono/assíncrono, polaridade | síncrono, ativo alto (`CPU_RESETN` invertido no top) |
| O que o reset zera (PC, banco, DMEM, MMIO, outros) | só o PC (a instrução registrada volta à do endereço 0) |
| Efeito na síntese (impede LUTRAM/BRAM?) | nenhum |

## 5. Microarquitetura e caminho crítico
| Item | TCC |
| :-- | :-- |
| CPI de fato (busca, load, store) | 1 |
| Registradores no caminho além do PC | instrução registrada (tira a leitura da ROM do caminho) |
| Bordas de clock usadas | só subida |
| Decisão de desvio | comparador dedicado rs1×rs2, fora da ALU |
| Alvo de desvio / PC+4 | somadores dedicados |
| Endereço da DMEM | somador dedicado rs1+imm; flags de região sem esperar o carry |
| ALU (operações, shifter, SLT/SLTU) | add/sub, shifter, SLT/SLTU pelo carry |
| Mux de write-back / mux do próximo PC (nº de entradas) | write-back: 2 entradas (ALU × memória); próximo PC: reset / PC+4 / alvo |
| Banco de registradores | 32×32 LUTRAM, leitura assíncrona, x0 por mux |
| Caminho crítico medido (origem → destino, níveis — `build/final/resumo.txt`) e por que é esse | instrução registrada → instrução registrada, 12 níveis, 10,18 ns |

## 6. Projeto e verificação
| Item | TCC |
| :-- | :-- |
| HDL, nº de módulos, linhas de RTL | SystemVerilog |
| Testbench próprio / riscv-tests | testbenches autoverificáveis + autoteste em C |
| Erros encontrados na leitura | — |

## Fechamento
Um parágrafo **"O que explica a diferença de caminho crítico e área em relação ao TCC"**, ligando os itens
acima aos números do seu `build/final/resumo.txt`.
