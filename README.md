# agentic-opencode

A ready-to-use agent and skill template for [OpenCode](https://opencode.ai) — drop it into any project to get structured agents, reusable skills, an autonomous loop, and a one-command update path.

## What it includes

- **4 agents** — specialized AI personas for coding, research, reflection, and Linux expertise
- **5 skills** — reusable instruction sets the agents load on demand
- **Ralph loop** — an autonomous iteration plugin that feeds a prompt back until a task is done
- **`update.sh`** — one script to fetch or refresh all template files from GitHub

## Quick start

Fetch all template files into your project with a single `curl` command:

```bash
curl -fsSL https://raw.githubusercontent.com/aheimsbakk/agentic-opencode/main/.opencode/update.sh | bash
```

Then update at any time by running:

```bash
./.opencode/update.sh
```

## Agents

Agents are AI personas stored in `.opencode/agents/`. Each agent has a focused scope and a distinct set of allowed tools. Switch agents inside OpenCode to match your current task.

### Vibe — pair programmer

The default interactive coding partner. Reads `AGENTS.md` and `RULES.md` at the start of every session, then works through the full development lifecycle: architecture → implementation → testing → wrap-up. Uses all tools. Loads the `wrap-up` skill when you say "wrap up" or "commit".

```
Mode: primary | Tools: all (except question, external_directory)
```

### Facts — technical researcher

A zero-filler technical analyst. Enforces strict citation rules: it only calls `webfetch` for recent CVEs, undocumented API behaviors, or framework versions released in the last 24 months, and limits itself to two fetches per query. Unverified claims get an explicit Accuracy Probability Score (APS) instead of a guess.

```
Mode: primary | Tools: webfetch only
```

### Linux Expert — systems sounding board

A senior advisor for Linux internals, Bash scripting, Python 3, and log analysis. Has **no filesystem access** — it cannot read or run anything. Provide logs and code snippets directly in chat. It diagnoses root causes, ranks solutions with trade-offs, and gives a verification plan for every fix.

```
Mode: primary | Tools: none (read-only discussion partner)
```

### Reflect — Socratic thinking partner

Helps you think more clearly rather than thinking for you. Uses structured techniques — assumption surfacing, inversion, pre-mortem, steelmanning — to surface hidden assumptions and sharpen decisions. Stays concise (3–10 lines by default) and never gives unsolicited advice or implementation details.

```
Mode: primary | Temperature: 0.7 | Tools: read (only when explicitly asked)
```

## Skills

Skills are instruction sets stored in `.opencode/skills/`. An agent loads a skill with the `skill` tool when the task matches its description. Skills extend agent behavior without changing the agent's core persona.

### clear-language

Applies plain language principles (ISO 24495-1:2023) to any human-readable text: documentation, error messages, API responses, commit messages, inline comments, and README files. The goal: a reader understands the text on the first read without guessing.

Covers word choice, sentence structure, active voice, scanning-friendly layout, and a revision checklist.

### clear-language-norwegian

Extends `clear-language` with Norwegian-specific rules from Språkrådet (the Norwegian Language Council). Covers klarspråk (plain language law), the kansellisten (list of bureaucratic words to avoid), common preposition errors, Norwegian alternatives to English loanwords, formal letter format, gender-balanced language, sensitive terminology, and language requirements for digital public services.

Defaults to bokmål. Use nynorsk only when explicitly requested.

### memory

Stores and recalls context across sessions: preferences, architectural decisions, patterns, and warnings. Writes entries to `docs/memory/archive/` with a structured front matter and maintains an index at `docs/memory/INDEX.md`.

Load this skill when the user says "remember", references a past session, or states a rule worth keeping.

### wrap-up

Defines the end-of-task ceremony: write a worklog in `docs/worklogs/`, bump the version with `scripts/bump-version.sh`, stage only the changed files, and commit using Conventional Commits format. No wildcard staging (`git add .`) is allowed.

Load this skill when the user says "wrap up", "commit", or "done".

### todo-txt

Tracks tasks, todos, and work logs using the [todo.txt](https://github.com/todotxt/todo.txt) plain-text format. Each task is one short, atomic line. Complex work is split into multiple tasks rather than written as a long description.

Supports priorities `(A)`–`(Z)`, creation and completion dates, `@contexts`, `+tags`, and `key:value` metadata (e.g. `due:`, `pri:`). The file is always kept sorted using `sort todo.txt -o todo.txt`. Completed tasks are marked with a leading `x` and sort to the bottom automatically. Includes operations for adding, completing, editing, deleting, archiving, and filtering tasks.

Default files: `todo.txt` (active tasks) and `done.txt` (archived completed tasks).

## Ralph loop

The Ralph loop is an autonomous iteration technique. It feeds the same prompt back to the agent repeatedly, letting the agent see its own previous work in files and git history, and improve incrementally until done.

Based on the [Ralph Wiggum technique](https://ghuntley.com/ralph/) by Geoffrey Huntley. The OpenCode plugin in this repository is derived from [rot13maxi/opencode-ralph](https://github.com/rot13maxi/opencode-ralph).

### How it works

1. You run `/ralph-loop <prompt>` inside OpenCode.
2. The agent creates a state file (`ralph-loop.local.md`) and starts working.
3. When the agent finishes responding, the Ralph plugin intercepts the idle event.
4. The same prompt is fed back, with the iteration counter incremented.
5. The agent sees its previous changes in the files and git history.
6. The loop continues until a stop condition is met.

### Stop conditions

| Condition | How to trigger |
|---|---|
| Completion promise | Agent outputs `<promise>EXACT TEXT</promise>` |
| Max iterations | Pass `--max-iterations N` when starting |
| Manual cancel | Run `/cancel-ralph` |

The agent must only output the promise tag when the statement is **genuinely true**. The loop is designed to keep running if the task is incomplete.

### Commands

```
/ralph-loop <PROMPT> [--max-iterations N] [--completion-promise TEXT]
/cancel-ralph
/ralph-help
```

### Examples

```
# Fix a bug and stop when all tests pass (up to 10 iterations)
/ralph-loop "Fix the token refresh logic in auth.ts. Output <promise>FIXED</promise> when all tests pass." \
  --completion-promise "FIXED" \
  --max-iterations 10

# Refactor without a hard stop (runs until you cancel)
/ralph-loop "Refactor the cache layer" --max-iterations 20

# Greenfield build until done
/ralph-loop "Build a REST API for todos" --completion-promise "DONE" --max-iterations 30
```

### When to use Ralph

**Good for:** well-defined tasks with clear success criteria, iterative bug fixes, greenfield builds, tasks that benefit from self-correction over multiple attempts.

**Not good for:** tasks requiring human judgment or design decisions, one-shot operations, debugging production issues.

### Plugin setup

The plugin is written in TypeScript (`/.opencode/plugin/ralph.ts`) and depends on `@opencode-ai/plugin`. Dependencies are installed locally under `.opencode/node_modules/` and are excluded from Git via `.opencode/.gitignore`.

## Repository layout

```
.
├── AGENTS.md                   # Master rules for all agents
├── opencode.json               # OpenCode configuration
└── .opencode/
    ├── RULES.md                # Detailed coding and security rules
    ├── update.sh               # Fetch/update script
    ├── agents/
    │   ├── vibe.md             # Pair programmer agent
    │   ├── facts.md            # Technical researcher agent
    │   ├── linux-expert.md     # Linux/Bash/Python advisor agent
    │   └── reflect.md          # Socratic thinking partner agent
    ├── skills/
    │   ├── clear-language/     # Plain language writing skill
    │   ├── clear-language-norwegian/  # Norwegian klarspråk skill
    │   ├── memory/             # Cross-session memory skill
    │   ├── todo-txt/           # todo.txt task tracking skill
    │   └── wrap-up/            # Worklog, version bump, and commit skill
    ├── command/
    │   ├── ralph-loop.md       # /ralph-loop command
    │   ├── cancel-ralph.md     # /cancel-ralph command
    │   └── ralph-help.md       # /ralph-help command
    └── plugin/
        └── ralph.ts            # Ralph loop TypeScript plugin
```

## Updating

The `update.sh` script downloads `AGENTS.md`, `opencode.json`, and everything under `.opencode/` from this repository. It skips files listed in `.opencode/.gitignore` (such as `node_modules/`) so your local dependencies are never overwritten.

### Options

```
Usage: update.sh [OPTIONS] [BRANCH/TAG]

Options:
  -D            Delete the legacy ./agents folder before updating
  -d DIR        Target directory (default: current directory)
  -h, --help    Show this help message and exit
  -v, --version Show version and exit
```

### Examples

```bash
# Update from main into the current directory
./.opencode/update.sh

# Update from a specific tag
./.opencode/update.sh v1.2.0

# Update into a different project directory
./.opencode/update.sh -d ~/myproject

# Remove the legacy agents/ folder, then update
./.opencode/update.sh -D
```

`update.sh` requires `curl` and `python3`.
