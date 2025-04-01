from setuptools_scm import get_version
import os
import re
import shutil
import subprocess
import saxonche

PWD = os.path.realpath(os.path.dirname(__file__))
UAL = os.path.dirname(PWD)

def join_path(path1="", path2=""):
    return os.path.normpath(os.path.join(path1, path2))


DD_GIT_DESCRIBE = get_version()

# Target files
dd_xsd = "dd_data_dictionary.xml.xsd"
dd_xsl = "dd_data_dictionary.xml.xsl"
dd_xml = "dd_data_dictionary.xml"
doc_xsl = "dd_data_dictionary_html_documentation.xsl"
doc_html = "html_documentation.html"
cocos_xsl = "ids_cocos_transformations_symbolic_table.csv.xsl"
cocos_csv = "html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv"
names_xsl = "IDSNames.txt.xsl"
names_txt = "IDSNames.txt"
valid_xsl = "dd_data_dictionary_validation.txt.xsl"
valid_txt = "dd_data_dictionary_validation.txt"
js_xsl = "docs/generate_js_IDSDef.xsl"
js_def = "docs/_static/IDSDefxml.js"

def generate_dd_data_dictionary(extra_opts=""):
    print("generating dd_data_dictionary.xml")
    with saxonche.PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xdm_ddgit = proc.make_string_value(DD_GIT_DESCRIBE)
        xsltproc.set_parameter('DD_GIT_DESCRIBE', xdm_ddgit)
        xsltproc.transform_to_file(source_file=dd_xsd, stylesheet_file=dd_xsl, output_file=dd_xml)

    try:
        if not os.path.islink(join_path(PWD, "IDSDef.xml")):
            os.symlink(
                "dd_data_dictionary.xml",
                "IDSDef.xml",
            )
    except Exception as _:  # noqa: F841
        shutil.copy("dd_data_dictionary.xml", "IDSDef.xml")


def generate_html_documentation(extra_opts=""):
    print("generating html_documentation.html")
    with saxonche.PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xdm_ddgit = proc.make_string_value(DD_GIT_DESCRIBE)
        xsltproc.set_parameter('DD_GIT_DESCRIBE', xdm_ddgit)
        xsltproc.transform_to_file(source_file=dd_xml, stylesheet_file=doc_xsl, output_file=doc_html)

    shutil.copy(
        "utilities/coordinate_identifier.xml",
        "html_documentation/utilities/coordinate_identifier.xml",
    )


def generate_ids_cocos_transformations_symbolic_table(extra_opts=""):
    print("generating html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv")
    with saxonche.PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xdm_ddgit = proc.make_string_value(DD_GIT_DESCRIBE)
        xsltproc.set_parameter('DD_GIT_DESCRIBE', xdm_ddgit)
        xsltproc.transform_to_file(source_file=dd_xml, stylesheet_file=cocos_xsl, output_file=cocos_csv)


def generate_idsnames():
    print("generating IDSNames.txt")
    with saxonche.PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xsltproc.transform_to_file(source_file=dd_xml, stylesheet_file=names_xsl, output_file=names_txt)

        
def generate_dd_data_dictionary_validation(extra_opts=""):
    print("dd_data_dictionary_validation.txt")
    with saxonche.PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xsltproc.transform_to_file(source_file=dd_xml, stylesheet_file=valid_xsl, output_file=valid_txt)

def generate_idsdef_js():
    print("Generating docs/_static/IDSDefxml.js")
    with saxonche.PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt30_processor()
        xsltproc.transform_to_file(source_file=dd_xml, stylesheet_file=js_xsl, output_file=js_def)


if __name__ == "__main__":

    generate_dd_data_dictionary()
    generate_html_documentation()
    generate_ids_cocos_transformations_symbolic_table()
    generate_idsnames()
    generate_dd_data_dictionary_validation()
    generate_idsdef_js()
