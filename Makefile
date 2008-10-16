SVN=/usr/local/apps/subversion-1.4.3/bin/svn
CHMOD=/bin/chmod
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
TIMESTAMP=`$(DATE) +%Y%m%d%H%M` 
CATALINA=catalina
DISTFILE=dist.tar
#TEMP_DIR_OUT=build-`$(DATE) +%Y%m%d`
TEMP_DIR_OUT=build-catalina
TEMP_DIR=$(TEMP_DIR_OUT)
REPO_LOCATION=file:///projects/sysint/admin/sdsc/dev/sched/svn/repository/catalina

all:

dist: clean
	@ if \
		test -e $(TEMP_DIR) ; \
	then \
		$(ECHO) "This directory already exist. Please check $(TEMP_DIR), empty it and rerun"; \
		exit 1; \
	else \
		mkdir $(TEMP_DIR); \
	fi
	
	@ $(ECHO) "Downloading files from SVN .."  
	@ mkdir -p $(TEMP_DIR)/$(CATALINA); cd $(TEMP_DIR)/$(CATALINA); \
	$(SVN) cat $(REPO_LOCATION)/MANIFEST > MANIFEST; for i in `$(CAT) MANIFEST`; do $(SVN) cat $(REPO_LOCATION)/$$i > $$i; done; $(CHMOD) ugo+x conf.sh
	@ $(ECHO) "done"

	@ $(ECHO) "Creating DATESTAMP file .."	
	@ cd $(TEMP_DIR)/$(CATALINA); $(ECHO) $(TIMESTAMP) > DATESTAMP
	@ $(ECHO) "done"

	#@ $(ECHO) "Creating MANIFEST file .."	
	#@ cd $(TEMP_DIR)/$(CATALINA); $(LS) | grep -v ^MANIFEST$$ | grep -v ^dist.tar$$ | grep -v ^RCS$$  | grep -v ^VERSIONHASH$$ > MANIFEST
	#@ $(ECHO) "done"
	
	@ $(ECHO) "Creating VERSIONHASH file .."
	cd $(TEMP_DIR)/$(CATALINA); $(CAT) `$(CAT) MANIFEST` | $(MD5SUM) | $(AWK) '{print $$1}' > VERSIONHASH
	@ $(ECHO) "done"

	@ $(ECHO) "Tarring everything up .."	
	@ cd $(TEMP_DIR); $(TAR) cf dist.tar --exclude Makefile --exclude RCS --exclude .svn  $(CATALINA)
	@ $(ECHO) "done"

	@ $(ECHO) "Packing $(DISTFILE) into $(DISTFILE).gz "
	@ cd $(TEMP_DIR); $(GZIP) $(DISTFILE)
	
release:
	@ $(ECHO) "** Moving $(DISTFILE).gz to FTP server **"

	@ $(ECHO) "Copying $(DISTFILE).gz file from build dir to cwd"
	@ $(CP) $(TEMP_DIR)/$(DISTFILE).gz .
	
	@ $(ECHO) "Removing old symlink catalina.tar.gz"
	$(RM) $(FTP_SITE_PATH)/catalina.tar.gz
	
	@ $(ECHO) "Copying $(DISTFILE).gz to $(FTP_SITE_PATH)"
	$(CP) $(DISTFILE).gz $(FTP_SITE_PATH)/
	@ $(ECHO) "Copying $(DISTFILE).gz to catalina.`$(CAT) $(TEMP_DIR)/$(CATALINA)/DATESTAMP`.tar.gz"	
	$(CP) $(FTP_SITE_PATH)/$(DISTFILE).gz $(FTP_SITE_PATH)/catalina.`$(CAT) $(TEMP_DIR)/$(CATALINA)/DATESTAMP`.tar.gz
	@ $(ECHO) "Linking Catalina.tar.gz to dist.tar.gz"
	cd $(FTP_SITE_PATH) ; $(LN) -s $(DISTFILE).gz catalina.tar.gz
	@ $(ECHO) "** Moving $(DISTFILE).gz to FTP server **.... done"
	@ $(ECHO) "Now, go to $(WEB_SITE_PATH), edit index.html. Add the changes as before."
	@ $(ECHO) "The MD5SUM for this build is: `$(MD5SUM) $(DISTFILE).gz`"	
	@ $(ECHO) "Completed"
clean:
	- @$(RM) $(DISTFILE)
	- @$(RM) $(DISTFILE).gz
	- @$(RM) -rf ./$(TEMP_DIR)
