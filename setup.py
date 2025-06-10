import pathlib
import sys

from setuptools import setup
from setuptools.command.install import install

sys.path.append(str(pathlib.Path(__file__).parent.resolve()))

current_directory = pathlib.Path(__file__).parent.resolve()


class CustomInstallCommand(install):
    description = "DD files generation"

    def run(self):
        from generate import (
            generate_dd_data_dictionary,
            generate_dd_data_dictionary_validation,
            generate_html_documentation,
            generate_ids_cocos_transformations_symbolic_table,
            generate_idsdef_js,
            generate_idsnames,
        )
        from install import (
            copy_utilities,
            create_idsdef_symlink,
            install_dd_files,
            install_html_docs,
            install_identifiers_files,
            install_sphinx_docs,
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

        super().run()


if __name__ == "__main__":
    setup(
        cmdclass={
            "install": CustomInstallCommand,
        },
    )
