#!/usr/bin/perl -w
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($dIn,$clist,$dOut,$dShell,$slist);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"dIn:s"=>\$dIn,
	"fqdir:s"=>\$fqdir,
	"out:s"=>\$dOut,
	"dsh:s"=>\$dShell,
			) or &USAGE;
&USAGE unless ($dIn and $dOut and $dShell);
mkdir $dOut if (!-d $dOut);
mkdir $dShell if(!-d $dShell);
$dOut=ABSOLUTE_DIR($dOut);
$dShell=ABSOLUTE_DIR($dShell);
$dIn=ABSOLUTE_DIR($dIn);
open SH,">$dShell/step07.genotype.sh";
print SH "populations -P $dIn -t 8 -m 4 -O $dOut/ --vcf && ";
print SH "sort_read_pairs.pl -p $dIn -s $fqdir -o $dOut/ -r 10"
close SH;
my $job="perl /mnt/ilustre/users/dna/.env//bin//qsub-sge.pl --Queue dna --Resource mem=80G --CPU 8 --Nodes 1 $dShell/step07.genotype.sh";
print  "$job\n";
`$job`;
print "$job\tdone!\n";

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
	-dIn	<dir>	input dir
	-out	<dir>	output dir
	-dsh	<dir>	work shell dir
	-h         Help

USAGE
        print $usage;
        exit;
}
