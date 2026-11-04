# Log de timing e área

Alvo: `xc7a100tcsg324-1`, clock de 100 MHz (período 10 ns). Medições com `scripts/synth.ps1` (pós-roteamento, salvo indicação). Fluxo e regras na skill `.claude/skills/otimizar-timing`.

## Histórico

Sempre compare runs com o **mesmo programa** (coluna Programa): a síntese otimiza o core para o conteúdo da IMEM.

| Data | Tag | Programa | Mudança | WNS (ns) | Fmax est. (MHz) | LUTs | LUTRAM | FFs | BRAM | Conclusão |
| :-- | :-- | :-- | :-- | --: | --: | --: | --: | --: | --: | :-- |
| 2026-10-31 | GUI impl_1 | placa | estado inicial (run da GUI, referência) | -5,063 | ~66 | 13914 | 44 | 32839 | 0 | ver diagnóstico abaixo |
| 2026-10-31 | base_placa | placa | estado inicial (`synth.ps1`) | -5,409 | 64,9 | 13914 | 44 | 32839 | 0 | confirma a GUI; PC com só 3 FFs (programa de 5 instruções) |
| 2026-10-31 | base_selftest | selftest | estado inicial — **referência do processador** | -12,115 | 45,2 | 15204 | 44 | 32867 | 0 | caminho crítico PC → IMEM → … → register_file, 18 níveis, 85% roteamento |
| 2026-11-03 | dmem_lutram | selftest | `data_memory`: array 2-D de bytes → array 1-D de words de 32 bits com escrita por faixa de byte (`data.mem` montado no `initial`) | -7,391 | 57,5 | 1685 | 556 | 99 | 0 | **mantido.** RAM inferida como LUTRAM (512); FFs 32867 → 99, LUTs −89%; caminho crítico agora é o LW completo, 15 níveis, 81% roteamento |
| 2026-11-03 | antigo_placa | placa | RTL de `ff61b04` (antes de `a94a053` "melhoria de sinais internos"), medido num worktree | -4,735 | 67,9 | 13393 | 44 | 32839 | 0 | referência para o "≈ -4,6" lembrado pelo usuário |
| 2026-11-03 | antigo_selftest | selftest | RTL de `ff61b04` | -11,848 | 45,8 | 15561 | 44 | 32867 | 0 | igual a `base_selftest` (−12,1) dentro do ruído: `a94a053` não piorou o processador |
| 2026-11-03 | dmem_lutram_placa | placa | RTL atual com `dmem_lutram` | -0,834 | 92,3 | — | — | — | 0 | com o programa da placa fica a 0,8 ns de fechar 100 MHz |
| 2026-11-03 | base_completo | placa (`autoteste_placa`, 37 instruções) | programa da placa trocado pelo autoteste com todas as instruções — **nova referência** | -7,625 | 56,7 | 1684 | 556 | 99 | 0 | igual ao selftest dentro do ruído; a partir daqui `-App placa` = processador completo |
| 2026-11-03 | addr_dedicado | placa | somador dedicado `rs1 + imm` na `execution` (`mem_addr_o`) para o endereço da DMEM (plano `docs/planos/2026-11-03-somador-endereco-dmem.md`) | -4,207 | 70,4 | 1801 | 556 | 99 | 0 | **mantido** (+3,4 ns, +117 LUTs). Saíram do caminho a decodificação do seletor da ALU-B, o mux B e o mux da ALU |
| 2026-11-03 | base_mmio | placa | `b67af4a` (reset invertido no `top_core`) medido de novo num worktree | -4,207 | 70,4 | 1801 | 556 | 99 | 0 | idêntico a `addr_dedicado`: o fluxo é determinístico para a mesma entrada |
| 2026-11-03 | mmio_generico | placa | E/S genérica: 4 saídas + 4 entradas de 32 bits, saídas com leitura de volta (plano `docs/planos/2026-11-03-mmio-generico.md`) | -5,083 | 66,3 | 1798 | 556 | 195 | 0 | **−0,9 ns**: mesmo caminho (PC → IMEM → imm → somador → decodificação de região → RF), 21 níveis; lógica igual (3,9 ns), roteamento +1,2 ns. Os 128 FFs das saídas não podem ser podados porque são lidos de volta |
| 2026-11-03 | mmio_sem_leitura | placa | experimento (worktree): `mmio_generico` com leitura das saídas devolvendo 0 | -4,259 | 70,1 | 1674 | 556 | 67 | 0 | igual à base dentro do ruído: o custo de `mmio_generico` vem da leitura de volta das saídas de 32 bits |
| 2026-11-03 | mmio_somente_escrita | placa | versão final: E/S genérica com saídas somente escrita (mesma lógica do experimento; só muda a ordem dos itens do `case`) | -4,724 | 67,9 | 1676 | 556 | 67 | 0 | **mantido** (decisão do usuário): −125 LUTs e −32 FFs em relação à base. A diferença de 0,47 ns para `mmio_sem_leitura`, com netlist quase idêntico, é variação de placement: o ruído real para pequenas mudanças de netlist é de ~0,5 ns |
| 2026-11-04 | regiao_carry_sel | placa | flags de região (`addr[31:28] == 4`, `addr[31:12] == 0`) calculadas na `execution` sem esperar o carry: candidatos `rs1[31:12]` −1/0/+1 escolhidos por `imm[11]` e pelo carry do bit 11 (plano `docs/planos/2026-11-04-regiao-sem-carry.md`) | -3,656 | 73,2 | 1826 | 556 | 67 | 0 | **mantido** (+1,07 ns, +150 LUTs). A decodificação saiu do caminho crítico; agora empatam a leitura da LUTRAM e a ALU (ver diagnóstico abaixo) |
| 2026-11-04 | regiao_rasa_teto | placa | experimento (worktree, não mantido): decodificação mínima, MMIO = `addr[30]` e leitura da RAM sem checar `addr < 4 KiB` | -4,618 | 68,4 | 1727 | 556 | 68 | 0 | **pior que `regiao_carry_sel`**: o caminho crítico também é a leitura da LUTRAM (18 níveis, contra 16 na (a)). Simplificar o mapa não traz ganho adicional |
| 2026-11-04 | fanout_pc50 | placa | experimento (worktree, não mantido): `(* max_fanout = 50 *)` no `pc_reg` do `search` (os bits do PC alimentam ~190 LUTs da ROM cada) | -4,417 | 69,4 | 1769 | 556 | 95 | 0 | **pior** (−0,76 ns): a síntese replicou o PC (`pc_reg_reg[*]_rep`, +28 FFs), mas a ROM em LUTs continua espalhada e o placement piorou |
| 2026-11-04 | fanout_physopt | placa | só ferramenta: `phys_opt_design` entre place e route (`synth.ps1 -PhysOpt`), RTL de `regiao_carry_sel` | -3,430 | 74,5 | 1841 | 556 | 94 | 0 | +0,23 ns, **dentro do ruído**. Replicou 26 células do caminho crítico (estimativa +0,54 ns antes do roteamento). Não vale como ganho de RTL; pode ser ligado no fluxo da GUI como bônus |
| 2026-11-04 | alu_eq_direto | placa | `alu`: igualdade do `OP_CMP` como `a_i == b_i` em vez de `(a − b) == 0` (o OP_CMP deixa de forçar a subtração) | -3,470 | 74,2 | 1711 | 556 | 67 | 0 | **mantido**: WNS dentro do ruído, mas −115 LUTs, TNS −1495 → −1343 e o caminho da ALU de 22 níveis (8 CARRY4) saiu dos 10 piores. Agora todos os piores são o load |
| 2026-11-04 | alu_cmp_dedicado | placa | experimento (worktree): `alu_eq_direto` + SLT/SLTU por comparadores dedicados (`<`, `$signed <`) em vez do carry do somador | -3,900 | 71,9 | 1918 | 556 | 71 | 0 | **pior** (+207 LUTs, TNS −1696): o carry do somador já entrega SLT/SLTU de graça |
| 2026-11-04 | load_regiao_fim | placa | experimento: `data_memory` com seleção de byte/sinal aplicada à RAM e ao MMIO separadamente e região escolhida por último | -4,143 | 70,7 | 1705 | 556 | 67 | 0 | **pior**: a extensão de sinal ficou com 6 LUTs depois da RAM (eram 4). Revertido |
| 2026-11-04 | addr_fanout128 | placa | experimento: `(* max_fanout = 128 *)` no `word_addr` da `data_memory` | -3,942 | 71,7 | 1710 | 556 | 67 | 0 | **ignorado pela síntese** (a rede continua com fanout 518; o driver é CARRY4). Netlist igual a `alu_eq_direto` ±1 LUT: os 0,47 ns de diferença são ruído de placement. Revertido |
| 2026-11-04 | dir_synth_perf | placa | só ferramenta: `synth_design -directive PerformanceOptimized` (RTL de `alu_eq_direto`) | -3,470 | 74,2 | 1711 | 556 | 67 | 0 | sem efeito: netlist e resultado idênticos à base |
| 2026-11-04 | dir_explore | placa | só ferramenta: `place_design` e `route_design` com `-directive Explore` | -3,469 | 74,2 | 1709 | 556 | 67 | 0 | igual à base (5,4 min contra 3,3) |
| 2026-11-04 | dir_extratiming | placa | só ferramenta: `place_design -directive ExtraTimingOpt` | -3,827 | 72,3 | 1718 | 556 | 67 | 0 | pior. Conclusão da varredura: com este netlist o placer chega a ~−3,47 ns no melhor caso; as diretivas não ajudam |
| 2026-11-04 | imm_mem | placa | imediato dedicado ao endereço de load/store: `imm_gen.imm_mem_o` = `sext({instr[31:25], instr[5] ? instr[11:7] : instr[24:20]})`, usado no somador `mem_addr_o` e nas flags de região (plano `docs/planos/2026-11-04-imediato-endereco.md`) | -3,614 | 73,5 | 1741 | 556 | 67 | 0 | **revertido** (critério: não piorar nos dois placements). O imediato saiu do caminho; o novo crítico parte do `rs1`: ROM → endereço do register_file (fanout 34) → RAMD32 → somador → RAM |
| 2026-11-04 | imm_mem_explore | placa | o mesmo RTL com `place`/`route -directive Explore` | -3,626 | 73,4 | 1741 | 556 | 67 | 0 | confirma: ~0,15 ns pior que a base nos dois placements. O `rs1` chega ao somador junto com o imediato; encurtar só o imediato não rende |
| 2026-11-04 | retiming | placa | só ferramenta: `synth_design -retiming` (Tcl próprio no scratchpad, RTL de `alu_eq_direto`) | -3,470 | 74,2 | 1711 | 556 | 67 | 0 | sem efeito: nenhum registrador movido (netlist idêntico) |
| 2026-11-04 | esforco_maximo | placa | só ferramenta: `opt_design ExploreWithRemap`, `place Explore`, `phys_opt Explore`, `route Explore` e `phys_opt Explore` pós-route | -3,120 | 76,2 | 1772 | — | 124 | 0 | +0,35 ns. O `phys_opt` pós-route levou o mesmo placement de −3,402 para −3,120: ganho real de ferramenta, não ruído |
| 2026-11-04 | X1 (protótipo) | placa | RAM de dados com 256 palavras (1 KiB) só na instância da `data_memory` | -3,218 | 75,7 | 1333 | — | 67 | 0 | sozinho, +0,25 ns (ruído); −378 LUTs |
| 2026-11-04 | X2 (protótipo) | placa | comparador de desvio dedicado (`rs1 == rs2`, `<` com e sem sinal) no lugar de `alu_lsb` | -4,322 | 69,8 | 2012 | — | 76 | 0 | sozinho, pior (+301 LUTs) |
| 2026-11-04 | X5 (protótipo) | placa | registrador de instrução: a ROM é lida com o próximo PC e a instrução é guardada na mesma borda do PC | -2,159 | 82,2 | 1672 | — | 98 | 0 | +1,31 ns; limitado pelo próximo PC, que ainda espera a decodificação da ALU |
| 2026-11-04 | X3 (protótipo) | placa | X5 + X2 | -1,061 | 90,4 | 1721 | — | 98 | 0 | +2,41 ns |
| 2026-11-04 | X4 (protótipo) | placa | X5 + X2 + X1 | -0,337 | 96,7 | 1264 | — | 98 | 0 | +3,13 ns; todas as famílias entre −0,34 e −0,04 |
| 2026-11-04 | X4 + esforço máximo | placa | X4 com a estratégia de `esforco_maximo` | +0,095 | 101,0 | 1276 | — | 98 | 0 | **fecha 100 MHz** (WHS +0,086). Margem pequena; protótipo, não mantido |

