#!/usr/bin/perl

&getPrimitive();
sub getPrimitive()
{
	#open(F,"text.txt");
	open(F,"result_refined.tmp");
	while(<F>){
		chomp;
		$flag=0;
		@targetarray=split /\t/;
		$node1=$targetarray[0];
		$node2=$targetarray[1];
		#($node1,$node2)=split /\t/;
		if($node1=~/,/|| $node2=~/,/){ 
			$flag=1;
			if($node1=~/,/){
				$tmpstr1="";
				my @tmps=split /,/,$node1;
				foreach my $item (@tmps) {
					$tmpstr1.=$item." ";
				}
				$tmpstr1=~s/\s+$//g;
				print "\t~-<$tmpstr1>\n";
			}
			else{$tmpstr1=$node1;}
			if($node2=~/,/){
				$flag=1;
				$tmpstr2="";
				my @tmps=split /,/,$node2;
				foreach my $item (@tmps) {
					$tmpstr2.=$item." ";
				}
				$tmpstr2=~s/\s+$//g;
				print "\t~+<$tmpstr2>\n";
			}
			else{$tmpstr2=$node2;}
			#print "## $node1\t$tmpstr\n";
		}
		if($flag ==0){
			if($node1>$node2){$pair=$node2." ".$node1;}
			else{ $pair=$node1." ".$node2;}
			$pri4id{$pair}=$node2;
		}
		if($flag==1){
			$thisSpan=$tmpstr1." ".$tmpstr2;
			@x=split / /,$thisSpan;
			$lastSpan="";
			foreach $item (sort {$a<=>$b} @x) {
				$lastSpan.=$item." ";
			}
			$lastSpan=~s/\s+$//g;
			$pri4id{$lastSpan}=$tmpstr2;
			print "!!!\$pri4id{$lastSpan}=$pri4id{$lastSpan}\n";
		}
	}
	close F;
	foreach $item (sort {$a<=>$b} keys %pri4id) {
		if($pri4id{$item}=~/\s+/){print "<$item>\t=\t$pri4id{$pri4id{$item}}\n";}
		else{
			print "<$item>\t=\t$pri4id{$item}\n";
		}
	}
	print "###################\n";
}

#open(F,"text.txt");
open(F,"result_refined.tmp");
while(<F>){
	chomp;
	#($node1,$node2)=split /\t/;
	@targetarray=split /\t/;
	$node1=$targetarray[0];
	$node2=$targetarray[1];

	#print "\t";
	if($node1=~/,/){$node1=&checkNode($node1);}
	if($node2=~/,/){$node2=&checkNode($node2);}
	print "=[$node1][$node2]\n";
}
close F;


&getLastStep();
sub getLastStep()
{
	#open(F,"text.txt");
	open(F,"result_refined.tmp");
	open(Fout,">Result_fined.txt");
	print "==========getLastStep\n";
	while(<F>){
		chomp;
		$flag=0;
		@targetarray=split /\t/;
		$node1=$targetarray[0];
		$node2=$targetarray[1];
		#($node1,$node2)=split /\t/;
		#print "\t";
		if($node1=~/,/){
			print "\t---[$node1]\n";
			my @tmp=split /,/,$node1;
			@mytmp=sort {$a<=>$b} @tmp;
			$myBackupNode1="";
			foreach my $item (@mytmp) {
				$myBackupNode1.=$item." ";
			}
			$myBackupNode1=~s/\s+$//;
			print "\t***($myBackupNode1):$pri4id{$myBackupNode1}\n";
			if($pri4id{$myBackupNode1}=~/\s+/){
				$node1=$pri4id{$pri4id{$myBackupNode1}};
			}
			else {
				$node1=$pri4id{$myBackupNode1};
			}
		}
		if($node2=~/,/){
			print "\t===[$node2]\n";
			my @tmp=split /,/,$node2;
			@mytmp=sort {$a<=>$b} @tmp;
			$myBackupNode2="";
			foreach my $item (@mytmp) {
				$myBackupNode2.=$item." ";
			}
			$myBackupNode2=~s/\s+$//;
			print "\t***+++($myBackupNode2):$pri4id{$myBackupNode2}\n";
			$node2=$pri4id{$myBackupNode2};
		}
		print "=[$node1][$node2]\n";
		print Fout "$node1\t$node2\t";
		print Fout abs($node1-$node2);
		print Fout "\t";
		print Fout "$targetarray[3]\t$targetarray[4]\t$targetarray[5]\n";
	}
	close F;
}

sub checkNode()
{
	local($node)=@_;
	@array=split /,/,$node;
	if($#array>=1){print "\tvalidate($node)\n";}
	#print "\t##<".$node.">:".$#array."\n";
	if($#array==1){
		if($array[0]>$array[1]){$comp=$array[1]." ".$array[0];}
		else {$comp=$array[0]." ".$array[1];}
		if(defined $pri4id{$comp}){
			#print "\t==[$comp]\t$pri4id{$comp}"."\n";
			return $pri4id{$comp};
		}
	}
}