#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.fastq  = "$baseDir/data/fastq/HG002_half.fastq.gz"
params.ref    = "$baseDir/reference/GRCh38.fa"
params.outdir = "$baseDir/results"
params.threads = 16

process ALIGN {
    cpus params.threads
    memory '64 GB'
    time '12h'
    clusterOptions '--partition=gpu'

    output:
    path "HG002_aligned.bam",     emit: bam
    path "HG002_aligned.bam.bai", emit: bai

    script:
    """
    export PATH=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/minimap2:\$PATH
    export PATH=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/samtools/bin:\$PATH
    minimap2 -ax map-hifi -t ${params.threads} ${params.ref} ${params.fastq} | samtools sort -@ ${params.threads} -o HG002_aligned.bam
    samtools index HG002_aligned.bam
    """
}

process CLAIR3 {
    cpus params.threads
    memory '64 GB'
    time '24h'
    clusterOptions '--partition=gpu'

    input:
    path bam
    path bai

    output:
    path "clair3_output/merge_output.vcf.gz", emit: vcf

    script:
    """
    singularity exec --bind ${params.outdir} /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/clair3_latest.sif /opt/bin/run_clair3.sh --bam_fn=${bam} --ref_fn=${params.ref} --threads=${params.threads} --platform="hifi" --model_path=/opt/models/hifi_sequel2 --output=clair3_output --include_all_ctgs
    """
}

process DEEPVARIANT {
    cpus params.threads
    memory '64 GB'
    time '24h'
    clusterOptions '--partition=gpu'

    input:
    path bam
    path bai

    output:
    path "HG002_deepvariant.vcf.gz", emit: vcf

    script:
    """
    singularity exec --bind ${params.outdir} /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/deepvariant_1.6.1.sif /opt/deepvariant/bin/run_deepvariant --model_type=PACBIO --ref=${params.ref} --reads=${bam} --output_vcf=HG002_deepvariant.vcf.gz --output_gvcf=HG002_deepvariant.g.vcf.gz --num_shards=${params.threads}
    """
}

process FILTER_VCF {
    input:
    path vcf
    val  name

    output:
    path "${name}_chr1-22.vcf.gz",     emit: vcf
    path "${name}_chr1-22.vcf.gz.csi", emit: idx

    script:
    """
    export PATH=/hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/bcftools/bin:\$PATH
    bcftools view -r chr1,chr2,chr3,chr4,chr5,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22 ${vcf} -O z -o ${name}_chr1-22.vcf.gz
    bcftools index ${name}_chr1-22.vcf.gz
    """
}

process BENCHMARK {
    cpus 8
    memory '32 GB'
    time '4h'
    clusterOptions '--partition=gpu'

    input:
    path query_vcf
    val  name

    output:
    path "${name}_benchmark.summary.csv"

    script:
    """
    singularity exec --bind ${params.outdir} /hdd4/sines/specialtopicsinbioinformatics/hafsa.sines/singularity_cache/hap.py_latest.sif /opt/hap.py/bin/hap.py ${params.outdir}/benchmark/HG002_GRCh38_1_22_v4.2.1_benchmark.vcf.gz ${query_vcf} -f ${params.outdir}/benchmark/HG002_GRCh38_1_22_v4.2.1_benchmark_noinconsistent.bed -r ${params.ref} -o ${name}_benchmark --engine=vcfeval --threads=8
    """
}

workflow {
    ALIGN()
    CLAIR3(ALIGN.out.bam, ALIGN.out.bai)
    DEEPVARIANT(ALIGN.out.bam, ALIGN.out.bai)
    FILTER_VCF(CLAIR3.out.vcf, "clair3")
    FILTER_VCF(DEEPVARIANT.out.vcf, "deepvariant")
    BENCHMARK(FILTER_VCF.out.vcf, "clair3")
    BENCHMARK(FILTER_VCF.out.vcf, "deepvariant")
}
