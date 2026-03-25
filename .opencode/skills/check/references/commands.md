# Common Commands Reference

This reference contains common validation commands used during code quality checks.

## JavaScript/TypeScript

| Category       | Commands                                               |
| -------------- | ------------------------------------------------------ |
| **Formatters** | `prettier --write`, `npx prettier --write`             |
| **Linters**    | `eslint`, `npx eslint`, `prettier --check`             |
| **Type Check** | `tsc`, `npx tsc`, `tsc --noEmit`                       |
| **Tests**      | `jest`, `vitest`, `npm test`, `yarn test`, `pnpm test` |

## Go

| Category       | Commands                             |
| -------------- | ------------------------------------ |
| **Formatters** | `go fmt`, `gofmt`, `gofmt -w`        |
| **Linters**    | `golangci-lint`, `golangci-lint run` |
| **Type Check** | (built-in with compiler)             |
| **Tests**      | `go test`                            |

## Python

| Category       | Commands                                                  |
| -------------- | --------------------------------------------------------- |
| **Formatters** | `black`, `ruff format`, `poetry run black`                |
| **Linters**    | `ruff check`, `flake8`, `pylint`, `poetry run ruff check` |
| **Type Check** | `mypy`, `pyright`, `poetry run mypy`                      |
| **Tests**      | `pytest`, `poetry run pytest`                             |
