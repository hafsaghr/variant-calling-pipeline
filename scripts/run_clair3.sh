#!/bin/bash
#SBATCH --job-name=clair3
#SBATCH --output=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/clair3_%j.log
#SBATCH --error=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/clair3_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00

WORKDIR=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline

singularity exec \
    --bind $WORKDIR \
    /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/clair3_latest.sif \
    /opt/bin/run_clair3.sh \
    --bam_fn=$WORKDIR/results/HG002_aligned.bam \
    --ref_fn=$WORKDIR/reference/GRCh38.fa \
    --threads=16 \
    --platform="hifi" \
    --model_path=/opt/models/hifi_sequel2 \
    --output=$WORKDIR/results/clair3 \
    --include_all_ctgs

echo "Clair3 done"
