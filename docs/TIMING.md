# Log de timing e área

Alvo: `xc7a100tcsg324-1`, clock de 100 MHz (período 10 ns). Medições com `scripts/synth.ps1` (pós-roteamento, salvo indicação). Fluxo e regras na skill `.claude/skills/otimizar-timing`.

## Histórico

Sempre compare runs com o **mesmo programa** (coluna Programa): a síntese otimiza o core para o conteúdo da IMEM.

| Data | Tag | Programa | Mudança | WNS (ns) | Fmax est. (MHz) | LUTs | LUTRAM | FFs | BRAM | Conclusão |
| :-- | :-- | :-- | :-- | --: | --: | --: | --: | --: | --: | :-- |
| 2026-10-31 | GUI impl_1 | placa | estado inicial (run da GUI, referência) | -5,063 | ~66 | 13914 | 44 | 32839 | 0 | ver diagnóstico abaixo |
| 2026-10-31 | base_placa | placa | estado inicial (`synth.ps1`) | -5,409 | 64,9 | 13914 | 44 | 32839 | 0 | confirma a GUI; PC com só 3 FFs (programa de 5 instruções) |
| 2026-10-31 | base_selftest | selftest | estado inicial — **referência do processador** | -12,115 | 45,2 | 15204 | 44 | 32867 | 0 | caminho crítico PC → IMEM → … → register_file, 18 níveis, 85% roteamento |

## Diagnóstico inicial (run da GUI, 31/10/2026)

- **Caminho crítico:** `search/pc_reg[3]` → `register_file` (porta de escrita, LUTRAM), 14 níveis de lógica (CARRY4, LUT6×5, MUXF7×2, MUXF8×2, RAMD32), atraso 14,7 ns, sendo **75% roteamento**.
- **32.839 flip-flops:** a `data_memory` (4 KiB) foi implementada em FFs (≈ 32.768 bits) em vez de RAM, porque o array `mem[0:MEM_DEPTH-1][0:3]` com leitura combinacional e escrita por faixa de byte não foi inferido como memória. Isso também espalha um mux enorme pelo chip e explica o roteamento dominante.
- Não alterado ainda: aguardando decisão do usuário sobre como atacar (ver skill, alavanca 1).

## Diagnóstico da referência (`base_selftest`, 31/10/2026)

- **WNS -12,1 ns → ~45 MHz.** Caminho crítico: PC → instruction_memory → decode/controle → ALU/data_memory → write-back → escrita no register_file; 18 níveis (LUT6×15, MUXF7×2), atraso 21,8 ns, **85% roteamento**.
- **Área por módulo:** `data_memory` 9.287 LUTs + **32.836 FFs** (a RAM de 4 KiB em flip-flops); `search` 5.624 LUTs (a IMEM de 1,2 KiB de código virou lógica/ROM em LUTs; a ALU foi absorvida aqui pela otimização entre fronteiras); `register_file` 264 LUTs (44 LUTRAM, inferido corretamente).
- **Conclusão:** as duas memórias implementadas como lógica espalham o circuito pelo chip, e o roteamento domina. Atacar a inferência da `data_memory` (e depois da IMEM) vem antes de qualquer ajuste fino de lógica.
