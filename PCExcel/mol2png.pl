#!/usr/bin/perl
#
# mol2png.pl    Norbert Haider, University of Vienna, 2005
#
# Script reads MDL MOL or SDF files, extracts the molecular
# structures (i.e., the connection tables) and generates 2D
# graphical images in PNG format by piping the data through the 
# mol2ps utility program and Ghostscript.
#
# Requirements: mol2ps must be installed in your search path,
# Ghostscript must be installed and the "gs" command must be in
# your search path.


# =============== user customizable parameters: ===============

$bitmapdir = "./bitmaps"; # where to store the output files
$digits = 6;              # filenames will be 000001.png, 000002.png, etc.
$mol2psopt = "";          # options for mol2ps, e.g. "--showmolname=on"
$scalingfactor = 0.22;    # 0.22 gives good results

# =============================================================

if ($#ARGV < 0) {
  print "Usage: mol2png.pl <inputfile>\n";
  exit;
}

$infile = $ARGV[0];
open (SDF, "<$infile") || die ("cannot open input file $infile!");

if ( ! -d $bitmapdir) {
  mkdir $bitmapdir;
  print "created new output directory: $bitmapdir\n";
}

$counter = 0;
$li      = 0;
$buf     = "";
$mol     = "";
$txt     = "";
$lbl     = "";
$ct      = 1;
$badmols = 0;

while ($line = <SDF>) {
  $line =~ s/\r//g;      # remove carriage return characters (DOS/Win)
  if (substr($line,0,4) eq '$$$$') {
    $counter ++;
    if ($ct eq 1) {
      $mol = $buf;
      $txt = "";
    } else {
      $txt = $buf;
    }
    if (valid_mol($mol) eq 1) {
      $fname = $counter;
      while (length($fname) < $digits) { $fname = "0" . $fname; }
      $fname = $bitmapdir . "/" . $fname . ".png";
      process_mol($mol,$fname,$mol2psopt,$scalingfactor);
    } else {
      $counter --;
      $badmols ++;
      #print "all-zero molfile skipped!\n";
    }
    $buf = "";
    $txt = "";
    $mol = "";
    $ct  = 1;
  } else {
    if (substr($line,0,1) eq '>') { 
      if ($ct eq 1) {
        $mol = $buf;
        $buf = $line;
      }
      $ct = 0; 
    }
    $buf = $buf . $line;
  }
}        # end while ($line....

# check for any remaining molecules in the input buffer

if ($ct eq 1) {
  $mol = $buf;
}

if ((length($mol) > 20) && (valid_mol($mol) eq 1)) {
  $counter ++;
  $fname = $counter;
  while (length($fname) < $digits) { $fname = "0" . $fname; }
  $fname = $bitmapdir . "/" . $fname . ".png";
  process_mol($mol,$fname,$mol2psopt,$scalingfactor);
}

print "$counter records processed in total\n";
print "$badmols records ignored\n";


# =============================================================

sub valid_mol() {
  $testmol = shift;
  $zerolines = 0;
  @xyzline = split(/\n/, $testmol);
  for ($i = 0; $i <= $#xyzline; $i++) {
    $testline = $xyzline[$i];
    $testline =~ s/\ +/:/g;
    @xyz = split(/:/, $testline);
    $xval = $xyz[1];
    $yval = $xyz[2];
    $zval = $xyz[3];
    if ((index($xval,"0.0000") >= 0) && (index($yval,"0.0000") >= 0) && 
       (index($zval,"0.0000") >= 0)) { $zerolines ++; }
  }
  if ($zerolines > 1) {
    return 0;
  } else {
    return 1;
  }
}

sub process_mol() {
  $molecule = shift;
  $filename = shift;
  $mopt = shift;
  $sf = shift;
  $molecule =~ s/\"/\\\"/g;
  if (index($molecule,"M  END") < 0) { $molecule = $molecule . "M  END\n"; }	
  #print "$molecule\n";
  $molps = filterthroughcmd($molecule,"mol2ps $mopt - ");
  #print "$molps\n";
  $bb =  filterthroughcmd($molps,"gs -q -sDEVICE=bbox -dNOPAUSE -dBATCH  -r300 -g500000x500000 - ");
  #print "$bb\n";
  @bbrec =   split(/\n/, $bb);
  $bblores = $bbrec[0];
  $bblores =~ s/%%BoundingBox://g;
  chomp($bblores);
  $bblores = ltrim($bblores);
  @bbcorner = split(/\ /, $bblores);
  $bbleft = $bbcorner[0];
  $bbbottom = $bbcorner[1];
  $bbright = $bbcorner[2];
  $bbtop = $bbcorner[3];
  $xtotal = ($bbright + $bbleft) * $sf;
  $ytotal = ($bbtop + $bbbottom) * $sf;
  if (($xtotal > 0) && ($ytotal > 0)) {
    $molps = $sf . " " . $sf . " scale\n" . $molps;  ## insert the PS "scale" command
    #print "low res: $bblores  .... max X: $bbright, max Y: $bbtop \n";
    print "writing file $filename with output dimensions of $xtotal x $ytotal pt\n";
  } else {
    $xtotal = 99;
    $ytotal = 55;
    $molps = "%!PS-Adobe
    /Helvetica findfont 14 scalefont setfont
    10 30 moveto
    (2D structure) show
    10 15 moveto
    (not available) show
    showpage\n";
    print "writing empty file\n";
  }	
  $gsopt1 = " -r300 -dGraphicsAlphaBits=4 -dTextAlphaBits=4 -dDEVICEWIDTHPOINTS=";
  $gsopt1 = $gsopt1 . $xtotal . " -dDEVICEHEIGHTPOINTS=" . $ytotal;
  $gsopt1 = $gsopt1 . " -sOutputFile=" . $filename;
  $gscmd = "gs -q -sDEVICE=pnggray -dNOPAUSE -dBATCH " . $gsopt1 . " - ";
  #print "$gscmd\n";
  system("echo \"$molps\" \| $gscmd");
}

sub filterthroughcmd {
  $input   = shift;
  $cmd     = shift;
  open(FHSUB, "echo \"$input\"|$cmd 2>&1 |");   # stderr must be redirected to stdout
  $res      = "";                               # because the Ghostscript "bbox" device
  while($line = <FHSUB>) {                      # writes to stderr
    $res = $res . $line;
  }
  return $res;
}

sub ltrim() {
  $subline1 = shift;
  $subline1 =~ s/^\ +//g;
  return $subline1;
}
