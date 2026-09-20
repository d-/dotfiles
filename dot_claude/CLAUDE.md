# Environment

- **Shell is fish** (`/opt/homebrew/bin/fish`). Write interactive snippets in
  fish syntax — `set -gx FOO bar`, not `export FOO=bar`.
- **Homebrew comes before system binaries.** macOS `path_helper` appends
  `/etc/paths.d/homebrew` *after* `/usr/bin`, so anything not sourcing
  `brew shellenv` gets system binaries. Ruby in particular: use
  `/opt/homebrew/bin/ruby` (3.3), never `/usr/bin/ruby` (2.6).
- **Python** is conda env `py11` from `~/miniconda3`, activated by
  `config.fish`. Conda's env deliberately precedes Homebrew on `PATH`.
  Create envs with `-c conda-forge --override-channels` — the Anaconda default
  channels require accepting a ToS with commercial-use conditions.
- **tmux** config is `~/.config/tmux/tmux.conf`. Plugins are managed by tpm in
  `~/.config/tmux/plugins/`.

# Dotfiles

Managed by **chezmoi**. The source of truth is `~/.local/share/chezmoi/`;
everything under `~/.config/` is generated output.

- Edit the source (`dot_config/fish/config.fish`), then `chezmoi apply`.
  Never edit the target directly — the next apply reverts it.
- Use `chezmoi apply --exclude=scripts` while iterating, so `run_once_` and
  `run_onchange_` scripts don't fire unintentionally.
- Keep synced files machine-agnostic. Per-machine settings (repo checkouts,
  `PYTHONPATH`, tokens) go in `~/.config/fish/config.local.fish`, which is
  intentionally unmanaged.
- The remote `github.com/d-/dotfiles` is **public** and its README says
  "don't push". Confirm before pushing, and never commit employer-internal
  project names.

# Preferences

- Verify changes by running them, not by asserting they work. Shell config in
  particular: test a *clean* login shell (`env -i HOME=$HOME fish --login -c
  ...`), since a shell inherited from the parent hides `PATH` problems.
