# $Log: htmlscan.pl,v $
#Revision 1.7  1997/01/24  14:43:33  myoder
#none
#
#Revision 1.6  1996/03/15  21:02:34  myoder
#Tags are now mapped to lower case.
#
#Revision 1.5  1996/02/06  17:40:05  myoder
#Removed a stray ;
#
#Revision 1.4  1996/02/06  17:37:45  myoder
#Fixed bug in foundtag();  Forgot to init $tag.
#
#Revision 1.3  1995/07/18  15:12:47  myoder
#None?
#
#Revision 1.2  1995/07/06  17:02:06  myoder
#FIxed comment character.
#
#Revision 1.1  1995/07/06  17:00:19  myoder
#Initial revision
#;

$Header = '$Header: /database/bookcd/support/lib/RCS/htmlscan.pl,v 1.7 1997/01/24 14:43:33 myoder Exp $';
#===========================
# htmlscan
#===========================
# Scans through array of strings looking for < followed by an
# html extenstion.  If it is found it is expanded, if not it is
# just passed through.

use Text::ParseWords;

sub htmlscan {
local(@allwords) = @_;
local($tag) = '';

while(@allwords) {
	$word = shift(@allwords);

	if($word eq ">") {	# A complete html tag has been found
		$tag .= $word;
		&foundtag($tag);
		$tag = '';
		}
	elsif($word eq "<" || $tag) {	# the start of a tag
		$tag .= $word;
		}
	else {	# no tag, keep passing things through
		print HTML $word;
	}
}	# while(@allwords)
}	# htmlscan()

#===========================
# foundtag
#===========================
sub foundtag {
local($tag) = @_;
# local($debug) = 0;

print "Tag $tag\n" if $debug;
if(0) {
  @fields = split(/[<\s>]/, $tag);	# Parse so we can get to the first word
} else {
  $tag =~ /<(.*)>/;
  @fields = quotewords(" ", 0, $1);
}
if(0) {
  foreach $tmp (@fields) {
    print "fields[] = $tmp\n";
  }
  print "\n";
}

# Lookup the word in database

$_ = @fields[0];
tr/[A-Z]/[a-z]/;# Map to lower-case

$value = $data{$_};
if($value) {			# True if it was there
	print "Found tag, $tag, with value, $value\n" if $debug;
	if(substr($value,0,1) eq "&") {
#		print "Found function $value\n" if $debug;
		%params = &getparams($tag);
		$value = eval $value;		# database has name of function to call
#		print "Processing chap $chap, unit $unit\n" if $debug;
		}
	$tag = $value;
	} # if($value)
print HTML "$tag";
}

1;
