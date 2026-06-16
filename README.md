# Caracterização Experimental do Limiar de Cache L3 em Throughput de Memória

Repositório de apoio ao artigo *"Caracterização Experimental do Limiar
de Cache L3 em Throughput de Memória: um Estudo em Arquitetura Híbrida
Intel Raptor Lake"*, desenvolvido para a disciplina de Infraestrutura
de Hardware (CESAR School).

## Pergunta de pesquisa

Qual é o efeito quantitativo da capacidade do cache L3 sobre o
throughput de cópia de memória em um processador híbrido Intel Core
i5-13420H, e em que medida esse efeito se manifesta como um limiar
identificável e reprodutível?

## Principais resultados

- Queda de **17,7%** no throughput de memória ao cruzar o limiar de
  capacidade do L3 (12 MiB), validando experimentalmente a
  especificação nominal do fabricante.
- Razão B/A de apenas **1,11×** entre acesso em stride e acesso
  sequencial, evidenciando a eficácia do *prefetcher* de hardware dos
  P-cores Raptor Cove em mitigar penalidades de localidade.
- Diferença de quase **duas ordens de grandeza** entre o throughput de
  memória (RAM) e a leitura aleatória em armazenamento NVMe.

## Estrutura do repositório

.
├── codigo/
│   ├── benchmark_mbw.sh        Benchmark de throughput de memória (mbw)
│   ├── benchmark_fio.sh        Benchmark de I/O sequencial e aleatório (fio)
│   └── teste_localidade.py     Teste de localidade espacial (Python)
├── dados/
│   ├── resultados_mbw.txt           Saída do benchmark de throughput
│   ├── resultados_localidade.txt    Saída do teste de localidade espacial
│   ├── resultados_fio_sequencial.txt
│   └── resultados_fio_aleatorio.txt
└── docs/
    ├── artigo.pdf      Artigo completo (formato SBC)
    └── coleta.md       Passo a passo de coleta e reprodução dos experimentos

## Como reproduzir

Pré-requisitos: Linux (ou WSL2), Python 3, `mbw` e `fio` instalados.

```bash
# Throughput de memória
sudo apt install mbw
./codigo/benchmark_mbw.sh dados/resultados_mbw.txt

# Localidade espacial
python3 codigo/teste_localidade.py 6000

# I/O de armazenamento
sudo apt install fio
./codigo/benchmark_fio.sh /tmp dados/resultados_fio.txt
```

Detalhes completos do procedimento de coleta estão em
[`docs/coleta.md`](docs/coleta.md).

## Ambiente de teste

Intel Core i5-13420H (Raptor Lake, 4 P-cores + 4 E-cores, 12 threads),
16 GB RAM DDR5, NVMe SSD, Ubuntu 24.04 LTS via WSL2 (Windows 11).

## Autor

André Borges Viana — Curso de Ciência da Computação, CESAR School.

## Licença

Conteúdo acadêmico produzido para fins educacionais.
