# Memória de instruções síncrona, comparador de desvio e RAM de dados de 1 KiB
Data: 2026-11-04 · Status: concluído

**Resultado:** implementado em 5 commits:

| Commit | Mudança |
| :-- | :-- |
| `33ca0d7` | memória síncrona |
| `a2eeef1` | comparador |
| `93f0599` | RAM de 1 KiB |
| `6686dd1` | `synth.ps1 -MaxEffort` |
| `bca8f53` | registrador da instrução no `search` |

Nos 5 commits: 10/10 testbenches e `tb_program` com `selftest` e `autoteste_placa`.

| Medição | Fluxo padrão | `-MaxEffort` |
| :-- | --: | --: |
| `ir_search` (RTL final) | −0,228 ns (1 endpoint) | **+0,008 ns: fecha 100 MHz** (WHS +0,353) |
| base `alu_eq_direto` | −3,470 ns | −3,120 ns |

- **Área:** 1266 LUTs e 98 FFs, contra 1711 LUTs e 67 FFs na base.
- **Desvio do plano:** o registrador da instrução ficou no `search`, e não dentro da `instruction_memory`. Dentro dela (`rom_style = "distributed"`) deu −0,809 / −0,468 ns; a troca foi decisão do usuário depois da medição. A margem é mínima: na GUI, usar a estratégia `Performance_ExplorePostRoutePhysOpt` com `opt_design` em `ExploreWithRemap` (ver `docs/TIMING.md`).

## Objetivo e critério de pronto

Fechar 100 MHz (WNS ≥ 0) sem pipeline, BRAM nem MMCM. Para isso, viram RTL as três peças que, nos protótipos, só rendem juntas (`docs/TIMING.md`, seção "Análise por família de caminho"). O protótipo X4 deu −0,337 ns no fluxo padrão e +0,095 ns no fluxo de esforço máximo.

1. **Memória de instruções síncrona endereçada pelo próximo PC.** A `instruction_memory` lê a ROM com o próximo PC e registra a instrução na mesma borda que atualiza o PC. O processador continua monociclo: uma instrução por ciclo, sem estágios e sem hazards. A instrução registrada é sempre `ROM[PC]`.
2. **Comparador de desvio dedicado** na `execution`. Faz `rs1 == rs2`, `$signed(rs1) < $signed(rs2)` e `rs1 < rs2` sem passar pelos muxes de operando nem pela ALU.
3. **RAM de dados com 1 KiB** (256 palavras). O endereço da RAM passa a ter fanout de ~128 (hoje ~525) e some o mux das 4 faixas.

Pronto quando:
- **Testes:** todos os testbenches passam, com os casos novos da seção Verificação, e o `tb_program` passa com `selftest` e `autoteste_placa`.
- **Medição:** `synth.ps1 -App placa` medido no fluxo padrão e no de esforço máximo, com os números no `TIMING.md`. A meta é WNS ≥ 0 no esforço máximo; a seção Decisões diz o que fazer se não fechar.
- **Bitstream:** os FFs do registrador da instrução têm como valor inicial a palavra 0 da ROM, e não há BRAM.

## Decisões

