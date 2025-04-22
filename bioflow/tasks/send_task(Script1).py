from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "genome_id:" "691",
    "species_info_json": "app/data/inputs/Slycopersicum_691_ITAG4/species_info/species_info.json",
    "species_info_output_dir": "app/data/inputs/Slycopersicum_691_ITAG4/species_info",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script1.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--genome_id {params['genome_id']} "
    f"--species_info_json {params['species_info_json']} "
    f"--species_info_output_dir {params['species_info_output_dir']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
