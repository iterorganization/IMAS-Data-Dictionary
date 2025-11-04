#!/usr/bin/env python3
"""
Open IMAS Data Dictionary documentation in default browser.

By default, opens the online documentation at ReadTheDocs.
Use -l/--legacy flag to open the local HTML documentation from package resources.
"""

import argparse
import sys
import webbrowser
from pathlib import Path


def get_docs_url():
    """Get the appropriate ReadTheDocs URL based on package version."""
    try:
        from imas_data_dictionary._version import __version__
        
        version = __version__
        
        # Check if this is a development version
        if "dev" in version.lower() or "post" in version.lower():
            # Development versions use 'latest'
            return "https://imas-data-dictionary.readthedocs.io/en/latest/"
        else:
            # Release versions use the specific version number
            return f"https://imas-data-dictionary.readthedocs.io/en/{version}/"
    except Exception:
        # Fallback to latest if version can't be determined
        return "https://imas-data-dictionary.readthedocs.io/en/latest/"


def open_online_docs():
    """Open the online documentation on ReadTheDocs."""
    doc_url = get_docs_url()
    print(f"[IMAS-DD] Opening online documentation: {doc_url}")
    
    success = webbrowser.open(doc_url)
    
    if success:
        print("[IMAS-DD] Documentation opened in default browser")
        sys.exit(0)
    else:
        print(
            "[IMAS-DD] Warning: Could not open browser, please open manually:",
            file=sys.stderr,
        )
        print(f"  {doc_url}", file=sys.stderr)
        sys.exit(1)


def open_legacy_docs():
    """Open the local legacy HTML documentation from package resources."""
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
            print("[IMAS-DD] Error: Legacy documentation file not found", file=sys.stderr)
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

        print(f"[IMAS-DD] Opening legacy documentation: {doc_file}")
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
            print(f"  {doc_url}", file=sys.stderr)
            sys.exit(1)

    except Exception as e:
        print(f"[IMAS-DD] Error: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """Main entry point with argument parsing."""
    parser = argparse.ArgumentParser(
        prog="dd_doc",
        description="Open IMAS Data Dictionary documentation",
    )
    parser.add_argument(
        "-l",
        "--legacy",
        action="store_true",
        help="Open local legacy HTML documentation instead of online version",
    )
    
    args = parser.parse_args()
    
    if args.legacy:
        open_legacy_docs()
    else:
        open_online_docs()


if __name__ == "__main__":
    main()
