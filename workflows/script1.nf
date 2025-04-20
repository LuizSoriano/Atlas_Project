params.genome_id = "691"
params.species_info_json = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/species_info/species_info.json"
params.species_info_output_dir = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/species_info"


process EXTRACT_METADATA {
    publishDir params.species_info_output_dir, mode: 'copy'

    input:
    val genome_id
    path json_path

    output:
    path "meta_output.json"


    script:
    """

     if [ ! -s "$json_path" ]; then
        echo "Erro: O arquivo JSON não existe ou está vazio: $json_path"
        exit 1
    fi


    # Remove espaços e quebras de linha do genome_id, se houver
    gid=\$(echo "$genome_id" | tr -d '[:space:]')
    echo "Genome ID usado: \$gid"

    # Extrai os valores do JSON
    specie=\$(jq -r '.species' "$json_path")
    annotation_version=\$(jq -r --argjson gid "\$gid" '.ids[] | select(.agg_id == \$gid) | .annotation_version' "$json_path")
    assembly_version=\$(jq -r --argjson gid "\$gid" '.ids[] | select(.agg_id == \$gid) | .assembly_version' "$json_path")


    jq -n --argjson genome_id "\$gid" \
      --arg specie "\$specie" \
      --arg annotation_version "\$annotation_version" \
      --arg assembly_version "\$assembly_version" \
      '{genome_id: \$genome_id, specie: \$specie, annotation_version: \$annotation_version, assembly_version: \$assembly_version}' > meta_output.json

    """

}

workflow {
    id_ch = Channel.of(params.genome_id)
    meta_ch = EXTRACT_METADATA(id_ch, file(params.species_info_json))
}

workflow.onComplete {
    log.info (workflow.success ? "\nCompleto! Seus arquivos estão disponíveis em --> $projectDir/../$params.species_info_output_dir\n" : "Oops .. algo deu errado")
}