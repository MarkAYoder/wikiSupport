#!/usr/local/gnu/bin/perl
# Contains:
#  labview(%params) - processed the <cd-LabVIEW> tag
# %params comes from getparams($tag)

#"$Log: head.pl,v $
#";
#'CODEBASE="ftp://ftp.ni.com/support/labview/runtime/windows/8.0/English/LVRunTimeEng.exe">

$Header = '$Header: /home/ratbert5/myoder/cd/visible2/support/lib/RCS/head.pl,v 2.3 2000/04/17 21:35:50 myoder Exp myoder $';

require 'htmlscan.pl';
require 'constants.pl';

#==============
# LabVIEW
#==============

sub labview {
local(%params) = @_;
local($debug) = 1;

# Make some global assignments 

$src    = $params{'src'};	# global assignment for all to use.
$width  = $params{'width'} + 25;
$height = $params{'height'} + 50;
$topVI  = $params{'top'};
$topVI =~ s/_/ /g;              # Hack so top paramter can have spaces in it.
# print "topVI=$topVI\n";
$topVI = $src unless $topVI;
$vers   = $params{'vers'};

# print "labview called with src=$src, topVI=$topVI width=$width and height=$height vers=$vers\n" if $debug;
#
#  Version 8.2 or 8.5
#
my $num, $num2, $id, $cnx;
if ($vers eq '82') {
	$num = '8.2.1'; $num2 = '821'; $id = 'AE'; $num3 = '82';
}
if ($vers eq '85') {
	$num = '8.5';   $num2 = '85';  $id = 'AF'; $num3 = '85';
}
if ($vers eq '82' or $vers eq '85') {
  "<a name=\"LabVIEW\"></a>
<script type=\"text/javascript\">
<!--
var BrowserDetect = {
	init: function () {
		this.OS = this.searchString(this.dataOS) || \"an unknown OS\";
	},
	searchString: function (data) {
		for (var i=0;i<data.length;i++)	{
			var dataString = data[i].string;
			var dataProp = data[i].prop;
			this.versionSearchString = data[i].versionSearch || data[i].identity;
			if (dataString) {
				if (dataString.indexOf(data[i].subString) != -1)
					return data[i].identity;
			}
			else if (dataProp)
				return data[i].identity;
		}
	},
	searchVersion: function (dataString) {
		var index = dataString.indexOf(this.versionSearchString);
		if (index == -1) return;
		return parseFloat(dataString.substring(index+this.versionSearchString.length+1));
	},	
	dataOS : [
		{	string: navigator.platform,
			subString: \"Win\",
			identity: \".win\"
		},
		{	string: navigator.platform,
			subString: \"Mac\",
			identity: \".mac\"
		},
		{	string: navigator.platform,
			subString: \"Linux\",
			identity: \"Linux\"	
		}
	]
};
BrowserDetect.init();
// -->
</script>

<script type=\"text/javascript\">
<!--
/**************************************************/
var VINAME = \"$src\";	/* set this value */
var LLBNAME = \"LabVIEW/builds/$src/$src\";	/* set this value */
var VIWIDTH = $width		/* set this value */
var VIHEIGHT = $height		/* set this value */
/* LLB's Should be uploaded in the format  .win.llb, .mac.llb .linux.llb */
/**************************************************/

if(BrowserDetect.OS.search(/.win|.mac/) != -1) {
document.write('<object classid=\"CLSID:A40B0AD4-B50E-4E58-8A1D-8544233807$id\" ');
document.write('	codebase=\"http://ftp.ni.com/support/softlib/labview/labview_runtime/$num/windows/LabVIEW${num2}RuntimeEngineFull.exe\" ');
document.write('	width=\"' + VIWIDTH + '\" height=\"' + VIHEIGHT + '\">');
document.write('<param name=\"SRC\" value=\"'+ LLBNAME + BrowserDetect.OS + '.llb\">');
document.write('<param name=\"LVFPPVINAME\" value=\"'+ VINAME + '.vi\">');
document.write('<param name=\"REQCTRL\" value=\"false\">');
document.write('<param name=\"RUNLOCALLY\" value=\"true\">');
document.write('<embed src=\"'+ LLBNAME + BrowserDetect.OS + '.llb\" ');
document.write('	reqctrl=\"true\" runlocally=\"true\" ');
document.write('	type=\"application/x-labviewrpvi$num3\" ');
document.write('	pluginspage=\"http://digital.ni.com/express.nsf/bycode/cnx$num3\" ');
document.write('	lvfppviname=\"'+ VINAME + '.vi\" width=\"' + VIWIDTH + '\" height=\"' + VIHEIGHT + '\">');
document.write('</object>');

document.write('<a href=http://www.ni.com/academic target=_blank');
document.write('        onClick=\"javascript:urchinTracker (\\'NI Link\\'); \">');

document.write('<br><img align=right src=\"" . findpath('PoweredByLabVIEWh.jpg') . "\" border=0>');
document.write('</a>');
document.write('<font size=-2 color=gray>' + BrowserDetect.OS + ' Version 8.5.1         <a href=\"" . findpath('labview.htm') . "\" target=_blank><font size=-2 color=blue>LabVIEW tips</font></a></font><p>');

} else {  // Not .mac or .win
    document.write('<p>Sorry, but the <b> ' + BrowserDetect.OS + '</b> platform is not supported at this time.<p>');
}
// -->
</script>
";

}
#
#  Default version (8.2)
#
elsif($vers eq '') {
my $border = 1;
if($width == 0) {$border = 0;}
"<TABLE BORDER = $border BORDERCOLOR = #000000><TR><TD>
<OBJECT ID=\"LabVIEWControl\"
\tCLASSID=\"CLSID:A40B0AD4-B50E-4E58-8A1D-8544233807AE\"
\tWIDTH=$width HEIGHT=$height
\tCODEBASE=\"ftp://ftp.ni.com/support/labview/runtime/windows/8.2/LVRunTimeEng.exe\">
<PARAM name=\"SRC\" value=\"LabVIEW/builds/$src/$src.llb\">
<PARAM name=\"LVFPPVINAME\" value=\"$topVI.vi\">
<PARAM name=\"REQCTRL\" value=true>
<PARAM name=\"RUNLOCALLY\" value=true>
<EMBED SRC=\"LabVIEW/builds/$src/$src.llb\"
\tLVFPPVINAME=\"$topVI.vi\" 
\tREQCTRL=true
\tRUNLOCALLY=true
\tTYPE=\"application/x-labviewrpvi82\"
\tWIDTH=$width HEIGHT=$height
\tPLUGINSPAGE=\"http://digital.ni.com/express.nsf/express?openagent&code=exck2m&\">
</EMBED>
</OBJECT>
</TD></TR></TABLE>";
} else {
  print("##### Version $vers not known #####\n");
}

}

1;
