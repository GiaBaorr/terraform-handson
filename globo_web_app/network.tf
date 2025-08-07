##################################################################################
# DATA
##################################################################################

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
module "app" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  cidr = var.vpc_cidr_block

  azs = slice(data.aws_availability_zones.available.names, 0, var.vpc_public_subnet_count)
  # list of availability zones to use for public subnets
  public_subnets = [for subnet in range(var.vpc_public_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]
  # list of public subnets to create based on the CIDR block and count

  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  enable_dns_hostnames    = var.enable_dns_hostnames
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-vpc"
  })
}

# SECURITY GROUPS #
# Nginx security group linked to VPC
resource "aws_security_group" "nginx_sg" {
  name   = "${local.naming_prefix}-nginx-sg"
  vpc_id = module.app.vpc_id

  # HTTP access from anywhere for port 80 to 80 of ec2
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # outbound internet access: allow outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "${local.naming_prefix}-alb-sg"
  vpc_id = module.app.vpc_id

  # HTTP access from anywhere for port 80 to 80 of ec2
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access: allow outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
