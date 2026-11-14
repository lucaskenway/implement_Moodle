# =============================================================================
# versions.tf — Configuração do provider AWS e versão mínima do Terraform
#
# Este arquivo NÃO contém blocos TODO porque é o único arquivo .tf
# pré-preenchido e funcional do template (ver test_todo_comments.py).
# =============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
