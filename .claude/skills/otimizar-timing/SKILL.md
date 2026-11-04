---
name: otimizar-timing
description: Use quando o objetivo for fechar timing (atingir a frequência do clock), aumentar a Fmax, reduzir área (LUTs, FFs, BRAM, DSP) ou entender relatórios de síntese/implementação do Vivado neste projeto — WNS/TNS negativos, caminho crítico, latches, memória inferida como flip-flops, congestionamento. Também ao comparar antes/depois de uma mudança de RTL em área ou timing.
---

# Otimizar timing e área (Vivado, Artix-7, core monociclo)

Alvo padrão: `xc7a100tcsg324-1`, clock de **100 MHz** (`create_clock -period 10.00` no XDC). O usuário pode definir outro alvo; registre-o no log.

**Princípio:** diagnosticar com dados, mudar **uma** estrutura, medir de novo. O gargalo raramente está onde a intuição aponta. Nunca diga que algo melhorou sem número de antes e depois.

## Ferramentas

```powershell
.\scripts\synth.ps1 -Tag <nome>        # síntese + place + route -> build/synth/<nome>/ (5–15 min; rode em background)
.\scripts\synth.ps1 -Tag <nome> -SynthOnly   # só síntese: rápido, timing apenas ESTIMADO
.\scripts\synth.ps1 -Compare           # histórico (build/synth/historico.csv)
.\scripts\synth.ps1 -Tag <nome> -ParseOnly   # refaz o resumo de um run existente, sem Vivado
.\scripts\synth.ps1 -Tag <nome> -App placa   # mede com os .mem da placa em vez do selftest
.\scripts\run_tb.ps1                   # regressão funcional — obrigatória após cada mudança de RTL
```
(sempre via `powershell -ExecutionPolicy Bypass -File ...`)

Em `build/synth/<tag>/`: `resumo.txt` (WNS, TNS, Fmax estimada, área, latches, 5 piores caminhos), `timing.rpt` (detalhe célula a célula dos 10 piores), `paths.rpt` (20 caminhos em tabela), `util_hier.rpt` (área por módulo), `methodology.rpt` (regras de boas práticas do Vivado; resumidas no `resumo.txt`), `vivado.log`.

Avisos de methodology esperados neste projeto (não são o gargalo): `TIMING-18` (sem `set_input/output_delay` nos pinos de chaves/LEDs/botões, assíncronos por natureza), `HPDR-1` (direção dos pinos `JA` inout do PMOD) e `TIMING-16` (consequência do WNS negativo). `ULMTCS-2` (control sets demais) vem dos ~32 mil FFs da `data_memory` e deve sumir quando ela virar RAM.

**O programa carregado muda o resultado.** A IMEM é uma ROM com conteúdo conhecido na síntese, então o Vivado remove toda lógica que aquele programa nunca usa (com o programa de 5 instruções da placa, o PC ficou com 3 FFs). Por isso:
- Para medir o **processador**, use `-App selftest` (padrão), que exercita quase todas as instruções. Compare sempre runs com o **mesmo** programa.
- `-App placa` mede o que vai de fato para a placa (`.mem` de `sources_1/imports/new`). Use quando o objetivo for fechar timing de um programa específico.
- Uma "melhora" que só aparece trocando de programa não é melhora de RTL.

O script não usa nem altera o `.xpr`. Os runs da GUI (`processador_riscV.runs/`) podem ser lidos, mas os números de referência vêm do `synth.ps1` (mesmo fluxo sempre).

## Ciclo de trabalho

1. **Medir a base** (`-Tag base_<assunto>`) se não houver medição recente do estado atual do RTL. Decisões só com números **pós-roteamento**; pós-síntese serve para triagem rápida (o roteamento costuma ser a maior parte do atraso).
2. **Diagnosticar** lendo o `resumo.txt` e o caminho crítico em `timing.rpt` (seção 2). Responder: qual é a origem e o destino, quantos níveis de lógica, quanto é lógica vs. roteamento, e quais primitivas aparecem.
3. **Hipótese sobre uma estrutura.** Escreva antes de mudar: "o caminho X passa por Y; trocando Y por Z espero WNS melhorar ~N ns / área cair ~M LUTs".
4. **Se a mudança altera arquitetura** (latência de memória, pipeline, novo clock, portas entre módulos), carregue a skill `planejar-tarefa` e obtenha aprovação. Mudanças locais e equivalentes (reescrever uma expressão, separar um comparador) seguem direto, respeitando as regras de "Change discipline" do CLAUDE.md.
5. **Mudar e validar funcionalmente:** `run_tb.ps1` completo deve passar antes de medir. Uma otimização que quebra a função não conta.
6. **Medir de novo** com tag nova (`-Tag <assunto>_v2`) e comparar com `-Compare`.
7. **Decidir:** manteve se melhorou além do ruído (ver abaixo); senão reverte. Pare de atacar uma estrutura quando ela sair do caminho crítico — o próximo gargalo é outro.
8. **Registrar** em `docs/TIMING.md`: data, tag, mudança, WNS/Fmax/LUT/FF/BRAM/DSP antes→depois, e a conclusão (inclusive tentativas que não funcionaram).

