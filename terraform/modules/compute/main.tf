# =============================================================================
# modules/compute/main.tf — Instância EC2 com Amazon Linux 2023 e Moodle
# TODO: Ajuste ec2_instance_type ou repo_branch no terraform.tfvars se necessário
# =============================================================================

# -----------------------------------------------------------------------------
# AMI mais recente do Amazon Linux 2023 (x86_64)
# Usar data source evita fixar um AMI ID que muda por região e versão
# -----------------------------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# LabRole — instance profile pré-existente no AWS Learner Lab
# Restrição do Learn Lab: não é permitido criar aws_iam_role ou
# aws_iam_instance_profile. Use sempre via data source.
# -----------------------------------------------------------------------------
data "aws_iam_instance_profile" "lab_role" {
  name = "LabInstanceProfile"
}

# -----------------------------------------------------------------------------
# Instância EC2
# key_name = "vockey" — par de chaves pré-existente no Learner Lab
# user_data via templatefile() — injeta variáveis Terraform no script de boot
# -----------------------------------------------------------------------------
resource "aws_instance" "moodle" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.ec2_security_group_id]
  iam_instance_profile   = data.aws_iam_instance_profile.lab_role.name

  # Par de chaves pré-existente no Learner Lab
  # TODO: Baixe o labsuser.pem no portal AWS Academy para acessar via SSH
  key_name = "vockey"

  # Disco ampliado para 20 GB gp3 — o build da imagem Docker esgotava o disco padrão da AMI (2 GB)
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh", {
    rds_address           = var.rds_address
    rds_port              = var.rds_port
    db_name               = var.db_name
    db_username           = var.db_username
    db_password           = var.db_password
    moodle_admin_password = var.moodle_admin_password
    repo_url              = var.repo_url
    repo_branch           = var.repo_branch
    compose_version       = var.compose_version
  })

  tags = {
    Name = "${var.project_name}-moodle"
  }
}
