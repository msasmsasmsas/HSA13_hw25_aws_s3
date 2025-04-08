# Variable for the main bucket name
variable "bucket_name" {
  description = "The name of the main S3 bucket"
  type        = string
}

# Variable for the AWS region
variable "region" {
  description = "The AWS region where the bucket will be created"
  type        = string
  default     = "us-east-1"
}

# Variable for retention period in days
variable "retention_days" {
  description = "Number of days for object retention in COMPLIANCE mode"
  type        = number
  default     = 30
}
