# 14_marslan6 — Risc-V (marslan6) — NÃO MEDIDO

- Trabalho: marslan6, "RV32I RISC-V Processor Core" (projeto no GitHub, sem artigo associado).
- GitHub: https://github.com/marslan6/Risc-V — commit clonado `bf99a53149dbb2c44c7fb8c90a17dc55d052815d`
  (clone raso em `repo/`). Licença: MIT.
- HDL: VHDL, projeto Vivado (`RISC-V/RISC-V.xpr`).

## Por que não foi medido

O repositório não contém um núcleo completo, apenas blocos soltos. Em
`RISC-V/RISC-V.srcs/sources_1/new/` há 18 entidades (`Adder`, `ALU`, `Controller`,
`Data_Memory`, `DRAM`, `Extend_Immediate`, `Instruction_Memory`, `Program_Counter`,
`Register_File`, `Register_Simple`, `Register_Write_Enable`, muxes e decodificadores), mas
**nenhuma entidade de topo/datapath que as interligue**. As únicas instanciações existentes são
internas: `Register_File` → `Decoder_5to32` + `Register_Write_Enable`, e
`Instruction_Memory`/`Data_Memory` → `DRAM`. Nada instancia `Controller`, `ALU`,
`Program_Counter` e `Register_File` juntos. O `.xpr` usa `ALU` como top de síntese e `TB_ALU`
como top de simulação; todos os testbenches são de módulos isolados.

O README descreve um processador monociclo RV32I (diagrama de blocos e "modelo de execução"),
mas a integração não existe no código. O próprio README diz (linha ~490): "Actual synthesis has
not been completed for this design. The following are typical estimates for similar RV32I cores"
— ou seja, os números de recursos publicados são estimativas genéricas, não medições deste
projeto.

Montar o datapath a partir dos blocos seria projetar o núcleo no lugar do autor (decisões de
fiação, seleção de PC, write-back, alinhamento de loads/stores), o que viola a regra "medir, não
consertar". Por isso não houve wrapper, config, síntese nem execução `-Final`.

## Para a comparação

- Status: **não medido** (não é um núcleo completo; só blocos de um RV32I monociclo).
- Números publicados pelo autor: apenas estimativas genéricas, sem valor comparativo.
- Recomendação: manter fora da tabela, citando o motivo acima.
