######################################################################
# Global variables for VPC, Subnet, Routes and Bastion Host          #
######################################################################
variable "default_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "cluster_name" {
  type        = string
  description = "Name of EKS cluster"
}

variable "cidr_block" {
  type        = string
  description = "Cidr range for vpc"
}

variable "instance_tenancy" {
  type        = string
  description = "Type of instance tenancy required default/dedicated"
}

variable "enable_dns" {
  type        = string
  description = "To use private DNS within the VPC"
}

variable "support_dns" {
  type        = string
  description = "To use private DNS support within the VPC"
}

variable "private_azs_with_cidr" {
  type        = list(string)
  description = "Name of azs with cidr to be used for infrastructure"
}

variable "public_azs_with_cidr" {
  type        = list(string)
  description = "Name of azs with cidr to be used for infrastructure"
}

variable "db_azs_with_cidr" {
  type        = list(string)
  description = "Name of azs with cidr to be used for Database infrastructure"
}

variable "db_subnet_gp" {
  type        = string
  description = "DB subnet group name for RDS and Aurora instances"
}

variable "enable_nat_gateway" {
  type        = string
  description = "want to create nat-gateway or not"
}

variable "enable_eks_public_subnet" {
  type        = string
  description = "Flag for creating public subnet for EKS worker nodes"
}

variable "enable_eks_pvt_subnet" {
  type        = string
  description = "Flag for creating private subnet for EKS worker nodes"
}

variable "enable_db_subnet" {
  type        = string
  description = "Flag for creating private subnet for Database"
}

variable "enable_vpc_endpoint" {
  type        = string
  description = "Flag to control the creation of VPC endpoints, S3, ECS Task, ECR, EC2, Cloudwatch"
}

#########################################################
# Default variables for backend and SSH key for Bastion #
#########################################################
variable "tfstate_s3_bucket_prefix" {
  type        = string
  description = "Prefix for s3 bucket"
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

#####=============Local variables===============#####
locals {
  common_tags = {
    owner       = var.owner
    team        = var.team
    environment = var.environment
    monitoring  = var.isMonitoring
    Project     = "Learning-TF"
  }
}



