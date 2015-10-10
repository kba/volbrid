DESTDIR = /
PREFIX = usr

VERSION = $(shell grep version package.json | grep -oE '[0-9\.]+')
PKGNAME = $(shell grep name package.json |/bin/grep -o '[^"]*",'|/bin/grep -o '[^",]*')
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
	rm -f $(PKGNAME)-$(VERSION).tar.gz

install:
	npm install --unsafe-perm --prefix=$(DESTDIR)/$(PREFIX) -g
