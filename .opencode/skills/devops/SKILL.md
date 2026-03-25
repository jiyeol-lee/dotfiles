---
name: devops
description: Handles CI/CD configurations, containerization, deployment scripts, and infrastructure as code. Use when asked to "set up CI/CD", "create a pipeline", "write a Dockerfile", "configure deployment", "add GitHub Actions", "write Terraform", or "set up infrastructure".
---

## Quick Start

- Writes CI/CD configurations (GitHub Actions, GitLab CI, Jenkins)
- Creates and updates Dockerfiles and container configurations
- Configures deployment scripts and automation
- Manages environment configurations
- Writes Infrastructure as Code (Terraform, CloudFormation, CDK, Pulumi)

## Workflow

1. **Understand** the infrastructure requirement and target environment
2. **Check existing config** — read current CI/CD, Docker, IaC files to follow established patterns
3. **Implement** the configuration changes
4. **Validate** using the appropriate linter/checker (see table below)
5. **Assess deployment impact** (see assessment below)
6. **Report** changes and any breaking/security concerns

## Example: Creating a GitHub Actions CI Workflow

```
Requirement: Add CI pipeline for a Node.js project with lint, test, and build

Step 1 — Check existing config:
  Read package.json for scripts: lint, test, build
  No existing .github/workflows/ directory

Step 2 — Create .github/workflows/ci.yml:
  name: CI
  on:
    push:
      branches: [main]
    pull_request:
      branches: [main]
  jobs:
    ci:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version-file: '.node-version'
            cache: 'npm'
        - run: npm ci
        - run: npm run lint
        - run: npm run test
        - run: npm run build

Step 3 — Validate:
  $ actionlint .github/workflows/ci.yml
  ✓ No errors

Step 4 — Impact assessment:
  - Requires redeploy: No (CI config only)
  - Affected services: None (new pipeline)
  - Breaking changes: None
  - Downtime risk: None
```

## Validation Commands

MUST validate config files before reporting completion:

| File Type      | Validation Command                             |
| -------------- | ---------------------------------------------- |
| YAML           | `yamllint <file>` or syntax check              |
| Dockerfile     | `docker build --check` or `hadolint <file>`    |
| Terraform      | `terraform validate` or `terraform fmt -check` |
| CloudFormation | `aws cloudformation validate-template`         |
| GitHub Actions | `actionlint <file>`                            |
| Shell scripts  | `shellcheck <file>`                            |

If the validation tool is not installed, note it in the report and proceed.

## Deployment Impact Assessment

Evaluate and report ALL of the following for every change:

1. **Requires Redeploy**: Will this change require service restart/redeploy?
2. **Affected Services**: Which services/components are impacted?
3. **Breaking Changes**: Are there backwards-incompatible changes?
4. **Downtime Risk**: Could this cause service interruption?

## Constraints (Never Allowed)

- Hardcoding credentials, API keys, or secrets (use environment variables or secret managers)
- Disabling security features without explicit user approval
- Direct production deployments (always stage first or require approval)
- Using sed/perl/awk/tr for multi-file replacements (use grep + edit)
- Removing existing CI checks without explicit approval

## Always Report

- Breaking changes to deployment or infrastructure
- Security configuration changes (IAM, network, secrets)
- Changes that require manual steps (migrations, DNS updates, etc.)
