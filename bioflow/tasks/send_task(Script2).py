from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "token": "/api/sessions/eee331c332b6316d3cf0ddd1d97e1eb0",
    "meta_output": "app/data/inputs/Slycopersicum_691_ITAG4/species_info/meta_output.json",
    "output_dir": "app/data/inputs/Slycopersicum_691_ITAG4/genoma",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script2.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--token {params['token']} "
    f"--meta_output {params['meta_output']} "
    f"--output_dir {params['output_dir']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
