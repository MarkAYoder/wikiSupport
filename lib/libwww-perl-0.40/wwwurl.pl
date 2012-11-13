# $Id: wwwurl.pl,v 0.14 1994/08/01 13:30:59 fielding Exp fielding $
# ---------------------------------------------------------------------------
# wwwurl: A package for parsing and manipulating World-Wide Web
#         Uniform Resource Locators (URL).
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# It is distributed under the Artistic License (included with your Perl
# distribution files).
#
# 13 Jun 1994 (RTF): Initial version
# 17 Jun 1994 (RTF): Fixed double-relative URL handling (e.g. ../../)
# 06 Jul 1994 (RTF): Fixed bug parsing URLs with an empty path and added
#                    fallback code for undefined associative array entries.
#                    Replaced complicated unescape loop with a simple
#                    substitute (from Steven E. Brenner via Brooks Cutter).
#                    Added escape() routine (w/mods) from Brooks Cutter.
# 16 Jul 1994 (RTF): Added get_site() routine.
# 27 Jul 1994 (RTF): Firmed-up algorithm for parsing relative URLs, fixing
#                    several potential (but unlikely) bugs in the process.
#                    Removed any hint of "URL:" prefix.
# 17 Sep 1994 (RTF): Renamed parsing sets to match IETF draft and changed
#                    how they are tested to use bitmap masks;
#                    Modified parsing algorithm to use new sets;
#                    Parser now handles URLs like http://host:/ and uses
#                    the leftmost "?" as the start of query info;
#                    Added caching of base URL components so that they don't
#                    get re-parsed for every URL in a document.
#                    Allowed lowercase hex digits in unescape.
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to the libwww-perl mailing list at <libwww-perl@ics.uci.edu>.
# ---------------------------------------------------------------------------

package wwwurl;

%DefPort = (             # Define the default ports for major net services
    'ftp',        21,
    'file',        0,    # note: non-local file URLs are changed to ftp URLs
    'telnet',     23,
    'whois',      43,
    'gopher',     70,
    'finger',     79,
    'http',       80,
    'nntp',      119,
    'news',      119,
    'wais',      210,
    'webster',   765,
    'prospero', 1525,    # I thought it was 191, but IETF differs
);

# ===========================================================================
# The following six categories are bitmap masks for determining membership
# in the corresponding URL syntactic set, as per the IETF/URI working group
# draft specification for Relative URLs <draft-ietf-uri-relative-url-00.txt>.

$UsesRelative    = 1;
$UsesNetloc      = 2;
$NonHierarchical = 4;
$UsesParams      = 8;
$UsesQuery       = 16;
$UsesFragment    = 32;

%InSet = (      # Define scheme membership in each category
    '',         ($UsesRelative | $UsesNetloc | $UsesFragment | $UsesQuery),
    'http',     ($UsesRelative | $UsesNetloc | $UsesFragment | $UsesQuery),
    'file',     ($UsesRelative | $UsesNetloc | $UsesFragment),
    'ftp',      ($UsesRelative | $UsesNetloc | $UsesFragment | $UsesParams),
    'prospero', ($UsesRelative | $UsesNetloc | $UsesFragment | $UsesParams),
    'nntp',     ($UsesRelative | $UsesNetloc | $UsesFragment),
    'gopher',   ($UsesRelative | $UsesNetloc | $NonHierarchical |
                 $UsesFragment),
    'wais',     ($UsesRelative | $UsesNetloc | $NonHierarchical | $UsesQuery | 
                 $UsesFragment),
    'mailto',   ($NonHierarchical),
    'news',     ($NonHierarchical | $UsesFragment),
    'finger',   ($UsesNetloc | $NonHierarchical | $UsesFragment),
    'whois',    ($UsesNetloc | $NonHierarchical | $UsesFragment),
    'webster',  ($UsesNetloc | $NonHierarchical | $UsesFragment),
    'telnet',   ($UsesNetloc | $NonHierarchical),
    'rlogin',   ($UsesNetloc | $NonHierarchical),
    'tn3270',   ($UsesNetloc | $NonHierarchical),
);

# ===========================================================================
# The following package globals are used to cache the last Base URL parsed.

$Burl   = '';
$Bsch   = '';
$Baddr  = '';
$Bport  = '';
$Bpath  = '';
$Bquery = '';
$Bfrag  = '';
$Bmem   = 0;


