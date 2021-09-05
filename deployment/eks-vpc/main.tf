####################################################
#        EKS-VPC module implementation             #
####################################################
module "eks-vpc" {
  source = "../../aws-eks-tf-modules/module.eks-nodes-vpc"

  environment    = var.environment
  default_region = var.default_region

  cluster_name = var.cluster_name

  db_subnet_gp          = var.db_subnet_gp
  cidr_block            = var.cidr_block
  private_azs_with_cidr = var.private_azs_with_cidr
  public_azs_with_cidr  = var.public_azs_with_cidr
  db_azs_with_cidr      = var.db_azs_with_cidr
  instance_tenancy      = var.instance_tenancy
  enable_dns            = var.enable_dns
  support_dns           = var.support_dns
  enable_nat_gateway    = var.enable_nat_gateway

  team         = var.team
  owner        = var.owner
  isMonitoring = var.isMonitoring


  enable_db_subnet = var.enable_db_subnet
  enable_eks_public_subnet = var.enable_eks_public_subnet
  enable_eks_pvt_subnet = var.enable_eks_pvt_subnet
  enable_vpc_endpoint = var.enable_vpc_endpoint
  tfstate_s3_bucket_prefix = var.tfstate_s3_bucket_prefix
}
