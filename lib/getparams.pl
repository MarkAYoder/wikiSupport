#!/usr/local/gnu/bin/perl

#"$Log: getparams.pl,v $
#Revision 1.8  1996/01/17  18:42:06  myoder
#Handles NULL ("") string such as alt="" now.
#
#Revision 1.7  1995/10/10  14:07:01  myoder
#Keywords are mapped to lower case.
#
#Revision 1.6  1995/06/19  18:26:40  myoder
#Added 1; at the end so it will work with 'require'.
#
#Revision 1.5  1995/06/19  18:16:45  myoder
#*** empty log message ***
#
#Revision 1.4  1995/06/19  18:10:36  myoder
#Fixed comment bug
#
#Revision 1.3  1995/06/01  19:00:12  myoder
#Added putparams() which undoes what getparams() did.
#
#Revision 1.2  1995/06/01  16:41:30  myoder
#Changed comment character to #
#
#Revision 1.1  1995/06/01  15:58:44  myoder
#Initial revision
#";
$Header = '$Header: /a/crowe/export5/ee2200cd/support/lib/RCS/getparams.pl,v 1.8 1996/01/17 18:42:06 myoder Exp $';

sub getparams {
local(@here, @keys, @values, %data, $value, $key);
local($tag) = @_;

local($debug) = 0;

$_ = $tag;

print "**$_**\n" if $debug;

s/\s*=\s*/=/g;		# remove stuff around ='s

#print "$_\n" if $debug;

@here = split(/[ \t\n>]+/);	# split on white space and >
@here = &quotewords('[\s>]+', 0, $_);

#print "here=@here\n" if $debug;
#  my $i = 0;
#  foreach (@here) {
#      print "$i: <$_>\n";
#      $i++;
#  }


grep(do {
	($key, $value) = /(\w+)=([\S]+)/;		# Pull stuff off before and after =
	($key, $value) = /(\w+)=(.+)/;		# Pull stuff off before and after =
	print "key = $key, value = $value\n" if $debug;
	$value =~ s/"//g;	# strip off quotes.
	if( ! $value) { $value = '""'; }	# check for empty string
	$key =~ y/A-Z/a-z/;	# Make lower case
	$data{$key} = $value if $key;			# save it in an assoc array
	0;
}, @here);

# print "hereDone=@here\n";

if($debug) {
@keys = keys %data;
@values = values %data;
while ($#keys >= 0) {
    print pop(@keys), '=', pop(@values), "\n";
}
}  # end if($debug)

return(%data);
}

#=============
# putparams
#=============

sub putparams {
local($tag) = "";
local(%params) = @_;

local($debug) = 0;

@keys = keys %params;
@values = values %params;
while ($#keys >= 0) {
	$tag .= pop(@keys) . '="' . pop(@values) . '" ';
	}
$tag;
}

1;
