# =============================================================================
# modules/database/variables.tf — Variáveis do módulo RDS PostgreSQL
# TODO: Preencha db_username, db_password e db_name no terraform.tfvars
# =============================================================================

variable "project_name" {
  type        = string
  description = "Prefixo usado em todos os recursos para identificar o projeto."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Lista de IDs das subnets privadas para o subnet group do RDS (mínimo 2 AZs)."
}

variable "rds_security_group_id" {
  type        = string
  description = "ID do Security Group do RDS (permite 5432 somente do SG da EC2)."
}

variable "db_name" {
  type        = string
  description = "Nome do banco de dados criado na instância RDS."
  default     = "moodle"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Usuário master do banco de dados RDS. Forneça via terraform.tfvars."
  # TODO: Defina em terraform.tfvars — nunca coloque o valor aqui
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha master do banco de dados RDS. Use somente letras e números."
  # TODO: Defina em terraform.tfvars — senha forte, somente letras e números
}
