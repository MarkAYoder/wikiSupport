# Contains global constants.
# $Headings - unit headings for auto generated tables of contents.

#'$Log: constants.pl,v $
#Revision 1.19  2000/04/17  21:35:00  myoder
#Added chapters 10, 11, 12, and 13.
#
#Revision 1.18  1997/10/01  22:01:27  myoder
#Removed notes.
#Added HeadingsID.
#
#Revision 1.17  1997/09/11  20:41:49  myoder
#Added chapid.
#
#Revision 1.16  1997/09/10  22:27:10  myoder
#Added the exercise column.
#
#Revision 1.15  1997/06/19  22:28:18  myoder
#Changed @chapter for june-97 chapter renumbering.
#
#Revision 1.14  1996/11/15  14:21:49  myoder
#Fixed a bug that had the wrong link when the left arrow on a demo was
#pushed.
#
#Revision 1.13  1996/09/02  16:04:13  myoder
#Split chapter 6 and changed the background colors.
#
#Revision 1.12  1996/07/09  17:47:42  myoder
#Converted to lowercase.
#
#Revision 1.11  1996/06/04  21:06:05  myoder
#Changed Chapter to Chapters
#
#Revision 1.10  1996/03/15  20:58:42  myoder
#Added Notes column.
#
#Revision 1.9  1996/03/15  16:00:13  myoder
#Added Notes column and a few more $Next $Prev's.
#
#Revision 1.8  1996/02/05  18:38:33  myoder
#Added more $Prev and $Next enteries.
#
#Revision 1.6  1996/01/24  21:33:52  myoder
#Added Chapter 1 info for $Next and $Prev.  Need to add for other chaps.
#
#Revision 1.5  1995/12/13  20:12:35  myoder
#Removed "Overview" the @Headings.
#
#Revision 1.3  1995/08/21  19:54:08  myoder
#Removed Solution and Matlab from Headings.
#
#Revision 1.2  1995/06/19  19:08:31  myoder
#fixed comments
#
#Revision 1.1  1995/06/19  19:07:41  myoder
#Initial revision
#
#';
$Header = '$Header: /home/ratbert5/myoder/cd/visible2/support/lib/RCS/constants.pl,v 1.19 2000/04/17 21:35:00 myoder Exp myoder $';

@Headings = ("", "chapters", "demos", "demosLV", "labs", "labsLV", "example", "exercise", "homework");
@Headings = ("", "chapters", "demos", "demosLV", "labs", "labsLV", "example", "exercise", "homework", "figures", "baf");
# This is the order for dtsp
@Headings = ("", "chapters", "figures", "baf", "homework", "labs", "demosLV");

@chapter = ("0", "1sines", "2complex", "3phasors", "4spect", 
"5samplin", "6fir", "7firfreq", "8ztrans", "9feedbac", "10specta");

@chapter = ("0", "1intro", "2sines", "3spect", 
"4samplin", "5fir", "6firfreq", "7ztrans", "8feedbac", "9specta", "10appa");

@chapter = ("0", "01intro", "02sines", "03spect",
"04samplin", "05fir", "06firfreq", "07ztrans", "08feedbac",
"09contin", "10confrq", "11confor", "12confil",  "13specta", "14appa");

# "5samplin", "6fir", "7ztrans", "8feedbac", "9spectan");

@chapid = ("0", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", 
"11", "12", "13", "A");
# @HeadingsID = ("", "Chapters", "Demos", "Labs", "Exercises", "Homework");
%HeadingsID = (
'chapters', 'Chapters',
'notes',    'Notes',
'demos',    'Demos - MATLAB',
'demosLV',  'Demos - LabVIEW',
# 'demosLV',  'Demos',
'labs',     'Labs - MATLAB',
# 'labs',     'MATLAB Projects',
'labsLV',     'Labs - LabVIEW',
'example',  'Examples',
'exercise', 'Exercises',
'homework', 'Homework',
'figures',  'Live Figures',
'baf',      'Build-a-Figure',
'contents', 'Contents'
    );

my $title = 'Signal Processing First';

# The following are the page numbers for the Matlab hw, hw extras, and hw solution

our @pdfhw  = (0, 0, 1, 3, 6, 8, 9, 10, 13, 15, 16);
our @pdfhwe = (0, 0, 1, 7, 9, 19, 29, 33, 37, 49, 51);
our @pdfhws = (0, 0, 2, 10, 13, 26, 42, 50, 56, 74, 77);

# Here are the eBook page number

our @eBook = (0, 1, 9, 99, 153, 274, 374, 493, 623, 716,
	      792, 890, 942, 980, 1043, 1056, 1061, 1082,
	      1091);

our %eBookPreface = (
		     'figures', 'xxii',
		     'baf',     'xxiii',
		     'homework','xxiii',
		     'labs',    'xxiv',
		     'demosLV', 'xxiv',
);
