#!/bin/bash
#SBATCH --job-name=align
#SBATCH --output=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/align_%j.log
#SBATCH --error=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/align_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00

WORKDIR=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline

export PATH=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/minimap2:$PATH
export PATH=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/samtools/bin:$PATH

minimap2 -ax map-hifi \
    -t 16 \
    $WORKDIR/reference/GRCh38.fa \
    $WORKDIR/data/fastq/HG002_half.fastq.gz \
    | samtools sort -@ 16 -o $WORKDIR/results/HG002_aligned.bam

samtools index $WORKDIR/results/HG002_aligned.bam

echo "Alignment done"
