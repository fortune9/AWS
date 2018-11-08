#!/bin/env perl

# No getopt in my Msys, so perl has to be used

use strict;
use Getopt::Long;

my $defaultAMI='ami-bc86dfaa';
my $amiId;
my $count;
my $type;
my $key;
my $secGrp;
my $subnet;
my $devMap;
my $withPubIp;
my $waitForRun;
# parsing command line arguments

GetOptions(
	'ami|a:s' => \$amiId,
	'count|c:i' => \$count,
	'type|t=s'  => \$type,
	'key|k:s'   => \$key,
	'sec-grp|s:s' => \$secGrp,
	'subnet:s'  => \$subnet,
	'dev-map|d:s' => \$devMap,
	'public-ip|p!' => \$withPubIp,
	'wait|w!'   => \$waitForRun
);

&usage() unless($type);

# set default values
$amiId ||= $defaultAMI;
$count   = 1 unless(defined $count and $count > 0);
#$type='t2.micro'
$key  ||='zzhang';
$secGrp||='sg-05c7a67a';
#$vpc='vpc-168e9973|zymo'
#$subnet='subnet-3309706a' # this is a private subnet
$subnet ||= 'subnet-3209706b'; # this is a public subnet
#$devMap ||= 'file://ec2_devices.json';
$devMap ||= ' ';
$withPubIp = 1 unless(defined $withPubIp);
$withPubIp = $withPubIp? '--associate-public-ip-address' :
'--associate-public-ip-address';

if($devMap)
{
	# if it is a file
	$devMap="file://$devMap" if(-e $devMap);
}

# launch the instance now
my $cmd="aws ec2 run-instances \\
--image-id $amiId --count $count \\
--instance-type $type --key-name $key \\
--security-group-ids $secGrp \\
--subnet-id $subnet --block-device-mappings $devMap \\
$withPubIp --query 'Instances[*].InstanceId' --output text";
#--tag-specifications 'ResourceType=instance,Tags=[{Key=owner,Value=zzhang}]' \\
#'ResourceType=volume,Tags=[{Key=owner,Value=zzhang}]'

print '-' x 40, "\n", "Running command:\n$cmd\n", '-' x 40, "\n";
my $instIds = `$cmd`;
if($?) { die "Launching instances with '$cmd' failed\n"; }
my @instIds = split /\s+/, $instIds;
printf "The following instances have been launched:\n%s\n", 
join(", ", @instIds);
if($waitForRun)
{
	print "Checking instance status:\n";
	foreach (@instIds)
	{
		print "-- Chcking $_ ...\n";
		if(system("aws ec2 wait instance-running --instance-ids ".$_))
		{ print "[FAIL] $_\n"; }
		else
		{ print "[OK] $_\n"; }
	}
}

print "Work done!\n";

exit 0;
## functions ##
sub usage 
{
	print <<USAGE;
	Usage: $0 [options]

	This program launches EC2 instances in one command. It is a
	wrapper of 'aws ec2 run-instances', so most given options are
	mapped to the options of 'aws ec2 run-instances'.

	Available options are:

	--ami = image-id, the id of AMI from which to launch the instances
	                  Default: $defaultAMI.
	--count=num,      the number of instances to launch
	                  Default: 1.
	--type=instance-type, the type of instances, such as 't2.micro'

	--key=key-name,   the key name used to login the instances
	                  Default: zzhang.
	--sec-grp=sec-group, the security groups associated with instances
	                  Default:sg-05c7a67a.
	--subnet=subnet-id, the subnet-id used for the instances
	                  Default: subnet-3209706b
	--public-ip,      switch option. if provided, a public IP is assigned
	                  Default: true
	--dev-map=device-mapping, block device mapping for the instance,
	                  see --block-device-mappings for details.
	                  Default: none
	--wait,           switch option. If provided, the program will
	                  wait until all the instances reach running state.
	                  Default: false.
USAGE
	exit 1;
}