**Ruído de placement (03/11/2026):** o fluxo é determinístico para a mesma entrada (`base_mmio` = `addr_dedicado`), mas netlists quase iguais (`mmio_sem_leitura` × `mmio_somente_escrita`, 2 LUTs de diferença) deram WNS 0,47 ns diferentes. Diferenças de WNS abaixo de ~0,5 ns não provam melhora ou piora de RTL.

**Conclusão da comparação com `a94a053`:** a diferença entre o "≈ -4,6 ns" e o "-12,1 ns" vem do **programa** (placa × selftest), não do commit. Com o mesmo programa, `ff61b04` × `a94a053` dá −11,8 × −12,1 (selftest) e −4,7 × −5,4 (placa): ambas dentro da variação de placement de um design dominado pela RAM em FFs. Não foi revertido (`a94a053` traz decodificação estrita e escrita por faixa de byte no MMIO, que são funcionais).

## Análise por família de caminho (04/11/2026, RTL de `alu_eq_direto`)

Medido com um Tcl próprio (implementação padrão + `get_timing_paths` agrupado por início/fim). Programa da placa: 390 instruções, então a ROM usa `pc[10:2]` (9 bits) e fica com 3 níveis (LUT6 → MUXF7 → rota → LUT6).

| Família | Pior slack (ns) | Observação |
| :-- | --: | :-- |
| load (leitura da RAM → register_file) | −3,470 | 14 níveis, 74% rota |
| register_file → register_file (passando pela leitura do RF) | −3,311 | o `rs1` chega ao somador quase junto com o imediato |
| próximo PC (desvios/saltos → PC) | −3,099 | 20 níveis: a comparação espera ~2,9 ns de decodificação da operação da ALU (subtração/seleção do operando B, fanout 104) |
| store (→ WE da RAM) | −2,547 | |
| MMIO (→ CE das saídas) | −1,797 | |

