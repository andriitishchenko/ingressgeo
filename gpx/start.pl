#!/usr/bin/perl

#generate file
#grep -o -E '({"l([^}]*("type":"portal")[^}]*)})' testIN.txt > out.txt

#test 5 records
#grep -o -E '({"l([^}]*("type":"portal")[^}]*)})' testIN.txt | head -n5 | grep .  > out.txt
use utf8;
use Math::Trig;
# use strict;
# use warnings;
use JSON;
no warnings 'experimental::smartmatch';

# use Data::Dumper;
binmode(STDOUT,':utf8');

sub createGPX(@);

system("clear");
############################
#50.453426, 30.478263  - off

# DEFAULTS
$myLocationLAT = 50.453426;
$myLocationLONG = 30.478263;
$allowRadius = 500; #meters
############################

my $key = undef;

foreach my $arg (@ARGV) {

    if ( $key && ($arg  ~~ ['-c', '-r']) ) {
        die "Invalid arguments\n -c <lat,long>\n -r <radius in meters>\n";
    } 
    elsif ( !$key && !($arg  ~~ ['-c', '-r']) ) {
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

    if ($arg eq '-c') {
      $key = "-c";
    }
    elsif ($arg eq '-r') {
      $key = "-r";
    }
}


unlink glob "./gpx/*.*";

$__static_rad = pi/180 ;
$__static_radius = 0.00046; #~45meters !!!

$json = JSON->new->allow_nonref;
my $file = 'out.txt';
open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {   
    $json_item = $json->decode($line);
    $lat = $json_item->{"latE6"} / 1000000;
    $long = $json_item->{"lngE6"} / 1000000;
    $title = $json_item->{"title"};
    $title =~s/[^\wа-я\s]+/_/ig;
	
my $a = sin(($lat - $myLocationLAT)*$__static_rad*0.5) ** 2;
my $b = sin(($long - $myLocationLONG)*$__static_rad*0.5) ** 2;
my $h = $a + cos($lat*$__static_rad) * cos($myLocationLAT*$__static_rad) * $b;
my $theta = 2 * asin(sqrt($h)) * 6372797.560856; 

if ($theta > $allowRadius) {
	next;
}
	
	print "$title === $theta \n";	

    for (my $i = 0; $i<8 ;$i++) {
    	#$alfa = 45*$i;
    	$rand=45*$i;# $alfa+int(rand(45));
    	# $nfname= $title."-".$rand."_".$i;
      $nfname= $title."-".$rand;
		  $radians  = deg2rad($rand);
	    $bx = $lat + $__static_radius*cos($radians);
	 	  $by = $long + $__static_radius*sin($radians);
      createGPX($nfname,$bx,$by);
    }

 	# print $lat.",".$long."  ".$bx.",".$by."\n";

    # print  Dumper($bx, $by);
    # print $title;
}
close $info;

sub createGPX(@)
{
  $filename = $_[0];
  $lat = $_[1];
  $lon = $_[2];
  my $heredoc =<<"END_HERE_1";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx
xmlns="http://www.topografix.com/GPX/1/1"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
version="1.1">
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
