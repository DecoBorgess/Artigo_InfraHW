#!/usr/bin/env bash
#
# benchmark_fio.sh — Benchmark de I/O sequencial e aleatório (fio)
# ============================================================================
# Executa dois testes de leitura com fio para posicionar a RAM na
# hierarquia mais ampla do sistema de armazenamento:
#
#   Sequencial: blocos de 1 MiB  (representativo de transferências em lote)
#   Aleatório:  blocos de 4 KiB  (representativo de acesso a pequenos registros)
#
# Pré-requisito: fio instalado (ex: sudo apt install fio)
#
# Uso:
#   ./benchmark_fio.sh [diretorio_teste] [arquivo_saida.txt]
#
# Aviso: o teste cria um arquivo temporário de 1 GiB no diretório
# informado (padrão: diretório atual) e o remove ao final.

set -euo pipefail

DIR_TESTE="${1:-.}"
SAIDA="${2:-resultados_fio.txt}"
ARQ_TESTE="${DIR_TESTE}/fio_testfile"
TAMANHO="1G"

if ! command -v fio &> /dev/null; then
    echo "Erro: fio não encontrado. Instale com: sudo apt install fio" >&2
    exit 1
fi

echo "Benchmark de I/O (fio)" | tee "$SAIDA"
echo "Data: $(date)" | tee -a "$SAIDA"
echo "Diretório de teste: $DIR_TESTE" | tee -a "$SAIDA"
echo "==========================================================" | tee -a "$SAIDA"

echo "" | tee -a "$SAIDA"
echo "--- Leitura sequencial (blocos de 1 MiB) ---" | tee -a "$SAIDA"
fio --name=seqread \
    --rw=read \
    --bs=1024k \
    --size="$TAMANHO" \
    --filename="$ARQ_TESTE" \
    --ioengine=psync \
    --iodepth=1 \
    --direct=1 | tee -a "$SAIDA"

echo "" | tee -a "$SAIDA"
echo "--- Leitura aleatória (blocos de 4 KiB) ---" | tee -a "$SAIDA"
fio --name=randread \
    --rw=randread \
    --bs=4k \
    --size="$TAMANHO" \
    --filename="$ARQ_TESTE" \
    --ioengine=psync \
    --iodepth=1 \
    --direct=1 | tee -a "$SAIDA"

rm -f "$ARQ_TESTE"

echo ""
echo "Resultados salvos em: $SAIDA"
