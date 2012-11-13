#!/usr/local/gnu/bin/perl
# Contains:
#  makesummary($path) - creates a summary of demo/lab/hw

#"$Log: makesummary.pl,v $
#Revision 1.11  1997/10/13  21:52:38  myoder
#Added 2nd argument to makesummary to tell which unit is being summarized.
#
#Revision 1.10  1997/10/01  22:02:17  myoder
#Removed .mov's.
#
#Revision 1.9  1997/09/09  22:30:36  myoder
#Aded alt= field to images.
#
#Revision 1.8  1997/06/19  22:32:26  myoder
#Looks like some changes with the tape.gif stuff.
#
#Revision 1.7  1996/11/14  23:20:52  myoder
#Added "tape:" and "camera" icons.
#
#Revision 1.6  1996/07/09  17:48:56  myoder
#Converted to lowercase.
#
#Revision 1.5  1996/04/29  13:51:18  myoder
#Checks for both overview.htm and index.htm when calling isthere().
#
#Revision 1.4  1996/03/26  17:28:35  myoder
#Now looks for overview.htm and index.htm of the navigation buttons.
#
#Revision 1.3  1996/03/15  16:01:49  myoder
#Fixed a bug in one of the paths.
#
#Revision 1.2  1996/02/13  21:02:11  myoder
#Changed comment from % to #
#
#Revision 1.1  1996/02/13  20:30:41  myoder
#Initial revision
#
#";

$Header = '$Header: /home/ratbert5/myoder/cd/support/lib/RCS/makesummary.pl,v 1.11 1997/10/13 21:52:38 myoder Exp myoder $';

require 'head.pl';

sub makesummary {
# $num is the chapter number
my($path, $unit, $noshow, $num) = @_;
my($text, $html, $gif, $wav, $mov);

my $veryfirst=1;  # Set if anything at all is found.
my $first=1;  # Used to see if any demos/labs were found

# print "makesummary($path)\n";
if(!-e $path) {
	print "Can\'t find $path\n";
	return;
}
if(-e "$path/overview.wav") {
	    print OUTPUT "<a href=\"$path/overview.wav\">";
	    print OUTPUT "<img style=\"align:center border:none\" alt=\"Click for Audio\" src=\"tape.gif\" />";
	    print OUTPUT "</a>\n";
	}

opendir(DEMOS, $path) || die("$0: Can't open $path\n");
foreach $demo (sort readdir(DEMOS)) {
    $_ = $demo;

    next if($noshow && -e "$path/$demo/hide.txt");

    if(-d "$path/$demo" && $demo ne "." && $demo ne ".." && $demo ne "rcs" ) {
        if($veryfirst) {
	  $veryfirst = 0;
	  print OUTPUT "<table border=\"1\">\n";
	}
        $first=0;
#	print "$_\n";
	$text = "$path/$demo/overview.txt";
	$zip  = "$path/$demo/$demo.zip";
	$html = "$path/$demo/overview.htm";
	$index= "$path/$demo/index.htm";
	$jpg  = "$path/$demo/overview.jpg";
	$png  = "$path/$demo/overview.png";
	$gif  = "$path/$demo/overview.gif";
	$wav  = "$path/$demo/overview.wav";
	$mov  = "$path/$demo/overview.mov";
	$pdf  = "$path/$demo/$demo.pdf";
	$doc  = "$path/$demo/$demo.docx";

	if(-e $text) {
	  print OUTPUT "<tr align=\"left\">\n";

	  if($unit ne "labs" and $unit ne "labsLV" and $unit ne "labsSL" 
				and bookType() ne 'dtsp') {
	    print OUTPUT "<td>";
	    if(-e $jpg) {
	      print OUTPUT "<img alt=\"\" src=\"$jpg\" width=\"64\" height=\"64\" />";
	    } elsif(-e $png) {
	      print OUTPUT "<img alt=\"\" src=\"$png\" width=\"64\" height=\"64\" />";
	    } elsif(-e $gif) {
	      print OUTPUT "<img alt=\"\" src=\"$gif\" width=\"64\" height=\"64\" />";
	    } else {
	      print OUTPUT &isthere($html, $index);
	    }
	    print OUTPUT "</td>\n";
	  } # if ($nit ne "labs")

	  open(TEXT, $text);
#	First line of text if the name of the demo.
	  $tmp = <TEXT>; $tmp =~ s/[\n\r]/ /g;
	  if(-e $html) {
	    print OUTPUT "<td><a href=\"$html\">";
	  } elsif(-e $pdf) {
	    if($unit eq 'homework') {
	      $pdf .= "#pagemode=bookmarks&view=Fit&page=$pdfhw[$num]"
		if($demo eq 'hw');
	      $pdf .= "#pagemode=bookmarks&view=Fit&page=$pdfhwe[$num]"
		if($demo eq 'hwe');
	      $pdf .= "#pagemode=bookmarks&view=Fit&page=$pdfhws[$num]"
		if($demo eq 'hws');
	    }
	    print OUTPUT "<td><a href=\"$pdf\">";
	  } else {
	    print OUTPUT "<td><a href=\"$index\">";
	  }
	  print OUTPUT "<strong>$tmp</strong>";
	  print OUTPUT "</a>";
	  print OUTPUT "</td>";

#	The rest of the text is the description.
	  if(-e "$path/$demo/hide.txt") {
	      print OUTPUT "<td style=\"color:gray\">\n";
	  } else {
	      print OUTPUT "<td>\n";
	  }
	  if(-e $wav) {
	    print OUTPUT "<a href=\"$wav\">";
	    print OUTPUT "<img style=\"border:none\" align=\"right\" alt=\"Click for Audio\" src=\"tape.gif\" />";
	    print OUTPUT "</a>\n";
	  }
	  while(<TEXT>) {
	    s/[\r\n]/ /g;		# Hack to remove \r before \n
	    $_ = "$_\n";
	    print OUTPUT;
	  }
# If there is a zip file, link to it.
	  if(-e $zip)
	    {
#	      print "found $zip\n";
	      print OUTPUT "<a href=\"$zip\"><font size=\"-2\">[Files]</font></a>\n";
	    }

# If there is a docx file, link to it.
	  if(-e $doc)
	    {
#	      print "found $doc\n";
	      print OUTPUT "<a href=\"$doc\"><font size=\"-2\">[docx]</font></a>\n";
	    }

	  print OUTPUT "</td>\n";
	  print OUTPUT "</tr>\n";
	} else {
	  print "No overview.txt for $demo\n";
	}
      }	# if(-d.....
    
  }

if(!$veryfirst) {
  print OUTPUT "</table>\n";
}

if($first and ($unit eq 'demos' or $unit eq 'labs')) {
#  print OUTPUT "<br/>No $unit for this chapter.\n";
}

}

1;
