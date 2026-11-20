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

## Etapa 6 — Correções e melhorias (prova P2)

- [x] 6.1 **Segunda subnet pública em AZ diferente** (`terraform/modules/networking/`)
       Adicionar `aws_subnet.public_b` (10.0.4.0/24, us-east-1b, map_public_ip_on_launch = true).
       Adicionar `aws_route_table_association.public_b` associando à route table pública.
       Adicionar output `public_subnet_ids` (lista com IDs de public_a e public_b).
       Manter output `public_subnet_id` (aponta para public_a — EC2 continua lá).
       Verificar: `terraform validate` passa; pytest passa.

- [x] 6.2 **Tipo da EC2: t3.medium → t3.micro**
       Alterar default de `ec2_instance_type` para `"t3.micro"` em:
       `terraform/variables.tf` e `terraform/modules/compute/variables.tf`.
       Verificar: `terraform validate` passa; pytest passa.

- [x] 6.3 **SSH porta 22 restrito ao IP do aluno — tornar obrigatório**
       Remover default `"0.0.0.0/0"` de `ssh_allowed_cidr` em `terraform/variables.tf`
       e `terraform/modules/networking/variables.tf`.
       Adicionar bloco `validation` em ambos os arquivos que rejeita qualquer CIDR que
       não termine em `/32` (regex `^\\d+\\.\\d+\\.\\d+\\.\\d+/32$`).
       Atualizar `terraform/terraform.tfvars.example` com placeholder `SEU.IP.PUBLICO.AQUI/32`.
       Verificar: `terraform validate` passa; pytest passa.

- [x] 6.4 **Outputs do módulo compute: renomear para `public_dns` e `public_ip`**
       Em `terraform/modules/compute/outputs.tf`: outputs nomeados `public_dns` e `public_ip`
       (referenciando `aws_instance.moodle.public_dns` e `.public_ip`).
       Em `terraform/outputs.tf`: manter nomes externos `ec2_public_dns` e `ec2_public_ip`
       apontando para `module.compute.public_dns` e `module.compute.public_ip`.
       Adicionar outputs `public_dns`, `public_ip` e `moodle_url` no root `outputs.tf`.
       Verificar: `terraform validate` passa; pytest passa.

- [x] 6.5 **terraform-plan.yml: PR trigger + comentário do plan**
       Adicionar trigger `pull_request` com paths `terraform/**` e `.github/workflows/terraform-plan.yml`.
       Adicionar `permissions: contents: read` e `pull-requests: write`.
       Adicionar secret `TF_VAR_ssh_allowed_cidr` nos env do job.
       Adicionar step `terraform validate -no-color` antes do plan.
       Configurar `terraform plan -no-color` com `continue-on-error: true` e `id: plan`.
       Adicionar step `actions/github-script` que posta o output do plan como comentário
       no PR (condicional: `if: github.event_name == 'pull_request'`), saída cortada em 60000 caracteres.
       Adicionar step final que falha com `exit 1` se `steps.plan.outcome == 'failure'`.
       Verificar: arquivo yaml válido; pytest passa.

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
