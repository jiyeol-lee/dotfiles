#!/bin/bash

# Function to create symbolic links idempotently
# Arguments: source_path destination_path
link_file() {
  local source="$1"
  local dest="$2"

  # Check if dest is already a symlink
  if [ -L "$dest" ]; then
    # Check if it points to the correct source
    local current_target
    current_target=$(readlink "$dest")

    if [ "$current_target" == "$source" ]; then
      # Already correct, do nothing
      return
    fi
  fi

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$dest")"

  # If dest exists (and is not the correct link), remove it
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    rm -rf "$dest"
  fi

  # Create the link
  ln -s "$source" "$dest"
}

link_file "$HOME/dotfiles/.opencode" "$HOME/.config/opencode"

link_file "$HOME/dotfiles/.tmux" "$HOME/.config/tmux"

link_file "$HOME/dotfiles/.alacritty" "$HOME/.config/alacritty"

link_file "$HOME/dotfiles/.nvim" "$HOME/.config/nvim"

link_file "$HOME/dotfiles/.ssh/config" "$HOME/.ssh/config"

link_file "$HOME/dotfiles/.editorconfig" "$HOME/.editorconfig"

# Dynamic Alacritty bindings
target_binding=""
case "$(uname -s)" in
Linux*) target_binding="key-bindings-nonmacos.toml" ;;
Darwin*) target_binding="key-bindings-macos.toml" ;;
esac

if [ -n "$target_binding" ]; then
  # Link inside the repo folder (which is linked to config)
  # We use ln -sf to force creation/update of the symlink
  ln -sf "$target_binding" "$HOME/dotfiles/.alacritty/key-bindings.toml"
fi

unset link_file
