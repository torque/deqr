import re
import sys

# usage: version_check.py <__init__.py> <poetry version -s>

source_ver = re.match(r'__version__\s*=\s*(.+)', open(sys.argv[1], 'r').read())[1][1:-1]
poetry_ver = sys.argv[2]

sys.exit(source_ver != poetry_ver)
