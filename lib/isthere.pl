#!/usr/local/gnu/bin/perl

# Pick an icon based on whether the file is there or not.

#$Log: isthere.pl,v $
#Revision 1.6  1996/04/29  13:48:38  myoder
#Added a second argument.  If the first isn't there the second
#is checked.
#
#Revision 1.5  1995/06/19  18:27:38  myoder
#Added 1; at the end so it will work with 'require'.
#
#Revision 1.4  1995/06/19  18:26:52  myoder
#*** empty log message ***
#
#Revision 1.3  1995/06/19  18:16:51  myoder
#*** empty log message ***
#
#Revision 1.2  1995/06/19  18:10:54  myoder
#Fixed comment bug
#
# Revision 1.1  1995/05/22  15:38:13  myoder
# Initial revision
#
$Header = '$Header: /a/crowe/export5/ee2200cd/support/lib/RCS/isthere.pl,v 1.6 1996/04/29 13:48:38 myoder Exp $';

# Translate special html characters

sub isthere {
	    local($html, $index) = @_;

	if(-e $html) {
		return("<cd-ybullet>");
	} elsif($index && -e $index) {
		return("<cd-ybullet>");
	} else {
		return("<cd-underconstruct>");
	}
}

1;
