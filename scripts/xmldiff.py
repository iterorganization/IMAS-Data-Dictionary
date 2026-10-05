from __future__ import annotations
import textwrap
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Tuple


@dataclass
class XMLNode:
    """Snapshot of an XML node (for added/removed trees)."""

    path: str
    tag: str
    attributes: Dict[str, str]
    text: Optional[str]
    children: List[XMLNode]


@dataclass
class AttributeDiff:
    name: str
    old_value: Optional[str]
    new_value: Optional[str]

    def __str__(self) -> str:
        if self.old_value is None:
            return f"[+] @{self.name}: {self.new_value}"
        if self.new_value is None:
            return f"[-] @{self.name}: {self.old_value}"
        return f"[~] @{self.name}: {self.old_value} -> {self.new_value}"


@dataclass
class ElementDiff:
    path: str
    tag: str
    identifier: str
    state: str = "changed"  # "added", "removed", "changed"

    # For "added" or "removed" nodes, this holds the full tree snapshot
    node: Optional[XMLNode] = None

    # For "changed" nodes:
    text_diff: Optional[Tuple[str, str]] = None  # (old, new)
    attributes: List[AttributeDiff] = field(default_factory=list)
    children: List[ElementDiff] = field(default_factory=list)

    def __str__(self) -> str:
        # Simple string representation for CLI
        lines = []
        if self.state == "added":
            lines.append(f"[+] {self.path}")
        elif self.state == "removed":
            lines.append(f"[-] {self.path}")
        else:
            lines.append(f"[~] {self.path}")
            for attr in self.attributes:
                lines.append(f"  {attr}")
            if self.text_diff:
                lines.append(f"  Text: {self.text_diff[0]} -> {self.text_diff[1]}")

        for child in self.children:
            child_str = str(child)
            lines.append(textwrap.indent(child_str, "  "))
        return "\n".join(lines)


class XMLDiffer:
    def __init__(self, id_attribs: Optional[List[str]] = None):
        self.id_attribs = id_attribs or ["name"]

    def _get_identifier(self, elem: ET.Element) -> str:
        """Generates a unique identifier for an element based on its tag and ID attributes."""
        for attr in self.id_attribs:
            if attr in elem.attrib:
                return f"{elem.tag}[@{attr}={elem.attrib[attr]}]"
        return elem.tag

    def _element_to_node(self, path: str, elem: ET.Element) -> XMLNode:
        """Converts an ET.Element to a static XMLNode snapshot recursively."""
        children = []
        for child in elem:
            ident = self._get_identifier(child)
            new_path = f"{path}/{ident}"
            children.append(self._element_to_node(new_path, child))

        return XMLNode(
            path=path,
            tag=elem.tag,
            attributes=dict(elem.attrib),
            text=elem.text,
            children=children,
        )

    def _compare_attributes(
        self, e1: ET.Element, e2: ET.Element
    ) -> List[AttributeDiff]:
        attr_diffs = []

        # Determine strict order of keys for deterministic output
        all_keys = sorted(set(e1.attrib.keys()) | set(e2.attrib.keys()))

        for key in all_keys:
            val1 = e1.attrib.get(key)
            val2 = e2.attrib.get(key)

            if val1 != val2:
                # If one is None, it means added or removed. If both present but different, changed.
                attr_diffs.append(AttributeDiff(key, val1, val2))
        return attr_diffs

    def _compare_children(
        self, e1: ET.Element, e2: ET.Element, path: str
    ) -> List[ElementDiff]:
        children_diffs = []
        map1 = {self._get_identifier(c): c for c in e1}
        map2 = {self._get_identifier(c): c for c in e2}

        # Preserve order from both XMLs:
        # - Use e1's order as the base structure (preserves removed items in their original position)
        # - Insert new items from e2 at their appropriate positions

        keys1 = [self._get_identifier(c) for c in e1]
        keys2 = [self._get_identifier(c) for c in e2]

        # Build the merged order
        all_child_keys = []
        seen_keys = set()

        # Start with e1's order
        for k in keys1:
            if k not in seen_keys:
                all_child_keys.append(k)
                seen_keys.add(k)

        for i, k in enumerate(keys2):
            if k not in seen_keys:
                insert_pos = len(all_child_keys)

                for j in range(i - 1, -1, -1):
                    prev_key = keys2[j]
                    if prev_key in seen_keys:
                        try:
                            insert_pos = all_child_keys.index(prev_key) + 1
                            break
                        except ValueError:
                            pass

                all_child_keys.insert(insert_pos, k)
                seen_keys.add(k)

        for k in all_child_keys:
            new_path = f"{path}/{k}"
            if k not in map1:
                # Added
                child_node = map2[k]
                children_diffs.append(
                    ElementDiff(
                        path=new_path,
                        tag=child_node.tag,
                        identifier=k,
                        state="added",
                        node=self._element_to_node(new_path, child_node),
                    )
                )
            elif k not in map2:
                # Removed
                child_node = map1[k]
                children_diffs.append(
                    ElementDiff(
                        path=new_path,
                        tag=child_node.tag,
                        identifier=k,
                        state="removed",
                        node=self._element_to_node(new_path, child_node),
                    )
                )
            else:
                # Common - recurse
                child_diff = self._compare_elements(map1[k], map2[k], new_path, k)
                if child_diff:
                    children_diffs.append(child_diff)

        return children_diffs

    def _compare_elements(
        self, e1: ET.Element, e2: ET.Element, path: str, identifier: str
    ) -> Optional[ElementDiff]:
        diff = ElementDiff(
            path=path, tag=e1.tag, identifier=identifier, state="changed"
        )
        has_changes = False

        # Attributes
        diff.attributes = self._compare_attributes(e1, e2)
        if diff.attributes:
            has_changes = True

        # Text
        t1 = (e1.text or "").strip()
        t2 = (e2.text or "").strip()
        if t1 != t2:
            diff.text_diff = (t1, t2)
            has_changes = True

        # Children
        diff.children = self._compare_children(e1, e2, path)
        if diff.children:
            has_changes = True

        return diff if has_changes else None

    def diff_files(self, file1: str, file2: str) -> Optional[ElementDiff]:
        try:
            tree1 = ET.parse(file1)
            tree2 = ET.parse(file2)
            root1 = tree1.getroot()
            root2 = tree2.getroot()

            if root1.tag != root2.tag:
                print(f"Root tag mismatch: {root1.tag} vs {root2.tag}")
                return None

            diff = self._compare_elements(
                root1, root2, path=root1.tag, identifier=root1.tag
            )
            if diff is None:
                # Return an empty diff
                return ElementDiff(
                    path=root1.tag, tag=root1.tag, identifier=root1.tag, state="none"
                )
            else:
                return diff

        except Exception as e:
            print(f"Error diffing files: {e}")
            return None


if __name__ == "__main__":
    import sys

    differ = XMLDiffer(id_attribs=["name"])

    f1 = "build/base.xml"
    f2 = "build/cur.xml"

    if len(sys.argv) > 2:
        f1 = sys.argv[1]
        f2 = sys.argv[2]

    result = differ.diff_files(f1, f2)

    if not result:
        print("No differences found.")
    else:
        print(result)
