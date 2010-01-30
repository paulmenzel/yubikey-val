# Written by Simon Josefsson <simon@josefsson.org>.
# Copyright (c) 2009, 2010 Yubico AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

VERSION = 2.1
PACKAGE = yubikey-val
CODE = Makefile NEWS ykval-api.html ykval-common.php ykval-config.php	\
	ykval-db.php ykval-db.sql ykval-export.php ykval-import.php	\
	ykval-log.php ykval-ping.php ykval-queue.php ykval-synclib.php	\
	ykval-sync.php ykval-verify.php
DOCS = doc/Installation.wiki doc/ClientInfoFormat.wiki			\
	doc/ServerReplicationProtocol.wiki doc/Troubleshooting.wiki

all:
	@echo "Try 'make install' or 'make symlink'."
	@echo "Docs: http://code.google.com/p/$(PROJECT)/wiki/Installation"
	@exit 1

# Installation rules.

etcprefix = /etc/ykval
sbinprefix = /usr/sbin
phpprefix = /usr/share/ykval
docprefix = /usr/share/doc/ykval
wwwgroup = www-data

install:
	install -D ykval-verify.php $(phpprefix)/ykval-verify.php
	install -D ykval-common.php $(phpprefix)/ykval-common.php
	install -D ykval-synclib.php $(phpprefix)/ykval-synclib.php
	install -D ykval-sync.php $(phpprefix)/ykval-sync.php
	install -D ykval-db.php $(phpprefix)/ykval-db.php
	install -D ykval-log.php $(phpprefix)/ykval-log.php
	install -D ykval-queue.php $(sbinprefix)/ykval-queue
	install -D ykval-export.php $(sbinprefix)/ykval-export
	install -D ykval-import.php $(sbinprefix)/ykval-import
	install -D --backup --mode 640 --group $(wwwgroup) ykval-config.php $(etcprefix)/ykval-config.php
	install -D ykval-db.sql $(docprefix)/ykval-db.sql
	install -D $(DOCS) $(docprefix)/

wwwprefix = /var/www/wsapi

symlink:
	install -d $(wwwprefix)/2.0
	ln -sf $(phpprefix)/ykval-verify.php $(wwwprefix)/2.0/verify.php
	ln -sf $(phpprefix)/ykval-sync.php $(wwwprefix)/2.0/sync.php
	ln -sf 2.0/verify.php $(wwwprefix)/verify.php

# Maintainer rules.

PROJECT=yubikey-val-server-php
USER=simon75j
KEYID=B9156397

$(PACKAGE)-$(VERSION).tgz: $(FILES)
	mkdir $(PACKAGE)-$(VERSION) $(PACKAGE)-$(VERSION)/doc
	cp $(CODE) $(PACKAGE)-$(VERSION)/
	cp $(DOCS) $(PACKAGE)-$(VERSION)/doc/
	tar cfz $(PACKAGE)-$(VERSION).tgz $(PACKAGE)-$(VERSION)
	rm -rf $(PACKAGE)-$(VERSION)

dist: $(PACKAGE)-$(VERSION).tgz

clean:
	rm -f *~
	rm -rf $(PACKAGE)-$(VERSION)

release: dist
	gpg --detach-sign --default-key $(KEYID) $(PACKAGE)-$(VERSION).tgz
	gpg --verify $(PACKAGE)-$(VERSION).tgz.sig
	svn copy https://$(PROJECT).googlecode.com/svn/trunk/ \
	 https://$(PROJECT).googlecode.com/svn/tags/$(PACKAGE)-$(VERSION) \
	 -m "Tagging the $(VERSION) release of the $(PACKAGE) project."
	googlecode_upload.py -s "OpenPGP signature for $(PACKAGE) $(VERSION)." \
	 -p $(PROJECT) -u $(USER) $(PACKAGE)-$(VERSION).tgz.sig
	googlecode_upload.py -s "$(PACKAGE) $(VERSION)." \
	 -p $(PROJECT) -u $(USER) $(PACKAGE)-$(VERSION).tgz 