Orçamento do pior load, a partir da borda do clock: PC (fanout 191) + ROM até o bit de instrução 3,34 ns; distribuição + decodificação do imediato 2,38 ns; somador 0,73 ns; rota do endereço até as 512 células da RAM (fanout 525) 1,92 ns; RAMS64E + F7 + F8 0,65 ns; rota até a primeira LUT 1,23 ns; 4 LUTs (faixa, região, byte/sinal, write-back) 2,89 ns.

Dispersão física: RAM de dados em X2..30 / Y14..40 (128 SLICEM); ROM e lógica absorvida no `search` em X5..28 / Y13..59. Uso de RAM pelos programas atuais: ~100 B estáticos (`autoteste_placa`) e pilha com quadros de no máximo 64 B.

**Conclusão:** as três famílias principais estão a 0,4 ns uma da outra, então nenhuma mudança local isolada move o WNS. O trecho comum é o PC → ROM (3,3 ns). Os protótipos X1–X5 (tabela do histórico; diffs guardados fora do repositório) mostram três peças que só rendem juntas:

1. **Registrador de instrução:** a ROM é lida com o próximo PC e a instrução fica num registrador carregado na mesma borda do PC. Continua monociclo (uma instrução por ciclo, sem estágios, sem hazards); só muda onde fica o registrador da busca. Tira a ROM do início de todos os caminhos e a põe no fim do caminho do próximo PC.
2. **Comparador de desvio dedicado** (`rs1` × `rs2`): o próximo PC deixa de esperar a decodificação da ALU. Muda a convenção de desvio por `alu_lsb_o`.
3. **RAM de dados com 1 KiB:** fanout do endereço 128 em vez de 525 e sem o mux das 4 faixas. Exige profundidade separada para a DMEM e `link.ld` com 1 KiB.

