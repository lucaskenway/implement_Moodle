# =============================================================================
# modules/networking/main.tf — VPC, subnets, IGW, route table e security groups
# TODO: Revise os CIDRs e AZs conforme a região do seu ambiente
# =============================================================================

# -----------------------------------------------------------------------------
# VPC principal
# enable_dns_hostnames = true é obrigatório para o DNS público da EC2 funcionar
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# -----------------------------------------------------------------------------
# Subnets
# 1 pública (EC2) + 2 privadas em AZs distintas (exigido pelo subnet group do RDS)
# -----------------------------------------------------------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-a"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_name}-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project_name}-private-b"
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway + Route Table pública
# Apenas a subnet pública tem rota para o IGW
# As subnets privadas usam a route table main (sem saída para internet)
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Security Group — EC2
# Ingress: HTTP (80) de qualquer origem + SSH (22) restrito ao CIDR configurado
# Egress: liberado para download de pacotes, imagens Docker e clone do repo
# TODO: Restrinja ssh_allowed_cidr ao seu IP no terraform.tfvars
# -----------------------------------------------------------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Permite HTTP publico e SSH restrito para a EC2 do Moodle"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP publico — acesso ao Moodle"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH restrito ao CIDR configurado (menor privilegio)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Saida liberada para downloads e comunicacao com RDS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# -----------------------------------------------------------------------------
# Security Group — RDS
# Ingress: PostgreSQL (5432) SOMENTE a partir do SG da EC2 (menor privilegio)
# Nunca usar cidr_blocks aqui — impede acesso direto da internet ao banco
# -----------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Permite PostgreSQL somente a partir do SG da EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL — origem restrita ao SG da EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Saida liberada"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}
