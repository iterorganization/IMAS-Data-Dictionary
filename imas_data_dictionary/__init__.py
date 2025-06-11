"""
IMAS Data Dictionary Python Package.

This package provides access to the ITER IMAS Data Dictionary, which describes
the structure and format of ITER's Interface Data Structures (IDSs).
"""

import sys
from contextlib import contextmanager
from importlib import resources
from pathlib import Path

from . import idsinfo

__all__ = ["idsinfo", "get_resource_path", "get_xml_resource"]

from ._version import version as __version__  # noqa: F401
from ._version import version_tuple  # noqa: F401


@contextmanager
def get_resource_path(resource_name: str):
    """Return the path to a resource file in the package.

    Parameters
    ----------
    resource_name : str
        Path to the resource relative to the package root.
        Example: "resources/xml/IDSDef.xml"

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
            yield Path(path)
    else:
        # For Python < 3.9
        package_parts = resource_name.split("/")
        resource_file = package_parts.pop()
        package_path = "imas_data_dictionary"
        if package_parts:
            package_path = f"{package_path}.{'.'.join(package_parts)}"
        with resources.path(package_path, resource_file) as path:
            yield Path(path)


def get_xml_resource(xml_filename: str) -> Path:
    """Get path to an XML resource file.

    Parameters
    ----------
    xml_filename : str
        Name of the XML file in the resources/xml directory.

    Returns
    -------
    Path
        Path object to the XML file.
    """
    with get_resource_path(f"resources/xml/{xml_filename}") as path:
        return path
