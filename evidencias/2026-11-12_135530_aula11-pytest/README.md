# Evidências — aula11-pytest

- **Projeto:** `implement_Moodle`
- **Início da sessão:** 2026-11-12T13:55:30-03:00
- **Fim da sessão:** 2026-11-12T13:55:34-03:00
- **Ambiente:** WSL (Ubuntu) Ubuntu 26.04 LTS · usuário `lucaskenway` · host `DESKTOP-AMJ5UEC`
- **Comandos registrados:** 2 (2 com retorno 0, 0 com falha) · **capturas de tela:** 0

> Gerado pela ferramenta `evidencia`. Os TXT contêm a saída capturada diretamente dos processos, sem edição; a única alteração possível é a troca de dados sensíveis por `[REDIGIDO:tipo]`, sempre informada abaixo. Imagens **renderizadas** são desenhadas a partir do TXT e **não são capturas de tela**; capturas **autênticas** são cópias dos pixels da tela.

## Índice

| # | Horário | Descrição | Comando | Retorno | Arquivos |
|---|---------|-----------|---------|---------|----------|
| 001 | 13:55:31 | pytest do template (copia no FS Linux) | `cd /home/lucaskenway/.claude-tmp/claude-1000/-mnt-c-Users-lucas-devops-20262/ca12936d-720f-4fb3-b2f8-18fc2d2414b0/scratchpad/moodle-copy && git pull -q && uv run --no-project --with pytest --with hypothesis --with pyyaml python -m pytest -q -p no:cacheprovider` | ✅ 0 | [001_135531_pytest-do-template-copia-no-fs-linux.txt](001_135531_pytest-do-template-copia-no-fs-linux.txt) — TXT — saída real do processo<br>[001_135531_pytest-do-template-copia-no-fs-linux_renderizada.png](001_135531_pytest-do-template-copia-no-fs-linux_renderizada.png) — PNG — imagem renderizada (não é captura de tela) |
| 002 | 13:55:33 | titulo da pagina servida | `curl -sL http://localhost:8080/ \| grep -o '<title>[^<]*'` | ✅ 0 | [002_135533_titulo-da-pagina-servida.txt](002_135533_titulo-da-pagina-servida.txt) — TXT — saída real do processo<br>[002_135533_titulo-da-pagina-servida_renderizada.png](002_135533_titulo-da-pagina-servida_renderizada.png) — PNG — imagem renderizada (não é captura de tela) |

## Detalhes

### #001 — pytest do template (copia no FS Linux)

- **Comando:** `cd /home/lucaskenway/.claude-tmp/claude-1000/-mnt-c-Users-lucas-devops-20262/ca12936d-720f-4fb3-b2f8-18fc2d2414b0/scratchpad/moodle-copy && git pull -q && uv run --no-project --with pytest --with hypothesis --with pyyaml python -m pytest -q -p no:cacheprovider`
- **Shell:** bash · **diretório:** `/mnt/c/Users/lucas/implement_Moodle`
- **Início:** 2026-11-12T13:55:31-03:00 · **fim:** 2026-11-12T13:55:32-03:00 · **duração:** 1.778 s
- **Código de retorno:** 0
- `001_135531_pytest-do-template-copia-no-fs-linux.txt` — TXT — saída real do processo — SHA-256 `d261dbaf5b1e8a9f3ea2e43407b4ed07163195e9a6fa4739e4622aaaa058d929`
- `001_135531_pytest-do-template-copia-no-fs-linux_renderizada.png` — PNG — imagem renderizada (não é captura de tela) — SHA-256 `1a7281a19575fbf4c12d4f14708253cac799b62881cf529930ba09a44a1512c6`

### #002 — titulo da pagina servida

- **Comando:** `curl -sL http://localhost:8080/ | grep -o '<title>[^<]*'`
- **Shell:** bash · **diretório:** `/mnt/c/Users/lucas/implement_Moodle`
- **Início:** 2026-11-12T13:55:33-03:00 · **fim:** 2026-11-12T13:55:34-03:00 · **duração:** 0.589 s
- **Código de retorno:** 0
- `002_135533_titulo-da-pagina-servida.txt` — TXT — saída real do processo — SHA-256 `260738f2172cdb0a43a984bab24f8a04b2c4b4305dae3ef4104a8cf10a5bf8d3`
- `002_135533_titulo-da-pagina-servida_renderizada.png` — PNG — imagem renderizada (não é captura de tela) — SHA-256 `3b652dbf9436e6fd91fca22ce84bee685c0cc65d9573f6e489ff1b1b175d0e53`

## Verificação de integridade

- ✅ Todos os arquivos existem e conferem com o SHA-256 registrado.
