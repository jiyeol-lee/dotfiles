#!/usr/bin/env bash

function installPackages() {
  # Install Homebrew.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  source ~/.zshrc

  # Make sure we’re using the latest Homebrew.
  brew update

  # Upgrade any already-installed formulae.
  brew upgrade

  # Add additional taps
  # ref: https://github.com/Homebrew/homebrew-cask/blob/master/USAGE.md#additional-taps-optional
  # brew tap homebrew/cask-versions

  # Install fonts for 'Hack Nerd Front Mono'
  brew install --cask font-hack-nerd-font

  # Install powerlevel10k
  brew install powerlevel10k

  # Install chatgpt
  brew install --cask chatgpt

  # Install figma
  brew install --cask figma

  # Install notion
  brew install --cask notion

  # Install brave browser
  # brew install --cask brave-browser

  # Install google chrome
  brew install --cask google-chrome

  # Install firefox developer edition
  # brew install --cask firefox@developer-edition

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
  brew install node@20

  # Install yarn -- must be installed after nodejs
  brew install yarn

  # Install gh
  brew install gh

  # Install go
  brew install go

  # Install go tools
  brew install golines
  brew install gofumpt

  # Install ripgrep
  brew install ripgrep

  # Install lazygit
  brew install lazygit

  # Install gnu sed
  brew install gnu-sed
}

function doIt() {
  # Create config directories
  mkdir -p ~/.config/alacritty
  mkdir -p ~/.config/tmux
  mkdir -p ~/.docker

  installPackages;

  # Configure git
  git config --global user.name "Jiyeol Lee"
  git config --global user.email "ka.felix496@gmail.com"
  git config --global rerere.enabled true # Enable rerere to make my life easier

  # Create symbolic links
  ln -s ~/dotfiles/.tmux.conf ~/.config/tmux/tmux.conf
  ln -s ~/dotfiles/.shorten_current_path.sh ~/.config/tmux/.__shorten_current_path.sh
  ln -s ~/dotfiles/.activated_gh_account.sh ~/.config/tmux/.__activated_gh_account.sh
  ln -s ~/dotfiles/.alacritty.toml ~/.config/alacritty/alacritty.toml
  ln -s ~/dotfiles/.nvim ~/.config/nvim
  ln -s ~/dotfiles/.p10k.zsh ~/.p10k.zsh
  ln -s ~/dotfiles/.aliases ~/.aliases
  ln -s ~/dotfiles/.exports ~/.exports
  ln -s ~/dotfiles/.extras ~/.extras
  ln -s ~/dotfiles/.profile ~/.zshrc

  # Configure docker
  echo -e "{\n\t\"cliPluginsExtraDirs\": [\n\t\t\"/opt/homebrew/lib/docker/cli-plugins\"\n\t],\n\t\"currentContext\": \"colima\"\n}" > ~/.docker/config.json
  
  source ~/.zshrc
}

doIt;

echo "Configurations are done!";
echo "Do not forget to run ':Copilot setup' in neovim!";
echo "Do not forget to run 'Prefix + I' in tmux!";

unset installPackages;
unset doIt;
