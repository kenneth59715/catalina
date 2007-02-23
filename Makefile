TAR=/bin/tar
ECHO=/bin/echo
RM=/bin/rm -f
LS=/bin/ls
CAT=/bin/cat
CP=/bin/cp
MD5SUM=/usr/bin/md5sum
DATE=/bin/date
AWK=/usr/bin/awk
GZIP=/usr/bin/gzip
LN=/bin/ln
MD5SUM=/usr/bin/md5sum
FTP_SITE_PATH=/misc/ftp/pub/sdsc/system/catalina
WEB_SITE_PATH=/misc/www/server/catalina
TIMESTAMP=`$(DATE) +%Y%m%d` 
CATALINA=catalina
DISTFILE=dist.tar

all:
	@ $(ECHO) "To modify any file:"
	@ $(ECHO) "	/usr/local/bin/co -l <filename>"
	@ $(ECHO) "	vi <filename>"
	@ $(ECHO) "	/usr/local/bin/ci -u <filename>"
	@ $(ECHO) "To create a tar distribution:"
	@ $(ECHO) "	make dist"
	@ $(ECHO) "This will create the file dist.tar"
	@ $(ECHO) "To install a test instance:"
	@ $(ECHO) "	cd <test directory>"
	@ $(ECHO) "	tar xf <path to tar file>"
	@ $(ECHO) "	cd catalina"
	@ $(ECHO) "Read the README file for install directions"

dist: clean
	if \
		test -e $(DISTFILE) ; \
	then \
		$(RM) $(DISTFILE) ; \
	fi
	if \
		test -e DATESTAMP ; \
	then \
		$(RM) DATESTAMP ; \
	fi
	if \
		test -e MANIFEST ; \
	then \
		$(RM) MANIFEST ; \
	fi
	if \
		test -e VERSIONHASH ; \
	then \
		$(RM) VERSIONHASH ; \
	fi
	$(DATE) +%Y%m%d > DATESTAMP
	$(LS) | grep -v ^MANIFEST$$ | grep -v ^dist.tar$$ | grep -v ^RCS$$  | grep -v ^VERSIONHASH$$ > MANIFEST
	$(CAT) `$(CAT) MANIFEST` | $(MD5SUM) | $(AWK) '{print $$1}' > VERSIONHASH
	cd .. ; $(TAR) cf $(CATALINA)/dist.tar --exclude Makefile --exclude RCS $(CATALINA)
	@ $(ECHO) "Packing $(DISTFILE) into $(DISTFILE).gz "
	$(GZIP) $(DISTFILE)
	@ $(ECHO) "** Moving $(DISTFILE).gz to FTP server **"
	@ $(ECHO) "Removing old symlink catalina.tar.gz"
	$(RM) $(FTP_SITE_PATH)/catalina.tar.gz
	@ $(ECHO) "Copying $(DISTFILE).gz to $(FTP_SITE_PATH)"
	$(CP) $(DISTFILE).gz $(FTP_SITE_PATH)/
	@ $(ECHO) "Copying $(DISTFILE).gz to catalina.`date +%Y%m%d%H%M`.tar.gz"	
	cd $(FTP_SITE_PATH) ; $(CP) $(DISTFILE).gz catalina.`date +%Y%m%d%H%M`.tar.gz
	@ $(ECHO) "Linking Catalina.tar.gz to dist.tar.gz"
	cd $(FTP_SITE_PATH) ; $(LN) -s $(DISTFILE).gz catalina.tar.gz
	@ $(ECHO) "** Moving $(DISTFILE).gz to FTP server **.... done"
	@ $(ECHO) "Now, go to $(WEB_SITE_PATH), edit index.html. Add the changes as before."
	@ $(ECHO) "The MD5SUM for this build is: `$(MD5SUM) $(DISTFILE).gz`"	
	@ $(ECHO) "Completed"
clean:
	- $(RM) $(DISTFILE)
	- $(RM) $(DISTFILE).gz
