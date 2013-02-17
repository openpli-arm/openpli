#!/usr/bin/make -f
# target platform: dm7025, dm800, dm8000, vuduo, dm500hd, dm800se, et9000
MACHINE ?= dm800
BUILDDIR = build-${MACHINE}
# for a list of some other repositories have
# a look at http://git.opendreambox.org/
GIT_URL = https://github.com/openpli-arm/openembedded.git
GIT_BRANCH = master
BITBAKE_BRANCH = senbox
TOOLCHAIN_NAME = gcc-4.5.2_glibc
TOOLCHAIN_FULL_NAME = gcc-4.5.2_glibc.tar.bz2
TOOLCHAIN_URL = https://www.dropbox.com/s/8umac1s9wr8n2fz/$(TOOLCHAIN_FULL_NAME)
# in case you want to send pull requests or generate patches
#GIT_AUTHOR_NAME ?= Your Name
#GIT_AUTHOR_EMAIL ?= you@example.com
# you should not need to change anything below

GIT = git
PWD := $(shell pwd)
OE_BASE = $(PWD)
all: initialize
	@echo
	@echo "<--------------------------openpli-2.0-------------------------------->"
	@echo "Openembedded for the OpenPLi 2.0 environment has been initialized"
	@echo "properly. Now you can start building your image, by doing either:"
	@echo
	@echo " make image"
	@echo "	or"
	@echo " cd $(BUILDDIR) ; source env.source ; bitbake openpli-enigma2-image"
	@echo
	@echo "and after 'some time' you should find your image (.tar.gz or jffs2) in"
	@echo "$(BUILDDIR)/tmp/deploy/images/"
	@echo
	@echo "Notice: You can reuse your sources directory by creating a soft link:"
	@echo " rm -r sources"
	@echo " ln -s YOUR_SOURCES_PATH sources"
bitbake:
	$(GIT) clone -b $(BITBAKE_BRANCH) https://github.com/openpli-arm/bitbake.git
	cd bitbake && ( \
		python setup.py build ;\
	)
.PHONY: image initialize openembedded-update openembedded-update-all
#image: initialize openembedded-update
image: initialize 
	cd $(OE_BASE)/${BUILDDIR}; . ./env.source; bitbake openpli-enigma2-image
initialize: $(OE_BASE)/cache sources $(OE_BASE)/${BUILDDIR} $(OE_BASE)/${BUILDDIR}/conf \
	$(OE_BASE)/${BUILDDIR}/tmp $(OE_BASE)/${BUILDDIR}/conf/local.conf \
	$(OE_BASE)/${BUILDDIR}/env.source bitbake $(OE_BASE)/openembedded \
	$(OE_BASE)/tools/$(TOOLCHAIN_NAME)
openembedded-update: $(OE_BASE)/openembedded
	cd $(OE_BASE)/openembedded && $(GIT) pull origin $(GIT_BRANCH)
$(OE_BASE)/${BUILDDIR} $(OE_BASE)/${BUILDDIR}/conf $(OE_BASE)/${BUILDDIR}/tmp $(OE_BASE)/cache sources:
	mkdir -p $@
$(OE_BASE)/${BUILDDIR}/conf/local.conf:
	echo 'OE_BASE = "$(PWD)"' > $@
	echo 'DL_DIR = "$(PWD)/sources"' >> $@
	echo 'BBFILES = "$${OE_BASE}/local/recipes/*/*.bb $${OE_BASE}/openembedded/recipes/*/*.bb"' >> $@
	echo '# BBMASK = "(nslu.*|.*-sdk.*|opie-.*|gpe-*)"' >> $@
	echo 'BBFILE_COLLECTIONS = "overlay"' >> $@
	echo 'BBFILE_PATTERN_overlay = "$${OE_BASE}/local"' >> $@
	echo 'BBFILE_PRIORITY_overlay = 5' >> $@
	echo 'MACHINE = "$(MACHINE)"' >> $@
	echo 'TARGET_ARCH = "arm"' >> $@
	echo 'TARGET_FPU = "hard"' >> $@
	echo 'TARGET_OS = "linux-gnueabi"' >> $@
	echo 'DISTRO = "openpli"' >> $@
	echo 'CACHE = "$${OE_BASE}/cache/oe-cache.$${USER}.$${MACHINE}"' >> $@
	echo 'BB_NUMBER_THREADS = "2"' >> $@
	echo 'PARALLEL_MAKE = "-j4"' >> $@
	echo '#BB_SRCREV_POLICY = "cache"' >> $@
	echo 'TOPDIR = "$${OE_BASE}/build-$${MACHINE}"' >> $@
	echo 'IMAGE_KEEPROOTFS = "0"' >> $@
	echo 'IMAGE_FSTYPES = "tar.gz jffs2"' >> $@
	echo 'OE_ALLOW_INSECURE_DOWNLOADS = "1"' >> $@
	echo 'TOOLCHAIN_VENDOR = "-cortex"' >> $@
	echo 'TOOLCHAIN_TYPE = "external"' >> $@
	echo 'TOOLCHAIN_BRAND = "trident"' >> $@
	echo 'TOOLCHAIN_PATH = "$${OE_BASE}/tools/${TOOLCHAIN_NAME}"' >> $@
	echo 'PREFERRED_PROVIDER_virtual/kernel = "linux-su980"' >> $@

$(OE_BASE)/${BUILDDIR}/env.source:
	echo 'OE_BASE=$(OE_BASE)' > $@
	echo 'MACHINE="$(MACHINE)"' >> $@
	echo 'export BBPATH="$${OE_BASE}/local/:$${OE_BASE}/openembedded/:$${OE_BASE}/bitbake/:$${OE_BASE}/build-$${MACHINE}/"' >> $@
	echo 'PATH=$${OE_BASE}/bitbake/bin:$${OE_BASE}/tools/${TOOLCHAIN_NAME}/bin:$${PATH}' >> $@
	echo 'export PATH' >> $@
	echo 'export LD_LIBRARY_PATH=' >> $@
	echo 'export LANG=C' >> $@
	echo 'export CVS_RSH=ssh' >> $@
	echo 'umask 0022' >> $@
$(OE_BASE)/openembedded: $(OE_BASE)/openembedded/.git
$(OE_BASE)/openembedded/.git:
	$(GIT) clone -b $(GIT_BRANCH) $(GIT_URL) $(OE_BASE)/openembedded
	cd $(OE_BASE)/openembedded && ( \
		if [ -n "$(GIT_AUTHOR_EMAIL)" ]; then git config user.email "$(GIT_AUTHOR_EMAIL)"; fi; \
		if [ -n "$(GIT_AUTHOR_NAME)" ]; then git config user.name "$(GIT_AUTHOR_NAME)"; fi; \
	)

$(OE_BASE)/tools/$(TOOLCHAIN_NAME):
	mkdir -p $(OE_BASE)/tools
	cd $(OE_BASE)/tools/ &&\
	echo "Download toolchain ..." &&\
	wget $(TOOLCHAIN_URL) &&\
	echo "Extract toolchain ..." &&\
	tar -xvjf ${TOOLCHAIN_FULL_NAME}

