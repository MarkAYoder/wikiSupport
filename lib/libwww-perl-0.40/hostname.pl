# $Id$
# ---------------------------------------------------------------------------
# hostname.pl: A package for getting the fully-qualified domain name (FQDN)
#              of the operating host machine.  This is used for From: and
#              Reply-To: addresses sent to other (possibly distant) machines.
#
# Usage:   require "hostname.pl";
#          $my_name = $hostname'FQDN;
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# It is distributed under the Artistic License (included with your Perl
# distribution files and with the standard distribution of this package).
#
# 17 Sep 1994 (RTF): Initial version
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to the libwww-perl mailing list at <libwww-perl@ics.uci.edu>.
# ---------------------------------------------------------------------------

package hostname;

chop($host = `hostname`);            # The preferred BSD method
if (!$host)
{
    chop($host = `uuname -l`);       # The UUCP method (very old, but not dumb)
    if (!$host)
    {
        chop($host = `uname -n`);    # The POSIX method (very dumb)
        if (!$host)
        {
            $host = $ENV{'HOST'} ||  # The desperation method
                    $ENV{'host'} ||
                    die "Can't find the hostname for this machine, stopped";
        }
    }
}

if (index($host,'.') == -1)          # Is it not fully-quallified?
{
    ($FQDN, $aliases, $addrtype, $len, @addrs) = gethostbyname($host);
    if (!$FQDN) { die "Unknown host $host, stopped"; }
}
else { $FQDN = $host; }

# ==================
# print $FQDN, "\n";   # Uncomment for testing via "perl hostname.pl"
  
1;
