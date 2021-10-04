default_region = "us-east-1"

team         = "Learning-Team"
owner        = "Vivek"
isMonitoring = true

common_tags = {
  Owner       = "Vivek"
  Team        = "Learning-Team"
  Environment = "prod"
  Monitoring  = true
  Project     = "Learning-EKS"
}

#####=======Please provide below values to use already available VPC for EKS NodeGroup/Workers=========#####
vpc_cidr       = null
pvt_subnet_ids = []
pub_subnet_ids = []
#####===================================================================================================#####

launch_template = {}
ssh_public_key  = ""
ssh_source_sg   = null

cluster_endpoint_public_access_cidrs = null
cluster_service_ipv4_cidr            = "172.20.0.0/16"

eks_cluster_create_timeout = "30m"
eks_cluster_delete_timeout = "30m"

cluster_encryption_resources = ["secrets"]
cluster_egress_cidrs         = ["0.0.0.0/0"]

node_labels = {
  "component" : "learning"
}

cluster_version        = "1.20"
cluster_name           = null
cluster_log_kms_key_id = ""

enable_public_access  = true
enable_private_access = true
pvt_node_group_name   = "Private-EKS-NodeGroup-11"
pub_node_group_name   = "Public-EKS-NodeGroup-11"
ami_type              = "AL2_x86_64"
ami_release_version   = "1.20.4-20210826"
disk_size             = 30
instance_types        = ["t3a.medium"]
pvt_desired_size      = 1
pvt_max_size          = 1
pvt_min_size          = 1
public_desired_size   = 1
public_max_size       = 1
public_min_size       = 1


log_retention     = 3
enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]