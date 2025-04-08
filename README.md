# HSA13_hw25_aws_s3

This project demonstrates how to create and configure an AWS S3 bucket using Terraform. The bucket is set up with Object Lock for immutable storage and server access logging for auditability.
Features

    Immutable Storage: Objects are protected from modification or deletion using Object Lock in COMPLIANCE mode.
    Versioning: Enabled to maintain object history.
    Access Logging: All requests to the main bucket are logged into a separate logging bucket.
    Terraform Configuration: Infrastructure is defined as code for easy deployment and management.

## Prerequisites

    Terraform installed (v1.0+ recommended).
    AWS account with IAM credentials configured (access key and secret key).
    AWS CLI configured (optional, for verification).

## Setup Instructions

    Clone the Repository:
    bash

git clone https://github.com/alexeysirenko/prjctr-25-aws-s3.git
cd prjctr-25-aws-s3
Initialize Terraform:
bash
terraform init
Review Variables:

    Open terraform.tfvars to customize bucket_name, region, or retention_days if needed.
    Default bucket name: my-test-bucket-12345
    Default region: eu-west-1
    Default retention: 30 days

Deploy the Infrastructure:
bash
terraform apply
Confirm the changes by typing yes when prompted.
Verify Deployment:

    Check the AWS S3 console to confirm the creation of:
        Main bucket (my-test-bucket-12345) with Object Lock and versioning.
        Logging bucket (my-test-bucket-12345-logs) with logs.

Cleanup (optional):
bash

    terraform destroy
    Confirm with yes to remove all resources.

## File Descriptions

    main.tf: Defines the S3 buckets, Object Lock, versioning, and logging configuration.
    variables.tf: Declares variables like bucket name, region, and retention period.
    terraform.tfvars: Sets specific values for the variables.

## Notes

    Ensure the bucket name is globally unique, as S3 bucket names must not conflict with existing ones.
    The retention period can be adjusted in terraform.tfvars to meet your needs.
    Logs will appear in the logging bucket under the logs/ prefix.

## Original Context

This project builds upon a simple S3 bucket creation example, enhancing it with immutability and logging features for a more robust storage solution.
