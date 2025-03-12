# Baseando-se na imagem oficial do Ubuntu
FROM ubuntu:20.04

# Atualize e instale curl e jq
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    wget

# Defina o diretório de trabalho (opcional)
WORKDIR /data
