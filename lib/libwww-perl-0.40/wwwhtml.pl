# $Id: wwwhtml.pl,v 0.13 1994/07/21 08:50:11 fielding Exp fielding $
# ---------------------------------------------------------------------------
# wwwhtml: A package for parsing pages of HyperText Markup Language (HTML)
#          for a World-Wide Web spider.
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
# 07 Jul 1994 (RTF): Removed buggy attempt to extract comments.
#                    Updated META parsing to reflect HTML 2.0 proposal.
# 20 Jul 1994 (RTF): Fix segmentation fault if we are fooled into trying
#                    to extract links from a non-html document.
# 22 Jul 1994 (RTF): Fixed parsing of href's that had a new-line after
#                    the quote mark, causing an extra space to precede the
#                    extracted URL, which in turn created a black hole.
#                    Also added code to extract and change the base URL
#                    if there exists a <BASE href="..."> element.
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to Roy Fielding at <fielding@ics.uci.edu>.
# ---------------------------------------------------------------------------
# Some of these routines are reduced versions of those distributed by
# Oscar Nierstrasz <oscar@cui.unige.ch> from CUI, University of Geneva. 
# See <ftp://cui.unige.ch/PUBLIC/oscar/scripts/README.html> for more info.
# ===========================================================================
require "wwwurl.pl";

package wwwhtml;

# This is just a minimal start.  Eventually it would be nice to have
# a complete HTML parser with the ability to output formatted text.
# PostScript output would be even better (yeah, I know, keep dreaming).


# ===========================================================================
# extract_links(): Extract the document metainformation and links from a
# page of HTML content and return them for use by a traversal program.
#
# The parameters are:
#      $base    = the URL of this document (for fixing relative links);
#      *headers = the %table of document metainformation (should already
#                 contain some information from the HTTP response headers);
#      *content = the $page of HTML (this will be DESTROYED in processing);
#      *links   = the return @queue of absolute child URLs (w/o query or tag);
#      *labs    = the return @queue of absolute child URLs (with query or tag);
#      *lorig   = the return @queue of original child HREFs;
#      *ltype   = the return @queue of link types, where
#                 'L' = normal link,
#                 'I' = IMG source,
#                 'Q' = link or source containing query information,
#                 'R' = redirected link (used elsewhere).
#
# Uses ideas from Oscar's hrefs() dated 13/4/94 in
#      <ftp://cui.unige.ch/PUBLIC/oscar/scripts/html.pl>
#
sub extract_links
{
    local($base, *headers, *content, *links, *labs, *lorig, *ltype) = @_;
    local($scheme, $host, $port, $path, $query, $frag);
    local($link, $orig, $elem);

    $content =~ s/\s+/ /g;           # Remove all extra whitespace and newlines

    $content =~ s#<base\s[^>]*href\s*=\s*"?\s*([^">\s]+)[^>]*>##i; # Base?
    if ($1) { $base = $1; }
    
    $content =~ s#<title[^>]*>([^<]+)</title[^>]*>##i;  # Extract the title
    if ($1) { $headers{'title'} = $1; }
    
    $content =~ s/^[^<]+//;         # Remove everything before first element
    $content =~ s/>[^<]*/>/g;       # Remove everything between elements (text)
    $content =~ s/<[^>]*</</g;      # Remove extra <'s from bad HTML or text
    $content =~ s/>[^>]+$/>/;       # Remove everything after  last  element

    return unless ($content);       # Return if we removed everything

                                    # Isolate all META elements as text
    $content =~ s/<meta\s[^>]*http-equiv\s*=\s*"?\s*([^">\s]+)[^>]*content\s*=\s*"?([^">]+)[^>]*>/M $1 $2\n/gi;
    $content =~ s/<meta\s[^>]*name\s*=\s*"?\s*([^">\s]+)[^>]*content\s*=\s*"?([^">]+)[^>]*>/M $1 $2\n/gi;
                                    # Isolate all A element HREFs as text
    $content =~ s/<a\s[^>]*href\s*=\s*"?\s*([^">\s]+)[^>]*>/A $1\n/gi;
                                    # Isolate all IMG element SRCs as text
    $content =~ s/<img\s[^>]*src\s*=\s*"?\s*([^">\s]+)[^>]*>/I $1\n/gi;

    $content =~ s/<[^>]*>//g;       # Remove all remaining elements
    $content =~ s/\n+/\n/g;         # Remove all blank lines

    #
    # Finally, construct the link queues from the remaining list
    #

    foreach $elem (split(/\n/,$content))
    {
        if ($elem =~ /^A\s+(\S*)$/)
        {
            $orig = $1;
            push(@lorig, $orig);
            $link = &wwwurl'absolute($base, $orig);
            push(@labs, $link);
            ($scheme,$host,$port,$path,$query,$frag) = &wwwurl'parse($link);
            if ($query)
            {
                push(@ltype, 'Q');
            }
            else
            {
                push(@ltype, 'L');
            }
            push(@links, &wwwurl'compose($scheme,$host,$port,$path,'',''));
        }
        elsif ($elem =~ /^I\s+(\S*)$/)
        {
            $orig = $1;
            push(@lorig, $orig);
            $link = &wwwurl'absolute($base, $orig);
            push(@labs, $link);
            ($scheme,$host,$port,$path,$query,$frag) = &wwwurl'parse($link);
            if ($query)
            {
                push(@ltype, 'Q');
            }
            else
            {
                push(@ltype, 'I');
            }
            push(@links, &wwwurl'compose($scheme,$host,$port,$path,'',''));
        }
        elsif ($elem =~ /^M\s+(\S+)\s+(.*)$/)
        {
            $link = $1;          # Actually the metainformation name
            $orig = $2;          # Actually the metainformation value
            $link =~ tr/A-Z/a-z/;
            $headers{$link} = $orig;
        }
        else { warn "A mistake was made in link extraction from $base"; }
    }
}


1;
