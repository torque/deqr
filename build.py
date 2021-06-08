from __future__ import annotations
from typing import Any

import Cython.Build
from setuptools.extension import Extension

def build(setup_kwargs: dict[str, Any]) -> None:
    cython_modules = Cython.Build.cythonize(
        [
            Extension(
                "deqr.quirc",
                sources=["deqr/quirc.pyx"]
            ),
            Extension(
                "deqr.qrdec",
                sources=["deqr/qrdec.pyx"]
            ),
            Extension(
                "deqr.binarize",
                sources=["deqr/binarize.pyx"]
            )
        ],
        language_level=3,
    )

    setup_kwargs.update(
        {
            "ext_modules": cython_modules,
            "zip_safe": False,
        }
    )
