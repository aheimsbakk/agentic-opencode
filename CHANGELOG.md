# Changelog

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
