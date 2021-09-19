default_region = "us-east-1"

team         = "EKSAdminTeam"
owner        = "Vivek"
isMonitoring  = true
project     = "LearningTF"
component = "Managed-EKS"

eks_bastion_name_prefix = "eks-admin-"
bastion_instance_type   = "t3a.small"
default_cooldown        = 300
volume_size = 20

eks_bastion_asg_desired_capacity = 1
eks_bastion_asg_max_size = 2
eks_bastion_asg_min_size = 1
termination_policies = ["Default"]

eks_iam_group = "eks-developer-group"
apply_config_map_aws_auth = true
map_additional_aws_accounts = []
map_additional_iam_roles = []
map_additional_iam_users = []

kubeconfig_path = "~/.kube/config"
configmap_auth_template_file = ""
configmap_auth_file = ""