| Dúvida | Escolha | Motivo |
| :-- | :-- | :-- |
| Tamanho da RAM de dados | 1 KiB (256 palavras, `0x000`–`0x3FF`) | Decisão do usuário (04/11). Única que fechou. WNS no padrão / esforço máximo: 1 KiB −0,337 / +0,095; 2 KiB −0,782 / −0,660; 4 KiB −1,061 (só padrão). Os programas atuais usam ~100 B de dados e ~400 B de pilha (`fib(10)` recursivo). |
| `alu_lsb_o` e `OP_CMP` na ALU | Remover a porta e o cálculo de igualdade da ALU. `OP_CMP` fica no `alu_pkg` só como seletor do comparador (BEQ/BNE); a ALU devolve 0 para ele | Decisão do usuário (04/11): com o comparador, os dois ficam sem uso (~15 LUTs a menos) |
| Onde fica o registrador da instrução | ~~Dentro da `instruction_memory` (leitura síncrona, `rom_style = "distributed"`)~~ → **no `search`**, com a `instruction_memory` combinacional lida com o próximo PC (decisão do usuário, 04/11, depois da medição) | Dentro da memória deu −0,809 / −0,468 ns (padrão / esforço máximo); no `search` (como no protótipo) deu −0,228 / +0,008 ns, com ~40–60 LUTs a menos |
| BRAM | Registrador fora da `instruction_memory`, sem atributo | A ROM continua com leitura combinacional, que não pode virar BRAM. Conferido: 0 BRAM |
| Partida sem reset (placa) | O registrador da instrução nasce com a palavra 0 (`initial` no `search`, lendo `MEM_FILE`) e o PC nasce 0 (INIT padrão dos FFs) | Mantém `instrução = ROM[PC]` desde a configuração, sem lógica extra. Conferido na síntese: INIT = palavra 0 (`0x40000113` no `autoteste_placa` com pilha em `0x400`) |
| Reset | Entra no próximo PC (`pc_sel = 0`), não só no registrador do PC | Durante o reset a memória registra `ROM[0]`; ao soltar, PC = 0 e instrução = `ROM[0]` |
| `pc_write_i = 0` | `pc_sel = PC` | A memória relê a mesma palavra; o invariante continua valendo |
| Seleção da comparação | Pelo `alu_control_i` que o `control_unit` já gera (`OP_SLT` com sinal, `OP_SLTU` sem sinal, senão igualdade) | Nenhum encoding novo. A seleção fica no fim, em paralelo com a leitura do RF |
| Profundidades no `core` | `MEM_DEPTH` vira `INSTR_MEM_DEPTH` (1024) e entra `DATA_MEM_DEPTH` (256) | Mesmo padrão de `INSTR_MEM_FILE` e `DATA_MEM_FILE` |
| Programa da placa | Recompilar e reinstalar o `autoteste_placa` com o `link.ld` novo (pilha em `0x400`) e commitar os `.mem` com a RAM de 1 KiB | O `.mem` instalado põe a pilha em `0x1000`, fora da RAM nova |
| Fluxo de implementação | `synth.ps1 -MaxEffort`: `opt_design ExploreWithRemap`, `place`/`phys_opt`/`route` `Explore` e `phys_opt Explore` depois do route | É o fluxo que fechou o protótipo; fica reproduzível no script |
| Critério de manter | Manter mesmo se o esforço máximo não fechar | O ganho estrutural é de 3,1 ns. Entre fechar e não fechar decide o ruído de placement (~0,5 ns), não o RTL. Se não fechar, trago os números e as opções |
| Commits | Um por peça, cada um com a suíte passando; depois `build(synth)` e `docs(timing)` | Etapas diferentes, cada uma verificável sozinha |

## Arquitetura

```text
core
├── search
│   ├── pc_sel = reset_i ? 0 : pc_write_i ? (pc_branch_i ? new_pc_i : PC+4) : PC   combinacional (sinal interno novo)
│   ├── PC <= pc_sel                                                               borda
│   ├── instr_o <= ROM[pc_sel]                                                     borda (registrador NOVO, 32 bits, nasce ROM[0])
│   └── instruction_memory   ROM combinacional; addr_i = pc_sel
├── decoder                  sem mudança
├── execution
│   ├── NOVO comparador: rs1 == rs2 | $signed(rs1) < $signed(rs2) | rs1 < rs2, escolhido por alu_control_i
│   ├── branch_taken: OP_BCT = comparador, OP_BCF = ~comparador     (antes: alu_lsb)
│   └── alu                  sem alu_lsb_o e sem OP_CMP
└── data_memory              MEM_DEPTH = DATA_MEM_DEPTH = 256 → RAM em 0x000..0x3FF
```

Um ciclo (de uma borda à seguinte):

```text
borda tN    PC ← pc_sel e instrução ← ROM[pc_sel], juntos
ciclo       decodifica e executa a instrução registrada; calcula o próximo pc_sel;
            a ROM entrega ROM[pc_sel] antes da borda seguinte
borda tN+1  PC ← pc_sel e instrução ← ROM[pc_sel]
```

## Interfaces

