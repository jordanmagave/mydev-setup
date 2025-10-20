#!/bin/bash

#################################################
# Script de Setup para Ubuntu WSL2
# Ferramentas: LunarVim, Zsh, OhMyZsh, Powerlevel10k, ASDF, Go, Python, Node, Rust
# 
# Uso: chmod +x setup.sh && ./setup.sh
#################################################

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Função para print colorido
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

print_info() {
    echo -e "${PURPLE}ℹ${NC} $1"
}

# Verificar se está rodando como root
if [[ $EUID -eq 0 ]]; then
   print_error "Este script não deve ser executado como root!"
   exit 1
fi

# Verificar se está no WSL2
if ! grep -qi microsoft /proc/version; then
    print_warning "Este script foi otimizado para WSL2, mas parece que você não está no WSL."
    read -p "Deseja continuar? (s/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

print_status "Iniciando setup do ambiente de desenvolvimento no WSL2..."

# Criar diretórios necessários
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config"

# Atualizar sistema
print_status "Atualizando lista de pacotes..."
sudo apt update && sudo apt upgrade -y

print_status "Instalando dependências básicas..."
sudo apt install -y \
    curl \
    git \
    build-essential \
    wget \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    fontconfig \
    python3-pip \
    python3-venv \
    python3-dev \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    liblzma-dev \
    lldb \
    pkg-config \
    zlib1g-dev \
    sqlite3 \
    libsqlite3-dev

# Instalar Zsh
if ! command -v zsh &> /dev/null; then
    print_status "Instalando Zsh..."
    sudo apt install -y zsh
    print_success "Zsh instalado!"
else
    print_warning "Zsh já está instalado"
fi

# Instalar Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_status "Instalando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh instalado!"
else
    print_warning "Oh My Zsh já está instalado"
fi

# Instalar Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_status "Instalando Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k instalado!"
else
    print_warning "Powerlevel10k já está instalado"
fi

# Instalar fontes Nerd Fonts (necessário para P10k)
print_status "Instalando MesloLGS NF fonts (necessário para Powerlevel10k)..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Download das fontes MesloLGS NF
fonts=(
    "MesloLGS%20NF%20Regular.ttf"
    "MesloLGS%20NF%20Bold.ttf"
    "MesloLGS%20NF%20Italic.ttf"
    "MesloLGS%20NF%20Bold%20Italic.ttf"
)

for font in "${fonts[@]}"; do
    if [ ! -f "${font//%20/ }" ]; then
        wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/${font}"
        print_success "Fonte ${font//%20/ } baixada"
    fi
done

# Atualizar cache de fontes
fc-cache -f -v > /dev/null 2>&1
cd ~
print_success "Fontes instaladas!"

# Instalar plugins do Zsh
print_status "Instalando plugins do Zsh..."

# Função auxiliar para instalar plugin Zsh
install_zsh_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${plugin_name}"

    if [ -d "$plugin_dir" ]; then
        # Verifica se é um repositório git válido
        if [ -d "$plugin_dir/.git" ]; then
            print_warning "${plugin_name} já está instalado"
            return 0
        else
            # Diretório existe mas não é um repositório git válido, remove e reinstala
            print_warning "${plugin_name} está em estado inválido, removendo e reinstalando..."
            rm -rf "$plugin_dir"
        fi
    fi

    # Instala o plugin
    git clone "$plugin_url" "$plugin_dir"
    print_success "${plugin_name} instalado!"
}

# zsh-autosuggestions
install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"

# zsh-syntax-highlighting
install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"

# zsh-histdb
install_zsh_plugin "zsh-histdb" "https://github.com/larkery/zsh-histdb"

# Instalar ferramentas CLI modernas
print_status "Instalando ferramentas CLI modernas..."

# bat (cat melhorado)
if ! command -v bat &> /dev/null; then
    print_status "Instalando bat..."
    sudo apt install -y bat
    # No Ubuntu, bat é instalado como batcat
    if [ -f /usr/bin/batcat ]; then
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi
    print_success "bat instalado!"
fi

# exa (ls melhorado)
if ! command -v exa &> /dev/null; then
    print_status "Instalando exa..."
    # Baixar a versão mais recente do exa
    wget -q -O exa.zip https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip
    unzip -q exa.zip -d exa-temp
    sudo mv exa-temp/bin/exa /usr/local/bin/
    rm -rf exa.zip exa-temp
    print_success "exa instalado!"
fi

# ripgrep
if ! command -v rg &> /dev/null; then
    print_status "Instalando ripgrep..."
    sudo apt install -y ripgrep
    print_success "ripgrep instalado!"
fi

