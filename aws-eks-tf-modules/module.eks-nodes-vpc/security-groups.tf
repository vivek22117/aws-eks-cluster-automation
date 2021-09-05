#################################################
#       Bastion Host Security Group             #
#################################################
resource "aws_security_group" "eks_admin_host_sg" {
  name = "eks-${var.environment}-adminhost-sg"

  description = "Allow SSH from owner IP"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, map("Name", "eks-${var.environment}-admin-host-sg"))
}

#################################################
#       VPC Endpoints Security Group            #
#################################################
resource "aws_security_group" "vpce" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  name   = "vpc-endpoint-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  tags = merge(local.common_tags, map("Name", "${var.environment}-vpc-endpoint-sg"))
}

resource "aws_security_group" "ecs_s3_endpoint_sg" {
  depends_on = [aws_vpc_endpoint.s3_endpoint]
  count      = var.enable_vpc_endpoint == "true" ? 1 : 0

  name   = "ecs-s3-endpoint-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3_endpoint.*.prefix_list_id]
  }
  tags = merge(local.common_tags, map("Name", "${var.environment}-ecs-s3-endpoint-sg"))
}


