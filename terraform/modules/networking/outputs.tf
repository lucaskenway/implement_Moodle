# =============================================================================
# modules/networking/outputs.tf — Outputs exportados pelo módulo de rede
# TODO: Adicione outputs extras se precisar referenciar outros recursos de rede
# =============================================================================

output "vpc_id" {
  description = "ID da VPC principal."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da subnet pública onde a EC2 será criada."
  value       = aws_subnet.public_a.id
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas (usada pelo subnet group do RDS)."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "ec2_security_group_id" {
  description = "ID do Security Group da EC2."
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS."
  value       = aws_security_group.rds.id
}
