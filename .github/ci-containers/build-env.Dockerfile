ARG PYTHON_VERSION=3.8-alpine
FROM python:$PYTHON_VERSION

# python's crypto library has rust as a build dependency, unfortunately
RUN apk add --no-cache git gcc musl-dev libffi-dev libressl-dev curl unzip rust cargo
RUN python -m pip install -U pip poetry pytest
COPY poetry.lock pyproject.toml ./
RUN poetry config virtualenvs.create false && poetry install --no-root
