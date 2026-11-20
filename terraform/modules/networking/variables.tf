# =============================================================================
# modules/networking/variables.tf — Variáveis do módulo de rede
# TODO: Ajuste os valores padrão conforme necessário para o seu ambiente
# =============================================================================

variable "project_name" {
  type        = string
  description = "Prefixo usado em todos os recursos para identificar o projeto."
  # TODO: Preencha no terraform.tfvars (ex: \"moodle-challenge\")
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block da VPC principal."
  default     = "10.0.0.0/16"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR do IP público do aluno no formato x.x.x.x/32, único endereço autorizado a acessar a porta 22 da EC2."

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0)) && endswith(var.ssh_allowed_cidr, "/32") && var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "ssh_allowed_cidr deve ser um único IP no formato x.x.x.x/32 (ex: 203.0.113.10/32). O valor 0.0.0.0/0 não é permitido."
  }
}
