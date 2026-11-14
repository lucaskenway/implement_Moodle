# Requirements — moodle-aws-p2

## Contexto

Prova P2 da disciplina de DevOps (ADS/UniFAAT). O template já entrega o ambiente
Docker local funcional. Esta spec cobre apenas o que ainda falta entregar.

Restrições fixas do AWS Learner Lab:
- Região: us-east-1
- IAM bloqueado (sem criar roles/users) — usar LabRole via data source
- Route 53, ACM e CloudFront indisponíveis
- Credenciais temporárias (~4h), nunca commitadas

---

## Etapa 1 — Preparação do repositório [CONCLUÍDA]

- [x] .gitignore: remove .kiro/, adiciona padrões Terraform (crash.log, tfplan, etc.)
- [x] .gitattributes: normaliza EOL para LF
- [x] docker/.dockerignore: exclui .env do contexto de build
- [x] docker/Dockerfile: adiciona extensão pgsql, ajusta hadolint ignores

---

## Etapa 2 — Infraestrutura Terraform (35 pts)

### R2.1 Estrutura de arquivos
O diretório `terraform/` deve conter:
- `versions.tf` — provider AWS ~> 5.0, required_version >= 1.5
- `main.tf` — instancia os três módulos
- `variables.tf` — variáveis raiz
- `outputs.tf` — ec2_public_dns, rds_endpoint, vpc_id
- `terraform.tfvars.example` — template sem valores reais

### R2.2 Módulo networking
Recursos obrigatórios:
- `aws_vpc`: CIDR 10.0.0.0/16, enable_dns_hostnames = true
- `aws_subnet` pública: 10.0.1.0/24, us-east-1a, map_public_ip_on_launch = true
- `aws_subnet` privada-a: 10.0.2.0/24, us-east-1a
- `aws_subnet` privada-b: 10.0.3.0/24, us-east-1b
- `aws_internet_gateway`
- `aws_route_table` com rota 0.0.0.0/0 → IGW
- `aws_route_table_association` na subnet pública
- `aws_security_group` ec2: ingress 80 de 0.0.0.0/0, ingress 22 de var.ssh_allowed_cidr, egress livre
- `aws_security_group` rds: ingress 5432 somente do SG da EC2 (security_groups, nunca cidr)

Outputs: vpc_id, public_subnet_id, private_subnet_ids (lista), ec2_security_group_id, rds_security_group_id

### R2.3 Módulo database
Recursos obrigatórios:
- `aws_db_subnet_group`: usa private_subnet_ids (mínimo 2 AZs)
- `aws_db_instance`: engine postgres 15, db.t3.micro, 20 GB gp2,
  publicly_accessible = false, skip_final_snapshot = true, multi_az = false

Variáveis recebidas: private_subnet_ids, rds_security_group_id, db_name,
db_username (sensitive), db_password (sensitive)
Outputs: rds_address (somente hostname, via .address), rds_port (via .port)

### R2.4 Módulo compute
Recursos obrigatórios:
- `data "aws_ami"`: filter name = "al2023-ami-*-x86_64", owners = ["amazon"], most_recent = true
- `data "aws_iam_instance_profile"`: name = "LabRole"
- `aws_instance`: t3.medium, subnet pública, SG ec2, key_name = "vockey",
  iam_instance_profile = LabRole, user_data = templatefile(...)

Variáveis recebidas: public_subnet_id, ec2_security_group_id, ec2_instance_type,
rds_address, rds_port, db_name, db_username (sensitive), db_password (sensitive),
moodle_admin_password (sensitive), repo_url, repo_branch
Outputs: ec2_public_dns, ec2_instance_id

### R2.5 user_data.sh
Executado no boot da EC2. Requisitos:
- `set -euo pipefail`
- `exec > /var/log/user-data.log 2>&1`
- Instala Docker e git via dnf: `dnf install -y docker git`
- Instala Docker Compose v2 como plugin via binário oficial com versão fixa:
  baixar https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64
  para /usr/local/lib/docker/cli-plugins/docker-compose e chmod +x
  (não usar dnf install docker-compose-plugin — não disponível no AL2023)
- `systemctl enable --now docker`
- `git clone --branch ${repo_branch} --depth 1 ${repo_url} /opt/moodle`
- Cria /opt/moodle/docker/.env com as variáveis abaixo via heredoc `<< 'EOF'`:
    MOODLE_DATABASE_TYPE=pgsql
    MOODLE_DATABASE_HOST=${rds_address}
    MOODLE_DATABASE_PORT_NUMBER=${rds_port}
    MOODLE_DATABASE_NAME=${db_name}
    MOODLE_DATABASE_USER=${db_username}
    MOODLE_DATABASE_PASSWORD=${db_password}
    MOODLE_USERNAME=admin
    MOODLE_PASSWORD=${moodle_admin_password}
    MOODLE_SITE_NAME=Moodle Challenge
    MOODLE_HTTP_PORT=80
  Senhas injetadas via templatefile() — somente letras e números, sem SSM
