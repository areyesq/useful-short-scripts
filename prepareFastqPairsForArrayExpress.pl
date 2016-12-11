################################
## GET OPTIONS FROM COMMANDS####
################################

use Getopt::Long;
GetOptions(
   'f|read1=s' => \$read1,
   'r|read2=s' => \$read2,
   'p|prefix=s' => \$prefix
);

sub parseOneRead
{
   my $nh = shift;
   my @thisRead;
   for(my $i = 0; $i < 4; $i++){
     $thisRead[$i] = <$nh>;
     chop $thisRead[$i];
#     print "$thisRead[$i]\n";
   }
   return @thisRead;
}

sub printRead
{
   my $nh = shift @_;
   my $rd = shift @_;
   my @readInfo = @_;
   my $newReadName = $readInfo[0].$rd;
   print $nh "$newReadName\n$readInfo[1]\n$readInfo[2]\n$readInfo[3]\n";
}

################################
###### OPEN INPUT FILES ########
################################


if( $read1 =~ /\.gz$/ ){
   open($handler1, "gunzip -c $read1 |") or die "I could not open the read 1 file\n";
}else{
   open($handler1, $read1) or die "I could not open the read 1 file\n";
}

if( $read2 =~ /\.gz$/ ){
   open($handler2, "gunzip -c $read2 |") or die "I could not open the read 2 file\n";
}else{
   open($handler2, $read2) or die "I could not open the read 2 file\n";
}

################################
###### OPEN OUTPUT FILES #######
################################

die "The output file already exist\n" if -e "$prefix.fastq";

open( $output, ">$prefix.fastq" ) or die "I did not open output";

while(not eof $handler1 and not eof $handler2) {
   my @first = &parseOneRead($handler1);
   my @second = &parseOneRead($handler2);
   my @verifyName1 = split(/ /, $first[0]);
   my @verifyName2 = split(/ /, $second[0]);
   if( $verifyName1[0] ne $verifyName2[0] ){
      print "Error: Something is wrong with the order of the read pairs\n";
      last;
   }
   &printRead($output, "/1", @first);
   &printRead($output, "/2", @second);
}

close($handler1);
close($handler2);
close($output);