# fd-find
if ! command -v fd &> /dev/null; then
    print_status "Instalando fd-find..."
    sudo apt install -y fd-find
    ln -sf $(which fdfind) ~/.local/bin/fd
    print_success "fd instalado!"
fi

# Instalar ASDF 0.16.0
if [ ! -d "$HOME/.asdf" ]; then
    print_status "Instalando ASDF v0.16.0..."
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.16.0
    print_success "ASDF instalado!"
else
    print_warning "ASDF já está instalado"
    # Atualizar para v0.16.0 se necessário
    cd ~/.asdf
    git fetch
    git checkout v0.16.0
    cd ~
fi

# Instalar NVM
if [ ! -d "$HOME/.nvm" ]; then
    print_status "Instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    print_success "NVM instalado!"
else
    print_warning "NVM já está instalado"
fi

# Instalar Rust
if ! command -v rustc &> /dev/null; then
    print_status "Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    print_success "Rust instalado!"
else
    print_warning "Rust já está instalado"
fi

# Instalar Neovim
if ! command -v nvim &> /dev/null || [ ! -f "/opt/nvim-linux-x86_64/bin/nvim" ]; then
    print_status "Instalando Neovim (versão mais recente)..."
    # Baixar a versão mais recente do Neovim
    wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    sudo mv /opt/nvim-linux64 /opt/nvim-linux-x86_64
    rm nvim-linux64.tar.gz
    print_success "Neovim instalado!"
else
    print_warning "Neovim já está instalado"
fi

# Instalar LunarVim
if ! command -v lvim &> /dev/null; then
    print_status "Instalando dependências do LunarVim..."
    
    # Node.js via NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    
    # Instalar pacotes npm globais necessários
    npm install -g neovim tree-sitter-cli
    
    print_status "Instalando LunarVim..."
    bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/master/utils/installer/install.sh) --no-install-dependencies
    print_success "LunarVim instalado!"
    
    # Criar diretório de configuração se não existir
    mkdir -p ~/.config/lvim
    
    # Copiar configuração se fornecida
    if [ -f "config.lua" ]; then
        print_status "Copiando configuração do LunarVim..."
        cp config.lua ~/.config/lvim/
        print_success "Configuração copiada!"
    fi
else
    print_warning "LunarVim já está instalado"
fi

# Configurar ASDF
print_status "Configurando plugins ASDF..."
source "$HOME/.asdf/asdf.sh"

# Plugin Python
if ! asdf plugin list | grep -q python; then
    print_status "Adicionando plugin Python ao ASDF..."
    asdf plugin add python
    print_success "Plugin Python adicionado!"
fi

# Plugin Golang
if ! asdf plugin list | grep -q golang; then
    print_status "Adicionando plugin Golang ao ASDF..."
    asdf plugin add golang
    print_success "Plugin Golang adicionado!"
fi

# Plugin NodeJS
if ! asdf plugin list | grep -q nodejs; then
    print_status "Adicionando plugin NodeJS ao ASDF..."
    asdf plugin add nodejs
    print_success "Plugin NodeJS adicionado!"
fi

# Plugin Ruby
if ! asdf plugin list | grep -q ruby; then
    print_status "Adicionando plugin Ruby ao ASDF..."
    asdf plugin add ruby
    print_success "Plugin Ruby adicionado!"
fi

# Instalar versões das linguagens
print_status "Instalando linguagens de programação..."

# Python
if ! asdf list python | grep -q "3.12"; then
    print_status "Instalando Python 3.12..."
    asdf install python 3.12.0
    asdf global python 3.12.0
    print_success "Python instalado!"
fi

# Go
if ! asdf list golang | grep -q "1.21"; then
    print_status "Instalando Go 1.21..."
    asdf install golang 1.21.5
    asdf global golang 1.21.5
    print_success "Go instalado!"
fi

# Node.js (via ASDF também, além do NVM)
if ! asdf list nodejs | grep -q "20"; then
    print_status "Instalando Node.js 20 LTS via ASDF..."
    asdf install nodejs 20.11.0
    asdf global nodejs 20.11.0
    print_success "Node.js instalado via ASDF!"
fi

# Instalar ferramentas Python
print_status "Instalando ferramentas Python..."
python -m pip install --upgrade pip
pip install --user \
    black \
    isort \
    ruff \
    pytest \
    django \
    virtualenv \
    pipx

# Instalar ferramentas Go
print_status "Instalando ferramentas Go..."
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install mvdan.cc/gofumpt@latest
go install golang.org/x/tools/cmd/goimports@latest

