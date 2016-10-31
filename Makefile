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
	sed -e 's/@DATE@/$(date +%Y-%m-%d)/' $< > $@.tmp
	kramdown-rfc2629 $@.tmp >$@.new
	rm $@.tmp
	mv $@.new $@

%.html: %.xml
	xml2rfc --html $<
	$(OPEN) $@

%.txt:  %.xml
	xml2rfc  $< $@

clean:
	rm -f ${DRAFTS} ${HTML} ${XML}
