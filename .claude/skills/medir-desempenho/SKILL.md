---
name: medir-desempenho
description: Use ao planejar, rodar, analisar ou apresentar experimentos de desempenho — benchmarks, tempo de execução, comparação entre versões (sequencial, paralela, distribuída, otimizada), speedup, eficiência, escalabilidade forte/fraca, custo de comunicação e sincronização, gargalos, lei de Amdahl/Gustafson, Karp-Flatt, profiling, configuração experimental (CPU, núcleos, RAM, SO, versões), CSV de resultados, gráficos e tabelas para relatório ou slides. Também ao comparar antes/depois de uma otimização. NÃO usar para escrever o texto do relatório nem para depurar resultado incorreto.
---

# Medir desempenho

Princípio: **diagnosticar com dados, mudar uma coisa, medir de novo. Nunca dizer que algo melhorou
sem número de antes e depois, na mesma configuração.**

**Antes de começar:** ler o `CLAUDE.md` do projeto. Se houver a seção **"Perfil para as skills"**,
usar `comando_testes`, `pasta_experimentos`, `maquina` e `restricoes` (modelo em
`modelos/CLAUDE-perfil.md`). Sem perfil: resultados em `experimentos/` e a máquina capturada na hora.

## 1. Validade antes de tempo

- **Um tempo só vale se o resultado estiver correto.** Versões que deveriam ser equivalentes
  (sequencial × paralela × distribuída × otimizada) devem produzir a mesma saída — conferir por
  *hash*/comparação no mesmo cenário. Divergiu → não é resultado, é bug.
- **Mesmos cenários em todas as versões comparadas.** Variar uma dimensão por vez (tamanho da
  entrada, nº de *workers*/hosts, parâmetros do problema) e registrar todas.
- Respeitar as `restricoes` do projeto (ex.: trabalhos que proíbem paralelismo implícito ou certas
  bibliotecas no núcleo do cálculo). Bibliotecas de análise e gráfico (pandas, matplotlib) fora do
  código medido normalmente são permitidas — confirme no perfil.
- Parâmetros do problema que fazem a execução terminar cedo demais (critério de parada, entrada
  degenerada) tornam a comparação inútil: escolher conscientemente e dizer qual foi usado. Se houver
  parada antecipada, medir **custo por passo** com ela desligada, e o caso real com ela ligada,
  sem misturar os dois na mesma tabela.

## 2. Como medir

- Relógio monotônico de alta resolução (`time.perf_counter()`, `System.nanoTime()`,
  `std::chrono::steady_clock`). **Fora** do tempo medido: impressão por passo, desenho, escrita de
  arquivo. Quando há paralelismo/distribuição, separar e registrar: `t_inicializacao` (criar
  processos/threads, conectar, distribuir dados), `t_calculo`, `t_comunicacao`, `t_sincronizacao`
  (espera em barreira/redução) e `t_total`.
- **Aquecimento:** 1 execução descartada por cenário (JIT, caches, *page faults*). **Repetições:** ≥ 5;
  reportar **mediana** (e média ± desvio padrão na tabela). Mais repetições se o coeficiente de
  variação passar de 5%.
- Ambiente estável: na tomada, perfil de energia de alto desempenho, outros programas fechados,
  mesma máquina para tudo que estiver no mesmo gráfico. Anotar exceções.
- **Custo de criar processos:** no Windows e no macOS o `multiprocessing` usa *spawn* (centenas de
  ms); reportar speedup com e sem `t_inicializacao` e explicar.
