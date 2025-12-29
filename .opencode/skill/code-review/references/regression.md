# Regression Review Checklist

## API & Interface Stability

- [ ] Public function/method signatures unchanged (or versioned)
- [ ] Component props/inputs backward compatible
- [ ] Return types and response schemas backward compatible
- [ ] Default parameter values preserved
- [ ] Error codes and messages stable
- [ ] Deprecation warnings before removal

## Behavior

- [ ] Existing functionality still works
- [ ] Side effects unchanged
- [ ] Event/callback order preserved
- [ ] Configuration defaults unchanged
- [ ] UI/UX behavior consistent
- [ ] State management patterns preserved

## Data & Resources

- [ ] Database migrations reversible
- [ ] Existing data remains valid
- [ ] Cache invalidation handled
- [ ] No data loss scenarios
- [ ] Resource renames handled safely (moved blocks, redirects)
- [ ] Infrastructure changes don't break dependent services
