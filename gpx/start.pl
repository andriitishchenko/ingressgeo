#!/usr/bin/perl

#grep -o -E '({"l([^}]*("type":"portal")[^}]*)})' testIN.txt > out.txt
#grep -o -E '({"l([^}]*("type":"portal")[^}]*)})' testIN.txt | sed 's/$/,/g'|  > out.txt
#grep -o -E '({"l([^}]*("type":"portal")[^}]*)})' testIN.txt | head -n5 | grep .  > out.txt

use Math::Trig;
# use strict;
use warnings;
use JSON;
use Data::Dumper;

############################
#50.453426, 30.478263  - off


# CUSTUMIZE
$myLocationLAT = 50.453426;
$myLocationLONG = 30.478263;
$allowRadius = 500; #meters
############################

system("clear");
unlink glob "./gpx/*.*";

$__static_rad = pi/180 ;
$__static_radius = 0.00047; #~45meters !!!

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
	# print $title."\n";
	# next;
    for (my $i = 1; $i<9 ;$i++) {
    	$alfa = 45*$i;
    	$rand=45*$i;# $alfa+int(rand(45));
    	$nfname= "gpx/".$title."-".$rand."_".$i.".gpx";
		$radians  = deg2rad($rand);
	    $bx = $lat + $__static_radius*cos($radians);
	 	$by = $long + $__static_radius*sin($radians);

my $heredoc =<<"END_HERE_1";
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx
xmlns="http://www.topografix.com/GPX/1/1"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
version="1.1" 
creator="gpx-poi.com">
   <wpt lat="$bx" lon="$by">
      <time>2014-11-07T09:12:05Z</time>
      <name>p1</name>
   </wpt>
</gpx>
END_HERE_1

	open(my $fh, '>:encoding(UTF-8)', $nfname) or die "Не могу открыть файл '$nfname'";
	print $fh $heredoc;
	close($fh);

    }

 	# print $lat.",".$long."  ".$bx.",".$by."\n";

    # print  Dumper($bx, $by);
    # print $title;
}

close $info;