# =============================================================================
# terraform/main.tf — Instancia os três módulos da infraestrutura Moodle AWS
# TODO: Revise as passagens de variáveis entre módulos antes do terraform apply
# =============================================================================

module "networking" {
  source = "./modules/networking"

  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  public_subnet_id      = module.networking.public_subnet_id
  ec2_security_group_id = module.networking.ec2_security_group_id
  ec2_instance_type     = var.ec2_instance_type
  rds_address           = module.database.rds_address
  rds_port              = module.database.rds_port
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  moodle_admin_password = var.moodle_admin_password
  repo_url              = var.repo_url
  repo_branch           = var.repo_branch
}
