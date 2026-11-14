# Sessão Kiro — Prova P2 (14/11/2026)

Registro da conversa com o Kiro para finalizar a P2: ajustes de `.gitignore`, `docker-compose.yml`,
workflows de CI/CD, evidências e push final para o fork.

Branch: `feat/aula-11-docker-local`
Commits gerados nesta sessão: `6705f19` a `25846dc`
Repositório: `fork` = `lucaskenway/implement_Moodle` · `origin` = `AleTavares/implement_Moodle` (nunca tocado)

Senhas, tokens e chaves AWS foram substituídos por `***`.

---

## Parte 1 — Revisão do estado do projeto

**Lucas:** Antes de começar, quero conferir algumas coisas porque encontrei diferenças entre sua análise e a análise anterior do Claude. Confere no projeto atual se o architecture-design.md realmente existe e se está no Git. Verifica também se os 4 workflows estão funcionando de verdade, principalmente o terraform-plan.yml e o terraform-validate.yml.

**Kiro:** Verificou com `git ls-files` e `git show HEAD:docs/architecture-design.md`. Confirmou:
- `docs/architecture-design.md` existe no worktree E está rastreado no HEAD atual
- Tinha 3 `<!-- TODO -->` pendentes (diagrama, link custo)
- `terraform-plan.yml` era stub com `on: {}` e `if: false` — não disparava nada
- `terraform-validate.yml` tinha guard `if: hashFiles('terraform/versions.tf') != ''` — nunca rodava sem o Terraform criado
- `docker-lint.yml` e `health-check.yml` funcionais

Pontuação estimada na rubrica: ~36–53 pts de 100. Terraform faltando = 0 pts na Cat.2 + trava Cat.3 e Cat.5.

---

## Parte 2 — Revisão da rubrica oficial

**Lucas:** Abre o arquivo docs/evaluation-rubric.md e confere a pontuação oficial de cada categoria.

**Kiro:** Rubrica confirmada:
- Cat.1 Docker: 20 pts
- Cat.2 Terraform: 35 pts
- Cat.3 CI/CD: 15 pts (terraform-validate 5 + docker-lint 4 + terraform-plan 4 + health-check 2)
- Cat.4 Arquitetura: 20 pts (eliminatório se ausente)
- Cat.5 Segurança: 10 pts

**Descoberta importante:** criar o Terraform destrava 46 pts simultaneamente (35 Cat.2 + 5 Cat.3 + 6 Cat.5).

---

## Parte 3 — Planejamento do Terraform

**Lucas:** Vamos começar pelo Terraform. Antes de sair criando os arquivos, dá uma olhada no terraform-guide.md, no aws-learn-lab-setup.md e também nos requisitos da prova.

Leitura dos guias. Planejamento definido:

**Estrutura:**
```
terraform/
├── versions.tf, main.tf, variables.tf, outputs.tf, terraform.tfvars.example
└── modules/
    ├── networking/  (VPC, subnets, IGW, route table, SG-EC2, SG-RDS)
    ├── database/    (aws_db_subnet_group, aws_db_instance postgres 15)
    └── compute/     (data aws_ami AL2023, data LabRole, aws_instance, user_data.sh)
```

**Decisões chave:**
- Chave SSH: `vockey` pré-existente no Learner Lab (sem criar `aws_key_pair`)
- IAM: `data "aws_iam_instance_profile" "lab_role"` — restrição do Learn Lab
- RDS outputs: `.address` e `.port` separados (evita split de string no shell)
- `--no-deps` no `docker compose up` para não tentar subir o serviço `db`
- Senhas: somente letras e números, sem SSM (simplificação para o Lab)
- `user_data.sh`: variáveis Terraform `${var}`, variáveis shell `$${VAR}`, heredoc `<< EOF`

**Variáveis raiz:** aws_region, project_name, vpc_cidr, ec2_instance_type, ssh_allowed_cidr, db_name, db_username (sensitive), db_password (sensitive), moodle_admin_password (sensitive), repo_url, repo_branch, compose_version

---

## Parte 4 — Ajustes no docker-compose.yml e .gitignore

