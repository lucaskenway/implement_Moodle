# =============================================================================
# terraform/outputs.tf — Outputs raiz exportados após o terraform apply
# TODO: Use estes valores para configurar o health-check e validar o deploy
# =============================================================================

output "ec2_public_dns" {
  description = "DNS público da EC2 — acesse o Moodle em http://<ec2_public_dns>"
  value       = module.compute.ec2_public_dns
}

output "rds_endpoint" {
  description = "Endpoint completo do RDS (hostname:porta)."
  value       = "${module.database.rds_address}:${module.database.rds_port}"
}

output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.networking.vpc_id
}
