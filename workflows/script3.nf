#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.specie            = 'Solanum lycopersicum'
params.output_dir        = "$projectDir/../data/results/$params.specie"

// Channels for Python modules
busca_py       = Channel.fromPath('scripts/busca_ids.py')
sra_py         = Channel.fromPath('scripts/sra.py')
bioproject_py  = Channel.fromPath('scripts/bioproject.py')
biosample_py   = Channel.fromPath('scripts/biosample_info.py')



// All processes use the same Docker image with Python and dependencies pre-installed
process BUSCA_IDS {
    publishDir params.output_dir, mode: 'copy'

    input:
        val(specie)
        path script

    output:
        path 'ids.json'

    script:
    """
    python3 $script ${specie}
    """
}

process SRA_INFO {
    publishDir params.output_dir, mode: 'copy'

    input:
        path ids_json
        path script

    output:
        path 'sra_info.json'

    script:
    """
    python3 $script $ids_json sra_info.json
    """
}

process BIOPROJECT {
    publishDir params.output_dir, mode: 'copy'

    input:
        path sra_json
        path script

    output:
        path 'bioproject.json'

    script:
    """
    python3 $script $sra_json bioproject.json
    """
}

process BIOSAMPLE {
    publishDir params.output_dir, mode: 'copy'

    input:
        path sra_json
        path script

    output:
        path 'biosample.json'

    script:
    """
    python3 $script $sra_json biosample.json
    """
}



workflow {
    // Species input channel
    specie_ch = Channel.of(params.specie)

    // 1. Busca IDs iniciais
    ids_ch = BUSCA_IDS(specie_ch, busca_py)

    // 2. Recupera dados SRA
    sra_ch = SRA_INFO(ids_ch, sra_py)

    // 3. Coleta dados de BioProject
    bioproject_ch = BIOPROJECT(sra_ch, bioproject_py)

    // 4. Coleta dados de BioSample
    biosample_ch = BIOSAMPLE(sra_ch, biosample_py)

}