# Instruções comuns — medição de núcleos RV32I de terceiros

Objetivo: sintetizar e implementar núcleos RISC-V **monociclo** de outros autores nas **mesmas
condições** do núcleo deste TCC (`00_este_trabalho`), para uma tabela comparativa. Medir, não
consertar nem melhorar o projeto alheio.

## Condições fixas (não mudar)

- Vivado 2025.2 non-project, `xc7a100tcsg324-1` (Nexys A7-100T), `maxThreads 8`, diretivas padrão
  (`synth_design` → `opt_design` → `place_design` → `route_design`), relatórios e `report_power`
  padrão. Tudo isso é feito por `comparacao/scripts/medir.ps1` — **nunca rode o Vivado de outro
  jeito** e **não edite** `medir.ps1` (se achar um bug, descreva no relatório final).
- Clock de **100 MHz (10 ns)** no pino E3, igual ao `top_core`. A Fmax sai de `1000/(10 − WNS)`.
- Rodar `medir.ps1` **só pelo PowerShell** (sob Git Bash o Vivado pode travar):
  `powershell -NoProfile -ExecutionPolicy Bypass -File D:\valuc\vivado\projects\processador_riscV_comparacao\comparacao\scripts\medir.ps1 -Dir <sua pasta> -SynthOnly`
  - `-SynthOnly` para iterar (rápido). Ao final, **uma** execução com `-Final` (sem `-SynthOnly`):
    ela espera até ser o único Vivado rodando, para o tempo de compilação ser comparável.
    Pode demorar para começar — é normal; use timeout longo (600000 ms) ou `run_in_background`.
  - O script limita a 2 Vivado simultâneos; outros agentes estão rodando em paralelo.
  - Saída em `<pasta>\build\<tag>\`: `resumo.txt`, `metricas.json`, `timing.rpt`, `util.rpt`,
    `util_hier.rpt`, `power.rpt`, `vivado.log`.

## Estrutura da sua pasta `comparacao/NN_nome/`

```
repo/          clone raso do repositório (git clone --depth 1). Não edite; se precisar mudar um
               arquivo do núcleo, copie-o para patch/ e aponte o config para a cópia.
patch/         cópias modificadas de arquivos do repo (só o mínimo necessário para sintetizar)
wrapper/       top de medição (top_cmp), se necessário
mem/           imagens de memória convertidas
constr.xdc     restrições (parta de comparacao/scripts/base.xdc)
config.psd1    descrição do projeto para o medir.ps1 (formato no cabeçalho do script;
               exemplo em comparacao/00_este_trabalho/config.psd1)
