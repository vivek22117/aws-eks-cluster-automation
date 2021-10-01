default_region = "us-east-1"

team         = "LearningTeam"
owner        = "Vivek"
isMonitoring  = true
project     = "LearningTF"
component = "Managed-EKS-Autoscaler"

enabled = true
oidc_url = ""
oidc_arn = ""

helm = {
  name            = "cluster-autoscaler"
  chart           = "cluster-autoscaler"
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  cleanup_on_fail = true
}

cluster_name = ""

