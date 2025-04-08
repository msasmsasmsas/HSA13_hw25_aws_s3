# HSA13_hw25: AWS S3 Immutable Storage

This project uses Terraform to create an AWS S3 bucket with Object Lock for immutable storage and server access logging. It includes a script to test the Write-Once-Read-Many (WORM) policy and verify logging functionality.

## Features

    Immutable Storage: Objects are protected with Object Lock in COMPLIANCE mode.
    Versioning: Enabled to maintain object history.
    Access Logging: All requests are logged to a separate bucket.
    Testing Script: Verifies WORM policy and logging functionality.

## Prerequisites

    Terraform (v1.0+ recommended).
    AWS CLI configured with IAM credentials (access key and secret key).
    Bash shell for running the test script.

## Setup Instructions

### 1. Clone the Repository:
    bash

git clone https://github.com/alexeysirenko/prjctr-25-aws-s3.git
cd prjctr-25-aws-s3
### 2. Initialize Terraform:
bash
terraform init
### 3. Deploy Resources:
bash
terraform apply
Confirm with yes to create the buckets.
### 4. List Created Buckets:
bash
aws s3 ls
### 5. Run Tests:

    Make the test script executable:
    bash

chmod +x test-worm.sh
Run the test script:
bash

    ./test-worm.sh
    The script will:
        Upload two versions of a file (test-worm.txt).
        Verify that both versions are immutable (deletion attempts return "Access Denied").
        Add a DeleteMarker and list object versions.
        Check the contents of both versions.
        Check for access logs (note: logs may take 30-60 minutes to appear).

### 6. Cleanup (optional):
bash

    terraform destroy
    Confirm with yes to remove all resources.

## Alternative Setup with Python

### 1. Configure AWS CLI:
        Ensure AWS CLI is installed and configured with your credentials:
        bash

    aws configure
    Enter your AWS Access Key ID, Secret Access Key, region (e.g., eu-west-1), and output format (e.g., json).

### 2. Install Python Dependencies:

    Install the boto3 library if not already present:
    bash

    pip install boto3

### 3. Run the Python Script:

    Save the provided create_s3_bucket.py file.
    Execute the script to create the buckets and configure them:
    bash

    python create_s3_bucket.py
    The script will:
        Create the main bucket (my-immutable-bucket-1234-3) with Object Lock enabled.
        Enable versioning and set a 30-day retention policy in COMPLIANCE mode.
        Create a logging bucket (my-immutable-bucket-1234-3-logs) and enable server access logging.
        Apply a policy to allow logging service access.

### 4. Verify Setup:

    Check the created buckets:
    bash

        aws s3 ls
        Proceed with the test-worm.sh script as described above to test the WORM policy and logging.

## Expected Test Results

    WORM Policy:
        Deletion attempts for both file versions return "Access Denied".
        Deleting the object adds a DeleteMarker but preserves versions.
        Listing versions shows two versions of test-worm.txt.
        File contents match the uploaded versions:
            version1.txt: "Original content - Version 1"
            version2.txt: "Modified content - Version 2"
    Logging:
        Logs appear in s3://my-immutable-bucket-1234-3-logs/s3-access-logs/ after 30-60 minutes.
        Log files contain details like request time, IP, and operation (e.g., REST.PUT.OBJECT).

## File Descriptions

    main.tf: Defines the S3 buckets, Object Lock, versioning, and logging.
    variables.tf: Declares variables for bucket name, region, and retention period.
    terraform.tfvars: Sets specific values for variables.
    test-worm.sh: Script to test WORM policy and logging.
    create_s3_bucket.py: Python script to create and configure the S3 buckets programmatically.

## Notes

    The bucket name (my-immutable-bucket-1234-3) must be globally unique. Update terraform.tfvars if needed.
    Logs may take time to appear due to AWS processing delays.
    Ensure your IAM user has permissions for s3:* actions and iam:PassRole if needed.

Original Context

This project extends a basic S3 bucket creation example with immutability and logging, providing a robust testing framework for WORM compliance.
