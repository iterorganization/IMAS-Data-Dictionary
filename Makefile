
include Makefile.common

# Include OS-specific Makefile, if exists.
ifneq (,$(wildcard Makefile.$(SYSTEM)))
include Makefile.$(SYSTEM)
endif

DD_FILES=dd_data_dictionary.xml IDSDef.xml IDSNames.txt dd_data_dictionary_validation.txt
HTMLDOC_FILES=$(wildcard $(addprefix html_documentation/,*.html css/*.css img/*.png js/*js))
HTMLDOC_FILES_IDS=$(wildcard $(addprefix html_documentation/,$(addsuffix /*.*,$(shell cat IDSNames.txt))))
COCOS_FILES=$(wildcard $(addprefix html_documentation/cocos/,*.csv))
UTILITIES_FILES=$(wildcard $(addprefix html_documentation/utilities/,*.*))

# Identifiers definition files
ID_IDENT = $(wildcard schemas/*/*_identifier.xml)
ID_FILES = $(ID_IDENT)

.PHONY: all clean test install

all: dd htmldoc test

clean: # dd_clean htmldoc_clean
	$(if $(wildcard .gitignore),git clean -f -X -d,$(RM) -f $(DD_FILES))

test: dd_data_dictionary_validation.txt
	grep -i -w Error $< >&2 && exit 1 || grep valid $<

install: dd_install identifiers_install htmldoc_install

.PHONY: htmldoc htmldoc_clean htmldoc_install
htmldoc: IDSNames.txt html_documentation/html_documentation.html html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv
htmldoc_clean:
	$(if $(wildcard .gitignore),git clean -f -X -d -- html_documentation,$(warning This target depends on .gitignore))
htmldoc_install: htmldoc
	$(mkdir_p) $(addprefix $(htmldir)/imas/,$(sort $(dir $(HTMLDOC_FILES:html_documentation/%=%))))
	$(INSTALL_DATA) $(filter %.html,$(HTMLDOC_FILES)) $(htmldir)/imas/
	$(INSTALL_DATA) $(filter %.css,$(HTMLDOC_FILES)) $(htmldir)/imas/css
	$(INSTALL_DATA) $(filter %.js,$(HTMLDOC_FILES)) $(htmldir)/imas/js
	$(INSTALL_DATA) $(filter %.png,$(HTMLDOC_FILES)) $(htmldir)/imas/img
	$(mkdir_p) $(htmldir)/imas/utilities
	$(INSTALL_DATA) $(UTILITIES_FILES) $(htmldir)/imas/utilities
	$(mkdir_p) $(htmldir)/imas/cocos
	$(INSTALL_DATA) $(filter %.csv,$(COCOS_FILES)) $(htmldir)/imas/cocos
	$(mkdir_p) $(addprefix $(htmldir)/imas/,$(sort $(dir $(HTMLDOC_FILES_IDS:html_documentation/%=%))))
	$(foreach idsdir,$(sort $(dir $(HTMLDOC_FILES_IDS))),\
		$(INSTALL_DATA) $(idsdir)/* $(htmldir)/imas/$(idsdir:html_documentation/%=%) ;\
	)

.PHONY: dd dd_clean dd_install
dd: $(DD_FILES)
dd_clean:
	$(if $(wildcard .gitignore),git clean -f -X -- *.*,$(warning This target depends on .gitignore))
dd_install: $(DD_FILES)
	$(mkdir_p) $(includedir)
	$(INSTALL_DATA) $(filter-out IDSDef.xml,$^) $(includedir)
	ln -sf dd_data_dictionary.xml $(includedir)/IDSDef.xml
	pip install . --prefix $(prefix) --upgrade

identifiers_install: $(ID_IDENT)
	$(mkdir_p) $(foreach subdir,$(sort $(^D)),$(includedir)/$(subdir))
	$(foreach F,$^,$(INSTALL_DATA) $(F) $(includedir)/$(dir $(F));)

# Compatibility target
IDSDef.xml: dd_data_dictionary.xml
	ln -sf $< $@

dd_data_dictionary.xml: %: %.xsd %.xsl
	$(xslt2proc)

html_documentation/html_documentation.html: dd_data_dictionary.xml dd_data_dictionary_html_documentation.xsl
	$(xslt2proc)
	cp schemas/utilities/coordinate_identifier.xml html_documentation/utilities/coordinate_identifier.xml

html_documentation/cocos/ids_cocos_transformations_symbolic_table.csv: dd_data_dictionary.xml ids_cocos_transformations_symbolic_table.csv.xsl
	$(xslt2proc)

IDSNames.txt dd_data_dictionary_validation.txt: %: dd_data_dictionary.xml %.xsl
	$(xslt2proc)

# Sphinx documentation
.PHONY: sphinx docs

docs: sphinx
sphinx: all
	$(MAKE) -C docs html

# Generic Dependencies

SAXON := $(shell command -v saxon 2> /dev/null)
ifeq ($(SAXON),)
SAXON := $(JAVA) net.sf.saxon.Transform
endif
# Saxon -threads is only valid from 9.4:
SAXON_THREADS := $(shell sv=$$($(SAXON) -t 2>&1 | grep "^Saxon");\
	major=$$(echo $${sv} | sed "s/Saxon[^ ]* \([0-9]\+\).*/\1/");\
	minor=$$(echo $${sv} | sed "s/Saxon[^ ]* [0-9]\+\.\([0-9]\+\).*/\1/");\
	minor=$$(printf %02d $${minor});\
	sv=$${major}$${minor};\
	if [ $${sv} -ge 904 ]; then echo "-threads:4"; else echo ""; fi;\
)


# Canned recipes
define xsltproc
@# Expect prerequisites: <xmlfile> <xslfile>
xsltproc $(word 2,$^) $< > $@ || { rm -f $@ ; exit 1 ;}
endef
define xslt2proc
@# Expect prerequisites: <xmlfile> <xslfile>
$(SAXON) $(SAXON_THREADS) -t -warnings:fatal -s:$< -xsl:$(word 2,$^) > $@ DD_GIT_DESCRIBE=$(DD_GIT_DESCRIBE) || { rm -f $@ ; exit 1 ; }
endef
