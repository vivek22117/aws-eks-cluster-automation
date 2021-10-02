#################################################
#                  S3 Endpoint                  #
#################################################
resource "aws_vpc_endpoint" "s3_endpoint" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.default_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = flatten([aws_route_table.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-s3-endpoint"))
}

#################################################
#            AWS ECR VPC Endpoint               #
#################################################
resource "aws_vpc_endpoint" "private_link_ecr_api" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.default_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-ecr-api-endpoint"))
}

resource "aws_vpc_endpoint" "private_link_ecr_dkr" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.default_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-dkr-endpoint"))
}


#################################################
#                  AWS ECS VPC Endpoint         #
#################################################
resource "aws_vpc_endpoint" "private_link_ecs_agent" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.default_region}.ecs-agent"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-ecs-agent-endpoint"))
}

resource "aws_vpc_endpoint" "private_link_ecs_telemetry" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.default_region}.ecs-telemetry"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-ecs-telemetry-endpoint"))
}

resource "aws_vpc_endpoint" "private_link_ecs" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.default_region}.ecs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-ecs-endpoint"))
}

#################################################
#              AWS CW Logs VPC Endpoint         #
#################################################
resource "aws_vpc_endpoint" "private_link_cw_logs" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.default_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-cw-endpoint"))
}


#################################################
#              AWS EC2 VPC Endpoint             #
#################################################
resource "aws_vpc_endpoint" "ec2" {
  count = var.enable_vpc_endpoint == "true" ? 1 : 0

  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${var.default_region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = flatten([aws_security_group.vpce.*.id])
  subnet_ids          = flatten([aws_subnet.private.*.id])

  tags = merge(local.common_tags, map("Name", "${var.environment}-ec2-endpoint"))
}