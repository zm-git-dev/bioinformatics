#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($fIn,$fOut,$region);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"i:s"=>\$fIn,
	"r:s"=>\$region,
	"o:s"=>\$fOut,
			) or &USAGE;
&USAGE unless ($fIn and $fOut and $region);
open In,$region;
my %region;
while (<In>) {
	chomp;
	next if ($_ eq ""||/^$/ ||/#/);
	my ($chr,$pos1,$pos2)=split(/\t/,$_);
	$region{$chr}{join("\t",$pos1,$pos2)}=1;;
}
close In;
open In,$fIn;
my %info;
my $head;
while (<In>) {
	chomp;
	next if ($_ eq ""||/^$/);
	if (/^#/) {
		$head=$_;
	}else{
		my ($chr,$pos,undef)=split(/\t/,$_);
		foreach my $posi (sort keys %{$region{$chr}}) {
			my ($pos1,$pos2)=split(/\t/,$posi);
			if ($pos > $pos1 && $pos < $pos2) {
				push @{$info{$chr}{$posi}},$_;
			}
		}
	}
}
close In;
open Out,">$fOut";
print Out "#\@chr\tpos1\tpos2";
print Out 
close Out;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################
sub ABSOLUTE_DIR #$pavfile=&ABSOLUTE_DIR($pavfile);
{
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir \n$in";
		exit;
	}
	chdir $cur_dir;
	return $return;
}

sub USAGE {#
        my $usage=<<"USAGE";
Contact:        long.huang\@majorbio.com;
Script:			$Script
Description:
	fq thanslate to fa format
	eg:
	perl $Script -i -o -k -c

Usage:
  Options:
  -i	<file>	input file name
  -o	<file>	output file name
  -r	<file>	input region file
  -h         Help

USAGE
        print $usage;
        exit;
}
