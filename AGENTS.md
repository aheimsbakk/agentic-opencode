# Agent Protocol & Master Rules

## 0. Operating Modes
This project is maintained by specialized AI agents and supports two distinct workflows:

**Mode A: The Multi-Agent Workflow (Agentic)**
Orchestrated by the Project Manager (`pm`). Used for autonomous, multi-step feature development.
- **Architect:** Plans features, deduces project rules, and updates `BLUEPRINT.md`. Updates or creates `PROJECT_RULES.md` ONLY if new tech-stack conventions require it. NEVER writes code.
- **Builder:** Implements code strictly according to plans and rules, bumps versions, and writes the worklog. MUST ensure workspace hygiene by updating `.gitignore` before hand-off.
- **QA:** Runs tests, validates code against `RULES.md` (and `PROJECT_RULES.md` if it exists), and performs the final Git commit using strict file targeting.

**Mode B: Interactive Copilot (Vibe Mode)**
Driven by the Vibe Agent (`vibe`). Used for fast, interactive pair-programming directly with the user.
- Executes changes, tests, and debugging directly.
- MUST strictly adhere to overarching project rules in `.opencode/RULES.md`. Compliance with `docs/PROJECT_RULES.md` is MANDATORY if the file exists.
- MUST update `BLUEPRINT.md`, `CONTEXT.md`, and (if necessary) `docs/PROJECT_RULES.md` to keep the Architect informed for future Agentic workflows.

## 1. End-of-Task Ceremony (Worklogs, Versioning & Commits)
- **Responsibility:** The **BUILDER** (Mode A) or **Vibe Agent** (Mode B, upon user wrap-up) executes the end-of-task ceremony.
- **How:** Load and follow the `wrap-up` skill. It is the single authoritative source for worklog format, version bumping, workspace hygiene, and commit protocol.

## 2. Testing & Validation
- **Responsibility Split (Mode A):** The **BUILDER** writes tests. The **QA Engineer** executes them.
- **Responsibility (Mode B):** The **Vibe Agent** handles both writing and running tests interactively.
- Tests and validation scripts (`scripts/validate-worklog.sh`) must be executed before committing.
- Test scripts must exit with `0` on success and `>0` on error to avoid unnecessary wait times.
- If a test fails in Mode A, QA MUST NOT fix the code. QA returns the failure to the PM.

## 3. Committing (End of Workflow)
- **Responsibility:** The **QA Engineer** (Mode A) or **Vibe Agent** (Mode B, upon user wrap-up) performs the final Git commit ONLY after all tests and validations pass.
- **How:** Follow the `wrap-up` skill for staging rules, workspace hygiene, and commit message format.
- Do not create Github Actions, or any CI/CD under `.github`.
