"""
This Python script verifies the presence of an AWS S3 bucket and DynamoDB table for Terraform state management
before deployment operations commence. It checks that all required environment variables are set and verifies
the existence of the S3 bucket and DynamoDB table. If these resources are absent, it directs the user to run
the Infrastructure Initial Setup workflow.

Key Steps:

Retrieve AWS region, S3 bucket name, and DynamoDB table name from environment variables.
Validate the presence of S3 bucket and DynamoDB table.
Environment Variables:

AWS_REGION: AWS region of the resources.
TFSTATE_BUCKET: Name of the S3 bucket for Terraform state storage.
TFSTATE_LOCK_TABLE: Name of the DynamoDB table for state locking.
"""


import os
import sys
import boto3

region_name = os.getenv('AWS_REGION')
bucket_name = os.getenv('TFSTATE_BUCKET')
table_name = os.getenv('TFSTATE_LOCK_TABLE')

try:
    if not region_name:
        raise ValueError("AWS_REGION environment variable is not set")
    if not bucket_name:
        raise ValueError("TFSTATE_BUCKET environment variable is not set")
    if not table_name:
        raise ValueError("TFSTATE_LOCK_TABLE environment variable is not set")
except Exception as e:
    print(e)
    sys.exit(1)
    
all_good = True

try:
    boto3.client('s3', region_name=region_name).head_bucket(Bucket=bucket_name)
    boto3.client('dynamodb', region_name=region_name).describe_table(TableName=table_name)
except Exception:
    all_good = False

if all_good:
    print(f"S3 bucket '{bucket_name}' and DynamoDB table '{table_name}' exist. Proceeding...")
    sys.exit(0)
else:
    print(f"Please run the Infrastructure Initial Setup workflow first! TFState do not exist. Exiting...")
    sys.exit(1)
