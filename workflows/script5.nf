params.genome_fasta = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/genoma/output/Slycopersicum_691_SL4.0.fa"
params.gff_file = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/genoma/output/Slycopersicum_691_ITAG4.0.gene.gff3"
params.transcriptome_file = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/genoma/output/Slycopersicum_691_ITAG4.0.transcript_primaryTranscriptOnly.fa"
params.out_decoy = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4"
params.out_index = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4"
log.info """\
    R N A S E Q - N F   P I P E L I N E
    ===================================
    Genome fasta   : ${params.genome_fasta}
    GFF file       : ${params.gff_file}
    transcriptome   :${params.transcriptome_file}
    """
    .stripIndent()


process GENERATE_GTF {
    input:
    path gff_file

    output:
    path 'gtf_file.gtf'

    script:
    """
    # Gerar transcriptoma usando gffread
    gffread $gff_file -T -o gtf_file.gtf
    """
}


process GENERATE_TRANSCRIPTOME_WITH_DECOYS {
    publishDir params.out_decoy, mode:'copy'

    input:
    path genome_fasta
    path gtf_file 
    path transcriptome_file

    output:
    path "decoy/gentrome.fa", emit: gentrome
    path "decoy/decoys.txt", emit: decoys

    script:
    """
    mkdir decoy
   /usr/local/bin/generateDecoyTranscriptome.sh -j $task.cpus -a $gtf_file -g $genome_fasta -t $transcriptome_file -o decoy
    """
}


process INDEX_WITH_DECOYS {
    publishDir params.out_index, mode:'copy'

    input:
    path gentrome
    path decoys

    output:
    path 'salmon_index'

    script:
    """
    # Geração do índice com decoys usando Salmon
    salmon index -t $gentrome -i salmon_index --decoys $decoys -k 31
    """
}



workflow {

    gtf_ch = GENERATE_GTF(params.gff_file)

    decoy_ch = GENERATE_TRANSCRIPTOME_WITH_DECOYS(params.genome_fasta, gtf_ch, params.transcriptome_file)

    index_ch = INDEX_WITH_DECOYS(decoy_ch.gentrome, decoy_ch.decoys)
}

workflow.onComplete {
    log.info ( workflow.success ? "\nCompleto! A indexação está disponível em --> $params.out_index/salmon_index\n" : "Oops .. algo deu errado" )
}
