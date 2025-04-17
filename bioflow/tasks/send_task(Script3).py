from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "lib": "SRR12172675",
    "out_sra": "app/data/reads",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script3.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--lib {params['lib']} "
    f"--out_sra {params['out_sra']} "
)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
