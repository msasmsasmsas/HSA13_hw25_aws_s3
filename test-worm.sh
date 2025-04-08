#!/bin/bash

# Exit on error
set -e

# List created buckets
echo "Listing created buckets:"
aws s3 ls

# Test WORM policy
echo "Testing WORM policy..."

# Upload the first version of the file
echo "Original content - Version 1" > test-worm.txt
aws s3api put-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --body test-worm.txt

# Get the initial version ID
INITIAL_VERSION=$(aws s3api list-object-versions \
  --bucket my-immutable-bucket-1234-3 \
  --prefix test-worm.txt \
  --query 'Versions[0].VersionId' \
  --output text)
echo "Initial version ID: $INITIAL_VERSION"

# Check retention settings
aws s3api get-object-retention \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --version-id $INITIAL_VERSION

# Upload the second version of the file
echo "Modified content - Version 2" > test-worm.txt
aws s3api put-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --body test-worm.txt

# Get the second version ID
SECOND_VERSION=$(aws s3api list-object-versions \
  --bucket my-immutable-bucket-1234-3 \
  --prefix test-worm.txt \
  --query 'Versions[0].VersionId' \
  --output text)
echo "Second version ID: $SECOND_VERSION"

# Try deleting the original file (should fail)
echo "Trying to delete the original file (expecting Access Denied)..."
aws s3api delete-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --version-id $INITIAL_VERSION || echo "Access Denied (expected)"

# Try deleting the second file (should fail)
echo "Trying to delete the second file (expecting Access Denied)..."
aws s3api delete-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --version-id $SECOND_VERSION || echo "Access Denied (expected)"

# Try deleting the object (should add DeleteMarker)
echo "Trying to delete the object (should add DeleteMarker)..."
aws s3api delete-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt

# List object versions
echo "Listing object versions:"
aws s3api list-object-versions \
  --bucket my-immutable-bucket-1234-3 \
  --prefix test-worm.txt

# Check file contents
echo "Checking file contents..."
aws s3api get-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --version-id $INITIAL_VERSION \
  version1.txt
aws s3api get-object \
  --bucket my-immutable-bucket-1234-3 \
  --key test-worm.txt \
  --version-id $SECOND_VERSION \
  version2.txt

cat version1.txt
cat version2.txt

# Test logging
echo "Testing logging (logs may take 30-60 minutes to appear)..."
aws s3 ls s3://my-immutable-bucket-1234-3-logs/s3-access-logs/ --recursive

# Example: Download a log file (replace <log_file_name> with actual file name after logs appear)
# aws s3 cp s3://my-immutable-bucket-1234-3-logs/s3-access-logs/<log_file_name> .
# cat <log_file_name>
