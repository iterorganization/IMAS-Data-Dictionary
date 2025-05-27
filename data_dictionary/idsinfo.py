#!/usr/bin/env python

"""
Usage

$ python idsinfo metadata
This is Data Dictionary version = 3.37.0, following COCOS = 11

$ python idsinfo info amns_data ids_properties/comment -a
name: comment
path: ids_properties/comment
path_doc: ids_properties/comment
documentation: Any comment describing the content of this IDS
data_type: STR_0D
type: constant

$ python idsinfo info amns_data ids_properties/comment -m
This is Data Dictionary version = 3.37.0, following COCOS = 11
==============================================================
Any comment describing the content of this IDS
$

$ python idsinfo info amns_data ids_properties/comment -s data_type
STR_0D
$

$ python idsinfo idspath
/home/ITER/sawantp1/.local/dd_3.37.1+54.g20c6794.dirty/include/IDSDef.xml

$ python idsinfo idsnames
amns_data
barometry
bolometer
bremsstrahlung_visible
...

$ python idsinfo search ggd
distribution_sources/source/ggd
distributions/distribution/ggd
edge_profiles/grid_ggd
        ggd
        ggd_fast
edge_sources/grid_ggd
        source/ggd
...
"""
from packaging.version import Version
from pathlib import Path
import os
import re
import sys
import xml.etree.ElementTree as ET


