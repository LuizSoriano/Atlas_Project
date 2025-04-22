from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "specie": 'Solanum lycopersicum',
    "output_dir": "app/data/results/specie",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script3.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--specie {params['specie']} "
    f"--output_dir {params['output_dir']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
