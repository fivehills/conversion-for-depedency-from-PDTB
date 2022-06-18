open(F,$ARGV[0]);
open(Ftemp,">mytemp.txt");
while(<F>){
	chomp;
	@array=split /\|/;
	$tmpNode=$array[14];
	$tmpNode=~s/^\s//g;
	&splitPossibleMultiNodes($tmpNode);

	$tmpNode=$array[20];
	$tmpNode=~s/^\s//g;
	&splitPossibleMultiNodes($tmpNode);
}
close F;
close Ftemp;

open(Ftemp,"mytemp.txt");
open(Ftemp1,">mytempp1.txt");
while(<Ftemp>){
	chomp;
	if($hash{$_}){next;}
	else{
		print Ftemp1 "$_\n";
		$hash{$_}=1;
	}
}
close Ftemp;
close Ftemp1;

open(IN,"mytempp1.txt");
open(OUT,">mytempout.txt");
@out=sort {$a->[1] <=>$b->[1] or $b->[2] <=>$a->[2]} map[(split)],<IN>;
foreach $out(@out) {
	#print OUT "@$out\n";
	foreach $item (@$out) {
		print OUT $item."\t";
	}
	print OUT "\n";
}
close OUT;

#@myx=<Ftemp>;
#@myx=sort {$a<=>$b} @myx;
#open(F,">mytemp1.txt");
#print F @myx;

sub splitPossibleMultiNodes()
{
	local($tmpspan)=@_;
	if($tmpspan=~/;/){
		my @array=split /;/,$tmpspan;
		foreach $item (@array) {
			my($a,$b)=split /\.\./,$item;
		#	if( defined $hash{$item}){next;}
		#	else {
				print Ftemp "$item\t$a\t$b\t";
				print Ftemp abs($a-$b); print Ftemp "\n";
				$hash{$item}=1;
		#	}
		}
	}
	else {
		my($a,$b)=split /\.\./,$tmpspan;
		#if( defined $hash{$tmpspan}){next;}
		#else{
			print Ftemp "$tmpspan\t$a\t$b\t";
			print Ftemp abs($a-$b); print Ftemp "\n";
			$hash{$tmpspan}=1;
		#}
	}
}

&test();

open(Fdebug,">nodeindex_debug.tmp");
open(Findex,">nodeIndex.tmp");
open(Ftmp,">result_tmp.tmp");
sub test
{
	#open(F,"temp.txt");
	open(F,"mytempout.txt");
	$comp=0; $order=0;
	while(<F>){
		chomp;
		print "++++++++$_++++++\n";;
		@array=split /\t/;
		$order++;
		$start=$array[1];
		$end=$array[2];
		$span=$array[0];
		print "\t$span++++++\n";
		if($end-$start<=6){$sentid4span{$span}=0;next;}      #616
		push(@sets,$span);
		if($start<=$comp){
			#print "\t".$_."\n";
		}
		if($end>=$comp){
			$comp=$end;
		}
		$Span4end{$comp}=$span;
		$Order4end{$comp}=$order;

	}
	close F;
}

$id=0;
@sets=sort {$a<=>$b} @sets;
for($i=0;$i<=$#sets;$i++) {
#	print "##\$sets[$i]:$sets[$i]\n";
	@results=();@results=&checkInclusion($i,$sets[$i],@sets);
	print "\t$sets[$i]==";
	if ($#results==-1) {
		print "($sets[$i])==\n";
		push(@baseSets,$sets[$i]); #basesets
		$id++;
		$sentid4span{$sets[$i]}=$id;
    }
	else{
		print "++";
		foreach $item(@results){
			#$sentid4span{$sets[$i]}.=
			print "($item)";$constitute4span{$sets[$i]}.=$item."\t";
		}
		print "==\n";
	}
}

print "BaseSets:\n";
print Fdebug "BaseSets:\n";

foreach $item(sort {$sentid4span{$a}<=>$sentid4span{$b}} keys %sentid4span){
	print $item."~~~~~~~~~~~~~~$sentid4span{$item}\n";
	print Fdebug "\t".$item."\t$sentid4span{$item}\n";
	print Findex $item."\t$sentid4span{$item} \n";
}
print "CompSets:\n";print Fdebug "CompSets:\n";
foreach $item ( sort {$a<=>$b} keys %constitute4span){
#	print $item."~~~~~~~~~~~~~~$constitute4span{$item}\n";
	print $item."~~~~~~~~~~~~~~"; print Fdebug "\t".$item."\t->\t";print Findex $item."\t";
	print "ooooooooo$constitute4span{$item}000000000\n";
	@itemarray=split /\t/,$constitute4span{$item};
	foreach $spans(@itemarray){
		if(defined $sentid4span{$spans}) { 
			print "$spans($sentid4span{$spans}) ";
			$sentid4span{$item}.=$sentid4span{$spans}."\,"; #617
			print Fdebug "$spans($sentid4span{$spans})  ";
			print Findex "$spans($sentid4span{$spans}) ";
		}
		if(defined $constitute4span{$spans}){
			print Fdebug $spans."+ ";
			foreach $temp (@{$spans{$constitute4span{$spans}}}) {
				@temparray=split /\t/,$temp;
				foreach $temp1 (@temparray) {
					print $temp1." "; print Fdebug "$temp1  "; print Findex "$temp1 ";
				}
			}
			#print "*$spans($constitute4span{$spans}) "
        }
#       $sentid4span{$item}=$sentid4span{$itemarray[$#itemarray]};
	}
	#$sentid4span{$item}=$sentid4span{$itemarray[$#itemarray]}; 617
	print "****$itemarray[$#itemarray]***$sentid4span{$itemarray[$#itemarray]}\n";
	
	print "\n";
	print Fdebug "\n";
	print Findex "\n";
	
}

