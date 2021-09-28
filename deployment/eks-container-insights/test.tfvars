default_region = "us-east-1"

team         = "LearningTeam"
owner        = "Vivek"
isMonitoring  = true
project     = "LearningTF"
component = "Managed-EKS-ContainerInsights"

enabled = true
oidc_url = ""
oidc_arn = ""
helm = {
  repository      = "https://aws.github.io/eks-charts"
  cleanup_on_fail = true
}

cluster_name = ""

