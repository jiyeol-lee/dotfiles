package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"time"
)

const target = ".opencode/command/explain-diff.md"

var (
	semver = `(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)`
	client = &http.Client{Timeout: 30 * time.Second}
)

type dependency struct {
	name        string
	registryURL string
	patterns    []string
}

func main() {
	contents, err := os.ReadFile(target)
	check(err)

	dependencies := []dependency{
		{
			name:        "@tailwindcss/browser",
			registryURL: "https://registry.npmjs.org/@tailwindcss%2Fbrowser/latest",
			patterns: []string{
				`https://cdn\.jsdelivr\.net/npm/@tailwindcss/browser@(` + semver + `)"`,
			},
		},
		{
			name:        "highlight.js",
			registryURL: "https://registry.npmjs.org/highlight.js/latest",
			patterns: []string{
				`https://cdn\.jsdelivr\.net/gh/highlightjs/cdn-release@(` + semver + `)/build/styles/dark\.min\.css"`,
				`https://cdn\.jsdelivr\.net/gh/highlightjs/cdn-release@(` + semver + `)/build/highlight\.min\.js"`,
			},
		},
		{
			name:        "mermaid",
			registryURL: "https://registry.npmjs.org/mermaid/latest",
			patterns: []string{
				`https://cdn\.jsdelivr\.net/npm/mermaid@(` + semver + `)/\+esm"`,
			},
		},
	}

	for _, dep := range dependencies {
		version := versionInFile(dep, contents)
		latest := registryLatest(dep)
		if version != latest {
			fail("%s is pinned to %s, but npm latest is %s", dep.name, version, latest)
		}
	}

	cdnPattern := regexp.MustCompile(`https://cdn\.jsdelivr\.net/[^"\s]+`)
	urls := cdnPattern.FindAllString(string(contents), -1)
	if len(urls) != 4 {
		fail("expected exactly four jsDelivr resources, found %d", len(urls))
	}
	for _, url := range urls {
		validateURL(url)
	}
}

func versionInFile(dep dependency, contents []byte) string {
	var version string
	for _, pattern := range dep.patterns {
		matches := regexp.MustCompile(pattern).FindAllSubmatch(contents, -1)
		if len(matches) != 1 {
			fail("expected exactly one %s reference matching %q, found %d", dep.name, pattern, len(matches))
		}
		current := string(matches[0][1])
		if version != "" && current != version {
			fail("%s references are not synchronized: %s and %s", dep.name, version, current)
		}
		version = current
	}
	return version
}

func registryLatest(dep dependency) string {
	request, err := http.NewRequest(http.MethodGet, dep.registryURL, nil)
	check(err)
	request.Header.Set("User-Agent", "dotfiles-dependency-validator")

	response, err := client.Do(request)
	check(err)
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		fail("npm registry returned %s for %s", response.Status, dep.name)
	}

	var metadata struct {
		Version string `json:"version"`
	}
	check(json.NewDecoder(response.Body).Decode(&metadata))
	if !regexp.MustCompile(`^` + semver + `$`).MatchString(metadata.Version) {
		fail("npm latest for %s is not a stable exact semver: %q", dep.name, metadata.Version)
	}
	return metadata.Version
}

func validateURL(url string) {
	request, err := http.NewRequest(http.MethodGet, url, nil)
	check(err)
	request.Header.Set("Range", "bytes=0-0")
	request.Header.Set("User-Agent", "dotfiles-dependency-validator")

	response, err := client.Do(request)
	check(err)
	defer response.Body.Close()
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		fail("CDN returned %s for %s", response.Status, url)
	}

	bytesRead, err := io.Copy(io.Discard, io.LimitReader(response.Body, 1))
	check(err)
	if bytesRead != 1 {
		fail("CDN returned an empty resource for %s", url)
	}
}

func check(err error) {
	if err != nil {
		fail("%v", err)
	}
}

func fail(format string, args ...any) {
	fmt.Fprintf(os.Stderr, format+"\n", args...)
	os.Exit(1)
}
