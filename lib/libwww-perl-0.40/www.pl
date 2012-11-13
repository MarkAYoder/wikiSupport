# $Id: www.pl,v 0.15 1994/08/01 13:32:38 fielding Exp fielding $
# ---------------------------------------------------------------------------
# www.pl: A package for handling requests of any World-Wide Web URL,
#         including requests that should be redirected to a proxy server.
#         This package is the main entry point for the libwww-perl system.
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# Each routine in this package has been derived from the work of multiple
# authors -- those that are known are listed above the respective routines.
# It is distributed under the Artistic License (included with your Perl
# distribution files and with the standard distribution of this package).
#
# The latest version of libwww-perl can always be obtained at:
#
#     <http://www.ics.uci.edu/WebSoft/libwww-perl/>
#
# 13 Jun 1994 (RTF): Initial version 
# 07 Jul 1994 (RTF): Added stat() code from Brooks Cutter.
#                    Updated error messages.
# 20 Jul 1994 (RTF): Added set_def_header() and check_defaults() along with
#                    the DefaultHeaders arrays so that defaults can be set
#                    once by the client and effect all requests.
#                    Changed the request eval to version suggested by Brooks.
# 31 Jul 1994 (RTF): Added get_def_header() and lrequest() (from Brooks).
#                    Removed default headers from the stat() interface.
# 19 Sep 1994 (RTF): Added hostname.pl to satisfy those non-BSD people.
#                    Fixed usage of undefined proxy vars (from Martijn Koster).
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to the libwww-perl mailing list at <libwww-perl@ics.uci.edu>.
# ---------------------------------------------------------------------------
require "hostname.pl";
require "wwwurl.pl";
require "wwwerror.pl";
require "wwwdates.pl";

require "wwwhttp.pl";    # Note that there should eventually be a wwwSCHEME
require "wwwfile.pl";    #    package for each supported protocol scheme.
                         #    Each package must define an %AllowedMethods array
                         #    and a "request" subroutine.
package www;

require "LWP_Changes.pl";     # Imports Library Version Number

# ==========================================================================
# Get the default From address for HTTP requests and add it to defaults.

@DefaultHeaders   = ();
@DefHeaderSchemes = ();
@DefHeaderValues  = ();

$user = ( $ENV{'USER'} || $ENV{'LOGNAME'} || 'unknown' );

