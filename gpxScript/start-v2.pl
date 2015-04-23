#!/usr/bin/perl

# perl -MCPAN -e shell
# install Encode::Escape;

#generate file

#grep -o -E '\[("p")[^\]]*\](.*?)\]' testIN.txt > out.txt
#grep -o -E '(\["p"[^]]*](.*?)])' inl2.txt > outl2.txt

#test 5 records
#grep -o -E '(\["p"[^]]*](.*?)])' inl2.txt | head -n5 | grep .  > out.txt


use lib '/opt/local/lib/perl5/site_perl/5.16.1';
use utf8;
use Math::Trig;
# use strict;
# use warnings;
use JSON;

# use Unicode::Escape;
# use Encode::Escape;
# use Encode::Escape::Unicode;

# use URI::Escape;
use Encode qw( decode );
# use URI::Escape;

no warnings 'experimental::smartmatch';

use Data::Dumper;
# binmode(STDOUT,':utf8');

binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, ":encoding(utf8)";

sub createGPX(@);

# system("clear");
############################
#50.453426, 30.478263  - off

# DEFAULTS
$myLocationLAT = 50.453426;
$myLocationLONG = 30.478263;
# $myLocationLAT = 50.454069;
# $myLocationLONG = 30.474492;

# $myLocationLAT = 50.452441;
# $myLocationLONG = 30.479698;

$allowRadius = 50000; #meters
############################

$radiusEarthKilometres=6372797.560856;
$distanceMetres = 40;
# $angle = 45;

#     $initialBearingRadians = deg2rad($angle);
#     $startLatRad = deg2rad($myLocationLAT);
#     $startLonRad = deg2rad($myLocationLONG);
#     $distRatio = $distanceMetres / $radiusEarthKilometres;
#     $distRatioSine = sin($distRatio);
#     $distRatioCosine = cos($distRatio);
#     $startLatCos = cos($startLatRad);
#     $startLatSin = sin($startLatRad);

#     $endLatRads = asin(($startLatSin * $distRatioCosine) + ($startLatCos * $distRatioSine * cos($initialBearingRadians)));

#     $endLonRads = $startLonRad + atan2(
#             sin($initialBearingRadians) * $distRatioSine * $startLatCos,
#             $distRatioCosine - $startLatSin * sin($endLatRads));

# printf "%f,%f\n",rad2deg($endLatRads),rad2deg($endLonRads);

# die "terminate";
print "############################################\n";

use I18N::Langinfo qw(langinfo CODESET);
    my $codeset = langinfo(CODESET);
use Encode qw(decode);
    @ARGV = map { decode $codeset, $_ } @ARGV;


my $key = undef;
my $filter = undef;
foreach my $arg (@ARGV) {

    if ( $key && ($arg  ~~ ['-c', '-r', '-f']) ) {
        die "Invalid arguments\n -c <lat,long>\n -r <radius in meters>\n  -f <filter>\n";
    } 
    elsif ( !$key && !($arg  ~~ ['-c', '-r', '-f']) ) {
        die "Undefined argument:\n $arg";
    }

    if ( $key && $key eq '-c') {
      @values = split(',', $arg);
      if (@values < 2) {
        die "Invalid coordinates:\n -c $arg";
      }
      ($var1,$var2) = @values;
      $myLocationLAT = $var1;
      $myLocationLONG = $var2;
      $key = undef;
    }
    elsif ($key && $key eq '-r') {
      $param = int($arg);
      $key = undef;
      $allowRadius = $param;
    }
    elsif ($key && $key eq '-f') {
      $filter = lc($arg);
      $key = undef;
    }

    if ($arg eq '-c') {
      $key = "-c";
    }
    elsif ($arg eq '-r') {
      $key = "-r";
    }
    elsif ($arg eq '-f') {
      $key = "-f";
    }
}

# print $filter;
# die;

unlink glob "./gpx/*.*";

$json = JSON->new->allow_nonref;
my $file = 'outl2.txt';
open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {   


    my $str = "{\"a\":$line}";
    $test= $json->decode($str);

    # print $test->{"a"}[2] ;
    # @elements  = $test->{"a"};
    $lat = $test->{"a"}[2] / 1000000;
    $long = $test->{"a"}[3] / 1000000;
    my $str = $test->{"a"}[8];
    # $str =~s/[,]//ig;
    $title = $str;

    # $title = $json->decode($str);


    
    
    # $title = $json->decode($elements[8]);

    # $json_item = $json->decode($line);
    # Dumper($json_item[0]);
    # print $json_item[3];
    # $lat = $json_item[2] / 1000000;
    # $long = $json_item[3] / 1000000;
    # $title = $json_item[8];
 
    $title =~s/[^\w\dа-я\s]+/_/ig;
    # print $title, $lat , $long;
    # die;
	
my $a = sin( deg2rad($lat - $myLocationLAT)*0.5) ** 2;
my $b = sin( deg2rad($long - $myLocationLONG)*0.5) ** 2;
my $h = $a + cos(deg2rad($lat)) * cos(deg2rad($myLocationLAT)) * $b;
my $theta = 2 * asin(sqrt($h)) * 6372797.560856; 

if ($filter && (index(lc($title), $filter) < 0)) {
  next;
}

if ($allowRadius>0 && $theta > $allowRadius) {
	next;
}
	
	print "$title === $theta \n";	
  createGPX($title,$lat,$long);

    for (my $i = 0; $i<8 ;$i++) {
    	#$alfa = 45*$i;
    	$angle=45*$i;# $alfa+int(rand(45));
    	# $nfname= $title."-".$rand."_".$i;
      $nfname= $title."-".$angle;

    $initialBearingRadians = deg2rad($angle);
    $startLatRad = deg2rad($lat);
    $startLonRad = deg2rad($long);
    $distRatio = $distanceMetres / $radiusEarthKilometres;
    $distRatioSine = sin($distRatio);
    $distRatioCosine = cos($distRatio);
    $startLatCos = cos($startLatRad);
    $startLatSin = sin($startLatRad);

    $endLatRads = asin(($startLatSin * $distRatioCosine) + ($startLatCos * $distRatioSine * cos($initialBearingRadians)));

    $endLonRads = $startLonRad + atan2(
            sin($initialBearingRadians) * $distRatioSine * $startLatCos,
            $distRatioCosine - $startLatSin * sin($endLatRads));

      # printf "%f,%f\n    %d %f,%f\n",$lat,$long ,$angle, rad2deg($endLatRads),rad2deg($endLonRads);

      createGPX($nfname,rad2deg($endLatRads),rad2deg($endLonRads));
    }

 	# print $lat.",".$long."  ".$bx.",".$by."\n";

    # print  Dumper($bx, $by);
    # print $title;
}
close $info;
print "############################################\n";

sub createGPX(@)
{
  my $filename = $_[0];
  my $lat = $_[1];
  my $lon = $_[2];
  my $heredoc =<<"END_HERE_1";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx version="1.1" creator="Xcode">
   <wpt lat="$lat" lon="$lon">
      <time>2014-11-07T09:12:05Z</time>
      <name>$filename</name>
   </wpt>
</gpx>
END_HERE_1

    open(my $fh, '>:encoding(UTF-8)', "./gpx/$filename.gpx") or die "Couldn't create file '$filename'";
    print $fh $heredoc;
    close($fh);
}
