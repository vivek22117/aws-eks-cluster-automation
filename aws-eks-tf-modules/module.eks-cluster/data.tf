###################################################
# Fetch remote state for S3 deployment bucket     #
###################################################
data "terraform_remote_state" "eks_vpc" {
  backend = "s3"

  config = {
    bucket = "${var.tfstate_s3_bucket_prefix}-tfstate-${var.default_region}"
    key    = "state/${var.environment}/eks-vpc/terraform.tfstate"
    region = var.default_region
  }
}


data "aws_caller_identity" "current" {}