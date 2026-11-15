#!/bin/bash
# =============================================================================
# user_data.sh — Script de inicialização da EC2
# Executado como root no primeiro boot da instância Amazon Linux 2023.
# Toda a saída é redirecionada para /var/log/user-data.log para diagnóstico.
#
# REGRAS DE ESCAPE (arquivo processado por templatefile() do Terraform):
#   Variaveis Terraform: escreva VAR entre chaves com cifrao simples (sem espaco)
#   Variaveis shell: use cifrao duplo, ex: COMPOSE_VERSION vira cifrao-VAR no shell
#
# TODO: Após o deploy, verifique o log com:
#   ssh -i labsuser.pem ec2-user@<EC2_DNS> "cat /var/log/user-data.log"
# =============================================================================
set -euo pipefail
exec > /var/log/user-data.log 2>&1

echo "=== [1/6] Instalando Docker e Git ==="
dnf install -y docker git

echo "=== [2/6] Instalando Docker Compose ${compose_version} como plugin ==="
# O docker-compose-plugin nao esta disponivel via dnf no Amazon Linux 2023.
# Instala o binario oficial com versao fixa para garantir reprodutibilidade.
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL \
  "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "=== [3/6] Iniciando e habilitando o Docker ==="
systemctl enable --now docker

echo "=== [4/6] Clonando repositorio ==="
git clone --branch "${repo_branch}" --depth 1 "${repo_url}" /opt/moodle

echo "=== [5/6] Criando .env do Moodle ==="
# Heredoc sem aspas: o Terraform substitui as variaveis antes do envio.
# Nao ha variaveis shell neste heredoc, nenhum escape necessario.
cat > /opt/moodle/docker/.env << EOF
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
EOF

chmod 600 /opt/moodle/docker/.env

echo "=== [6/6] Subindo Moodle com Docker Compose ==="
# --no-deps: impede que o Compose tente subir o servico db (banco e o RDS)
docker compose -f /opt/moodle/docker/docker-compose.yml up -d --no-deps moodle

echo "=== Boot concluido com sucesso ==="
