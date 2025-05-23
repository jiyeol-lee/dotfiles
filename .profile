(cd ~/dotfiles && make load-secrets)

# Load the shell dotfiles, and then some:
for file in ~/.{extras,exports,exports-overwrite,aliases}; do
	if [ -f "$file" ]; then
		# shellcheck disable=SC1090
		source "$file"
	fi
done
unset file
