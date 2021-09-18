#!/bin/env perl

# No getopt in my Msys, so perl has to be used

use strict;
use Getopt::Long;

my $dryRun;
my $resources;
my $tagNames;
my $tagVals;
# parsing command line arguments

GetOptions(
	'resources|r=s' => \$resources,
	'tag-names|n=s' => \$tagNames,
	'tag-values|v=s'  => \$tagVals,
	'dry-run!'  => \$dryRun
);

&usage() unless($resources and $tagNames);

# format parameters according to AWS requirement
$resources =~ s/,/ /g; # replace comma by space
my @names = split ',', $tagNames;
my @vals = split ',', $tagVals,-1;

if($#names != $#vals) { 
	die "The number of tag names and values	differ: '$tagNames' vs '$tagVals': $!"; 
}

my $tagStr='';
for(my $i=0; $i <= $#names; $i++)
{
	$tagStr .= " Key='".$names[$i]."',Value='".$vals[$i]."'";
}

# launch the instance now
my $cmd="aws ec2 create-tags $dryRun \\
--resources $resources \\
--tags $tagStr";

print '-' x 40, "\n", "Running command:\n$cmd\n", '-' x 40, "\n";
my $instIds = `$cmd`;
if($?) { die "Creating tags with '$cmd' failed\n"; }

print "The following tags were added for the '$resources':\n";
for(my $i=0; $i <= $#names; $i++)
{
	print join(" = ", $names[$i], $vals[$i]), "\n";
}

print "Work done!\n";

exit 0;
## functions ##
sub usage 
{
	print <<USAGE;
	Usage: $0 [options]

	This program creates/overrides the tags for EC2 resources, such as
	instances, AMIs, etc. It is essentially the wrapper of 'aws ec2
	create-tags', so refer to that command for more info.

	Available options are:

	--dry-run,        switch option, if provided, the command is
	                  tested but not run.
	--resources,      a list of resources to apply tags, e.g.,
	                  ami-1,ami-2,instance-1. Use comma to
					  separate list elements.
	--tag-names,      the tag names separated by comma, quote them if
	                  any space, like: key1,'key 2',key3
	--tag-values,     the values for the above tags in the same order,
	                  like: val1,val2,'val 3'.
USAGE
	exit 1;
}

