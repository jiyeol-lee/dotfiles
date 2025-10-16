#!/usr/bin/env bash

# Get the current shell name
current_shell=$(basename "$SHELL")

function executeByShell() {
  local zsh_command="$1"
  local bash_command="$2"

  case "$current_shell" in
  zsh)
    echo "Executing zsh command: $zsh_command"
    eval "$zsh_command"
    ;;
  bash)
    echo "Executing bash command: $bash_command"
    eval "$bash_command"
    ;;
  *)
    echo "Error: Unsupported shell '$current_shell'. Only zsh and bash are supported."
    ;;
  esac
}

function installPackages() {
  # Add additional taps
  # ref: https://github.com/Homebrew/homebrew-cask/blob/master/USAGE.md#additional-taps-optional
  # brew tap homebrew/cask-versions

  # Install fonts for 'Hack Nerd Front Mono'
  brew install --cask font-hack-nerd-font

  # Install terraform
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform

  # Install awscli
  brew install awscli

  # Install starship
  brew install starship

  # Install chatgpt
  brew install --cask chatgpt

  # Install notion
  brew install --cask notion

  # Install pngpaste for pasting image to markdown using obsidian.nvim
  brew install pngpaste

  # Install google chrome
  brew install --cask google-chrome

  # Install alfred
  brew install --cask google-drive

  # Install alfred
  brew install --cask alfred

  # Install alacritty
  brew install --cask --no-quarantine alacritty

  # Install slack
  brew install --cask slack

  # Install KeePassXC
  brew install --cask keepassxc

  # Install tmux
  # ref1: https://github.com/tmux/tmux/wiki/Installing
  # ref2: https://github.com/tmux-plugins/tpm
  brew install tmux
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/tpm/

  # Install neovim
  # ref: https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package
  brew install neovim

  # Install podman
  brew install podman

  # Install uv (python package manager)
  brew install uv

  # Install docker-compose
  brew install docker-compose

  # Install nodejs
  brew install node@22

  # Install web dev tools
  brew install prettier

  # Install gh
  brew install gh

  # Install go
  brew install go

  # Install go tools
  brew install golines
  brew install gofumpt

  # Install shell tools
  brew install shellcheck
  brew install shfmt

  # Install lua tools
  brew install stylua

  # Install ripgrep
  brew install ripgrep

  # Install lazygit
  brew install lazygit

  # Install gnu sed
  brew install gnu-sed

  go install github.com/coding-for-fun-org/gcli@latest
}

function doIt() {
  ~/dotfiles/create_config_folders.sh

  # Configure git
  git config --global user.name "Jiyeol Lee"
  git config --global user.email "jiyeol.tech@gmail.com"
  git config --global rerere.enabled true # Enable rerere to make my life easier

  # Install Homebrew.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Create symbolic links
  ~/dotfiles/link_symbolic.sh

  executeByShell \
    "ln -sf ~/dotfiles/.profile ~/.zshrc" \
    "ln -sf ~/dotfiles/.profile ~/.bashrc"
  executeByShell \
    "source ~/.zshrc" \
    "source ~/.bashrc"

  # Make sure we’re using the latest Homebrew.
  brew update
  # Upgrade any already-installed formulae.
  brew upgrade

  installPackages

  executeByShell \
    "source ~/.zshrc" \
    "source ~/.bashrc"
}

doIt

echo "Configurations are done!"
echo "Do not forget to run ':Copilot setup' in neovim!"
echo "Do not forget to run 'Prefix + I' in tmux!"

unset installPackages
unset doIt
