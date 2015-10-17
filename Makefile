DESTDIR = /
PREFIX = usr

VERSION = $(shell grep version package.json | grep -oE '[0-9\.]+')
PKGNAME = $(shell grep name package.json |/bin/grep -o '[^"]*",'|/bin/grep -o '[^",]*')
PANDOC = pandoc

all: dist

clean:
	rm -rf lib
	rm -rf man
	rm -rf etc

docs:
	mkdir -p man
	$(PANDOC) -s -t man dist/volbrid.1.md |gzip > man/volbrid.1.gz
	$(PANDOC) -s -t man dist/volbri.1.md |gzip > man/volbri.1.gz

etc:
	mkdir -p etc
	sed 's/^/# /' < builtin.yml > etc/volbrid.yml

build: docs etc
	coffee -c -o lib src

dist: build
	mkdir -p $(PKGNAME)-$(VERSION)
	cp -r -t $(PKGNAME)-$(VERSION) \
		bin \
		dist \
		man \
		etc \
		lib \
		Makefile \
		.npmignore \
		package.json
	tar czf $(PKGNAME)-$(VERSION).tar.gz $(PKGNAME)-$(VERSION)

distclean: clean
	rm -rf $(PKGNAME)-$(VERSION)
	rm -f $(PKGNAME)-$(VERSION).tar.gz

install: build
	npm install --unsafe-perm --prefix=$(DESTDIR)/$(PREFIX) --global
	mkdir -p $(DESTDIR)/etc
	cp -t $(DESTDIR)/etc etc/volbrid.yml
	# find $(DESTDIR/$(PREFIX) -name "package.json" -exec sed -i "s,$(PWD),," {} \;
	# find $(DESTDIR/$(PREFIX) -name "package.json" -exec sed -i "s,$(PWD),," {} \;