# Instalar ferramentas JavaScript/TypeScript
print_status "Instalando ferramentas JavaScript/TypeScript..."
npm install -g \
    typescript \
    @types/node \
    eslint \
    eslint_d \
    prettier \
    jest \
    @vue/cli \
    create-react-app

# Instalar LazyGit
if ! command -v lazygit &> /dev/null; then
    print_status "Instalando LazyGit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
    print_success "LazyGit instalado!"
fi

# Configurar .zshrc
print_status "Configurando .zshrc..."

# Backup do .zshrc atual
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    print_status "Backup do .zshrc criado"
fi

# Criar novo .zshrc baseado no fornecido
cat > "$HOME/.zshrc" << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    docker-compose
    npm
    node
    python
    pip
    golang
    rust
    ubuntu
    command-not-found
    colored-man-pages
    extract
    sudo
    web-search
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Zsh History Database
source $HOME/.oh-my-zsh/custom/plugins/zsh-histdb/sqlite-history.zsh
autoload -Uz add-zsh-hook
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor
export EDITOR='lvim'
export VISUAL='lvim'

# PATH configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# ASDF
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Aliases - Modern CLI tools
alias cat='bat'
alias ls='exa --icons'
alias ll='exa -la --icons'
alias la='exa -a --icons'
alias lt='exa --tree --icons'
alias python3='python'
alias vim='lvim'
alias vi='lvim'
alias lg='lazygit'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dex='docker exec -it'

# Utility functions
mkcd() { mkdir -p "$1" && cd "$1"; }
fcd() { cd "$(find . -type d -name "*$1*" | head -n 1)"; }

# WSL2 specific settings
if grep -qi microsoft /proc/version; then
    # Fix for WSL2 clipboard
    export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
    
    # Windows home directory alias
    alias winhome='cd /mnt/c/Users/$(whoami)'
fi

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Directory navigation
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

# Command correction
setopt correct

# Completion system
autoload -Uz compinit
compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Configurar Git
print_status "Configurando Git..."
git config --global core.editor "lvim"
git config --global init.defaultBranch main

# Definir Zsh como shell padrão
if [ "$SHELL" != "/usr/bin/zsh" ] && [ "$SHELL" != "/bin/zsh" ]; then
    print_status "Definindo Zsh como shell padrão..."
    chsh -s $(which zsh)
    print_success "Zsh definido como shell padrão!"
fi

# Criar script de atualização
print_status "Criando script de atualização..."
cat > "$HOME/.local/bin/update-dev-tools" << 'EOF'
#!/bin/bash
echo "Atualizando ferramentas de desenvolvimento..."

# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Atualizar Rust
rustup update

# Atualizar ferramentas Go
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install mvdan.cc/gofumpt@latest

# Atualizar LunarVim
lvim +LvimUpdate +q

# Atualizar npm global packages
npm update -g

echo "Atualização concluída!"
EOF

chmod +x "$HOME/.local/bin/update-dev-tools"

# Resumo final
print_success "Setup concluído com sucesso!"
echo ""
print_info "=== RESUMO DA INSTALAÇÃO ==="
echo "✓ Zsh + Oh My Zsh + Powerlevel10k"
echo "✓ ASDF v0.16.0 + plugins (Python, Go, Node.js, Ruby)"
echo "✓ NVM (Node Version Manager)"
echo "✓ Rust + Cargo"
echo "✓ Neovim + LunarVim"
echo "✓ Ferramentas CLI modernas (bat, exa, ripgrep, fd)"
echo "✓ LazyGit"
echo "✓ Ferramentas de desenvolvimento (linters, formatters)"
echo ""
print_warning "=== PRÓXIMOS PASSOS ==="
echo "1. Reinicie seu terminal ou execute: source ~/.zshrc"
echo "2. Configure o Powerlevel10k: p10k configure"
echo "3. Configure a fonte do terminal: MesloLGS NF"
echo "4. No Windows Terminal, configure a fonte em Settings > Profiles > Defaults > Appearance"
echo "5. Execute 'lvim' para configurar o LunarVim pela primeira vez"
echo "6. Use 'update-dev-tools' para atualizar suas ferramentas"
echo ""
print_info "=== COMANDOS ÚTEIS ==="
echo "• asdf list all python    # Listar versões do Python disponíveis"
echo "• asdf install python latest    # Instalar última versão do Python"
echo "• nvm list-remote    # Listar versões do Node.js"
echo "• cargo install <package>    # Instalar pacotes Rust"
echo "• lvim    # Abrir LunarVim"
echo ""

# Verificar se precisa reiniciar o shell
if [ "$SHELL" != "$(which zsh)" ]; then
    print_warning "Por favor, faça logout e login novamente para usar o Zsh como shell padrão."
fi
