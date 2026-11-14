# Tasks — moodle-aws-p2

## Etapa 1 — Preparação do repositório [CONCLUÍDA]

- [x] 1.1 Corrigir .gitignore (remove .kiro/, adiciona padrões Terraform)
- [x] 1.2 Criar .gitattributes (normaliza EOL para LF)
- [x] 1.3 Criar docker/.dockerignore (exclui .env do contexto de build)
- [x] 1.4 Corrigir docker/Dockerfile (extensão pgsql, hadolint ignores)

---

## Etapa 2 — Infraestrutura Terraform

- [ ] 2.1 Criar `terraform/versions.tf`
      provider "aws" ~> 5.0, required_version >= "1.5"

- [ ] 2.2 Criar `terraform/modules/networking/variables.tf`
      project_name, vpc_cidr, ssh_allowed_cidr

- [ ] 2.3 Criar `terraform/modules/networking/main.tf`
      aws_vpc, 3 subnets, igw, route_table, route_table_association, sg-ec2, sg-rds

- [ ] 2.4 Criar `terraform/modules/networking/outputs.tf`
      vpc_id, public_subnet_id, private_subnet_ids, ec2_security_group_id, rds_security_group_id

- [ ] 2.5 Criar `terraform/modules/database/variables.tf`
      project_name, private_subnet_ids, rds_security_group_id, db_name, db_username, db_password

- [ ] 2.6 Criar `terraform/modules/database/main.tf`
      aws_db_subnet_group, aws_db_instance (postgres 15, db.t3.micro, publicly_accessible=false)

- [ ] 2.7 Criar `terraform/modules/database/outputs.tf`
      rds_address (.address), rds_port (.port)

- [ ] 2.8 Criar `terraform/modules/compute/variables.tf`
      project_name, public_subnet_id, ec2_security_group_id, ec2_instance_type,
      rds_address, rds_port, db_name, db_username, db_password,
      moodle_admin_password, repo_url, repo_branch

- [ ] 2.9 Criar `terraform/modules/compute/main.tf`
      data aws_ami (AL2023), data aws_iam_instance_profile (LabRole), aws_instance

- [ ] 2.10 Criar `terraform/modules/compute/outputs.tf`
       ec2_public_dns, ec2_instance_id

- [ ] 2.11 Criar `terraform/modules/compute/user_data.sh`
       dnf install docker git, curl Compose v2.29.1, systemctl enable docker,
       git clone, criar .env com heredoc 'EOF', chmod 600, docker compose up --no-deps moodle

- [ ] 2.12 Criar `terraform/variables.tf` (variáveis raiz — ver tabela no design.md)

- [ ] 2.13 Criar `terraform/main.tf`
       module networking, module database, module compute com todas as passagens de variável

- [ ] 2.14 Criar `terraform/outputs.tf`
       ec2_public_dns, rds_endpoint (rds_address:rds_port), vpc_id

- [ ] 2.15 Criar `terraform/terraform.tfvars.example`
       template comentado sem valores reais, com # TODO: em cada campo

- [ ] 2.16 Ajustar `docker/docker-compose.yml`
       porta: "${MOODLE_HTTP_PORT:-8080}:80"
       env_file: "- .env" (formato simples)

- [ ] 2.17 Verificar: `terraform fmt -recursive` sem erros
- [ ] 2.18 Verificar: todos os arquivos .tf e .sh (exceto versions.tf) têm # TODO:
- [ ] 2.19 Rodar pytest — deve passar 51 testes, 0 skipped

---

## Etapa 4 — Documento de arquitetura

- [ ] 4.1 Revisar `docs/architecture-design.md`
       Remover todos os `<!-- TODO -->` restantes (diagrama, link custo)

- [ ] 4.2 Substituir diagrama placeholder por diagrama ASCII detalhado
       Cobrir: VPC, subnets, EC2, RDS, SGs, IGW, fluxo de acesso

- [ ] 4.3 Preencher Custo Estimado com valores reais e link do AWS Pricing Calculator

- [ ] 4.4 Verificar: `grep -c "TODO" docs/architecture-design.md` retorna 0

---

## Etapa 5 — Workflows CI/CD

- [ ] 5.1 Reescrever `.github/workflows/terraform-plan.yml`
       Substituir stub por workflow funcional (ver R5.1 no requirements.md)
       Secrets necessários: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN,
       TF_VAR_db_username, TF_VAR_db_password, TF_VAR_moodle_admin_password, TF_VAR_repo_url

- [ ] 5.2 Corrigir `.github/workflows/terraform-validate.yml`
       Remover `if: ${{ hashFiles('terraform/versions.tf') != '' }}`

- [ ] 5.3 Corrigir `.github/workflows/docker-lint.yml`
       Adicionar step `cp docker/.env.example docker/.env` antes do compose config

- [ ] 5.4 Verificar: pytest passa (test_workflow_step_comments.py — todos run: com name:)

---

## Etapa 7 — Commit e push final

- [ ] 7.1 Commit: docker-compose.yml
       "fix(docker): parametriza porta e simplifica env_file"

- [ ] 7.2 Commit: docker-lint.yml
       "fix(ci): copia env.example para .env antes de validar compose"

- [ ] 7.3 Commit: terraform-validate.yml
       "fix(ci): remove guard hashFiles do terraform-validate"

- [ ] 7.4 Commit: todos os arquivos terraform/ novos
       "feat(terraform): implementa modulos networking, compute e database"

- [ ] 7.5 Commit: docs/architecture-design.md
       "docs(arch): preenche design de arquitetura da solucao AWS"

- [ ] 7.6 Commit: terraform-plan.yml
       "feat(ci): implementa workflow terraform-plan com workflow_dispatch"

- [ ] 7.7 Push origin feat/aula-11-docker-local

- [ ] 7.8 Verificar pytest final: 51 passed, 0 skipped

---

## Etapa 3 — Deploy real na AWS [OPCIONAL]

- [ ] 3.1 Configurar credenciais do Learner Lab em ~/.aws/credentials
- [ ] 3.2 Criar terraform/terraform.tfvars com valores reais
- [ ] 3.3 terraform init && terraform plan — revisar saída
- [ ] 3.4 terraform apply — anotar ec2_public_dns e rds_endpoint
- [ ] 3.5 Aguardar boot da EC2 (~3-5 min) e verificar /var/log/user-data.log
- [ ] 3.6 scripts/health-check.sh <ec2_public_dns> — deve retornar exit 0
- [ ] 3.7 terraform destroy ao encerrar a sessão do Lab
