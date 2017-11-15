#!/usr/bin/env perl 
use strict;
use warnings;
my $BEGIN_TIME=time();
use Getopt::Long;
my ($proc,$bamlist,$dOut,$dShell,$ref,$dict,$gff);
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
my $version="1.0.0";
GetOptions(
	"help|?" =>\&USAGE,
	"bam:s"=>\$bamlist,
	"gff:s"=>\$gff,
	"out:s"=>\$dOut,
	"proc:s"=>\$proc,
	"dsh:s"=>\$dShell,
			) or &USAGE;
&USAGE unless ($bamlist and $dOut and $dShell and $gff);
$proc||=20;
mkdir $dOut if (!-d $dOut);
$dOut=ABSOLUTE_DIR($dOut);
$bamlist=ABSOLUTE_DIR($bamlist);
mkdir $dShell if (!-d $dShell);
$dShell=ABSOLUTE_DIR($dShell);
$gff=ABSOLUTE_DIR($gff);
open SH,">$dShell/11.cnv-calling.sh";
open In,$bamlist;
open Out,">$dOut/cnv.filter.list";
while (<In>) {
	chomp;
	next if ($_ eq "" ||/^$/);
	my ($sampleID,$bam)=split(/\s+/,$_);
	print SH "export  LD_LIBRARY_PATH=/mnt/ilustre/app/medical/tools/zlib-1.2.8/:/mnt/ilustre/app/dna/Others/yeppp-1.0.0/binaries/linux/x86_64/:/mnt/ilustre/app/medical/tools/root-6.04.10/lib/:/mnt/ilustre/app/pub/gcc/5.1.0/lib64/:/mnt/ilustre/app/dna/software/lib/:/usr/lib64/:/mnt/ilustre/app/pub/lib64/:\$LD_LIBRARY_PATH &&";
	print SH "cnvnator -root $dOut/$sampleID.root -tree $bam &&";
	print SH "cnvnator -root $dOut/$sampleID.root -his 300 -d  $dOut/ &&";
	print SH "cnvnator -root $dOut/$sampleID.root -stat 300 &&";
	print SH "cnvnator -root $dOut/$sampleID.root -partition 300 &&";
	print SH "cnvnator -root $dOut/$sampleID.root -call 300 > $dOut/$sampleID.cnv &&";
	print SH "perl $Bin/bin/cnv_anno.pl -i $dOut/$sampleID.cnv -g $gff -o $dOut/$sampleID.cnv.anno \n";
	print Out "$sampleID\t$dOut/$sampleID.cnv.anno\n";
}
close In;
close SH;
close Out;
my $job="perl /mnt/ilustre/users/dna/.env//bin/qsub-sge.pl  --Resource mem=3G --CPU 1 --maxjob $proc $dShell/11.cnv-calling.sh";
`$job`;
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
  -bam	<file>	input bamlist file
  -gff	<file>	input gff file
  -out	<dir>	output dir
  -proc <num>	number of process for qsub,default 20
  -dsh	<dir>	output shell dir
  -h         Help

USAGE
        print $usage;
        exit;
}
