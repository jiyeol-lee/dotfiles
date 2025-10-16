#!/bin/bash

ln -snf ~/.config/containers/auth.json ~/.config/containers/config.json
ln -snf ~/dotfiles/.tmux.conf ~/.config/tmux/tmux.conf
ln -snf ~/dotfiles/.activated_gh_account.sh ~/.config/tmux/.__activated_gh_account.sh
ln -snf ~/dotfiles/.alacritty.toml ~/.config/alacritty/alacritty.toml
ln -snf ~/dotfiles/.mcphub.json ~/.config/mcphub/servers.json
case "$(uname -s)" in
Linux*) ln -snf ~/dotfiles/.alacritty-bindings-nonmacos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
Darwin*) ln -snf ~/dotfiles/.alacritty-bindings-macos.toml ~/.config/alacritty/alacritty-bindings.toml ;;
esac

ln -snf ~/dotfiles/.nvim ~/.config/nvim
ln -snf ~/dotfiles/.__editorconfig ~/.editorconfig
ln -snf ~/dotfiles/.ssh_config ~/.ssh/config
