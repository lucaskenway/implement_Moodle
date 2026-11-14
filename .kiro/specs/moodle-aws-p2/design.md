# Design — moodle-aws-p2

## Visão geral

```
GitHub repo (fork)
      │
      │ git clone --depth 1
      ▼
┌─────────────────────────────────────────────────────────┐
│  VPC 10.0.0.0/16  (us-east-1)                          │
│                                                         │
│  ┌─────────────────────────────┐                        │
│  │ Subnet pública 10.0.1.0/24 │◄── IGW ◄── Internet    │
│  │  EC2 t3.medium (AL2023)    │    :80                  │
│  │  Docker + Moodle 4.1       │                         │
│  │  SG-EC2: 80+22 in          │                         │
│  └────────────┬────────────────┘                        │
│               │ :5432 (SG-RDS permite só SG-EC2)        │
│  ┌────────────▼────────────────┐                        │
│  │ Subnet privada-a 10.0.2.0  │                        │
│  │ Subnet privada-b 10.0.3.0  │                        │
│  │  RDS PostgreSQL 15          │                        │
│  │  db.t3.micro, 20GB gp2      │                        │
│  │  publicly_accessible=false  │                        │
│  └─────────────────────────────┘                        │
└─────────────────────────────────────────────────────────┘
```

---

## Módulos Terraform

### networking
Entradas: project_name, vpc_cidr, ssh_allowed_cidr
Saídas: vpc_id, public_subnet_id, private_subnet_ids, ec2_security_group_id, rds_security_group_id

Decisões:
- `enable_dns_hostnames = true` — necessário para o DNS público da EC2 funcionar
- Route table separada para a subnet pública; subnets privadas ficam na route table main (sem rota IGW)
- SG RDS usa `security_groups = [ec2_sg_id]` como origem — nunca cidr_blocks

### database
Entradas: project_name, private_subnet_ids, rds_security_group_id, db_name, db_username, db_password
Saídas: rds_address (via .address), rds_port (via .port)

Decisões:
- `.address` e `.port` separados para evitar split de string no user_data.sh
- `skip_final_snapshot = true` — ambiente educacional, sem necessidade de snapshot
- `storage_type = "gp2"` — suficiente para carga de estudo

### compute
Entradas: project_name, public_subnet_id, ec2_security_group_id, ec2_instance_type,
          rds_address, rds_port, db_name, db_username, db_password,
          moodle_admin_password, repo_url, repo_branch
Saídas: ec2_public_dns, ec2_instance_id

Decisões:
- AMI via data source (most_recent = true) — sem fixar ID que muda por região
- key_name = "vockey" — key pair pré-existente no Learner Lab
- LabRole via data source — restrição do Learner Lab
- user_data via templatefile() — injeta variáveis Terraform antes do envio

---

## user_data.sh — fluxo detalhado

```
1. set -euo pipefail + exec > /var/log/user-data.log 2>&1
2. dnf install -y docker git
3. mkdir -p /usr/local/lib/docker/cli-plugins
   curl -fsSL https://github.com/docker/compose/releases/download/v2.29.1/
        docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
   chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
4. systemctl enable --now docker
5. git clone --branch <repo_branch> --depth 1 <repo_url> /opt/moodle
6. cat > /opt/moodle/docker/.env << 'EOF'
   MOODLE_DATABASE_TYPE=pgsql
   MOODLE_DATABASE_HOST=<rds_address>       ← injetado pelo templatefile()
   MOODLE_DATABASE_PORT_NUMBER=<rds_port>   ← injetado pelo templatefile()
   MOODLE_DATABASE_NAME=<db_name>           ← injetado pelo templatefile()
   MOODLE_DATABASE_USER=<db_username>       ← injetado pelo templatefile()
   MOODLE_DATABASE_PASSWORD=<db_password>   ← injetado pelo templatefile()
   MOODLE_USERNAME=admin
   MOODLE_PASSWORD=<moodle_admin_password>  ← injetado pelo templatefile()
   MOODLE_SITE_NAME=Moodle Challenge
   MOODLE_HTTP_PORT=80
   EOF
7. chmod 600 /opt/moodle/docker/.env
8. docker compose -f /opt/moodle/docker/docker-compose.yml up -d --no-deps moodle
```

Regras de escape no templatefile():
- Variáveis Terraform: `${nome}` — substituídas na fase 1 (Terraform)
- Variáveis shell fora do heredoc: `$${VAR}` — viram `$VAR` após o templatefile()
- Dentro do heredoc `<< 'EOF'`: Terraform substitui, shell não interpola — sem escape

---

## docker-compose.yml — ajuste de porta

```yaml
ports:
  - "${MOODLE_HTTP_PORT:-8080}:80"
```

- Localmente: sem `.env` definindo `MOODLE_HTTP_PORT`, usa default 8080
- Na EC2: `.env` tem `MOODLE_HTTP_PORT=80`, expõe na porta 80 do host

`env_file` volta para formato simples `- .env` (sem path/required).
O `docker-lint.yml` copia `.env.example` → `.env` antes de validar.

---

## Variáveis raiz

| Variável | Tipo | Sensitive | Default |
|---|---|---|---|
| aws_region | string | não | "us-east-1" |
| project_name | string | não | "moodle-challenge" |
| vpc_cidr | string | não | "10.0.0.0/16" |
| ec2_instance_type | string | não | "t3.medium" |
| ssh_allowed_cidr | string | não | "0.0.0.0/0" + aviso |
| db_name | string | não | "moodle" |
| db_username | string | sim | — |
| db_password | string | sim | — |
| moodle_admin_password | string | sim | — |
| repo_url | string | não | — |
| repo_branch | string | não | "feat/aula-11-docker-local" |

---

## CI/CD

### terraform-plan.yml
- Trigger: workflow_dispatch
- Secrets AWS: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
- Secrets TF: TF_VAR_db_username, TF_VAR_db_password, TF_VAR_moodle_admin_password, TF_VAR_repo_url
  (o Terraform lê variáveis com prefixo TF_VAR_ automaticamente — evita prompt interativo)
- Steps: checkout → configure-aws-credentials@v4 → setup-terraform@v3 →
  terraform init -backend=false → terraform plan

### terraform-validate.yml
- Remover `if: ${{ hashFiles('terraform/versions.tf') != '' }}` do job
- Sem essa condição o workflow roda sempre que terraform/** for alterado

### docker-lint.yml
- Adicionar step `cp docker/.env.example docker/.env` antes do `docker compose config`

---

## Segurança — resumo

| Risco | Mitigação |
|---|---|
| Senhas no tfstate | tfstate no .gitignore; nunca commitado |
| Senhas no user_data | Senhas só com letras+números; user_data visível no console AWS (limitação aceita) |
| RDS exposto | publicly_accessible=false + subnet privada + SG restrito |
| SSH aberto | ssh_allowed_cidr com aviso; restringir ao IP do aluno em produção |
| Credenciais AWS | Nunca commitadas; rotacionar antes de 3h de sessão |
