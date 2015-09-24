# Copied from Carsten Bormann's kramdown-rfc tutorial
#
OPEN=$(word 1, $(wildcard /usr/bin/xdg-open /usr/bin/open /bin/echo))
SOURCES?=$(filter-out README.md,${wildcard *.md})
DRAFTS=${SOURCES:.md=.txt}
HTML=${SOURCES:.md=.html}
XML=${SOURCES:.md=.xml}

all:    xml html txt

html:   $(HTML)

txt:	$(DRAFTS)

xml:	$(XML)

%.xml: $(SOURCES)
	kramdown-rfc2629 $< >$@.new
	mv $@.new $@

%.html: %.xml
	xml2rfc --html $<
	$(OPEN) $@

%.txt:  %.xml
	xml2rfc  $< $@
