DESTDIR = /
PREFIX = usr

VERSION = 0.1.3
PKGNAME = volbriosd
PANDOC = pandoc

all: dist

clean:
	rm -rf lib
	rm -rf man

docs:
	mkdir -p man
	$(PANDOC) -s -t man dist/volbriosd.1.md |gzip > man/volbriosd.1.gz

build: docs
	coffee -c -o lib src

dist: build
	mkdir -p $(PKGNAME)-$(VERSION)
	cp -r -t $(PKGNAME)-$(VERSION) \
		bin \
		dist \
		man \
		lib \
		Makefile \
		.npmignore \
		package.json
	tar czf $(PKGNAME)-$(VERSION).tar.gz $(PKGNAME)-$(VERSION)

distclean: clean
	rm -rf $(PKGNAME)-$(VERSION)
	rm -f $(PKGNAME)-*.tar.gz

install:
	npm install --unsafe-perm --prefix=$(DESTDIR)/$(PREFIX) -g
