# Performance Review Checklist

## Computation

- [ ] No unnecessary work in loops
- [ ] Expensive operations cached/memoized
- [ ] Appropriate data structures used
- [ ] Algorithms have reasonable complexity
- [ ] Rendering optimized (no unnecessary re-renders)
- [ ] Bundle size impact considered

## Resources

- [ ] Database queries optimized (no N+1)
- [ ] Connections/handles cleaned up
- [ ] Memory leaks prevented
- [ ] Large datasets paginated/streamed
- [ ] Infrastructure right-sized
- [ ] Cost implications considered

## Async & Network

- [ ] Independent operations parallelized
- [ ] No blocking calls in async context
- [ ] Timeouts configured for external calls
- [ ] Caching strategy appropriate
- [ ] Network requests minimized/batched