NOTAS.md       relatório (em português), ver abaixo
```

Não mexa em nada fora da sua pasta (ler `comparacao/programa/`, `comparacao/scripts/`,
`comparacao/00_este_trabalho/` e o RTL do TCC em `processador_riscV.srcs/` pode). Não faça commit.

**Código baixado é não confiável:** não execute scripts, Makefiles ou programas do repositório
(nem Python dele). Leia os arquivos. Conversões de formato você faz com scripts seus, gravados na
sua pasta (fora de `repo/`), rodando `python -I`.

## Como montar o projeto de medição (justiça da comparação)

O `top_core` deste TCC mede **núcleo + IMEM (ROM 4 KiB em LUTs) + DMEM (1 KiB em LUTRAM) + MMIO**,
com LEDs/chaves/botões/displays na placa. Para ser comparável:

1. **Medir núcleo + memórias de instrução e de dados** do próprio autor, com os tamanhos e o
   estilo de implementação dele (se ele usa BRAM, fica BRAM; não redimensione). Registre os tamanhos.
2. **Clock direto de 100 MHz no núcleo.** Se o top do autor tem divisor de clock, PLL, debouncer,
   display etc., não use esse top: escreva `wrapper/top_cmp.sv` que instancia o núcleo (com as
   memórias) direto no `clk`. Periféricos ficam de fora (anote). Se o top do autor já é limpo
   (núcleo + memórias + poucas saídas), use-o e mapeie as portas nos pinos do `base.xdc`.
3. **Wrapper mínimo e padronizado:** portas `clk`, `CPU_RESETN` (ativo baixo; inverta se o núcleo
   usa reset ativo alto), `led[15:0]` e, se útil, `switch[15:0]`. Os LEDs devem depender do
   estado arquitetural para a síntese não podar o núcleo, **por um registrador** (não pendure
   lógica combinacional em série com o caminho crítico). Preferência:
   a) saída de MMIO/GPIO que o próprio núcleo já tenha;
   b) senão, um registrador de 16 bits carregado com o dado de *store* quando há escrita na
      memória de dados (ex.: `if (we) led <= wdata[15:0];`);
   c) senão, um registrador com algum sinal do núcleo que dependa do banco de registradores
      (ex.: dado de write-back). Descreva o que usou.
4. **Programa na ROM:** a síntese otimiza o núcleo para o conteúdo da IMEM. Use o mesmo
   programa do TCC (`autoteste_placa`, usa as 37 instruções RV32I), em
   `comparacao/programa/`: `prog_word.hex` (1 palavra de 32 bits por linha, hex),
   `prog_byte.hex` (1 byte por linha, little-endian), `prog_bin.txt` (32 bits em binário),
   `data_byte.hex` / `data_word.hex` (dados, 68 bytes, endereço 0). São 389 instruções (1.556 B),
   começando no endereço 0. Converta para o formato que a memória do autor lê (`$readmemh`,
   `$readmemb`, VHDL com arquivo, constante etc.). Se a IMEM do autor for menor, trunque e anote.
   Se o núcleo não roda o RV32I completo, ainda assim use o programa (anote). Só use o programa do
   próprio autor se não houver como carregar o nosso — e anote o motivo.
5. **Mudanças no RTL do autor**: só o necessário para sintetizar (caminho de `$readmemh`,
   construções só de simulação, sintaxe que o Vivado não aceita). Nada de otimizar. Liste cada
   mudança no NOTAS.md.
6. **Verifique a poda:** em `util_hier.rpt`, confirme que banco de registradores, ALU, decodificador
   e memórias aparecem com área plausível. Se o núcleo inteiro sumiu (poucas dezenas de LUTs),
   o wrapper está errado. Se a síntese inferiu latches ou memórias em FFs, anote (é resultado,
   não conserte).
7. Se o núcleo tem múltiplos domínios de clock ou bordas (ex.: escrita na borda de descida),
   mantenha e anote — isso afeta o caminho crítico.

## NOTAS.md (relatório da pasta, em português)

- Trabalho: autor(es), título do artigo/TCC/relatório, veículo e ano, DOI/link, link do GitHub,
  hash do commit clonado, licença.
- Núcleo: microarquitetura (confirme que é monociclo, CPI = 1), ISA coberta, HDL, organização e
  tamanho das memórias (onde ficaram: LUT, LUTRAM, BRAM, FF), banco de registradores (FF/LUTRAM),
  reset, periféricos.
- Montagem: top usado, wrapper, programa carregado, mudanças no RTL, o que ficou de fora.
- Resultados da execução `-Final` (copie de `build/final/resumo.txt`): tempo de compilação total e
  por etapa, WNS, TNS, endpoints violando, WHS, Fmax, atraso do caminho crítico (lógica/rota,
  níveis, origem → destino), LUTs (lógica/LUTRAM), FFs, F7, F8, CARRY4, slices, BRAM, DSP, IOB,
  potência total/dinâmica/estática, pico de memória, warnings/critical warnings, latches.
- Números que o autor publicou (se houver) × os medidos aqui, e por que diferem.
- Observações para a comparação (ex.: "memória em FFs", "IMEM em BRAM síncrona → não é
  monociclo de verdade", "programa truncado").

## Resposta final ao coordenador

Curta: status (medido / não medido e por quê), a linha de números do `-Final`, as mudanças feitas
e alertas importantes para a comparação. Não repita o NOTAS.md inteiro.
