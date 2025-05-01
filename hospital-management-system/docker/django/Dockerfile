FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y     build-essential     libpq-dev     && rm -rf /var/lib/apt/lists/*

COPY backend/requirements /tmp/requirements
RUN pip install --upgrade pip &&     pip install -r /tmp/requirements/prod.txt

COPY backend /app

EXPOSE 8000
