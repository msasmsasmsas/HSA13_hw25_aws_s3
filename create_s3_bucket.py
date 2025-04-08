import boto3
import json
from botocore.exceptions import ClientError
from datetime import datetime, timedelta

# Initialize AWS S3 client
s3_client = boto3.client('s3')

# Configuration variables
BUCKET_NAME = "my-immutable-bucket-1234-3"
REGION = "eu-west-1"
RETENTION_DAYS = 30

def create_main_bucket():
    """Create the main S3 bucket with Object Lock enabled."""
    try:
        s3_client.create_bucket(
            Bucket=BUCKET_NAME,
            CreateBucketConfiguration={'LocationConstraint': REGION},
            ObjectLockEnabledForBucket=True
        )
        print(f"Main bucket '{BUCKET_NAME}' created successfully with Object Lock.")
    except ClientError as e:
        print(f"Error creating main bucket: {e}")

def enable_versioning():
    """Enable versioning on the main bucket."""
    try:
        s3_client.put_bucket_versioning(
            Bucket=BUCKET_NAME,
            VersioningConfiguration={'Status': 'Enabled'}
        )
        print(f"Versioning enabled on '{BUCKET_NAME}'.")
    except ClientError as e:
        print(f"Error enabling versioning: {e}")

def set_retention_policy():
    """Set default retention policy with COMPLIANCE mode."""
    try:
        s3_client.put_object_lock_configuration(
            Bucket=BUCKET_NAME,
            ObjectLockConfiguration={
                'ObjectLockEnabled': 'Enabled',
                'Rule': {
                    'DefaultRetention': {
                        'Mode': 'COMPLIANCE',
                        'Days': RETENTION_DAYS
                    }
                }
            }
        )
        print(f"Retention policy set on '{BUCKET_NAME}' for {RETENTION_DAYS} days in COMPLIANCE mode.")
    except ClientError as e:
        print(f"Error setting retention policy: {e}")

def create_log_bucket():
    """Create a logging bucket."""
    log_bucket_name = f"{BUCKET_NAME}-logs"
    try:
        s3_client.create_bucket(
            Bucket=log_bucket_name,
            CreateBucketConfiguration={'LocationConstraint': REGION}
        )
        print(f"Log bucket '{log_bucket_name}' created successfully.")
        return log_bucket_name
    except ClientError as e:
        print(f"Error creating log bucket: {e}")
        return None

def enable_logging(log_bucket_name):
    """Enable server access logging on the main bucket."""
    try:
        s3_client.put_bucket_logging(
            Bucket=BUCKET_NAME,
            BucketLoggingStatus={
                'LoggingEnabled': {
                    'TargetBucket': log_bucket_name,
                    'TargetPrefix': 's3-access-logs/'
                }
            }
        )
        print(f"Logging enabled on '{BUCKET_NAME}' with logs stored in '{log_bucket_name}'.")
    except ClientError as e:
        print(f"Error enabling logging: {e}")

def set_log_bucket_policy(log_bucket_name):
    """Set policy to allow S3 logging service to write to the log bucket."""
    bucket_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {"Service": "logging.s3.amazonaws.com"},
                "Action": "s3:PutObject",
                "Resource": f"arn:aws:s3:::{log_bucket_name}/*",
                "Condition": {
                    "ArnLike": {
                        "aws:SourceArn": f"arn:aws:s3:::{BUCKET_NAME}"
                    }
                }
            }
        ]
    }
    try:
        s3_client.put_bucket_policy(
            Bucket=log_bucket_name,
            Policy=json.dumps(bucket_policy)
        )
        print(f"Policy applied to '{log_bucket_name}' for logging access.")
    except ClientError as e:
        print(f"Error setting log bucket policy: {e}")

def main():
    """Main function to orchestrate bucket creation and configuration."""
    # Create and configure the main bucket
    create_main_bucket()
    enable_versioning()
    set_retention_policy()

    # Create and configure the logging bucket
    log_bucket_name = create_log_bucket()
    if log_bucket_name:
        enable_logging(log_bucket_name)
        set_log_bucket_policy(log_bucket_name)

    print("S3 bucket setup completed.")

if __name__ == "__main__":
    main()
