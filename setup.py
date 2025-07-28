import glob
import os
import pathlib
import sys

from setuptools import setup
from setuptools.command.build_py import build_py
from setuptools.command.develop import develop
from setuptools.command.install import install
from setuptools_scm import get_version

sys.path.append(str(pathlib.Path(__file__).parent.resolve()))

current_directory = pathlib.Path(__file__).parent.resolve()


class ResourceGeneratorMixin:
    """
    Mixin class that provides common resource generation functionality for
    setuptools commands.
    """

    def generate_resources(self):
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

        # Generate resources using mixin
        self.generate_resources()

        # Additional install steps specific to full installation
        install_identifiers_files()

        super().run()


class BuildPyCommand(build_py, ResourceGeneratorMixin):
    """Custom build command that generates resources before building."""

    def run(self):
        self.generate_resources()
        super().run()


class DevelopCommand(develop, ResourceGeneratorMixin):
    """
    Custom develop command that generates resources before installing in
    development mode.
    """

    def run(self):
        self.generate_resources()
        super().run()


if __name__ == "__main__":
    setup(
        cmdclass={
            "install": CustomInstallCommand,
            "build_py": BuildPyCommand,
            "develop": DevelopCommand,
        },
    )
