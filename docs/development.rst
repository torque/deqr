Development Tips and Tricks
===========================

``deqr`` uses poetry_ for dependency management and as its build system. For
development, it can be installed with the command ``poetry install``, which will haul
in the development dependencies because ``deqr`` has no standard dependencies. These
dependencies are listed in ``pyproject.toml``.

Alternately, ``pip install .`` also ought to work because Poetry exposes a PEP 517 build
backend, but this will not also automatically the development dependencies. If not all
development dependencies are desired, this is the easiest way to go about skipping
them.

Since ``deqr`` is a Cython_ wrapper around some C libraries, poetry delegates
compilation to Cython via a setuptools build extension, which is stored in ``build.py``
in the root of the repository.  When adding or removing Cython-compiled modules, that
file must be updated.

.. _poetry: https://github.com/python-poetry/poetry
.. _Cython: https://github.com/cython/cython
