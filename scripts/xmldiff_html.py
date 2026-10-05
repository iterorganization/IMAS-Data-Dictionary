import argparse
import os
import sys
from jinja2 import Environment, FileSystemLoader
from xmldiff import XMLDiffer


class HTMLDiffGenerator:
    def generate(self, base_file: str, current_file: str, output_file: str) -> None:
        differ = XMLDiffer(id_attribs=["name"])
        print(f"Comparing {base_file} and {current_file}...")
        root_diff = differ.diff_files(base_file, current_file)

        if not root_diff:
            print("Error generating diff.")
            sys.exit(1)

        # Setup Jinja2 environment
        # We assume the template is in the same directory as this script or the current working directory
        template_dir = os.path.dirname(os.path.abspath(__file__))
        env = Environment(
            loader=FileSystemLoader([template_dir, os.getcwd()]),
            autoescape=True,
            trim_blocks=True,
            lstrip_blocks=True,
        )

        try:
            template = env.get_template("diff_template.html.jinja")
        except Exception as e:
            print(f"Error loading template 'diff_template.html.jinja': {e}")
            sys.exit(1)

        print("Rendering HTML...")
        html_content = template.render(
            file1=base_file, file2=current_file, diff_root=root_diff
        )

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(html_content)
        print(f"HTML diff generated at {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate HTML diff for XML files.")
    parser.add_argument(
        "base", nargs="?", default="build/base.xml", help="Base XML file"
    )
    parser.add_argument(
        "current", nargs="?", default="build/cur.xml", help="Current XML file"
    )
    parser.add_argument("-o", "--output", default="diff.html", help="Output HTML file")

    args = parser.parse_args()

    # Check if files exist
    if not os.path.exists(args.base):
        print(f"Error: Base file '{args.base}' not found.")
        sys.exit(1)
    if not os.path.exists(args.current):
        print(f"Error: Current file '{args.current}' not found.")
        sys.exit(1)

    generator = HTMLDiffGenerator()
    generator.generate(args.base, args.current, args.output)
