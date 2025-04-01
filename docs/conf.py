# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import datetime
import os
import subprocess
import sys
from git import Repo
# Ensure that our extension module can be imported:
sys.path.append(os.path.curdir)
import sphinx_dd_extension.autodoc


# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "IMAS Data Dictionary"
copyright = f"{datetime.datetime.now().year}, ITER Organization"
author = "ITER Organization"
try:
    version = subprocess.check_output(["git", "describe"]).decode().strip()
    last_tag = subprocess.check_output(["git", "describe", "--abbrev=0"]).decode().strip()
    is_develop = version != last_tag
except Exception as _:
    os.chdir("..")
    from setuptools_scm import get_version
    version=get_version()
    is_develop="dev" in version
    os.chdir("docs")

html_context = {
    "is_develop": is_develop
}

language = "en"

# Options for generating documentation.
#
# Note: these can be enabled/disabled to generate the IDS reference and changelog!
#   For example: SPHINXOPTS="-D dd_changelog_generate=1 -D dd_autodoc_generate=1"
dd_changelog_generate = True
dd_autodoc_generate = True


# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "sphinx.ext.todo",
    # "sphinx.ext.autosectionlabel",
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
    "sphinx_immaterial",
    "sphinx_dd_extension.dd_domain",
    "sphinx_dd_extension.autodoc",
    "sphinx_dd_extension.dd_changelog",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

cocos = sphinx_dd_extension.autodoc.get_cocos_version()
rst_epilog = f"""
.. |cocos| replace:: {cocos}
"""


# -- Intersphinx configuration -----------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/extensions/intersphinx.html#configuration

intersphinx_mapping = {}


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_immaterial"
html_theme_options = {
    "repo_url": "https://github.com/iterorganization/IMAS-Data-Dictionary",
    "repo_name": "Data Dictionary",
    "icon": {
        "repo": "fontawesome/brands/github",
    },
    "features": [
        # "navigation.expand",
        # "navigation.tabs",
        "navigation.sections",
        "navigation.instant",
        # "header.autohide",
        "navigation.top",
        # "navigation.tracking",
        # "search.highlight",
        # "search.share",
        # "toc.integrate",
        # "toc.follow",
        "toc.sticky",
        # "content.tabs.link",
        "announce.dismiss",
    ],
    # "toc_title_is_page_title": True,
    # "globaltoc_collapse": True,
    "palette": [
        {
            "media": "(prefers-color-scheme: light)",
            "scheme": "default",
            "primary": "blue",
            "accent": "light-green",
            "toggle": {
                "icon": "material/lightbulb-outline",
                "name": "Switch to dark mode",
            },
        },
        {
            "media": "(prefers-color-scheme: dark)",
            "scheme": "slate",
            "primary": "light-blue",
            "accent": "lime",
            "toggle": {
                "icon": "material/lightbulb",
                "name": "Switch to light mode",
            },
        },
    ],
    "version_dropdown": True,
    "version_json": "../versions.js",
}

html_static_path = ["_static"]


def setup(app):
    app.add_css_file("dd.css")
    app.add_js_file("dd.js")
