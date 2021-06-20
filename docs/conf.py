# We run this against the installed version
import deqr

project = "deqr"
copyright = "2021"
author = "torque"

version = deqr.__version__
release = deqr.__version__

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx_copybutton",
]

# This prevents sphinx from truncating tuple type annotations like `tuple
# [int, int]` into simply `tuple`. But I don't understand why sphinx is
# truncating these annotations in the first place (google searches have
# revealed nothing of note on this topic).
autodoc_type_aliases = {"tuple": "tuple"}
autodoc_member_order = "bysource"
intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "numpy": ("https://numpy.org/doc/stable/", None),
    "PIL": ("https://pillow.readthedocs.io/en/stable/", None),
}

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "furo"
html_title = "deqr"
html_show_sourcelink = False
html_show_copyright = False
html_show_sphinx = False
html_codeblock_linenos_style = "table"
