# dotfiles

Dotfile sync via chezmoi.  For personal use only - don't push.

```
chezmoi init
chezmoi add ~/.bashrc
chezmoi edit ~/.bashrc
chezmoi -v apply

chezmoi cd
git add .
git commit -m "Initial commit"

git remote add origin https://github.com/d-/dotfiles.git
git branch -M main
git push -u origin main

# New Node
chezmoi init --apply d-
```
