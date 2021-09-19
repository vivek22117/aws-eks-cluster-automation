default_region           = "us-east-1"
tfstate_s3_bucket_prefix = "training"

cidr_block         = "10.2.0.0/20" # 4096 IPs, 10.2.0.0 - 10.2.15.255
instance_tenancy   = "default"
enable_dns         = "true"
support_dns        = "true"
enable_nat_gateway = "true"
db_subnet_gp       = "eks-dbsubnet-group"

public_azs_with_cidr  = ["10.2.0.0/24", "10.2.2.0/24", "10.2.4.0/24"]
private_azs_with_cidr = ["10.2.1.0/24", "10.2.3.0/24", "10.2.5.0/24"]
db_azs_with_cidr      = ["10.2.6.0/24", "10.2.7.0/24", "10.2.8.0/24"]

team         = "Learning-Team"
owner        = "Vivek"
isMonitoring = true

cluster_name = "Learning-EKS"

enable_vpc_endpoint      = "true"
enable_eks_pvt_subnet    = "true"
enable_eks_public_subnet = "true"
enable_db_subnet         = "true"
