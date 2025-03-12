params.reads = "$projectDir/../reads/SRR12172675_{1,2}.fastq"
params.outdir = "$projectDir/../results"
params.adapter_path = "$projectDir/../adapters/all_adapters.fa"
params.leading_quality = 3
params.trailing_quality = 3
params.sliding_window = "4:15"
params.min_length = 40
params.illumina_clip = "ILLUMINACLIP:${params.adapter_path}:2:30:10:2:True"
params.salmon_index = "$projectDir/../salmon/salmon_index"
log.info """\
    R N A S E Q - N F   P I P E L I N E
    ===================================
    reads   : ${params.reads}
    adapters       : ${params.adapter_path}
    salmon_index  :${params.salmon_index}
    """
    .stripIndent()

process TRIMMOMATIC {
    tag "$sample_id"

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
    publishDir params.outdir, mode:'copy'

    input:
    path salmon_index
    tuple val(sample_id), path(trimmed_1), path(trimmed_2)

    output:
    path "$sample_id"

    script:
    """
    salmon quant --threads $task.cpus --libType=A -i $salmon_index -1 ${trimmed_1} -2 ${trimmed_2} -o $sample_id
    """
}

process FASTQC {
    tag "FASTQC on $sample_id"
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(sample_id), path(trimmed_1), path(trimmed_2)

    output:
    path 'fastQC'

    script:
    """
    mkdir fastQC
    fastqc -q ${trimmed_1} -o fastQC
    fastqc -q ${trimmed_2} -o fastQC 
    """
}

process MULTIQC {
    publishDir params.outdir, mode:'copy'

    input:
    path '*'

    output:
    path 'multiqc_report.html'

    script:
    """
    multiqc .
    """
}

workflow {
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }


    // Processo de Trimmomatic para limpar os dados raw
    trimmed_ch = TRIMMOMATIC(read_pairs_ch)

    // Quantificação com Salmon
    quant_ch = QUANTIFICATION(params.salmon_index, trimmed_ch)

    // Execução de FASTQC nos arquivos amostrados
    fastqc_ch = FASTQC(trimmed_ch)

    // Execute MultiQC nos resultados coletados
    MULTIQC(quant_ch.mix(fastqc_ch).collect())
}

workflow.onComplete {
    log.info ( workflow.success ? "\nCompleto! Abra o relatório no seu navegador --> $params.outdir/multiqc_report.html\n" : "Oops .. algo deu errado" )
}