**Lucas:** Diversas rodadas de ajuste no `.gitignore` (remove `.kiro/`, adiciona padrões Terraform), `.gitattributes` (normaliza EOL para LF), `docker/.dockerignore` (`.env`, `.env.*`, `!.env.example`).

**Commits desta parte:**
```
4ec6b3f  chore(git): versiona .kiro e ignora plan/state do terraform
b9b9c2f  chore(git): padroniza finais de linha com .gitattributes
a50073c  chore(docker): ignora .env no contexto de build
7ef0233  fix(docker): adiciona extensao pgsql e ajusta hadolint
a60e459  fix(git): libera .kiro e completa padroes do terraform
```

**Nota:** Houve uma reversão de arquivo pelo usuário durante o processo. O `.gitignore` foi corrigido em dois commits por causa disso.

---

## Parte 5 — Spec do Kiro

**Lucas:** Cria uma spec chamada moodle-aws-p2 com base no plano. Requirements, design e tasks.

Arquivos criados em `.kiro/specs/moodle-aws-p2/`:
- `requirements.md` — R2 (Terraform), R4 (arquitetura), R5 (workflows), R7 (commits/push)
- `design.md` — diagrama ASCII, módulos, user_data.sh fluxo, variáveis, CI/CD
- `tasks.md` — tarefas numeradas por etapa

Ajustes pedidos pelo Lucas antes de finalizar:
- Porta `${MOODLE_HTTP_PORT:-8080}:80` (EC2 usa porta 80, local usa 8080 por default)
- `env_file: - .env` simples; `docker-lint.yml` copia `.env.example → .env`
- `terraform-plan.yml`: secrets `TF_VAR_*` para evitar prompt interativo
- `terraform-validate.yml`: remover guard `hashFiles`
- `user_data.sh`: `git` instalado junto com Docker; Compose v2 via binário oficial versão fixa
- Remoção do commit de "fallback do .env.example"

**Commit:**
```
f1a24fa  docs(kiro): adiciona spec moodle-aws-p2
```

---

## Parte 6 — Implementação do Terraform

**Lucas:** Pode seguir sem me perguntar a cada task: faz as variables, o main, os outputs e o módulo networking inteiro.

Arquivos criados em sequência:
- `terraform/versions.tf`
- `modules/networking/variables.tf`, `main.tf`, `outputs.tf`
- `modules/database/variables.tf`, `main.tf`, `outputs.tf`
- `modules/compute/variables.tf`, `main.tf`, `outputs.tf`, `user_data.sh`
- `terraform/variables.tf` (com validações em db_password, moodle_admin_password, repo_url)
- `terraform/main.tf`, `outputs.tf`, `terraform.tfvars.example`

**Validações adicionadas:**
```hcl
validation {
  condition     = length(var.db_password) >= 12 && can(regex("^[A-Za-z0-9]+$", var.db_password))
  error_message = "db_password deve ter no mínimo 12 caracteres e conter somente letras e números."
}
```

**Problemas encontrados e resolvidos no `user_data.sh`:**
1. `templatefile()` processa comentários também — `${...}` em comentários causava erro de validação
2. `'EOF'` no heredoc não é reconhecido pelo `templatefile()` — trocado para `<< EOF` sem aspas
3. `COMPOSE_VERSION="v2.29.1"` com aspas duplas causava erro — movido para variável Terraform `compose_version`
4. Comentários com `${...}` ou `$${...}` continuavam causando erros — todos removidos

**Resultado do `terraform validate` via Docker:**
```
Success! The configuration is valid.
```

**Resultado do pytest:** 64 passed, 0 skipped, 0 failed

**Commits:**
```
b8b134c  feat(terraform): implementa modulos networking, database e compute
436c5bc  fix(docker): porta configuravel e env_file simples
2904e5b  ci: corrige validate e implementa terraform-plan
```

---

## Parte 7 — Sessão do dia 14 (continuação)

### Estado inicial

Commits já existentes ao iniciar a sessão do dia 14:
```
7c953e2  fix(terraform): corrige instance profile e descricoes de SG
e489445  docs(evidencias): registra sessao do kiro
6705f19  docs(arch): finaliza design de arquitetura
```

