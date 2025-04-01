from setuptools import setup
from setuptools.command.install import install
from setuptools_scm import get_version
import glob
import os
import pathlib
import sys

sys.path.append(str(pathlib.Path(__file__).parent.resolve()))

current_directory = pathlib.Path(__file__).parent.resolve()

class CustomInstallCommand(install):
    description = "DD files generation"
    paths = []

    def run(self):
        from generate import (
            generate_dd_data_dictionary,
            generate_dd_data_dictionary_validation,
            generate_html_documentation,
            generate_ids_cocos_transformations_symbolic_table,
            generate_idsnames,
            generate_idsdef_js,
        )
        from install import (
            copy_utilities,
            create_idsdef_symlink,
            install_html_docs,
            install_sphinx_docs,
            install_dd_files,
            install_identifiers_files,
        )

        # Generate
        generate_dd_data_dictionary()
        generate_html_documentation()
        generate_ids_cocos_transformations_symbolic_table()
        generate_idsnames()
        generate_dd_data_dictionary_validation()
        generate_idsdef_js()

        # install
        install_html_docs()
        install_sphinx_docs()
        install_dd_files()
        create_idsdef_symlink()
        copy_utilities()
        install_identifiers_files()

        self.set_data_files()
        super().run()

    def set_data_files(self):
        version = get_version()
        if os.path.exists("install"):
            for path, directories, filenames in os.walk("install"):
                CustomInstallCommand.paths.append((path.replace("install", "dd_" + version), glob.glob(path + "/*.*")))
        else:
            raise Exception("Couldn't find IDSDef.xml, Can not install data dictionary python package")


if __name__ == "__main__":
    setup(
        data_files=CustomInstallCommand.paths,
        cmdclass={
            "install": CustomInstallCommand,
        },
    )
