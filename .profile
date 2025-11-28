# Load the shell dotfiles, and then some:
for file in ~/dotfiles/.{extras,default-exports,override-exports,aliases}; do
  if [ -f "$file" ]; then
    # shellcheck disable=SC1090
    source "$file"
  fi
done
unset file

# This could be called from bootstrap.sh for the first time setup
# and then from .profile for subsequent logins.
# It doesn't hurt to run it multiple times.
# This can prevent issues when the dotfiles are updated
~/dotfiles/scripts/git_config.sh
~/dotfiles/scripts/create_config_folders.sh
~/dotfiles/scripts/link_symbolic.sh
