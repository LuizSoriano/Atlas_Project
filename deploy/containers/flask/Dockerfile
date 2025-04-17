FROM python:3.9-alpine

ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache gcc musl-dev linux-headers libpq-dev postgresql-dev graphviz xdg-utils

ARG UID=1000

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    app


COPY requirements.txt .

RUN pip install -r requirements.txt

RUN rm requirements.txt

RUN mkdir -p /app && \
    chown -R app:app /app && \
    chmod -R 755 /app

USER app

WORKDIR /app

# Expõe a porta 5000
EXPOSE 5000

# Comando para rodar o Flask
CMD ["python", "flask_app.py"]
