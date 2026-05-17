# dotfiles

Personal macOS dev setup, biased toward TypeScript work.

## Quick start (new machine)

```bash
git clone https://github.com/<you>/.dotfiles.git ~/.dotfiles
~/.dotfiles/scripts/install.sh
```

The installer:

1. Re-execs under native ARM64 if running through Rosetta 2
2. Ensures Xcode Command Line Tools (clang/make/headers for node-gyp builds)
3. Installs Homebrew if missing; repairs the Homebrew git repo if corrupted; fixes ownership of `/usr/local/share/zsh*` so brew packages can write completions there
4. Installs **`Brewfile`** (essentials) — always
5. For every other `Brewfile.<group>` file, prompts y/n
6. Clones [`fzf-tab`](https://github.com/Aloxaf/fzf-tab) into `~/.local/share/zsh/fzf-tab` (no Homebrew formula exists for it)
7. Installs npm globals (`tree-sitter-cli`, used by nvim-treesitter to compile parsers) — skipped with a hint if `npm` isn't on `PATH` yet
8. Sets `zsh` as default shell
9. Runs `scripts/config.sh` to symlink dotfiles

Skip prompts with flags:

```bash
install.sh --all                       # install every group
install.sh --none                      # essentials only
install.sh --with python-ml,c-cpp      # only these groups
install.sh --skip creators,networking  # everything except these
```

After it finishes, open a new terminal and:

```bash
mise use --global node@lts   # install + activate latest LTS node
atuin import auto            # one-time: import existing zsh history into atuin
```

## Day-to-day shortcuts

### Keybindings

| Key             | Action                                                |
| --------------- | ----------------------------------------------------- |
| `Ctrl+H`        | Fuzzy shell history search (atuin)                    |
| `Ctrl+F`        | Fuzzy file picker with bat preview (fzf + fd)         |
| `Alt+C`         | Fuzzy `cd` into subdirectory with eza preview         |
| `Tab`           | Completion menu with previews (fzf-tab)               |
| `↑` / `↓`       | Prefix-based history search                           |
| `j` / `k` (vi)  | Same prefix-based history search in normal mode       |
| `y` (vi)        | Yank to system clipboard (`pbcopy`)                   |
| `z <dir>`       | Jump to most-used matching dir (zoxide)               |

> `Ctrl+H` is normally Backspace on terminals that send `^H` instead of `^?`. Ghostty defaults to `^?` so the binding is safe; if Backspace breaks on another terminal, swap the binding in `zsh/.zshrc`.

### Shell aliases (most-used)

| Alias  | Expands to                                        |
| ------ | ------------------------------------------------- |
| `g`    | `git`                                             |
| `v`    | `nvim`                                            |
| `y`    | `yazi`                                            |
| `b`    | `brew`                                            |
| `p`    | `pnpm`                                            |
| `use`  | `use_tool` (opt-in tool init — see below)         |
| `-`    | `cd -` (jump to previous directory)               |
| `ls`   | `eza -la --icons=auto --sort=name`                |
| `lt`   | `eza -la --icons=auto --sort=time` (recent first) |
| `la`   | `eza -laT -L3 --icons=auto` (tree, 3 levels)      |
| `gst`  | `git status`                                      |
| `gss`  | `git status --short`                              |
| `gd`   | `git diff` · `gds` for staged                     |
| `gc`   | `git commit --verbose` · `gc!` to amend           |
| `gco`  | `git checkout` · `gcb` for new branch             |
| `gp`   | `git push` · `gpf` for safe force-push            |
| `gl`   | `git pull` · `gpr` for `--rebase`                 |
| `gll`  | Pretty graph log                                  |
| `glog` | Oneline graph log                                 |
| `bup`  | `brew update && brew upgrade`                     |

Full list in [`zsh/.aliases`](zsh/.aliases).

### Opt-in tool environments

`use_tool` (alias: `use`) loads heavyweight tools on demand instead of every shell:

```bash
use dotnet   # adds /usr/local/share/dotnet to PATH
use node     # pnpm + corepack + p alias (node version is handled by mise)
use psql     # adds libpq's psql client to PATH
use bun      # sources bun completions
use gcloud   # sources gcloud path + completions
```

`use node` and `use psql` run automatically on login (cheap; node uses mise, no nvm).

### Node version management (mise)

[`mise`](https://mise.jdx.dev) replaces nvm/asdf/pyenv. It activates automatically in every shell and reads `.nvmrc`, `.tool-versions`, and `.mise.toml`.

```bash
mise use --global node@lts        # global default
mise use node@20                  # pin in current project (.mise.toml)
mise install                      # install whatever the project pins
```

### Shell history (atuin)

[`atuin`](https://atuin.sh) replaces Ctrl-R with sqlite-backed fuzzy search, scoped by directory/host/session. Up/Down arrows still do prefix search (atuin's binding is disabled in favor of zsh's built-in).

```bash
atuin import auto                 # one-time: pull in existing zsh history
atuin search <query>              # cli search
atuin stats                       # command frequency
```

Optional encrypted sync across machines via `atuin register`/`atuin login`.

## Brewfiles

| File | Purpose |
| --- | --- |
| `Brewfile` | Day-1 essentials: TS toolchain, neovim/tmux, terminal, GUI editors, postgres, fonts, core VS Code extensions |
| `Brewfile.nice-to-have` | Broadly useful but not critical: extra CLI tools, general media, other AI CLIs, secondary apps + extensions |
| `Brewfile.python-ml` | Python + Jupyter / data-science stack |
| `Brewfile.c-cpp` | C/C++ build chain — required for some Node native packages and container builds |
| `Brewfile.networking` | `arp-scan`, `nmap`, `nghttp2` |
| `Brewfile.creators` | Content creation: writing, typesetting (`pandoc`, `tectonic`, `typst`, `ghostscript`, `poppler*`), image/video/audio (`imagemagick`, `ffmpeg`), markdown/PDF/SVG VS Code extensions |
| `Brewfile.special-cases` | Leftovers grouped by section (Geo, Cloud, K8s, Redis, Yarn PnP, Procfile, JSON5, Remote/SSH, Prisma, Gemini IDE) |

Install a single one:

```bash
brew bundle --file=~/.dotfiles/Brewfile.python-ml
```

For `Brewfile.special-cases`, prefer copying just the section you need rather than installing the whole file.

## Keeping the Brewfiles in sync

Three workflows depending on what you want:

```bash
# Read-only: report drift in both directions, exit non-zero if drift exists
~/.dotfiles/scripts/update-brewfiles.sh --check

# Interactive: route each newly-installed entry into a Brewfile (numbered menu)
~/.dotfiles/scripts/update-brewfiles.sh

# Show uninstall commands for stuff installed locally but not tracked
~/.dotfiles/scripts/cleanup-drift.sh
~/.dotfiles/scripts/cleanup-drift.sh --apply   # actually run them (asks y/N)
```

`cleanup-drift.sh` skips auto-installed Homebrew dependencies (anything not in
`brew leaves`) — those would just be re-pulled, so they aren't real drift.

To install missing tracked entries on a stale machine:

```bash
brew bundle install --file=~/.dotfiles/Brewfile
```

## Shell config

Zsh uses `ZDOTDIR=$HOME/.config/zsh` so everything lives under `~/.config/` next to nvim/yazi/ghostty. A one-line `.zshenv` stub at `$HOME` exports `ZDOTDIR` (zsh has to read that one before it knows where the rest live).

| File | Runs when | Purpose |
| --- | --- | --- |
| `~/.zshenv` (stub) | every invocation | Exports `ZDOTDIR`, sources real `.zshenv` |
| `$ZDOTDIR/.zshenv` | every invocation | XDG vars, `EDITOR`, `MANPAGER`, `GPG_TTY`, `$HOME/.local/bin` on PATH |
| `$ZDOTDIR/.zprofile` | login shells | Homebrew shellenv, `use_tool` helper, runs `use_tool node` |
| `$ZDOTDIR/.zshrc` | interactive shells | Completions, plugins, fzf, mise, atuin, history, vi mode, prompt |
| `$ZDOTDIR/.aliases` | sourced from zshrc | Aliases (sourced last so they can reference initialized tools) |
| `$ZDOTDIR/.zshrc.local` | sourced from zshrc | Machine-local overrides (not in git) |

Why this split: env vars belong in `.zshenv` so non-interactive contexts (git via IDE, `crontab -e`, `ssh host cmd`) inherit them. Login-only setup (Homebrew's expensive `shellenv`, tool inits) belongs in `.zprofile` so subprocesses don't re-pay the cost. Interactive-only setup (prompt, plugins, keybindings) belongs in `.zshrc`.

Plugins are Homebrew-managed (no third-party plugin manager — `brew upgrade` keeps them current). The one exception is `fzf-tab`, which has no Homebrew formula and is cloned by `install.sh` into `~/.local/share/zsh/fzf-tab`:

- `zsh-autosuggestions` — fish-style inline suggestions
- `zsh-fast-syntax-highlighting` — faster, better-tokenized replacement for `zsh-syntax-highlighting`
- `fzf-tab` (git clone) — replaces `Tab` completion with an fzf picker that previews files (bat) and directories (eza)
- `starship` — prompt; config in [`starship.toml`](starship.toml) with per-state git status (⇡ahead, ⇣behind, +staged, ●modified, ?untracked, ✘deleted, ⚡conflicted)
- `zoxide` — smarter `cd` (`z <partial>`)
- `fzf` with `fd`-backed file search and `bat` preview window
- `mise` — version manager (nvm replacement, auto-activates)
- `atuin` — shell history (Ctrl-R replacement)

Vi mode is hand-rolled (`bindkey -v` + a `vi-yank-pbcopy` widget that yanks into the macOS clipboard) — no `zsh-vi-mode` plugin, which has known startup-latency issues and clobbers user bindings.

oh-my-zsh and Powerlevel10k were removed — `starship` is the prompt; the omz `git`/`docker`/`docker-compose`/`colored-man-pages`/`colorize` plugins are replaced inline (docker completion auto-generated on first run, man pages via `bat`, git aliases in `.aliases`).

## Configure links only

If brew is already set up and you just want to relink:

```bash
~/.dotfiles/scripts/config.sh
```

Idempotent and safe to re-run. Uses atomic `ln -sfn`, backs up real files/dirs to
`*.backup-<timestamp>`, and only prunes symlinks that point into `$DOTFILES_DIR`.

## Layout

```
.dotfiles/
├── Brewfile                  # essentials (always installed)
├── Brewfile.nice-to-have
├── Brewfile.python-ml
├── Brewfile.c-cpp
├── Brewfile.networking
├── Brewfile.creators
├── Brewfile.special-cases
├── .gitconfig
├── .zshenv                   # one-line ZDOTDIR bootstrap stub
├── zsh/                      # ZDOTDIR — real zsh config
│   ├── .zshenv
│   ├── .zprofile
│   ├── .zshrc
│   └── .aliases
├── .tmux.conf
├── starship.toml
├── ghostty/
├── nvim/
├── vscode/
├── yazi/
├── keychron_q6_max_ansi_knob.layout.json
└── scripts/
    ├── install.sh             # bootstrap (auto-discovers Brewfile.*)
    ├── config.sh              # symlink dotfiles into $HOME (idempotent)
    ├── update-brewfiles.sh    # diff installed vs tracked, route new entries
    └── cleanup-drift.sh       # uninstall packages not in any Brewfile
```