O `terraform plan` já havia rodado com sucesso no GitHub Actions (run 43642163011) com todos os 12 recursos planejados corretamente.

### Evidências

**Lucas:** Confira a pasta `evidencias/2026-11-14_prints/`. Ela tem cinco arquivos com os prints do Moodle e do Terraform Plan. Antes de fazer o commit, confira todos os arquivos, inclusive as imagens, para garantir que não aparece nenhuma credencial AWS, token ou senha.

**Kiro:** Verificou `004_actions-terraform-plan-saida.txt` — todas as credenciais mascaradas com `***`:
```
TF_VAR_db_username: ***
TF_VAR_db_password: ***
TF_VAR_moodle_admin_password: ***
TF_VAR_repo_url: ***
AWS_ACCESS_KEY_ID: ***
AWS_SECRET_ACCESS_KEY: ***
AWS_SESSION_TOKEN: ***
```
Nenhum valor sensível exposto. Os PNGs são binários. Commit realizado.

**Commit:**
```
7ec3d82  docs(evidencias): adiciona prints do moodle e do terraform plan
```

### Ajustes nos workflows

**Lucas:** Quero que você confira e ajuste: docker-lint.yml, terraform-validate.yml, terraform-plan.yml. O terraform-validate precisa rodar em PR para main quando houver alteração em terraform/**. O docker-lint precisa rodar em push e PR quando houver alteração em docker/**. Como não temos mudanças em docker/ nesta branch, adiciona workflow_dispatch nos dois.

**Kiro:** Ajustes aplicados:
- `terraform-validate.yml`: adicionado `workflow_dispatch:`, branches filter já existia
- `docker-lint.yml`: adicionado `workflow_dispatch:` + `branches: [main]` nos triggers push/PR

**Commit:**
```
25846dc  ci: adiciona workflow_dispatch ao docker-lint e terraform-validate
```

### Push para o fork

```
git push fork feat/aula-11-docker-local
7c953e2..25846dc  feat/aula-11-docker-local -> feat/aula-11-docker-local
```

Push enviado para `lucaskenway/implement_Moodle` (fork). `origin` (AleTavares) não foi tocado.

**Nota:** `gh` não estava autenticado no ambiente do Kiro, então o acompanhamento dos runs foi feito pelo Lucas diretamente em https://github.com/lucaskenway/implement_Moodle/actions.

---

## Estado final da branch

```
git log --oneline -8:
25846dc  ci: adiciona workflow_dispatch ao docker-lint e terraform-validate
7ec3d82  docs(evidencias): adiciona prints do moodle e do terraform plan
7c953e2  fix(terraform): corrige instance profile e descricoes de SG
e489445  docs(evidencias): registra sessao do kiro
6705f19  docs(arch): finaliza design de arquitetura
2904e5b  ci: corrige validate e implementa terraform-plan
436c5bc  fix(docker): porta configuravel e env_file simples
b8b134c  feat(terraform): implementa modulos networking, database e compute
```

**pytest:** 64 passed, 0 skipped, 0 failed
**terraform validate:** Success (via Docker hashicorp/terraform:1.9)
**terraform plan (CI):** 12 to add, 0 to change, 0 to destroy ✅

---

## Arquivos criados/modificados nesta sessão

| Arquivo | Ação |
|---|---|
| `.gitignore` | corrigido (remove `.kiro/`, adiciona padrões Terraform) |
| `.gitattributes` | criado |
| `docker/.dockerignore` | criado |
| `docker/Dockerfile` | corrigido (pgsql, hadolint) |
| `docker/docker-compose.yml` | porta configurável, env_file simples |
| `terraform/` (16 arquivos) | criado do zero |
| `.github/workflows/terraform-plan.yml` | reescrito (era stub) |
| `.github/workflows/terraform-validate.yml` | remove guard hashFiles, adiciona workflow_dispatch |
| `.github/workflows/docker-lint.yml` | adiciona step .env, workflow_dispatch, branches filter |
| `.kiro/specs/moodle-aws-p2/` | spec completa criada |
| `evidencias/2026-11-14_prints/` | 5 arquivos de evidência commitados |
