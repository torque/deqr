ARG ARCHITECTURE=2_28_x86_64
FROM quay.io/pypa/manylinux_$ARCHITECTURE:latest

RUN yum groupinstall -y 'Development Tools' && yum install -y rustc curl unzip cargo libffi-devel openssl-devel

ENV PY310=/opt/python/cp310-cp310/bin/python
ENV PY311=/opt/python/cp311-cp311/bin/python
ENV PY312=/opt/python/cp312-cp312/bin/python
ENV PY313=/opt/python/cp313-cp313/bin/python
ENV PY313T=/opt/python/cp313-cp313t/bin/python

RUN mkdir /venvs
RUN "$PY313" -m venv /venvs/poetry && /venvs/poetry/bin/pip install -U pip poetry_core==2.1.3 poetry==2.1.3
RUN "$PY311" -m venv /venvs/docbuild && /venvs/docbuild/bin/pip install -U pip
ENV POETRY=/venvs/poetry/bin/poetry
ENV POETRY_PY=/venvs/poetry/bin/python
ENV DOCENV=/venvs/docbuild

RUN "$PY310" -m pip install -U pip build
RUN "$PY311" -m pip install -U pip build
RUN "$PY312" -m pip install -U pip build
RUN "$PY313" -m pip install -U pip build
RUN "$PY313T" -m pip install -U pip build

COPY poetry.lock pyproject.toml ./

RUN . "$DOCENV"/bin/activate && "$POETRY" install --no-root -E dev -E documentation && deactivate
