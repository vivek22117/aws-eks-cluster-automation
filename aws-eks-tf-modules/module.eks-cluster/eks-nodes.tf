locals {
  node_ssh_source_sg = var.ssh_source_sg == null ? data.terraform_remote_state.eks_vpc.outputs.eks_bastion_sg_id : var.ssh_source_sg
}

########################################################
#    Key pair to be used for SSH access                #
########################################################
resource "tls_private_key" "eks_admin_host_ssh_data" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "eks-admin-key"
  public_key = var.ssh_public_key == "" ? tls_private_key.eks_admin_host_ssh_data.public_key_openssh : var.ssh_public_key

  tags = merge(local.common_tags, map("Name", "eks-nodes-ssh-key"))
}


#################################################
#       EKS Cluster Nodes In Private Subnet     #
#################################################
resource "aws_eks_node_group" "eks_private_ng" {
  cluster_name = aws_eks_cluster.learning_eks_cluster.name

  node_group_name = var.pvt_node_group_name
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = local.pvt_nodeGroup_subnets
  ami_type        = var.ami_type
  disk_size       = var.disk_size
  instance_types  = var.instance_types
  capacity_type   = "ON_DEMAND"

  force_update_version = false
  labels               = var.node_labels
  release_version      = var.ami_release_version

  scaling_config {
    desired_size = var.pvt_desired_size
    max_size     = var.pvt_max_size
    min_size     = var.pvt_min_size
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.ssh_key.key_name
    source_security_group_ids = [local.node_ssh_source_sg]
  }

  dynamic "launch_template" {
    for_each = length(var.launch_template) == 0 ? [] : [var.launch_template]
    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version", null)
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  tags = merge(local.common_tags, map("Name", "eks-${var.environment}-pvt-node-gp"))

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.learning_eks_cluster,
    aws_security_group.eks_nodes_sg,
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
  ]
}


#################################################
#       EKS Cluster Nodes In Public Subnet      #
#################################################
resource "aws_eks_node_group" "eks_public_ng" {
  cluster_name = aws_eks_cluster.learning_eks_cluster.name

  node_group_name = var.pub_node_group_name
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = local.pub_nodeGroup_subnets
  ami_type        = var.ami_type
  disk_size       = var.disk_size
  instance_types  = var.instance_types
  capacity_type   = "ON_DEMAND"

  force_update_version = false
  labels               = var.node_labels
  release_version      = var.ami_release_version

  scaling_config {
    desired_size = var.public_desired_size
    max_size     = var.public_max_size
    min_size     = var.public_min_size
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.ssh_key.key_name
    source_security_group_ids = [data.terraform_remote_state.eks_vpc.outputs.eks_bastion_sg_id]
  }

  dynamic "launch_template" {
    for_each = length(var.launch_template) == 0 ? [] : [var.launch_template]
    content {
      id      = lookup(launch_template.value, "id", null)
      name    = lookup(launch_template.value, "name", null)
      version = lookup(launch_template.value, "version", null)
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  tags = merge(local.common_tags, map("Name", "eks-${var.environment}-pub-node-gp"))

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.learning_eks_cluster,
    aws_security_group.eks_nodes_sg,
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
  ]
}