## Como ler o caminho crítico (7-series)

| Sinal no relatório | Significado provável |
| :-- | :-- |
| Roteamento > ~60% do atraso | fanout alto, mux enorme espalhado, ou lógica distribuída pelo chip (ex.: memória virando milhares de FFs). Atacar a estrutura, não a lógica. |
| Muitos `MUXF7`/`MUXF8` | mux largo — tipicamente leitura de um array implementado em FFs/LUTs (register file, memória). |
| `RAMD32`/`RAMS32`/`RAMD64E` | LUTRAM (memória distribuída) — leitura assíncrona, ok para tamanhos pequenos. |
| `FDRE`/`FDSE` em quantidade ≈ bits de uma memória | a memória **não** foi inferida como RAM; virou flip-flops. Grande perda de área e de timing. |
| `RAMB18`/`RAMB36` | Block RAM — leitura **síncrona** (1 ciclo de latência); exige mudança de arquitetura num monociclo. |
| `CARRY4` em cadeia longa | somador/comparador largo (ALU, alvo de branch, PC+4). 32 bits ≈ 8 CARRY4. |
| Muitos níveis de `LUT6` | lógica de decisão profunda (decode → controle → mux). |
| `DSP48E1` | multiplicação; aqui não deveria aparecer (RV32I sem M). |

Caminho típico de um monociclo (todos combinacionais em série num ciclo):
`PC (FF) → instruction_memory → decoder/control_unit → register_file (leitura) → muxes A/B → ALU → write_back → register_file (escrita)`; no load, o endereço vem do somador dedicado `rs1 + imm` (`execution.mem_addr_o`): `register_file → somador → data_memory (decodificação de região + leitura) → write_back → register_file` e o laço de desvio `ALU → alu_lsb_o → branch_taken → mux do PC → PC`.

## Alavancas, da menos para a mais invasiva

1. **Inferência de memória correta** (geralmente o maior ganho): arrays que viram FFs. Para continuar com leitura assíncrona, a forma inferível como LUTRAM é um array 1-D por faixa de byte, escrita síncrona simples, sem reset e sem lógica extra no array. Confirme no `util.rpt` (LUT as Memory sobe, Registers caem) e no `vivado.log` (mensagens de inferência de RAM).
2. **Encurtar o caminho mantendo o comportamento:** comparador de branch dedicado em paralelo à ALU; pré-calcular alvos/PC+4 (já existe somador separado); simplificar muxes de write-back e de operandos; decodificação mais rasa (sinais one-hot); evitar prioridade desnecessária (`if/else` encadeado vira cadeia — prefira `case` paralelo quando as condições são exclusivas).
3. **Opções de ferramenta** (sem mudar RTL; registre como experimento): `synth_design -directive PerformanceOptimized`, `-retiming`, `place_design -directive Explore`, `phys_opt_design`, `route_design -directive Explore`. Para testar, edite o `run.tcl` gerado ou acrescente um parâmetro ao `synth.ps1` (e documente).
4. **Mudanças de arquitetura** (sempre com `planejar-tarefa`): BRAM com leitura síncrona, pipeline (2–5 estágios), clock menor via MMCM (ex.: 50 MHz) quando o objetivo é só funcionar na placa.

**Não fazer:** `set_false_path`/`set_multicycle_path` para "esconder" caminhos reais; afrouxar o `create_clock` sem decisão do usuário; otimizar algo fora do caminho crítico; trocar várias estruturas de uma vez (não dá para saber o que ajudou).

## Ruído e confiabilidade

- Área pós-síntese é praticamente determinística para o mesmo RTL; diferenças pequenas (dezenas de LUTs) podem ser ruído do otimizador.
- Timing pós-roteamento varia com o placement: diferenças de WNS abaixo de ~0,5 ns não provam nada (medido em 03/11/2026: dois netlists com 2 LUTs de diferença deram 0,47 ns de diferença). Rodar de novo a mesma entrada dá o mesmo resultado (o fluxo é determinístico), então não serve como teste de ruído; compare o número de níveis e o atraso de lógica do caminho.
- WHS (hold) negativo pós-roteamento é problema real; pós-síntese pode ser ignorado.
- Latches inferidos (`Synth 8-327`) são bug de RTL combinacional (atribuição faltando em algum ramo): sempre relatar ao usuário.

## Formato do relato ao usuário

Tabela antes → depois (WNS, Fmax estimada, TNS, LUTs, FFs, LUTRAM, BRAM), o caminho crítico atual em uma linha (origem → destino, níveis, % roteamento), o que foi mudado e a próxima alavanca sugerida. Se não melhorou, diga isso e reverta.
