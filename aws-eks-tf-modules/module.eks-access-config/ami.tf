####################################################
#             Bastion host AMI for EKS             #
####################################################
data "aws_ami" "eks_admin_host" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["eks-admin-"]
  }
}
