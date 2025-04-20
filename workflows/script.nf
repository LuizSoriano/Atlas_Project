params.species = 'Slycopersicum'
params.output_dir = "$projectDir/../data/inputs/Slycopersicum_691_ITAG4/species_info"

process GET_SPECIES_INFO {
    publishDir params.output_dir, mode: 'copy'

    input:
    val species

    output:
    path "species_info.json"

    script:
    """
    #!/bin/bash
    set -e

    mkdir -p output

    echo "Consultando informações para a espécie: ${species}"
    curl -s -X GET "https://files.jgi.doe.gov/phytozome_file_list/?species=${species}&api_version=2&a=false&h=false&d=asc&p=1&x=10&t=simple" \\
         -H "accept: application/json" -o output/raw_species.json


    jq ' 
        {
          species: .organisms[0].files[0].metadata.phytozome.Gspecies,
          ids: [ 
            .organisms[] | { 
              agg_id: .agg_id, 
              annotation_version: .top_hit.metadata.phytozome.annotation_version, 
              assembly_version: .files[0].metadata.phytozome.assembly_version 
            } 
          ] 
        }
    ' output/raw_species.json > species_info.json

    echo "✅ Arquivo species_info.json gerado com sucesso."
    """
}

workflow {
    GET_SPECIES_INFO(params.species)
}

workflow.onComplete {
    log.info workflow.success ? "\n✅ Completo! O arquivo species_info.json está em: ${params.output_dir}" : "\n❌ Ocorreu um erro no workflow"
}