---
"@ai-hero/sandcastle": patch
---

Bundle Sandcastle with `tsup` and move all Effect packages (`effect`, `@effect/cli`, `@effect/platform`, `@effect/platform-node`, `@effect/printer`, `@effect/printer-ansi`) from `dependencies` to `devDependencies`. The Effect runtime is now inlined into the published JS bundle, so consumers no longer transitively install ~72 MB of Effect packages.

To enforce that Effect never leaks into the public type surface, the build now strips `@internal` declarations from emitted `.d.ts` files (`stripInternal: true`), `CwdError`'s public type was reshaped to a plain `Error` subclass (the runtime class is unchanged — `instanceof CwdError` still works), and a CI script (`scripts/check-public-types-effect-free.mjs`) fails the build if any bundled `.d.ts` references `effect` or `@effect/*`.

`@effect/vitest` was removed (it wasn't imported anywhere).