Para virar RTL de verdade falta: valor inicial do registrador de instrução igual à palavra 0 da ROM (a placa roda sem reset), revisar o `tb_instruction_fetch`, atualizar ESPEC/README/CLAUDE.md (convenção de desvio) e o `link.ld`. Mudança de arquitetura da busca: precisa de plano e decisão do usuário.

## Diagnóstico após `regiao_carry_sel` (04/11/2026)

- **Caminho crítico (load, −3,656 ns):** PC → IMEM (3 níveis) → imediato → 2 CARRY4 do somador `rs1 + imm` → `addr[11:2]` da LUTRAM (**fanout 516**, 1,6 ns de rota) → RAMS64E + MUXF7/MUXF8 → seleção de byte/sinal → write-back → register_file. 13,4 ns, 16 níveis, 72% roteamento.
- **Empatado (−3,598 ns):** caminho da ALU: IMEM → mux de operando → 8 CARRY4 (ADD/SLT de 32 bits) → mux de resultado → mux do PC/write-back → register_file. 22 níveis.
- O teto `regiao_rasa_teto` (decodificação mínima) não passou de −4,6 ns, então mexer mais na decodificação de região não rende.
- **Fanout (04/11):** o netlist mostra os bits 2–10 do PC com fanout ~190 (ROM da IMEM em LUTs) e `addr[9:2]` com fanout 516 (os 128 RAM256X1S da DMEM). Replicar o PC por atributo piorou (`fanout_pc50`) e o `phys_opt_design` ficou dentro do ruído (`fanout_physopt`): o atraso está nos ~15 trechos de roteamento de ~0,6–1 ns de lógica espalhada, não só nessas redes.
- Próximas alavancas, uma de cada vez: reduzir o fanout de `addr[11:2]` (a LUTRAM de 4 KiB são 512 células RAMS64E lendo o mesmo endereço) ou o mux de leitura (MUXF7/F8 + byte/sinal); encurtar a ALU (comparador SLT/SLTU dedicado ou mux de resultado mais raso); opções de ferramenta (`phys_opt_design`, `Explore`). Para 100 MHz: pipeline ou MMCM.

