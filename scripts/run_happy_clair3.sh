#!/bin/bash
#SBATCH --job-name=happy_clair3
#SBATCH --output=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/happy_clair3_%j.log
#SBATCH --error=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/happy_clair3_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=4:00:00

WORKDIR=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline

mkdir -p $WORKDIR/results/benchmark/happy_clair3

singularity exec \
    --bind $WORKDIR \
    /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/hap.py_latest.sif \
    /opt/hap.py/bin/hap.py \
    $WORKDIR/results/benchmark/HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz \
    $WORKDIR/results/clair3/HG002_clair3_chr1-22.vcf.gz \
    -f $WORKDIR/results/benchmark/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed \
    -r $WORKDIR/reference/GRCh38.fa \
    -o $WORKDIR/results/benchmark/happy_clair3/clair3_benchmark \
    --engine=vcfeval \
    --threads=8

echo "hap.py clair3 done"
