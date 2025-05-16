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
calorimetry
camera_ir
camera_visible
camera_x_rays
charge_exchange
controllers
core_instant_changes
core_profiles
core_sources
core_transport
cryostat
dataset_description
disruption
distribution_sources
distributions
divertors
ece
edge_profiles
edge_sources
edge_transport
em_coupling
equilibrium
ferritic
focs
gas_injection
gas_pumping
gyrokinetics_local
hard_x_rays
interferometer
iron_core
langmuir_probes
magnetics
mhd
mhd_linear
mse
nbi
neutron_diagnostic
ntms
operational_instrumentation
pellets
pf_active
pf_passive
pf_plasma
polarimeter
polarimeter_interferometer
pulse_schedule
radiation
reflectometer_heterodyne
reflectometer_profile
resistivity
spi
spectrometer_passive
spectroscopy_ce_zeff
spectroscopy_ms
spectroscopy_passive
summary
tf
thomson_scattering
top_level
transport_solver_numerics
vehicledef
waves
waves_code

$ python idsinfo cocos magnetics/b_field_tor_vacuum_r/0
{11: 'magnetics/b_field_tor_vacuum_r/0'}

$
"""

from xml.dom import minidom
import argparse
import importlib.resources
import os
import pathlib
import re
import subprocess
import sys


def _domattr(element, attribute):
    if not element.hasAttribute(attribute):
        return ""
    return element.getAttribute(attribute)


def _searchpath(filename, pathlist=None):
    if pathlib.Path(filename).exists():
        return pathlib.Path(filename)

    if pathlist is None:
        pathlist = os.environ.get("PATH", None)
        if not pathlist:
            pathlist = os.defpath
        pathlist = pathlist.split(":")
    for path in pathlist:
        realpath = pathlib.Path(path) / filename
        if realpath.exists():
            return realpath
    return None


def _get_python_strs():
    # First try the resources package
    try:
        # Locate the IDSDef.xml file in the resources/xml subfolder
        xml_path_resource = (
            importlib.resources.files("imas_data_dictionary.resources.xml")
            / "IDSDef.xml"
        )
        # Convert the resource path to a filesystem path if possible
        if xml_path_resource.is_file():
            return xml_path_resource

    except (ImportError, ModuleNotFoundError):
        pass

    # Then try traditional file paths
    include_path = os.environ.get("IMAS_INCLUDE")
    if include_path:
        xml_path = pathlib.Path(include_path) / "IDSDef.xml"
        if xml_path.exists():
            return xml_path

    for directory in [
        os.environ.get("HOME") + "/.local/",
        "/usr/local/",
        "/usr/",
    ]:
        if not directory:
            continue
        directory = pathlib.Path(directory)

        dd_dirs = [i for i in directory.glob("dd_*") if i.is_dir() or i.is_symlink()]

        for d in dd_dirs:
            xml_path = d / "include/IDSDef.xml"
            if pathlib.Path(xml_path).exists():
                return xml_path

    vscode_imas = _searchpath("imas-vscode")

    if vscode_imas:
        try:
            imas_dd_folder = (
                subprocess.check_output([vscode_imas, "--info-imas-path"])
                .strip()
                .decode("utf-8")
            )

            if imas_dd_folder and pathlib.Path(imas_dd_folder).exists():
                xml_path = pathlib.Path(imas_dd_folder) / "include/IDSDef.xml"
                if xml_path.exists():
                    return xml_path
        except Exception:
            pass

    # Fallback to local file
    xml_path = pathlib.Path(os.path.dirname(__file__)) / "../dd_data_dictionary.xml"
    if xml_path.exists():
        return xml_path

    return None


def _get_ids_dom():
    xml_path = _get_python_strs()

    if xml_path:
        try:
            # Handle both Path objects and resources
            if hasattr(xml_path, "read_bytes"):
                # This is a traversable resource
                content = xml_path.read_bytes()
                dom = minidom.parseString(content)
            else:
                # This is a Path object
                dom = minidom.parse(str(xml_path))
            return {"dom": dom, "path": xml_path}
        except Exception as e:
            print(f"Error parsing XML: {e}", file=sys.stderr)

    return None


def _get_ids(name):
    dom_info = _get_ids_dom()

    if not dom_info:
        return None

    dom = dom_info["dom"]
    ids = [
        i
        for i in dom.getElementsByTagName("IDS")
        if i.hasAttribute("name") and i.getAttribute("name") == name
    ]

    return ids[0] if len(ids) > 0 else None


def _strformat(strin):
    strin = strin.strip().split("\n")
    strin = [i.strip() for i in strin]
    return " ".join(strin)


class IdsPath:
    def __init__(self, idsname=None, path=None):
        self.idsname = idsname
        self.path = path or ""

    def __str__(self):
        if not self.idsname:
            return ""

        if not self.path:
            return self.idsname

        return f"{self.idsname}/{self.path}"

    def ispath(self, tocheck):
        if not self.idsname:
            return False

        fspath = str(self)

        if "/" in tocheck:
            return fspath.startswith(tocheck)

        return self.idsname == tocheck

    def leafname(self):
        if self.path and "/" in self.path:
            return self.path.split("/")[-1]
        return self.path

    @staticmethod
    def fromstr(stringpath):
        if not stringpath:
            return None

        if "/" not in stringpath:
            return IdsPath(idsname=stringpath)

        spl = stringpath.split("/", maxsplit=1)
        return IdsPath(idsname=spl[0], path=spl[1])


def _get_node_by_path(stringpath):
    idspath = IdsPath.fromstr(stringpath)

    if not idspath:
        return None

    ids = _get_ids(idspath.idsname)

    if not ids:
        return None

    if not idspath.path:
        return ids

    nodes = _path_structure_to_nodes(idspath.path)

    node = ids
    for key in nodes:
        if key["name"] == "":
            continue
        currnode = _get_node_child(node, key["name"], key["occurrence"])
        if not currnode:
            return None
        node = currnode

    return node


def _get_node_by_path_version(stringpath):
    idspath = IdsPath.fromstr(stringpath)

    if not idspath:
        return {}

    ids = _get_ids(idspath.idsname)

    if not ids:
        return {}

    if not idspath.path:
        return {
            "idsversion": _domattr(ids, "version"),
            "global_cocos": _domattr(ids, "global_cocos"),
        }

    stru = _path_structure_to_nodes(idspath.path)

    curr = ids
    versions = []
    cocoss = []
    for i, item in enumerate(stru):
        if item["name"] == "":
            continue

        curr = _get_node_child(curr, item["name"], item["occurrence"])

        if not curr:
            break

        if curr.nodeName == "attribute":
            v = _domattr(curr, "version")
            if v:
                versions.append(v)

            c = _domattr(curr, "cocos")
            if c:
                cocoss.append((c, list(range(i + 1))))
            local_cocos = _domattr(curr, "local_cocos")
            for parent_cocos in list(cocoss):
                if len(parent_cocos[1]) > 0 and i in parent_cocos[1]:
                    parent_cocos[1].remove(i)
                    if local_cocos:
                        cocoss.append((local_cocos, []))

    idspath = idspath.idsname
    idsversion = _domattr(ids, "version")
    global_cocos = _domattr(ids, "global_cocos")
    cocos = None
    dictVersions = {"idsversion": idsversion, "global_cocos": global_cocos}
    if len(versions) > 0:
        dictVersions["attribute_versions"] = ", ".join(versions)

    for c in cocoss:
        if len(c[1]) == 0:
            dictVersions["cocos"] = c[0]
            cocos = c[0]

    return dictVersions


def _get_cocos_dict(stringcocos):
    dom_info = _get_ids_dom()
    if not dom_info:
        return {}
    dom = dom_info["dom"]
    cocos = dom.getElementsByTagName("transform")
    result = {}
    for c in cocos:
        if c.hasAttribute("type") and c.getAttribute("type") == "cocos":
            if c.hasAttribute("path") and c.hasAttribute("to_cocos"):
                other_cocos = []
                for x in c.getAttribute("to_cocos").split(","):
                    if ":" in x:
                        t = x.split(":", 1)
                        if stringcocos == t[0]:
                            result[t[1]] = c.getAttribute("path")
                    other_cocos.append(x)

                if stringcocos in other_cocos:
                    result[stringcocos] = c.getAttribute("path")
    return result


def _get_max_occurrence(node, name):
    occurrence = 0
    for child in node.childNodes:
        if (
            child.nodeType == minidom.Node.ELEMENT_NODE
            and child.hasAttribute("name")
            and child.getAttribute("name") == name
        ):
            occurrence += 1
    return occurrence


def _get_node_child(node, name, occurrence=None):
    collection = []
    for child in node.childNodes:
        if (
            child.nodeType == minidom.Node.ELEMENT_NODE
            and child.hasAttribute("name")
            and child.getAttribute("name") == name
        ):
            collection.append(child)

    if occurrence is None:
        return collection[0] if len(collection) > 0 else None

    try:
        num = int(occurrence)
        if 0 <= num < len(collection):
            return collection[num]
    except (TypeError, ValueError):
        pass

    return None


def _idsnames():
    dom_info = _get_ids_dom()

    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)

    dom = dom_info["dom"]

    ids = [
        i.getAttribute("name")
        for i in dom.getElementsByTagName("IDS")
        if i.hasAttribute("name")
    ]

    print("\n".join(sorted(ids)))


def _attribute_values(node):
    results = {}
    for attr in node.attributes.keys():
        results[attr] = node.getAttribute(attr)
    return results


_RE_PATH_STRUCTURE = re.compile(r"([^/[{}\]\s]+)(?:\[([0-9]+)\])?")


def _path_structure_to_nodes(path):
    """
    Convert a path structure to a list of key/occurrence
    coils_non_axisymmetric/cocosrp/tconfig[0]/cocos

    [{"name": "coils_non_axisymmetric", "occurrence": None},
     {"name": "cocosrp", "occurrence": None},
     {"name": "tconfig", "occurrence": "0"},
     {"name": "cocos", "occurrence": None}]
    """
    matches = _RE_PATH_STRUCTURE.findall(path)
    nodes = []
    for m in matches:
        nodes.append({"name": m[0], "occurrence": m[1] if m[1] else None})
    return nodes


def _ids_children(node):
    # Returns a list of available attributes and structures.
    attributes = []
    structures = []
    for child in node.childNodes:
        if child.nodeType == minidom.Node.ELEMENT_NODE:
            if child.nodeName == "attribute" and child.hasAttribute("name"):
                childname = child.getAttribute("name")
                # Keep the occurrence when more than one
                occurrence = _get_max_occurrence(node, childname)
                if occurrence > 1:
                    for occ in range(occurrence):
                        attributes.append(f"{childname}[{occ}]")
                else:
                    attributes.append(childname)
            elif child.nodeName == "structure" and child.hasAttribute("name"):
                structures.append(child.getAttribute("name"))

    return sorted(attributes) + sorted(structures)


def _attributes(node):
    if node.nodeName == "attribute":
        return _attribute_values(node)

    # Returns all the attributes for children
    attributes = {}
    for child in node.childNodes:
        if (
            child.nodeType == minidom.Node.ELEMENT_NODE
            and child.nodeName == "attribute"
            and child.hasAttribute("name")
        ):
            attributes[child.getAttribute("name")] = _attribute_values(child)

    return attributes


def _ids_metadata():
    """
    Return the metadata of the data dictionary
    """
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)

    dom = dom_info["dom"]
    try:
        data_dictionary = dom.getElementsByTagName("data_dictionary")[0]

        # Find version in the data dictionary
        version = _domattr(data_dictionary, "imas_version")
        if version:
            print(f"This is Data Dictionary version = {version}", end="")
            # Find default cocos
            default_cocos = _domattr(data_dictionary, "default_cocos")
            if default_cocos:
                print(f", following COCOS = {default_cocos}")
            else:
                print()
        else:
            print("Unknown Data Dictionary version.")

    except Exception:
        print("No valid data dictionary found.")
        sys.exit(1)


def _path_children(args):
    """List elements in a path"""
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)
    node = _get_node_by_path(args.path)

    if not node:
        print(f"Path not found: {args.path}")
        sys.exit(1)

    print("\n".join(_ids_children(node)))


def _path_version(args):
    """List version/cocos information of a given path"""
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)
    version_info = _get_node_by_path_version(args.path)

    if "cocos" in version_info:
        print(f"cocos = {version_info['cocos']}")
    elif "global_cocos" in version_info:
        print(f"cocos = {version_info['global_cocos']} (global)")
    else:
        print("No cocos set.")

    if "idsversion" in version_info:
        print(f"IDS version = {version_info['idsversion']}")

    if "attribute_versions" in version_info:
        print(f"Attribute versions = {version_info['attribute_versions']}")


def _path_cocos_info(args):
    """List the cocos for a given path"""
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)
    cocos_dict = _get_cocos_dict(args.cocos)
    result = {}
    for cocos, path in cocos_dict.items():
        result[cocos] = path

    if len(result) == 0:
        print(f"No paths found for cocos {args.cocos}")
    else:
        print(result)


def _path_info(args):
    """Print information about a given path"""
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)
    node = _get_node_by_path(args.path)

    if not node:
        print(f"Path not found: {args.path}")
        sys.exit(1)

    if node.nodeName != "attribute":
        print(f"Path is not an attribute: {args.path}")
        sys.exit(1)

    attr_values = _attribute_values(node)
    if args.value:
        if args.value in attr_values:
            print(attr_values[args.value])
        else:
            print(f"Value not found: {args.value}")
            sys.exit(1)
    elif args.document:
        leaf = IdsPath.fromstr(args.path).leafname()
        version_info = _get_node_by_path_version(args.path)
        _ids_metadata()
        print("=" * 62)
        print(
            _strformat(attr_values.get("documentation", f"No documentation for {leaf}"))
        )

    else:
        info_string = []
        for key, value in attr_values.items():
            info_string.append(f"{key}: {value}")
        print("\n".join(info_string))


def _path_info_all(args):
    """Print all information about a given path"""
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)
    node = _get_node_by_path(args.path)

    if not node:
        print(f"Path not found: {args.path}")
        sys.exit(1)

    if node.nodeName == "IDS":
        # Print IDS info
        print(f"name: {_domattr(node, 'name')}")
        print(f"version: {_domattr(node, 'version')}")
        print(f"global_cocos: {_domattr(node, 'global_cocos')}")
        print(f"description: {_domattr(node, 'description')}")
    else:
        # Print node info
        info_string = [f"name: {IdsPath.fromstr(args.path).leafname()}"]
        info_string.append(f"path: {args.path}")
        if "/" in args.path:
            info_string.append(f"path_doc: {args.path}")
        else:
            info_string.append(f"path_doc: {args.path}")

        attr_values = _attribute_values(node)
        for key, value in attr_values.items():
            info_string.append(f"{key}: {value}")

        versiondict = _get_node_by_path_version(args.path)
        if "cocos" in versiondict:
            info_string.append(f"local_cocos: {versiondict['cocos']}")

        print("\n".join(info_string))


def _path_idspath(args):
    dom_info = _get_ids_dom()
    if dom_info is None:
        print(
            "No Data Dictionary found. Try: IMAS_INCLUDE=your_path/include/.",
            file=sys.stderr,
        )
        sys.exit(1)

    path = dom_info.get("path")

    if path:
        print(str(path))


def main():
    parser = argparse.ArgumentParser(description="IDS Info")
    subparsers = parser.add_subparsers(dest="command")

    parser_metadata = subparsers.add_parser(
        "metadata", help="Print Data Dictionary metadata"
    )
    parser_metadata.set_defaults(func=lambda x: _ids_metadata())

    parser_idsnames = subparsers.add_parser("idsnames", help="Show all IDS names")
    parser_idsnames.set_defaults(func=lambda x: _idsnames())

    parser_idspath = subparsers.add_parser(
        "idspath", help="Show full path to the IDSdef.xml file"
    )
    parser_idspath.set_defaults(func=_path_idspath)

    parser_ls = subparsers.add_parser("ls", help="List children of a given IDS path")
    parser_ls.add_argument("path", help="IDS path to list children")
    parser_ls.set_defaults(func=_path_children)

    parser_cocos = subparsers.add_parser(
        "cocos", help="List cocos information for a given COCOS"
    )
    parser_cocos.add_argument("cocos", help="The COCOS to search for")
    parser_cocos.set_defaults(func=_path_cocos_info)

    parser_info = subparsers.add_parser("info", help="Show info for a given IDS path")
    parser_info.add_argument("path", help="Path to get information for")
    group = parser_info.add_mutually_exclusive_group()
    group.add_argument(
        "-s", "--value", metavar="KEY", help="Get a specific value for the attribute"
    )
    group.add_argument(
        "-m", "--document", action="store_true", help="Show documentation only"
    )
    group.add_argument(
        "-a", "--all", action="store_true", help="Show all information about this path"
    )
    parser_info.set_defaults(func=_path_info)

    parser_imas_version = subparsers.add_parser(
        "version", help="Show version info for a given IDS path"
    )
    parser_imas_version.add_argument("path", help="Path to get version information for")
    parser_imas_version.set_defaults(func=_path_version)

    # Parse arguments
    args = parser.parse_args()

    if not args.command:
        parser.print_usage()
        sys.exit(1)

    if hasattr(args, "all") and args.all:
        _path_info_all(args)
    elif hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_usage()
        sys.exit(1)


if __name__ == "__main__":
    main()
