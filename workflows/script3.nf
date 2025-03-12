params.out_sra = "$projectDir/../reads"
params.lib = "SRR12172675"

process DOWNLOAD_SRA {
    tag "$sra_id"
    publishDir params.out_sra, mode:'copy'

    input:
    val sra_id

    output:
    path "${sra_id}_1.fastq"
    path "${sra_id}_2.fastq"

    script:
    """
    # Baixa e converte os dados do SRA para FASTQ pareado
    fasterq-dump --split-files $sra_id
    """
}

workflow {
    sra_ids_ch = Channel.of(params.lib)
    reads_ch = DOWNLOAD_SRA(sra_ids_ch)
}

workflow.onComplete {
    log.info ( workflow.success ? "\nCompleto! Suas reads estão disponíveis em --> $params.out_sra\n" : "Oops .. algo deu errado" )
}
