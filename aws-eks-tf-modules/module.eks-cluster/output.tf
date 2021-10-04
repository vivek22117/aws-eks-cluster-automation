output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = aws_eks_cluster.learning_eks_cluster.id
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.learning_eks_cluster.arn
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.learning_eks_cluster.endpoint
}

output "eks_cluster_version" {
  description = "The Kubernetes server version of the cluster"
  value       = aws_eks_cluster.learning_eks_cluster.version
}

output "eks_cluster_identity_oidc_issuer" {
  description = "The OIDC Identity issuer for the cluster"
  value       = join("", aws_eks_cluster.learning_eks_cluster.*.identity.0.oidc.0.issuer)
}

output "eks_cluster_identity_oidc_issuer_arn" {
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "eks_cluster_identity_oidc_url" {
  value = replace(aws_iam_openid_connect_provider.eks_oidc_provider.url, "https://", "")
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.learning_eks_cluster.certificate_authority
}

output "eks_cluster_iam_role_arn" {
  value = aws_iam_role.eks_cluster_iam.arn
}

output "eks_cluster_worker_role_arn" {
  value = aws_iam_role.eks_nodes_role.arn
}

output "eks_cluster_austoscaling_policy_arn" {
  value = aws_iam_policy.cluster_autoscaling_policy.arn
}

output "eks_vpc_config" {
  value = aws_eks_cluster.learning_eks_cluster.vpc_config
}

output "eks_cluster_sg_id" {
  value = aws_eks_cluster.learning_eks_cluster.vpc_config.*.cluster_security_group_id[0]
}

output "worker_node_ssh_key" {
  value = tls_private_key.eks_admin_host_ssh_data.public_key_openssh
}

output "ssh_keypair_name" {
  value = aws_key_pair.ssh_key.key_name
}


data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.learning_eks_cluster.name
}


output "helm_config" {
  description = "The configurations map for Helm provider"
  sensitive   = true
  value = {
    host  = aws_eks_cluster.learning_eks_cluster.endpoint
    token = data.aws_eks_cluster_auth.cluster_auth.token
    ca    = aws_eks_cluster.learning_eks_cluster.certificate_authority
  }
}