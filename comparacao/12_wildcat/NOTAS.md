# 12 — Wildcat (versão monociclo) — NÃO MEDIDO

## Trabalho

- Autor: Martin Schoeberl
- Título: "The Educational RISC-V Microprocessor Wildcat", WOSET 2024
  (https://woset-workshop.github.io/PDFs/2024/9_The_Educational_RISC_V_Micro.pdf).
  Há também "Wildcat: Educational RISC-V Microprocessors", ARCS 2025
  (https://www.jopdesign.com/doc/wildcat-arcs.pdf).
- GitHub: https://github.com/schoeberl/wildcat — clone raso em `repo/`, commit
  `3594f0d49b873bdc54116a4017cf3f97ecf4fd11` (14/07/2026). Licença BSD 2-Clause.

## Por que não foi medido

O núcleo está em Chisel (Scala). O Verilog é gerado pelo sbt (`emitVerilog` → `generated/`),
e esse diretório não é versionado. Foi procurado em 25/11/2026:

- `repo/verilog/` só tem `hello_top.v` (top do "Hello" piscando LED) e `register_file.v`
  (banco de registradores avulso, usado nos experimentos de ASIC/OpenLane) — não há o núcleo;
- nenhum `.v`/`.sv` do `SingleCycle`/`SingleCycleTop` em outro lugar do repositório;
- nenhum release (`gh release list` vazio) e nenhum artefato de GitHub Actions (o CI só roda
  `make test`, não publica Verilog);
- busca de código no GitHub por `module SingleCycle` no repositório: nada.

A máquina não tem Java nem sbt, e a instrução foi não instalar nada. Sem o Verilog, não há o que
sintetizar. Status: **não medido**.

## O núcleo (lido do código-fonte)

Arquivos: `repo/src/main/scala/wildcat/single/SingleCycle.scala` e `SingleCycleTop.scala`
(decodificação e ALU compartilhadas com o pipeline em `wildcat/pipeline/Functions.scala`).

- **Monociclo confirmado (CPI = 1):** o único estado é `pc` (registrador), o banco `regs` e a
  memória de dados; a instrução é lida combinacionalmente da ROM (`rom(pc(31,2))`), decodificada,
  executada e escrita no mesmo ciclo; `pc := Mux(doBranch, branchTarget, pc + 4)`.
- **IMEM:** ROM combinacional (`VecInit` de constantes) com exatamente o tamanho do programa,
  embutida no Verilog na geração (o programa é fixo em tempo de elaboração). Na síntese vira LUTs.
- **DMEM:** `Mem(16, UInt(32.W))` = 16 palavras (64 B), leitura assíncrona → LUTRAM ou FFs.
  Indexada pelo endereço `rs1 + imm` direto (sem `>> 2`; na prática usa os 4 bits baixos do
  endereço como índice de palavra). Só acesso de palavra inteira: LB/LH/LBU/LHU/SB/SH não têm
  tratamento de largura nem de extensão de sinal.
- **Banco de registradores:** `RegInit(VecInit(32 × 0))` → 32×32 FFs com reset; todos os 32
  registradores são saída (`io.regs`).
- **Reset:** reset implícito do Chisel (síncrono, ativo alto); PC inicia em 0 (programas `.bin` /
  ELF) ou 0x200 (`.hex`).
- **Periféricos:** nenhum. O `SingleCycleTop` expõe só `led[7:0] = regs(4)[7:0]` (x4/tp). Por
  isso o autor relata ~11 MHz com o programa de piscar LED e quase tudo podado: a síntese mantém
  apenas o que influencia x4 para aquele programa.
- **ISA:** RV32I parcial na versão monociclo (load/store só de palavra, DMEM de 64 B, ECALL vira
  `io.stop`, sem CSRs). LUI, AUIPC, JAL, JALR, desvios e ALU reg/imm estão presentes.

## O que seria necessário para medir

1. Instalar JDK 17 (o CI usa Temurin 17) e sbt. O `build.sbt` usa Scala 2.13.14, Chisel 3.6.1
   e `jelf` 0.9.0 (leitura de ELF) — baixados pelo sbt na primeira execução.
2. Gerar o Verilog com o nosso programa embutido. Topo monociclo: classe
   `wildcat.single.SingleCycleTop` (instancia `wildcat.single.SingleCycle`). Comando (alvo
   `hw-single` do Makefile):
   `sbt "runMain wildcat.single.SingleCycleTop <programa>"` → `generated/SingleCycleTop.v`.
   O programa entra como argumento e é lido por `Util.getCode`: `.bin` (binário cru,
   little-endian, início em 0), `.out` (ELF; `.text` + `.data`) ou `.hex` (formato riscv-tests,
   128 bits por linha, início em 0x200). Para o nosso programa basta converter
   `comparacao/programa/prog_byte.hex` em um `.bin` cru (389 palavras, 1.556 B) com um script
   próprio e passar esse `.bin`. Os dados iniciais (`data_byte.hex`) não têm como ser carregados:
   a DMEM `Mem(16)` não tem inicialização.
3. Wrapper `top_cmp`: `clk` direto em 100 MHz, `CPU_RESETN` invertido para `reset`, e
   `led[15:0]` registrado. Opção (c) das instruções: o próprio `SingleCycleTop` já entrega
   `regs(4)[7:0]`, mas para não podar o núcleo seria melhor um top que registre, por exemplo,
   o dado de write-back ou `io.regs` reduzido — isso exige mexer no Scala (um top novo) ou usar
   `SingleCycle` diretamente (portas `io_regs_0..31`) e registrar no wrapper uma combinação de
   registradores. Anotar que o próprio top do autor só observa x4.
4. Rodar `medir.ps1 -SynthOnly`, verificar a poda em `util_hier.rpt`, depois `-Final`.

## Números publicados pelo autor

- Monociclo: ~11 MHz em Artix-7, com programa de piscar LED (quase tudo podado, segundo o autor).
- Pipeline de 3 estágios (não é objeto desta comparação): 1.270 LUTs, 303 FFs, 112,3 MHz.

## Observações para a comparação

- Monociclo legítimo (ROM combinacional, CPI = 1), mas a versão monociclo é didática e
  incompleta: DMEM de 64 B só com palavras, banco em FFs, ROM com o tamanho exato do programa.
- O número de ~11 MHz do autor não é comparável diretamente (programa diferente, poda agressiva,
  saída só de x4).
