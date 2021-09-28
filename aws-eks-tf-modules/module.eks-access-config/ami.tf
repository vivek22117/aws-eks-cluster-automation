####################################################
#             EKS Admin host AMI for EKS           #
####################################################
locals {
  ami_filter_prefix = var.ami_filter_type == "self" ? "eks-admin-*" : "amzn2-ami-*-x86_64-gp2"
}


data "aws_ami" "eks_admin_host" {
  most_recent = true
  owners      = [var.ami_filter_type]

  filter {
    name   = "name"
    values = [local.ami_filter_prefix]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
