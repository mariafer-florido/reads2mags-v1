#!/usr/bin/env bash
set -euo pipefail

db="/ruta/real/base_kraken2"
longitud=75
nivel="C"
out="results/08.kraken/bracken"

test -r "$db/database${longitud}mers.kmer_distrib" || {
  echo "Falta la distribución de Bracken para esta longitud y base." >&2
  exit 1
}
mkdir -p "$out" outs

for sample in 0hrs 9hrs 24hrs 48hrs; do
  bracken -d "$db" \
    -i "results/08.kraken/${sample}_sm.kreport" \
    -o "$out/${sample}_sm.bracken.${nivel}.tsv" \
    -r "$longitud" -l "$nivel" -t 10
done
