#!/bin/usr/perl

use strict;
use Getopt::Std;

my $numAr = scalar(@ARGV);

#my $feature = "";
getopts('b:');
our($opt_b);
my $feature = $opt_b || "gene_id";

#print "$feature\n";

if( $numAr != 5 ){
   die "\nusage: perl scriptDefineIntrons.pl -b gene_id <annotation gtf> <subset file> <output gtf>\n
   This script subsets a gtf file based on a specified attribute (-b), and writes a new gtf file containing 
   only the values indicated in the 'subset file'. The annotation file needs to be in gtf format, as the ones 
   provided by ENSEMBL. The subset file is a text file containing one value per line. This script is useful, for example,
   if one wants a gtf file containing only a set of specific transcripts (e.g. only protein coding).\n\n";
}

my $file = $ARGV[0];
my $transcripts = $ARGV[1];
my $output = $ARGV[2];

open(INPUT, $transcripts) or die "The subsetting values file could not be opened\n";
my %transcripts;
print "\nparsing values...\n";
while(<INPUT>){
   $_ =~ /^(\S+)*/;
   $transcripts{$1} = 1;
}
close(INPUT);

die "The output file already exist, please remove it or rename the output parameter.\n" if -e "$output";

open(OUTPUT, ">$output");
open(ANNOTATION, $file) or die "The annotation file could not be opened.\n";
print "\nsubsetting gtf file based on $feature...\n\n";
while(<ANNOTATION>){
  $_ =~ /.*$feature \"(\S+)\".*/;
  if( $transcripts{$1} == 1 ){
    print OUTPUT $_;
  }
}
close(ANNOTATION);
close(OUTPUT);
