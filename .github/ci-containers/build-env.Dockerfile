ARG ARCHITECTURE=x86_64
FROM quay.io/pypa/manylinux_2_24_$ARCHITECTURE:latest

RUN apt-get update && apt-get install -y build-essential git libffi-dev libssl-dev curl unzip rustc cargo

ENV PY38=/opt/python/cp38-cp38/bin/python
ENV PY39=/opt/python/cp39-cp39/bin/python
ENV PY310=/opt/python/cp310-cp310/bin/python
ENV PY311=/opt/python/cp311-cp311/bin/python

ENV VE38=/venvs/py-38
ENV VE39=/venvs/py-39
ENV VE310=/venvs/py-310
ENV VE311=/venvs/py-311

RUN mkdir /venvs
RUN "$PY311" -m venv /venvs/poetry \
 && /venvs/poetry/bin/pip install -U pip poetry
ENV POETRY=/venvs/poetry/bin/poetry

RUN "$PY38" -m pip install -U pip build
RUN "$PY39" -m pip install -U pip build
RUN "$PY310" -m pip install -U pip build
RUN "$PY311" -m pip install -U pip build
RUN "$PY38" -m venv "$VE38"
RUN "$PY39" -m venv "$VE39"
RUN "$PY310" -m venv "$VE310"
RUN "$PY311" -m venv "$VE311"

COPY poetry.lock pyproject.toml ./

RUN . "${VE38}"/bin/activate && "$POETRY" install --no-root && deactivate
RUN . "${VE39}"/bin/activate && "$POETRY" install --no-root && deactivate
RUN . "${VE310}"/bin/activate && "$POETRY" install --no-root && deactivate
RUN . "${VE311}"/bin/activate && "$POETRY" install --no-root && deactivate