- `chmod 600 /opt/moodle/docker/.env`
- `docker compose -f /opt/moodle/docker/docker-compose.yml up -d --no-deps moodle`
- Variáveis shell fora de heredoc escapadas com $$; heredoc com 'EOF' para o .env

### R2.6 docker-compose.yml (ajuste para EC2)
- Porta do host parametrizada: `"${MOODLE_HTTP_PORT:-8080}:80"`
  (local usa 8080 por default; EC2 define MOODLE_HTTP_PORT=80 no .env)
- env_file volta para formato simples `- .env` (sem path/required)
- docker-lint.yml deve copiar .env.example para .env antes de rodar
  `docker compose config`, para que a validação não falhe por .env ausente

### R2.7 Restrições de segurança
- db_password, db_username, moodle_admin_password: sensitive = true, sem default
- ssh_allowed_cidr: default "0.0.0.0/0" com aviso na description
- RDS: publicly_accessible = false
- SG RDS: ingress 5432 via security_groups (não cidr_blocks)
- Nenhum recurso aws_iam_*, aws_route53_*, aws_acm_*, aws_cloudfront_*
- Todo arquivo .tf e .sh em terraform/ deve ter ao menos um # TODO:
  (exigido pelo test_todo_comments.py), exceto versions.tf

---

## Etapa 4 — Documento de arquitetura (20 pts)

### R4.1
O arquivo `docs/architecture-design.md` deve existir e não conter nenhum `<!-- TODO -->`.

### R4.2 Diagrama
Cobrir: VPC, subnets pública e privadas, EC2, RDS, SGs, fluxo Internet→IGW→EC2→RDS.
Pode ser diagrama ASCII detalhado ou imagem. Substituir o placeholder atual.

### R4.3 Seções obrigatórias preenchidas
- Visão Geral
- Decisões de Design (tabela com justificativas reais)
- Componentes (VPC, subnets, IGW, SG-EC2, SG-RDS, EC2, RDS)
- Segurança
- Escalabilidade
- Custo Estimado (tabela com valores On-Demand us-east-1 + link AWS Pricing Calculator)

---

## Etapa 5 — Workflows CI/CD (9 pts)

### R5.1 terraform-plan.yml
Substituir o stub atual por um workflow funcional com:
- trigger: workflow_dispatch
- secrets AWS: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
- secrets Terraform (para evitar prompt interativo de variáveis):
  TF_VAR_db_username, TF_VAR_db_password, TF_VAR_moodle_admin_password, TF_VAR_repo_url
- steps: checkout, configure-aws-credentials@v4, setup-terraform@v3,
  terraform init -backend=false, terraform plan
- working-directory: terraform
- Todo run: step com name: preenchido (exigido pelo test_workflow_step_comments.py)

### R5.2 terraform-validate.yml
Remover a condição `if: ${{ hashFiles('terraform/versions.tf') != '' }}` do job,
para que o workflow execute sempre que arquivos terraform/** forem alterados,
independentemente de o versions.tf já existir no PR.

### R5.3 docker-lint.yml
Adicionar step antes do `docker compose config`:
```
- name: Preparar .env para validação
  run: cp docker/.env.example docker/.env
```

---

## Etapa 7 — Commit e push final

### R7.1 Commits individuais
- docker-compose.yml: "fix(docker): parametriza porta e simplifica env_file"
- docker-lint.yml: "fix(ci): copia env.example para .env antes de validar compose"
- terraform-validate.yml: "fix(ci): remove guard hashFiles do terraform-validate"
- Terraform (todos os arquivos novos): "feat(terraform): implementa modulos networking, compute e database"
- architecture-design.md: "docs(arch): preenche design de arquitetura da solucao AWS"
- terraform-plan.yml: "feat(ci): implementa workflow terraform-plan com workflow_dispatch"

### R7.2 Push e validação
- Push para origin no branch feat/aula-11-docker-local
- Todos os testes passando (41 passed, 10 skipped → 51 passed, 0 skipped)

---

## Etapa 3 — Deploy real na AWS [OPCIONAL]

### R3.1
- terraform apply com credenciais válidas do Learner Lab
- Moodle acessível em http://<ec2_public_dns>
- health-check.sh <ec2_public_dns> retorna exit 0
- terraform destroy ao final da sessão
