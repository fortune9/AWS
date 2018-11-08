#!/bin/bash

## functions ##
function usage 
{
	echo "
	Usage: $0 [options]

	This program launches EC2 instances in one command. It is a
	wrapper of 'aws ec2 run-instances', so all the given options are
	mapped to the options of 'aws ec2 run-instances', see below.

	Available options are:

	--amiId=image-id, the id of AMI from which to launch the instances
	                  Default: ami-08f4831e.
	--count=num,      the number of instances to launch
	                  Default: 1.
	--type=instance-type, the type of instances, such as 't2.micro'

	--key=key-name,   the key name used to login the instances
	                  Default: zzhang.
	--secGrp=sec-group, the security groups associated with instances
	                  Default:sg-05c7a67a.
	--subnet=subnet-id, the subnet-id used for the instances
	                  Default: subnet-3209706b
	--publicIp,       switch option. if provided, a public IP is assigned
	                  Default: true
	--devMap=device-mapping, block device mapping for the instance,
	                  see --block-device-mappings for details.
	                  Default: file://ec2_devices.json 
	";
	exit 1;
}

# parsing command line arguments
# test the getopt system first
getopt --test >/dev/null;
if [[ $? -ne 4 ]]; then # the expected return is 4, interesting
	echo "Sorry, `getopt --test` failed"
	exit 1;
fi

if [[ $# -lt 1 ]]; then
	usage
fi

## the expected options
shortOpts=''
longOpts=amiId,count,type,key,secGrp,subnet,publicIp,devMap

#parsed=$(getopt --options $shortOpts --longoptions $longOpts --name "$0" -- "$@")
parsed=$(getopt --longoptions $longOpts --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
	exit 2;
fi

# use eval to handle the quoting properly
eval set -- "$parsed"
# now get the option values until see '--'
while true;
do
	case "$1" in
		--amiId)
			amiId="$2";
			shift 2
			;;
		--count)
			count="$2";
			shift 2
			;;
		--type)
			type="$2";
			shift 2
			;;
		--key)
			key="$2";
			shift 2
			;;
		--secGrp)
			secGrp="$2";
			shift 2
			;;
		--subnet)
			subnet="$2";
			shift 2
			;;
		--publicIp)
			publicIp="--associate-public-ip-address";
			shift 1
			;;
		--devMap)
			devMap="$2";
			shift 2
			;;
		--)
			shift
			break
			;;
		*)
			echo "Unknown option '$1'"
			exit 3;
			;;
	esac
done

if [[ -z $type ]]; then
	usage;
fi

# set default values
amiId=${amiId:-'ami-08f4831e'}
count=${count:-1}
#type='t2.micro'
key=${key:-'zzhang'}
secGrp=${secGrp:-'sg-05c7a67a'}
vpc='vpc-168e9973|zymo'
#subnet='subnet-3309706a' # this is a private subnet
subnet=${subnet:-'subnet-3209706b'} # this is a public subnet
devMap=${devMap:-'file://ec2_devices.json'};

# launch the instance now
cmd="--image-id $amiId --count $count \
--instance-type $type --key-name $key --security-group-ids \
$secGrp --subnet-id $subnet --block-device-mappings \
$publicIp
"
echo $cmd

exit 0;
aws ec2 run-instances --image-id $amiId --count $count \
--instance-type $type --key-name $key --security-group-ids \
$secGrp --subnet-id $subnet --block-device-mappings \
file://ec2_devices.json --associate-public-ip-address
