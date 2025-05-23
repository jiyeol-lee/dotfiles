#!/usr/bin/env bash

function installPackages() {
  # Add additional taps
  # ref: https://github.com/Homebrew/homebrew-cask/blob/master/USAGE.md#additional-taps-optional
  # brew tap homebrew/cask-versions

  # Install fonts for 'Hack Nerd Front Mono'
  brew install --cask font-hack-nerd-font

  # Install terraform
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform

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

  # Install docker
  brew install docker docker-compose

  # Install colima
  brew install colima

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
  # Create config directories
  mkdir -p ~/.config/alacritty
  mkdir -p ~/.config/tmux
  mkdir -p ~/.docker

  # Create vault directories
  mkdir -p ~/vaults/vpersonal
  mkdir -p ~/vaults/vwork2
  mkdir -p ~/vaults/vwork3

  # Configure git
  git config --global user.name "Jiyeol Lee"
  git config --global user.email "jiyeol.tech@gmail.com"
  git config --global rerere.enabled true # Enable rerere to make my life easier

  # Install Homebrew.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Create symbolic links
  ln -s ~/dotfiles/.tmux.conf ~/.config/tmux/tmux.conf
  ln -s ~/dotfiles/.shorten_current_path.sh ~/.config/tmux/.__shorten_current_path.sh
  ln -s ~/dotfiles/.activated_gh_account.sh ~/.config/tmux/.__activated_gh_account.sh
  ln -s ~/dotfiles/.alacritty.toml ~/.config/alacritty/alacritty.toml
  ln -s ~/dotfiles/.nvim ~/.config/nvim
  ln -s ~/dotfiles/.aliases ~/.aliases
  ln -s ~/dotfiles/.extras ~/.extras
  ln -s ~/dotfiles/.profile ~/.zshrc
  ln -s ~/dotfiles/.__editorconfig ~/.editorconfig

  source ~/.zshrc

  # Make sure we’re using the latest Homebrew.
  brew update
  # Upgrade any already-installed formulae.
  brew upgrade

  installPackages

  # Configure docker
  echo -e "{\n\t\"cliPluginsExtraDirs\": [\n\t\t\"/opt/homebrew/lib/docker/cli-plugins\"\n\t],\n\t\"currentContext\": \"colima\"\n}" >~/.docker/config.json

  source ~/.zshrc
}

doIt

echo "Configurations are done!"
echo "Do not forget to run ':Copilot setup' in neovim!"
echo "Do not forget to run 'Prefix + I' in tmux!"

unset installPackages
unset doIt
