"""
IMAS Data Dictionary Python Package.

This package provides access to the ITER IMAS Data Dictionary, which describes
the structure and format of ITER's Interface Data Structures (IDSs).
"""

from . import idsinfo

__all__ = ["idsinfo"]

from ._version import version as __version__  # noqa: F401
from ._version import version_tuple  # noqa: F401
