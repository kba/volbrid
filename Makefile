DESTDIR = /

clean:
	rm -rf lib

install:
	npm install --unsafe-perm --prefix=$(DESTDIR) -g
