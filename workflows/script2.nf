params.token_file = "$projectDir/../inputs/.jgi_token"
params.project_id = '691'
params.output_dir = "$projectDir/../teste_input"


process DOWNLOAD_SPECIFIC_FILES {
    // Diretório de saída será copiado para o diretório externo
    publishDir params.output_dir, mode: 'copy'

    input:
    path token_file
    val project_id

    output:
    path "${task.workDir}/output/*"  // Usar o diretório temporário de trabalho


    script:
    """
    #!/bin/bash

    # Criar o diretório temporário dentro do diretório de trabalho do processo
    mkdir -p ${task.workDir}/output

    # Token de autenticação
    TOKEN=\$(grep BEARER_TOKEN ${token_file} | cut -d '=' -f2)

    # Validação do token
    echo "🔍 Validando token..."
    VALIDATION_STATUS=\$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer \$TOKEN" "https://data.jgi.doe.gov/api/projects/${project_id}")

    if [ "\$VALIDATION_STATUS" != "200" ]; then
        echo "❌ Token inválido ou expirado (HTTP \$VALIDATION_STATUS). Abortando."
        exit 1
    fi

    echo "✅ Token válido! Iniciando download dos metadados..."

    curl -H "Authorization: Bearer \$TOKEN" \
         "https://data.jgi.doe.gov/api/projects/${project_id}" \
         -o ${task.workDir}/output/metadata.json

    # Arquivos a serem baixados
    FILES_TO_DOWNLOAD=(
        "Slycopersicum_691_ITAG4.0.transcript_primaryTranscriptOnly.fa"
        "Slycopersicum_691_ITAG4.0.transcript.fa"
        "Slycopersicum_691_ITAG4.0.gene_exons.gff3"
        "Slycopersicum_691_ITAG4.0.gene.gff3"
    )

    # Baixar os arquivos para o diretório temporário
    for file_name in "\${FILES_TO_DOWNLOAD[@]}"; do
        FILE_URL=\$(jq -r --arg NAME "\$file_name" '.files[] | select(.name == \$NAME) | .url' ${task.workDir}/output/metadata.json)

        if [ "\$FILE_URL" != "" ]; then
            echo "⬇️ Baixando \$file_name ..."
            wget --header="Authorization: Bearer \$TOKEN" -P ${task.workDir}/output "\$FILE_URL"
        else
            echo "⚠️ Arquivo \$file_name não encontrado no projeto."
        fi
    done
    """
}


workflow {
    DOWNLOAD_SPECIFIC_FILES(params.token_file, params.project_id)
}

workflow.onComplete {
    log.info (workflow.success ? "\nCompleto! Seus arquivos estão disponíveis em --> $projectDir/../$params.output_dir\n" : "Oops .. algo deu errado")
}

