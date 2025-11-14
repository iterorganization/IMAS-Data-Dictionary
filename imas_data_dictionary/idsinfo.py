#!/usr/bin/env python3

"""
Usage

$ idsinfo metadata
This is Data Dictionary version = 3.37.0, following COCOS = 11

$ idsinfo info amns_data ids_properties/comment -a
name: comment
path: ids_properties/comment
path_doc: ids_properties/comment
documentation: Any comment describing the content of this IDS
data_type: STR_0D
type: constant

$ idsinfo info amns_data ids_properties/comment
This is Data Dictionary version = 3.37.0, following COCOS = 11
==============================================================
Any comment describing the content of this IDS
$

$ idsinfo info amns_data ids_properties/comment -s data_type
STR_0D
$

$ idsinfo idspath
/home/ITER/sawantp1/.local/dd_3.37.1/include/IDSDef.xml

$ idsinfo idsnames
amns_data
barometry
bolometer
bremsstrahlung_visible
...

$ idsinfo search ggd
distribution_sources/source/ggd
distributions/distribution/ggd
edge_profiles/grid_ggd
        ggd
        ggd_fast
edge_sources/grid_ggd
        source/ggd
...
"""

import importlib.resources
import os
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

from packaging.version import Version


class IDSInfo:
    """Simple class which allows to query meta-data from the definition of IDSs as expressed in data_dictionary.xml."""

    root = None
    version = None
    cocos = None

    def __init__(self):
        # Find and parse XML definitions
        from imas_data_dictionary import get_schema

        self.idsdef_path = ""
        self.root = None
        self.version = ""
        self.cocos = ""
        schema_path = get_schema("data_dictionary.xml")
        self.idsdef_path = schema_path

        if not self.idsdef_path:
            raise Exception(f"Error accessing data_dictionary.xml.  {self.idsdef_path}")

        tree = ET.parse(self.idsdef_path)
        self.root = tree.getroot()
        self.version = self.root.findtext("./version", default="N/A")
        self.cocos = self.root.findtext("./cocos", default="N/A")

    def get_idsdef_path(self):
        "Get selected data_dictionary.xml path"
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
            raise ValueError(
                f"Error getting the IDS, please check that '{ids}' corresponds to a valid IDS name"
            )

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
                fieldlist = []
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
                    field_path = re.sub(
                        r"\(([^:][^itime]*?)\)", "(:)", field.attrib["path_doc"]
                    )
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

    idspath_command_parser = subparsers.add_parser(
        "idspath", help="print ids definition path"
    )
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

    idsfields_command_parser = subparsers.add_parser(
        "idsfields", help="shows all fields from ids"
    )
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
    info_command_parser = subparsers.add_parser(
        "info", help="Query the IDS XML Definition for documentation"
    )
    info_command_parser.set_defaults(cmd="info")

    info_command_parser.add_argument("ids", type=str, help="IDS name")
    info_command_parser.add_argument(
        "path",
        type=str,
        nargs="?",
        default=None,
        help="Path for field of interest within the IDS",
    )
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
