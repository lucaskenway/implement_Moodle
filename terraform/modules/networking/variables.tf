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
  default     = "0.0.0.0/0"
  description = <<-DESC
    CIDR autorizado para acesso SSH (porta 22) à instância EC2.
    AVISO DE SEGURANÇA: o valor padrão 0.0.0.0/0 permite SSH de qualquer origem.
    TODO: Restrinja ao seu IP público (ex: 203.0.113.10/32) em produção.
  DESC
}
