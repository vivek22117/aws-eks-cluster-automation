###########################################################
#             Remote state configuration to fetch         #
#                  vpc, artifactory bucket                #
###########################################################
data "terraform_remote_state" "eks_vpc" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-eks-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/eks-vpc/terraform.tfstate"
    region = var.default_region
  }
}


data "terraform_remote_state" "eks_cluster" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-eks-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/eks-cluster/terraform.tfstate"
    region = var.default_region
  }
}


data "aws_caller_identity" "current" {}