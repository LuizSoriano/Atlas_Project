from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "results_dir": "app/data/results/Slycopersicum_691_ITAG4",
    "sample_ids_file": "app/data/results/Slycopersicum_691_ITAG4/sample_ids.txt",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script6.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--results_dir {params['results_dir']} "
    f"--sample_ids_file {params['sample_ids_file']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