| Módulo | Porta | Dir | Largura/tipo | Descrição |
| :-- | :-- | :-- | :-- | :-- |
| `instruction_memory` | `addr_i` | in | `[XLEN-1:0]` | Passa a ser o endereço da próxima instrução (`search.pc_sel`); a leitura continua combinacional |
| `search` | — | — | — | Portas iguais; `instr_o` agora sai de um registrador (instrução do PC atual), que nasce `ROM[0]` |
| `alu` | `alu_lsb_o` | out | 1 | **Removida** |
| `core` | `MEM_DEPTH` → `INSTR_MEM_DEPTH` | param | `int` | Renomeado; 1024 palavras (4 KiB), como hoje |
| `core` | `DATA_MEM_DEPTH` | param | `int` | **Novo**; 256 palavras (1 KiB) |

## Controle

Não há sinal nem encoding novo; o `control_unit` não muda. Os códigos que ele já gera para desvios passam a escolher a comparação do comparador:

| Instrução | `alu_control` | `branch_control` | Desvia quando |
| :-- | :-- | :-- | :-- |
| BEQ | `OP_CMP` | `OP_BCT` | `rs1 == rs2` |
| BNE | `OP_CMP` | `OP_BCF` | `rs1 != rs2` |
| BLT | `OP_SLT` | `OP_BCT` | `$signed(rs1) < $signed(rs2)` |
| BGE | `OP_SLT` | `OP_BCF` | não (`$signed(rs1) < $signed(rs2)`) |
| BLTU | `OP_SLTU` | `OP_BCT` | `rs1 < rs2` |
| BGEU | `OP_SLTU` | `OP_BCF` | não (`rs1 < rs2`) |

A ALU deixa de implementar `OP_CMP` (devolve 0). `OP_SLT` e `OP_SLTU` continuam na ALU para SLT, SLTI, SLTU e SLTIU.

## Temporização

- **Registrado novo:** a instrução (32 FFs). Continuam registrados o PC, a escrita no RF, a escrita na RAM e as saídas MMIO.
- **Início dos caminhos:** todos começam no registrador da instrução (clk→Q ≈ 0,5 ns), e não mais em PC → ROM (≈ 3,3 ns).
- **Fim do caminho do próximo PC:** termina no registrador da instrução, atravessando a ROM: instrução → leitura do RF → comparador → mux do próximo PC → ROM → registrador.
- **Comparador:** tira do caminho do próximo PC a espera pela decodificação da operação da ALU (≈ 2,9 ns no diagnóstico).
- **RAM de 1 KiB:** uma faixa só, sem o mux por `addr[11:10]`; fanout do endereço ≈ 128.
- **Reset:** entra no endereço da ROM (antes, só no reset síncrono do PC). O pino de reset não é temporizado (entrada sem `set_input_delay`).
- **Protótipo X4:** −0,337 ns no padrão e +0,095 ns no esforço máximo, com 1264 LUTs e 98 FFs.

## Verificação (testbench primeiro, peça a peça)

**Peça 1: memória síncrona**
- **`tb_instruction_fetch`:**
  - O modelo `instruction_memory` do testbench passa a devolver `~addr_i`, uma palavra diferente por endereço. Na primeira versão ele era síncrono, como a memória da época; com o registrador no `search`, voltou a ser combinacional e o teste confere o registrador real.
  - O `check_result` passa a conferir também `instr_o === ~pc_o`, nos casos de reset, sequência, cálculo do desvio, salto, parada e retomada:
    - no cálculo do desvio, a instrução não muda antes da borda;
    - na parada (`pc_write_i = 0`), a memória relê a mesma palavra.
  - Caso novo: reset no meio da execução, com PC = 0 e instrução = palavra 0.
- **Falha esperada antes:** o `search` atual não liga `clk` na memória e a endereça com o PC atual, então a instrução sai errada a partir do primeiro avanço.
- **`tb_core` e `tb_program`:** não mudam nesta peça. O reset por 2 bordas já carrega a palavra 0.

**Peça 2: comparador e ALU**
- **`tb_execution`, casos novos:**
  - (a) O comparador ignora os muxes da ALU: com `rs1 == rs2` e `control_alu_b` = imediato diferente, o BEQ é tomado.
  - (b) Fronteiras de sinal: `0x8000_0000` × `0x7FFF_FFFF` em BLT, BGE, BLTU e BGEU, e `0xFFFF_FFFF` × `0`.
  - (c) 2000 vetores aleatórios contra um modelo de referência, nos 6 tipos de desvio:
    - `rs2 = rs1` em ~1/4 dos vetores;
    - só o bit de sinal diferente em outro ~1/4;
    - muxes e imediato aleatórios.
