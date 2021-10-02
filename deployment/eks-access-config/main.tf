####################################################
#        EKS Access Infra module configuration     #
####################################################
module "eks_access_infra" {
  source = "../../aws-eks-tf-modules/module.eks-access-config"

  environment    = var.environment
  default_region = var.default_region

  team         = var.team
  owner        = var.owner
  project      = var.project
  isMonitoring = var.isMonitoring
  component    = var.component

  eks_bastion_name_prefix = var.eks_bastion_name_prefix
  bastion_instance_type   = var.bastion_instance_type
  default_cooldown        = var.default_cooldown
  volume_size             = var.volume_size

  eks_bastion_asg_desired_capacity = var.eks_bastion_asg_desired_capacity
  eks_bastion_asg_max_size         = var.eks_bastion_asg_max_size
  eks_bastion_asg_min_size         = var.eks_bastion_asg_min_size
  termination_policies             = var.termination_policies

  eks_iam_group    = var.eks_iam_group
  eks_creator_role = var.eks_creator_role


  apply_config_map_aws_auth   = var.apply_config_map_aws_auth
  map_additional_aws_accounts = var.map_additional_aws_accounts
  map_additional_iam_roles    = var.map_additional_iam_roles
  map_additional_iam_users    = var.map_additional_iam_users

  kubeconfig_path              = var.kubeconfig_path
  configmap_auth_template_file = var.configmap_auth_template_file
  configmap_auth_file          = var.configmap_auth_file

  ami_filter_type   = var.ami_filter_type
  kubectl_version   = var.kubectl_version
  terraform_version = var.terraform_version
}
