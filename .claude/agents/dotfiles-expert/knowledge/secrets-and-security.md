---
name: secrets-and-security
description: 1Password integration, secret patterns, security validation across the ecosystem
---

# Secrets & Security

## 1Password CLI (op)

All secrets across the ecosystem use 1Password CLI references — never hardcoded values.

### Pattern
```bash
export SECRET="$(op read "op://VaultName/ItemName/field")"
```

### Usage by Tool

| Tool | Secret Type | Example op:// Path |
|---|---|---|
| dotfiles-private globals | GitHub tokens, AWS credentials | `op://Personal/GitHub Token/credential` |
| dotfiles-private providers | Anthropic API keys | `op://Personal/Anthropic API Key/credential` |
| dotfiles-private providers | AWS Bedrock credentials | `op://Splash/AWS Bedrock/access_key_id` |
| loadout init | GitHub token for SSH key registration | `op://Personal/GitHub Token/credential` |
| devbox create | Preset env vars (any op:// refs resolved at create time) | varies per preset |

### SSH Agent
SSH keys are managed by 1Password SSH agent — no plaintext private keys on disk.

## Devbox Security

- Secrets resolved from presets at create time, written to `/Users/dx-{name}/.devbox-env` (mode 0600)
- Sudoers drop-in: only allows `dscl` and `createhomedir` on `dx-*` users
- UID range 600-699 for devbox accounts
- SSH key pair generated fresh per devbox; public key registered with GitHub, removed on nuke
- Inbound SSH: parent user's GitHub `.keys` endpoint used for authorized_keys
- Password disabled on devbox accounts (SSH-only access)

## Canvas Security

- Path traversal protection: validates org/slug against `/\\..[\x00]` regex
- Templates are user-controlled local files (Jinja2 unsandboxed — safe because local)
- TOCTOU on slug collision acknowledged as acceptable for single-user CLI

## Validation Suite (dotfiles repo)

`test/validate.sh` runs 10 checks including:

**Secrets scan** — regex patterns for common secret formats:
- OpenAI API keys
- GitHub tokens (`ghp_`, `gho_`, `ghu_`)
- AWS access keys (`AKIA`)
- Slack tokens (`xoxb-`, `xoxp-`)
- Private key headers (`BEGIN.*PRIVATE KEY`)

**Hardcoded path scan** — flags `/Users/` or `/home/` patterns for portability.

## Licensing

All repos use **AGPL-3.0-or-later** (strong copyleft).

AI attribution policy: No "Co-Authored-By" or AI attribution in commits (copyright protection for AGPL-3.0). This is enforced in CI for canvas and devbox.

## Public Repo Rules (dotfiles)

Never commit to the public dotfiles repo:
- API keys, tokens, or secrets
- Personal email addresses or identifiers
- Machine-specific paths (`/Users/username/`)
- Organization-specific configurations
