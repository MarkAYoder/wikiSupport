# $Id: wwwdates.pl,v 0.12 1994/07/08 08:08:14 fielding Exp fielding $
# ---------------------------------------------------------------------------
# wwwdates: A package for manipulating date/time stamps in the format used
#           on the World-Wide Web.
#
# NOTE: Due to the limitations of timelocal.pl, this library can only
#       handle dates between "01 Jan 1970" and "01 Jan 2038".
#
# This package has been developed by Roy Fielding <fielding@ics.uci.edu>
# as part of the Arcadia project at the University of California, Irvine.
# Each routine in this package has been derived from the work of multiple
# authors -- those that are known are listed above the respective routines.
# The routines have been changed substantially, so don't blame them for bugs.
# It is distributed under the Artistic License (included with your Perl
# distribution files).
#
# 09 Jun 1994 (RTF): Initial Version 
# 18 Sep 1994 (RTF): Fixed a number of problems with the handling of years,
#                    most of which were due to limitations in timelocal.pl
#                    which goes into an infinite loop if (year >= 2038).
#
# If you have any suggestions, bug reports, fixes, or enhancements,
# send them to the libwww-perl mailing list at <libwww-perl@ics.uci.edu>.
# ---------------------------------------------------------------------------
#
# To convert machine time to ascii www date:
# 
# $thistime  = time;                     # Get the current date-time stamp
# $stringLOC = &wtime($thistime,'');     # Format it as local time
# $stringGMT = &wtime($thistime,'GMT');  #  and also as  GMT  time
#
# To convert ascii date to machine time:
# 
# $mtime = &get_gmtime($stringGMT);
#
# ===========================================================================

package wwwdates;

require "timelocal.pl";

$Mstr = 'JanFebMarAprMayJunJulAugSepOctNovDec';

@DoW = ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
@MoY = ('Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec');

