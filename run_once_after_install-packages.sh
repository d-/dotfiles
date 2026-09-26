#!/bin/bash
# Bootstrap a new machine. Run once by chezmoi after dotfiles are applied.
# Re-runs only if this file's contents change. Everything here is idempotent
# and machine-agnostic -- no repo checkouts, no credentials, no per-host paths.
set -uo pipefail

info() { printf '\n==> %s\n' "$1"; }
warn() { printf '    !! %s\n' "$1" >&2; }

[[ "$(uname -s)" == "Darwin" ]] || { warn "not macOS; skipping"; exit 0; }

# --- Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        [[ -x "$p" ]] && eval "$("$p" shellenv)" && break
    done
fi
if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew not installed. Install it first, then re-run:"
    warn '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

info "Installing CLI tools"
brew install fish fzf gh tmux neovim lynx chezmoi || warn "some formulae failed"

# Neovim config deps: node (Copilot, pyright, ts_ls via Mason), ripgrep/fd
# (Telescope), tree-sitter-cli (nvim-treesitter parser builds).
info "Installing Neovim dependencies"
brew install node ripgrep fd tree-sitter-cli || warn "some neovim deps failed"

info "Installing GUI apps"
brew install --cask kitty espanso || warn "some casks failed"

info "Installing window manager (yabai/skhd)"
brew tap koekeishiya/formulae >/dev/null 2>&1
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd || warn "yabai/skhd failed"

# --- C++ toolchain ------------------------------------------------------------
# Apple's CLT provides clang/clangd/lldb but no cmake, ninja, clang-format or
# clang-tidy. llvm is keg-only; config.fish puts its bin dir first on PATH so
# Homebrew's clang is the default compiler. gcc installs as gcc-NN/g++-NN.
info "Installing C++ toolchain"
brew install cmake ninja ccache llvm gcc include-what-you-use \
    vcpkg conan cppcheck bear lcov gcovr google-benchmark hyperfine pkgconf cppman \
    || warn "some C++ formulae failed"
# cppman: cppreference as man pages. Neovim pipes it through PAGER=cat, which
# only works when cppman's own pager setting is "system".
command -v cppman >/dev/null 2>&1 && cppman --pager=system >/dev/null 2>&1 || true

# vcpkg's brew formula is just the binary; ports live in a full clone (shallow
# clones break baseline lookups). config.fish exports VCPKG_ROOT when present.
VCPKG_DIR="$HOME/.local/share/vcpkg"
if [[ ! -d "$VCPKG_DIR/.git" ]]; then
    info "Cloning vcpkg registry to $VCPKG_DIR"
    git clone -q https://github.com/microsoft/vcpkg "$VCPKG_DIR" || warn "vcpkg clone failed"
fi

# Editor extensions (Cursor/VS Code CLI, if present). clangd + CMake Tools +
# CodeLLDB cover language server, build integration and debugging.
if command -v code >/dev/null 2>&1; then
    info "Installing C++ editor extensions"
    for ext in llvm-vs-code-extensions.vscode-clangd ms-vscode.cmake-tools \
               twxs.cmake vadimcn.vscode-lldb; do
        code --install-extension "$ext" >/dev/null 2>&1 || warn "extension $ext failed"
    done
fi

# --- Register fish as a login shell -----------------------------------------
FISH="$(command -v fish || true)"
if [[ -n "$FISH" ]] && ! grep -qxF "$FISH" /etc/shells; then
    info "Adding $FISH to /etc/shells (needs sudo)"
    echo "$FISH" | sudo tee -a /etc/shells >/dev/null || warn "could not update /etc/shells"
fi
if [[ -n "$FISH" && "$SHELL" != "$FISH" ]]; then
    warn "Default shell is $SHELL. To switch:  chsh -s $FISH"
fi

# --- Miniconda --------------------------------------------------------------
# Installed to ~/miniconda3 to match the path config.fish probes for.
CONDA="$HOME/miniconda3/bin/conda"
if [[ ! -x "$CONDA" ]]; then
    info "Installing miniconda to ~/miniconda3"
    case "$(uname -m)" in
        arm64) MC_ARCH="arm64" ;;
        *)     MC_ARCH="x86_64" ;;
    esac
    MC_TMP="$(mktemp -t miniconda).sh"
    if curl -fsSL -o "$MC_TMP" \
        "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-${MC_ARCH}.sh"; then
        bash "$MC_TMP" -b -p "$HOME/miniconda3" || warn "miniconda install failed"
    else
        warn "miniconda download failed"
    fi
    rm -f "$MC_TMP"
fi

# conda-forge only: avoids Anaconda's default-channel Terms of Service, which
# also carry commercial-use licensing conditions.
if [[ -x "$CONDA" ]] && ! "$CONDA" env list | grep -qE '^py11\s'; then
    info "Creating conda env py11 (conda-forge)"
    "$CONDA" create -n py11 python=3.11 -y -c conda-forge --override-channels \
        || warn "py11 env creation failed"
fi

# --- fish plugins -----------------------------------------------------------
# Plugin list is tracked in dot_config/fish/fish_plugins; fisher reconciles to it.
if [[ -n "$FISH" ]]; then
    if [[ ! -f "$HOME/.config/fish/functions/fisher.fish" ]]; then
        info "Installing fisher"
        mkdir -p "$HOME/.config/fish/functions"
        curl -fsSL -o "$HOME/.config/fish/functions/fisher.fish" \
            https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
            || warn "fisher download failed"
    fi
    if [[ -f "$HOME/.config/fish/fish_plugins" ]]; then
        info "Syncing fish plugins"
        "$FISH" -c 'fisher update' || warn "fisher update failed"
    fi
fi

# --- tmux plugins (tpm) -----------------------------------------------------
# tpm is XDG-aware: with the config at ~/.config/tmux/tmux.conf it installs
# plugins into ~/.config/tmux/plugins, so tpm itself lives there too.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if command -v tmux >/dev/null 2>&1; then
    if [[ ! -d "$TPM_DIR/.git" ]]; then
        info "Installing tpm"
        mkdir -p "$(dirname "$TPM_DIR")"
        git clone -q --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" \
            || warn "tpm clone failed"
    fi
    if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
        info "Installing tmux plugins"
        "$TPM_DIR/bin/install_plugins" </dev/null || warn "tpm plugin install failed"
    fi
fi

info "Bootstrap complete. Machine-specific settings go in ~/.config/fish/config.local.fish"
