#!/usr/bin/env bash
set -euo pipefail

db="/ruta/real/base_kraken2"
out="results/08.kraken"
hilos=2
mkdir -p "$out" outs

for sample in 0hrs 9hrs 24hrs 48hrs; do
  kraken2 --db "$db" --threads "$hilos" \
    --paired --use-names --confidence 0.10 \
    --report "$out/${sample}_sm.kreport" \
    --output "$out/${sample}_sm.kraken.reads.tsv" \
    "data/${sample}_sm_R1.fastq" "data/${sample}_sm_R2.fastq"
done
