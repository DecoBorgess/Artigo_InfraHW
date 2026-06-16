#!/usr/bin/env bash
#
# benchmark_mbw.sh — Benchmark de throughput de memória por tamanho de array
# ============================================================================
# Executa o mbw (Memory Bandwidth benchmark) em três tamanhos de array
# estrategicamente escolhidos em relação à capacidade do cache L3 (12 MiB):
#
#   16 MiB    -> próximo ao limiar do L3, ainda parcialmente cacheável
#   128 MiB   -> excede o L3 em mais de uma ordem de grandeza (regime de RAM)
#   1024 MiB  -> ponto de controle para estabilidade da banda em regime de RAM
#
# Pré-requisito: mbw instalado (ex: sudo apt install mbw)
#
# Uso:
#   ./benchmark_mbw.sh [arquivo_saida.txt]

set -euo pipefail

SAIDA="${1:-resultados_mbw.txt}"
TAMANHOS=(16 128 1024)
REPETICOES=3

if ! command -v mbw &> /dev/null; then
    echo "Erro: mbw não encontrado. Instale com: sudo apt install mbw" >&2
    exit 1
fi

echo "Benchmark de throughput de memória (mbw)" | tee "$SAIDA"
echo "Data: $(date)" | tee -a "$SAIDA"
echo "Repetições por tamanho: $REPETICOES" | tee -a "$SAIDA"
echo "==========================================================" | tee -a "$SAIDA"

for tamanho in "${TAMANHOS[@]}"; do
    echo "" | tee -a "$SAIDA"
    echo "--- Array de ${tamanho} MiB ---" | tee -a "$SAIDA"
    mbw -n "$REPETICOES" "$tamanho" | tee -a "$SAIDA"
done

echo "" | tee -a "$SAIDA"
echo "==========================================================" | tee -a "$SAIDA"
echo "Resumo (linhas AVG MEMCPY):" | tee -a "$SAIDA"
grep "AVG.*MEMCPY" "$SAIDA" | tee -a "$SAIDA"

echo ""
echo "Resultados salvos em: $SAIDA"
