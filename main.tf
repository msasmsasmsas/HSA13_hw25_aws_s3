# Define the AWS provider
provider "aws" {
  region = var.region
}

# Create the main S3 bucket with Object Lock enabled
resource "aws_s3_bucket" "main_bucket" {
  bucket = var.bucket_name
  
  # Enable Object Lock for immutability
  object_lock_enabled = true
  
  tags = {
    Name = var.bucket_name
    Purpose = "Immutable storage"
  }
}

# Configure versioning for the main bucket
resource "aws_s3_bucket_versioning" "main_versioning" {
  bucket = aws_s3_bucket.main_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Set default retention policy for immutability
resource "aws_s3_bucket_object_lock_configuration" "main_lock_config" {
  bucket = aws_s3_bucket.main_bucket.id
  
  object_lock_enabled = "Enabled"
  
  rule {
    default_retention {
      mode = "COMPLIANCE"  # Objects cannot be modified or deleted until retention period ends
      days = var.retention_days
    }
  }
}

# Create a logging bucket for access logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucket_name}-logs"
  
  tags = {
    Name = "${var.bucket_name}-logs"
    Purpose = "Access logging"
  }
}

# Enable server access logging for the main bucket
resource "aws_s3_bucket_logging" "main_logging" {
  bucket = aws_s3_bucket.main_bucket.id
  
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "s3-access-logs/"
}

# Policy to allow S3 logging service to write to the log bucket
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.main_bucket.arn
          }
        }
      }
    ]
  })
}
