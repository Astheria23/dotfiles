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
    
    # Create plugins symlink and install
    local plugins_dir="$HOME/.tmux/plugins"
    local tpm_dir="$plugins_dir/tpm"
    
    # Create symlink to local plugins directory
    create_symlink "$DOTFILES_DIR/tmux/plugins" "$plugins_dir"
    
    if [[ ! -d "$tpm_dir" ]]; then
        print_status "Installing TPM (Tmux Plugin Manager)..."
        mkdir -p "$plugins_dir"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        
        # Install other plugins
        print_status "Installing tmux plugins..."
        "$tpm_dir/bin/install_plugins"
    else
        print_status "TPM already installed"
    fi
}

# Install Zsh configuration
install_zsh() {
    print_status "Installing Zsh configuration..."
    
    local zshrc="$HOME/.zshrc"
    local zshenv="$HOME/.zshenv"
    local src_zshrc="$DOTFILES_DIR/zsh/.zshrc"
    local src_zshenv="$DOTFILES_DIR/zsh/.zshenv"
    
    # Create symlinks for zsh config
    create_symlink "$src_zshrc" "$zshrc"
    create_symlink "$src_zshenv" "$zshenv"
    
    # Install Oh My Zsh if not exists
    local oh_my_zsh_dir="$HOME/.oh-my-zsh"
    if [[ ! -d "$oh_my_zsh_dir" ]]; then
        print_status "Installing Oh My Zsh..."
        RUN_ZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    else
        print_status "Oh My Zsh already installed"
    fi
    
    # Install zsh plugins
    local zsh_plugins_dir="$HOME/.zsh"
    create_symlink "$DOTFILES_DIR/zsh/z" "$zsh_plugins_dir/z"
    
    # Clone external plugins if they don't exist
    if [[ ! -d "$zsh_plugins_dir/zsh-autosuggestions" ]]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_plugins_dir/zsh-autosuggestions"
    fi
    
    if [[ ! -d "$zsh_plugins_dir/zsh-syntax-highlighting" ]]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_plugins_dir/zsh-syntax-highlighting"
    fi
    
    # Copy custom configurations to oh-my-zsh
    if [[ -d "$DOTFILES_DIR/zsh/plugins" ]]; then
        create_symlink "$DOTFILES_DIR/zsh/plugins" "$oh_my_zsh_dir/custom/plugins"
    fi
    
    if [[ -d "$DOTFILES_DIR/zsh/themes" ]]; then
        create_symlink "$DOTFILES_DIR/zsh/themes" "$oh_my_zsh_dir/custom/themes"
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
    install_zsh
    
    print_status "Installation completed!"
    print_warning "Don't forget to:"
    print_warning "1. Open tmux and press prefix + I to install plugins"
    print_warning "2. Open neovim and run :Lazy to install plugins"
    print_warning "3. Restart your shell or run: source ~/.zshrc"
}

# Run main function
main "$@"