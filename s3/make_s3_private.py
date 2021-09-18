#!/usr/bin/env python
#remove public read right for all keys within a directory

#usage: remove_public.py bucketName folderName

import sys
import boto3

if len(sys.argv) < 3:
    print(f"Usage: {sys.argv[0]} bucketName folderName");
    print(f"E.g.: {sys.argv[0]} zymo-filesystem home/zzhang");
    print("The program sets all the files in the S3 folder private");
    sys.exit(1);

BUCKET = sys.argv[1]
PATH = sys.argv[2]
s3client = boto3.client("s3")
paginator = s3client.get_paginator('list_objects_v2')
page_iterator = paginator.paginate(Bucket=BUCKET, Prefix=PATH)
for page in page_iterator:
    keys = page['Contents']
    for k in keys:
        response = s3client.put_object_acl(
                        ACL='private',
                        Bucket=BUCKET,
                        Key=k['Key']
                    )

print("The job is done");
sys.exit(0);