class IDSInfo:
    """Simple class which allows to query meta-data from the definition of IDSs as expressed in IDSDef.xml."""

    root = None
    version = None
    cocos = None

    def __init__(self):
        # Find and parse XML definitions
        self.idsdef_path = ""
        self.legacy_doc_path = ""
        self.sphinx_doc_path = ""
        # Check idsdef.xml is installed in the Python environment (system as well as local)
        if not self.idsdef_path:
            local_path = os.path.join(str(Path.home()), ".local")
            python_env_list = [sys.prefix]
            if os.path.exists(local_path):
                python_env_list.append(local_path)
            reg_compile = re.compile("dd_*")
            version_list = None
            python_env_path = ""
            for python_env in python_env_list:
                version_list = [dirname for dirname in os.listdir(python_env) if reg_compile.match(dirname)]
                if version_list:
                    python_env_path = python_env
                    break
            if version_list is not None and len(version_list) != 0:
                version_objects = [Version(version.replace("dd_", "")) for version in version_list]
                latest_version = max(version_objects)
                folder_to_look = os.path.join(python_env_path, "dd_" + str(latest_version))
                for root, dirs, files in os.walk(folder_to_look):
                    for file in files:
                        if file.endswith("IDSDef.xml"):
                            self.idsdef_path = os.path.join(root, file)
                        if file.endswith("html_documentation.html"):
                            self.legacy_doc_path = os.path.join(root, file)
                        if root.endswith("sphinx") and file == "index.html":
                            self.sphinx_doc_path = os.path.join(root, file)

        # Search through higher level directories
        if not self.idsdef_path:
            current_fpath = os.path.dirname(os.path.realpath(__file__))
            # Newer approach : IMAS/<VERSION>/lib/python3.8/site-packages/data_dictionary/idsinfo.py
            _idsdef_path = os.path.join(current_fpath, r"../../../../include/IDSDef.xml")
            if os.path.isfile(_idsdef_path):
                self.idsdef_path = os.path.abspath(_idsdef_path)
            else:
                # Legacy approach : IMAS/<VERSION>/python/lib/data_dictionary/idsinfo.py
                _idsdef_path = os.path.join(current_fpath, r"../../../include/IDSDef.xml")
                if os.path.isfile(_idsdef_path):
                    self.idsdef_path = os.path.abspath(_idsdef_path)

            _doc_path = os.path.join(current_fpath, r"../../../../share/doc/imas/html_documentation.html")
            if os.path.isfile(_doc_path):
                self.legacy_doc_path = os.path.abspath(_doc_path)
            else:
                _doc_path = os.path.join(current_fpath, r"../../../share/doc/imas/html_documentation.html")
                if os.path.isfile(_doc_path):
                    self.legacy_doc_path = os.path.abspath(_doc_path)

            _sphinxdoc_path = os.path.join(current_fpath, r"../../../../share/doc/imas/sphinx/index.html")
            if os.path.isfile(_sphinxdoc_path):
                self.sphinx_doc_path = os.path.abspath(_sphinxdoc_path)
            else:
                _sphinxdoc_path = os.path.join(current_fpath, r"../../../share/doc/imas/sphinx/index.html")
                if os.path.isfile(_sphinxdoc_path):
                    self.sphinx_doc_path = os.path.abspath(_sphinxdoc_path)

        # Search using IMAS_PREFIX env variable
        if not self.idsdef_path:
            if "IMAS_PREFIX" in os.environ:
                _idsdef_path = os.path.join(os.environ["IMAS_PREFIX"], r"include/IDSDef.xml")
                if os.path.isfile(_idsdef_path):
                    self.idsdef_path = _idsdef_path

        if not self.legacy_doc_path:
            if "IMAS_PREFIX" in os.environ:
                _doc_path = os.path.join(os.environ["IMAS_PREFIX"], r"share/doc/imas/html_documentation.html")
                if os.path.isfile(_doc_path):
                    self.legacy_doc_path = _doc_path

        if not self.sphinx_doc_path:
            if "IMAS_PREFIX" in os.environ:
                _doc_path = os.path.join(os.environ["IMAS_PREFIX"], r"share/doc/imas/sphinx/index.html")
                if os.path.isfile(_doc_path):
                    self.sphinx_doc_path = _doc_path

            # Search using IDSDEF_PATH env variable
        if not self.idsdef_path:
            if "IDSDEF_PATH" in os.environ:
                _idsdef_path = os.environ["IDSDEF_PATH"]
                if os.path.isfile(_idsdef_path):
                    self.idsdef_path = os.environ["IDSDEF_PATH"]

        if not self.idsdef_path:
            raise Exception(
                "Error accessing IDSDef.xml.  Make sure its location is defined in your environment, e.g. by"
                "loading an IMAS module."
            )

        tree = ET.parse(self.idsdef_path)
        self.root = tree.getroot()
        self.version = self.root.findtext("./version", default="N/A")
        self.cocos = self.root.findtext("./cocos", default="N/A")

    def get_idsdef_path(self):
        "Get selected idsdef.xml path"
        return self.idsdef_path

    def get_version(self):
        """Returns the current Data-Dictionary version."""
        return self.version

    def __get_field(self, struct, field):  # sourcery skip: raise-specific-error
        """Recursive function which returns the node corresponding to a given field which is a descendant of struct."""
        elt = struct.find(f'./field[@name="{field[0]}"]')
        if elt is None:
            raise Exception(f"Element '{field[0]}' not found")
        if len(field) > 1:
            return self.__get_field(elt, field[1:])
        else:
            # specific generic node for which the useful doc is from the parent
            return elt if field[0] != "value" else struct

    def query(self, ids, path=None):
        """Returns attributes of the selected ids/path node as a dictionary."""
        ids = self.root.find(f"./IDS[@name='{ids}']")
        if ids is None:
            raise ValueError(f"Error getting the IDS, please check that '{ids}' corresponds to a valid IDS name")

        if path is not None:
            fields = path.split("/")

            try:
                f = self.__get_field(ids, fields)
            except Exception as exc:
                raise ValueError("Error while accessing {path}: {str(exc)}") from exc
        else:
            f = ids

        return f.attrib

    def get_ids_names(self):
        return [ids.attrib["name"] for ids in self.root.findall("IDS")]

    def find_in_ids(self, text_to_search="", strict=False):
        search_result = {}
        regex_to_search = text_to_search
        if strict:
            regex_to_search = f"^{text_to_search}$"
        for ids in self.root.findall("IDS"):
            is_top_node = False
            top_node_name = ""
            search_result_for_ids = {}
            for field in ids.iter("field"):
                if re.match(regex_to_search, field.attrib["name"]):
                    attributes = {}

                    if "units" in field.attrib.keys():
                        attributes["units"] = field.attrib["units"]
                    if "documentation" in field.attrib.keys():
                        attributes["documentation"] = field.attrib["documentation"]

                    search_result_for_ids[field.attrib["path"]] = attributes
                    if not is_top_node:
                        is_top_node = True
                        top_node_name = ids.attrib["name"]
            if top_node_name:  # add to dict only if something is found
                search_result[top_node_name] = search_result_for_ids
        return search_result

    def list_ids_fields(self, idsname=""):
        search_result = {}
        for ids in self.root.findall("IDS"):
            if ids.attrib["name"] == idsname.lower():
                is_top_node = False
                top_node_name = ""
                search_result_for_ids = {}
                fieldlist=[]
                for field in ids.iter("field"):
                    fieldlist.append(field)
                    attributes = {}

                    if "units" in field.attrib.keys():
                        attributes["units"] = field.attrib["units"]
                        if "as_parent" in attributes["units"]:
                            for sfield in reversed(fieldlist):
                                if "units" in sfield.attrib.keys():
                                    if "as_parent" not in sfield.attrib["units"]:
                                        attributes["units"] = sfield.attrib["units"]
                                        break
                    if "documentation" in field.attrib.keys():
                        attributes["documentation"] = field.attrib["documentation"]
                    field_path = re.sub(r"\(([^:][^itime]*?)\)", "(:)", field.attrib["path_doc"])
                    if "timebasepath" in field.attrib.keys():
                        field_path = re.sub(r"\(([:]*?)\)$", "(itime)", field_path)
                    search_result_for_ids[field_path] = attributes
                    if not is_top_node:
                        is_top_node = True
                        top_node_name = ids.attrib["name"]
                if top_node_name:  # add to dict only if something is found
                    search_result[top_node_name] = search_result_for_ids
        return search_result


