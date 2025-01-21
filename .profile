# Load the shell dotfiles, and then some:
for file in ~/.{extras,exports,aliases}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file
