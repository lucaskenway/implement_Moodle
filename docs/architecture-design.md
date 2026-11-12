# Design de Arquitetura — Moodle Docker AWS Challenge

> **Status:** rascunho v0 (aula 11). As seções descrevem a arquitetura **planejada**.
> Valores e diagrama serão atualizados conforme os módulos Terraform forem implementados e aplicados.

---

## Visão Geral

A solução coloca o Moodle 4.1 em produção na AWS usando o mesmo contêiner validado localmente com `docker compose`. Uma instância EC2 `t3.medium` (Amazon Linux 2023) em subnet pública executa o Moodle em Docker; o banco de dados é um RDS PostgreSQL 15 (`db.t3.micro`) em subnet privada, sem IP público.

Toda a infraestrutura será provisionada com Terraform na região `us-east-1` do AWS Learn Lab, dividida em três módulos: `networking` (VPC, subnets, IGW, route table, security groups), `compute` (EC2 + `user_data.sh`) e `database` (RDS + subnet group). No boot, o `user_data.sh` instala Docker 24+ e Docker Compose v2 e sobe o Moodle apontando para o endpoint do RDS.

As decisões de alto nível foram guiadas pelas restrições do Learn Lab: nenhum recurso IAM é criado (a EC2 usa o `LabRole` via data source), não há Route 53, ACM nem CloudFront (acesso por HTTP na porta 80 pelo DNS público da EC2) e as credenciais são temporárias (~4 h), o que exige estado e segredos fora do repositório.

## Diagrama de Arquitetura

<!-- TODO: Substituir pelo diagrama real (ícones AWS) após implementar os módulos Terraform. -->

Rascunho do fluxo (será substituído por diagrama com ícones de serviço):

```text
Internet ──HTTP :80──▶ IGW ──▶ Route Table pública (0.0.0.0/0 → IGW)
                                   │
        ┌──────────── VPC 10.0.0.0/16 (us-east-1) ─────────────────────┐
        │  Subnet pública 10.0.1.0/24 (us-east-1a)                      │
        │    EC2 t3.medium · AL2023 · Docker + Moodle · SG-EC2 (80, 22) │
        │                    │ PostgreSQL :5432                         │
        │  Subnet privada 10.0.2.0/24 (us-east-1a)                      │
        │    RDS PostgreSQL 15 db.t3.micro · SG-RDS (5432 ← SG-EC2)     │
        │  Subnet privada 10.0.3.0/24 (us-east-1b) — subnet group RDS   │
        └───────────────────────────────────────────────────────────────┘
        EC2 usa o instance profile LabRole (data source, sem criar IAM)
```

![Diagrama Exemplo](img/diagrama.png)

## Decisões de Design

| Componente | Escolha | Justificativa |
|---|---|---|
| Tipo de instância EC2 | `t3.medium` | 2 vCPU e 4 GB de RAM comportam Apache + PHP + Moodle com OPcache (256 MB) e o build da imagem; `t3.micro`/`small` ficam sem memória no build. Tipo disponível no Learn Lab. |
| Engine do banco de dados | RDS PostgreSQL 15 | Mesma versão do ambiente local (`postgres:15`), o que evita diferenças de comportamento entre local e nuvem; serviço gerenciado tira backup e patch do escopo da EC2. |
| Classe da instância RDS | `db.t3.micro` | Menor classe suportada; suficiente para carga de estudo e economiza o crédito do Lab. |
| AMI da EC2 | Amazon Linux 2023 | AMI mantida pela AWS, com Docker disponível via `dnf`; buscada por data source para sempre pegar a versão mais recente. |
| Topologia de rede | 1 subnet pública + 2 privadas | EC2 pública para HTTP/SSH; RDS isolado em subnet privada; o `aws_db_subnet_group` exige subnets em pelo menos 2 AZs. |
| Acesso IAM na EC2 | LabRole via data source | O Learn Lab bloqueia criação de roles/instance profiles; `data "aws_iam_instance_profile"` referencia o perfil existente. |
| Segredos | Variáveis `sensitive = true` + `terraform.tfvars` fora do Git | Nenhuma senha no código; mesmo padrão já aplicado no `docker/.env` local. |

## Componentes

### VPC

`10.0.0.0/16` em `us-east-1`, com `enable_dns_hostnames = true` e `enable_dns_support = true` (necessário para o DNS público da EC2 e para resolver o endpoint do RDS).

### Subnets

| Nome | Tipo | CIDR | AZ | Hospeda |
|---|---|---|---|---|
| public-a | Pública (`map_public_ip_on_launch = true`) | `10.0.1.0/24` | us-east-1a | EC2 Moodle |
| private-a | Privada | `10.0.2.0/24` | us-east-1a | RDS PostgreSQL |
| private-b | Privada | `10.0.3.0/24` | us-east-1b | Apenas subnet group do RDS |

