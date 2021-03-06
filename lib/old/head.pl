# Contains:
#  head(%params) - processed the <cd-head> tag
#  body(%params) - processed the <cd-body> tag
#  foot(%params) - processed the <cd-foot> tag
# %params comes from getparams($tag)

#"$Log: head.pl,v $
#Revision 2.3  2000/04/17  21:35:50  myoder
#Uses visible2 now.
#New20001 copywright date.
#Appendex is now chapter 14.
#
#Revision 2.2  2000/04/12  19:35:00  myoder
#Found newer version of head.pl.  CHecking it in.
#
#Revision 1.37  1997/10/01  22:02:53  myoder
#Added $HeadingsID.  Heading are now uppercase.
#
#Revision 1.36  1997/09/30  17:35:58  myoder
#Fixxed a // bug.
#demos.htm and labs.htm now go to chapters.htm when ChapBack is pushed.
#demos.htm and labs.htm now just list demos and labs in Nav Box.
#
#Revision 1.35  1997/09/17  22:16:20  myoder
#Removed some old commented out code.
#Added code to handle exercise.
#Help now opens in a new window.
#
#Revision 1.34  1997/09/12  20:53:01  myoder
#Removed the nbsp at the in the Nav Box so the link would look more centered.
#
#Revision 1.33  1997/09/11  20:40:31  myoder
#Added chapid so chapter 10 will appear as A.
#
#Revision 1.32  1997/09/10  22:29:05  myoder
#Centered the navigation buttons.
#Fixed BuildNav to work in new archive location.
#
#Revision 1.31  1997/09/09  22:28:20  myoder
#Updated footer for final version.  No dates or bug report URL.
#Added alt= filed to many images.
#
#Revision 1.30  1997/09/04  21:59:40  myoder
#Added some space between the numbers and units in the nav box by
#changing the spaces to non-braking spaces (&nbsp).
#
#Revision 1.29  1997/09/04  21:06:00  myoder
#Added <cd-nav> tag.  It's will instert navigation buttons.
#Major changed to handle homework.  homework doesn't appear in the usual
#file locals, so I've had to do some kludgeing.
#
#Revision 1.28  1997/06/19  22:31:00  myoder
#Added a hack to change chap A to 10.
#
#Revision 1.27  1997/02/07  13:29:23  myoder
#Changed the path in foot() to reflect the new path returned by 'pwd'.
#
#Revision 1.26  1996/11/12  19:00:15  myoder
#Changed footer to point to feedback.htm.
#
#Revision 1.25  1996/09/02  16:05:02  myoder
#Split chapter 6.  Now uses location of file for the chapter number
#rather than the parameter in the <cd-head> tag.
#
#Revision 1.24  1996/07/09  17:48:16  myoder
#Converted to lowercase.
#
#Revision 1.23  1996/06/03  17:49:11  myoder
#Added new navigation buttons.  Now you can jump straight to a chapter,
#or a chapter section.
#
#Revision 1.22  1996/04/29  13:49:56  myoder
#Added a "overchap" unit for chapter overviews.
#Added a fifth argument of buildNav which allows one to specify the BACK
#button.
#
#Revision 1.21  1996/04/15  19:49:33  myoder
#Updated copyright notice to reflect the title.
#Notes now know how to find who is up and down from them.
#
#Revision 1.20  1996/03/26  18:30:04  myoder
#Put in DSP First title.
#
#Revision 1.19  1996/03/26  18:23:43  myoder
#stuff
#
#Revision 1.18  1996/03/15  21:00:23  myoder
#Added 'notes' as a type of unit.
#No longer looks for .html, just .htm
#
#Revision 1.17  1996/02/07  19:08:35  myoder
#Up and down button will not appear if directory isn't in $Prev{}.
#New look for navigation buttons.  right justified.  Text wraps around it.
#
#Revision 1.16  1996/01/24  21:31:54  myoder
#Improved navigation buttons so demos will have up and down buttons
#that take them to the other demos in the same chapter.
#You must put the up and down info in constants.pl.
#
#Revision 1.15  1996/01/10  22:01:13  myoder
#Changed .html to .htm
#.html is used if .htm isn't there.
#
#Revision 1.14  1995/12/11  12:50:43  myoder
#Commented out many print debug statements.
#Swapped left and right buttons.
#
#Revision 1.13  1995/12/08  12:42:02  myoder
#Further refinement of how the navigation buttons operate.
#
#Revision 1.11  1995/10/17  17:56:42  myoder
#Added two new heading styles:
#1.	Has Map and help button only.
#2.	HAs 1. plus back button.
#
#Revision 1.10  1995/08/22  20:26:40  myoder
#Added background color and getcolor to pick which one to use.
#
#Revision 1.9  1995/07/18  15:11:33  myoder
#Moved nav buttons from header to body since putting gifs in the
#header seems to prevent the body from having a background.
#
#Revision 1.8  1995/07/06  17:06:42  myoder
#head now passes it's html through the converter so path names can be
#computed.
#
#Revision 1.7  1995/06/29  21:48:17  myoder
#The -b option to cd2html will now prevent the background image
#from being loaded.
#The -d option will set the debug flag.
#
#Revision 1.6  1995/06/19  18:26:47  myoder
#Added 1; at the end so it will work with 'require'.
#
#Revision 1.5  1995/06/19  18:16:49  myoder
#*** empty log message ***
#
#Revision 1.4  1995/06/19  18:10:47  myoder
#Fixed comment bug
#
#Revision 1.3  1995/06/01  19:00:50  myoder
#back() now uses findpath() to find backgrounds.
#
#Revision 1.2  1995/06/01  16:41:50  myoder
#Changed comment character to #
#
#Revision 1.1  1995/06/01  16:05:00  myoder
#Initial revision
#";
$Header = '$Header: /home/ratbert5/myoder/cd/visible2/support/lib/RCS/head.pl,v 2.3 2000/04/17 21:35:50 myoder Exp myoder $';

