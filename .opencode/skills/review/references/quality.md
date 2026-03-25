# Quality Review Checklist

## Security

- [ ] No hardcoded secrets or credentials
- [ ] Secrets not in code, config files, or environment defaults
- [ ] Input validated at trust boundaries
- [ ] No injection vulnerabilities (SQL, command, XSS, etc.)
- [ ] Authentication checked before authorization
- [ ] Sensitive data not logged or exposed
- [ ] Dependencies free of known vulnerabilities
- [ ] No sensitive data in client-side storage

## Correctness

- [ ] Null/undefined/empty cases handled
- [ ] Boundary values considered
- [ ] Error handling at appropriate level
- [ ] Race conditions considered for async code
- [ ] Idempotency for retryable operations
- [ ] Edge cases covered
- [ ] State transitions valid
- [ ] Resource cleanup on error paths

## Maintainability

- [ ] Single responsibility principle followed
- [ ] No copy-paste duplication (DRY)
- [ ] Clear, descriptive naming
- [ ] Reasonable complexity (no deep nesting)
- [ ] Dead code removed
- [ ] No commented-out code
- [ ] Consistent patterns with codebase
- [ ] Proper separation of concerns
