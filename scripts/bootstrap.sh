#!/usr/bin/env bash

current_os=$(uname -s)

function installMacOSPackages() {
  # Install bash shell
  brew install bash

  # Install fonts for 'FiraCode Nerd Font'
  brew install --cask font-fira-code-nerd-font

  # Install terraform
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform

  # Install awscli
  brew install awscli

  # Install oh-my-posh
  brew install oh-my-posh

  # Install sox for audio recording in https://github.com/jiyeol-lee/voice-dictate
  brew install sox

  # Install opencode
  brew install anomalyco/tap/opencode

  # Install gum
  brew install gum

  # Install pass
  brew install pass

  # Install pngpaste for pasting image to markdown using obsidian.nvim
  brew install pngpaste

  # Install luacheck
  brew install luacheck

  # Install firefox
  brew install --cask firefox

  # Install alfred
  brew install --cask alfred

  # Install alacritty
  brew install --cask --no-quarantine alacritty

  # Install tmux
  # ref1: https://github.com/tmux/tmux/wiki/Installing
  # ref2: https://github.com/tmux-plugins/tpm
  brew install tmux
  # git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/tpm/
  git clone https://github.com/tmux-plugins/tpm ~/dotfiles/.tmux/tpm

  # Install neovim
  # ref: https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-package
  brew install neovim

  # Install podman
  brew install podman

  # Install nodejs
  brew install node@24

  # Install web dev tools
  brew install prettier

  # Install gh
  brew install gh

  # Install go
  brew install go

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

  # For personal cli tools
  go install github.com/jiyeol-lee/cli/cmd/cli@latest
}

function installLinuxPackages() {
  sudo dnf install golang -y

  sudo dnf install opentofu -y

  sudo dnf install awscli2 -y

  sudo dnf install fira-code-fonts -y

  sudo dnf install oh-my-posh -y

  # This is for audio recording in https://github.com/jiyeol-lee/voice-dictate
  # remove it when opencode supports
  sudo dnf install sox -y

  sudo dnf install pass -y

  sudo dnf install alacritty -y

  # ref1: https://github.com/tmux/tmux/wiki/Installing
  # ref2: https://github.com/tmux-plugins/tpm
  sudo dnf install tmux -y
  # git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/tpm/
  git clone https://github.com/tmux-plugins/tpm ~/dotfiles/.tmux/tpm

  sudo dnf install neovim -y

  sudo dnf install gh -y

  sudo dnf install ShellCheck -y

  sudo dnf install shfmt -y

  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz | tar -xJ -C ~/.local/share/fonts
  fc-cache -fv

  # For personal cli tools
  go install github.com/jiyeol-lee/cli/cmd/cli@latest
}

function doIt() {
  ~/dotfiles/scripts/create_config_folders.sh

  if [[ "$current_os" == "Darwin" ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Create symbolic links
  ~/dotfiles/scripts/link_symbolic.sh

  case "$current_os" in
  Darwin)
    ln -sf ~/dotfiles/.profile ~/.zshrc

    source ~/.zshrc

    brew update
    brew upgrade

    installMacOSPackages

    source ~/.zshrc
    ;;
  Linux)
    ln -sf ~/dotfiles/.profile ~/.bashrc

    source ~/.bashrc

    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat fedora_layout.js)"
    ./bootstrap_fedora_keyboard.sh

    sudo dnf update -y

    installLinuxPackages

    source ~/.bashrc
    ;;
  esac
}

doIt

echo "Configurations are done!"
echo "Do not forget to run ':Copilot setup' in neovim!"
echo "Do not forget to run 'Prefix + I' in tmux!"

unset installMacOSPackages
unset doIt
