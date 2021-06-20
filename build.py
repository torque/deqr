from __future__ import annotations
from typing import Any

import Cython.Build
from setuptools.extension import Extension


def build(setup_kwargs: dict[str, Any]) -> None:
    cython_modules = Cython.Build.cythonize(
        [
            Extension(
                "deqr.quirc",
                sources=[
                    "deqr/quirc.pyx",
                    "deps/quirc/lib/decode.c",
                    "deps/quirc/lib/identify.c",
                    "deps/quirc/lib/quirc.c",
                    "deps/quirc/lib/version_db.c",
                ],
                include_dirs=["deps/quirc/lib"],
                extra_compile_args=["-fdiagnostics-color=always"],
            ),
            Extension(
                "deqr.qrdec",
                sources=[
                    "deqr/qrdec.pyx",
                    "deps/qrdec/src/bch15_5.c",
                    "deps/qrdec/src/isaac.c",
                    "deps/qrdec/src/qrdec.c",
                    "deps/qrdec/src/rs.c",
                    "deps/qrdec/src/util.c",
                ],
                include_dirs=["deps/qrdec/src"],
                extra_compile_args=["-fdiagnostics-color=always"],
            ),
            Extension(
                "deqr.binarize",
                sources=["deqr/binarize.pyx", "deps/qrdec/src/binarize.c"],
                include_dirs=["deps/qrdec/src"],
                extra_compile_args=["-fdiagnostics-color=always"],
            ),
        ],
        language_level=3,
        compiler_directives={"embedsignature": True},
    )

    setup_kwargs.update(
        {
            "ext_modules": cython_modules,
            "zip_safe": False,
        }
    )
