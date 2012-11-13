# img2pdf.pl
# ----------
# Merge input images into one pdf file.
# 
#    img2pdf.pl outPDFfile imagefile1 [ imagefile2 ... ]
#
# Requires PDFLib: http://www.pdflib.com
# Version 3.02 of PDFLib supports the following images:
#       png, gif, jpeg, tiff

# Jordan Rosenthal, jr@ece.gatech.edu, 16-Aug-2000
#    Rev. 21-Nov-2000 : Changed PDFLib from 3.01 to 3.02

use File::Basename;
use pdflib_pl 3.02;
$OK = 1;
$FAILED = -1;

($output_PDF,@input_IMGs) = @ARGV;
if ( !defined(@input_IMGs) ) { die "Not enough arguments\n" }

# Create a new PDF file and set some parameters
$p = PDF_new();

( PDF_open_file($p,$output_PDF) == $OK ) 
    || die "Could not open PDF file: $!\n";

@suffixlist = ('png','gif','jpeg','jpg','tiff','tif');
foreach $imgfile (@input_IMGs){
    # Get the extension of the image file and convert
    # if necessary to be compatible with the PDFLib's
    # open function
    $ext = lc( ( fileparse($imgfile,@suffixlist) )[2] );
    if ($ext eq "tif") {
    $ext = "tiff";
    } elsif ($ext eq "jpg") {
    $ext = "jpeg";
    }
    # Open the image
    $img = PDF_open_image_file($p, $ext, $imgfile, "", 0);
    if ($img == $FAILED) { die "Could not open image $imgfile:\n" }
    
    
    # Generate a page with the image's dimensions
    $width = PDF_get_value($p, "imagewidth", $img);
    $height = PDF_get_value($p, "imageheight", $img);
    PDF_begin_page($p, $width, $height);
    PDF_place_image($p, $img, 0, 0, 1);
    PDF_end_page($p);

    PDF_close_image($p,$img);
}

# Finish creating the PDF
PDF_close($p);

# Remove the PDF object and free resources

PDF_delete($p);
