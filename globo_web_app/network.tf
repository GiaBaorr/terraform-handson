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
# Create VPC
resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = local.common_tags
}

# Create IGW and link to VPC
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = local.common_tags
}

# Create public subnets in VPC
resource "aws_subnet" "public_subnets" {
  count                   = var.vpc_public_subnet_count
  cidr_block              = var.vpc_public_subnets_cidr_block[count.index]
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = local.common_tags
}

# ROUTING #
# Create route table and route internet gateway to public internet
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
}

# Link public subnets with route table
resource "aws_route_table_association" "app_subnets" {
  count          = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS #
# Nginx security group linked to VPC
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.app.id

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
  name   = "nginx_alb_sg"
  vpc_id = aws_vpc.app.id

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
}
