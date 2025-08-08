#!/bin/bash

ln -sf ~/dotfiles/.tmux.conf ~/.config/tmux/tmux.conf
ln -sf ~/dotfiles/.activated_gh_account.sh ~/.config/tmux/.__activated_gh_account.sh
ln -sf ~/dotfiles/.alacritty.toml ~/.config/alacritty/alacritty.toml
case "$(uname -s)" in
Linux*) ln -sf ~/dotfiles/.alacritty-bindings-nonmacos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
Darwin*) ln -sf ~/dotfiles/.alacritty-bindings-macos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
esac

ln -sf ~/dotfiles/.nvim ~/.config/nvim
ln -sf ~/dotfiles/.__editorconfig ~/.editorconfig
ln -sf ~/dotfiles/.ssh_config ~/.ssh/config
