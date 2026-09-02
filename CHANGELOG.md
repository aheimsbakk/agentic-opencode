# Changelog

## [v0.2.3] - 2026-09-02

- **why:** Restructure project rules for agent reliability and require explicit commit consent
- **model:** z-ai/glm-5.3-flash
- **tags:** docs, rules

### Changed

- Rewrote `.opencode/RULES.md`: merged layer, presentation, and state rules into `Layer Boundaries` and `State Ownership & Concurrency`, added `Verification Gate` and `Commit Consent`, removed `Protocol Alignment`
- Removed the Builder-to-QA handoff trigger from the wrap-up skill so commits require a direct user request

## [v0.2.2] - 2026-07-29

- **why:** Add intent-based commenting rule to project rules
- **model:** kompis/gemma-4-26b
- **tags:** docs, rules

### Added

- Rule 27 for intent-based commenting in `.opencode/RULES.md`

## [v0.2.1] - 2026-07-19

- **why:** Disable Playwright MCP server
- **model:** qwen-3.6-think-coding-mtp
- **tags:** mcp, playwright, config

### Changed

- Commented out Playwright MCP server configuration in `opencode.json`

## [v0.2.0] - 2026-07-18

- **why:** Add Playwright MCP server for browser automation
- **model:** opencode/deepseek-v4-flash-free
- **tags:** mcp, playwright, config

### Added

- Playwright MCP server configuration to `opencode.json` — enables browser automation via the `@playwright/mcp` package

### Changed

- `autoupdate` set to `false` in `opencode.json` to prevent automatic update notifications

## [v0.1.5] - 2026-07-05

- **why:** Fix documentation casing and file formatting
- **model:** qwen-3.6-think-coding
- **tags:** docs, formatting

### Fixed

- Capitalized `CODEBASE.md` in AGENTS.md synchronization protocol
- Added missing trailing newline to `.opencode/agents/vibe.md`

## [v0.1.4] - 2026-06-07

- **why:** Replace separate worklog files with standardized CHANGELOG.md entries per Keep a Changelog format
- **model:** opencode/deepseek-v4-flash
- **tags:** wrap-up, skill, changelog, documentation

### Changed

- Rewrote `.opencode/skills/wrap-up/SKILL.md` to prepend CHANGELOG.md entries instead of creating standalone worklog files in `docs/worklogs/`
- Updated execution sequence: worklog step replaced by "prepend changelog entry to CHANGELOG.md"
- Updated staging rules to include `CHANGELOG.md` in architecture files list

### Added

- `scripts/bump-version.sh` — version bumping utility supporting patch/minor/major
- `scripts/validate-changelog.sh` — validates CHANGELOG.md structure and metadata presence
- `VERSION` file — single-source version tracking
