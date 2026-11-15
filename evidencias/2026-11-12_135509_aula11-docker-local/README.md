# Evidências — aula11-docker-local

- **Projeto:** `implement_Moodle`
- **Início da sessão:** 2026-11-12T13:55:09-03:00
- **Fim da sessão:** 2026-11-12T13:55:19-03:00
- **Ambiente:** WSL (Ubuntu) Ubuntu 26.04 LTS · usuário `lucaskenway` · host `DESKTOP-AMJ5UEC`
- **Comandos registrados:** 3 (3 com retorno 0, 0 com falha) · **capturas de tela:** 0

> Gerado pela ferramenta `evidencia`. Os TXT contêm a saída capturada diretamente dos processos, sem edição; a única alteração possível é a troca de dados sensíveis por `[REDIGIDO:tipo]`, sempre informada abaixo. Imagens **renderizadas** são desenhadas a partir do TXT e **não são capturas de tela**; capturas **autênticas** são cópias dos pixels da tela.

> **Atualização 2026-11-15:** as imagens renderizadas (`*_renderizada.png`) foram removidas. Os TXT acima continuam sendo o registro original desta sessão. Os mesmos comandos foram refeitos em 2026-11-15 e capturados com print real da tela; esses arquivos estão nesta pasta com o nome `*_print-real-2026-11-15_*.png` (o resultado pode diferir do TXT original, por exemplo HTTP 200 em vez de 302, porque o Moodle local já estava instalado).

## Índice

| # | Horário | Descrição | Comando | Retorno | Arquivos |
|---|---------|-----------|---------|---------|----------|
| 001 | 13:55:11 | Moodle respondendo em localhost:8080 | `curl -s -o /dev/null -w 'HTTP %{http_code} -> %{redirect_url}\n' http://localhost:8080/` | ✅ 0 | [001_135511_moodle-respondendo-em-localhost-8080.txt](001_135511_moodle-respondendo-em-localhost-8080.txt) — TXT — saída real do processo |
| 002 | 13:55:14 | health-check do template | `bash scripts/health-check.sh http://localhost:8080` | ✅ 0 | [002_135514_health-check-do-template.txt](002_135514_health-check-do-template.txt) — TXT — saída real do processo |
| 003 | 13:55:18 | commits locais | `git log --oneline -3` | ✅ 0 | [003_135518_commits-locais.txt](003_135518_commits-locais.txt) — TXT — saída real do processo |

## Detalhes

### #001 — Moodle respondendo em localhost:8080

- **Comando:** `curl -s -o /dev/null -w 'HTTP %{http_code} -> %{redirect_url}\n' http://localhost:8080/`
- **Shell:** direto · **diretório:** `/mnt/c/Users/lucas/implement_Moodle`
- **Início:** 2026-11-12T13:55:11-03:00 · **fim:** 2026-11-12T13:55:11-03:00 · **duração:** 0.405 s
- **Código de retorno:** 0
- `001_135511_moodle-respondendo-em-localhost-8080.txt` — TXT — saída real do processo — SHA-256 `22bd19c5b459997bc6fb92b45f1ad725a9c63b0670be55570284a41cffa0b254`

### #002 — health-check do template

- **Comando:** `bash scripts/health-check.sh http://localhost:8080`
- **Shell:** direto · **diretório:** `/mnt/c/Users/lucas/implement_Moodle`
- **Início:** 2026-11-12T13:55:14-03:00 · **fim:** 2026-11-12T13:55:17-03:00 · **duração:** 2.687 s
- **Código de retorno:** 0
- `002_135514_health-check-do-template.txt` — TXT — saída real do processo — SHA-256 `fc0d88a94957bc9331ce0989cd5e19651b755d41dd06ea28d4b3a4594bcbb2d2`

### #003 — commits locais

- **Comando:** `git log --oneline -3`
- **Shell:** direto · **diretório:** `/mnt/c/Users/lucas/implement_Moodle`
- **Início:** 2026-11-12T13:55:18-03:00 · **fim:** 2026-11-12T13:55:18-03:00 · **duração:** 0.150 s
- **Código de retorno:** 0
- `003_135518_commits-locais.txt` — TXT — saída real do processo — SHA-256 `39d34fa4b24373b5d11d280c4a762ef035753212d5f7f3b0114a0020f2287d0c`

## Verificação de integridade

- ✅ Todos os arquivos existem e conferem com o SHA-256 registrado.
