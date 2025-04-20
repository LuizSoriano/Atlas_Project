# atlas/deploy/containers/Dockerfile
FROM python:3.9-slim

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Instala as bibliotecas necessárias
RUN pip install --no-cache-dir requests biopython

# Define o PYTHONPATH para que os scripts possam ser encontrados corretamente
ENV PYTHONPATH="/app"