# =============================================================================
# terraform/outputs.tf — Outputs raiz exportados após o terraform apply
# TODO: Use estes valores para configurar o health-check e validar o deploy
# =============================================================================

output "ec2_public_dns" {
  description = "DNS público da EC2 — acesse o Moodle em http://<ec2_public_dns>"
  value       = module.compute.public_dns
}

output "ec2_public_ip" {
  description = "IP público da EC2."
  value       = module.compute.public_ip
}

output "public_dns" {
  description = "DNS público da EC2 (alias de ec2_public_dns)."
  value       = module.compute.public_dns
}

output "public_ip" {
  description = "IP público da EC2 (alias de ec2_public_ip)."
  value       = module.compute.public_ip
}

output "moodle_url" {
  description = "URL de acesso ao Moodle após o deploy."
  value       = "http://${module.compute.public_dns}"
}

output "rds_endpoint" {
  description = "Endpoint completo do RDS (hostname:porta)."
  value       = "${module.database.rds_address}:${module.database.rds_port}"
}

output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.networking.vpc_id
}
