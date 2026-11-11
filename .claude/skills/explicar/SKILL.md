---
name: explicar
description: Use quando o usuário digitar /explicar ou pedir para explicar algo do projeto — "para que serve X", "o que é X", "o que X faz", "explica X", "não entendi X", "de onde vem X", "como funciona esse trecho" — sobre um sinal, porta, flag, valor, módulo, bloco always, função, trecho de C/assembly, instrução ou conceito do RTL/software deste processador. Separa dois modos (valor específico × bloco/trecho de código) e define o formato da resposta de cada um. NÃO usar para pedidos de mudança de código, review com achados ou planejamento.
---

# Explicar algo do projeto

Objetivo: o usuário entender **o que a coisa faz** logo na primeira olhada e depois **de onde ela vem** e **por que existe**, nessa ordem.

Antes de escrever, leia o código envolvido (declaração, onde é gerado, onde é usado, testbench que cobre). O RTL é a fonte da verdade; não explique de memória. Responda em português.

## Primeiro passo: escolher o modo

| O usuário pergunta sobre... | Modo |
|---|---|
| **Um valor específico**: sinal, fio, flag, porta isolada, campo, constante, parâmetro, valor de enum, registrador, endereço MMIO — "o que é X", "para que serve X", "de onde vem X", "onde X é usado" | **A — Valor** |
| **Um bloco ou parte do programa**: módulo, `always`/`assign` com várias linhas, `case`, função/task, trecho de C ou assembly, rotina (`crt0`, `_halt`), testbench ou um pedaço selecionado no editor — "o que esse trecho faz", "como funciona X", "explica esse bloco" | **B — Bloco** |
| Instrução RV32I ou conceito (ex.: convenção de branch) | Use **B** se a explicação passa pelo hardware que a executa; use **A** se é sobre um campo/valor dela |

Se a pergunta misturar os dois (ex.: "o que o `search` faz e o que é `pc_next`"), responda o bloco no modo B e o valor no modo A, nessa ordem, cada um com seu título.

## Modo A — Valor específico

Foco: **o que o valor significa** e **onde ele é utilizado**.

### A1. Tabela-resumo (primeiro de tudo)

Uma tabela direta, sem texto antes dela além de no máximo uma linha de título: **valor → o que acontece**. Se o efeito depende de outro sinal, inclua as combinações (ex.: `addr_page0_i` × `addr_io_i`) e marque combinações impossíveis como "não acontece" com o motivo curto.

### A2. O que é

Afirmações diretas, sem enquadrar como pergunta. Não escreva "X responde a uma pergunta: ...?". Escreva:

> É um fio de 1 bit que indica se o endereço do load/store está no começo da memória (de `0x000` a `0xFFF`).
>
> - **1** = a RAM pode ser usada.
> - **0** = a RAM fica desligada: o store não escreve e o load não lê dela.

Diga o tipo/largura (fio de 1 bit, barramento de 32 bits, registrador, constante...) e o que cada valor ou estado significa. Se o valor sozinho não basta (ex.: a flag cobre 4 KiB mas a RAM tem 1 KiB), mostre o teste adicional que o consumidor faz.

### A3. Onde é utilizado

Tabela com cada consumidor: **módulo/linha (link `[arquivo.sv:linha](caminho#Lnn)`) → o que faz com o valor**. Se não houver consumidor (valor morto), diga isso — é achado para reportar, não corrigir.

### A4. De onde vem e como é definido

- **Caminho do sinal** entre módulos, em uma linha:
  `execution.mem_page0_o ──► core.data_memory_addr_page0 ──► data_memory.addr_page0_i`
  seguido dos links para declaração e ligações.
- **Como é calculado:** o trecho de código relevante (curto) com o que cada parte faz.
- **Exemplos concretos:** tabela curta de casos reais (instrução, operandos, valor resultante, efeito), incluindo pelo menos um caso de borda. No testbench, aponte onde a referência é calculada se ajudar.

### A5. Por que existe

Seção própria no final: o motivo do projeto (ex.: tirar o carry de 32 bits do caminho crítico até a RAM), o que havia antes e o que mudou. Restrições que decorrem disso (ex.: RAM limitada a 4 KiB, só exato para imediato de 12 bits) vão aqui.

## Modo B — Bloco ou parte do código

Foco: **o que entra, o que sai** e **como a saída é produzida**.

### B1. Tabela de entradas e saídas (primeiro de tudo, sempre)

Antes de qualquer texto além de no máximo uma linha de título, monte a tabela de interface do bloco:

| Direção | Nome | Largura/tipo | De onde vem / para onde vai | Significado |
|---|---|---|---|---|
| entrada | `rs1_data_i` | 32 bits | `decoder.register_file` | valor de rs1 |
| saída | `alu_result_o` | 32 bits | `write_back`, `data_memory` | resultado da operação |

- **Módulo:** as portas reais (agrupe barramentos repetidos, ex.: `io_in0_i..io_in3_i`). Inclua `clk`/`reset` só se o bloco tiver estado.
- **Trecho `always`/`assign`/`case`:** os sinais que ele **lê** (entradas) e os que ele **escreve** (saídas), mesmo que sejam internos ao módulo.
- **Função C/assembly:** argumentos (registrador da ABI: `a0`, `a1`...), retorno, e efeitos colaterais como saídas (memória, MMIO, `sp`). Variáveis globais lidas contam como entradas.
- **Estado interno** (registradores, memória) que o bloco lê e escreve: linha própria com direção "estado".

### B2. Tabela de comportamento

**Entrada/condição → saída/efeito**, só os casos principais (não todas as combinações). Para blocos com clock, separe o que é combinacional do que muda na borda de `clk`.

### B3. Como funciona

Passo a passo curto, na ordem em que o dado flui das entradas da tabela B1 até as saídas. Mostre os trechos de código relevantes com link `[arquivo.sv:linha](caminho#Lnn)` e diga o que cada parte faz. Se o bloco tem submódulos, um diagrama em uma linha ou árvore curta da ligação entre eles.

### B4. Exemplo concreto

Tabela curta com valores reais nas entradas e o que aparece nas saídas (instrução, operandos, resultado), incluindo pelo menos um caso de borda. Aponte o testbench que cobre o bloco, se houver.

### B5. Por que existe / por que é assim

Motivo do projeto para o bloco existir ou estar dividido desse jeito (ex.: comparador de branch separado da ALU por timing), o que havia antes e restrições que decorrem disso.

## Regras (os dois modos)

- **Precisão nas palavras:** não use termos que sugiram outro comportamento (ex.: "previsão" para um cálculo exato, "dentro da RAM" quando a flag cobre 4 KiB). Se o usuário usar um termo impreciso, corrija.
- **Analogias** (ex.: números decimais) só quando o usuário disser que não entendeu ou pedir.
- **Quando o usuário resumir o próprio entendimento:** comece dizendo se está certo ("Isso mesmo" / "Quase isso. Faltam N ajustes:") e corrija em itens numerados, cada um com a frase certa em negrito; feche com a tabela atualizada se algo mudou.
- Se for um conceito sem "de onde vem" (ex.: convenção de branch), a seção de origem vira "Onde aparece no RTL".
- Sem meta-texto ("vou explicar...", "em resumo..."), sem oferecer ajuda no final.
