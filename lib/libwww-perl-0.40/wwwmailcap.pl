# $Id$
# ---------------------------------------------------------------------------
# wwwmailcap.pl: This library implements routines for parsing a 
#                MIME mailcap file and executing commands based on
#                a file's MIME Content-type
#
# This package has been developed by Brooks Cutter <bcutter@stuff.com>.
# It is distributed under the Artistic License (included with your Perl
# distribution files and with the standard distribution of this package).
#
# 26 Jul 1994 (BBC): Initial version
# 31 Jul 1994 (RTF): Reformatted a bit (and new name) for inclusion in
#                    standard libwww-perl distribution.
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to the libwww-perl mailing list at <libwww-perl@ics.uci.edu>.
# ---------------------------------------------------------------------------
#
# The MIME mailcap file is defined in the (Work in progress) mailcap draft:
# ftp://venera.isi.edu/internet-drafts/draft-borenstein-mailcap-00.ps
# ftp://venera.isi.edu/internet-drafts/draft-borenstein-mailcap-00.txt
#
# This package currently parses mailcap lines, and uses the test field
# to determine if the mailcap line should be used.  It will save the
# 'view' command associated with each MIME Content-type.
#
# Public/External routines:
#
# &exists_handler($mime_type,$cmd)    - is a mime type handler defined?
#  Returns 1 if there exists a definition for $mime_type in mailcap
#  Returns 0 if there is no handler for the specified $mime_type
#   $mime_type is of the form "type/subtype" like "text/html"
#   $cmd is optional, and defaults to 'view' if not specified
#
# &view($mime_type,$fn)               - exec view program for $mime_type
#   $mime_type is of the form "type/subtype" like "text/html"
#   $fn is the name of the file to pass to the program
#
# Private/Internal routines:
#  - You don't need to call (or know about) these routines.
#    the first time you call &view or &exists_handler, &init
#    is called and parses the mailcap files..
#
# &init                 - load defaults and search for mailcap files
# &load_mailcap_default - load mailcap from internal defaults
# &load_mailcap_file    - local mailcap from external file
# &parse_mailcap(@_)    - parse mailcap lines intro internal assoc array
#
#----------------------------------------------------------------------
# Todo:
#      This package recognizes the 'view' and 'test' fields, however there
#      are a number of other fields that should be recognized, and the values
#      (if any) should be saved and accessible through the library API.
#
# The following key/value fields or flags are not currently recognized:
#
# key/value fields: compose, composetyped, edit, print,  description,
#                   textualnewlines, x11bitmap, nametemplate
# flags: needsterminal, copiousoutput, needsx11
#
# Also needs to be done:
# - rewrite parse_mailcap so it recognizes lines that end with \ (backslash)
# - recognize attribute/variable quoting and pass other needed MIME headers.
#----------------------------------------------------------------------

package wwwmailcap;


# ===========================================================================
# This is Mosaic's default mailcap ...

