# Progresso da Prova P2 — Moodle Docker AWS Challenge

Atualizado em 13/11/2026. Branch: `feat/aula-11-docker-local` (push feito no remoto `fork`).
Spec: `.kiro/specs/moodle-aws-p2/` (requirements, design, tasks).

## Regras do projeto
- Push sempre no remoto `fork` (lucaskenway). Nunca no `origin` (repositório do professor).
- Shell é PowerShell: separar comandos com `;`, nunca `&&`.
- Terraform não está instalado: rodar pelo Docker, a partir da raiz do projeto:
  `docker run --rm -v "${PWD}/terraform:/tf" -w /tf hashicorp/terraform:1.9 <fmt -check -recursive | init -backend=false | validate>`
- Senhas: só letras e números, mínimo 12 (validation no variables.tf). Sem SSM por enquanto.
- No `user_data.sh` (templatefile), qualquer `${` que não seja variável do Terraform precisa virar `$${`, inclusive em comentários.
- Todo `.tf` (exceto versions.tf), `.yml` e `.sh` em docker/ e terraform/ precisa de um `# TODO:` (exigido pelo pytest).
- No `docs/architecture-design.md` é o contrário: nenhum `<!-- TODO -->` pode sobrar (zera a categoria 4).
- Não fazer commit nem push sem aprovação. `git add` com nome de arquivo, nunca `git add .`.

## Já feito (commitado e enviado)
- `.gitignore` (libera `.kiro/`, ignora state/plan/crash.log), `.gitattributes` (LF), `docker/.dockerignore`
- Dockerfile com extensão `pgsql`; compose com porta `${MOODLE_HTTP_PORT:-8080}:80` e `env_file: - .env`
- Spec do Kiro commitada antes do código
- Terraform completo: raiz + módulos networking, database e compute + `user_data.sh` + `.terraform.lock.hcl`
  (`fmt -check` e `validate` passando)
- Workflows: docker-lint (copia `.env.example`), terraform-validate (sem `if: hashFiles`),
  terraform-plan (workflow_dispatch, session token, `TF_VAR_*` por secrets, `plan -input=false`)
- pytest: 64 passed

## Falta
1. `docs/architecture-design.md`: diagrama em Mermaid (Internet → IGW → EC2 → RDS:5432, VPC, subnets, SGs)
   no lugar do rascunho ASCII e do `img/diagrama.png`; link do AWS Pricing Calculator; tirar o
   "rascunho v0"; zero `<!-- TODO -->`. Commit: `docs(arch): finaliza design de arquitetura`.
2. Atualizar os secrets AWS no GitHub (expiram em ~4h) e rodar o `terraform-plan` pelo Actions.
3. PR da branch para o `main` do fork (dispara o terraform-validate).
4. `entrega.md` com a declaração de uso de IA e um único PR na pasta de entregas.
5. Opcional: instalação automática do Moodle (Etapa 3) e `terraform apply` + health-check + `destroy`.
