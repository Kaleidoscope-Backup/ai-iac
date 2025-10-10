terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for Bedrock resources"
  type        = string
  default     = "us-east-1"
}

variable "bedrock_models" {
  description = "List of Bedrock foundation models to enable"
  type        = list(string)
  default = [
    "anthropic.claude-3-sonnet-20240229-v1:0",
    "anthropic.claude-3-haiku-20240307-v1:0",
    "amazon.titan-text-express-v1",
    "amazon.titan-embed-text-v1"
  ]
}

# IAM role for Bedrock access
resource "aws_iam_role" "bedrock_execution_role" {
  name = "bedrock-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Bedrock model access
resource "aws_iam_role_policy" "bedrock_model_policy" {
  name = "bedrock-model-policy"
  role = aws_iam_role.bedrock_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:GetFoundationModel",
          "bedrock:ListFoundationModels"
        ]
        Resource = "*"
      }
    ]
  })
}

# Bedrock foundation model access
resource "aws_bedrock_foundation_model" "models" {
  for_each = toset(var.bedrock_models)
  
  model_id = each.value
}

# S3 bucket for Bedrock artifacts (optional)
resource "aws_s3_bucket" "bedrock_artifacts" {
  bucket = "bedrock-artifacts-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket_versioning" "bedrock_artifacts_versioning" {
  bucket = aws_s3_bucket.bedrock_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_artifacts_encryption" {
  bucket = aws_s3_bucket.bedrock_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch log group for Bedrock
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/model-invocations"
  retention_in_days = 14
}

# Outputs
output "bedrock_execution_role_arn" {
  description = "ARN of the Bedrock execution role"
  value       = aws_iam_role.bedrock_execution_role.arn
}

output "bedrock_artifacts_bucket" {
  description = "S3 bucket for Bedrock artifacts"
  value       = aws_s3_bucket.bedrock_artifacts.bucket
}

output "enabled_models" {
  description = "List of enabled Bedrock foundation models"
  value       = var.bedrock_models
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for Bedrock"
  value       = aws_cloudwatch_log_group.bedrock_logs.name
}
