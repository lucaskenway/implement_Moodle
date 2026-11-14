# =============================================================================
# modules/database/outputs.tf — Outputs exportados pelo módulo de banco de dados
# TODO: Adicione outputs extras se precisar expor outros atributos do RDS
# =============================================================================

output "rds_address" {
  description = "Hostname do endpoint RDS (sem porta) — use em MOODLE_DATABASE_HOST."
  value       = aws_db_instance.moodle.address
}

output "rds_port" {
  description = "Porta do endpoint RDS — use em MOODLE_DATABASE_PORT_NUMBER."
  value       = aws_db_instance.moodle.port
}
