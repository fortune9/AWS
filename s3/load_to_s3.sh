#!/bin/bash

num=$1

if [[ -z $num ]]; then
	echo "
	Usage: $0 <num>
	";
	exit 1;
fi

fileName=tmp.$num

cat >$fileName <<EOF
I am $num in `hostname`.
I will load myself to S3.
EOF

aws s3 cp $fileName s3://zhang-data/temp/

echo Job $num is done;

exit 0;
