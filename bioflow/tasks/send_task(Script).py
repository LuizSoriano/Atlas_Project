from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "species": 'Slycopersicum',
    "output_dir": "app/data/inputs/Slycopersicum_691_ITAG4/species_info",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--species {params['species']} "
    f"--output_dir {params['output_dir']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
