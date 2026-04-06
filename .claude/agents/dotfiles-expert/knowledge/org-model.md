---
name: org-model
description: Multi-org support — 5 orgs, per-org config surfaces, identity resolution
---

# Multi-Org Model

## Supported Organizations

| Org Slug | GitHub Identity | Description |
|---|---|---|
| `personal` | oakensoul | Personal projects |
| `splash` | splash-rob | Splash Sports (employer) |
| `mythical-journeys` | TBD | Side project (game/LARP) |
| `sidequest-syndicate` | TBD | Side project collective |
| `equinox-consulting` | TBD | Consulting work |

## Per-Org Configuration Surface

Each org can have any/all of:

| Config Type | Location in dotfiles-private | Purpose |
|---|---|---|
| Git identity | `dotfiles/orgs/{org}/.gitconfig` | user.name, user.email, signing key |
| Shell globals | `globals/orgs/globals.{org}.sh` | Env vars (secrets via op://) |
| Brewfile | `brewfiles/orgs/Brewfile.{org}` | Org-specific packages |
| Claude CLAUDE.md | `claude/orgs/{org}/CLAUDE.md` | Org instructions for Claude |
| Claude MCP | `claude/orgs/{org}/mcp-{org}.json` | MCP server config |
| Claude providers | `claude/providers/anthropic-{org}.sh`, `bedrock-{org}.sh` | API key providers |
| Shell config | `dotfiles/orgs/{org}/.zshrc` | Org shell extensions |
| Devbox presets | `devbox/presets/{project}.json` | Per-project dev environment presets |
| Canvas templates | `canvas/orgs/{org}/CLAUDE.md.tmpl` | Jinja2 session templates |
| Slack | `slack/{org}/slack-workspaces.json` | Workspace URLs |

## Org Selection

### loadout
- Set at init: `loadout init --orgs=personal --orgs=splash`
- Stored in `~/.dotfiles/.loadout.toml` → `orgs = ["personal", "splash"]`
- Multiple orgs can be active simultaneously (configs merged in order)

### canvas
- Set in `~/.canvas/config` (JSON with `org` field)
- Written by `loadout init`
- Single active org at a time (determines which CLAUDE.md.tmpl to render)

### devbox
- Set per-devbox via preset: `devbox create mybox --preset=splash-data`
- Preset's `mcp_profile` field selects org context
- Each devbox has exactly one org/preset

## Git Identity Resolution

Git identity is never in the public base `.gitconfig`. Instead:

1. Base `.gitconfig` includes `~/.gitconfig.local` and `~/.gitconfig.d/`
2. `loadout build` writes org configs to `~/.gitconfig.d/{org}.gitconfig`
3. Each org gitconfig uses `[includeIf "gitdir:~/Developer/{org}/"]` for path-based identity
4. When you `cd` into `~/Developer/splash/some-repo`, git automatically uses the splash identity

## Naming Conventions

- Org slugs: kebab-case (e.g., `mythical-journeys`, `sidequest-syndicate`)
- Flat files: org in filename (e.g., `globals.personal.sh`, `Brewfile.splash`)
- Multi-file categories: subdirectory per org (e.g., `orgs/personal/`, `orgs/splash/`)
