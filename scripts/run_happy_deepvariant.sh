#!/bin/bash
#SBATCH --job-name=happy_dv
#SBATCH --output=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/happy_dv_%j.log
#SBATCH --error=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/happy_dv_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=4:00:00

WORKDIR=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline

mkdir -p $WORKDIR/results/benchmark/happy_deepvariant

singularity exec \
    --bind $WORKDIR \
    /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/hap.py_latest.sif \
    /opt/hap.py/bin/hap.py \
    $WORKDIR/results/benchmark/HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz \
    $WORKDIR/results/deepvariant/HG002_deepvariant_chr1-22.vcf.gz \
    -f $WORKDIR/results/benchmark/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed \
    -r $WORKDIR/reference/GRCh38.fa \
    -o $WORKDIR/results/benchmark/happy_deepvariant/deepvariant_benchmark \
    --engine=vcfeval \
    --threads=8

echo "hap.py deepvariant done"