require 'htmlscan.pl';
require 'constants.pl';

#==============
# head
#==============

sub head {
local(%params) = @_;
local($debug) = 1;

# Make some global assignments 

$chap = $params{'chap'};	# global assignment for all to use.
$unit = $params{'unit'};
$next = $params{'next'};        # Used for homework
$prev = $params{'prev'};

$anaflag = $params{'analytics'};

# print "head called with chap=$chap and unit=$unit\n" if $debug;

# The following looks up the path for 'visible2', then goes down to
# directories to find the number.txt file
#	print "$pwd\n";
# Homework and Exercises  get their chap num from cd-head
    if($unit ne 'homework' && $unit ne 'exercise') { 
	@tmp = split("/", $pwd);	# Find name of current directory
	$i = 6;				# Oops, visible2 appears twice in the path.  Skip the first on
	foreach $dir (@tmp) {
		$i++;
#		print "$i $dir\n";
		last if ($dir eq 'visible2');
	}
#	print "@tmp\n";
	splice(@tmp, $i+2, $#tmp-$i, 'number.txt');
#	print "@tmp\n";
	$numb = join('/', @tmp);
#	print "$tmp\n";
#	print "$numb\n";
	open(NAME, $numb);   $chapnum  = <NAME>; chop($chapnum); chop($chapnum);
#	print "$chapnum\n";
	if ($chapnum != $chap) {
#    		print "<cd-head> has chap = $chap, file is in $chapnum\n";
#		print "Using $chapnum\n";
		$chap = $chapnum;
	}
   } # if($unit ne 'homework')

# Hack
if($chap eq "A") {
    $chap = 14;
}

my $analytics;
my $key;
if(bookType() eq 'dtsp') {
  $key = "UA-119847-5";	# dtsp
} else {
  $key = "UA-119847-1";	# spfirst
}

if($anaflag ne 'none') {
$analytics = "<script src=\"http://www.google-analytics.com/urchin.js\" type=\"text/javascript\">
</script>
<script type=\"text/javascript\">
_uacct = \"$key\";
urchinTracker();
</script>
";
}

if(bookType() eq 'dtsp') {
"<head>

<meta http-equiv=\"imagetoolbar\" content=\"no\" />
<meta name=\"author\" content=\"Alan V. Oppenheim, Ron W. Schafer\" />
<meta name=\"copyright\" content=\"Oppenheim, Schafer, Discrete-Time Signal Processing, ISBN 0-13-065-???. Prentice Hall, Upper Saddle River, NJ 07458. &copy; 2007 Pearson Education, Inc.\" />

$analytics
";


} else {
"<head>

<meta http-equiv=\"imagetoolbar\" content=\"no\" />
<meta name=\"author\" content=\"James H. McClellan, Ronald W. Schafer, Mark A. Yoder\" />
<meta name=\"copyright\" content=\"McClellan, Schafer, and Yoder, Signal Processing First, ISBN 0-13-065562-7. Prentice Hall, Upper Saddle River, NJ 07458. &copy; 2007 Pearson Education, Inc.\" />

$analytics
";
}

}

sub headend {
$css  = $params{'css'};
if(!$css) {
	$css="main.css";
}
  "
<link rel=\"stylesheet\" href=\"" . findpath($css)     . "\" type=\"text/css\" />
</head>
"
}

#==============
# body
#==============

sub body {
local(%params) = @_;
local($background, $controls);

if($back_flag) {
#    $background = "background=\"" . &findpath("back$chap$unit.gif") . "\"";
#    $background = "bgcolor=\"" . &getcolor($chap, $unit) . "\"";

#    print HTML "<body $background text=f0f0f0 link=f0f0f0 vlink=f0e0e0>\n";
#    print HTML "<body $background >\n";
#    print HTML "<body background=\"" . &findpath("bg-grid.gif") . "\">\n";
    print HTML "<body>\n";
#    print HTML "<img align=right height=100 src=\"" . &findpath("ChirpForCover.png") . "\">\n";
#    print HTML "
#<script language=\"JavaScript1.2\">
#
#/*
#Watermark Backgound Image Script- � Dynamic Drive (www.dynamicdrive.com)
#For full source code, 100's more DHTML scripts, and TOS,
#visit dynamicdrive.com
#*/
#
#if (document.all||document.getElementById)
#document.body.style.background=\"url('overview.jpg') center no-repeat fixed\"
#
#</script>
#";

    if(0) {
    # If not chapter 0, put up the navigation controls.
#    if($chap >! 0) {
    if(1) {
	@tmp = split("/", $pwd);	# Find name of current directory
	@tmp = reverse(@tmp);
	$dir = $tmp[0];
	$_ = $dir;
	($number, $name) = /(\d*)(\w*)/;
	print "$number\n";
	
	if($unit eq 'demo' || $unit eq 'lab') {
	    print "Found $unit\n";
		$dir = $tmp[1];  # Kludge
	    	print "no up/down\n";
		&buildNav("","","","","../overview.htm","../..")
#	    }

	} elsif($unit eq 'notes') {
	    $down = $number; $down++;
	    $up   = $number; $up--; if($up<10){ $up = "0$up"}
#	    print "up = $up, down = $down\n";
	    opendir(NOTES, '..') || die("$0: Can't open ..\n");
	    @notes = sort readdir(NOTES);
#	    print "notes = @notes\n";
	    @down = grep(/$down/, @notes);
	    @up   = grep(/$up/, @notes);
	    $dir = $tmp[1]; #kludge
		&buildNav(
		    "../$up[0]/index.htm",		# up
		    "../$down[0]/index.htm", 	# down
		    "",	# left
	    	    "", 	# right
			  "", # overview
			  "../..");

	} elsif($unit eq 'homework' || $unit eq 'exercise') {
	    print "I Found $unit prev=$prev next=$next\n";
	    $dir = $unit; #kludge
		&buildNav(
		    $prev,    # up
                    $next,    # down
		    "",	# left
	    	    "", 	# right
		    "../../chapters/$chapter[$chap]/$dir/overview.htm", # overview
		    "../chapters");

	} elsif($unit eq 'overview') {
	    print "found overview\n";
	    $upchap = $chap + 1; if($upchap > $#chapter) { $upchap = 1;}
	    $downchap = $chap -1; if($downchap <1) {$downchap = $#chapter}
#	    print "chap = $chap, up = $upchap, down= = $downchap\n";
	    if($Next{$dir}) {
		
#	    print "$dir\t$Next{$dir}\t$Prev{$dir}\n";
	    &buildNav(
		"../../$chapter[$downchap]/$dir/overview.htm",	# up
		"../../$chapter[$upchap]/$dir/overview.htm", 	# down
		"../$Prev{$dir}/overview.htm",		# right
		"../$Next{$dir}/overview.htm", 	# left
		      "",  # overview
		      "..");  # Where to find other overviews
	    }

	} elsif($unit eq 'overchap') {
	    print "found overchap\n";
	    $upchap = $chap + 1; if($upchap > $#chapter) { $upchap = 1;}
	    $downchap = $chap -1; if($downchap <1) {$downchap = $#chapter}
#	    print "chap = $chap, up = $upchap, down= = $downchap\n";
		
	    &buildNav(
		"../$chapter[$downchap]/overview.htm",	# up
		"../$chapter[$upchap]/overview.htm", 	# down
		"",		# right
		"", 	# left
		      "../../contents/chapters.htm",    # Back
		      "."); # overviews

	} elsif($unit eq 'chap') {
	    print "found chap\n";
		
	    # Hack
	    $dir = "";
	    &buildNav(
		"",	# up
		"", 	# down
		"",	# right
		"", 	# left
		"chapters.htm",    # Back
		      "chapters"); # overviews
	    }
    }
  } # if(0)
    return('');
    }
    else {	# no background.
	return("<body>");
    }
}

#==============
# foot
#==============

sub foot {
local($file) = @_;

# Find the modification time of the input file
$mtime = (stat($file))[9];
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);
$mon = (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)[$mon];
$year = $year + 1900;

# Find relative path to file
$file = &relpath2("$pwd/$file", $ENV{'CDROOT'});

if(bookType() eq 'dtsp') {
#    print "dtsp found\n";
    $footer = "<br/><br/><hr/>\n" .
       "<a href=\"http://www.pearsonhighered.com/educator/academic/product/0,3110,0137549202,00.html\" target=\"_blank\">" .
       "<img style=\"border:none\" align=\"right\" height=\"100\" src=\"" . &findpath("chirpcov.png") . "\" />\n" .
       "</a><font color=\"gray\">\n";

    $footer .= "<a href=\"" . &findpath("indexHome.htm") . 
      "\" target=\"_blank\">Home</a>
<br/>Oppenheim and Schafer, <i>Discrete-Time Signal Processing</i>m ISBN 0-13-????.\n";

} else {
    $footer = "<br/><br/><hr/>\n" .
       "<a href=\"http://vig.prenhall.com/catalog/academic/product/0,1144,0130909998,00.htm\" target=\"_blank\">" .
       "<img style=\"border:none\" align=\"right\" height=\"100\" src=\"" . &findpath("chirpcov.png") . "\">\n" .
       "</a><font color=\"gray\">\n";
    $footer .= "<a href=\"" . &findpath("indexHome.htm") .
	"\" target=\"_blank\">Home</a>
<br/>
McClellan, Schafer, and Yoder, <i>Signal Processing First</i>, ISBN 0-13-065562-7. 
";
}

# Common stuff
$footer .= 
"<br/>
<a href=\"http://www.pearsonhighered.com\" target=\"_blank\">
Prentice Hall, Upper Saddle River, NJ 07458. 
&copy; 2007 Pearson Education, Inc.
</a>
</font>
" .

#"<p><a href=\"feedback.htm\">Click here</a> to submit bug reports, comments, \n" .

#"<p><font size=-2 color=gray><a href=\"mailto:Mark.A.Yoder_at_Rose-Hulman.edu?subject=Signal Processing_First_Web_Feedback&body=$file\">Click here</a> to submit bug reports, comments, \n" .
#"or suggestions for improvements.\n" .
#
#"When submitting a report, please note the URL for this page is " .
#"<code>$file</code>\n" .
#"<br/>It was last updated $hour:$min on $mday-$mon-$year</font>\n" .
"";

&htmlscan(split(/([<>])/,$footer));
"";
}

#==============
# bookType
#==============

sub bookType {

# Returns the type of book being processed.
# 'spfirst'  for Signal Processing First
# 'dtsp' for Discrete-Time Signal Processing
# 'tb' for Telecommunication Breakdown
    print "bookType: $ENV{'BOOKTYPE'}\n";
    $ENV{'BOOKTYPE'};
}

#==============
# getcolor
#==============

sub getcolor {
local($chap, $unit) = @_;
# compute a background color based on the chapter and unit
# $color is defined in constants.pl

# print "getcolor($chap, $unit) = $color[$chap]\n";
$color[$chap];

}

#==============
# buildNav
#==============

sub buildNav {
local($up, $down, $left, $right, $back, $over) = @_;
# Builds html code for navigation buttons.  Arguments tell where the
# up, down, left, and right buttons should go.

# print "up = $up\n";
# print "down = $down\n";
# print "left = $left\n";
# print "right = $right\n";

# if $fullhead has something in it, we've already built the nav buttons and
# there is no need to do it again.
if(!$fullhead) {
$fullhead = "<table border=2 align=right>\n" .
    "<tr>\n";

# Figure the number of columns in the table.
$colspan=2;    # ToC an help are always there.
if($back || -e "../overview.htm") {$colspan++}
if($left) {$colspan++}
if($up || $down) {$colspan++}
if($right) {$colspan++}

# print "colspan=$colspan\n";
$fullhead .="<td colspan=$colspan align=center>\n";

# Build the chapter overview link at the top of the Nav panel

# print "chapter = $#chapter\n";
for($i=1; $i<=$#chapter; $i++) {
    if($i eq $chap) {
	$fullhead .= "$chapid[$i]\&nbsp\n";
    } elsif($over eq ".") {
	$fullhead .= "<a href=\"../$chapter[$i]/overview.htm\">$chapid[$i]</a>\&nbsp\n";
    } elsif($dir) {
	$fullhead .= "<a href=\"../$over/$chapter[$i]/$dir/overview.htm\">$chapid[$i]</a>\&nbsp\n";
    } else {
	$fullhead .= "<a href=\"../$over/$chapter[$i]/overview.htm\">$chapid[$i]</a>\&nbsp\n";
    }

}
# Remove the last &nbsp
chop($fullhead);chop($fullhead);chop($fullhead);
chop($fullhead);chop($fullhead);chop($fullhead);
$fullhead .= "\n";
$fullhead .= "</td></tr>\n";

# Build the up/down left/right etc. icons in the middle of the Nav panel

$fullhead .= "<tr align=center>";

if($back) {
        $fullhead .= "<td><a href = \"$back\">\t" .
	    "<img border=0 alt=\"Back\" src=\"chapback.gif\"></a></td>\n";
} elsif(-e "../overview.htm") {
	$fullhead .= "<td><a href = \"../overview.htm\">\t" . 
		"<img border=0 alt=\"Overview\" src=\"chapback.gif\"></a></td>\n";
}
if($left) {
	$fullhead .= "<td><a href = \"$left\">\t" .
		"<img border=0 alt=\"Left\" src=\"back.gif\"></a></td>\n";
}
if($up || $down) {
	$fullhead .= "<td align=center>\t";
}
if(-e $up) {
	$fullhead .= "<a href = \"$up\">\t" .
		"<img border=0 alt=\"Up\" src=\"up.gif\"></a><br>\n";
}
if(-e $down) {
	$fullhead .= "<a href = \"$down\">\t" .
		"<img border=0 alt=\"Down\" src=\"down.gif\"></a>";
}
if($up || $down) {
	$fullhead .= "</td>\n";
}
if($right) {
	$fullhead .= "<td><a href = \"$right\">\t" .
		"<img border=0 alt=\"Right\" src=\"forward.gif\"></a></td>\n";
}
$fullhead .= "<td><a href = \"toc.htm\"> <img border=0 alt=\"Contents\" src=\"map.gif\"></a></td>\n" .
"<td><a href = \"#\" onClick=window.open(\'help.htm\',\'help\',\'status=no,width=503,height=380,menubar=yes\')>	<img border=0 alt=\"Help\" src=\"ques2.gif\"></a></td>\n" .
    "</tr>\n";

# Build the demo/lab/exercise/hw link at the bottom of the Nav panel

$fullhead .= "<tr><td colspan=$colspan align=center>\n";
foreach $head (@Headings[2..$#Headings]) {
    if($head eq $dir) {
	$fullhead .= "$HeadingsID{$head}\&nbsp\n";
    } elsif($unit eq 'homework' || $unit eq 'exercise') {
	$fullhead .= "<a href=\"../$over/$chapter[$chap]/$head/overview.htm\">$HeadingsID{$head}</a>\&nbsp\n";
    } elsif($unit eq 'chap') {
	if($head eq 'demos' || $head eq 'labs') {
	    $fullhead .= "<a href=\"$head.htm\">$HeadingsID{$head}</a>\&nbsp\n";
    }
    } else {
	$fullhead .= "<a href=\"$over/$head/overview.htm\">$HeadingsID{$head}</a>\&nbsp\n";
    }
}
# Remove the last &nbsp
chop($fullhead);chop($fullhead);chop($fullhead);
chop($fullhead);chop($fullhead);chop($fullhead);
$fullhead .= "\n";
$fullhead .= "</td></tr>\n" .
    "</table>\n" .
    "<br>\n" .
    "";
}  # end of if(!$fullhead)

&htmlscan(split(/([<>])/,$fullhead));
}

#==============
# nav
#==============

sub nav {
local($up, $down, $left, $right, $back, $over) = @_;
# Writes the html code for navigation buttons.  Must be run after BuildNav.

print "Found <cd-nav>\n";
&htmlscan(split(/([<>])/,$fullhead));
"";
}

1;
