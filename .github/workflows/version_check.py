import pathlib
import sys

from poetry.core.pyproject.toml import PyProjectTOML

# usage: version_check.py /path/to/pyproject.toml [git tag]

pyptoml = pathlib.Path(sys.argv[1])
projver = pyptoml.parent / "deqr" / "version.py"

proj = PyProjectTOML(pyptoml)

ver = {}
with open(projver) as f:
    verc = f.read()
exec(verc, None, ver)

vermatch = ver['__version__'] != proj.data['project']['version']

if len(sys.argv) == 3:
    vermatch = vermatch or sys.argv[2] != ver['__version__']

if vermatch:
    print(
        (
            "::error::version mismatch: {\n"
            f"  version.py:     {ver['__version__']}\n"
            f"  pyproject.toml: {proj.data['project']['version']}\n"
            + (f"  git tag: {sys.argv[2]}\n" if len(sys.argv) == 3 else "")
            + "}"
        ),
        file=sys.stderr
    )

sys.exit(vermatch)
