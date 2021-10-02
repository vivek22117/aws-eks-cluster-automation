######################################################################
# Global variables for VPC, Subnet, Routes and Bastion Host          #
######################################################################
variable "default_region" {
  type        = string
  description = "AWS region to deploy resources"
}


#########################################################
#              Variables for EKS Bastion                #
#########################################################
variable "ami_filter_type" {
  type = string
  description = "AMI filter type, valid values 'self', 'amazon'"
}

variable "eks_bastion_name_prefix" {
  type        = string
  description = "EKS bastion name prefix"
}

variable "bastion_instance_type" {
  type        = string
  description = "Instance type for Bastion Host"
}

variable "default_cooldown" {
  type        = string
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
}

variable "volume_size" {
  type        = number
  description = "EBS size for EKS bastion host"
}


variable "eks_bastion_asg_max_size" {
  type        = number
  description = "Max size for EKS bastion ASG"
}

variable "eks_bastion_asg_min_size" {
  type        = number
  description = "Min size for EKS bastion ASG"
}

variable "eks_bastion_asg_desired_capacity" {
  type        = number
  description = "Desired size for EKS bastion ASG"
}

variable "termination_policies" {
  type        = list(string)
  description = "Termination policy for EKS ASG group"
}


######################################################
# Local variables defined                            #
######################################################
variable "team" {
  type        = string
  description = "Owner team for this application infrastructure"
}

variable "owner" {
  type        = string
  description = "Owner of the product"
}

variable "environment" {
  type        = string
  description = "Environment to be used"
}

variable "isMonitoring" {
  type        = bool
  description = "Monitoring is enabled or disabled for the resources creating"
}

variable "project" {
  type        = string
  description = "Monitoring is enabled or disabled for the resources creating"
}

variable "component" {
  type        = string
  description = "Component name for the resource"
}


#####=============Local variables===============#####
locals {
  common_tags = {
    Owner       = var.owner
    Team        = var.team
    Environment = var.environment
    Monitoring  = var.isMonitoring
    Project     = var.project
    Component   = var.component
  }
}

#####=============ASG Standards Tags===============#####
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default = {
    owner      = "vivek"
    team       = "EKSAdminTeam"
    tool       = "Terraform"
    monitoring = "true"
    Name       = "EKS-Admin-Host"
    Project    = "LearningTF"
  }
}


#####================EKS ConfigMap Variables======================#####
variable "eks_iam_group" {
  type        = string
  description = "Name of the IAM group to make EKS user"
}

variable "apply_config_map_aws_auth" {
  type        = bool
  default     = true
  description = "Whether to generate local files from `kubeconfig` and `config-map-aws-auth` templates and perform `kubectl apply` to apply the ConfigMap to allow worker nodes to join the EKS cluster"
}

variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
  description = "The path to `kubeconfig` file"
}

variable "configmap_auth_template_file" {
  type        = string
  default     = ""
  description = "Path to `config_auth_template_file`"
}

variable "configmap_auth_file" {
  type        = string
  default     = ""
  description = "Path to `configmap_auth_file`"
}

variable "eks_creator_role" {
  type = string
  description = "IAM role used to create EKS Resources"
}


