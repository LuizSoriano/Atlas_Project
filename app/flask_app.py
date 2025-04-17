from flask import Flask, request, jsonify
from celery import Celery
import os

app = Flask(__name__)

# Configura o Celery (precisa bater com a configuração do worker)
celery_app = Celery(
    'bioflow',
    broker=os.getenv('CELERY_BROKER_URL', 'redis://redis:6379/0'),
    backend=os.getenv('CELERY_BACKEND_URL', 'redis://redis:6379/0')
)

@app.route('/send-task', methods=['POST'])
def send_task():
    """Endpoint que envia uma task para o Celery."""
    name = "Lorrana"

    # Envia a task para o Celery
    task = celery_app.send_task('tasks.tasks_queue.test_task', args=[name], queue='task_queue')

    return jsonify({
        "message": "Task enviada!",
        "task_id": task.id
    }), 202

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
