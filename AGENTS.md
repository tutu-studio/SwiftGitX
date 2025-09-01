# Repository Guidelines

## Project Structure & Modules
- `Package.swift`: Swift Package definition (targets, dependencies, plugins).
- `Sources/SwiftGitX/`: Library source (Swift wrapper over libgit2).
- `Tests/SwiftGitXTests/`: XCTest test suite; see `SwiftGitX.xctestplan` for Xcode.
- `.github/workflows/`: CI for build/test and DocC documentation.
- Tooling configs: `.swiftlint.yml`, `.swiftformat`, `.spi.yml`.

## Build, Test, and Docs
- Build: `swift build` — compiles the `SwiftGitX` library.
- Test: `swift test -v` — runs all XCTest tests.
- Resolve deps: `swift package resolve` — fetches/locks dependencies.
- Clean: `swift package clean` — clears build artifacts.
- Docs (local): `swift package --allow-writing-to-directory .docs generate-documentation --target SwiftGitX --output-path .docs` — builds DocC into `.docs/`.

## Coding Style & Conventions
- Swift 5.8+; target platforms: macOS 11+, iOS 13+.
- Formatting: configured via `.swiftformat` (max width 120, wrap parameters before first). Run: `swiftformat .`.
- Linting: configured via `.swiftlint.yml` (SPM `.build/` excluded). Run: `swiftlint` (and optionally `swiftlint --fix`).
- Naming: types `UpperCamelCase`, methods/properties `lowerCamelCase`, constants `lowerCamelCase`.
- Public API: prefer `struct`/`enum` over `class` when possible; throw errors instead of returning optionals for failure.

## Testing Guidelines
- Framework: XCTest. Place tests under `Tests/SwiftGitXTests/`.
- Names: file `*Tests.swift`; functions start with `test...()` and describe behavior (e.g., `testCloneRepository()`).
- Coverage: add tests for new public APIs and bug fixes; include happy-path and failure cases.
- Run: `swift test -v` locally and rely on CI to verify on PRs.

## Commit & Pull Requests
- Commit style: short, imperative subject (e.g., "Fix build on Xcode 16"). Group logical changes; keep noise low.
- Before PR: run format + lint + tests; update docs if API changes.
- PR description: summary, rationale, linked issues, notable API changes, and test notes. Add screenshots only if relevant to docs.
- CI: GitHub Actions runs build/tests on macOS; PRs must be green before merge.

## Notes & Tips
- libgit2: linked via SPM dependency `ibrahimcetin/libgit2`. Avoid direct C APIs in public surface.
- Documentation: prefer DocC comments on public types/methods to keep generated docs useful.
