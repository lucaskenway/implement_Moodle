# =============================================================================
# modules/database/main.tf — RDS PostgreSQL 15 em subnets privadas
# TODO: Ajuste allocated_storage ou instance_class conforme necessidade
# =============================================================================

# -----------------------------------------------------------------------------
# Subnet group — agrupa as subnets privadas em 2 AZs (exigido pelo RDS)
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "moodle" {
  name        = "${var.project_name}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group do RDS Moodle (subnets privadas em 2 AZs)"

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# -----------------------------------------------------------------------------
# Instância RDS PostgreSQL 15
#
# publicly_accessible = false — RDS sem IP público, acessível só pela VPC
# skip_final_snapshot = true  — ambiente educacional, sem snapshot final
# multi_az = false            — single-AZ para reduzir custo no Learn Lab
# -----------------------------------------------------------------------------
resource "aws_db_instance" "moodle" {
  identifier        = "${var.project_name}-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.moodle.name
  vpc_security_group_ids = [var.rds_security_group_id]

  # Segurança: RDS sem IP público — acessível somente pela EC2 na mesma VPC
  publicly_accessible = false

  # TODO: Em produção, considere multi_az = true para alta disponibilidade
  multi_az            = false
  skip_final_snapshot = true

  tags = {
    Name = "${var.project_name}-db"
  }
}