- **Núcleos:** registrar físicos e lógicos e o tipo. Em CPUs híbridas (núcleos de desempenho e de
  eficiência) e com SMT/*hyperthreading*, a eficiência cai por **hardware** ao passar do nº de
  núcleos P, depois do nº de núcleos físicos — marcar esses pontos nos gráficos e explicar.
- **Distribuído:** registrar hosts, processos por host e tipo de rede (loopback, Wi-Fi, cabo).
  Teste só em `localhost` mede *overhead* de processo e socket, não de rede: dizer isso.

## 3. Configuração experimental (capturar automaticamente)

```python
import json, os, platform, subprocess, sys

def ambiente():
    info = {"so": platform.platform(), "python": sys.version.split()[0],
            "cpu_logicos": os.cpu_count(), "maquina": platform.node()}
    try:
        if sys.platform.startswith("win"):
            ps = ("@{cpu = Get-CimInstance Win32_Processor | "
                  "Select-Object Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed; "
                  "ram_bytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory} | ConvertTo-Json")
            info.update(json.loads(subprocess.run(["powershell", "-NoProfile", "-Command", ps],
                                                  capture_output=True, text=True).stdout))
        elif sys.platform == "darwin":
            q = lambda k: subprocess.run(["sysctl", "-n", k], capture_output=True, text=True).stdout.strip()
            info.update(cpu=q("machdep.cpu.brand_string"), nucleos_fisicos=q("hw.physicalcpu"),
                        ram_bytes=q("hw.memsize"))
        else:
            info["lscpu"] = subprocess.run(["lscpu"], capture_output=True, text=True).stdout
            info["ram_bytes"] = os.sysconf("SC_PAGE_SIZE") * os.sysconf("SC_PHYS_PAGES")
    except Exception as e:  # a medição não deve falhar por causa disto
        info["erro_captura"] = repr(e)
    return info
```

Salvar junto dos resultados (`ambiente_<maquina>.json`). Registrar também a versão do compilador/JVM
quando houver e o commit medido (`git rev-parse --short HEAD`).

## 4. Formato dos resultados

`<pasta_experimentos>/`: scripts de execução, `resultados/*.csv` (dados brutos, **uma linha por
execução**) e `graficos/` (gerados por script, nunca à mão). Colunas mínimas:

```
data_hora, commit, maquina, versao, variante, <parâmetros do cenário...>, workers, hosts,
repeticao, aquecimento, t_total, t_inicializacao, t_calculo, t_comunicacao, t_sincronizacao,
<saída resumida/hash para conferir equivalência>
```

Mudou o formato → avisar (quebra scripts de análise) e registrar no commit.

## 5. Métricas e análise

- **Speedup** `S_p = T_1 / T_p` e **eficiência** `E_p = S_p / p`, com `T_1` = **melhor versão
  sequencial do mesmo algoritmo**. Ganho de algoritmo (versão original → sequencial otimizada) é
  mostrado à parte do ganho de paralelismo.
- **Fração serial experimental (Karp–Flatt):** `e = (1/S_p − 1/p) / (1 − 1/p)`. `e` crescendo com
  `p` → *overhead* de sincronização/comunicação; `e` constante → parte serial (Amdahl).
- **Escalabilidade forte** (problema fixo, `p` cresce) e **fraca** (trabalho por *worker* fixo),
  ligando às leis de Amdahl e Gustafson.
- **Comunicação:** estimar bytes por passo e comparar `t_comunicacao` com `t_calculo`; mostrar a
  partir de que tamanho de problema a versão distribuída compensa.
- **Gargalos:** decomposição de tempos e *profiler* (`cProfile`/`py-spy`, VisualVM, `perf`) numa
  execução representativa.

## 6. Gráficos e tabelas

- Mínimo para comparação de versões: tempo × *workers* por tamanho; speedup × *workers* com a
  **linha ideal** `S = p`; eficiência × *workers*; barras empilhadas da decomposição de tempos;
  tabela comparativa nos mesmos cenários.
- Eixos com unidade, legenda, mesma cor para a mesma versão em todos os gráficos, barras de erro
  quando houver, marcação dos limites de hardware (núcleos P, físicos, lógicos).
- Exportar vetorial (PDF/SVG) para LaTeX; PNG em alta resolução para slides.

## 7. Antes/depois de uma otimização

1. Medir a linha de base nos cenários afetados, com o commit registrado.
2. Mudar **uma** coisa.
3. Conferir equivalência da saída.
4. Medir de novo na mesma máquina e condições.
5. Relatar: cenário, antes → depois (mediana e desvio), variação %, e se a diferença supera a
   variação entre repetições. Sem isso, não afirmar ganho.
