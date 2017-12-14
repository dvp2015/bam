# install directories
INSTALL_PREFIX = /usr
INSTALL_BINDIR = $(INSTALL_PREFIX)/bin


# toolchain
PKG_CONFIG ?= pkg-config
PYTHON ?= python2
LUA ?= lua53
# flags
LUA_LIBS := $(shell $(PKG_CONFIG) --libs $(LUA) 2>/dev/null || echo "-llua")
LIBS += -lm -lpthread $(LUA_LIBS) -ldl
LUA_CFLAGS := $(shell $(PKG_CONFIG) --cflags $(LUA) 2>/dev/null || echo "-I/usr/include/lua")
CFLAGS += $(LUA_CFLAGS)


# objects
TARGETS = bam
BAM_OBJ = $(patsubst %.c,%.o,$(wildcard src/*.c))
TXT2C_LUA = $(wildcard src/*.lua)


# make rules
all: check_config $(TARGETS)

check_config:
	@echo "====="
	@echo "$(PKG_CONFIG) $(LUA)"
	@echo "$(shell $(PKG_CONFIG) --libs $(LUA) 2>/dev/null)"
	@echo "$(shell $(PKG_CONFIG) --libs $(LUA))"
	@echo "-----"

src/tools/txt2c: src/tools/txt2c.c

src/internal_base.h: src/tools/txt2c $(TXT2C_LUA)
	src/tools/txt2c $(TXT2C_LUA) > src/internal_base.h

src/main.o: src/internal_base.h src/main.c

bam: $(BAM_OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(BAM_OBJ) $(LIBS)

test: $(TARGETS)
	$(PYTHON) scripts/test.py

install: bam
	install -d "$(DESTDIR)$(INSTALL_BINDIR)"
	install -m755 bam "$(DESTDIR)$(INSTALL_BINDIR)"/bam

clean:
	rm -f $(BAM_OBJ) $(TARGETS) src/internal_base.h src/tools/txt2c


.PHONY: all test install clean check_config

