# Dotfiles Setup

This repository contains configuration files for my Linux development environment.

## Structure

- `nvim/` - Neovim configuration
- `tmux/` - Tmux configuration
- `tmux.conf` - Main tmux configuration file

## Installation

### Neovim
```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true

# Create symlink
ln -s $(pwd)/nvim ~/.config/nvim
```

### Tmux
```bash
# Backup existing config
mv ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null || true

# Create symlink
ln -s $(pwd)/tmux.conf ~/.tmux.conf

# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install plugins (prefix + I)
```

## Plugin List

### Tmux Plugins
- tmux-plugins/tpm - Plugin manager
- tmux-plugins/tmux-sensible - Sensible defaults
- tmux-plugins/tmux-resurrect - Save/restore sessions
- tmux-plugins/tmux-continuum - Automatic saving

### Neovim Plugins
(See nvim/lua/custom/plugins/init.lua for complete list)

## Notes

- This setup is optimized for Linux environment
- Uses Lua for Neovim configuration
- TPM handles tmux plugin management