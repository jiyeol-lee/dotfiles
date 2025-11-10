#!/bin/bash

mkdir -p ~/.config/containers
ln -snf ~/.config/containers/auth.json ~/.config/containers/config.json

mkdir -p ~/.config/tmux
ln -snf ~/dotfiles/.tmux.conf ~/.config/tmux/tmux.conf
ln -snf ~/dotfiles/.activated_gh_account.sh ~/.config/tmux/.__activated_gh_account.sh

mkdir -p ~/.config/alacritty
ln -snf ~/dotfiles/.alacritty.toml ~/.config/alacritty/alacritty.toml

mkdir -p ~/.config/mcphub
ln -snf ~/dotfiles/.mcphub.json ~/.config/mcphub/servers.json
case "$(uname -s)" in
Linux*) ln -snf ~/dotfiles/.alacritty-bindings-nonmacos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
Darwin*) ln -snf ~/dotfiles/.alacritty-bindings-macos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
esac

mkdir -p ~/.config/nvim
ln -snf ~/dotfiles/.nvim ~/.config/nvim

mkdir -p ~/.ssh
ln -snf ~/dotfiles/.ssh_config ~/.ssh/config

ln -snf ~/dotfiles/.__editorconfig ~/.editorconfig
