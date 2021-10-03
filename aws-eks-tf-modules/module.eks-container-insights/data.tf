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

provider "kubernetes" {
  load_config_file         = "false"
  host                     = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_endpoint
  cluster_ca_certificate   = base64decode(data.terraform_remote_state.eks_cluster.outputs.eks_cluster_certificate_authority[0]["data"])
  config_context_auth_info = "aws"
  config_context_cluster   = "kubernetes"
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws-iam-authenticator"
    args = [
      "token",
      "-i",
      data.terraform_remote_state.eks_cluster.outputs.eks_cluster_id,
      "-r",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSInfrastructureAdministratorRole"
    ]
  }
}


data "aws_caller_identity" "current" {}