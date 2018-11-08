#!/bin/sh

set -e

if [[ $# -lt 1 ]]; then
	echo "
	Usage: $0 <instance-id> [<private-key-file> <user-name>]
	";
	exit 1;
fi

instId=$1
pem=${2:-$HOME/.aws/zzhang.pem}
user=${3:-ec2-user}

# Verify RSA key fingerprint
#aws ec2 get-console-output --instance-id $instId 2>/dev/null

dns=`inst_ip $instId text | cut -f 2`
# connect to the instance
ssh -i $pem $user@$dns