# ===========================================================================
# wtime() is a modified version of Perl 4.036's ctime.pl
# library by Waldemar Kebsch <kebsch.pad@nixpbe.UUCP> and
# Marion Hakanson <hakanson@cse.ogi.edu>.
# 
# wtime returns a time string in the format "Wkd, Dy Mon Year HH:MM:SS Zone"
#               with no newline appended.
#
# USAGE:
#
# &wtime(time,'');     -- returns the local time with no timezone appended
#                         As in "Wed, 15 Dec 1993 23:59:59 "
#
# &wtime(time,'GMT');  -- returns GMT time
#                         As in "Thu, 16 Dec 1993 07:59:59 GMT"
#
sub wtime
{
    local($time, $tz) = @_;
    local($[) = 0;
    local($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);

    # Use local time if tz is anything other than 'GMT'

    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
        ($tz eq 'GMT') ? gmtime($time) : localtime($time);

    $year += 1900;
    sprintf("%s, %02d %s %04d %02d:%02d:%02d %s", substr($DoW[$wday],0,3),
            $mday, $MoY[$mon], $year, $hour, $min, $sec, $tz);
}


# ===========================================================================
# owtime() is the same as wtime() except that the returned date is
#          formatted as in RFC 850 (yuck, the old HTTP date format).
# 
# owtime returns a time string in the format "Weekday, Dy-Mon-Yr HH:MM:SS Zone"
#               with no newline appended.
#
# USAGE:
#
# &owtime(time,'');    -- returns the local time with no timezone appended
#                         As in "Wednesday, 15-Dec-93 23:59:59 "
#
# &owtime(time,'GMT'); -- returns GMT time
#                         As in "Thursday, 16-Dec-93 07:59:59 GMT"
#
sub owtime
{
    local($time, $tz) = @_;
    local($[) = 0;
    local($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);

    # Use local time if tz is anything other than 'GMT'

    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
        ($tz eq 'GMT') ? gmtime($time) : localtime($time);

    if ($year > 99) { $year %= 100; }

    sprintf("%s, %02d-%s-%02d %02d:%02d:%02d %s",
      $DoW[$wday], $mday, $MoY[$mon], $year, $hour, $min, $sec, $tz);
}

# ===========================================================================
# get_gmtime() is an extension of the datetomtime() routine found in
# htcache.pl by Gertjan van Oosten <gvoosten@isosa2.estec.esa.nl>.
#
# Description:
#	Translate a GMT date string to machine time (seconds since Epoch)
#
# Usage:
#	$mtime = &get_gmtime($date)
#
#    where $date can be any one of the following formats:
#
#	"Thu Feb  3 17:03:55 GMT 1994"        -- ctime format
#	"Wed, 09 Feb 1994 22:23:32 GMT"       -- proposed new HTTP format
#	"Tuesday, 08-Feb-94 14:15:29 GMT"     -- old rfc850 HTTP format
#	"Tuesday, 08-Feb-1994 14:15:29 GMT"   -- broken rfc850 HTTP format
#
#	"03/Feb/1994:17:03:55 -0700"   -- common logfile format
#	"09 Feb 1994 22:23:32 GMT"     -- proposed new HTTP format (no weekday)
#	"08-Feb-94 14:15:29 GMT"       -- old rfc850 HTTP format   (no weekday)
#	"08-Feb-1994 14:15:29 GMT"     -- broken rfc850 HTTP format(no weekday)
#
#	"08-Feb-94"     -- old rfc850 HTTP format    (no weekday, no time)
#	"08-Feb-1994"   -- broken rfc850 HTTP format (no weekday, no time)
#	"09 Feb 1994"   -- proposed new HTTP format  (no weekday, no time)
#	"03/Feb/1994"   -- common logfile format     (no time, no offset)

sub get_gmtime
{
    local($_) = @_;
    local($[) = 0;
    local($day, $mn, $yr, $hr, $min, $sec, $adate, $atime, $mon, $midx);
    local($offset) = 0;

    # Split date string
    local(@w) = split;

    # Remove useless weekday, if it exists
    if ($w[0] =~ /^\D/) { shift(@w); }

    if (!$w[0]) { return 0; }

    # Check which format
    if ($w[0] =~ /^\D/)   # Must be ctime (Feb  3 17:03:55 GMT 1994)
    {
        $mn    = shift(@w);
        $day   = shift(@w);
        $atime = shift(@w);
        shift(@w);
        $yr    = shift(@w);
    }
    elsif ($w[0] =~ m#/#) # Must be common logfile (03/Feb/1994:17:03:55 -0700)
    {
        ($adate, $atime) = split(/:/, $w[0], 2);
        ($day, $mn, $yr) = split(/\//, $adate);
        shift(@w);
        if ( $w[0] =~ m#^([+-])(\d\d)(\d\d)$# )
        {
            $offset = (3600 * $2) + (60 * $3);
            if ($1 eq '+') { $offset *= -1; }
        }
    }
    elsif ($w[0] =~ /-/)  # Must be rfc850 (08-Feb-94 ...)
    {
        ($day, $mn, $yr) = split(/-/, $w[0]);
        shift(@w);
        $atime = $w[0];
    }
    else                  # Must be rfc822 (09 Feb 1994 ...)
    {
        $day   = shift(@w);
        $mn    = shift(@w);
        $yr    = shift(@w);
        $atime = shift(@w);
    }
    if ($atime)
    {
        ($hr, $min, $sec) = split(/:/, $atime);
    }
    else
    {
        $hr = $min = $sec = 0;
    }

    if (!$mn || ($yr !~ /\d+/))     { return 0; }
    if (($yr > 99) && ($yr < 1970)) { return 0; }   # Epoch started in 1970

    if ($yr < 70)    { $yr += 100;  }
    if ($yr >= 1900) { $yr -= 1900; }
    if ($yr >= 138)  { return 0; }      # Epoch counter maxes out in year 2038

    # Translate month name to number
    $midx = index($Mstr, substr($mn,0,3));

    if ($midx  < 0) { return 0; }
    else            { $mon = $midx / 3; }

    # Translate to seconds since Epoch
    return (&timegm($sec, $min, $hr, $day, $mon, $yr) + $offset);
}

# ===========================================================================
# This last routine returns the three letter abbreviation for the month
# before the one in the date that was passed as an argument.  The argument
# must be a string that begins with the month.
#

sub lastmonth
{
    local($date) = @_;
    local($[) = 0;

    local($midx) = index($Mstr, substr($date,0,3));

    if    ($midx  < 0) { return 'Err'; }
    elsif ($midx == 0) { return 'Dec'; }
    else               { return substr($Mstr,($midx - 3),3); }
}

1;
