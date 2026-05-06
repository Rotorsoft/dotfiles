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
6. Installs npm globals (`tree-sitter-cli`, used by nvim-treesitter to compile parsers) — skipped with a hint if `npm` isn't on `PATH` yet
7. Sets `zsh` as default shell
8. Runs `scripts/config.sh` to symlink dotfiles

Skip prompts with flags:

```bash
install.sh --all                       # install every group
install.sh --none                      # essentials only
install.sh --with python-ml,c-cpp      # only these groups
install.sh --skip creators,networking  # everything except these
```

After it finishes, open a new terminal and:

```bash
nvm install --lts
```

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

`.zshrc` is the interactive entry point. It loads in this order: completions → colored man pages (via `bat`) → homebrew zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) → `zoxide` + `fzf` → `starship` prompt → history/directory `setopt`s → vi keybindings → aliases.

`.aliases` is sourced last so its commands can reference any tool initialized above. It's a curated subset of the oh-my-zsh `git` plugin (status/staging/commit/diff/checkout/branch/pull/push/fetch/merge/rebase/reset/restore/stash/cherry-pick/log/remote) plus a handful of `brew`, `eza`, and one-letter shortcuts.

`.zprofile` runs once per login and provides the `use_tool` helper (`use node`, `use psql`, etc.) for lazy-loading paths and aliases for tools that don't need to be in every shell.

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
├── .zshrc / .zprofile / .aliases
├── .tmux.conf
├── starship.toml
├── ghostty.config / ghostty/
├── nvim/
├── vscode/
├── yazi.toml / yazi/
├── keychron_q6_max_ansi_knob.layout.json
└── scripts/
    ├── install.sh             # bootstrap (auto-discovers Brewfile.*)
    ├── config.sh              # symlink dotfiles into $HOME (idempotent)
    ├── update-brewfiles.sh    # diff installed vs tracked, route new entries
    └── cleanup-drift.sh       # uninstall packages not in any Brewfile
```
