# =============================================================================
# modules/compute/outputs.tf — Outputs exportados pelo módulo de compute
# TODO: Adicione outputs extras se precisar expor outros atributos da EC2
# =============================================================================

output "ec2_public_dns" {
  description = "DNS público da instância EC2 — use no health-check.sh e no Moodle."
  value       = aws_instance.moodle.public_dns
}

output "ec2_instance_id" {
  description = "ID da instância EC2."
  value       = aws_instance.moodle.id
}