&set_def_header('http', 'From', join('@', $user, $hostname'FQDN));

# ==========================================================================

if ($NoProxy = $ENV{'no_proxy'}) { @DontProxy = split(/,/, $NoProxy); }


# ===========================================================================
# ===========================================================================
# request(): perform a WWW request using the passed method, absolute URL,
#            and request headers, and return the resulting response code.
#            The response codes for all protocols mirror those of HTTP. 
#            Also returns as parameters the response $headers, %headers and 
#            document $content.  $timeout is specified in seconds.
#
# This is the primary interface to libwww-perl.  Use the following
# format to request a WWW document:
#
# local($content) = '';
# local($headers) = '';
# local(%headers) = ();
#
# $respcode = &www'request($method, $url, *headers, *content, $timeout);
#
# WHERE, 
#
# $respcode: The three digit response code as defined by HTTP.
#
#   $method: The request method (e.g. 'GET','HEAD','POST',...) Case Significant
#
#      $url: A WWW Uniform Resource Locator in absolute form.
#
#  $headers: (Incoming) Ignored
#            (Returned) The actual headers returned from the network request
#
#  %headers: (Incoming) Request headers for request, e.g.
#                   $headers{'User-Agent'} = "MOMspider/0.1 $www'Library";
#
#            (Returned) Response headers from result (parsed and lower-case),
#                   $headers{'content-type'} = 'text/html';
#
#  $content: (Incoming) Document to send for methods POST, PUT, etc.
#
#            (Returned) Response body from result.
#
#  $timeout: Number of seconds to wait for a server response (usually 30).
#
#
sub request
{
    local($method, $url, *headers, *content, $timeout) = @_;
    local($routine, $allowed, $object, $proxy);

    local($scheme,$host,$port,$path,$query,$frag) = &wwwurl'parse($url);

    $object = &wwwurl'compose('','','',$path,$query,'');

    if (!$scheme)
    {
        return &wwwerror'onrequest($wwwerror'RC_bad_request_client, $method,
                         $scheme, $host, $port, $object, *headers, *content,
                         "URL requested does not have an access scheme");
    }

    if ($proxy = &lookup_proxy($scheme, $host, $port))
    {
        ($scheme,$host,$port,$path,$query,$frag) = &wwwurl'parse($proxy);
        $object = $url;
    }

    $routine =  'www' . $scheme . q/'request/;
    $allowed = '$www' . $scheme . q/'AllowedMethods{$method}/;

    if (!((eval "defined(\&$routine);") && (eval "$allowed;")) )
    {
        return &wwwerror'onrequest($wwwerror'RC_not_implemented_client,
                 $method, $scheme, $host, $port, $object, *headers, *content,
                 "Request method not supported by client library");
    }

    &check_defaults($scheme, *headers);

    if (!$port) { $port = $wwwurl'DefPort{$scheme} };

    return &$routine($method,$host,$port,$object,*headers,*content,$timeout);
}


# ===========================================================================
# set_def_header(): Allow the client to set a default header for a particular
#     protocol scheme.  These headers can be overridden by a header of the
#     same name appearing in the request.  This routine should ONLY be used
#     to set headers which will not change throughout the life of the process.
#      
# Examples:
# 
#     &set_def_header('http', 'From', 'fielding@ics.uci.edu');
#     &set_def_header('http', 'User-Agent', 'MOMspider/1.0');
#
#     Note that if a header called User-Agent is set, this routine will
#     automatically append the current library version to the name given
#     if it has not already been appended.
#
sub set_def_header
{
    local($scheme, $name, $value) = @_;
    local($pos);

    # First, see if one has already been set

    undef $pos;
    for ($[ .. $#DefaultHeaders)
    {
        $pos = $_, last if (($name   eq $DefaultHeaders[$_]) &&
                            ($scheme eq $DefHeaderSchemes[$_]));
    }
    if (!defined($pos)) { $pos = $#DefaultHeaders + 1; }

    if (($name =~ /^User-Agent$/io) && ($value !~ /$Library/o))
    {
        $value .= " $Library";
    }
    $DefaultHeaders[$pos]   = $name;
    $DefHeaderValues[$pos]  = $value;
    $DefHeaderSchemes[$pos] = $scheme;
}


# ===========================================================================
# get_def_header(): Allow the client to get the current default header for
#     a particular.
#      
# Examples:
# 
#     $address = &get_def_header('http', 'From');
#     $agent   = &get_def_header('http', 'User-Agent');
#
#     Returns undefined if the named neader has no default.
#
sub get_def_header
{
    local($scheme, $name) = @_;

    for ($[ .. $#DefaultHeaders)
    {
        return $DefHeaderValues[$_] if (($name   eq $DefaultHeaders[$_]) &&
                                        ($scheme eq $DefHeaderSchemes[$_]));
    }
    return undef;
}


# ===========================================================================
# check_defaults(): Check the header defaults and, if a corresponding value
#     was not set in the request, add the default header to the array.
#      
sub check_defaults
{
    local($scheme, *headers) = @_;

    foreach $idx ($[ .. $#DefaultHeaders)
    {
        next unless ($scheme eq $DefHeaderSchemes[$idx]);
        next if ($headers{$DefaultHeaders[$idx]});
        $headers{$DefaultHeaders[$idx]} = $DefHeaderValues[$idx];
    }
}


# ===========================================================================
# lookup_proxy(): Check to see if an environment variable exists which
#                 indicates that the passed-in scheme should be proxied.
#
#                 The environment variable must be of the form scheme_proxy
#                 and must contain a valid absolute URL for the proxy server.
#
#                 If the "no_proxy" environment variable exists, its contents
#                 (a comma-separated list of domain names with optional ports)
#                 are checked against this URL's host and port.
# Examples:
# 
#      setenv http_proxy "http://firewall.safe.com/"        -- a firewall gate
#      setenv wais_proxy "http://www.ncsa.uiuc.edu:8001/"   -- a wais gateway
#
#      no_proxy="cern.ch,ncsa.uiuc.edu,some.host:8080"; export no_proxy
#
sub lookup_proxy
{
    local($scheme, $host, $port) = @_;

    if ($NoProxy)
    {
        if ($port) { $host .= ":$port"; }
        foreach $domain (@DontProxy)
        {
            return '' if ($host =~ m/$domain$/i);
        }
    }

    local($pcheck) = q/$ENV{'/ . $scheme . q/_proxy'}/;

    return (eval "$pcheck if defined($pcheck);");
}


# ======================================================================
# stat(): Return the status of the passed-in URL.
#         Submitted by Brooks Cutter <bcutter@paradyne.com> 05 Jul 1994
#
# ($response,
#  $last_modified,
#  $content_length,
#  $content_type,
#  $content_transfer_encoding,
#  $content_encoding,
#  $content_language,
#  $expires,
#  $message_id) = &www'stat($url);
#
# WHERE,
#
# Values returned by &www'stat():
#    $response: HTTP numeric response code (see wwwerror.pl for a list)
#    $last_modified: Date last modified in Unix time_t (long) format.
#    $content_length: The length of the $url
#    $content_type: The type of the document
#    $content_transfer_encoding: As in MIME.
#    $content_encoding: if any, then x-compress or x-gzip
#    $content_language: ISO 3316 language code like 'en' for english
#    $expires: If specified, After $expires date retrieved document is invalid
#    $message_id: (globally) Unique identifier for object
#
#    Note:
#    - Values (if any) in the above fields depend on the remote
#      server and document requested.
#    - Additional return values may be added at a later time.
#
# Values passed to &www'stat():
#
#    $url: Fully qualified http: or file: URL
#
# ----------------------------------------------------------------------
# Example: retrieve Last modified and size of What's New with NCSA Mosaic
#
# $url = 'http://www.ncsa.uiuc.edu/SDG/Software/Mosaic/Docs/whats-new.html';
# ($rcode,$lastmod,$size) = (&www'stat($url))[0,1,2];
#
# For more information on the returned headers, see the Hypertext Transfer
# Protocol specification, section "The Response/Response Headers" at the URL
# http://info.cern.ch/hypertext/WWW/Protocols/HTTP/HTTP2.html
#
sub stat
{
    local($url) = @_;

    local($content)       = '';
    local($headers)       = '';
    local(%headers)       = ();
    local($response)      = 0;
    local($last_modified) = 0;

    $response = &request('HEAD', $url, *headers, *content, 30);

    if ($headers{'last-modified'})
    {
        $last_modified = &wwwdates'get_gmtime($headers{'last-modified'})
    }
                
    return(
        $response,
        $last_modified,
        $headers{'content-length'},
        $headers{'content-type'},
        $headers{'content-transfer-encoding'},
        $headers{'content-encoding'},
        $headers{'content-language'},
        $headers{'expires'},
        $headers{'message-id'},
    );
}


# ===========================================================================
# lrequest(): Same as request() above except that if a redirect response is
#             returned, perform an automatic redirection by requesting the
#             new URL.  To avoid an infinite loop, this routine will only
#             perform up to 10 redirections on one request.
#             Originally submitted by Brooks Cutter, with mods by Roy Fielding.
#
# Use the following format to request a WWW document:
#
# $respcode = &www'lrequest($method, *url, *headers, *content, $timeout);
#
# WHERE, 
#
# $respcode: The three digit response code as defined by HTTP.
#
#   $method: The request method (e.g. 'GET','HEAD','POST',...) Case Significant
#
#      $url: A WWW Uniform Resource Locator in absolute form.  If the request 
#            is redirected, $url will be changed to reflect the new URL.
#
#  $headers: (Incoming) Ignored
#            (Returned) The actual headers returned from the last net request
#
#  %headers: (Incoming) Request headers for request, e.g.
#                   $headers{'User-Agent'} = "MOMspider/0.1 $www'Library";
#
#            (Returned) Response headers from result (in lower-case), e.g.
#                   $headers{'content-type'} = 'text/html';
#
#  $content: (Incoming) Document to send for methods POST, PUT, etc.
#
#            (Returned) Response body from result.
#
#  $timeout: Number of seconds to wait for a server response (usually 30).
#
#
sub lrequest
{
    local($method, *url, *headers, *content, $timeout) = @_;
    local($hd, $response);

    foreach $idx (1 .. 10) 
    {
        $response = &request($method, $url, *headers, *content, $timeout);
        last unless ($response =~ /^30[12]$/);
        last if ($idx == 10);

        if ($url = $headers{'location'})
        {
              $url =~ s/, .*//;         # Get rid of multiple Location: entries
        }
        elsif ($url = $headers{'uri'})
        {
              $url =~ s/\s*;\s+.*//;
              $url =~ s/, .*//;         # Get rid of any multiple URI: entries
        }
        else { last; }

        foreach $hd (keys(%headers))
        {
            next if ($hd =~ m#^[A-Z]#);
            delete $headers{$hd};
        }
        $headers = '';
    }
    return($response);
}

# ===========================================================================

1;
