ARG ARCHITECTURE=2_28_x86_64
FROM quay.io/pypa/manylinux_$ARCHITECTURE:latest

RUN yum groupinstall -y 'Development Tools' && yum install -y rustc curl unzip cargo libffi-devel openssl-devel

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
