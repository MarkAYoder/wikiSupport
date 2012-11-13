# $Id: wwwhttp.pl,v 0.14 1994/09/17 10:12:59 fielding Exp fielding $
# ---------------------------------------------------------------------------
# wwwhttp: A package for sending HTTP requests and handling responses for the
#          World-Wide Web.  This package is designed for use by www.pl
#          for handling URL's with the "http" scheme designator.
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# Each routine in this package has been derived from the work of multiple
# authors -- those that are known are listed above the respective routines.
# The routines have been changed substantially, so don't blame them for bugs.
# It is distributed under the Artistic License (included with your Perl
# distribution files).
#
# 13 Jun 1994 (RTF): Initial version 
# 07 Jul 1994 (RTF): Moved require of sys/socket.ph outside of package due to
#                    a bug in perl4 found by Martijn Koster
#                    Fixed error handling in case of problems in eval.
# 19 Jul 1994 (RTF): Fixed nagging warning from perl -w that made no sense.
# 17 Sep 1994 (RTF): Removed unnecessary bind() and host stuff (Jack Shirazi);
#                    Added a bunch of alarm() calls to lessen timeout problems;
#                    Replaces empty paths with "/" (Marc VanHeyningen).
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to the libwww-perl mailing list at <libwww-perl@ics.uci.edu>.
# ---------------------------------------------------------------------------
# Some of these routines are enhanced versions of those distributed by
# Oscar Nierstrasz <oscar@iam.unibe.ch> from IAM, University of Berne. 
# See <ftp://cui.unige.ch/PUBLIC/oscar/scripts/README.html> for more info.
# ===========================================================================
require "wwwerror.pl";
require "socket.ph";

package wwwhttp;

%AllowedMethods = (     # Specify what HTTP request methods are supported
    'GET',        1,    # 1 = Allowed without content in request
    'HEAD',       1,
    'POST',       2,    # 2 = Allowed and with content in request
    'PUT',        2,
    'DELETE',     1,    # 0 = Not allowed (same as undefined)
    'LINK',       1,
    'UNLINK',     1,
    'CHECKIN',    2,
    'CHECKOUT',   1,
    'SHOWMETHOD', 1,
);


# ===========================================================================
# request(): perform an http request for the $object at the HTTP server
#            on the specified $host and $port, giving up after $timeout seconds.
#            Return the HTTP response code along with (as named parameters)
#            the parsed response %headers and document $content.
#
# This is a vastly modified version of Oscar's http'get() dated 28/3/94 in
#      <ftp://cui.unige.ch/PUBLIC/oscar/scripts/http.pl>
# including contributions from Marc van Heyningen and Martijn Koster.
#
sub request
{
    local($method, $host, $port, $object, *headers, *content, $timeout) = @_;
    local($fqdn, $aliases, $addrtype, $len, $thataddr);
    local($reqstr, $hd, $val);

    local($response) = 0;
    local($resphead) = '';

    if (!$AllowedMethods{$method})
    {
        return &wwwerror'onrequest($wwwerror'RC_bad_request_client, $method,
                          'http', $host, $port, $object, *headers, *content,
                          "Library does not allow that method for HTTP");
    }

    if (!$object) { $object = '/'; }  # Trailing slash is optional on URLs,
                                      # but is required for HTTP server root.

    $reqstr = "$method $object HTTP/1.0\r\n";
    foreach $hd (keys(%headers))
    {
        if ($val = $headers{$hd})
        {
            $reqstr .= "$hd: $val\r\n";
        }
    }
    $reqstr .= "\r\n";

    if (!$port) { $port = 80; };   # The default HTTP port is always 80

    if ($host =~ /^\d+\.\d+\.\d+\.\d+$/)
    {
        $thataddr = pack('c4', split(/\./, $host));
    }
    else
    {
        ($fqdn, $aliases, $addrtype, $len, $thataddr) = gethostbyname($host);
        if (!$fqdn)
        {
            return &wwwerror'onrequest($wwwerror'RC_connection_failed, $method,
                         'http', $host, $port, $object, *headers, *content,
                         "Cannot find hostname $host");
        }
    }

    $that = pack('S n a4 x8', &main'AF_INET, $port, $thataddr);
    if (! socket(FS, &main'AF_INET, &main'SOCK_STREAM, 0))
    {
        return &wwwerror'onrequest($wwwerror'RC_connection_failed, $method,
                         'http', $host, $port, $object, *headers, *content,
                         "Failed bind to our local socket: $!");
    }

    local($/);
    $run_it = <<'EOF';
        $SIG{'ALRM'} = "wwwhttp'timed_out";
        alarm($timeout);
        connect(FS, $that) || die "Cannot connect to $host:$port, $! \n";
        alarm($timeout);
        select((select(FS), $| = 1)[0]); # Make FS unbuffered
        print FS $reqstr; 
        if ($AllowedMethods{$method} == 2) { print FS $content; }

        $/ = "\n";
        $_ = <FS>;
        die "No response.\n" unless defined($_);

        $timeout <<= 2;                  # Quadruple timeout after 1st response
        alarm($timeout);
        if (m:^HTTP/\S+\s+(\d+)\s:)      # HTTP/1.0 or better
        {
            $response = $1;
            $headers  = $_;              # pass real headers back to client
            while(<FS>)
            {
                alarm($timeout);
                last if /^[\r\n]+$/;     # end of header
                $resphead .= $_;
                $headers  .= $_;
            }
            undef($/);
            $content = <FS>;
        }
        else                             # old style server reply
        {
            $content = $_;
            $response = $wwwerror'RC_ok; # Assume it is a good response
            undef($/);
            $_ = <FS>;            
            $content .= $_;
        }
        $SIG{'ALRM'} = "IGNORE";
        alarm(0);
EOF

    eval $run_it;
    if ($@)
    {
        $SIG{'ALRM'} = "IGNORE";
        alarm(0);
        close(FS);
        if    ($@ =~ /^Time/o) { $response = $wwwerror'RC_timed_out;         }
        elsif ($@ =~ /^No r/o) { $response = $wwwerror'RC_bad_response;      }
        else                   { $response = $wwwerror'RC_connection_failed; }

        return &wwwerror'onrequest($response, $method, 'http', $host, $port,
                                   $object, *headers, *content, $@);
    }
    close(FS);
    &parseRFC822head($resphead, *headers);
    return $response;
}

sub timed_out { die "Timed Out\n"; }


# ===========================================================================
# parseRFC822head(): Breaks out the headers passed in $head into a %headers
#                    indexed by a lower-cased keyword.  Returns nothing.
#
# This routine is (mostly) from Gene Spafford's <spaf@cs.purdue.EDU>
# ParseMailHeader() routine in the MailStuff package.
#
sub parseRFC822head
{
    local($head, *headers) =  @_;
    return if (!$head);

    local($save1, $keyw, $val, @array);

    $save1 = ($* || 0);
    $* = 1;
    $_ = $head;
    s/\r//g;
    s/\n\s+/ /g;
       
    @array = split('\n');
    foreach $_ (@array)
    {
        ($keyw, $val) = m/^([^:]+):\s*(.*\S)\s*$/g;
        $keyw =~ tr/A-Z/a-z/;
        if (defined($headers{$keyw}))
        {
            $headers{$keyw} .= ", $val";
        }
        else
        {
            $headers{$keyw} = $val;
        }
    }
    $* = $save1;
}


1;
