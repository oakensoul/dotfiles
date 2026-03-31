# Setup Guide

A step-by-step guide to setting up your macOS machine with the Loadout configuration system.

---

## Table of Contents

1. [Before You Begin](#1-before-you-begin)
2. [Initial Setup](#2-initial-setup)
3. [What Just Happened](#3-what-just-happened)
4. [Customizing Your Setup](#4-customizing-your-setup)
5. [Day-to-Day Usage](#5-day-to-day-usage)
6. [Advanced Topics](#6-advanced-topics)
7. [Troubleshooting](#7-troubleshooting)
8. [Uninstalling](#8-uninstalling)

---

## 1. Before You Begin

### What This System Does

Loadout takes a fresh macOS machine from factory settings to a fully configured development environment in a single command. It installs your tools, applies your shell and git configuration, sets macOS preferences, and manages updates going forward.

Unlike traditional dotfile managers that symlink files from a single repo, Loadout uses a **layered merge system**. You maintain a public base layer (this repo) with sensible defaults, then overlay private and organization-specific configuration on top. This means you can share your base setup publicly without exposing personal details, and switch between different team contexts cleanly. For a deeper look at the system design, see the [Architecture documentation](architecture/README.md).

### Prerequisites Checklist

Before running the setup, make sure you have:

- **macOS 13 Ventura or later** — Loadout targets modern macOS. Check your version in Apple menu > About This Mac.
- **Apple ID** — Required for installing Xcode Command Line Tools. If you are on a managed machine, your IT department may need to allow this.
- **GitHub account** — Your dotfiles repos are hosted on GitHub. [Create an account](https://github.com/signup) if you do not have one.
- **1Password account** (optional) — Adds convenience for SSH key management and secrets. See [SSH Key Setup Levels](#ssh-key-setup-levels) below. Not required.
- **GitHub CLI** (`gh`) (optional) — Enables automatic SSH key registration with GitHub. Installed by default via `Brewfile.base`. Not required.
- **cookiecutter** — Included automatically when you install loadout. No separate install needed.

### SSH Key Setup Levels

The `loadout init` flow gracefully degrades based on what tools are available. Every level produces a working SSH setup — the optional tools just add convenience.

| Tools Available | What Happens | User Action Required |
|---|---|---|
| **1Password CLI + GitHub CLI** | SSH key pulled from 1Password, saved locally, added to macOS keychain, and registered with GitHub automatically. | One-time 1Password authentication prompt. |
| **GitHub CLI only** | SSH key generated locally. Key registered with GitHub automatically via `gh`. | Authenticate `gh` manually once (e.g., `gh auth login`). |
| **Neither** | SSH key generated locally. | Register the key manually at [github.com/settings/keys](https://github.com/settings/keys). |

> **Note:** The SSH key provider is configurable. Loadout supports 1Password by default, and the provider interface is extensible for other secret managers (AWS Secrets Manager, HashiCorp Vault, etc.).

### Fork or Clone?

You have two options for getting started:

- **Fork** (recommended) — Fork this repo to your own GitHub account. This lets you customize the base layer, add your own packages to the Brewfile, and push changes back. This is the right choice if you want to tailor the defaults.
- **Clone** — Clone this repo directly. Good for evaluating or if you want to track upstream changes without maintaining your own fork. You can always fork later.

### What Will Happen

When you run `loadout init`, the CLI performs a 13-step bootstrap:

1. Ensure Xcode Command Line Tools are installed
2. Clone dotfiles repos (both `dotfiles` and `dotfiles-private`)
3. Set up SSH key (behavior depends on available tools — see [SSH Key Setup Levels](#ssh-key-setup-levels))
4. Register the SSH key with GitHub (automatic with `gh` CLI, otherwise manual)
5. Switch git remotes from HTTPS to SSH
6. Build dotfiles (merge base + private + org layers into `~/`)
7. Run Homebrew bundle (install all packages from assembled Brewfiles)
8. Install global runtimes (Node.js via nvm, Python via pyenv, Claude Code)
9. Build Claude Code configuration (merge MCP configs and CLAUDE.md)
10. Bootstrap canvas configuration (`~/.canvas/config.json`)
11. Apply macOS system defaults (Dock, Finder, keyboard, trackpad, screenshots)
12. Set up display launch agent (auto-detect connected displays and apply power settings)
13. Save configuration to `~/.dotfiles/.loadout.toml`

---

## 2. Initial Setup

### Step 1: Fork This Repo

On GitHub, fork this repository to your own account. If you plan to customize the base layer (adding packages, changing shell config), this is where those changes will live.

### Step 2: Create Your Private Repo

Your private repo (`dotfiles-private`) holds personal identity, org-specific configs, and secrets references. There are two ways to create it.

> **Note:** If you skip this step entirely, `loadout init` will fail when it tries to clone the missing `dotfiles-private` repo. Either create the private repo before running init, or use the [manual bootstrap](#manual-bootstrap) approach which only requires the public base layer. You can always create the private repo later and run `loadout build` to merge it in.

#### Recommended: Use `loadout scaffold`

The `loadout scaffold` command generates a properly structured `dotfiles-private` repo using a cookiecutter template. This is the fastest way to get started.

```bash
# Scaffold your private repo
loadout scaffold \
  --user=YOUR_USERNAME \
  --orgs=YOUR_ORG \
  --git-name="YOUR_NAME" \
  --git-email="YOUR_EMAIL" \
  --create-repo
```

This command:
- Creates `~/.dotfiles-private` with the correct directory structure for all configured layers
- Pre-fills git identity (name and email) for your primary org
- Optionally creates the GitHub repo and pushes the initial commit (when `--create-repo` is passed)

You can specify multiple orgs, and scaffold will create the directory structure for each:

```bash
loadout scaffold \
  --user=YOUR_USERNAME \
  --orgs=YOUR_ORG --orgs=another-org \
  --git-name="YOUR_NAME" \
  --git-email="YOUR_EMAIL"
```

To preview what will be generated without writing anything:

```bash
loadout scaffold --user=YOUR_USERNAME --orgs=YOUR_ORG --dry-run
```

<details>
<summary><strong>Alternative: Create the private repo manually</strong></summary>

If you prefer full control, create a private repository called `dotfiles-private` in your GitHub account and set up the directory structure yourself.

The expected structure is:

```
dotfiles-private/
├── brewfiles/
│   ├── Brewfile.private            # Personal Homebrew packages
│   └── orgs/
│       └── Brewfile.YOUR_ORG       # Per-org Homebrew packages
├── dotfiles/
│   ├── base/                       # Private base dotfiles (optional)
│   │   ├── .zshrc                  # Private shell config for all orgs
│   │   └── .gitconfig              # Private git config for all orgs
│   └── orgs/YOUR_ORG/
│       ├── .zshrc                  # Org-specific shell config
│       └── .gitconfig              # Org-specific git identity
├── globals/
│   └── orgs/
│       └── globals.YOUR_ORG.sh     # Org-specific env vars and tools
└── claude/
    └── orgs/YOUR_ORG/
        ├── mcp-YOUR_ORG.json       # Org-specific MCP servers
        └── CLAUDE.md               # Org-specific Claude context
```

You can start with just a `dotfiles/orgs/YOUR_ORG/.gitconfig` containing your `[user]` section and build from there.

</details>

### Step 3: Install Homebrew

If Homebrew is not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-install instructions to add Homebrew to your PATH.

### Step 4: Install the Loadout CLI

Loadout is not yet published to PyPI. Install it from the GitHub repository:

```bash
git clone https://github.com/oakensoul/loadout.git ~/.loadout-cli
pip3 install ~/.loadout-cli
```

Verify the installation:

```bash
loadout --help
```

### Step 5: Run Loadout Init

```bash
loadout init --user=YOUR_USERNAME --orgs=YOUR_ORG
```

Replace `YOUR_USERNAME` with your GitHub username and `YOUR_ORG` with your org slug (e.g., `personal`). You can specify multiple orgs:

```bash
loadout init --user=YOUR_USERNAME --orgs=personal --orgs=work
```

To preview what will happen without making changes:

```bash
loadout init --user=YOUR_USERNAME --orgs=YOUR_ORG --dry-run
```

The init process will prompt you for confirmation at key steps (SSH key generation, GitHub key registration). If any step fails, the process will tell you what went wrong and how to fix it before continuing.

### Step 6: Verify

Once init completes, verify everything is working:

```bash
loadout check
```

This runs read-only health checks and reports the status of your setup.

---

## 3. What Just Happened

After `loadout init` completes, here is what was created and configured on your machine.

### Directory Structure

| Path | What It Is |
|---|---|
| `~/.dotfiles/` | Clone of your dotfiles repo (public base layer) |
| `~/.dotfiles/dotfiles/base/` | Public base dotfiles (`.zshrc`, `.gitconfig`, `.aliases`) |
| `~/.dotfiles-private/` | Clone of your dotfiles-private repo (private/org layer) |
| `~/.dotfiles-private/dotfiles/base/` | Private base dotfiles (merged after public base) |
| `~/.dotfiles-private/dotfiles/orgs/` | Per-org dotfile overlays (highest priority) |
| `~/.dotfiles/.loadout.toml` | Loadout configuration (your username, active orgs, tool versions) |
| `~/.dotfiles/build/` | Staging area for merged dotfile output |
| `~/.dotfiles/backups/` | Timestamped backups of overwritten files |
| `~/.loadout/` | Runtime state directory (logs, backups) |
| `~/.zshrc.d/` | Shell overlay directory (numbered drop-in scripts) |
| `~/.gitconfig.d/` | Git config overlay directory (per-org includes) |
| `~/.claude/` | Claude Code config (mcp.json, CLAUDE.md, provider scripts) |

### What Got Installed

- **Homebrew packages** from `Brewfile.base` plus any org-specific Brewfiles
- **Node.js** via nvm (latest LTS)
- **Python** via pyenv
- **Claude Code** (installed via curl)
- **Canvas config** at `~/.canvas/config.json` (if canvas is installed and orgs are configured)
- Any additional global packages defined in your org globals scripts

### What Got Configured

- **Shell** — `~/.zshrc` merged from base + private + org layers, with overlay hooks in `~/.zshrc.d/`
- **Git** — `~/.gitconfig` with `[include]` directives to per-org configs in `~/.gitconfig.d/`
- **macOS defaults** — Dock, Finder, keyboard, trackpad, screenshot settings
- **SSH** — ed25519 key pair generated and registered with GitHub
- **Claude Code** — MCP servers and context files merged from all layers

---

## 4. Customizing Your Setup

### How the Layer Model Works

Loadout merges configuration from three layers, with later layers overriding earlier ones:

```
Priority 1 (lowest):   ~/.dotfiles/dotfiles/base/          Public base
Priority 2:            ~/.dotfiles-private/dotfiles/base/   Private base
Priority 3 (highest):  ~/.dotfiles-private/dotfiles/orgs/   Org overlays
```

The merge strategy depends on the file type:

| File Type | Strategy |
|---|---|
| `.zshrc`, `.aliases`, `.zprofile`, `.zshenv` | Concatenation (layers appended with comment separators) |
| `.gitconfig` | Include directives (`[include]` to `~/.gitconfig.d/`) |
| `*.json` | Recursive deep merge (later layers win on conflicts) |
| `*.yaml`, `*.yml` | Recursive deep merge |
| Everything else | Replace (last layer wins entirely) |

After making changes to any layer, run `loadout build` to regenerate the merged output.

### Adding Homebrew Packages

To add packages to your personal setup, create or edit a Brewfile in your private repo:

```ruby
# ~/.dotfiles-private/brewfiles/Brewfile.private
brew "ripgrep"
brew "fd"
cask "obsidian"
```

For org-specific packages:

```ruby
# ~/.dotfiles-private/brewfiles/orgs/Brewfile.YOUR_ORG
brew "awscli"
cask "docker"
```

Then run `loadout update` to install the new packages.

### Adding Shell Configuration

For personal shell config that applies across all orgs, add to your private base:

```bash
# ~/.dotfiles-private/dotfiles/base/.zshrc
# This gets concatenated after the public base .zshrc

export EDITOR="nvim"
alias ll="ls -la"
```

For org-specific shell config, add to the org overlay:

```bash
# ~/.dotfiles-private/dotfiles/orgs/YOUR_ORG/.zshrc
export AWS_PROFILE="YOUR_ORG"
```

You can also use the overlay hooks for quick, runtime changes that do not require a rebuild:

- **`~/.zshrc.d/*.zsh`** — Drop-in scripts sourced in numeric order. Use prefixes like `10-` for org config, `50-` for devbox, `90-` for private overrides.
- **`~/.zshrc.local`** — Sourced last. Good for machine-specific overrides that should not be in version control.

### Configuring Git Identity

Git identity should go in your private repo so it is never committed to a public repo:

```ini
# ~/.dotfiles-private/dotfiles/orgs/YOUR_ORG/.gitconfig
[user]
    name = Your Name
    email = your-email@example.com
```

For machine-specific git overrides, use `~/.gitconfig.local`:

```bash
git config --file ~/.gitconfig.local user.signingkey "YOUR_KEY_ID"
```

### Adding MCP Servers for Claude Code

To add private or org-specific MCP servers for Claude Code:

```json
// ~/.dotfiles-private/claude/orgs/YOUR_ORG/mcp-YOUR_ORG.json
{
  "mcpServers": {
    "your-server": {
      "command": "your-mcp-server",
      "args": ["--config", "/path/to/config"]
    }
  }
}
```

Run `loadout build` to merge the MCP configs into `~/.claude/mcp.json`.

---

## 5. Day-to-Day Usage

### Pull Latest and Rebuild

```bash
loadout update
```

This pulls the latest changes from your dotfiles repos, rebuilds the merged dotfiles, runs `brew bundle` to install any new packages, and installs global packages. Safe and idempotent — run it whenever you want to sync.

### Upgrade Everything

```bash
loadout upgrade
```

Everything in `update` plus `brew upgrade`. Run this intentionally, since Homebrew upgrades can occasionally break things. Use `--verbose` to see what is being upgraded.

### Check System Health

```bash
loadout check
```

Read-only health checks that never change anything. Reports on git status, Homebrew state, stale sessions, and disk space. Warnings are informational (optional tools not installed); errors indicate required tools that are missing.

### Rebuild Dotfiles

```bash
loadout build
```

Merges base + private + org layers and writes the result to `~/`. Use this after editing dotfile sources in either repo. Use `--dry-run` to preview changes without applying them.

### Manage Display Settings

```bash
loadout display              # Auto-detect connected displays
loadout display connected    # Force desktop/connected mode
loadout display solo         # Force laptop-solo mode
```

Applies power management and display settings based on your hardware configuration. Only relevant on macOS.

---

## 6. Advanced Topics

### Multi-Org Support

Loadout supports multiple organizations simultaneously. Each org gets its own:

- Git identity (conditional includes based on directory)
- Homebrew packages
- Shell environment variables
- Claude Code MCP servers and context
- iTerm2 color-coded terminal profiles

Configure active orgs during init or update `.loadout.toml` directly:

```toml
user = "YOUR_USERNAME"
orgs = ["personal", "work"]
```

Org overlays are applied in order, with later orgs taking priority on conflicts.

### Dev Environments with Devbox

[Devbox](https://github.com/oakensoul/devbox) creates disposable, SSH-only macOS user accounts for project isolation. Each devbox is a separate macOS user with its own home directory, SSH key, and shell environment.

```bash
devbox create --name myproject --org YOUR_ORG
ssh dx-myproject@localhost
```

Devbox reads presets from your `dotfiles-private` repo to configure environments per org.

### Project Workspaces with Canvas

[Canvas](https://github.com/oakensoul/canvas) manages ephemeral Claude Code workspaces. Each canvas session gets a dated directory with org-specific context injected from Jinja2 templates.

```bash
canvas new --org YOUR_ORG --name "api refactor"
canvas list
canvas archive SESSION_SLUG
```

### Manual Bootstrap

If you prefer not to use the loadout CLI, you can run the bootstrap scripts directly:

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Step 1: Install base tools
./bootstrap/install-base.sh
# Installs: Xcode CLI tools, Homebrew, Brewfile.base packages,
# global runtimes (nvm, Node.js, pyenv, Python), macOS defaults

# Step 2: Install dotfiles
./bootstrap/install-user.sh
# Backs up existing dotfiles to ~/.loadout/backups/,
# copies base configs to ~/, creates overlay directories

# Step 3 (optional): Install developer tools
./bootstrap/install-devbox.sh
# Installs: Brewfile.devbox packages, dev runtimes,
# devbox shell overlay, display detection
```

After running the manual scripts, set up your git identity:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "your-email@example.com"
```

Note that the manual scripts only install the base layer. They do not merge private or org layers, which is what `loadout init` and `loadout build` handle.

---

## 7. Troubleshooting

For any issue, start by running with `--verbose` to see the exact commands being executed:

```bash
loadout check --verbose
```

### Xcode CLI Tools Installation Hangs

The Xcode CLI tools installer sometimes stalls waiting for user input in a background dialog. Check for a macOS dialog box asking you to agree to the license terms. If the install is truly stuck, cancel it and install manually:

```bash
xcode-select --install
```

Then wait for the macOS installer dialog to complete.

### Homebrew Permission Issues

If `brew bundle` fails with permission errors, try:

```bash
sudo chown -R "$(whoami)" /opt/homebrew
brew doctor
```

On Intel Macs, the Homebrew prefix is `/usr/local/Homebrew` instead.

### SSH Key Registration Fails

SSH key registration with GitHub requires the GitHub CLI (`gh`). If `gh` is not available, `loadout init` will skip automatic registration with a warning. To register manually:

```bash
# Copy your public key
cat ~/.ssh/id_ed25519.pub | pbcopy

# Add it on GitHub: Settings > SSH and GPG keys > New SSH key
```

### 1Password CLI Not Found

Install the 1Password CLI via Homebrew:

```bash
brew install --cask 1password-cli
```

You also need to enable CLI integration in the 1Password desktop app: Settings > Developer > Command-Line Interface.

### Loadout Check Warnings

Warnings from `loadout check` are informational. They indicate optional tools that are not installed. Only errors indicate required tools that are missing and need attention.

### Git Pull Fails During Update

`loadout update` uses `--ff-only` for safety when pulling. If you have local uncommitted changes in your dotfiles repos:

```bash
cd ~/.dotfiles
git stash       # or git commit
loadout update
```

### Build Fails With Malformed JSON/YAML

Check the file path in the error message. The org overlay file has a syntax error. Fix the file in your private repo and re-run:

```bash
loadout build
```

### How to Start Over

If things go wrong and you want a clean slate:

```bash
# 1. Restore backed-up dotfiles BEFORE deleting anything.
#    Backups are stored in ~/.loadout/backups/ (the canonical location).
ls ~/.loadout/backups/
# Copy desired backup files back to ~/

# 2. Remove loadout-managed directories
rm -rf ~/.dotfiles ~/.dotfiles-private ~/.loadout

# 3. Re-run init
loadout init --user=YOUR_USERNAME --orgs=YOUR_ORG
```

### Where to Get Help

- Open an issue on [oakensoul/dotfiles](https://github.com/oakensoul/dotfiles/issues) for base layer issues
- Open an issue on [oakensoul/loadout](https://github.com/oakensoul/loadout/issues) for CLI tool issues

---

## 8. Uninstalling

To remove Loadout and restore your original dotfiles:

### Step 1: Restore Original Dotfiles

If you had dotfiles before installing Loadout, they were backed up:

```bash
# Check for backups
ls ~/.dotfiles/backups/
ls ~/.loadout/backups/

# Copy the most recent backup back to ~/
cp ~/.loadout/backups/TIMESTAMP/.zshrc ~/
cp ~/.loadout/backups/TIMESTAMP/.gitconfig ~/
cp ~/.loadout/backups/TIMESTAMP/.aliases ~/
```

If you did not have previous dotfiles, you can simply delete the installed ones:

```bash
rm ~/.zshrc ~/.gitconfig ~/.aliases
```

### Step 2: Remove Overlay Directories

```bash
rm -rf ~/.zshrc.d
rm -rf ~/.gitconfig.d
rm -f ~/.zshrc.local
rm -f ~/.gitconfig.local
```

### Step 3: Remove Loadout State

```bash
rm -rf ~/.dotfiles
rm -rf ~/.dotfiles-private
rm -rf ~/.loadout
```

### Step 4: Remove Claude Code Config (Optional)

```bash
rm -rf ~/.claude
```

### Step 5: Uninstall the CLI

```bash
pip3 uninstall oakensoul-loadout
rm -rf ~/.loadout-cli
```

Homebrew packages, nvm, pyenv, and other installed tools will remain on your system. Remove them individually if desired:

```bash
# Remove nvm
rm -rf ~/.nvm

# Remove pyenv
brew uninstall pyenv

# Remove all Homebrew packages (nuclear option)
# brew list | xargs brew uninstall --force
```
