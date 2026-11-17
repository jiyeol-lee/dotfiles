// Command worktree manages git worktrees under $HOME/worktree/<repo>/<slug>.
package main

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const usage = `usage: worktree <command> [args]

commands:
  create <slug> [--base <ref>] [--detach]  create a worktree and copy .env files into it
  remove <slug|path> [--force]             remove a worktree
  list                                     list worktrees as "<path> <branch>"
  prune                                    prune stale worktree entries`

func main() {
	if len(os.Args) < 2 {
		fail(errors.New(usage))
	}

	var err error
	switch os.Args[1] {
	case "create":
		err = create(os.Args[2:])
	case "remove":
		err = remove(os.Args[2:])
	case "list":
		err = list()
	case "prune":
		_, err = git("worktree", "prune")
	default:
		err = fmt.Errorf("unknown command %q\n\n%s", os.Args[1], usage)
	}
	if err != nil {
		fail(err)
	}
}

func create(args []string) error {
	var slug, base string
	detach := false
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--detach":
			detach = true
		case "--base":
			if i+1 >= len(args) {
				return errors.New("--base needs a ref")
			}
			i++
			base = args[i]
		default:
			if slug != "" {
				return fmt.Errorf("unexpected argument %q\n\n%s", args[i], usage)
			}
			slug = args[i]
		}
	}
	if slug == "" {
		return fmt.Errorf("create needs a slug\n\n%s", usage)
	}

	source, err := git("rev-parse", "--show-toplevel")
	if err != nil {
		return err
	}
	target, err := worktreePath(slug)
	if err != nil {
		return err
	}
	if _, err := os.Stat(target); err == nil {
		return fmt.Errorf("worktree path already exists: %s", target)
	}

	if err := addWorktree(target, slug, base, detach); err != nil {
		return err
	}

	copied, err := copyEnvFiles(source, target)
	if err != nil {
		return err
	}

	fmt.Println(target)
	if len(copied) == 0 {
		fmt.Println("copied no .env files")
	} else {
		fmt.Printf("copied %s\n", strings.Join(copied, ", "))
	}
	return nil
}

func addWorktree(target, slug, base string, detach bool) error {
	if base == "" {
		base = "HEAD"
	}
	if detach {
		_, err := git("worktree", "add", "--detach", target, base)
		return err
	}

	if _, err := git("show-ref", "--verify", "--quiet", fmt.Sprintf("refs/heads/%s", slug)); err == nil {
		if base != "HEAD" {
			return fmt.Errorf("branch %s already exists, so --base %s cannot apply", slug, base)
		}
		_, err := git("worktree", "add", target, slug)
		return err
	}

	_, err := git("worktree", "add", "-b", slug, target, base)
	return err
}

// copyEnvFiles copies every .env and .env.* file under source to the same relative path under
// target, skipping files the checkout already has.
func copyEnvFiles(source, target string) ([]string, error) {
	var copied []string
	err := filepath.WalkDir(source, func(path string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() {
			if entry.Name() == ".git" || entry.Name() == "node_modules" {
				return filepath.SkipDir
			}
			return nil
		}
		if !entry.Type().IsRegular() || !isEnvFile(entry.Name()) {
			return nil
		}

		rel, err := filepath.Rel(source, path)
		if err != nil {
			return err
		}
		dst := filepath.Join(target, rel)
		if _, err := os.Stat(dst); err == nil {
			return nil
		}
		if err := copyFile(path, dst); err != nil {
			return err
		}
		copied = append(copied, rel)
		return nil
	})
	return copied, err
}

func isEnvFile(name string) bool {
	return name == ".env" || strings.HasPrefix(name, ".env.")
}

func copyFile(src, dst string) error {
	info, err := os.Stat(src)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return err
	}

	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()

	out, err := os.OpenFile(dst, os.O_WRONLY|os.O_CREATE|os.O_EXCL, info.Mode().Perm())
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	return out.Close()
}

func remove(args []string) error {
	var target string
	force := false
	for _, arg := range args {
		if arg == "--force" {
			force = true
			continue
		}
		if target != "" {
			return fmt.Errorf("unexpected argument %q\n\n%s", arg, usage)
		}
		target = arg
	}
	if target == "" {
		return fmt.Errorf("remove needs a slug or path\n\n%s", usage)
	}

	if !strings.ContainsRune(target, filepath.Separator) {
		path, err := worktreePath(target)
		if err != nil {
			return err
		}
		target = path
	}

	removeArgs := []string{"worktree", "remove"}
	if force {
		removeArgs = append(removeArgs, "--force")
	}
	if _, err := git(append(removeArgs, target)...); err != nil {
		return err
	}
	if _, err := git("worktree", "prune"); err != nil {
		return err
	}

	fmt.Printf("removed %s\n", target)
	return nil
}

func list() error {
	out, err := git("worktree", "list", "--porcelain")
	if err != nil {
		return err
	}

	for _, block := range strings.Split(out, "\n\n") {
		var path, ref string
		prunable := false
		for _, line := range strings.Split(block, "\n") {
			switch {
			case strings.HasPrefix(line, "worktree "):
				path = strings.TrimPrefix(line, "worktree ")
			case strings.HasPrefix(line, "branch "):
				ref = strings.TrimPrefix(line, "branch refs/heads/")
			case line == "detached":
				ref = "(detached)"
			case line == "bare":
				ref = "(bare)"
			case strings.HasPrefix(line, "prunable"):
				prunable = true
			}
		}
		if path == "" {
			continue
		}
		if prunable {
			ref = fmt.Sprintf("%s (prunable)", ref)
		}
		fmt.Printf("%s %s\n", path, ref)
	}
	return nil
}

// worktreePath returns $HOME/worktree/<repo>/<slug>, where <repo> is the main checkout's
// directory name, so worktrees made from other worktrees land beside each other.
func worktreePath(slug string) (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	common, err := git("rev-parse", "--path-format=absolute", "--git-common-dir")
	if err != nil {
		return "", err
	}

	repo := strings.TrimSuffix(filepath.Base(common), ".git")
	if repo == "" {
		repo = filepath.Base(filepath.Dir(common))
	}
	return filepath.Join(home, "worktree", repo, slug), nil
}

func git(args ...string) (string, error) {
	var stdout, stderr bytes.Buffer
	cmd := exec.Command("git", args...)
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		return "", fmt.Errorf("git %s: %s", strings.Join(args, " "), strings.TrimSpace(stderr.String()))
	}
	return strings.TrimSpace(stdout.String()), nil
}

func fail(err error) {
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}