$gl_default_mailcap = <<'EOF';
audio/*; showaudio %s
image/xwd; xwud -in %s
image/x-xwd; xwud -in %s
image/x-xwindowdump; xwud -in %s
image/*; xv %s
video/mpeg; mpeg_play %s
application/postscript; ghostview %s
application/x-dvi; xdvi %d
message/rfc822; xterm -e metamail %s
EOF

# ===========================================================================
# As defined in draft-bornstein-mailcap-00.txt 5/94
# If Environment variable MAILCAPS isn't set, use the default search path

$gl_mailcap_path = $ENV{'MAILCAPS'} || 
"$ENV{'HOME'}/.mailcap:/etc/mailcap:/usr/etc/mailcap:/usr/local/etc/mailcap";


# ===========================================================================
# ===========================================================================
# exists_handler(): returns 1 if there is a "handler" for $mime_type (1st arg)
#                   otherwise returns 0
#                   $cmd indicates the MIME mailcap command to execute
#                   if $cmd isn't specified, it defaults to 'view'
#
# $ok = &exists_handler($mime_type,$cmd);
#
# WHERE,
#
#        $ok: 1 if there is a mailcap entry for $mime_type and command $cmd
#
# $mime_type: A MIME Content-type, like "text/html"
#
#       $cmd: Either null (defaults to 'view') or a MIME command
#             Currently the only supported command is 'view'
#
# Example
#
# $url = 'http://www.host.dom/dir/file.html';
# $response = &www'request('GET',$url,*headers,*content,$timeout);
# if ($headers{'content-type'} =~ m!^text/(plain|html)$!i) {
#   print $content; # display it on the screen 
# } elsif (&wwwmailcap'exists_handler($headers{'content-type'},'view')) {
#   local($fn) = "/tmp/file.$$.".time;
#   open(OUT,">$fn"); print OUT $content; close(OUT);
#   &wwwmailcap'view($headers{'content-type'},$fn);
# } else {
#   print "Unable to handle MIME type $headers{'content-type'}\n";
# }
#
sub exists_handler
{
    local($mime_type, $cmd) = @_;

    &init unless (%gl_mailcap);

    local($type, $subtype) = split(/\//,$mime_type,2);
    $cmd = 'view' unless(@_);
    if (($gl_mailcap{$type,$subtype,$cmd}) ||
        ($gl_mailcap{$type,'*',$cmd})      ||
        ($gl_mailcap{'*','*',$cmd}))
    {
        return(1);
    }
    return(0);
}


# ===========================================================================
# view(): select the 'view' program for $mime_type and execute with $fn
#
# &exists_handler($mime_type,$fn)
#
# WHERE,
#
# $mime_type: A MIME Content-type, like "text/html"
#
#        $fn: The name of the file to pass to the MIME mailcap 'view' program
#
# Note: For an example including &view, see &exists_handler
#
sub view
{
    local($mime_type, $fn) = @_;

    &init unless (%gl_mailcap);

    # %s - replace with name of file (otherwise pass data by stdin)
    # %t - replace with content-type (type/subtype)
    local($type,$subtype) = split(/\//,$mime_type,2);
    local($cmd) = $gl_mailcap{$type,$subtype,'view'} ||
                  $gl_mailcap{$type,'*','view'}      ||
                  $gl_mailcap{'*','*','view'};

    return unless($cmd); # exit rather than return since already forked
    return if (fork);

    if ($cmd =~ /%s/)
    { 
        $cmd =~ s/%s/$fn/g;
        if ($cmd =~ /%t/) { $cmd =~ s!%t!$type/$subtype!g; }
        exec "$cmd ; rm -f $fn"; # calls sh -c ..
    }
    else
    {
        exec "cat $fn | $cmd ; rm -f $fn"; # calls sh -c ..
    }
    exit;
}


# ===========================================================================
# init(): load mailcap files and default mailcap
#
# &init (no arguments)
#
sub init
{
    return if (%gl_mailcap);
    local($_);
    for (split(/:/,$gl_mailcap_path))
    {
        next unless(-f $_);
        &load_mailcap_file($_);
    }
    &load_mailcap_default;
}


# ===========================================================================
# load_mailcap_default(): load defaults from global var $gl_default_mailcap
#
# &load_mailcap_default (no arguments)
#
sub load_mailcap_default
{
    return(-1) unless($gl_default_mailcap);
    &parse_mailcap(split(/\n/,$gl_default_mailcap));
    return(0);
}


# ===========================================================================
# load_mailcap_file(): load mailcap data from external file $fn
#
# &load_mailcap_file($fn)
#
# WHERE,
#
# $fn: Name of mailcap file to load
#
sub load_mailcap_file
{
    local($fn) = @_;

    open(IN,$fn) || return(-1);
    &parse_mailcap(<IN>);
    close(IN);
    return(0);
}

# ===========================================================================
# parse_mailcap(): parse mailcap lines and store in var $gl_default_mailcap
#
# &parse_mailcap(@mailcap_lines)
#
# WHERE,
#
# @mailcap_lines: One or more mailcap lines.  Each element of @mailcap_lines
#                 is a complete entry and has any newlines and/or backslashes
#                 stripped out.
#
sub parse_mailcap
{
    local($_,$type,$view,@types,$line,$key,$val,$types,$subtype);

    for (@_)
    {
        tr/\x00-\x1f\x7f-\xff//d;
        @types = split(/\s*;\s*/);
        $types = shift(@types);
        ($type, $subtype) = split(/\//,$types,2);
        $view = shift(@types);
        for $line (@types)
        {
            $line =~ s/^\s+//;
            $line =~ s/\s+$//;
            ($key,$val) = split(/\s*=\s*/,$line,2);
            $key =~ tr/A-Z/a-z/;
            if (($key eq 'test') && ($val))
            {
                local(@ret) = `sh -c '$val'`;
                local($ret) = ($? >> 8); # value returned by exec'ing $val..
                # if test field returns a non-zero value, ignore the entry
                next if ($ret);
            } 
        }
        if (($view) && (!$gl_mailcap{$type,$subtype,'view'}))
        {
            $gl_mailcap{$type,$subtype,'view'} = $view;
        }
    }
}

# ===========================================================================

1;
