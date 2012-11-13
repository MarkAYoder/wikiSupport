# Contains:
#  head(%params) - processed the <cd-head> tag
#  body(%params) - processed the <cd-body> tag
#  foot(%params) - processed the <cd-foot> tag
# %params comes from getparams($tag)

#"$Log: head.pl,v $
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

<meta http-equiv=\"Content-Type\" content=\"text/html; charset= utf-8\" />
<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />
<meta http-equiv=\"imagetoolbar\" content=\"no\" />
<meta name=\"author\" content=\"Alan V. Oppenheim, Ron W. Schafer\" />
<meta name=\"copyright\" content=\"Oppenheim, Schafer, Discrete-Time Signal Processing, ISBN 0-13-198842-5. Hall, Upper Saddle River, NJ 07458. &copy; 2010 Pearson Education, Inc.\" />

$analytics
";


} else {
"<head>

<meta http-equiv=\"Content-Style-Type\" content=\"text/css\" />
<meta http-equiv=\"imagetoolbar\" content=\"no\" />
<meta name=\"author\" content=\"James H. McClellan, Ronald W. Schafer, Mark A. Yoder\" />
<meta name=\"copyright\" content=\"McClellan, Schafer, and Yoder, Signal Processing First, ISBN 0-13-065562-7. Prentice Hall, Upper Saddle River, NJ 07458. &copy; 2012 Pearson Education, Inc.\" />

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
<script type=\"text/javascript\" src=\"" . findpath("cb.js") . "\"></script>
<link rel=\"stylesheet\" href=\"" . findpath("$ENV{'BOOKTYPE'}.css") . "\" type=\"text/css\" media=\"screen,projection\" />
<link rel=\"stylesheet\" href=\"" . findpath($css) . "\" type=\"text/css\" />

</head>
"
}

#==============
# body
#==============

sub body {
local(%params) = @_;
local($background, $controls);

"<body>

<div id=\"wrap\">
	<div class=\"cbb\">
";
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
    $footer = "<p/><hr/>\n" .
       "<p style=\"color:gray\">
<a href=\"http://www.pearsonhighered.com\" target=\"_blank\">" .
       "<img style=\"border:none\" align=\"right\" height=\"103\" src=\"" . &findpath("coverSmall.jpg") . "\" />\n" .
       "</a>\n";

    $footer .= "<a href=\"" . &findpath("indexHome.htm") . 
      "\" target=\"_blank\">Home</a>
<br/>Oppenheim and Schafer, <i>Discrete-Time Signal Processing</i> ISBN 0-13-198842-5.\n";

} else {
    $footer = "<p/><hr/>\n" .
       "<p style=\"color:gray\">
<a href=\"http://vig.prenhall.com/catalog/academic/product/0,1144,0130909998,00.htm\" target=\"_blank\">" .
       "<img style=\"border:none\" align=\"right\" height=\"100\" src=\"" . &findpath("chirpcov.png") . "\">\n" .
       "</a>\n";
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
&copy; 2012 Pearson Education, Inc.
</a>
</p>
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
# dsplink
#==============

sub dtsplink {
local(%params) = @_;
local($debug) = 1;

# Make some global assignments 

my $page = $params{'page'};	# global assignment for all to use.
# print("path = $path\n");
my $relpath = $pwd;             # relative path to page.
# print("relpath = $relpath\n");
$relpath =~ s/$path//;          # find the last directory in the path
# print("$relpath\n");
my @type =split(/\//, $relpath);# use it to find the type (Build-a-Figure, etc)
# print("@type\n");
# Look up two levels in the path to find type.
my $type = $HeadingsID{$type[$#type-1]};
# If nothing is found, look up one level.
# if(!$type) {
#   $type = $HeadingsID{$type[$#type]};
# }
# print("type=$type\n");

if($type and !-e "hide.txt") {
  print PAGELINKS "$page\t$type\tdtsp$relpath/$outname\n";
}

my $tmp = $page;
$page =~ s/(\d*).*/\1/;      # get the first number in page.  123-129 is 123.
$page = $tmp if(!$page);     # If no number, use everything.  Hack for xxii.

"<a href=\"http://view.ebookplus.pearsoncmg.com/ebook/linktoebook5.do?platform=1027&bookid=2456&pageid=$page\" target=\"_blank\">";
# Do nothing for now
#"";
}

sub dtsplinkend {
local(%params) = @_;
local($debug) = 1;

# Make some global assignments 

$chap = $params{'chap'};	# global assignment for all to use.
$unit = $params{'unit'};
$next = $params{'next'};        # Used for homework
$prev = $params{'prev'};

$anaflag = $params{'analytics'};
# print("Found cd-dtsp-linkend(%params)\n");
"</a>";
# Do nothing for now
#"";
}

#==============
# spfirstlink
#==============

sub spfirstlink {
local(%params) = @_;
local($debug) = 1;

$anaflag = $params{'analytics'};
# print("Found cd-spfirst-link(%params)\n");
"</a>";
# Do nothing for now
#"";
}

sub spfirstlinkend {
local(%params) = @_;
local($debug) = 1;

$anaflag = $params{'analytics'};
# print("Found cd-spfirst-linkend(%params)\n");
"</a>";
# Do nothing for now
#"";
}

#==============
# bookType
#==============

sub bookType {

# Returns the type of book being processed.
# 'spfirst'  for Signal Processing First
# 'dtsp' for Discrete-Time Signal Processing
# 'tb' for Telecommunication Breakdown
#    print "bookType: $ENV{'BOOKTYPE'}\n";
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
