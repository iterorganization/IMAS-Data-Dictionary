from pathlib import Path
import os
import shutil
import subprocess


def generate_sphinx_documentation():
    from sphinx.cmd.build import main as sphinx_main
    from setuptools_scm import get_version
    
    git_describe_output = get_version()
    os.chdir("docs")

    source_dir = os.path.join(".")
    build_dir = os.path.join(".", "_build/html")

    directory = Path(build_dir)
    if directory.exists():
        shutil.rmtree(build_dir)
    sphinx_args = [
        "-b",
        "html",
        source_dir,
        build_dir,
        "-D",
        "dd_changelog_generate=1",
        "-D",
        "dd_autodoc_generate=1",
        "-W",
        "--keep-going",
    ]

    sphinx_main(sphinx_args)
    try:
        from git import Repo

        output_file_path = os.path.join("docs", "_build", "html", "version.txt")

        repo = Repo("..")

        git_describe_output = repo.git.describe().strip()
    except Exception as _:  # noqa: F841
        pass

    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
    with open(output_file_path, "w") as version_file:
        version_file.write(git_describe_output)
    os.chdir("..")


if __name__ == "__main__":
    from generate import (
        generate_dd_data_dictionary,
        generate_dd_data_dictionary_validation,
        generate_html_documentation,
        generate_ids_cocos_transformations_symbolic_table,
        generate_idsnames,
        generate_idsdef_js,
    )

    generate_dd_data_dictionary()
    generate_html_documentation()
    generate_ids_cocos_transformations_symbolic_table()
    generate_idsnames()
    generate_dd_data_dictionary_validation()
    generate_idsdef_js()
    generate_sphinx_documentation()
