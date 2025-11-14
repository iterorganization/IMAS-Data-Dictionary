import os
import pathlib
import sys
import importlib.util

from setuptools import setup
from setuptools.command.build_py import build_py
from setuptools.command.develop import develop
from setuptools.command.install import install

sys.path.append(str(pathlib.Path(__file__).parent.resolve()))

current_directory = pathlib.Path(__file__).parent.resolve()


class ResourceGeneratorMixin:
    """
    Mixin class that provides common resource generation functionality for
    setuptools commands.
    """

    def _should_build_docs(self):
        """Determine if documentation should be built based on environment variable."""
        # Set this environment variable to build docs:
        # IMAS_BUILD_DOCS=1 pip install .
        build_docs_flag = os.getenv("IMAS_BUILD_DOCS", "").strip().lower()
        build_docs = build_docs_flag in ("1", "true", "yes")
        if build_docs:
            print("[IMAS-DD] Documentation build enabled via IMAS_BUILD_DOCS")
        return build_docs

    def generate_resources(self, include_docs=False):
        """Generate all necessary resources for the data dictionary package."""
        from generate import (
            generate_dd_data_dictionary,
            generate_dd_data_dictionary_validation,
            generate_idsnames,
        )
        from install import install_dd_files, install_identifiers_files

        # Generate the data dictionary files
        generate_dd_data_dictionary()
        generate_idsnames()
        generate_dd_data_dictionary_validation()

        # Generate documentation if requested
        if include_docs:
            from generate import (
                generate_html_documentation,
                generate_ids_cocos_transformations_symbolic_table,
                generate_idsdef_js,
            )
            from install import (
                install_html_docs,
            )

            generate_html_documentation()
            generate_ids_cocos_transformations_symbolic_table()
            generate_idsdef_js()

            install_html_docs()

        # Create the resources directory in the package
        install_dd_files()
        install_identifiers_files()


class CustomInstallCommand(install, ResourceGeneratorMixin):
    """Custom install command that handles DD files generation and installation."""

    description = "DD files generation"
    paths = []

    def run(self):
        from install import (
            install_identifiers_files,
        )

        # Determine if docs should be built
        include_docs = self._should_build_docs()

        # Generate resources using mixin
        self.generate_resources(include_docs=include_docs)

        # Additional install steps specific to full installation
        install_identifiers_files()

        super().run()


class BuildPyCommand(build_py, ResourceGeneratorMixin):
    """Custom build command that generates resources before building."""

    def run(self):
        include_docs = self._should_build_docs()
        self.generate_resources(include_docs=include_docs)
        super().run()


class DevelopCommand(develop, ResourceGeneratorMixin):
    """
    Custom develop command that generates resources before installing in
    development mode.
    """

    def run(self):
        include_docs = self._should_build_docs()
        self.generate_resources(include_docs=include_docs)
        super().run()


if __name__ == "__main__":
    setup(
        cmdclass={
            "install": CustomInstallCommand,
            "build_py": BuildPyCommand,
            "develop": DevelopCommand,
        },
    )
