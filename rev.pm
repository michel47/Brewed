#!/usr/bin/perl
# $Id: rev.pl,v 0.9.7 2020-6-22 12:33:28 michelc Exp $
#
# revised rev !
# $Birth: 1162959076$
# --
# rev.pl 7469c @(#) MYC :  8-Nov-06 (YGL) 05:11:16 - WW45 [c]
#
# - 4164b: update rev to include major and release
# 

# $Source: /my/perl/scripts/rev.pl $
# $prev: ~$
package REV;
our $dbug = 0;

if ($0 == __FILE__) {
   my $tic = shift || time;
   my @rev = &rev($tic);
   printf "major: %s\nrev:%s\nlowid:%s\nyy:%s\n",@rev;
   exit $?;
}


sub rev {
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday,$yday) = (localtime($_[0]))[0..7];
  my $rweek=($yday+&fdow($_[0]))/7;
  my $rev_id = int($rweek) * 4;
  my $low_id = int(($wday+($hour/24)+$min/(24*60))*4/7);
  my $revision = ($rev_id + $low_id) / 100;
  if ($dbug) {
  printf "year: %03d\n",$yy+1900;
  printf "rweek: %02d.%s\n",$rweek,chr(ord('a')+$low_id);
  printf "rev_id: %s\n",$rev_id;
  printf "low_id: %s\n",$low_id;
  printf "revision: %s\n",$revision;
  }
  my $major = int($rev_id/10)/10,
  my $rev = $rev_id%10+$low_id;
  return (wantarray) ? ($major,$rev,$low_id,$yy) : $revision;
}
sub fdow {
   my $tic = shift;
   use Time::Local qw(timelocal);
   ##     0    1     2    3    4     5     6     7
   #y ($sec,$min,$hour,$day,$mon,$year,$wday,$yday)
   my $year = (localtime($tic))[5]; my $yr4 = 1900 + $year ;
   my $first = timelocal(0,0,0,1,0,$yr4);
   $fdow = (localtime($first))[6];
   #printf "1st: %s -> fdow: %s\n",&hdate($first),$fdow;
   return $fdow;
}

1;
