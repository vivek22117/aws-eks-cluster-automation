###########################################################
#             Remote state configuration to fetch         #
#                  eks vpc, eks cluster state file        #
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

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks_cluster.outputs.helm_config.host
    token                  = data.terraform_remote_state.eks_cluster.outputs.helm_config.token
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_cluster.outputs.helm_config.ca)
  }
}



data "aws_caller_identity" "current" {}