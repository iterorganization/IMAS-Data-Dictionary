"""
IMAS Data Dictionary Python Package.

This package provides access to the ITER IMAS Data Dictionary, which describes
the structure and format of ITER's Interface Data Structures (IDSs).
"""

from importlib import resources
from pathlib import Path
import sys

from . import idsinfo

__all__ = ["idsinfo", "get_resource_path", "get_schema"]

from ._version import version as __version__  # noqa: F401
from ._version import version_tuple  # noqa: F401


def get_resource_path(resource_name: str) -> Path:
    """Return the path to a resource file in the package.

    Parameters
    ----------
    resource_name : str
        Path to the resource relative to the package root.
        Example: "resources/schemas/data_dictionary.xml"

    Returns
    -------
    Path
        Path object to the resource file.
    """
    if sys.version_info >= (3, 9):
        with resources.as_file(
            resources.files("imas_data_dictionary").joinpath(resource_name)
        ) as path:
            # Return a copy of the path to ensure it remains valid after the context manager exits
            return Path(str(path))
    else:
        # For Python < 3.9
        package_parts = resource_name.split("/")
        resource_file = package_parts.pop()
        package_path = "imas_data_dictionary"
        if package_parts:
            package_path = f"{package_path}.{'.'.join(package_parts)}"
        with resources.path(package_path, resource_file) as path:
            return Path(str(path))


def get_schema(schema_path: str) -> Path:
    """Get path to a schema resource file.

    Parameters
    ----------
    schema_path : str
        Name of the schema file in the resources/schemas directory.
        Can include subdirectories, e.g., "utilities/coordinate_identifier.xml"

    Returns
    -------
    Path
        Path object to the schema file.
    """
    return get_resource_path(f"resources/schemas/{schema_path}")
