# 07 — Pequeno-Risco-5 (Julio Nunes Avelar, JN513)

## Trabalho

- Autor: Julio Nunes Avelar (JN513). Projeto pessoal, sem artigo/TCC associado ("construído em alguns dias de folga").
- GitHub: https://github.com/JN513/Pequeno-Risco-5 (arquivado). Licença MIT (2023).
- Commit clonado (`git clone --depth 1`): `27b7a9561618504e1465d2707973e8efaf507f6e` (2024-03-22).
- O autor não publica números de área/frequência; alvos dele são Tang Nano 9K/20K (Gowin) e ECP5.

## Núcleo

- **Monociclo confirmado (CPI = 1):** os únicos elementos sequenciais são o PC, o banco de
  registradores e a escrita da RAM de dados, todos em `posedge clk`. IMEM e leitura da DMEM são
  combinacionais. Baseado no datapath de ciclo único de Patterson & Hennessy (RISC-V).
- HDL: Verilog-2001, um só domínio de clock, borda de subida. Reset síncrono ativo alto (PC, os 32
  registradores e **toda a DMEM** são zerados no reset).
- **ISA real (conferida no código):** só os opcodes OP (R), OP-IMM, LOAD, STORE e BRANCH são
  decodificados pela `Control_Unit` — ~27 instruções, como o README diz. **JAL, JALR, LUI e AUIPC
  não são implementados** (o `Immediate_Generator` tem casos para eles, mas a unidade de controle
  não; FENCE/ECALL/EBREAK também não). Problemas de semântica encontrados (apenas registro, não
  corrigidos):
  - `Control_Unit` sem `default` → **latches** nos sinais de controle; opcodes não suportados
    repetem os sinais da instrução anterior.
  - Só `lw`/`sw`: funct3 de LOAD/STORE é ignorado (lb/lh/lbu/lhu viram lw; sb/sh viram sw).
  - PC conta em **palavras** (`PC+1`), IMEM e DMEM indexadas por palavra; o endereço de dados é o
    resultado da ALU usado direto como índice de palavra (endereço de byte do RISC-V não é
    convertido).
  - Alvo de desvio = `PC + (imm >> 1)` com deslocamento **lógico** → desvios para trás quebram.
  - SLT/SLTI/BLT/BGE comparam **sem sinal** (fios `wire` sem `signed`); SRA/SRAI = deslocamento
    lógico; deslocamentos usam os 32 bits de Y (não só 5).
  - `x0` não é fixo em zero (pode ser escrito).
- Memórias (tamanhos do autor, padrão do `Core`): IMEM 1 KiB = 256 palavras (ROM via `$readmemh`,
  virou LUTs, absorvida junto ao PC); DMEM 4 KiB = 1024 palavras de 32 bits — **implementada em FFs
  (32.768 FFs)** por causa do laço de reset síncrono que zera a RAM inteira (impede LUTRAM/BRAM).
- Banco de registradores: 32 × 32 bits em FFs (1.024 FFs), leitura por `case` (mux).
- Periféricos: nenhum; o núcleo exporta `leds = ~x15[7:0]` direto dos FFs do banco.

## Montagem

- Top do autor (`fpga/*/main.v`) já é limpo (Core + LEDs, clock direto, portas rx/tx sem uso), mas
  escrevi `wrapper/top_cmp.sv` para padronizar as portas: `clk` (100 MHz direto), `CPU_RESETN`
  invertido para `reset`, `led[7:0] = leds` do núcleo (saída já registrada: opção a/c — vem dos FFs
  de `x15`), `led[15:8] = 0`. Sem `switch`. `constr.xdc` = `base.xdc` sem as chaves.
- Programa: `autoteste_placa` (`programa/prog_word.hex`) **truncado para 256 palavras**
  (`mem/prog_word_256.hex`, gerado por `scripts/trunca.py`), pois a IMEM do autor tem 256 palavras.
  O programa serve só como estímulo de síntese: o núcleo não o executaria corretamente (falta JAL/
  JALR/LUI/AUIPC, endereçamento por palavra etc.). DMEM sem imagem de dados (o autor não carrega
  arquivo na DMEM; começa zerada).
- Mudança no RTL (cópia em `patch/instruction_memory.v`): `$readmemh(MEMORY_FILE, memory, 0, 14)`
  → `$readmemh(MEMORY_FILE, memory)`. O original só carrega as 15 primeiras palavras (programa de
  teste dele); sem a mudança, nosso programa não poderia ser carregado.
- Poda verificada em `util_hier.rpt`: Data_memory 8.794 LUTs / 32.768 FFs, PC (+ ROM) 1.717 LUTs,
  registers 1.220 LUTs / 1.024 FFs, Core (ALU, controle, imediato) 121 LUTs — núcleo inteiro presente.

## Resultados (`build/final/resumo.txt`)

| Métrica | Valor |
|---|---|
| Tempo total | 757,7 s (synth 4:37, opt 0:11, place 3:32, route 3:46, power 0:06) |
| Pico de memória | 2.412 MB |
| WNS / TNS | −13,52 ns / −425.571,9 ns |
| Endpoints violando | 58.729 / 67.600 |
| WHS / THS | 0,23 ns / 0 |
| **Fmax** | **42,5 MHz** |
| Caminho crítico | 23,315 ns (lógica 3,858 / rota 19,457), 17 níveis (LUT3=1 LUT4=1 LUT5=2 LUT6=8 MUXF7=3 MUXF8=2), `Core/PC/PC_Register_reg_rep[1]/C` → `Core/registers/register0_reg[11]/D` |
| LUTs | 11.878 (lógica 11.878, LUTRAM 0) |
| FFs | 33.818 (+ 10 latches) |
| F7 / F8 / CARRY4 | 4.657 / 2.136 / 25 |
| Slices | 11.816 |
| BRAM / DSP / IOB | 0 / 0 / 18 |
| Potência | total 1,179 W (dinâmica 1,079 W, estática 0,101 W), Tj 30,4 °C |
| Warnings / critical | 28 / 0; latches: 10 (TIMING-20 non-clocked latch) |

Síntese de iteração (`build/synth`, só synth): 70,4 MHz estimado, 11.817 LUTs, 33.818 FFs.

## Números publicados × medidos

O autor não publica números.

## Observações para a comparação

- **Área e tempo altíssimos são consequência da DMEM em FFs**: 4 KiB em 32.768 FFs + ~8.800 LUTs de
  mux de leitura (F7/F8). O reset síncrono que zera a RAM inteira impede inferir LUTRAM/BRAM. Isso
  domina a área, a potência (1,18 W), a rota longa (83 % do caminho crítico é rota) e o tempo de
  compilação (758 s). A DMEM do autor é 4× a do TCC (1 KiB).
- Caminho crítico: PC → ROM (LUTs) → banco de registradores (mux) → ALU → mux de leitura da DMEM
  em FFs → escrita no registrador.
- Latches na unidade de controle (sem `default`).
- ISA incompleta (sem JAL/JALR/LUI/AUIPC, só lw/sw, comparações sem sinal, SRA errado, x0
  gravável, endereçamento por palavra) — não é RV32I funcional; o programa do TCC foi truncado para
  256 palavras e só serve de estímulo para a síntese.
- Código de saída 1 do `medir.ps1` é só WNS < 0. O `stderr.txt` traz `ERROR: [Common 17-354] Could
  not open 'C' for writing.` (do perfil DFX, gera `dfx_runtime.txt`); não afetou os relatórios.
