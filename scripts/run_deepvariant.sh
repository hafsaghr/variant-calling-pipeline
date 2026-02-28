#!/bin/bash
#SBATCH --job-name=deepvariant
#SBATCH --output=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/deepvariant_%j.log
#SBATCH --error=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline/logs/deepvariant_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00

WORKDIR=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/variant_calling_pipeline

singularity exec \
    --bind $WORKDIR \
    /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/deepvariant_1.6.1.sif \
    /opt/deepvariant/bin/run_deepvariant \
    --model_type=PACBIO \
    --ref=$WORKDIR/reference/GRCh38.fa \
    --reads=$WORKDIR/results/HG002_aligned.bam \
    --output_vcf=$WORKDIR/results/deepvariant/HG002_deepvariant.vcf.gz \
    --output_gvcf=$WORKDIR/results/deepvariant/HG002_deepvariant.g.vcf.gz \
    --num_shards=16

echo "DeepVariant done"
