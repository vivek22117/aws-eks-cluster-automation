####################################################
#        EKS Cluster module implementation         #
####################################################
module "eks-vpc" {
  source = "../../aws-eks-tf-modules/module.eks-cluster"

  environment    = var.environment
  default_region = var.default_region

  team         = var.team
  owner        = var.owner
  isMonitoring = var.isMonitoring

  launch_template = var.launch_template

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  common_tags = var.common_tags

  cluster_service_ipv4_cidr    = var.cluster_service_ipv4_cidr
  eks_cluster_create_timeout   = var.eks_cluster_create_timeout
  eks_cluster_delete_timeout   = var.eks_cluster_delete_timeout
  cluster_encryption_resources = var.cluster_encryption_resources
  cluster_egress_cidrs         = var.cluster_egress_cidrs

  enable_private_access = var.enable_private_access
  enable_public_access  = var.enable_public_access
  pvt_node_group_name   = var.pvt_node_group_name
  pub_node_group_name   = var.pub_node_group_name
  ami_type              = var.ami_type
  disk_size             = var.disk_size
  instance_types        = var.instance_types
  pvt_desired_size      = var.pvt_desired_size
  pvt_max_size          = var.pvt_max_size
  pvt_min_size          = var.pvt_min_size
  public_desired_size   = var.public_desired_size
  public_max_size       = var.public_max_size
  public_min_size       = var.public_min_size
  log_retention         = var.log_retention
  enabled_log_types     = var.enabled_log_types

  node_labels    = var.node_labels
  ssh_public_key = var.ssh_public_key
  ssh_source_sg  = var.ssh_source_sg
  vpc_cidr       = var.vpc_cidr

  tfstate_s3_bucket_prefix = var.tfstate_s3_bucket_prefix
}
