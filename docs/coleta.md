# Procedimento de Coleta de Dados

Este documento descreve, passo a passo, como os dados em `dados/` foram
coletados, permitindo a reprodução dos experimentos.

## Ambiente

| Componente | Especificação |
|---|---|
| Processador | Intel Core i5-13420H (Raptor Lake) — 4 P-cores (8 threads) + 4 E-cores (4 threads) |
| Cache L3 | 12 MiB (unificado, compartilhado) |
| RAM | 16 GB DDR5 |
| Armazenamento | NVMe SSD |
| Sistema operacional | Ubuntu 24.04 LTS via WSL2 (Windows 11) |

## 1. Throughput de memória (mbw)

**Ferramenta:** [`mbw`](https://github.com/raas/mbw) (Memory Bandwidth benchmark)

**Instalação:**
```bash
sudo apt install mbw
```

**Execução:**
```bash
./codigo/benchmark_mbw.sh dados/resultados_mbw.txt
```

O script roda o `mbw` com o método `MEMCPY` em três tamanhos de array
(16, 128 e 1024 MiB), cada um repetido 3 vezes. Os tamanhos foram
escolhidos deliberadamente em relação à capacidade do L3 (12 MiB): 16 MiB
está imediatamente acima do limiar, 128 MiB excede o L3 em mais de uma
ordem de grandeza, e 1024 MiB serve como ponto de controle de
estabilidade da banda em regime de RAM.

## 2. Localidade espacial (script Python)

**Ferramenta:** script próprio (`codigo/teste_localidade.py`)

**Execução:**
```bash
python3 codigo/teste_localidade.py 6000
```

O script cria uma matriz 6000×6000 de floats de 64 bits (~274,7 MB) e
mede o tempo de dois padrões de percurso:

- **Loop A (sequencial):** linha por linha, row-major — favorece o
  prefetcher de hardware.
- **Loop B (stride):** coluna por coluna, gerando saltos regulares na
  memória subjacente.

Uma fase de aquecimento (`warm-up`) é executada antes da medição para
reduzir a influência de *cold misses*.

## 3. I/O de armazenamento (fio)

**Ferramenta:** [`fio`](https://github.com/axboe/fio)

**Instalação:**
```bash
sudo apt install fio
```

**Execução:**
```bash
./codigo/benchmark_fio.sh /caminho/com/espaco dados/resultados_fio.txt
```

O script executa dois padrões de leitura sobre um arquivo de 1 GiB:

- **Sequencial:** blocos de 1 MiB, representativo de transferências em lote.
- **Aleatório:** blocos de 4 KiB, representativo de acesso a pequenos registros.

Esses testes permitem comparar o throughput de memória (mbw) com a
vazão real de um dispositivo NVMe, posicionando a RAM na hierarquia
mais ampla do sistema de armazenamento.

## 4. Identificação de topologia de hardware

A topologia de núcleos e cache foi coletada e reconciliada entre três
fontes:

```bash
lscpu
cat /proc/cpuinfo
lstopo --of console
```

complementadas pela inspeção via CPU-Z no Windows (fora do WSL2), usada
como referência final por oferecer a granularidade mais detalhada
quanto à distinção entre P-cores e E-cores.

## Observação sobre o ambiente WSL2

Todos os testes foram executados em WSL2 sobre Windows 11. Essa camada
de virtualização leve pode introduzir *overhead* mensurável sobre
operações de memória e I/O, tornando os valores absolutos conservadores
em relação a um ambiente Linux nativo (*bare-metal*). Essa limitação é
discutida em detalhe no artigo (ver `docs/artigo.pdf`).
