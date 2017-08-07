
$numAr = scalar(@ARGV);

if( $numAr != 2 ){
   die "usage: perl scriptDefineIntrons.pl <flattened gtf> <output gtf>\n";
}

$file = $ARGV[0];
$output = $ARGV[1];


open(FILE, "$file") or die "I did not open input";
open(OUTPUT, ">$output") or die "I did not open output";
my $previousGene = "";
$contPart=1;
while(<FILE>){
   next if $_ =~ /aggregate\_gene/;
   $_ =~ /gene_id \"(\S+)\"/;
   $currentGene = $1;
   @lineinfo = split( /\t/, $_ );
   $currentStart = $lineinfo[3];
   $currentEnd = $lineinfo [4];
   $_ =~ /transcripts \"(\S+)\"/;
   $transcripts = $1;
   $_ =~ /exonic\_part\_number \"(\S+)\"/;
   $exonPart = $1;
   $_ =~ /gene\_id \"(\S+)\"/;
   $geneID = $1;
   if( $previousGene eq $currentGene ){
     if( $currentStart - $previousEnd > 1 ){
       $nPart = $exonPart-1;
       $nPart = sprintf "%03d", $nPart;
       $nPart = $nPart."i";
       $end = $currentStart - 1;
       $start = $previousEnd + 1;
       $binPart = sprintf "%03d", $contPart;
       print OUTPUT "$lineinfo[0]\t$lineinfo[1]\texonic_part\t$start\t$end\t.\t$lineinfo[6]\t.\ttranscripts \"$transcripts\"; exonic_part_number \"$nPart\"; gene_id \"$geneID\"; bin_part_number \"$binPart\"\n";       
       $contPart+=1;
      }
   }else{
      $contPart=1;
   }
   $_ =~ s/exonic\_part\_number \"(\S+)\"/exonic\_part\_number \"\1e\"/g;
   chomp $_;
   $binPart = sprintf "%03d", $contPart;
   print OUTPUT "$_; bin_part_number \"$binPart\"\n";
   $contPart+=1;
   $previousGene = $currentGene;
   $previousEnd = $currentEnd;
}
close(FILE);
