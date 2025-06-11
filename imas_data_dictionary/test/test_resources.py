import os
from pathlib import Path

import pytest

from imas_data_dictionary import get_resource_path, get_xml_resource


def test_get_resource_path_context_manager():
    """Test that get_resource_path yields a valid file path."""
    resource_rel_path = "resources/xml/IDSDef.xml"
    with get_resource_path(resource_rel_path) as path:
        assert isinstance(path, Path)
        assert path.exists()
        assert path.is_file()
        assert path.name == "IDSDef.xml"


def test_get_xml_resource_returns_valid_path():
    """Test that get_xml_resource returns a valid path."""
    path = get_xml_resource("IDSDef.xml")
    assert isinstance(path, Path)
    assert path.exists()
    assert path.is_file()
    assert path.name == "IDSDef.xml"