print "############################################\n";
foreach $temp (sort {$a<=>$b} keys %sentid4span) {
	print $temp."\t".$sentid4span{$temp}."\n";
}
print "############################################\n";

sub checkInclusion()
{
	local($a,$aSpan,@sets)=@_;
	@me=split /\.\./,$aSpan;
	@myresults=();
	#print "\t$a=$aSpan=$#sets\n";
	for( $i1=0;$i1<$a;$i1++){
		#print $sets[$i1]."\+";
		@items=split /\.\./,$sets[$i1];
#		print "\t($me[0],$me[1]),($items[0],$items[1]): "; 
		$result=&Isinclusion($me[0],$me[1],$aSpan,$items[0],$items[1],$sets[$i1]);
		if ($result>1) {
			push(@myresults,$result);
		}
	}
	#print "**";
	for( $i1=$a+1;$i1<=$#sets;$i1++){
		#print $sets[$i1]."\+";
		@items=split /\.\./,$sets[$i1];
#		print "\t($me[0],$me[1]),($items[0],$items[1]): ";
		$result=&Isinclusion($me[0],$me[1],$aSpan,$items[0],$items[1],$sets[$i1]);
		if ($result>1) {
			push(@myresults,$result);
		}
		if ($items[0]>$me[1]) {last; }
	}
	#print "\n";
	return @myresults;
}


#&Isinclusion($ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3]);
sub Isinclusion
{
	local($a1,$a2,$aa,$b1,$b2,$bb)=@_;
##	if($a1<=$b1+6 && $a2>=$b2-6){
	if($a1<=$b1+6 && $a2>=$b2-6){
#		print "\tInclusion\n";
		return $bb;
	}
	else {
#		print "\tNo\n";
		return NULL;
	}
}


#open(F,"wsj_0618")or die "error";
open(F,$ARGV[0])or die "error";
open(Fout,">result.txt");

