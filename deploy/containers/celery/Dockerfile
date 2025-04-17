FROM openjdk:11-slim

ARG DOCKER_GID=998
ARG UID=1000


RUN (getent group docker && groupmod -g ${DOCKER_GID} docker) || groupadd -g ${DOCKER_GID} docker; \
    useradd -u ${UID} -m app; \
    usermod -aG docker app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    docker.io \
    procps \
    curl \
    python3 \
    python3-pip \
    git && \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://get.nextflow.io | bash && \
    chmod +x nextflow && \
    mv nextflow /usr/local/bin/ && \
    chown app:docker /usr/local/bin/nextflow

RUN mkdir -p /app && \
    chown -R app:app /app && \
    chmod -R 755 /app

RUN mkdir -p /home/lorrana/atlas/bioflow && \
    chown -R app:app /home/lorrana/atlas/bioflow && \
    chmod -R 755 /home/lorrana/atlas/bioflow

RUN mkdir -p /home/lorrana/atlas/biodata && \
    chown -R app:app /home/lorrana/atlas/biodata && \
    chmod -R 755 /home/lorrana/atlas/biodata
    
RUN mkdir -p /home/lorrana/atlas/jobs && \
    chown -R app:app /home/lorrana/atlas/jobs && \
    chmod -R 755 /home/lorrana/atlas/jobs

RUN mkdir -p /home/lorrana/atlas/reads && \
    chown -R app:app /home/lorrana/atlas/reads && \
    chmod -R 755 /home/lorrana/atlas/reads

RUN mkdir -p /home/lorrana/atlas/nextflow/ && \
    chown -R app:app /home/lorrana/atlas/nextflow/ && \
    chmod -R 755 /home/lorrana/atlas/nextflow/

RUN mkdir -p /home/lorrana/atlas/nextflow/cache && \
    chown -R app:app /home/lorrana/atlas/nextflow/cache  && \
    chmod -R 755 /home/lorrana/atlas/nextflow/cache 

RUN mkdir -p /home/lorrana/atlas/nextflow/tmp && \
    chown -R app:app /home/lorrana/atlas/nextflow/tmp  && \
    chmod -R 755 /home/lorrana/atlas/nextflow/tmp 

RUN mkdir -p /home/lorrana/atlas/nextflow/work && \
    chown -R app:app /home/lorrana/atlas/nextflow/work  && \
    chmod -R 755 /home/lorrana/atlas/nextflow/work 


COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

RUN rm requirements.txt

USER app

WORKDIR /app

CMD ["celery", "-A", "celery_app", "worker", "--loglevel=info", "-Q", "task_queue", "-n", "worker.bioflow"]