- **`tb_execution`, ajustes:** nos casos com `OP_CMP`, o resultado esperado da ALU passa a 0. Os testes 18 e 19 (igualdade na ALU) passam a conferir o comparador.
- **`tb_alu`:** sai `alu_lsb_o`, e `OP_CMP` sai dos testes dirigidos e do modelo. O teste aleatório confere que a ALU devolve 0 para `OP_CMP`.
- **Falha esperada antes:** (a) falha porque a ALU compara `rs1` com o imediato, e parte de (c) falha também.

**Peça 3: RAM de 1 KiB**
- **`tb_core`:**
  - Usa o parâmetro `INSTR_MEM_DEPTH`, e o laço que zera a RAM usa `$size`.
  - Casos novos de fronteira:
    - `sw`/`lw` na última palavra (`0x3FC`);
    - `lw` em `0x400` lê 0;
    - `sw` em `0x400` não altera a palavra 0 (não dá a volta);
    - `lw 8(x)` com `x = −4` lê a RAM em `0x4` (candidato +1 da flag de página).
  - O caso `0xFFC` vira "fora da RAM: lê 0".
- **Falha esperada antes:** com 4 KiB, `0x400` ainda é RAM.
- **`tb_program`:** roda `selftest` e `autoteste_placa` com o `link.ld` de 1 KiB.
- **`tb_data_memory`:** não muda. Testa o módulo genérico com a sua própria profundidade (1024), que continua suportada.

**Medição (passo 5)**
- Fluxo padrão e `-MaxEffort` com `-App placa`.
- Conferir 0 BRAM e o INIT do registrador da instrução igual à palavra 0 do `program_bytes.mem` instalado.

## Arquivos

| Arquivo | Mudança |
| :-- | :-- |
| `sources_1/new/instruction_memory.sv` | Só o Doxygen: o endereço é o próximo PC (depois do desvio do plano, a leitura continua combinacional) |
| `sources_1/new/search.sv` | `pc_sel` combinacional (reset, `pc_write_i`, desvio); `PC <= pc_sel` e `instr <= ROM[pc_sel]`; valor inicial da instrução lido de `MEM_FILE`; Doxygen |
| `sources_1/new/execution.sv` | Comparador dedicado; `branch_taken` usa o comparador; sai o `alu_lsb`; Doxygen |
| `sources_1/new/alu.sv` | Sai `alu_lsb_o` e o `OP_CMP`; Doxygen |
| `sources_1/new/alu_pkg.sv` | Comentário do `OP_CMP` (seletor do comparador) |
| `sources_1/new/core.sv` | Parâmetros `INSTR_MEM_DEPTH` e `DATA_MEM_DEPTH`; Doxygen |
| `sources_1/new/data_memory.sv` | Só o comentário do mapa (exemplo de faixa da RAM) |
| `sim_1/new/tb_instruction_fetch.sv` | Modelo com palavra por endereço (`~addr_i`); confere a instrução registrada; caso de reset no meio |
| `sim_1/new/tb_execution.sv` | Casos do comparador e aleatório; ajustes do `OP_CMP` |
| `sim_1/new/tb_alu.sv` | Sem `alu_lsb_o` e sem `OP_CMP` |
| `sim_1/new/tb_core.sv` | Parâmetro renomeado; fronteiras de 1 KiB; caso do candidato +1; limpeza com `$size` |
| `sw/common/link.ld` | DMEM com 1K; comentário dos tamanhos |
| `scripts/build_sw.ps1` | Tamanhos separados da IMEM (4096) e da DMEM (1024) |
| `sources_1/imports/new/*.mem` | `autoteste_placa` recompilado e reinstalado |
| `scripts/synth.ps1` | Opção `-MaxEffort` |
| Documentação | Ver a seção "Documentação a atualizar" |

`run_tb.ps1` não muda: os submódulos de cada testbench continuam os mesmos.

## Passos de execução

