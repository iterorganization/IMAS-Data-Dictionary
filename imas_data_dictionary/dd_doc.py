#!/usr/bin/env python3
"""
Open IMAS Data Dictionary documentation in default browser.

This script locates and opens the HTML documentation that was installed
with the imas-data-dictionary package.
"""

import sys
import webbrowser
from pathlib import Path


def main():
    """Open the IMAS Data Dictionary documentation in the default browser."""
    try:
        # find documentation files using importlib.resources
        try:
            # Python 3.9+
            from importlib.resources import files

            package_files = files("imas_data_dictionary")
            doc_path = (
                package_files
                / "resources"
                / "docs"
                / "legacy"
                / "html_documentation.html"
            )
            doc_file = str(doc_path)
        except (ImportError, AttributeError):
            # Fallback for Python 3.8
            import importlib.resources as resources

            with resources.path("imas_data_dictionary", "resources"):
                resource_path = (
                    Path(resources.__file__).parent
                    / "imas_data_dictionary"
                    / "resources"
                )
            doc_file = str(
                resource_path / "docs" / "legacy" / "html_documentation.html"
            )

        # Alternative: direct path lookup
        if not Path(doc_file).exists():
            # Try to find it relative to this package
            package_dir = Path(__file__).parent
            doc_file = str(
                package_dir
                / "resources"
                / "docs"
                / "legacy"
                / "html_documentation.html"
            )

        if not Path(doc_file).exists():
            print("[IMAS-DD] Error: Documentation file not found", file=sys.stderr)
            print("[IMAS-DD] Searched locations:", file=sys.stderr)
            print(f"  - {doc_file}", file=sys.stderr)
            print(
                "[IMAS-DD] Documentation may not have been installed. Install with:",
                file=sys.stderr,
            )
            print("  pip install imas-data-dictionary[docs]", file=sys.stderr)
            sys.exit(1)

        # Convert to file:// URL for browser
        doc_url = Path(doc_file).as_uri()

        print(f"[IMAS-DD] Opening documentation: {doc_file}")
        print(f"[IMAS-DD] URL: {doc_url}")

        # Open in default browser
        success = webbrowser.open(doc_url)

        if success:
            print("[IMAS-DD] Documentation opened in default browser")
            sys.exit(0)
        else:
            print(
                "[IMAS-DD] Warning: Could not open browser, please open manually:",
                file=sys.stderr,
            )
            print(f"  file://{Path(doc_file).as_uri()}", file=sys.stderr)
            sys.exit(1)

    except Exception as e:
        print(f"[IMAS-DD] Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
