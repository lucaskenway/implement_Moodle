# =============================================================================
# terraform/variables.tf — Variáveis raiz do projeto Terraform
# TODO: Preencha os valores obrigatórios no terraform.tfvars
# =============================================================================

variable "aws_region" {
  type        = string
  description = "Região AWS onde os recursos serão criados."
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Prefixo usado em todos os recursos para identificar o projeto."
  default     = "moodle-challenge"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block da VPC principal."
  default     = "10.0.0.0/16"
}

variable "ec2_instance_type" {
  type        = string
  description = "Tipo da instância EC2 para o Moodle."
  default     = "t3.medium"
}

variable "ssh_allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = <<-DESC
    CIDR autorizado para SSH (porta 22) na EC2.
    AVISO DE SEGURANÇA: padrão 0.0.0.0/0 permite acesso de qualquer origem.
    TODO: Restrinja ao seu IP público (ex: 203.0.113.10/32) em produção.
  DESC
}

variable "db_name" {
  type        = string
  description = "Nome do banco de dados no RDS."
  default     = "moodle"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Usuário master do RDS. Forneça via terraform.tfvars."
  # TODO: Defina em terraform.tfvars
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha master do RDS. Use somente letras e números (mínimo 12 caracteres)."
  # TODO: Defina em terraform.tfvars — senha forte, somente letras e números

  validation {
    condition     = length(var.db_password) >= 12 && can(regex("^[A-Za-z0-9]+$", var.db_password))
    error_message = "db_password deve ter no mínimo 12 caracteres e conter somente letras e números (sem símbolos)."
  }
}

variable "moodle_admin_password" {
  type        = string
  sensitive   = true
  description = "Senha do administrador do Moodle. Use somente letras e números (mínimo 12 caracteres)."
  # TODO: Defina em terraform.tfvars — senha forte, somente letras e números

  validation {
    condition     = length(var.moodle_admin_password) >= 12 && can(regex("^[A-Za-z0-9]+$", var.moodle_admin_password))
    error_message = "moodle_admin_password deve ter no mínimo 12 caracteres e conter somente letras e números (sem símbolos)."
  }
}

variable "repo_url" {
  type        = string
  description = "URL HTTPS do fork do repositório clonado na EC2 no boot."
  # TODO: Preencha com a URL do seu fork no terraform.tfvars

  validation {
    condition     = can(regex("^https://", var.repo_url))
    error_message = "repo_url deve começar com https:// (ex: https://github.com/usuario/implement_Moodle)."
  }
}

variable "repo_branch" {
  type        = string
  description = "Branch do repositório a clonar na EC2."
  default     = "feat/aula-11-docker-local"
}
