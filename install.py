import logging
import os
import pathlib
import shutil
from pathlib import Path

from setuptools_scm import get_version

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


def install_html_docs():
    """
    Install HTML documentation to the package resources directory.

    Copies generated HTML documentation
    """
    logger.info("[IMAS-DD] Starting HTML documentation installation")
    try:
        # Build destination path
        resources_dir = Path(srcdir) / "imas_data_dictionary" / "resources"
        resources_dir.mkdir(parents=True, exist_ok=True)

        docs_dir = resources_dir / "docs"
        docs_dir.mkdir(parents=True, exist_ok=True)

        legacy_dir = docs_dir / "legacy"
        legacy_dir.mkdir(parents=True, exist_ok=True)

        html_docs_dir = Path("html_documentation")

        logger.info(f"[IMAS-DD] Source: {html_docs_dir}")
        logger.info(f"[IMAS-DD] Destination: {legacy_dir}")

        # Validate source exists and is a directory
        if not html_docs_dir.exists():
            logger.warning(
                f"[IMAS-DD] HTML documentation source not found at {html_docs_dir}"
            )
            logger.info(
                "[IMAS-DD] Proceeding with installation without HTML documentation"
            )
            return

        if not html_docs_dir.is_dir():
            logger.error(f"[IMAS-DD] Source path is not a directory: {html_docs_dir}")
            raise NotADirectoryError(f"Expected directory, got file: {html_docs_dir}")

        # Remove existing destination if present
        if legacy_dir.exists():
            logger.info(f"[IMAS-DD] Removing existing destination: {legacy_dir}")
            shutil.rmtree(legacy_dir)

        # Ensure parent directory exists
        legacy_dir.parent.mkdir(parents=True, exist_ok=True)

        # Copy documentation
        logger.info(f"[IMAS-DD] Copying HTML docs from {html_docs_dir} to {legacy_dir}")
        shutil.copytree(html_docs_dir, legacy_dir)

        # Check if there's a nested html_documentation directory and flatten it
        nested_dir = legacy_dir / "html_documentation"
        if nested_dir.exists() and nested_dir.is_dir():
            logger.info(
                "[IMAS-DD] Found nested html_documentation directory, flattening structure"
            )
            # Move files from nested directory to parent
            for item in nested_dir.iterdir():
                dest_path = legacy_dir / item.name
                # If item already exists at destination, remove it first
                if dest_path.exists():
                    if dest_path.is_dir():
                        shutil.rmtree(dest_path)
                    else:
                        dest_path.unlink()
                # Move the item
                shutil.move(str(item), str(dest_path))
                logger.debug(
                    f"[IMAS-DD] Moved {item.name} from nested to legacy directory"
                )
            # Remove the now-empty nested directory
            shutil.rmtree(nested_dir)
            logger.info("[IMAS-DD] Removed nested html_documentation directory")

        logger.info("[IMAS-DD] HTML documentation installation completed successfully")

    except Exception as e:
        logger.error(
            f"[IMAS-DD] Error during HTML documentation installation: {e}",
            exc_info=True,
        )
        raise


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
    install_dd_files()
    install_identifiers_files()