### Internet Gateway e Route Table

Um Internet Gateway associado à VPC e uma route table pública com a rota `0.0.0.0/0 → IGW`, associada somente à subnet pública. As subnets privadas usam a route table principal (sem saída para a internet).

### Security Group — EC2

- Ingresso TCP 80 de `0.0.0.0/0` (acesso ao Moodle).
- Ingresso TCP 22 apenas de `var.ssh_allowed_cidr` (IP do aluno, `/32`).
- Egresso liberado (download de pacotes, imagens Docker e Moodle).

### Security Group — RDS

- Ingresso TCP 5432 **somente** com origem no SG da EC2 (`source_security_group_id`), nunca `0.0.0.0/0`.
- Sem regras adicionais de ingresso.

### Instância EC2

`t3.medium`, AMI Amazon Linux 2023 (data source), na subnet pública, key pair `vockey` do Lab, instance profile `LabRole`. O `user_data.sh` instala Docker 24+ e o plugin Compose v2, gera o `.env` a partir das variáveis do Terraform (endpoint e senha do RDS) e executa `docker compose up -d`.

### RDS PostgreSQL

Engine `postgres` 15, classe `db.t3.micro`, 20 GB `gp2`, `multi_az = false`, `publicly_accessible = false`, `skip_final_snapshot = true` (ambiente de estudo), subnet group com `private-a` e `private-b`. Senha via variável sensível.

## Segurança

- **Isolamento de rede:** RDS em subnet privada, sem IP público e sem rota para a internet.
- **Menor privilégio:** SG do RDS aceita 5432 apenas do SG da EC2; SSH restrito a um `/32`.
- **Credenciais:** senhas em variáveis `sensitive = true`, valores em `terraform.tfvars` (ignorado pelo `.gitignore`); no ambiente local, o `docker-compose.yml` lê `docker/.env` (fora do Git) em vez do `.env.example`.
- **Credenciais AWS:** temporárias do Learn Lab, apenas em `~/.aws/credentials` local e nos secrets do GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`), nunca no repositório.
- **IAM:** uso exclusivo do `LabRole` via data source; nenhum `aws_iam_*` declarado como recurso.
- **Estado:** `terraform.tfstate` fora do Git (backend S3 avaliado para as próximas aulas).

## Escalabilidade

**Limitações atuais (Learn Lab):** uma única EC2 em uma AZ (ponto único de falha), RDS `db.t3.micro` single-AZ, sem HTTPS e sem Auto Scaling.

**Em produção real:**
- Application Load Balancer + Auto Scaling Group com Launch Template em 2+ AZs (as estratégias Blue/Green e Canary da aula 11 passam a ser possíveis sobre o ALB).
- `moodledata` compartilhado em EFS, já que várias instâncias precisam do mesmo diretório.
- RDS Multi-AZ e réplicas de leitura; cache de sessão em ElastiCache (Redis).
- HTTPS com ACM no ALB e CloudFront para estáticos.

**Mudanças no Terraform:** trocar `aws_instance` por `aws_launch_template` + `aws_autoscaling_group`, adicionar módulo `loadbalancer` (`aws_lb`, `aws_lb_target_group`, `aws_lb_listener`), subnets públicas em uma segunda AZ, `multi_az = true` no RDS e um módulo `storage` com `aws_efs_file_system`.

## Custo Estimado

Valores de referência On-Demand em `us-east-1`, 730 h/mês. <!-- TODO: confirmar no AWS Pricing Calculator e anexar o link. -->

| Serviço | Tipo/Configuração | Custo estimado (USD/mês) |
|---|---|---|
| EC2 | `t3.medium`, On-Demand, 730h (US$ 0,0416/h) | 30,37 |
| RDS PostgreSQL | `db.t3.micro`, 20 GB SSD, 730h (US$ 0,018/h + 20 × US$ 0,115) | 15,44 |
| Armazenamento EBS (EC2) | 20 GB gp3 (US$ 0,08/GB) | 1,60 |
| Transferência de dados | 10 GB saída (dentro dos 100 GB/mês gratuitos) | 0,00 |
| IPv4 público | 1 IP, 730h (US$ 0,005/h) | 3,65 |
| **Total estimado** | | **≈ 51,06** |

> Referência: [AWS Pricing Calculator](https://calculator.aws/) — use o link para obter valores atualizados e gerar um link compartilhável da sua estimativa.

<!-- TODO: Adicione o link gerado pelo AWS Pricing Calculator para a sua estimativa específica. -->
