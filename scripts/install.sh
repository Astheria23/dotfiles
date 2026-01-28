#!/bin/bash

# Dotfiles installation script

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Backup existing configuration
backup_config() {
    local src="$1"
    local backup_name="${src}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -e "$src" ]]; then
        mv "$src" "$backup_name"
        print_status "Backed up $src to $backup_name"
    fi
}

# Create symbolic link
create_symlink() {
    local src="$1"
    local dest="$2"
    
    backup_config "$dest"
    ln -sf "$src" "$dest"
    print_status "Created symlink: $dest -> $src"
}

# Install Neovim configuration
install_neovim() {
    print_status "Installing Neovim configuration..."
    
    local nvim_config_dir="$HOME/.config/nvim"
    local src_nvim_dir="$DOTFILES_DIR/nvim"
    
    create_symlink "$src_nvim_dir" "$nvim_config_dir"
}

# Install Tmux configuration
install_tmux() {
    print_status "Installing Tmux configuration..."
    
    local tmux_conf="$HOME/.tmux.conf"
    local src_tmux_conf="$DOTFILES_DIR/tmux.conf"
    
    create_symlink "$src_tmux_conf" "$tmux_conf"
    
    # Install TPM if not exists
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        print_status "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    else
        print_status "TPM already installed"
    fi
}

# Main installation
main() {
    print_status "Starting dotfiles installation..."
    print_status "Dotfiles directory: $DOTFILES_DIR"
    
    # Check if required directories exist
    if [[ ! -d "$DOTFILES_DIR/nvim" ]]; then
        print_error "Neovim configuration not found at $DOTFILES_DIR/nvim"
        exit 1
    fi
    
    if [[ ! -f "$DOTFILES_DIR/tmux.conf" ]]; then
        print_error "Tmux configuration not found at $DOTFILES_DIR/tmux.conf"
        exit 1
    fi
    
    # Install configurations
    install_neovim
    install_tmux
    
    print_status "Installation completed!"
    print_warning "Don't forget to:"
    print_warning "1. Open tmux and press prefix + I to install plugins"
    print_warning "2. Open neovim and run :Lazy to install plugins"
}

# Run main function
main "$@"