####### Makefile for openwattson - manually generated
#
# All user parameters are stored in a config file
# Default locations are 
# 1. Path to config file including filename given as parameter
# 2. ./openwattson.conf
# 3. /usr/local/etc/openwattson.conf
# 4. /etc/openwattson.conf
#
# This makefile is made for Linux.
# No Windows version yet
#
# You may want to adjust the 3 directories below

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin

#########################################

CC  = gcc
OBJ = linuxwattson.o rwwattson.o 
FETCH_OBJ = fetchwattson.o $(OBJ)
LOG_OBJ = logwattson.o $(OBJ)
DBLOG_OBJ = mysqllogwattson.o $(OBJ)
GET_POWER_OBJ = getpower.o $(OBJ)
GET_GEN_OBJ = getgen.o $(OBJ)
GET_CONF_OBJ = getconf.o $(OBJ)


VERSION = 0.2
HTML_DIR = ../html_openwattson

MYSQL_FLAGS = $(shell mysql_config --libs --cflags)

CFLAGS = -Wall -O3 -DVERSION=\"$(VERSION)\" $(MYSQL_FLAGS)
CC_LDFLAGS = -lm
CC_WINFLAG = 
# For Windows - comment the two line above and un-comment the two lines below.
#CC_LDFLAGS = -lm -lwsock32
#CC_WINFLAG = -mwindows
INSTALL = install
#MYSQL_FLAGS = -I/usr/include/mysql -DBIG_JOINS=1 -fno-strict-aliasing -g
#MYSQL_LIBS = -L/usr/lib/arm-linux-gnueabihf -lmysqlclient -lpthread -lz -lm -lrt -ldl

####### Build rules

all: fetchwattson logwattson mysqllogwattson getpower getgen getconf
	
fetchwattson : $(FETCH_OBJ)
	$(CC) $(CFLAGS) -o $@ $(FETCH_OBJ) $(CC_LDFLAGS)

logwattson : $(LOG_OBJ)
	$(CC) $(CFLAGS) -o $@ $(LOG_OBJ) $(CC_LDFLAGS)

mysqllogwattson : $(DBLOG_OBJ)
	$(CC) $(CFLAGS) -o $@ $(DBLOG_OBJ) $(CC_LDFLAGS)

getpower : $(GET_POWER_OBJ)
	$(CC) $(CFLAGS) -o $@ $(GET_POWER_OBJ) $(CC_LDFLAGS)

getgen : $(GET_GEN_OBJ)
	$(CC) $(CFLAGS) -o $@ $(GET_GEN_OBJ) $(CC_LDFLAGS)

getconf : $(GET_CONF_OBJ)
	$(CC) $(CFLAGS) -o $@ $(GET_CONF_OBJ) $(CC_LDFLAGS)

install:
	mkdir -p $(bindir)
	$(INSTALL) fetchwattson $(bindir)
	$(INSTALL) logwattson $(bindir)
	$(INSTALL) mysqllogwattson $(bindir)
	$(INSTALL) getpower $(bindir)
	$(INSTALL) getgen $(bindir)
	$(INSTALL) getconf $(bindir)
	
uninstall:
	rm -f $(bindir)/fetchwattson $(bindir)/logwattson $(bindir)/mysqllogwattson $(bindir)/getpower $(binddir)/getgen $(binddir)/getconf

clean:
	rm -rf *~ *.o fetchwattson logwattson mysqllogwattson getpower getgen getconf

cleanexe:
	rm -f *~ *.o fetchwattson.exe logwattson.exe mysqllogwattson.exe getpower.exe getgen.exe getconf.exe

tarball: clean
	mkdir -p $(HTML_DIR)
	tar -cf $(HTML_DIR)/openwattson-$(VERSION).tar ../openwattson 
	gzip -9 $(HTML_DIR)/openwattson-$(VERSION).tar 
	cp -u README $(HTML_DIR)/
	cp -u INSTALL $(HTML_DIR)/
	cp -u COPYING $(HTML_DIR)/

