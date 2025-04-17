from bioflow.task_queue import run_nextflow_pipeline

# Parâmetros dinâmicos
params = {
    "reads": "/app/data/reads/SRR12172675_{1,2}.fastq",
    "outdir": "/app/data/results/Slycopersicum_691_ITAG4",
    "adapter_path": "/app/data/inputs/db/adapters/all_adapters.fa",
    "leading_quality": 3,
    "trailing_quality": 3,
    "sliding_window": "4:15",
    "min_length": 40,
    "illumina_clip": "ILLUMINACLIP:/app/data/inputs/db/adapters/all_adapters.fa:2:30:10:2:True",
    "salmon_index": "/app/data/inputs/Slycopersicum_691_ITAG4/salmon_index",
    "logfile": "/app/logs/nextflow.log",
    "config": "/app/config/nextflow.config",
    "pipeline_path": "/app/workflows/script5.nf"
}

# construir o CMD

cmd = (
    f"nextflow run {params['pipeline_path']} "
    f"-log {params['logfile']} "
    f"-c {params['config']} "
    f"--reads {params['reads']} "
    f"--outdir {params['outdir']} "
    f"--adapter_path {params['adapter_path']} "
    f"--leading_quality {params['leading_quality']} "
    f"--trailing_quality {params['trailing_quality']} "
    f"--sliding_window {params['sliding_window']} "
    f"--min_length {params['min_length']} "
    f"--illumina_clip {params['illumina_clip']} "
    f"--salmon_index {params['salmon_index']}"
)

print("Comando a ser executado:")
print(cmd)

task = run_nextflow_pipeline.delay(params)

print(f"Tarefa enviada! Task ID: {task.id}")
