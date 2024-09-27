# ==============================================================================
# AWS Provider Configuration
# ==============================================================================
variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "AWS Access Key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "AWS Secret Key"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region     = yamldecode(file("${path.module}/../config/${local.env}.yaml"))["global"]["region"]
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}