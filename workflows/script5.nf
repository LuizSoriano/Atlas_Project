params.reads = "$projectDir/../data/reads/SRR12172675_{1,2}.fastq"
params.outdir = "$projectDir/../data/results/Slycopersicum_691_ITAG4"
params.adapter_path = "$projectDir/../data/inputs/db/adapters/all_adapters.fa"
params.leading_quality = 3
params.trailing_quality = 3
params.sliding_window = "4:15"
params.min_length = 40
params.illumina_clip = "ILLUMINACLIP:${params.adapter_path}:2:30:10:2:True"
params.salmon_index = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/salmon_index"
log.info """\
    R N A S E Q - N F   P I P E L I N E
    ===================================
    reads   : ${params.reads}
    adapters       : ${params.adapter_path}
    salmon_index  :${params.salmon_index}
    """
    .stripIndent()

process TRIMMOMATIC {
    tag "TRIMMOMATIC on $sample_id"

    input:
    // Recebe uma tupla com sample_id e os arquivos FASTQ pareados brutos
    tuple val(sample_id), path(raw_reads)

    output:
    // Produz os arquivos trimados (apenas os pares)
    tuple val(sample_id), path("${sample_id}_trimmed_1.fastq"), path("${sample_id}_trimmed_2.fastq")

    script:
    """
    # Execute o Trimmomatic em modo paired-end
    trimmomatic PE -phred33 -threads $task.cpus \\
      ${raw_reads[0]} ${raw_reads[1]} \\
      ${sample_id}_trimmed_1.fastq ${sample_id}_unpaired_1.fastq \\
      ${sample_id}_trimmed_2.fastq ${sample_id}_unpaired_2.fastq \\
      $params.illumina_clip \\
      LEADING:${params.leading_quality} TRAILING:${params.trailing_quality} \\
      SLIDINGWINDOW:${params.sliding_window} MINLEN:${params.min_length}

    # Removendo os arquivos unpaired (opcional) se não forem usados
    rm ${sample_id}_unpaired_1.fastq ${sample_id}_unpaired_2.fastq
    """
}

process QUANTIFICATION {
    tag "Salmon on $sample_id"
    publishDir "${params.outdir}/${sample_id}", mode:'copy'

    input:
    path salmon_index
    tuple val(sample_id), path(trimmed_1), path(trimmed_2)

    output:
    tuple val(sample_id), path(salmon)

    script:
    """
    salmon quant --threads $task.cpus --libType=A -i $salmon_index -1 ${trimmed_1} -2 ${trimmed_2} -o salmon
    """
}

process FASTQC {
    tag "FASTQC on $sample_id"
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(trimmed_1), path(trimmed_2)

    output:
    tuple val(sample_id), path(fastQC)

    script:
    """
    mkdir -p fastQC
    fastqc -q ${trimmed_1} -o fastQC
    fastqc -q ${trimmed_2} -o fastQC
    """
}

process CLEAN_IDS {
    output:
    path 'sample_ids.txt'

    script:
    """
    rm -f sample_ids.txt
    touch sample_ids.txt
    """
}


workflow {
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }

    CLEAN_IDS()
    // Processo de Trimmomatic para limpar os dados raw
    trimmed_ch = TRIMMOMATIC(read_pairs_ch)

    // Quantificação com Salmon
    quant_ch = QUANTIFICATION(params.salmon_index, trimmed_ch)

    // Execução de FASTQC nos arquivos amostrados
    fastqc_ch = FASTQC(trimmed_ch)

    sample_ids_ch = quant_ch
        .map { sample_id, salmon_dir -> sample_id }
        .distinct()

    sample_ids_ch
        .collectFile(
         name:     'sample_ids.txt',
         storeDir: params.outdir,
         newLine:  true,
         sort:     true
    )

}

workflow.onComplete {
    log.info ( workflow.success ? "\nCompleto! Abra o relatório no seu navegador --> $params.outdir\n" : "Oops .. algo deu errado" )
}
