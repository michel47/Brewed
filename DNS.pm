#!/usr/bin/perl

# Note:
#   This work has been done during my time at healthium
# 
# -- Copyright GCM, 2017,2019 --
# 


package Brewed::DNS;
require Exporter;
@ISA = qw(Exporter);
# Subs we export by default.
@EXPORT = qw();
# Subs we will export if asked.
#@EXPORT_OK = qw(nickname);
@EXPORT_OK = grep { $_ !~ m/^_/ && defined &$_; } keys %{__PACKAGE__ . '::'};

use strict;

# The "use vars" and "$VERSION" statements seem to be required.
use vars qw/$dbug $VERSION/;
# ----------------------------------------------------
our $VERSION = sprintf "%d.%02d", q$Revision: 0.0 $ =~ /: (\d+)\.(\d+)/;
my ($State) = q$State: Exp $ =~ /: (\w+)/; our $dbug = ($State eq 'dbug')?1:0;
# ----------------------------------------------------
$VERSION = &version(__FILE__) unless ($VERSION ne '0.00');

if ($dbug) {
  eval "use YAML::Syck qw(Dump);";
}
# -------------------------------------------------------------------
our $fdow = &fdow($^T);
# -----------------------------------------------------------------------

# =======================================================================
if (__FILE__ eq $0) {

}
# =======================================================================

# -----------------------------------------------------------------------
sub get_rrecord {
   my ($domain,$type) = @_;
   my @rrecord = ();
   use Net::DNS;
   my $res = Net::DNS::Resolver->new();
   $res->debug(0);
   $res->persistent_udp(1);
   $res->retrans(2);
   $res->retry(3);
   if ($type eq 'RP') { $res->udp_timeout(3); } else { $res->udp_timeout(6); }
   my $rr_query = $res->query($domain, $type);
   if ($rr_query) { # see [*]({{site.search}}=RFC1035)
      foreach my $rr ($rr_query->answer) {
         push @rrecord, { 
           owner => $rr->owner,
           ttl => $rr->ttl,
           class => $rr->class,
#           token => [$rr->token],
#           rdata => [$rr->rdata],
            plain => $rr->plain,
#           generic => $rr->generic,
#           canonical => $rr->canonical,
#           string => $rr->string,
#           rdstring => $rr->rdstring,
#           rdlength => $rr->rdlength,
           type => $rr->type };

         if ($rr->type eq 'A' || $rr->type eq 'AAAA') {
           $rrecord[-1]{address} = $rr->address;
         } elsif ($rr->type eq 'CNAME') {
           $rrecord[-1]{cname} = $rr->cname;
         } elsif ($rr->type eq 'MX') {
           $rrecord[-1]{preference} = $rr->preference;
           $rrecord[-1]{exchange} = $rr->exchange;
         } elsif ($rr->type eq 'TXT') {
           $rrecord[-1]{txtdata} = $rr->txtdata;
         } elsif ($rr->type eq 'RP') {
           $rrecord[-1]{mbox} = $rr->mbox;
           $rrecord[-1]{txtdname} = $rr->txtdname;
         } elsif ($rr->type eq 'NS') {
           $rrecord[-1]{nsdname} = $rr->nsdname;
         } elsif ($rr->type eq 'OPENPGPKEY') {
           $rrecord[-1]{keysbin} = $rr->keysbin;
         } elsif ($rr->type eq 'URI') {
           $rrecord[-1]{priority} = $rr->priority;
           $rrecord[-1]{weight} = $rr->weight;
           $rrecord[-1]{target} = $rr->target;
           $rrecord[-1]{os} = $rr->os;
         } elsif ($rr->type eq 'HINFO') {
           $rrecord[-1]{cpu} = $rr->cpu;
           $rrecord[-1]{os} = $rr->os;
         }
      }

   } else {
     push @rrecord, { error => $res->errorstring, type => $type, domain => $domain };
   }
  return \@rrecord;
}
# -----------------------------------------------------------------------
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
# -----------------------------------------------------------------------
sub version {
  #y ($atime,$mtime,$ctime) = (lstat($_[0]))[8,9,10];
  my @times = sort { $a <=> $b } (lstat($_[0]))[9,10]; # ctime,mtime
  my $vtime = $times[-1]; # biggest time...
  my $version = &rev($vtime);

  if (wantarray) {
     my $shk = &get_shake(160,$_[0]);
     print "$_[0] : shk:$shk\n" if $dbug;
     my $pn = unpack('n',substr($shk,-4)); # 16-bit
     my $build = &word($pn);
     return ($version, $build);
  } else {
     return sprintf '%g',$version;
  }
}
# -----------------------------------------------------------------------
sub rev {
  my ($sec,$min,$hour,$mday,$mon,$yy,$wday,$yday) = (localtime($_[0]))[0..7];
  my $rweek=($yday+&fdow($_[0]))/7;
  my $rev_id = int($rweek) * 4;
  my $low_id = int(($wday+($hour/24)+$min/(24*60))*4/7);
  my $revision = ($rev_id + $low_id) / 100;
  return (wantarray) ? ($rev_id,$low_id) : $revision;
}
# -----------------------------------------------------------------------
1; # $Source: /my/perl/modules/DNS.pm,v $
