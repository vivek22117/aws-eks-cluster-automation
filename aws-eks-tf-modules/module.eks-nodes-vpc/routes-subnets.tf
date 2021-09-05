######################################################
# NAT gateways  enable instances in a private subnet #
# to connect to the Internet or other AWS services,  #
# but prevent the internet from initiating           #
# a connection with those instances.                 #
#                                                    #
# Each NAT gateway requires an Elastic IP.           #
######################################################
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.vpc_igw]

  vpc   = true
  count = var.enable_nat_gateway == "true" && var.environment != "prod" ? 1 : 2

  tags = {
    Name = "eks-${var.environment}-eip-${aws_vpc.vpc.id}-${count.index}"
  }
}


######################################################
# Public subnets                                     #
# Each subnet in a different AZ                      #
######################################################
resource "aws_subnet" "public" {
  count = var.enable_eks_public_subnet == "true" ? length(var.public_azs_with_cidr) : 0

  cidr_block              = values(var.public_azs_with_cidr)[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = keys(var.public_azs_with_cidr)[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                                            = "eks-${var.environment}-pub-${element(keys(var.public_azs_with_cidr), count.index)}"
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
    "kubernetes.io/role/elb"                        = "1",
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "true",
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


######################################################
# Private subnets                                    #
# Each subnet in a different AZ                      #
######################################################
resource "aws_subnet" "private" {
  count = var.enable_eks_pvt_subnet == "true" ? length(var.private_azs_with_cidr) : 0

  cidr_block              = values(var.private_azs_with_cidr)[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = keys(var.private_azs_with_cidr)[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name                                            = "eks-${var.environment}-pvt-${element(keys(var.private_azs_with_cidr), count.index)}"
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "true",
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


######################################################
# Private DB subnets for RDS, Aurora                 #
# Each subnet in a different AZ                      #
######################################################
resource "aws_subnet" "db_subnet" {
  count = var.enable_db_subnet == "true" ? length(var.db_azs_with_cidr) : 0

  cidr_block              = values(var.db_azs_with_cidr)[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = keys(var.db_azs_with_cidr)[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    "Name" = "eks-${var.environment}-db-${element(keys(var.db_azs_with_cidr), count.index)}"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_db_subnet_group" "database_subnet_gp" {
  count = var.enable_db_subnet == "true" ? 1 : 0

  name        = var.db_subnet_gp
  description = "Database subnet group for EKS VPC"
  subnet_ids  = aws_subnet.db_subnet.*.id

  tags = merge(local.common_tags, {
    "Name" = "eks-${var.environment}-db-subnetGp-${aws_vpc.vpc.id}"
  })
}


#################################################
#       Create NatGateway and allocate EIP      #
#################################################
resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [aws_internet_gateway.vpc_igw, aws_eip.nat_eip, aws_subnet.public]

  count = var.enable_nat_gateway == "true" ? length(aws_eip.nat_eip.*.id) : 0

  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]

  tags = {
    Name = "eks-${var.environment}-ng-${aws_vpc.vpc.id}-${count.index}"
  }

}


######################################################
# Create route table for private subnets             #
# Route non-local traffic through the NAT gateway    #
# to the Internet                                    #
######################################################
resource "aws_route_table" "private" {
  count  = var.enable_eks_pvt_subnet == "true" ? length(var.private_azs_with_cidr) : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    "Name"                                        = "eks-${var.environment}-pvt-rt-${aws_vpc.vpc.id}-${count.index}"
    "alpha.eksctl.io/cluster-name"                = var.cluster_name
    "eksctl.cluster.k8s.io/v1alpha5/cluster-name" = var.cluster_name
  })
}

resource "aws_route" "private_nat_gateway_route" {
  count = var.enable_nat_gateway == "true" && var.enable_eks_pvt_subnet == "true" ? length(var.private_azs_with_cidr) : 0

  route_table_id         = aws_route_table.private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.*.id[0]
}

resource "aws_route_table_association" "private_association" {
  depends_on = [aws_route_table.private, aws_subnet.private]

  count = length(aws_route_table.private.*.id)

  route_table_id = aws_route_table.private.*.id[count.index]
  subnet_id      = aws_subnet.private.*.id[count.index]
}


######################################################
# Route the public subnet traffic through            #
# the Internet Gateway                               #
######################################################
resource "aws_route_table" "public" {
  count = var.enable_eks_public_subnet == "true" ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = merge(local.common_tags, {
    "Name"                                        = "eks-${var.environment}-eks-rt-${aws_vpc.vpc.id}"
    "alpha.eksctl.io/cluster-name"                = var.cluster_name
    "eksctl.cluster.k8s.io/v1alpha5/cluster-name" = var.cluster_name
  })
}

resource "aws_route_table_association" "public_association" {
  depends_on = [aws_route_table.public, aws_subnet.public]

  count = var.enable_eks_public_subnet == "true" ? length(var.public_azs_with_cidr) : 0

  route_table_id = aws_route_table.public.*.id[0]
  subnet_id      = aws_subnet.public.*.id[count.index]
}


######################################################
# Route the public subnet traffic through            #
# the NAT Gateway for DB Subnet                      #
######################################################
resource "aws_route_table" "db_rt" {
  count = var.enable_db_subnet == "true" ? length(var.db_azs_with_cidr) : 0

  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, {
    "Name"                                        = "eks-${var.environment}-db-rt-${aws_vpc.vpc.id}-${count.index}"
    "alpha.eksctl.io/cluster-name"                = var.cluster_name
    "eksctl.cluster.k8s.io/v1alpha5/cluster-name" = var.cluster_name
  })
}

resource "aws_route" "private_ng_route" {
  count = var.enable_nat_gateway == "true" && var.enable_db_subnet == "true" ? length(var.db_azs_with_cidr) : 0

  route_table_id         = element(aws_route_table.db_rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, 0)
}

resource "aws_route_table_association" "db_subnet_association" {
  depends_on = [aws_route_table.db_rt, aws_subnet.db_subnet]

  count = length(aws_route_table.db_rt.*.id)

  route_table_id = aws_route_table.db_rt.*.id[count.index]
  subnet_id      = aws_subnet.db_subnet.*.id[count.index]
}


