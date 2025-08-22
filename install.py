from pathlib import Path
from setuptools_scm import get_version
import os
import pathlib
import shutil
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(), logging.FileHandler("install.log")],
)
logger = logging.getLogger(__name__)

DD_BUILD = pathlib.Path(__file__).parent.resolve()
IMAS_INSTALL_DIR = os.path.join(DD_BUILD, "imas_data_dictionary/resources")

# Delete directory contents if it exists
if os.path.exists(IMAS_INSTALL_DIR) and os.path.isdir(IMAS_INSTALL_DIR):
    shutil.rmtree(IMAS_INSTALL_DIR)

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
            shutil.rmtree(
                destdir
            )  # Remove existing destination directory to avoid errors
        shutil.copytree(sourcedir, destdir)
    else:
        print(
            "Proceeding with installation without the Sphinx documentation since it could not be found"
        )


def install_html_docs():
    imas_dir = Path(htmldir) / "imas"
    imas_dir.mkdir(parents=True, exist_ok=True)

    html_docs_dir = Path("html_documentation")
    if html_docs_dir.exists() and html_docs_dir.is_dir():
        if imas_dir.exists():
            shutil.rmtree(
                imas_dir
            )  # Remove existing destination directory to avoid errors
        shutil.copytree(html_docs_dir, imas_dir)
    else:
        print(
            "Proceeding with installation without the html documentation since it could not be found"
        )


def install_dd_files():
    print("installing dd files")
    dd_files = [
        "dd_data_dictionary.xml",
    ]

    # Create schemas subfolder in resources directory for Python package access
    resources_dir = Path(srcdir) / "imas_data_dictionary" / "resources"
    resources_dir.mkdir(parents=True, exist_ok=True)

    schemas_dir = resources_dir / "schemas"
    schemas_dir.mkdir(parents=True, exist_ok=True)

    print(
        "Copying data dictionary files to resources/schemas directory for importlib.resources access"
    )
    # Exclude the IDSDef.xml file. This file is a copy of data_dictionary.xml
    # shutil.copy("IDSDef.xml", schemas_dir / "IDSDef.xml")

    # Copy schema files to the schemas subfolder
    for dd_file in dd_files:
        shutil.copy(dd_file, schemas_dir / dd_file)

    # rename schemas/dd_data_dictionary.xml to schemas/data_dictionary.xml
    data_dictionary_path = schemas_dir / "dd_data_dictionary.xml"
    if data_dictionary_path.exists():
        new_data_dictionary_path = schemas_dir / "data_dictionary.xml"
        # Remove target file if it exists to avoid rename error
        if new_data_dictionary_path.exists():
            new_data_dictionary_path.unlink()
        data_dictionary_path.rename(new_data_dictionary_path)
        logger.info(f"Renamed {data_dictionary_path} to {new_data_dictionary_path}")


def ignored_files(adir, filenames):
    return [
        filename for filename in filenames if not filename.endswith("_identifier.xml")
    ]


# Identifiers definition files
def install_identifiers_files():
    logger.info("Installing identifier files")
    exclude = set(["imas_data_dictionary", "dist", "build"])

    ID_IDENT = []

    for root, dirs, files in os.walk("schemas", topdown=True):
        dirs[:] = [d for d in dirs if d not in exclude]
        for filename in files:
            if filename.endswith("_identifier.xml"):
                ID_IDENT.append(os.path.join(root, filename))

    logger.debug(f"Found {len(ID_IDENT)} identifier files: {ID_IDENT}")

    # Also copy identifier files to schemas_dir for importlib.resources access
    logger.info(
        "Copying identifier files to resources/schemas directory for importlib.resources access"
    )
    resources_dir = Path(srcdir) / "imas_data_dictionary" / "resources"
    schemas_dir = resources_dir / "schemas"

    for file_path in ID_IDENT:
        directory_path = os.path.dirname(file_path)
        directory_name = os.path.basename(directory_path)

        # Create subdirectory in schemas_dir to maintain folder structure
        schemas_subdir = schemas_dir / directory_name
        schemas_subdir.mkdir(parents=True, exist_ok=True)

        # Copy the identifier file to the schemas subdirectory
        filename = os.path.basename(file_path)
        target_path = schemas_subdir / filename
        shutil.copy(file_path, target_path)
        logger.debug(f"Copied {file_path} to {target_path}")


if __name__ == "__main__":
    install_html_docs()
    install_sphinx_docs()
    install_dd_files()
    install_identifiers_files()
