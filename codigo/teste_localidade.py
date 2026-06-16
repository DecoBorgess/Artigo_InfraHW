#!/usr/bin/env python3
"""
Teste de Localidade de Cache — Localidade Espacial na Prática
================================================================
Compara o tempo de execução de dois padrões de acesso a uma matriz
quadrada de floats: percurso sequencial (row-major, favorável ao
prefetcher de hardware) e percurso em stride (column-major, gerando
saltos regulares na memória).

Uso:
    python3 teste_localidade.py [N]

    N: dimensão da matriz NxN (padrão: 6000)
"""

import sys
import time


def criar_matriz(n):
    """Cria uma matriz NxN de floats, armazenada como lista de listas
    (row-major), simulando o layout padrão de arrays em C/NumPy."""
    return [[float(i * n + j) for j in range(n)] for i in range(n)]


def loop_sequencial(matriz, n):
    """Loop A: percorre a matriz linha por linha (row-major).
    Acessos a endereços vizinhos -> favorece o prefetcher de hardware."""
    soma = 0.0
    for i in range(n):
        linha = matriz[i]
        for j in range(n):
            soma += linha[j]
    return soma


def loop_stride(matriz, n):
    """Loop B: percorre a matriz coluna por coluna (column-major em
    uma matriz row-major). Cada acesso salta n posições na memória
    subjacente -> tende a gerar mais cache misses."""
    soma = 0.0
    for j in range(n):
        for i in range(n):
            soma += matriz[i][j]
    return soma


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 6000
    tamanho_mb = (n * n * 8) / (1024 ** 2)  # float64 = 8 bytes

    print("=" * 70)
    print("TESTE DE LOCALIDADE DE CACHE — Localidade Espacial na prática")
    print("=" * 70)
    print(f"Matriz: {n}x{n} elementos float64")
    print(f"Tamanho em memória: {tamanho_mb:.1f} MB")
    print(f"Total de operações por loop: {n * n:,}")
    print("=" * 70)
    print()
    print(" Para o efeito ser visível, este script usa loops Python puros.")
    print("  Com NumPy vetorizado, o compilador resolveria isso pra nós.")
    print("  Reduza N se a sua máquina demorar muito (sugestão: 2000).")
    print()

    print("Criando matriz...")
    matriz = criar_matriz(n)

    print("Aquecimento...")
    loop_sequencial(matriz, min(n, 500))  # warm-up curto, reduz cold misses

    print()
    print("[A] Percorrendo linha por linha (sequencial)...")
    t0 = time.perf_counter()
    loop_sequencial(matriz, n)
    t_a = time.perf_counter() - t0
    print(f"    Tempo: {t_a:.2f}s")

    print()
    print("[B] Percorrendo coluna por coluna (com saltos na memória)...")
    t0 = time.perf_counter()
    loop_stride(matriz, n)
    t_b = time.perf_counter() - t0
    print(f"    Tempo: {t_b:.2f}s")

    print()
    print("=" * 70)
    print("RESULTADO")
    print("=" * 70)
    razao = t_b / t_a
    print(f"Loop A (sequencial):       {t_a:.2f}s")
    print(f"Loop B (com saltos):       {t_b:.2f}s")
    print(f"Razão B/A:                 {razao:.2f}x  <- acesso ruim é {razao:.1f}x mais lento")
    print()
    print("INTERPRETAÇÃO:")
    print("  • A matriz é armazenada em memória 'row-major' (linhas contíguas).")
    print("  • Loop A acessa endereços vizinhos -> o cache traz os próximos")
    print("    elementos de graça (cache hit).")
    print("  • Loop B salta de linha em linha -> o cache é invalidado a cada")
    print("    acesso (cache miss).")
    print("  • Mesma quantidade de cálculo, MUITA diferença de tempo.")
    print("  • Conclusão: o gargalo não é a CPU — é trazer dados até ela.")
    print("=" * 70)


if __name__ == "__main__":
    main()
