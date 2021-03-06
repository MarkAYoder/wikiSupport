# $Id: wwwmime.pl,v 0.12 1994/07/08 08:08:14 fielding Exp fielding $
# ---------------------------------------------------------------------------
# wwwmime.pl: A package for handling MIME-specific operations for
#             a World-Wide Web client.
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# It is distributed under the Artistic License (included with your Perl
# distribution files).
#
# 13 Jun 1994 (RTF): Initial version 
# 14 Jun 1994 (RTF): Changed environment variable to LIBWWW_PERL
# 07 Jul 1994 (RTF): Made calls to load_mimetypes more tolerant
# 15 Jul 1994 (RTF): Moved some code into new function set_content()
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to Roy Fielding at <fielding@ics.uci.edu>.
# ---------------------------------------------------------------------------
require "wwwdates.pl";

package wwwmime;

%MIMEtypes = (
    '',     'text/plain',       # The default MIME content-type
    'txt',  'text/plain',
    'htm',  'text/html',
    'html', 'text/html',
);

%MIMEencodings = (
    'gz',  'x-gzip',
    'z',   'x-compress',
);

$libloc = ($ENV{'LIBWWW_PERL'} || '.');
&load_mimetypes("$libloc/mime.types");

$myhome = ($ENV{'HOME'} || $ENV{'home'} || '.');
&load_mimetypes("$myhome/.mime.types");


# ===========================================================================
# load_mimetypes(): Read the named file (if it exists) and load the
#                   file extension -> MIME content-type mapping into the
#                   %MIMEtypes array.
#
#  See <http://www.ncsa.uiuc.edu/SDG/Software/Mosaic/Docs/extension-map.html>
#  for information on extension map files.
#
sub load_mimetypes
{
    local($file) = @_;
    local(@word, $type, $ext);

    return unless open(MIME, $file); 

    while (<MIME>)
    {
        next if /^#/;
        next if /^\s*$/;

        @word = split;

        $type = shift(@word);

        foreach $ext (@word)
        {
            $ext =~ tr/A-Z/a-z/;
            $MIMEtypes{$ext} = $type;
        }
    }
    close MIME;
}


# ===========================================================================
# content_type(): Map passed-in file extension to its MIME content-type.
#                 The extension must already be in lower-case.
#
sub content_type
{
    return ($MIMEtypes{$_[0]} || $MIMEtypes{''}); 
}


# ===========================================================================
# fakehead(): Compose a standard HTTP response head and place
#             the information in the %headers array.  This allows the
#             library-to-client interface to be uniform.
#
sub fakehead
{
    local($suffix, $contentlen, $lastmod, *headers) = @_;

    $headers{'date'}           = &wwwdates'wtime(time,'GMT');
    $headers{'mime-version'}   = '1.0';
    $headers{'content-length'} = $contentlen;

    if ($lastmod)
    {
        $headers{'last-modified'} = &wwwdates'wtime($lastmod,'GMT');
    }

    &set_content($suffix, *headers);
}


# ===========================================================================
# set_content(): Set the Content-type and Content-encoding headers based on
#                the filename extension(s) passed in $suffix.
#
sub set_content
{
    local($suffix, *headers) = @_;
    local($[) = 0;
    local(@suf, $conenc);

    $suffix =~ tr/A-Z/a-z/;
    @suf = split(/\./,$suffix);

    while ($#suf > 1) { shift(@suf); }

    if ($#suf == 1)
    {
        if ($conenc = $MIMEencodings{$suf[1]})
        {
            $headers{'content-encoding'} = $conenc;
        }
        else { shift(@suf); }
    }

    $headers{'content-type'} = &content_type($suf[0]);
}


1;
