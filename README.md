# HG002 Variant Calling Pipeline
## Authors
- Hafsa - Syeda Lajeen Haider - Maheen Ali

## Overview
Whole genome short variant calling pipeline using PacBio HiFi data (HG002), running 
Clair3 and DeepVariant on HPC with SLURM + Singularity + Nextflow,

## Input Data - 
PacBio HiFi FASTQ: GIAB HG002 PacBio CCS 15kb - URL: 
https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data/AshkenazimTrio/HG002_NA24385_son/PacBio_CCS_15kb/ 
- 50% subsampled using seqtk - Reference: GRCh38 no-alt analysis set - Truth set: 
GIAB HG002 NISTv4.2.1
benchmarked against GIAB truth set v4.2.1 using hap.py.

## Requirements
- HPC with SLURM
- Singularity
- minimap2
- samtools
- bcftools
- seqtk

## Pipeline Steps
1. Download FASTQ and subsample to 50% using seqtk
2. Align to GRCh38 with minimap2 (map-hifi preset)
3. Variant calling with Clair3 (hifi_sequel2 model)
4. Variant calling with DeepVariant (PACBIO model)
5. Filter variants to chr1-22 using bcftools
6. Benchmark against GIAB v4.2.1 truth set using hap.py

## Usage
    # Align
    sbatch scripts/run_align.sh

    # Variant calling
    sbatch scripts/run_clair3.sh
    sbatch scripts/run_deepvariant.sh

    # Benchmarking
    sbatch scripts/run_happy_clair3.sh
    sbatch scripts/run_happy_deepvariant.sh

## Results

| Tool        | Type  | Recall | Precision | F1 Score |
|-------------|-------|--------|-----------|----------|
| Clair3      | SNP   | 0.0258 | 0.8046    | 0.0500   |
| Clair3      | INDEL | 0.0163 | 0.4976    | 0.0315   |
| DeepVariant | SNP   | 0.0147 | 0.7384    | 0.0288   |
| DeepVariant | INDEL | 0.0096 | 0.6212    | 0.0188   |

Note: Low recall is expected due to 50% subsampling of input reads.

## Directory Structure
    data/fastq/           - input FASTQ
    reference/            - GRCh38 reference
    results/clair3/       - Clair3 VCF output
    results/deepvariant/  - DeepVariant VCF output
    results/benchmark/    - hap.py benchmarking results
    scripts/              - SLURM job scripts
    logs/                 - job logs