def main():
    import argparse

    idsinfo_parser = argparse.ArgumentParser(description="IDS Info Utilities")
    subparsers = idsinfo_parser.add_subparsers(help="sub-commands help")

    idspath_command_parser = subparsers.add_parser("idspath", help="print ids definition path")
    idspath_command_parser.set_defaults(cmd="idspath")

    metadata_command_parser = subparsers.add_parser("metadata", help="print metadata")
    metadata_command_parser.set_defaults(cmd="metadata")

    idsnames_command_parser = subparsers.add_parser("idsnames", help="print ids names")
    idsnames_command_parser.set_defaults(cmd="idsnames")

    search_command_parser = subparsers.add_parser("search", help="Search in ids")
    search_command_parser.set_defaults(cmd="search")
    search_command_parser.add_argument(
        "text",
        nargs="?",
        default="",
        help="Text to search in all IDSes",
    )
    search_command_parser.add_argument(
        "-s",
        "--strict",
        action="store_true",
        help="Perform a strict search, ie, the text has to match exactly within a word, eg:"
        "'value' does not match 'values'",
    )

    search_command_parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Shows description along with unit",
    )

    idsfields_command_parser = subparsers.add_parser("idsfields", help="shows all fields from ids")
    idsfields_command_parser.set_defaults(cmd="idsfields")
    idsfields_command_parser.add_argument(
        "idsname",
        type=str,
        default="",
        help="Provide ids Name",
    )
    idsfields_command_parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Shows description along with unit",
    )
    info_command_parser = subparsers.add_parser("info", help="Query the IDS XML Definition for documentation")
    info_command_parser.set_defaults(cmd="info")

    info_command_parser.add_argument("ids", type=str, help="IDS name")
    info_command_parser.add_argument(
        "path",
        type=str,
        nargs="?",
        default=None,
        help="Path for field of interest within the IDS",
    )
    doc_command_parser = subparsers.add_parser("doc", help="Show documentation in the browser")
    doc_command_parser.set_defaults(cmd="doc")

    doc_command_parser.add_argument("-l", "--legacy", action="store_true", help="Show legacy documentation")
    opt = info_command_parser.add_mutually_exclusive_group()
    opt.add_argument("-a", "--all", action="store_true", help="Print all attributes")
    opt.add_argument(
        "-s",
        "--select",
        type=str,
        default="documentation",
        help="Select attribute to be printed \t(default=%(default)s)",
    )
    args = idsinfo_parser.parse_args()
    try:
        if args.cmd is None:
            idsinfo_parser.print_help()
            return
    except AttributeError:
        idsinfo_parser.print_help()
        return

    # Create IDSDef Object
    idsinfoObj = IDSInfo()
    if args.cmd == "metadata":
        mstr = f"This is Data Dictionary version = {idsinfoObj.version}, following COCOS = {idsinfoObj.cocos}"
        print(mstr)
        print("=" * len(mstr))

    if args.cmd == "idspath":
        print(idsinfoObj.get_idsdef_path())
    if args.cmd == "info":
        attribute_dict = idsinfoObj.query(args.ids, args.path)
        if args.all:
            for a in attribute_dict.keys():
                print(f"{a}: {attribute_dict[a]}")
        else:
            print(attribute_dict[args.select])
    elif args.cmd == "idsnames":
        for name in idsinfoObj.get_ids_names():
            print(name)
    elif args.cmd == "doc":
        if args.legacy:
            url = idsinfoObj.legacy_doc_path
        else:
            url = idsinfoObj.sphinx_doc_path
            if not url:
                print("Could not find sphinx documentation. falling back to legacy documentation")
                url = idsinfoObj.legacy_doc_path
        if url:
            print("Showing documentation from : " + url)
            import webbrowser

            webbrowser.open(url)
    elif args.cmd == "search":
        if args.text not in ["", None]:
            print(f"Searching for '{args.text}'.")
            result = idsinfoObj.find_in_ids(args.text.strip(), strict=args.strict)
            for ids_name, fields in result.items():
                print(f"{ids_name}:")
                for field, attributes in fields.items():
                    print(field)
                    if args.verbose:
                        if "documentation" in attributes.keys():
                            documentation = attributes["documentation"]
                            print(f"\tDescription : {documentation}")
                        if "units" in attributes.keys():
                            units = attributes["units"]
                            print(f"\tUnit : {units}")
        else:
            search_command_parser.print_help()
            print("Please provide text to search in IDSes")
            return
    elif args.cmd == "idsfields":
        if args.idsname not in ["", None]:
            result = idsinfoObj.list_ids_fields(args.idsname.strip())
            if bool(result):
                print(f"Listing all fields from ids :'{args.idsname}'")
                for ids_name, fields in result.items():
                    print(ids_name)
                    for field, attributes in fields.items():
                        print(field)
                        if args.verbose:
                            if "documentation" in attributes.keys():
                                documentation = attributes["documentation"]
                                print(f"\tDescription : {documentation}")
                            if "units" in attributes.keys():
                                units = attributes["units"]
                                print(f"\tUnit : {units}")
            else:
                idsfields_command_parser.print_help()
                print("Please provide valid IDS name")
                return
        else:
            idsfields_command_parser.print_help()
            print("Please provide valid IDS name")
            return


if __name__ == "__main__":
    sys.exit(main())