# ===========================================================================
# ===========================================================================
# parse(): Parse the given URL into its component parts according to
#          WWW URI rules, returning '' for those that are not present. 
#          If no scheme is given, the URL is parsed according to HTTP rules,
#          so schemes which use different rules may have to recombine parts.
#
#     Returns the folowing in order:
#
#             $scheme : The access scheme (converted to lower case);
#             $address: The login or hostname/IP address (if appropriate);
#             $port   : The TCP port (if appropriate);
#             $path   : The object path (plus any params);
#             $query  : The post-'?' search info (if scheme uses queries);
#             $frag   : The post-'#' fragment identifier (if uses fragments).
#             
sub parse
{
    local($url)     = @_;
    local($scheme)  = '';
    local($address) = '';
    local($port)    = '';
    local($path)    = '';
    local($query)   = '';
    local($frag)    = '';

    if ($url =~ s#^([.+\-\w]+):##)
    {
        $scheme = $1;
        $scheme =~ tr/A-Z/a-z/;
    }

    local($member) = $InSet{$scheme} || 0;

    if ($member & $UsesFragment)
    {
        if ($url =~ s/#([^#]*)$//) { $frag = $1; }
    }

    if (($member & $UsesNetloc) && ($url =~ m#^//#o))
    {
        $url =~ s#^//([^/]*)##;
        $address = $1;
        if ($address =~ s/:(\d*)$//)
        {
            $port = $1;
        }
    }

    if ($member & $UsesQuery)
    {
        if ($url =~ s/\?(.*)$//) { $query = $1; }
    }

    $path = $url;

    return ($scheme, $address, $port, $path, $query, $frag);
}


# ===========================================================================
# compose(): Recombine the given component parts into a URL string.
#
#     The following in components may be passed in:
#
#             $scheme : The access scheme;
#             $address: The hostname/IP address;
#             $port   : The TCP port;
#             $path   : The object path (plus any params);
#             $query  : The post-? search info
#             $frag   : The post-'#' fragment identifier
#             
sub compose
{
    local($scheme, $address, $port, $path, $query, $frag) = @_;
    local($url) = '';

    if ($scheme) { $url = $scheme . ':'; }

    if ($address)
    {
        $url .= "//$address";
        if ($port) { $url .= ":$port"; }
    }

    if ($path) { $url .= $path;     }
    if ($query)
    {
        if (!$path) { $url .= '/';  }  # Avoid mistaking query as being
        $url .= "?$query";             # part of the address
    }
    if ($frag) { $url .= "#$frag";  }

    return $url;
}


# ===========================================================================
# unescape(): Return the passed URL after replacing all %NN escaped chars
#             with their actual character equivalents.
#
sub unescape
{
    local($url) = @_;

    $url =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack("C",hex($1))/ge;
    return $url;
}

# ===========================================================================
# escape(): Return the passed string after replacing all characters matching
#           the passed pattern with their %XX hex escape chars.  Note that
#           the caller must be sure not to escape reserved URL characters
#           (e.g. / in pathnames, ':' between address and port, etc.) and thus
#           this routine can only be applied to each URL part separately. E.g.
#
#           $escname = &escape($name,'[\x00-\x20"#%/;<>?\x7F-\xFF]');
#
sub escape
{
    local($str, $pat) = @_;
         
    $str =~ s/($pat)/sprintf("%%%02lx",unpack('C',$1))/ge;
    return($str);
}


# ===========================================================================
# absolute(): Return the absolute URL given a (possibly relative) URL
#             and the document's absolute base URL.  Uses the $B* variables
#             to cache the last Base URL parsed.
#
sub absolute
{
    local($base, $url) = @_;

    $url =~ s/^\s+//;  # Remove any preceding whitespace
    $url =~ s/\s.*//;  # Remove anything after first word

    local($scheme, $addr, $port, $path, $query, $frag) = &parse($url);

    local($member) = $InSet{$scheme} || 0;


    RELATED: {

        if (!$base)          # If no base was given then it can't be relative
        {
            if (!$scheme) { $scheme = 'file' }   # Default to a file URL
            last RELATED;
        }

        if ($base ne $Burl)  # Check the Base URL cache
        {
            $Burl = $base;
            ($Bsch,$Baddr,$Bport,$Bpath,$Bquery,$Bfrag) = &parse($Burl);
            $Bmem = $InSet{$Bsch} || 0;
        }

        if (!$scheme)
        {
            $scheme = $Bsch;
            $member = $Bmem;
            if ($query && !($Bmem & $UsesQuery))  # Restore mistaken queries
            {
                $path .= '?'. $query;
                $query = '';
            }
        }
        else { last RELATED if ($scheme ne $Bsch); }

        last RELATED unless ($member & $UsesRelative);

        last RELATED if ($addr || $port);    # Child must have used '//'

        $addr = $Baddr;                      # else it inherits base netloc
        $port = $Bport;

        if (!$path)
        {
            $path = $Bpath;
            if (!$query) { $query = $Bquery; }
        }
        elsif ($member & $NonHierarchical)
        {;} # Do nothing
        elsif ($path !~ m|^/|o)     # If the child URL does not begin with '/'
        {
            local($ppath);
            if ($Bpath)
            {
                $ppath = $Bpath;
                if ($Bmem & $UsesParams)
                {
                    $ppath =~ s#;.*##;       # Trim off any base parameters
                }
                $ppath =~ s#/[^/]*$#/#;      # Trim off any base filename
            }
            else { $ppath = '/'; }

            $path = $ppath . $path;
            #
            # The order in which we remove the relative "/." and "xxx/.."
            # path segment components is extremely important.
            #
            while ($path  =~ s#/\./#/#) {;}
            $path  =~ s#/\.$#/#;
            while ($path  =~ s#/[^/]*/\.\./#/#) {;}
            $path  =~ s#/[^/]*/\.\.$#/#;
        }
    }

    if ($scheme eq 'file')
    {
        if (!$addr)                  { $addr   = 'localhost'; }
        elsif ($addr ne 'localhost') { $scheme = 'ftp';       }
        #
        # The above line will have to be deleted once people stop using
        # file: as an alias for ftp: (i.e. when the IETF standard is done).
        #
    }
    elsif ($scheme eq 'http')        { $path  =~ s#^/\%7E#/~#io; }

    # NOTE: Fanatical spec-followers should reverse the above substitution
    #       because it improperly prefers the tilde character over %7E (:-b)

    if ($port && ($port == $DefPort{$scheme})) { $port = ''; }

    if (!$path) { $path = '/'; }

    return &compose($scheme, $addr, $port, $path, $query, $frag);
}


# ===========================================================================
# get_site(): Return the site part of the passed-in absolute URL
#             (i.e. the hostname:port) replacing any missing port with
#             the default.  If the URL scheme does not allow hostport,
#             then we return '';
#
sub get_site
{
    local($scheme, $site, $port, $path, $query, $frag) = &parse($_[0]);

    return '' unless (defined($DefPort{$scheme}));

    if (!$port) { $port = $DefPort{$scheme}; }

    if ($port)  { $site .= ":$port"; }

    return $site;
}


# ===========================================================================

1;
