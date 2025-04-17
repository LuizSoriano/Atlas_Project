from celery import Celery
import os

# Define a aplicação Celery
celery_app = Celery(
    "bioflow",
    broker=os.environ.get('CELERY_BROKER_URL'),  # URL do Redis como broker
    backend=os.environ.get('CELERY_BACKEND_URL'),  # Backend para armazenar resultados (opcional)
    include=["tasks.task_queue"],  # Arquivo onde as tarefas estão definidas
    task_routes={
        'tasks.tasks_queue.test_task': {'queue': 'task_queue'},
        'tasks.tasks_queue.execute_pipeline': {'queue': 'task_queue'}
    },
)

# Configurações opcionais do Celery
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

if __name__ == "__main__":
    celery_app.start()
