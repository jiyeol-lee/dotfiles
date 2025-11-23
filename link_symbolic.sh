#!/bin/bash

mkdir -p ~/.config/containers
ln -snf ~/.config/containers/auth.json ~/.config/containers/config.json

mkdir -p ~/.config/opencode
ln -snf ~/dotfiles/.opencode/opencode.json ~/.config/opencode/opencode.json
ln -snf ~/dotfiles/.opencode/themes ~/.config/opencode/themes
ln -snf ~/dotfiles/.opencode/agent ~/.config/opencode/agent
ln -snf ~/dotfiles/.opencode/command ~/.config/opencode/command
ln -snf ~/dotfiles/.opencode/AGENTS.md ~/.config/opencode/AGENTS.md

mkdir -p ~/.config/tmux
ln -snf ~/dotfiles/.tmux.conf ~/.config/tmux/tmux.conf
ln -snf ~/dotfiles/.activated_gh_account.sh ~/.config/tmux/.__activated_gh_account.sh

mkdir -p ~/.config/alacritty
ln -snf ~/dotfiles/.alacritty.toml ~/.config/alacritty/alacritty.toml

case "$(uname -s)" in
Linux*) ln -snf ~/dotfiles/.alacritty-bindings-nonmacos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
Darwin*) ln -snf ~/dotfiles/.alacritty-bindings-macos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
esac

mkdir -p ~/.config/nvim
ln -snf ~/dotfiles/.nvim ~/.config/nvim

mkdir -p ~/.ssh
ln -snf ~/dotfiles/.ssh_config ~/.ssh/config

ln -snf ~/dotfiles/.__editorconfig ~/.editorconfig
