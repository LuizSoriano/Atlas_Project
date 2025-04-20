params.token = "/api/sessions/eee331c332b6316d3cf0ddd1d97e1eb0"
params.meta_output = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/species_info/meta_output.json"
params.output_dir = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/genoma"


process DOWNLOAD_SPECIFIC_FILES {
    publishDir params.output_dir, mode: 'copy'

    input:
    path meta_json
    val token

    output:
    path "output/*"

    script:
    """
    #!/bin/bash
    set -e

    # Cria o diretório temporário de saída no workDir
    mkdir -p output


    if [ ! -s "$meta_json" ]; then
        echo "Erro: O arquivo JSON não foi encontrado: $meta_json"
        exit 1
    fi


    # Extraindo informações do JSON
    genome_id=\$(jq -r '.genome_id' "$meta_json")
    specie=\$(jq -r '.specie' "$meta_json")
    annotation_version=\$(jq -r '.annotation_version' "$meta_json")
    assembly_version=\$(jq -r '.assembly_version' "$meta_json")

    echo "Obtendo lista de arquivos para genome_id: \$genome_id"
    curl -s -X GET "https://files.jgi.doe.gov/phytozome_file_list/?genome_id=\$genome_id&api_version=2&a=false&h=false&d=asc&p=1&x=10&t=simple" \\
        -H "accept: application/json" -o output/file_list.json


    # Define os arquivos desejados
    FILES_TO_DOWNLOAD=( \\
        "\${specie}_\${genome_id}_\${annotation_version}.transcript_primaryTranscriptOnly.fa.gz" \\
        "\${specie}_\${genome_id}_\${annotation_version}.transcript.fa.gz" \\
        "\${specie}_\${genome_id}_\${annotation_version}.gene_exons.gff3.gz" \\
        "\${specie}_\${genome_id}_\${annotation_version}.gene.gff3.gz" \\
        "\${specie}_\${genome_id}_\${assembly_version}.fa.gz" \\
    )


      for file_name in "\${FILES_TO_DOWNLOAD[@]}"; do
        file_id=\$(jq -r --arg FILE "\$file_name" '.organisms[].files[] | select(.file_name == \$FILE) | ._id' output/file_list.json)

        echo "Arquivo: \$file_name"
        echo "ID encontrado: \$file_id"

        if [ -n "\$file_id" ] && [ "\$file_id" != "null" ]; then
            echo "Baixando \$file_name com ID \$file_id..."
            curl -L -X GET "https://files-download.jgi.doe.gov/download_files/\$file_id/" \\
                 -H "accept: application/json" \\
                 -H "Authorization: Bearer ${token}" \\
                 -o output/\$file_name
        else
            echo "❌ Erro: ID não encontrado para \$file_name"
        fi
    done

    echo "Listando arquivos baixados em output/..."
    ls -l output/

    echo "Extraindo arquivos .gz..."
    for file in output/*.gz; do
        if [ -f "\$file" ]; then
            echo "Tentando extrair \$file..."
            if gunzip -f "\$file"; then
                echo "Extraído com sucesso: \$file"
            else
                echo "⚠️ Falha ao extrair \$file. Verifique se o arquivo está corrompido ou se não é realmente um arquivo gzip."
            fi
        fi
    done

    echo "Listando arquivos após extração..."
    ls -l output/
    """
}

workflow {
    token_ch = Channel.of(params.token)
    DOWNLOAD_SPECIFIC_FILES(file(params.meta_output), token_ch)
}

workflow.onComplete {
    log.info (workflow.success ? "\nCompleto! Seus arquivos estão disponíveis em --> $projectDir/../$params.output_dir\n" : "Oops .. algo deu errado")
}

