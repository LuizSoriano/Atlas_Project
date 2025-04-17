from celery_app import celery_app  # Importa a instância do Celery
import subprocess


@celery_app.task(name="tasks.test_task", queue='task_queue')  # Defina um nome único para a task
def test_task(name):
    """Uma tarefa simples que apenas simula um processamento."""
    time.sleep(5)  # Simula um tempo de execução
    return f"Task concluída! Olá, {name} 🚀"

@celery_app.task(bind=True, max_retries=3, name='tasks.execute_pipeline', queue='task_queue')
def run_nextflow_pipeline(dynamic_params): # mudar para CMD
    """
    Executa o pipeline Nextflow com parâmetros dinâmicos.

    dynamic_params (dict): Dicionário contendo os parâmetros do pipeline.
    """
    command = ["nextflow", "run", "/app/workflows/script5.nf"]

    for key, value in dynamic_params.items():
        command.extend([f"--{key}", str(value)])

    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return e.stderr