## Diagnóstico após `dmem_lutram` (03/11/2026)

- **Caminho crítico (load):** PC → IMEM (ROM em LUTs, 3 níveis) → leitura do register_file → somador de endereço (rs1 + imm, 5 LUTs) → endereço da DMEM (**fanout 641**) → LUTRAM + MUXF8 → seleção de byte/sinal (3 LUTs) → escrita no register_file. 17,0 ns, 15 níveis, 81% roteamento (~0,9 ns por rede).
- `search` caiu de 5.624 para 1.066 LUTs: o mux de leitura gigante da DMEM em FFs tinha sido absorvido ali pela otimização entre fronteiras.
- É o caminho intrínseco de um monociclo com memórias assíncronas: cada estágio já tem poucos níveis. Ajustes locais devem render ~1–2 ns; chegar a 100 MHz exige mudança de arquitetura (pipeline ou memória síncrona) ou um clock menor via MMCM.

## Diagnóstico após `addr_dedicado` (03/11/2026)

- **Caminho crítico:** PC → IMEM (3 níveis) → leitura do register_file (fanout 50) → somador `rs1 + imm` (7 CARRY4 até o bit 31) → decodificação de região na `data_memory` (`is_io_space` = `addr[31:28] == 4`, `ram_addr_valid` = `addr[31:12] == 0`; 3 LUTs, fanout 56) → mux RAM/MMIO + seleção de byte/sinal → write-back → register_file. 13,9 ns, 20 níveis, 70% roteamento.
- A leitura da LUTRAM usa só `addr[11:2]` (prontos antes); quem atrasa é a decodificação, que espera o carry até o bit 31.
- Próximas alavancas: decodificação de região mais rasa (muda o comportamento fora do mapa → decisão do usuário), opções de ferramenta (`phys_opt_design`, diretivas `Explore`), e, para 100 MHz, pipeline.

## Diagnóstico inicial (run da GUI, 31/10/2026)

- **Caminho crítico:** `search/pc_reg[3]` → `register_file` (porta de escrita, LUTRAM), 14 níveis de lógica (CARRY4, LUT6×5, MUXF7×2, MUXF8×2, RAMD32), atraso 14,7 ns, sendo **75% roteamento**.
- **32.839 flip-flops:** a `data_memory` (4 KiB) foi implementada em FFs (≈ 32.768 bits) em vez de RAM, porque o array `mem[0:MEM_DEPTH-1][0:3]` com leitura combinacional e escrita por faixa de byte não foi inferido como memória. Isso também espalha um mux enorme pelo chip e explica o roteamento dominante.
- Não alterado ainda: aguardando decisão do usuário sobre como atacar (ver skill, alavanca 1).

## Diagnóstico da referência (`base_selftest`, 31/10/2026)

- **WNS -12,1 ns → ~45 MHz.** Caminho crítico: PC → instruction_memory → decode/controle → ALU/data_memory → write-back → escrita no register_file; 18 níveis (LUT6×15, MUXF7×2), atraso 21,8 ns, **85% roteamento**.
- **Área por módulo:** `data_memory` 9.287 LUTs + **32.836 FFs** (a RAM de 4 KiB em flip-flops); `search` 5.624 LUTs (a IMEM de 1,2 KiB de código virou lógica/ROM em LUTs; a ALU foi absorvida aqui pela otimização entre fronteiras); `register_file` 264 LUTs (44 LUTRAM, inferido corretamente).
- **Conclusão:** as duas memórias implementadas como lógica espalham o circuito pelo chip, e o roteamento domina. Atacar a inferência da `data_memory` (e depois da IMEM) vem antes de qualquer ajuste fino de lógica.
