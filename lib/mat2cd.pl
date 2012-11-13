#!/usr/local/gnu/bin/perl

# This file reads the MatlabDataBase and lookups up matlab
# keywords and replaces them with URLs to the matlab index.

#$Log: mat2cd.pl,v $
#Revision 1.6  1995/06/19  18:21:46  myoder
#Added 1; to the end so it will work with 'require'.
#
#Revision 1.5  1995/06/19  18:16:53  myoder
#*** empty log message ***
#
#Revision 1.4  1995/06/19  18:12:56  myoder
#Fixed it again.
#
#Revision 1.3  1995/06/19  18:10:59  myoder
#Fixed comment bug.
#
# Revision 1.2  1995/06/01  19:02:40  myoder
# Major change from being passed the matlab code to process to
# getting the matlab code from @allwords.
#
# Revision 1.1  1995/05/22  15:39:41  myoder
# Initial revision
#
$Header = '$Header: /a/crowe/export/home/crowe3/ee2200cd/support/lib/RCS/mat2cd.pl,v 1.6 1995/06/19 18:21:46 myoder Exp $';

# Translate special html characters

sub htmlchar {
  s/&/&amp;/g;
  s/\</&lt;/g;
  s/\>/&gt;/g;
  s/\"/&quot;/g;
}

# Write an html anchor, and keep track of how many have been
# written using the global variable $anchor_count

$anchor_count = 0;

sub anchor_url{
  local($url,$name) = @_;
  $anchor_count++;
#  return("<a href = \"$url\">$name<\/A>");
  $url =~ s?/database/bookcd/CD-ROM?/research/DSP/courses/ee2200/ee2200cd/visible/?;
return("<a href = \"$url\">$name<\/A>");
}

###########################
# main matlab routine
###########################
sub matlab {
local(@matwords, @linewords, %htmlmaster);
my $debug = 0;

# print "matlab called\n";
# print "@allwords\n";

# $db_file = "MatlabDataBase";		# this is where all the subs are

# dbmopen(%htmlmaster, $db_file, 0444) or
#	die "Cannot open subsitution database $db_file";

#my $print_db = 1;
#if($print_db) {
#	print "----------------\n";
#	while (($key,$val) = each %htmlmaster) {
# 	print $key, ' = ', $val, "\n";
#	}
#print "----------------\n";
#}	# if($print_db)

undef(@outbuff);

#my $tmp;
#foreach $tmp (@allwords) {
#	print "allwords = $tmp\n";
#}

while(@allwords) {
	$_ = shift(@allwords);
	print "$_" if $debug;
	last if(/\/cd-matlab/);
	@linewords = split(/(\W)/);	# split on non-words.

	#foreach $line (@linewords) {
	#	print "linewords[0] = $line\n";
	#	}
	# print "@linewords\n";

	push(@matwords, @linewords);
}
pop(@matwords);		# get rid of <
shift(@allwords); 	# get rid of >

push(@outbuff, "<pre>\n");

foreach $word (@matwords) {
#  print "Checking $word\n";
  if($htmlmaster{$word}) {
#    print "Found $word maps to $htmlmaster{$word}\n";
    push(@outbuff,&anchor_url($htmlmaster{$word}, $word));
  }
  else {
    push(@outbuff, $word);
  }

}	# foreach $word

push(@outbuff, "</pre>");

# dbmclose(%data);

join("",@outbuff)
}

1;
