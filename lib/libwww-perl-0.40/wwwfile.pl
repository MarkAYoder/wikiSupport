# $Id: wwwfile.pl,v 0.11 1994/07/06 19:19:12 fielding Exp fielding $
# ---------------------------------------------------------------------------
# wwwfile: A package for interpreting local FILE requests and returning
#          responses as if they came from a remote server via HTTP proxy.
#          It should be very useful for running a WWW spider on local files.
#          This package is designed for use by www.pl
#          for handling URL's with the "file" scheme designator.
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# It is distributed under the Artistic License (included with your Perl
# distribution files).
#
# 13 Jun 1994 (RTF): Initial version 
# 07 Jul 1994 (RTF): Updated the error messages and escaped generated URLs.
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to Roy Fielding at <fielding@ics.uci.edu>.
# ---------------------------------------------------------------------------
require "wwwurl.pl";
require "wwwmime.pl";
require "wwwerror.pl";

package wwwfile;

%AllowedMethods = (     # Specify what HTTP request methods are supported
    'GET',    1,        # 1 = Allowed without content in request
    'HEAD',   1,
    'POST',   0,        # 2 = Allowed and with content in request
    'PUT',    0,
    'DELETE', 0,        # 0 = Not allowed
);


# ===========================================================================
# request(): retrieve the file named $object on the local filesystem as
#            if we were performing an http $method request.  The only legal
#            value for $host is "localhost" -- remote file requests should
#            be handled by wwwftp'request().  $port and $timeout are ignored.
#
#            Return the HTTP response code along with (as named parameters) 
#            the parsed response %headers and $content.
#
sub request
{
    local($method, $host, $port, $object, *headers, *content, $timeout) = @_;
    local($tail);

    if (!($AllowedMethods{$method} && ($host =~ m/^localhost$/io)))
    {
        return &wwwerror'onrequest($wwwerror'RC_bad_request_client, $method,
                          'file', $host, $port, $object, *headers, *content,
                          "Library does not allow that method for file");
    }

    $pathname = &wwwurl'unescape($object);

    if (!(-e $pathname)) # If the file does not exist, say 404 Not Found
    {
        return &wwwerror'onrequest($wwwerror'RC_not_found, $method, 'file',
                                   $host, $port, $object, *headers, *content,
                                   "File does not exist");
    }
    if (!(-r _))         # If we don't have read permission, say 403 Forbidden
    {
        return &wwwerror'onrequest($wwwerror'RC_forbidden, $method, 'file',
                                   $host, $port, $object, *headers, *content,
                                   "User does not have read permission");
    }

    local($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
          $atime,$mtime,$ctime,$blksize,$blocks)
            = stat(_);

    if (-d _)            # If the pathname is a directory, process it
    {
        $content = &dirlist($pathname);
        $size = length($content);
        if ($method eq 'HEAD') { $content = ''; }
        $tail = 'html';
    }
    else                 # It must be an okay file
    {
        if ($method ne 'HEAD')
        {
            if (!open(FS, $pathname))
            {
                return &wwwerror'onrequest($RC_internal_error, $method,
                          'file', $host, $port, $object, *headers, *content,
                          "Open failed: $!");
            }
            local($/);
            undef($/);
            $content = <FS>;
            close(FS);
        }
        else { $content = ''; }

        $tail = substr($pathname,(rindex($pathname,'/') + 1)); # filename
        $tail = substr($tail,(index($tail,'.') + 1));          # file extensions
    }

    &wwwmime'fakehead($tail, $size, $mtime, *headers);
    return $wwwerror'RC_ok;
}


# ===========================================================================
# dirlist(): read the directory named $pathname and return an HTML index
#            of its contents.
#
sub dirlist
{
    local($pathname) = @_;
    local($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
          $atime,$mtime,$ctime,$blksize,$blocks);
    local($wstr, $parent, $htmlname, $pathesc, $file, $full);

    if ($pathname !~ m#/$#) { $pathname .= '/'; }

    $htmlname = $pathname;
    $htmlname =~ s/\&/\&amp;/g;
    $htmlname =~ s/\</\&lt;/g;
    $htmlname =~ s/\>/\&gt;/g;

    $wstr = <<"EOF";
<HEAD><TITLE>Local Directory $htmlname</TITLE></HEAD>
<BODY><H1>Local Directory $htmlname</H1>
<UL>
EOF

    if (!opendir(DIR, $pathname))
    {
        return $wstr . "ERROR: Failed to open the directory</UL></BODY>\n";
    }

    $pathesc = '[\x00-\x20"#%;<&>?\x7F-\xFF]';  # Everything bad except '/'

    if ($pathname ne '/')
    {
        $parent = $pathname;
        $parent =~ s#/[^/]+/$#/#;
        $parent = &wwwurl'escape($parent, $pathesc);
        $wstr  .= 
            "<LI> <A HREF=\"file://localhost$parent\">Parent Directory</A>\n";
    }

    foreach $file (sort(readdir(DIR)))
    {
        next if (($file eq '.') || ($file eq '..'));

        $full = $pathname . $file;

        ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
         $atime,$mtime,$ctime,$blksize,$blocks) = stat($full);

        $full = &wwwurl'escape($full, $pathesc);
        $file =~ s/\&/\&amp;/g;
        $file =~ s/\</\&lt;/g;
        $file =~ s/\>/\&gt;/g;

        if (-d _) { $file .= '/';  $full .= '/'; }

        if (-r _)
        {
            $wstr .= 
            "<LI> <A HREF=\"file://localhost$full\">$file</A> ($size bytes)\n";
        }
        else
        {
            $wstr .= "<LI> $file ($size bytes)\n";
        }
    }
    $wstr .= "</UL></BODY>\n";

    return $wstr;
}


1;
