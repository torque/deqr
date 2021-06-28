ARG ARCHITECTURE=x86_64
FROM quay.io/pypa/manylinux_2_24_$ARCHITECTURE:latest

RUN apt-get update && apt-get install -y build-essential git libffi-dev libssl-dev curl unzip rustc cargo
ENV PY38=/opt/python/cp38-cp38/bin/python
ENV PY39=/opt/python/cp39-cp39/bin/python
RUN $PY38 -m pip install -U pip poetry pytest \
 && $PY38 -m poetry config virtualenvs.create false
RUN $PY39 -m pip install -U pip poetry pytest \
 && $PY39 -m poetry config virtualenvs.create false
COPY poetry.lock pyproject.toml ./
RUN $PY38 -m poetry install --no-root
RUN $PY39 -m poetry install --no-root

# install this after the main project dependencies, so it doesn't barf when we
# install from the pyproject.toml outside of the git repo.
RUN $PY38 -m pip install -U pip poetry-dynamic-versioning
RUN $PY39 -m pip install -U pip poetry-dynamic-versioning
