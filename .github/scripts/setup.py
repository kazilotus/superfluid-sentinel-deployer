"""
This script sets up AWS resources required for Terraform state management.
It verifies the existence of an S3 bucket and a DynamoDB table, which are needed to store and manage Terraform state.
If either resource does not exist, the script creates it. The S3 bucket serves as a shared, centralized storage for the
Terraform state file, while the DynamoDB table ensures state locking and consistency, preventing potential
conflicts during concurrent operations. 

Key Steps:
1. Retrieve AWS region, S3 bucket name, and DynamoDB table name from environment variables.
2. Verify and create the S3 bucket as required.
3. Verify and create the DynamoDB table as required.

Environment Variables:
- AWS_REGION: AWS region for resource creation.
- TFSTATE_BUCKET: Name of S3 bucket for Terraform state storage.
- TFSTATE_LOCK_TABLE: Name of DynamoDB table for state locking.
"""


import boto3
import os
from botocore.exceptions import ClientError

region_name = os.getenv('AWS_REGION')
bucket_name = os.getenv('TFSTATE_BUCKET')
table_name = os.getenv('TFSTATE_LOCK_TABLE')

if not region_name:
    raise ValueError("AWS_REGION environment variable is not set")
if not bucket_name:
    raise ValueError("TFSTATE_BUCKET environment variable is not set")
if not table_name:
    raise ValueError("TFSTATE_LOCK_TABLE environment variable is not set")

s3 = boto3.resource('s3', region_name=region_name)
dynamodb = boto3.client('dynamodb', region_name=region_name)

bucket = s3.Bucket(bucket_name)
bucket_exists = bucket.creation_date is not None

# Check if S3 bucket exists
if bucket_exists:
    print(f"S3 bucket '{bucket_name}' already exists. Exiting...")
else:
    s3.create_bucket(Bucket=bucket_name)
    print(f"S3 bucket '{bucket_name}' created successfully.")

# Check if DynamoDB table exists
try:
    dynamodb.describe_table(TableName=table_name)
    print(f"DynamoDB table '{table_name}' already exists. Exiting...")
    table_exists = True
except dynamodb.exceptions.ResourceNotFoundException:
    table_exists = False

# Create DynamoDB table if it doesn't exist
if not table_exists:
    dynamodb.create_table(
        TableName=table_name,
        KeySchema=[
            {
                'AttributeName': 'LockID',
                'KeyType': 'HASH'
            },
        ],
        AttributeDefinitions=[
            {
                'AttributeName': 'LockID',
                'AttributeType': 'S'
            },
        ],
        ProvisionedThroughput={
            'ReadCapacityUnits': 5,
            'WriteCapacityUnits': 5
        }
    )
    print(f"DynamoDB table '{table_name}' created successfully.")

if bucket_exists and table_exists:
    print("Both S3 bucket and DynamoDB table exist. Exiting...")
    exit(0)
