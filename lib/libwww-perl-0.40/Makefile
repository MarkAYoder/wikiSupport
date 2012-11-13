# $Id: Makefile,v 1.1 1994/09/19 12:06:37 fielding Exp $
#
# This Makefile is used to configure the perl scripts so that
# they all use the correct pathname for the perl interpreter.
# It also makes the programs executable and creates links from "get"
# to the other commonly-used methods.  Use the following commands:
#
#     % make
#     % make config
#
# You should only need to change the following line to the full pathname
# of your perl interpreter (if it happens to be "/usr/public/bin/perl",
# you do not need to do a "make config").

PERLBIN = /usr/local/gnu/bin/perl

# The rest should be automatic

OLDPERL = /usr/public/bin/perl
CC      = gcc
CLIENTS = get testbot testdates testescapes testlinks

all:
	chmod 755 $(CLIENTS)
	ln -s get HEAD
	ln -s get POST

config:
	$(PERLBIN) -pi.orig -e 's#$(OLDPERL)#$(PERLBIN)#o' $(CLIENTS)

#
# Now this part is only used if you are having problems with sockets
# on non-BSD systems.  It just compiles the test program.
#

socket: sys_socket_ph.c
	$(CC) -o sys_socket_ph sys_socket_ph.c

#
# Use only for cleaning up after a bad config
#

clean:
	rm -f HEAD POST
	$(PERLBIN) -pi.orig -e 's#$(PERLBIN)#$(OLDPERL)#o' $(CLIENTS)
