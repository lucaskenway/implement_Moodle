# Tasks — moodle-aws-p2

## Etapa 1 — Preparação do repositório [CONCLUÍDA]

- [x] 1.1 Corrigir .gitignore (remove .kiro/, adiciona padrões Terraform)
- [x] 1.2 Criar .gitattributes (normaliza EOL para LF)
- [x] 1.3 Criar docker/.dockerignore (exclui .env do contexto de build)
- [x] 1.4 Corrigir docker/Dockerfile (extensão pgsql, hadolint ignores)

---

## Etapa 2 — Infraestrutura Terraform [CONCLUÍDA]

- [x] 2.1 Criar `terraform/versions.tf`
- [x] 2.2 Criar `terraform/modules/networking/variables.tf`
- [x] 2.3 Criar `terraform/modules/networking/main.tf`
- [x] 2.4 Criar `terraform/modules/networking/outputs.tf`
- [x] 2.5 Criar `terraform/modules/database/variables.tf`
- [x] 2.6 Criar `terraform/modules/database/main.tf`
- [x] 2.7 Criar `terraform/modules/database/outputs.tf`
- [x] 2.8 Criar `terraform/modules/compute/variables.tf`
- [x] 2.9 Criar `terraform/modules/compute/main.tf`
- [x] 2.10 Criar `terraform/modules/compute/outputs.tf`
- [x] 2.11 Criar `terraform/modules/compute/user_data.sh`
- [x] 2.12 Criar `terraform/variables.tf`
- [x] 2.13 Criar `terraform/main.tf`
- [x] 2.14 Criar `terraform/outputs.tf`
- [x] 2.15 Criar `terraform/terraform.tfvars.example`
- [x] 2.16 Ajustar `docker/docker-compose.yml` (porta configurável, env_file simples)
- [x] 2.17 Verificar: `terraform fmt -recursive` sem erros
- [x] 2.18 Verificar: todos os arquivos .tf e .sh (exceto versions.tf) têm # TODO:
- [x] 2.19 Rodar pytest — 64 passed, 0 skipped

---

## Etapa 4 — Documento de arquitetura

- [x] 4.1 Revisar `docs/architecture-design.md`
       Remover todos os `<!-- TODO -->` restantes (diagrama, link custo)

- [x] 4.2 Substituir diagrama placeholder por diagrama Mermaid (Internet → IGW → EC2 → RDS, VPC, subnets e SGs)
       Cobrir: VPC, subnets, EC2, RDS, SGs, IGW, fluxo de acesso

- [x] 4.3 Preencher Custo Estimado com valores reais e link do AWS Pricing Calculator

- [x] 4.4 Verificar: `grep -c "TODO" docs/architecture-design.md` retorna 0

---

## Etapa 5 — Workflows CI/CD [CONCLUÍDA]

- [x] 5.1 Reescrever `.github/workflows/terraform-plan.yml`
- [x] 5.2 Corrigir `.github/workflows/terraform-validate.yml` (remove guard hashFiles)
- [x] 5.3 Corrigir `.github/workflows/docker-lint.yml` (copia .env.example antes do config)
- [x] 5.4 Verificar: pytest passa (test_workflow_step_comments.py)

---

## Etapa 7 — Commit e push final

- [x] 7.1 Commit: docker-compose.yml — "fix(docker): porta configuravel e env_file simples"
- [x] 7.2 Commit: workflows (docker-lint, terraform-validate, terraform-plan) — "ci: corrige validate e implementa terraform-plan"
- [x] 7.4 Commit: terraform/ — "feat(terraform): implementa modulos networking, database e compute"
- [ ] 7.5 Commit: docs/architecture-design.md
       "docs(arch): preenche design de arquitetura da solucao AWS"
- [ ] 7.6 Atualizar spec (.kiro/) com tarefas concluídas
- [ ] 7.7 Push fork feat/aula-11-docker-local (nunca no origin, que é o repositório do professor)
- [ ] 7.8 Verificar pytest final: 64 passed, 0 skipped

---

## Etapa 3 — Deploy real na AWS [OPCIONAL]

- [ ] 3.1 Configurar credenciais do Learner Lab em ~/.aws/credentials
- [ ] 3.2 Criar terraform/terraform.tfvars com valores reais
- [ ] 3.3 terraform init && terraform plan — revisar saída
- [ ] 3.4 terraform apply — anotar ec2_public_dns e rds_endpoint
- [ ] 3.5 Aguardar boot da EC2 (~3-5 min) e verificar /var/log/user-data.log
- [ ] 3.6 scripts/health-check.sh <ec2_public_dns> — deve retornar exit 0
- [ ] 3.7 terraform destroy ao encerrar a sessão do Lab
