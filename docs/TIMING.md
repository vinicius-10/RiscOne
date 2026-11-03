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

**Conclusão da comparação com `a94a053`:** a diferença entre o "≈ -4,6 ns" e o "-12,1 ns" vem do **programa** (placa × selftest), não do commit. Com o mesmo programa, `ff61b04` × `a94a053` dá −11,8 × −12,1 (selftest) e −4,7 × −5,4 (placa): ambas dentro da variação de placement de um design dominado pela RAM em FFs. Não foi revertido (`a94a053` traz decodificação estrita e escrita por faixa de byte no MMIO, que são funcionais).

## Diagnóstico após `dmem_lutram` (03/11/2026)

- **Caminho crítico (load):** PC → IMEM (ROM em LUTs, 3 níveis) → leitura do register_file → somador de endereço (rs1 + imm, 5 LUTs) → endereço da DMEM (**fanout 641**) → LUTRAM + MUXF8 → seleção de byte/sinal (3 LUTs) → escrita no register_file. 17,0 ns, 15 níveis, 81% roteamento (~0,9 ns por rede).
- `search` caiu de 5.624 para 1.066 LUTs: o mux de leitura gigante da DMEM em FFs tinha sido absorvido ali pela otimização entre fronteiras.
- É o caminho intrínseco de um monociclo com memórias assíncronas: cada estágio já tem poucos níveis. Ajustes locais devem render ~1–2 ns; chegar a 100 MHz exige mudança de arquitetura (pipeline ou memória síncrona) ou um clock menor via MMCM.

## Diagnóstico inicial (run da GUI, 31/10/2026)

- **Caminho crítico:** `search/pc_reg[3]` → `register_file` (porta de escrita, LUTRAM), 14 níveis de lógica (CARRY4, LUT6×5, MUXF7×2, MUXF8×2, RAMD32), atraso 14,7 ns, sendo **75% roteamento**.
- **32.839 flip-flops:** a `data_memory` (4 KiB) foi implementada em FFs (≈ 32.768 bits) em vez de RAM, porque o array `mem[0:MEM_DEPTH-1][0:3]` com leitura combinacional e escrita por faixa de byte não foi inferido como memória. Isso também espalha um mux enorme pelo chip e explica o roteamento dominante.
- Não alterado ainda: aguardando decisão do usuário sobre como atacar (ver skill, alavanca 1).

## Diagnóstico da referência (`base_selftest`, 31/10/2026)

- **WNS -12,1 ns → ~45 MHz.** Caminho crítico: PC → instruction_memory → decode/controle → ALU/data_memory → write-back → escrita no register_file; 18 níveis (LUT6×15, MUXF7×2), atraso 21,8 ns, **85% roteamento**.
- **Área por módulo:** `data_memory` 9.287 LUTs + **32.836 FFs** (a RAM de 4 KiB em flip-flops); `search` 5.624 LUTs (a IMEM de 1,2 KiB de código virou lógica/ROM em LUTs; a ALU foi absorvida aqui pela otimização entre fronteiras); `register_file` 264 LUTs (44 LUTRAM, inferido corretamente).
- **Conclusão:** as duas memórias implementadas como lógica espalham o circuito pelo chip, e o roteamento domina. Atacar a inferência da `data_memory` (e depois da IMEM) vem antes de qualquer ajuste fino de lógica.
