#----------------------------------------------------------
# My Terraform
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give access to Internet from Private Subnets
#
# Made by Dmitry Yemelin. 
#----------------------------------------------------------

#==============================================================

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "cloudx" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-cloudx-vpc"
  }
}
# resource "aws_vpc" "main" {
#   cidr_block = var.vpc_cidr
#   tags = {
#     Name = "${var.env}-vpc"
#   }
# }

resource "aws_internet_gateway" "cloudx_igw" {
  vpc_id = aws_vpc.cloudx.id
  tags = {
    Name = "${var.env}-cloudx-igw"
  }
}

# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.cloudx.id
#   tags = {
#     Name = "${var.env}-igw"
#   }
# }


#-------------Public Subnets and Routing----------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.cloudx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudx_igw.id
  }

  tags = {
    Name = "${var.env}-cloudx-public_rt"
  }
}

resource "aws_subnet" "public" {
  for_each = var.subnets_data

  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = each.value["cidr"]
  availability_zone       = each.value["az"]
  map_public_ip_on_launch = true

  tags = {
    Name = each.value["name"]
  }
}
resource "aws_route_table_association" "public_rta" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private_subnet_db" {
  for_each = var.private_subnet_data

  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = each.value["cidr"]
  availability_zone       = each.value["az"]
  map_public_ip_on_launch = false

  tags = {
    Name = each.value["name"]
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.cloudx.id

  tags = {
    Name = "${var.env}-cloudx-private_rt"
  }
}

resource "aws_route_table_association" "private_rta" {
  #for_each = aws_subnet.private_subnet_db
  for_each = merge(aws_subnet.private_subnet_db, aws_subnet.private_subnet_ecs)

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_subnet" "private_subnet_ecs" {
  for_each = var.private_subnet_ecs_data

  vpc_id                  = aws_vpc.cloudx.id
  cidr_block              = each.value["cidr"]
  availability_zone       = each.value["az"]
  map_public_ip_on_launch = false

  tags = {
    Name = each.value["name"]
  }
}

# SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]

  tags = {
    Name = "${var.env}-ghost-ssm-vpc-endpoint"
  }
}

# ECR (API)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]

  tags = {
    Name = "${var.env}-ghost-ecr-vpc-endpoint"
  }
}

# ECR (Docker)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]

  tags = {
    Name = "${var.env}-ghost-ecr-dkr-vpc-endpoint"
  }
}

# CloudWatch
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.monitoring"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]

  tags = {
    Name = "${var.env}-ghost-cloudwatch-mon-vpc-endpoint"
  }
}

# CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
  tags = {
    Name = "${var.env}-ghost-cloudwatch-logs-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.cloudx.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [aws_route_table.private_rt.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    Name = "${var.env}-ghost-s3-vpc-gateway"
  }
}

resource "aws_vpc_endpoint" "efs" {
  vpc_id              = aws_vpc.cloudx.id
  service_name        = "com.amazonaws.${var.region}.elasticfilesystem"
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
  tags = {
    Name = "${var.env}-ghost-efs-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [for s in values(aws_subnet.private_subnet_ecs) : s.id]

  private_dns_enabled = true
  tags = {
    Name = "${var.env}-ghost-secret-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecs_agent" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ecs-agent"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
}

resource "aws_vpc_endpoint" "ecs_telemetry" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ecs-telemetry"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ecs"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id             = aws_vpc.cloudx.id
  service_name       = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = [for s in values(aws_subnet.private_subnet_ecs) : s.id]
}

# resource "aws_route_table_association" "private_rta_ecs" {
#   for_each = aws_subnet.private_subnet_ecs

#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.private_rt.id
# }


# resource "aws_subnet" "public_subnets" {
#   count                   = length(var.public_subnet_cidrs)
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = element(var.public_subnet_cidrs, count.index)
#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "${var.env}-public-${count.index + 1}"
#   }
# }


# resource "aws_route_table" "public_subnets" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#   tags = {
#     Name = "${var.env}-route-public-subnets"
#   }
# }

# resource "aws_route_table_association" "public_routes" {
#   count          = length(aws_subnet.public_subnets[*].id)
#   route_table_id = aws_route_table.public_subnets.id
#   subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
# }


#-----NAT Gateways with Elastic IPs--------------------------


# resource "aws_eip" "nat" {
#   count = length(var.private_subnet_cidrs)
#   vpc   = true
#   tags = {
#     Name = "${var.env}-nat-gw-${count.index + 1}"
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   count         = length(var.private_subnet_cidrs)
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
#   tags = {
#     Name = "${var.env}-nat-gw-${count.index + 1}"
#   }
# }


# #--------------Private Subnets and Routing-------------------------

# resource "aws_subnet" "private_subnets" {
#   count             = length(var.private_subnet_cidrs)
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = element(var.private_subnet_cidrs, count.index)
#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   tags = {
#     Name = "${var.env}-private-${count.index + 1}"
#   }
# }

# resource "aws_route_table" "private_subnets" {
#   count  = length(var.private_subnet_cidrs)
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.nat[count.index].id
#   }
#   tags = {
#     Name = "${var.env}-route-private-subnet-${count.index + 1}"
#   }
# }

# resource "aws_route_table_association" "private_routes" {
#   count          = length(aws_subnet.private_subnets[*].id)
#   route_table_id = aws_route_table.private_subnets[count.index].id
#   subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
# }

# #==============================================================
