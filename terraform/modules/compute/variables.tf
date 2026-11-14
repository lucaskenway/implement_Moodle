# =============================================================================
# modules/compute/variables.tf — Variáveis do módulo EC2
# TODO: Preencha repo_url, db_username, db_password e moodle_admin_password
#       no terraform.tfvars antes de executar terraform apply
# =============================================================================

variable "project_name" {
  type        = string
  description = "Prefixo usado em todos os recursos para identificar o projeto."
}

variable "public_subnet_id" {
  type        = string
  description = "ID da subnet pública onde a instância EC2 será criada."
}

variable "ec2_security_group_id" {
  type        = string
  description = "ID do Security Group da EC2 (HTTP 80 + SSH 22)."
}

variable "ec2_instance_type" {
  type        = string
  description = "Tipo da instância EC2."
  default     = "t3.medium"
}

variable "rds_address" {
  type        = string
  description = "Hostname do RDS (sem porta) — injetado no .env do Moodle."
}

variable "rds_port" {
  type        = number
  description = "Porta do RDS — injetado no .env do Moodle."
}

variable "db_name" {
  type        = string
  description = "Nome do banco de dados usado pelo Moodle."
  default     = "moodle"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Usuário do banco de dados RDS. Forneça via terraform.tfvars."
  # TODO: Defina em terraform.tfvars — nunca coloque o valor aqui
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha do banco de dados RDS. Use somente letras e números."
  # TODO: Defina em terraform.tfvars — senha forte, somente letras e números
}

variable "moodle_admin_password" {
  type        = string
  sensitive   = true
  description = "Senha do administrador do Moodle. Use somente letras e números."
  # TODO: Defina em terraform.tfvars — senha forte, somente letras e números
}

variable "repo_url" {
  type        = string
  description = "URL HTTPS do fork do repositório clonado na EC2 no boot."
  # TODO: Preencha com a URL do seu fork, ex: https://github.com/usuario/implement_Moodle
}

variable "repo_branch" {
  type        = string
  description = "Branch do repositório a clonar na EC2."
  default     = "feat/aula-11-docker-local"
}

variable "compose_version" {
  type        = string
  description = "Versão do Docker Compose plugin a instalar na EC2 (ex: v2.29.1)."
  default     = "v2.29.1"
  # TODO: Atualize se necessitar de versão mais recente
}
