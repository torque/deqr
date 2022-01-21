from __future__ import annotations

# We run this against the installed version
import deqr

project = "deqr"
copyright = "2022"
author = "torque"
github_url = "https://github.com/torque/deqr"

version = deqr.__version__
release = deqr.__version__

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx_copybutton",
    "sphinx_inline_tabs"
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
html_sidebars = {
    "**": [
        "sidebar/scroll-start.html",
        "sidebar/brand.html",
        "sidebar/search.html",
        "sidebar/navigation.html",
        "sidebar/scroll-end.html",
    ]
}

from docutils import nodes
from docutils.parsers.rst import directives
from docutils.parsers.rst.directives import images
from docutils.parsers.rst import Directive
from sphinx.environment.collectors.asset import ImageCollector


class GImage(images.Image):
    image_prefix = "/deqr-docs/images/"

    def run(self):
        self.options["__gimage_uri__"] = self.arguments[0]
        return super().run()

class GFigure(images.Figure):
    image_prefix = "/deqr-docs/images/"

    def run(self):
        self.options["__gimage_uri__"] = self.arguments[0]
        return super().run()

directives.register_directive("gimage", GImage)
directives.register_directive("gfigure", GFigure)

original_process_doc = ImageCollector.process_doc

# this kind of precludes properly rendering this to PDF or non-html formats, but
# I don't really care about doing that.
def dont_mangle_my_damn_image_uris(self, app, doctree) -> None:
    original_process_doc(self, app, doctree)

    for node in doctree.traverse(nodes.image):
        if (base_uri := node.attributes.get("__gimage_uri__")) is not None:
            node["uri"] = GImage.image_prefix + base_uri


ImageCollector.process_doc = dont_mangle_my_damn_image_uris

import furo

def put_titles_in_the_nav_tree(context: Dict[str, Any]) -> str:
    # The navigation tree, generated from the sphinx-provided ToC tree.
    if "toctree" in context:
        toctree = context["toctree"]
        toctree_html = toctree(
            collapse=False,
            titles_only=False,
            maxdepth=-1,
            includehidden=True,
        )
    else:
        toctree_html = ""

    return furo.get_navigation_tree(toctree_html)

def dont_show_toc(context: Dict[str, Any]) -> bool:
    return True

furo._compute_navigation_tree = put_titles_in_the_nav_tree
furo._compute_hide_toc = dont_show_toc
