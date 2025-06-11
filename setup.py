from setuptools import setup
from setuptools.command.install import install
from setuptools.command.build_py import build_py
from setuptools.command.develop import develop
from setuptools_scm import get_version
import glob
import os
import pathlib
import sys

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
            generate_html_documentation,
            generate_ids_cocos_transformations_symbolic_table,
            generate_idsdef_js,
            generate_idsnames,
            generate_idsnames,
        )
        from install import install_dd_files

        # Generate the data dictionary files
        generate_dd_data_dictionary()
        generate_html_documentation()
        generate_ids_cocos_transformations_symbolic_table()
        generate_idsnames()
        generate_dd_data_dictionary_validation()
        generate_idsdef_js()

        # Create the resources directory in the package
        install_dd_files()


class CustomInstallCommand(install, ResourceGeneratorMixin):
    """Custom install command that handles DD files generation and installation."""

    description = "DD files generation"
    paths = []

    def run(self):
        from install import (
            copy_utilities,
            create_idsdef_symlink,
            install_html_docs,
            install_identifiers_files,
            install_sphinx_docs,
        )

        # Generate resources using mixin
        self.generate_resources()

        # Additional install steps specific to full installation
        install_html_docs()
        install_sphinx_docs()
        create_idsdef_symlink()
        copy_utilities()
        install_identifiers_files()

        super().run()

    def set_data_files(self):
        """Set data files for installation based on generated content."""
        version = get_version()
        if os.path.exists("install"):
            for path, directories, filenames in os.walk("install"):
                CustomInstallCommand.paths.append(
                    (path.replace("install", "dd_" + version), glob.glob(path + "/*.*"))
                )
        else:
            raise Exception(
                "Couldn't find IDSDef.xml, Can not install data dictionary "
                "python package"
            )


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
