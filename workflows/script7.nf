params.results_dir = "$projectDir/../data/results/Slycopersicum_691_ITAG4"
params.sample_ids_file = "${params.results_dir}/sample_ids.txt"

log.info """
    MULTIQC PIPELINE
    ================
    resultados dir : ${params.results_dir}
    sample_ids     : ${params.sample_ids_file}
"""
    .stripIndent()



process MULTIQC {
    tag "MultiQC on $sample_id"
    publishDir "${params.results_dir}/${sample_id}/multiQC", mode:'copy'

    input:
    tuple val(sample_id), path(salmon_dir), path(fastqc_dir)

    output:
    path "multiqc_report_${sample_id}.html"

    script:
    """
    mkdir -p multiQC
    # roda MultiQC sobre as pastas salmon e fastQC
    multiqc ${salmon_dir} ${fastqc_dir} -o multiQC

    # opcional: renomeia o relatório para incluir o sample_id
    mv multiQC/multiqc_report.html multiqc_report_${sample_id}.html
    """
}

workflow{
Channel
    .fromPath(params.sample_ids_file)
    .splitText()                         // divide em linhas
    .map { it.trim() }                   // tira espaços
    .filter { it }                       // descarta linhas vazias
    .map { sample_id ->                  // para cada sample_id:
        def base = file("${params.results_dir}/${sample_id}")
        def salmon = file("${base}/salmon")
        def fastqc = file("${base}/fastQC")
        tuple(sample_id, salmon, fastqc)
    }
    .set { multiqc_inputs }

    MULTIQC(multiqc_inputs)
}


workflow.onComplete {
    log.info ( workflow.success ? "\nCompleto! Abra o relatório no seu navegador --> $params.results_dir/\n" : "Oops .. algo deu errado" )
}