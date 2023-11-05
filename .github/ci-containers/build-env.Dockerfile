ARG ARCHITECTURE=2_28_x86_64
FROM quay.io/pypa/manylinux_$ARCHITECTURE:latest

RUN yum groupinstall -y 'Development Tools' && yum install -y rustc curl unzip cargo libffi-devel openssl-devel

ENV PY38=/opt/python/cp38-cp38/bin/python
ENV PY39=/opt/python/cp39-cp39/bin/python
ENV PY310=/opt/python/cp310-cp310/bin/python
ENV PY311=/opt/python/cp311-cp311/bin/python
ENV PY312=/opt/python/cp312-cp312/bin/python

RUN mkdir /venvs
RUN "$PY311" -m venv /venvs/poetry && /venvs/poetry/bin/pip install -U pip poetry
RUN "$PY311" -m venv /venvs/docbuild && /venvs/docbuild/bin/pip install -U pip
ENV POETRY=/venvs/poetry/bin/poetry
ENV DOCENV=/venvs/docbuild

RUN "$PY38" -m pip install -U pip build
RUN "$PY39" -m pip install -U pip build
RUN "$PY310" -m pip install -U pip build
RUN "$PY311" -m pip install -U pip build
RUN "$PY312" -m pip install -U pip build

COPY poetry.lock pyproject.toml ./

RUN . "$DOCENV"/bin/activate && "$POETRY" install --no-root && deactivate
