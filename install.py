from pathlib import Path
from setuptools_scm import get_version
import os
import pathlib
import shutil

DD_BUILD = pathlib.Path(__file__).parent.resolve()
IMAS_INSTALL_DIR = os.path.join(DD_BUILD, "install")

DD_GIT_DESCRIBE = get_version()
UAL_GIT_DESCRIBE = DD_GIT_DESCRIBE


prefix = IMAS_INSTALL_DIR
exec_prefix = prefix
bindir = os.path.join(exec_prefix, "bin")
sbindir = bindir
libexecdir = os.path.join(exec_prefix, "libexec")
datarootdir = os.path.join(prefix, "share")
datadir = datarootdir
sysconfdir = os.path.join(prefix, "etc")
includedir = os.path.join(prefix, "include")
docdir = os.path.join(datarootdir, "doc")
htmldir = docdir
sphinxdir = os.path.join(docdir, "imas/sphinx")
libdir = os.path.join(exec_prefix, "lib")
srcdir = DD_BUILD


htmldoc = [
    "IDSNames.txt",
    "html_documentation/html_documentation.html",
    "html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv",
]


def install_sphinx_docs():
    print("Installing Sphinx files")
    sourcedir = Path("docs/_build/html")
    destdir = Path(sphinxdir)

    if sourcedir.exists() and sourcedir.is_dir():
        if destdir.exists():
            shutil.rmtree(destdir)  # Remove existing destination directory to avoid errors
        shutil.copytree(sourcedir, destdir)
    else:
        print("Proceeding with installation without the Sphinx documentation since it could not be found")


def install_html_docs():
    imas_dir = Path(htmldir) / "imas"
    imas_dir.mkdir(parents=True, exist_ok=True)

    html_docs_dir = Path("html_documentation")
    if html_docs_dir.exists() and html_docs_dir.is_dir():
        if imas_dir.exists():
            shutil.rmtree(imas_dir)  # Remove existing destination directory to avoid errors
        shutil.copytree(html_docs_dir, imas_dir)
    else:
        print("Proceeding with installation without the html documentation since it could not be found")


def install_dd_files():
    print("installing dd files")
    Path(includedir).mkdir(parents=True, exist_ok=True)
    dd_files = [
        "dd_data_dictionary.xml",
        "IDSNames.txt",
        "dd_data_dictionary_validation.txt",
    ]
    for dd_file in dd_files:
        shutil.copy(dd_file, includedir)


def create_idsdef_symlink():
    try:
        if not os.path.exists(os.path.join(includedir, "IDSDef.xml")):
            os.symlink(
                "dd_data_dictionary.xml",
                os.path.join(includedir, "IDSDef.xml"),
            )

    except Exception as _:  # noqa: F841
        shutil.copy(
            "dd_data_dictionary.xml",
            os.path.join(includedir, "IDSDef.xml"),
        )


def ignored_files(adir, filenames):
    return [filename for filename in filenames if not filename.endswith("_identifier.xml")]


def copy_utilities():
    print("copying utilities")
    if not os.path.exists(os.path.join(includedir, "utilities")):
        shutil.copytree("utilities", os.path.join(includedir, "utilities"), ignore=ignored_files)


# Identifiers definition files
def install_identifiers_files():
    print("installing identifier files")
    exclude = set(["install", "data_dictionary", "dist", "build"])

    ID_IDENT = []
    for root, dirs, files in os.walk(".", topdown=True):
        dirs[:] = [d for d in dirs if d not in exclude]
        for filename in files:
            if filename.endswith("_identifier.xml"):
                ID_IDENT.append(os.path.join(root, filename))

    for file_path in ID_IDENT:
        directory_path = os.path.dirname(file_path)
        directory_name = os.path.basename(directory_path)
        Path(includedir + "/" + directory_name).mkdir(parents=True, exist_ok=True)
        shutil.copy(file_path, os.path.join(includedir, directory_name))


if __name__ == "__main__":
    install_html_docs()
    install_sphinx_docs()
    install_dd_files()
    create_idsdef_symlink()
    copy_utilities()
    install_identifiers_files()
