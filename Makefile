DESTDIR = /
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
	tar czv \
		bin \
		dist \
		man \
		lib \
		Makefile \
		.npmignore \
		package.json |gzip > $(PKGNAME)-$(VERSION).tar.gz

distclean: clean
	rm -f $(PKGNAME)-*.tar.gz

install:
	npm install --unsafe-perm --prefix=$(DESTDIR) -g
