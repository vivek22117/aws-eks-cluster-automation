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
  default     = null
}

variable "cluster_log_kms_key_id" {
  type        = string
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  default     = null
}

variable "common_tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "pvt_subnet_ids" {
  type        = list(string)
  description = "A list of subnets to place EKS private NodeGroup"
}

variable "pub_subnet_ids" {
  type        = list(string)
  description = "A list of subnets to place EKS public NodeGroup"
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  default     = null
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  description = "The CIDR block to assign Kubernetes service IP addresses"
  default     = null
}

variable "eks_cluster_create_timeout" {
  type        = string
  description = "Timeout value when creating the EKS cluster."
  default     = "30m"
}

variable "eks_cluster_delete_timeout" {
  type        = string
  description = "Timeout value when deleting the EKS cluster."
  default     = "30m"
}

variable "cluster_encryption_resources" {
  type        = list(string)
  description = "Encryption configuration for the cluster resources"
  default     = []
}

variable "cluster_egress_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks that are permitted for cluster egress traffic."
}

variable "launch_template" {
  type        = map(string)
  description = "Configuration block with Launch Template settings. `name`, `id` and `version` parameters are available."
  default     = {}
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


#####================EKS Variables======================#####
variable "enable_private_access" {
  type        = bool
  description = "Amazon EKS private API server endpoint is enabled. Default is false"
}

variable "enable_public_access" {
  type        = bool
  description = "Amazon EKS public API server endpoint is enabled. Default is true"
}

variable "pvt_node_group_name" {
  type        = string
  description = "EKS cluster private Node Group name"
}

variable "pub_node_group_name" {
  type        = string
  description = "EKS cluster public Node Group name"
}

variable "ami_type" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64"
}

variable "node_labels" {
  type        = map(string)
  description = "Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed"
}

variable "ami_release_version" {
  type        = string
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version, https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html, '1.20.4-20210826'. Default is latest"
  default     = null
}

variable "ssh_public_key" {
  type        = string
  description = "SSH content for aws key pair"
}

variable "ssh_source_sg" {
  type        = string
  description = "Security group Id from where we can SSH on EKS worker nodes and access EKS cluster via kubectl commands"
}

variable "disk_size" {
  type        = number
  description = "Disk size in GiB for worker nodes."
}

variable "instance_types" {
  type        = list(string)
  description = "Set of instance types associated with the EKS Node Group."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range where EKS workers are provisioned"
}

variable "pvt_desired_size" {
  type        = number
  description = "Desired number of EKS Private worker nodes."
}

variable "pvt_max_size" {
  type        = number
  description = "Maximum number of EKS Private worker nodes."
}

variable "pvt_min_size" {
  type        = number
  description = "Minimum number of EKS Private worker nodes."
}

variable "public_desired_size" {
  type        = number
  description = "Desired number of EKS Private worker nodes."
}

variable "public_max_size" {
  type        = number
  description = "Maximum number of EKS Private worker nodes."
}

variable "public_min_size" {
  type        = number
  description = "Minimum number of EKS Private worker nodes."
}

variable "log_retention" {
  type        = number
  description = "Number of days to store EKS logs"
}

variable "enabled_log_types" {
  type        = list(string)
  description = "Amazon EKS control plane logging provides audit and diagnostic logs directly from the Amazon EKS control plane to CloudWatch Logs, valid values 'api', 'audit', 'authenticator', 'controllerManager', 'scheduler'"
  default     = ["api"]
}

variable "cluster_version" {
  type        = string
  description = "Desired Kubernetes master version."
}
