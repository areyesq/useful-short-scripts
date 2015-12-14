#!/bin/usr/perl

use strict;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::TranscriptMapper;
use Time::HiRes qw (sleep);

my $numAr = scalar(@ARGV);
if( $numAr != 2 ){
   die "\nusage: perl getProteinDomainGenomicCoordiantes.pl <transcript ids file> <output file>\n
   This script retrieves genomic coordinates of the protein domains displayed by the ensembl
   genome browser. The first argument contains a set of ensembl transcript identifiers, one 
   identifier per line. The output will be a tab separated file with information of the protein
   domains";
}

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org', # alternatively 'useastdb.ensembl.org'
    -user => 'anonymous',
    -port => 3337,  # COMMENT THIS LINE IF GRCH38 is needed
);

open(TRS, "@ARGV[0]");
open(OUT, ">@ARGV[1]");

my $transcript_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Transcript' );
while(<TRS>){
  sleep(.3);
  chop();
  print "$_\n";
  my $stable_id = $_;
  my $transcript = $transcript_adaptor->fetch_by_stable_id($stable_id);
  my $tamano = length($transcript);
  next if($tamano == 0);
  my $translation = $transcript->translation();
  next if($translation == "");
  my $pfeatures = $translation->get_all_DomainFeatures();
  next if(!$pfeatures);
  while (my $pfeature = shift @{$pfeatures}) {
     my $logic_name = $pfeature->analysis()->logic_name();
     my $transcript_mapper = Bio::EnsEMBL::TranscriptMapper->new ($transcript);
     my @genomic_coords = $transcript_mapper->pep2genomic($pfeature->start,$pfeature->end);
     my $something=$pfeature->display_id();
     my $something2=$pfeature->idesc();
     foreach my $genomic_coord(@genomic_coords){
       print OUT "$stable_id\t$logic_name\t$something\t$something2\t$genomic_coord->{start}\t$genomic_coord->{end}\n";
     }
  }
}

close(TRS);
close(OUT);
