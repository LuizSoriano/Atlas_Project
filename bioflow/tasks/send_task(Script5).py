from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "genome_fasta": "app/data/inputs/Slycopersicum_691_ITAG4/genoma/output/Slycopersicum_691_SL4.0.fa",
    "gff_file": "app/data/inputs/Slycopersicum_691_ITAG4/genoma/output/Slycopersicum_691_ITAG4.0.gene.gff3",
    "transcriptome_file": "app/data/inputs/Slycopersicum_691_ITAG4/genoma/output/Slycopersicum_691_ITAG4.0.transcript_primaryTranscriptOnly.fa",
    "out_decoy": "app/data/inputs/Slycopersicum_691_ITAG4",
    "out_index": "app/data/inputs/Slycopersicum_691_ITAG4",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script5.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--genome_fasta {params['genome_fasta']} "
    f"--gff_file {params['gff_file']} "
    f"--transcriptome_file {params['transcriptome_file']} "
    f"--out_decoy {params['out_decoy']} "
    f"--out_index {params['out_index']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