1. **Peça 1:**
   - estender o `tb_instruction_fetch` e confirmar a falha esperada;
   - implementar `instruction_memory` e `search`;
   - rodar o `run_tb.ps1` completo e o `tb_program -App autoteste_placa`;
   - atualizar as docs da peça;
   - commit `perf(search)`, junto com este plano.
2. **Peça 2:**
   - estender o `tb_execution` e o `tb_alu` e confirmar a falha esperada;
   - implementar `execution`, `alu` e o comentário do `alu_pkg`;
   - rodar a suíte e atualizar as docs;
   - commit `perf(execution)`.
3. **Peça 3:**
   - estender o `tb_core` e confirmar a falha esperada;
   - mudar `core`, `link.ld`, `build_sw.ps1` e o comentário da `data_memory`;
   - rodar `build_sw.ps1 autoteste_placa -Install`;
   - rodar a suíte e o `tb_program` com `selftest` e `autoteste_placa`;
   - atualizar as docs;
   - commit `perf(core)!` com `BREAKING CHANGE` (pilha em `0x400`, dados+bss até 768 B), incluindo os `.mem`.
4. **Script:** opção `-MaxEffort` no `synth.ps1`, documentada na skill `otimizar-timing`; commit `build(synth)`.
5. **Medição e fechamento:**
   - medir em paralelo o fluxo padrão e o `-MaxEffort`;
   - conferir BRAM e INIT;
   - registrar no `TIMING.md` e marcar este plano como concluído;
   - commit `docs(timing)`.

## Ações do usuário no Vivado

- **Arquivos:** nenhum novo, removido ou movido. O `.xpr` não precisa mudar por causa do RTL.
- **Bitstream a 100 MHz:**
  - em Implementation, escolher a estratégia `Performance_ExplorePostRoutePhysOpt`;
  - se não fechar, mudar a diretiva do `opt_design` para `ExploreWithRemap`. É o fluxo do `-MaxEffort`.
- **Programa da placa:** depois do commit da peça 3, os `.mem` em `sources_1/imports/new` já são os novos. O Vivado usa esses arquivos direto.

## Documentação a atualizar

Cada documento é atualizado no commit da peça que o afeta:
- **`ESPEC_RV32I.md`:**
  - §2: elementos sequenciais e reset;
  - §5.2: condição de desvio;
  - §6: ALU sem `OP_CMP` e sem `alu_lsb_o`;
  - §7: interfaces de `search`, `instruction_memory`, `alu`, `execution` e `core`;
  - §8: ligações e diagrama do ciclo;
  - §9: RAM de 1 KiB.
- **`README.md`:** comportamento (instrução registrada), módulos, memórias e pontos de atenção 1 (convenção de desvio) e 3 (reset).
- **`DOCUMENTACAO_PROJETO.md`:** §2.3, §3.1, §4 e §8.2.
- **`CLAUDE.md`:** árvore de arquitetura, o que tem clock, convenção de desvio, tamanhos das memórias e nota do `tb_instruction_fetch`.
- **Skills:** `rv32i-programas` (DMEM de 1 KiB, pilha em `0x400`, limite de dados+bss) e `otimizar-timing` (`-MaxEffort`).
- **`TIMING.md`:** medições e diagnóstico.

## Riscos e fora do escopo

- **Margem pequena:** o protótipo fechou com +0,095 ns, e o ruído de placement é de ~0,5 ns. O RTL final pode ficar levemente negativo; nesse caso fica assim mesmo (critério) e trago os números e as opções.
- **GUI × script:** a GUI pode dar resultado diferente do script (fluxo de projeto × non-project). Em 31/10, a GUI ficou 0,35 ns melhor.
- **Valor inicial vindo do `$readmemh`:** está conferido nesta versão do Vivado. Se não fosse aplicado, a placa pularia a primeira instrução quando ligada sem reset. O passo 5 confere de novo.
- **Tamanho dos programas:** dados+bss acima de 768 B não cabem mais; o `build_sw.ps1` acusa.
- **Convenção de desvio:** muda, e é preciso atualizar todos os lugares que citam o `alu_lsb_o`.
- **Fora do escopo:** pipeline, BRAM, MMCM, traps, mudanças nas flags de região e a profundidade da IMEM (continua 4 KiB).
