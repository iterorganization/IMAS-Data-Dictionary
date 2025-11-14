from pathlib import Path

import pytest

from imas_data_dictionary import get_resource_path, get_schema


def test_get_resource_path_returns_valid_path():
    """Test that get_resource_path yields a valid file path."""
    resource_rel_path = "resources/schemas/data_dictionary.xml"
    path = get_resource_path(resource_rel_path)
    assert isinstance(path, Path)
    assert path.exists()
    assert path.is_file()
    assert path.name == "data_dictionary.xml"


def test_get_schema_returns_valid_path():
    """Test that get_schema returns a valid path."""
    path = get_schema("data_dictionary.xml")
    assert isinstance(path, Path)
    assert path.exists()
    assert path.is_file()
    assert path.name == "data_dictionary.xml"
