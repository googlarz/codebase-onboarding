# Contributing to codebase-onboarding

A Claude Code skill for systematic orientation in unfamiliar codebases. Contributions welcome.

## Before you start

- Check [open issues](https://github.com/googlarz/codebase-onboarding/issues) and [discussions](https://github.com/googlarz/codebase-onboarding/discussions)
- For workflow changes or new modes, open a discussion first

## What to contribute

- **Workflow improvements** — better phases, stronger verification gates
- **Mode extensions** — e.g. monorepo mode, legacy-code mode
- **Shell command improvements** — better bash one-liners for the investigation phases
- **Bug reports** — describe the codebase type and what orientation went wrong

## Submitting a PR

1. Fork → branch from `main`
2. Edit `SKILL.md` — preserve the section structure (Modes table, Phase Order table, phases, Rationalizations, Red Flags, Verification)
3. New phases must be verifiable — an agent must be able to confirm the gate passed
4. Open the PR with a concrete example of what your change improves or catches

## Skill format

Every step must be executable and verifiable. Vague guidance ("understand the codebase") is rejected — every instruction should be something Claude can run and check. See the [agent-skills anatomy guide](https://github.com/addyosmani/agent-skills) for reference.
