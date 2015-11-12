DESTDIR = /
PREFIX = usr
ETC_PATH = $(DESTDIR)etc
INSTALL_PATH = $(DESTDIR)$(PREFIX)
LIBDIR = $(INSTALL_PATH)/lib/$(PKGNAME)

VERSION = $(shell grep version package.json | grep -oE '[0-9\.]+')
PKGNAME = $(shell grep name package.json |/bin/grep -o '[^"]*",'|/bin/grep -o '[^",]*')

PANDOC = pandoc -s -t man 
NPM = npm
COFFEE_COMPILE = coffee -c

MKDIR = mkdir -p
MKTEMP = mktemp -d --tmpdir "make-$(PKGNAME)-XXXXXXX"
RM = rm -rf
LN = ln -fsrv
CP = cp -r

BIN_TARGETS = $(shell find src/bin -type f -name "*.*" |sed 's,src/,,'|sed 's,\.[^\.]\+$$,,')
MAN_TARGETS = $(shell find src/man -type f -name "*.md"|sed 's,src/,,'|sed 's,\.md$$,.gz,')
COFFEE_TARGETS = $(shell find src/lib -type f -name "*.coffee"|sed 's,src/,,'|sed 's,\.coffee,\.js,')

.PHONY all: build

build: node_modules lib bin man LICENSE package.json

node_modules: package.json
	$(NPM) install

clean:
	$(RM) bin
	$(RM) lib
	$(RM) man

realclean: clean
	$(RM) node_modules

bin: $(BIN_TARGETS)

bin/%: src/bin/%.*
	@$(MKDIR) bin
	$(CP) $< $@
	chmod a+x $@

man: ${MAN_TARGETS}

man/%.gz : src/man/%.md
	@$(MKDIR) man
	$(PANDOC) $< |gzip > $@

lib: ${COFFEE_TARGETS}

lib/%.js: src/lib/%.coffee
	@$(MKDIR) $(dir $@)
	$(COFFEE_COMPILE) -p -b $^ > $@

install: MANS   = $(shell ls man)
install: build
	$(MKDIR) $(LIBDIR)
	$(CP) -t $(LIBDIR) lib node_modules LICENSE package.json
	$(MKDIR) $(INSTALL_PATH)/share/$(PKGNAME)
	$(CP) -t $(INSTALL_PATH)/share/$(PKGNAME) LICENSE README.md
ifneq ("$(wildcard bin)","")
	$(CP) -t $(LIBDIR) bin
	$(MKDIR) $(INSTALL_PATH)/bin
	cd $(LIBDIR) && $(LN) -t $(INSTALL_PATH)/bin $(wildcard bin/*)
endif
ifneq ("$(wildcard builtin/*)","")
	$(CP) -t $(LIBDIR) builtin
endif
ifneq ("$(wildcard share/*)","")
	$(CP) -t $(INSTALL_PATH) share
endif
ifneq ("$(wildcard etc/*)","")
	$(MKDIR) $(ETC_PATH)
	$(CP) -t $(ETC_PATH) $(wildcard etc/*)
endif
ifneq ("$(wildcard man/*)","")
	$(MKDIR) $(INSTALL_PATH)/share/man/man1
	$(CP) -t $(INSTALL_PATH)/share/man/man1 $(wildcard man/*)
endif

uninstall: TEMPDIR := $(shell $(MKTEMP))
uninstall:
	echo $(TEMPDIR)
	$(RM) $(LIBDIR)
	$(MAKE) DESTDIR=$(TEMPDIR)/ install
	$(RM) $(TEMPDIR)/$(PREFIX)/lib/$(PKGNAME)
	find $(TEMPDIR) -type f -o -type l \
		| sed 's,$(TEMPDIR)/,$(DESTDIR),'\
		| xargs rm
	find $(TEMPDIR) -type d -name "$(PKGNAME)" \
		| sed 's,$(TEMPDIR)/,$(DESTDIR),'\
		| xargs rmdir
	$(RM) $(TEMPDIR)

distclean: clean
	rm -rf $(PKGNAME)-$(VERSION)
	rm -f $(PKGNAME)-$(VERSION).tar.gz