$n=0;
#for($i=0;$i<=32;$i++){print "$i\t";}
print "\n";
while(<F>){
	chomp;$n++;
	@array=split /\|/;
	$tmpNode1=$array[14];
	$tmpNode1=~s/^\s//g;
	$tmpNode1=&checkTmpNode($tmpNode1);#618
	$tmpNode2=$array[20];
	$tmpNode2=~s/^\s//g;
	$tmpNode2=&checkTmpNode($tmpNode2);#618
	$tmpRelation=$array[8];
	@result=();
    #print $tmpNode1."\t".$tmpNode2."\t"."ToDo\t";
	@attr=split /\./,$tmpRelation;
	if($#attr==2){
		#print $attr[0]."\t".$attr[1]."\t".$attr[2];
		if($attr[2]=~/arg(\d)/i){
			$flag=$1; 
			if($flag==1){
				$tmpNode1result=$sentid4span{$tmpNode1};$tmpNode2result=$sentid4span{$tmpNode2};
				print "$tmpNode1 [$tmpNode1result]=$tmpNode2 [$tmpNode2result]:distance=".abs($tmpNode1result-$tmpNode2result);print "\n";
#				$result[0]=$tmpNode1;$result[1]=$tmpNode2;$result[2]="ToBe";
				$result[0]=$tmpNode1result;$result[1]=$tmpNode2result;$result[2]=abs($tmpNode1result-$tmpNode2result);
			}
			if($flag==2){
				$tmpNode1result=$sentid4span{$tmpNode1};$tmpNode2result=$sentid4span{$tmpNode2};;
				#print "[$tmpNode1result][$tmpNode2result]\n";
				print "flag2= $tmpNode1 [$tmpNode1result]=<$tmpNode2> [$tmpNode2result]:distance=".abs($tmpNode1result-$tmpNode2result);print "\n";
#				$result[0]=$tmpNode2;$result[1]=$tmpNode1;$result[2]="ToBe";
				$result[0]=$tmpNode2result;$result[1]=$tmpNode1result;$result[2]=abs($tmpNode1result-$tmpNode2result);
			}
		}
		else{
			$tmpNode1result=$sentid4span{$tmpNode1};$tmpNode2result=$sentid4span{$tmpNode2};
			#print "[$tmpNode1result][$tmpNode2result]\n";
			print "flag3= $tmpNode1 [$tmpNode1result]=$tmpNode2 [$tmpNode2result]:distance=".abs($tmpNode1result-$tmpNode2result);print "\n";
#			$result[0]=$tmpNode1;$result[1]=$tmpNode2;$result[2]="ToBe";
			$result[0]=$tmpNode1result;$result[1]=$tmpNode2result;$result[2]=abs($tmpNode1result-$tmpNode2result);;
		}
		$result[3]=$attr[0];$result[4]=$attr[1];$result[5]=$attr[2];
	}
	if($#attr==1){
		$tmpNode1result=$sentid4span{$tmpNode1};$tmpNode2result=$sentid4span{$tmpNode2};
		#print "[$tmpNode1result][$tmpNode2result]\n";
		print "flag4= $tmpNode1 [$tmpNode1result]=$tmpNode2 [$tmpNode2result]:distance=".abs($tmpNode1result-$tmpNode2result);print "\n";
#		$result[0]=$tmpNode1;$result[1]=$tmpNode2;$result[2]="ToBe";
		$result[0]=$tmpNode1result;$result[1]=$tmpNode2result;$result[2]=abs($tmpNode1result-$tmpNode2result);
		$result[3]=$attr[0];$result[4]=$attr[1];$result[5]="NA";
	}
	if($#attr==-1){
		$tmpNode1result=$sentid4span{$tmpNode1};$tmpNode2result=$sentid4span{$tmpNode2};
		#print "[$tmpNode1result][$tmpNode2result]\n";
		print "flag5= $tmpNode1 [$tmpNode1result]=$tmpNode2 [$tmpNode2result]:distance=".abs($tmpNode1result-$tmpNode2result);print "\n";
#		$result[0]=$tmpNode1;$result[1]=$tmpNode2;$result[2]="ToBe";
		$result[0]="".$tmpNode1result;$result[1]=$tmpNode2result;$result[2]=abs($tmpNode1result-$tmpNode2result);
		$result[3]=$array[0];$result[4]="NA";$result[5]="NA";
	}
	print "--------------------------------\n";
	for($i=0;$i<=5;$i++){
		print $result[$i]."\t";
		print Ftmp $result[$i]."\t";
	}
	print"\n";
	print Ftmp "\n";
	print "\n\n==================================\n";

	for($i=0;$i<=5;$i++){
		print Fout $result[$i]."\t";
	}
	print Fout "\n";

}
close F;
&refineTmp();
&refineNodeindex();
&refineResult();

sub refineResult()#TODO
{
	open(Fresult,"result_tmp.tmp");
	while(<Fresult>){
		chomp;

	}
	close Fresult;
}

sub refineNodeindex()
{
	open(Fnewindex,">nodeindex_refined.tmp");
	open(Findex,"nodeIndex.tmp");
	while(<Findex>){
		chomp;
		local($span,$number)=split /\t/;
		if($number=~/\(/){
			print Fnewindex $span."\t";
			@mymatches=$number=~/\((\d+)\)/g;
			foreach $temp (@mymatches) {
				print Fnewindex $temp.",";
			}
			print Fnewindex "\n";
			#print Fnewindex "**$_\n";
		}
		else {print Fnewindex $_."\n";}
	}
	close Findex;
}

sub refineTmp()
{
	open(Ftmp,"result_tmp.tmp");
	open(Fnew,">result_refined.tmp");
	while(<Ftmp>){
		chomp;
		local @array1=split /\t/;
		$node1=$array1[0];
		$node2=$array1[1];
		%hash=();$refined_node1="";
		if($node1=~/,/){
			@array2=split /,/,$node1;
			for($i=0;$i<=$#array2;$i++){
				if(defined $hash{$array2[$i]}){}
				else {$refined_node1.=$array2[$i].","; $hash{$array2[$i]}=$array2[$i];}
			}
		}
		else{$refined_node1=$array1[0];}
		%hash=();$refined_node2="";
		if($node2=~/,/){
			@array2=split /,/,$node2;
			for($i=0;$i<=$#array2;$i++){
				if(defined $hash{$array2[$i]}){}
				else {$refined_node2.=$array2[$i].","; $hash{$array2[$i]}=$array2[$i];}
			}
		}
		else{$refined_node2=$array1[1];}
		print Fnew $refined_node1."\t",$refined_node2."\t"."$array1[2]\t$array1[3]\t$array1[4]\t$array1[5]\n";
	}
}

sub checkTmpNode() #if there is more nodes in Node1 or Node2, delete the node which length is less than 6. especailly for line 3 in wsj0618
{
	local($tmpNode)=@_;
	if($tmpNode=~/;/){
		@tmpArray=split /;/,$tmpNode;
		$backTmpNode="";
		foreach $item (@tmpArray) {
			($start,$end)=split /\.\./,$item;
			if($end-$start<=6){}
			else {$backTmpNode.=$item." ";}
		}
		$backTmpNode=~s/^\s+//g;$backTmpNode=~s/\s+$//g;
		return $backTmpNode;
	}
	else {return $tmpNode;}
}