variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "us-east-1"
}

variable "app_name" {
  type        = string
  description = "Application name used for naming resources"
  default     = "sample-project"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod)"
  default     = "dev"
}
