#!/usr/bin/env bash
set -euo pipefail

db="/ruta/real/base_kaiju"
indice="$db/kaiju_db_nr_euk.fmi"
out="results/07.kaiju"
hilos=2
mkdir -p "$out" outs

for sample in 0hrs 9hrs 24hrs 48hrs; do
  kaiju -t "$db/nodes.dmp" -f "$indice" \
    -i "data/${sample}_sm_R1.fastq" \
    -j "data/${sample}_sm_R2.fastq" \
    -o "$out/${sample}.out" \
    -z "$hilos" -a mem -m 13

  kaiju-addTaxonNames -t "$db/nodes.dmp" -n "$db/names.dmp" \
    -i "$out/${sample}.out" -u -p \
    -o "$out/${sample}_names.out"
done

kaiju2table -t "$db/nodes.dmp" -n "$db/names.dmp" \
  -p -c 50 -r species -o "$out/kaiju_summary.tsv" \
  "$out/0hrs.out" "$out/9hrs.out" \
  "$out/24hrs.out" "$out/48hrs.out"
