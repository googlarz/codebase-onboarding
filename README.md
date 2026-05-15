# codebase-onboarding

A Claude Code skill for systematic orientation in an unfamiliar codebase.

Use when joining a new team's repo, returning to your own old code after months
away, or evaluating an OSS project before contributing. Builds a verified mental
model and produces a living `CODEBASE.md` orientation document.

## What it does

Claude runs the investigation — executes commands, reads files, traces critical
paths — and writes `CODEBASE.md` as a living orientation document. The human
provides the repository and answers questions that can't be found in code.

## Three modes

| Mode | When | What's different |
|------|------|-----------------|
| **join** | New team or project | Full workflow including convention extraction from git/PRs |
| **return** | Your own code, 3+ months away | Archaeology phase runs first — why decisions were made, not just what they are |
| **audit** | Evaluating OSS contribution | Skips first-PR phase; adds contributor signal assessment (merge rate, PR velocity) |

## Output

A living `CODEBASE.md` with:
- **What This Is** — one-paragraph system description
- **Critical Paths** — entry points → processing → exit
- **Architecture Map** — key components and how they connect
- **Conventions** — implicit rules the README doesn't mention
- **Danger Zones** — what not to touch first, and why
- **Open Questions** — actively maintained
- **Contribution Log** — changes and learnings (or audit findings)

## Install

```bash
# In your Claude Code project
cp SKILL.md ~/.claude/skills/codebase-onboarding/SKILL.md
```

Or reference the raw file directly in your `CLAUDE.md`.

## Usage

```
/codebase-onboarding join     # joining a new team
/codebase-onboarding return   # returning to your own code
/codebase-onboarding audit    # evaluating an OSS project
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
