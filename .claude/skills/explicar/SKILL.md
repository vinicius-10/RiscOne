---
name: explicar
description: Use quando o usuário digitar /explicar ou pedir para explicar algo do projeto — "para que serve X", "o que é X", "o que X faz", "explica X", "não entendi X", "de onde vem X" — sobre um sinal, porta, flag, módulo, instrução ou conceito do RTL/software deste processador. Define o formato da resposta (tabela primeiro, depois o que é, de onde vem e por que existe). NÃO usar para pedidos de mudança de código, review com achados ou planejamento.
---

# Explicar algo do projeto

Objetivo: o usuário entender **o que a coisa faz** logo na primeira olhada e depois **de onde ela vem** e **por que existe**, nessa ordem.

Antes de escrever, leia o RTL envolvido (declaração, onde é gerado, onde é usado, testbench que cobre). O RTL é a fonte da verdade; não explique de memória. Responda em português.

## Formato (sempre nesta ordem)

### 1. Tabela-resumo (primeiro de tudo)

Uma tabela direta, sem texto antes dela além de no máximo uma linha de título. Escolha as colunas conforme o que está sendo explicado:

- **Sinal / flag / porta:** valor → o que acontece. Se o efeito depende de outro sinal, inclua as combinações (ex.: `addr_page0_i` × `addr_io_i`), e marque combinações impossíveis como "não acontece" com o motivo curto.
- **Módulo:** entrada/condição → saída/efeito (os casos principais, não todas as portas).
- **Instrução:** campo/condição → resultado (ex.: rd recebe, PC vai para).
- **Conceito:** situação → comportamento.

### 2. O que é

Afirmações diretas, sem enquadrar como pergunta. Não escreva "X responde a uma pergunta: ...?". Escreva:

> É um fio de 1 bit que indica se o endereço do load/store está no começo da memória (de `0x000` a `0xFFF`).
>
> - **1** = a RAM pode ser usada.
> - **0** = a RAM fica desligada: o store não escreve e o load não lê dela.

Diga o tipo/largura (fio de 1 bit, barramento de 32 bits, módulo combinacional, registrador...), o que cada valor ou estado significa e quem usa o resultado (com link `[arquivo.sv:linha](caminho#Lnn)`). Se o valor sozinho não basta (ex.: a flag cobre 4 KiB mas a RAM tem 1 KiB), mostre o teste adicional que o consumidor faz.

### 3. De onde vem e como é definido

- **Caminho do sinal** entre módulos, em uma linha:
  `execution.mem_page0_o ──► core.data_memory_addr_page0 ──► data_memory.addr_page0_i`
  seguido dos links para declaração e ligações.
- **Como é calculado:** o trecho de código relevante (curto) com o que cada parte faz.
- **Exemplos concretos:** tabela curta de casos reais (instrução, operandos, valor resultante, efeito), incluindo pelo menos um caso de borda. No testbench, aponte onde a referência é calculada se ajudar.

### 4. Por que existe

Seção própria no final: o motivo do projeto (ex.: tirar o carry de 32 bits do caminho crítico até a RAM), o que havia antes e o que mudou. Se houver restrição que decorre disso (ex.: RAM limitada a 4 KiB, só exato para imediato de 12 bits), liste aqui.

## Regras

- **Precisão nas palavras:** não use termos que sugiram outro comportamento (ex.: "previsão" para um cálculo exato, "dentro da RAM" quando a flag cobre 4 KiB). Se o usuário usar um termo impreciso, corrija.
- **Analogias** (ex.: números decimais) só quando o usuário disser que não entendeu ou pedir.
- **Quando o usuário resumir o próprio entendimento:** comece dizendo se está certo ("Isso mesmo" / "Quase isso. Faltam N ajustes:") e corrija em itens numerados, cada um com a frase certa em negrito; feche com a tabela atualizada se algo mudou.
- Se for um conceito sem "de onde vem" (ex.: convenção de branch), a seção 3 vira "Onde aparece no RTL".
- Sem meta-texto ("vou explicar...", "em resumo..."), sem oferecer ajuda no final.
