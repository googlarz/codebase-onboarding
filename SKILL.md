---
name: codebase-onboarding
description: >
  Systematic orientation in an unfamiliar codebase. Use when joining a new
  team's repo, returning to your own old code after months away, or evaluating
  an OSS project before contributing. Builds a verified mental model — what the
  system does, where data flows, what the implicit conventions are, and which
  files are dangerous to touch first — producing a living CODEBASE.md.
version: 1.1
---

# Codebase Onboarding

Systematic orientation. Stop guessing. Build the right mental model before
touching anything.

**How this works:** Claude runs the investigation — executes commands, reads
files, traces paths — and writes CODEBASE.md as a living orientation document.
The human provides the repository and answers questions that can't be found in
the code. Think of it as pair programming where Claude does the archaeology and
you provide context that only humans have.

---

## When to Use

| Situation | Mode |
|-----------|------|
| Joining a new team or repo for the first time | **join** |
| Returning to your own code after 3+ months away | **return** |
| Evaluating an OSS project before contributing | **audit** |
| Inheriting a colleague's codebase | **join** |
| Doing due diligence on an acquisition or dependency | **audit** |

Default to **join** if unclear. Ask the user which mode if the context is ambiguous.

---

## Phase Order by Mode

Modes change which phases run and in what order. Don't follow join order for return.

| Phase | join | return | audit |
|-------|------|--------|-------|
| 0 — Bootstrap | ✓ first | ✓ first | ✓ first |
| 1 — Critical Paths | ✓ | ✓ | ✓ |
| 2 — Conventions | ✓ | ✓ after Phase 5 | ✓ |
| 3 — Danger Zones | ✓ | ✓ after Phase 5 | ✓ |
| 4 — First Safe Contribution | ✓ | ✓ | skip |
| 5 — Archaeology | skip | ✓ before Phase 2 | skip |
| 6 — Contributor Signal | skip | skip | ✓ |

**In return mode:** run Phase 5 (Archaeology) immediately after Phase 1. You need
to know why decisions were made before you can evaluate whether the current
conventions are intentional or legacy drift.

---

## Output: CODEBASE.md

The skill produces and maintains a single living document. Not a one-time scan.

```
CODEBASE.md
├── What This Is          # one-paragraph system description
├── Critical Paths        # entry points → processing → exit
├── Architecture Map      # key components and how they connect
├── Conventions           # implicit rules the README doesn't mention
├── Danger Zones          # what not to touch first, and why
├── Open Questions        # still unclear — actively maintained
└── Contribution Log      # join/return: changes + learnings
                          # audit: merge rate, PR velocity, go/no-go
```

Update CODEBASE.md at the end of each phase. Do not defer. The document is useless
if written retrospectively — the value is in the questions it forces you to ask.

---

## Phase 0: Bootstrap

Read these in order. Stop when you can answer the question at the bottom.

```
1. README.md / README.rst    → what does it claim to do?
2. CLAUDE.md / AGENTS.md     → what has an AI already learned here?
3. CONTRIBUTING.md           → what does the team care about?
4. package.json / go.mod /
   pyproject.toml / Cargo.toml → language, deps, run scripts
5. Makefile / justfile        → available commands
6. .github/workflows/         → what CI runs — the ground truth
```

**CI is the most honest documentation in any codebase.** It runs on every commit and
doesn't lie. If it conflicts with the README, CI wins.

```bash
# Scan in 30 seconds
ls -la && head -50 README.md
ls .github/workflows/ 2>/dev/null
grep -E "run:|script:" .github/workflows/*.yml 2>/dev/null | head -20

# Remote pulse (join/audit mode)
gh issue list --state open --limit 5 2>/dev/null
gh pr list --state open --limit 5 2>/dev/null
```

**Gate:** Write the "What This Is" section of CODEBASE.md. One paragraph. No
jargon. If you can't write it confidently, you haven't read enough — don't
proceed to Phase 1.

---

## Phase 1: Map the Critical Paths

Find where data enters and leaves. Every system has 2–5 entry points. Find them.

```bash
# Entry points
find . -name "main.*" -o -name "index.*" -o -name "app.*" \
  | grep -v "node_modules\|.git\|test\|spec" | head -20

# What the system exposes
grep -rn "listen\|:8080\|:3000\|serve\|router\|@app.route" \
  --include="*.go" --include="*.ts" --include="*.py" -l | head -10

# Data stores
find . \( -name "*.sql" -o -name "schema.*" -o -type d -name "migrations" \) \
  ! -path "*/.git/*" | head -10
grep -rn "sqlite\|postgres\|mysql\|redis\|mongo" \
  --include="*.toml" --include="*.json" --include="*.env*" -l | head -10

# Monorepo: find the packages first
ls packages/ apps/ services/ 2>/dev/null | head -20
```

For each entry point: trace the data one level deep. What format comes in? What
transformation happens? What goes out?

Write these as **Critical Paths** and the component layout as **Architecture Map**
in CODEBASE.md.

Don't trace everything. Two or three critical paths beat a full audit you'll
abandon.

---

## Phase 2: Extract Conventions

The README documents what the team intended. Git history documents what they
actually do. These often conflict. Git wins.

```bash
# Commit message style — what format do they use?
git log --format="%s" -30

# Pattern frequency
git log --format="%s" | grep -oE "^[a-z]+(\([^)]+\))?" | sort | uniq -c | sort -rn | head -10

# PR/commit discipline — do they test?
git log --format="%s" | grep -i "test\|spec\|fix" | wc -l
git log --format="%s" | grep -i "wip\|todo\|tmp" | wc -l

# High-churn files — what does the team touch most?
git log --format=format: --name-only | grep -v "^$" | sort | uniq -c | sort -rn | head -15

# Authorship — who owns what area?
git log --format="%ae" --follow -- src/ | sort | uniq -c | sort -rn | head -10
```

Look for what a new contributor would get wrong without being told:
- Commit message format (conventional commits? ticket prefix? freeform?)
- PR size norm (focused single-purpose, or large batch PRs?)
- Test discipline (every commit touches tests, or tests are separate?)
- Branch naming, squash vs merge, rebase policy

Write **Conventions** in CODEBASE.md. Prioritise implicit rules over documented
ones — the README already covers the rest.

---

## Phase 3: Map the Danger Zones

Danger zones are not necessarily bad code. They are high-blast-radius code. Do
not touch them first.

```bash
# High churn (conflict-prone, frequently broken)
git log --format=format: --name-only | grep -v "^$" | sort | uniq -c | sort -rn | head -20

# Known debt clusters (often load-bearing — don't "fix" these first)
grep -rn "TODO\|FIXME\|HACK\|XXX" \
  --include="*.go" --include="*.ts" --include="*.py" --include="*.js" \
  | awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -10

# Large files (hard to understand, high blast radius)
find . -type f \( -name "*.go" -o -name "*.ts" -o -name "*.py" -o -name "*.js" \) \
  ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
  -exec wc -l {} + 2>/dev/null | sort -rn | head -15

# Frequently reverted (unstable)
git log --format="%s" | grep -i "revert\|rollback" | head -10
```

Write **Danger Zones** in CODEBASE.md as a table:

```
| File / Area          | Why dangerous                              | When to touch |
|----------------------|--------------------------------------------|---------------|
| src/core/engine.go   | 2,847 lines, 47 TODOs, in 89% of PRs      | After 4+ weeks|
| migrations/          | Schema changes require team coordination   | Never solo    |
| auth/                | Security-sensitive, subtle failure modes   | With review   |
```

---

## Phase 4: First Safe Contribution

**(join and return modes only — skip in audit)**

The only real test of whether a mental model is correct is a change that
breaks something unexpected. Claude identifies and drafts the candidate
change; the human reviews, runs it locally, and submits. Neither party
should bypass the other here — Claude doesn't know the team politics, the
human doesn't know where the landmines are yet.

**Good targets:**

```
✓ A failing or flaky test
✓ A documentation error (wrong command, outdated example, broken link)
✓ A type or lint error CI flags but doesn't block on
✓ An explicit "good first issue" or "help wanted" label
✗ A refactor of anything (too much blast radius, too little context)
✗ A new feature (the right approach isn't clear yet)
✗ Anything in a Danger Zone
✗ "Cleaning up" code that isn't fully understood yet
```

Claude's role: find the target, draft the change, explain the reasoning.
Human's role: run CI locally, review the diff, own the submission.

```bash
# Run the checks CI runs — use the commands from Phase 0
# (Makefile targets, package.json scripts, or workflow run: steps)

# Confirm you're not touching Danger Zones
git diff --stat

# Scope tests to what you changed
# (don't run the full suite blind on a large repo until you know what's slow)
```

Write what was learned from this contribution in the **Contribution Log**. Even
"nothing broke and the review was fast" is signal.

---

## Phase 5: Archaeology

**(return mode only — run this before Phases 2 and 3)**

When returning to your own old code, the question shifts from "what does this do"
to "why did I do it this way." Answer that before evaluating conventions.

```bash
# What was I thinking?
git log --all --format="%ad %s" --date=short | head -40

# What decisions were captured?
find . -name "ADR*" -o -name "DECISION*" -o -path "*/docs/*.md" 2>/dev/null | head -10

# What was I in the middle of?
git stash list
git log --all --oneline --decorate | head -20
find . -name "*.todo" -o -name "NOTES*" -o -name "SCRATCH*" 2>/dev/null

# What broke last?
git log --format="%s" | grep -i "fix\|revert\|hotfix\|broke" | head -10
```

Add an **Archaeology Notes** section to CODEBASE.md:
- What you rediscovered that still makes sense
- What you'd do differently now
- What you found that surprised you

Then continue to Phase 2. Archaeology reframes what you'll see there.

---

## Phase 6: Contributor Signal

**(audit mode only)**

Before investing time in an OSS contribution, verify it's worth it.

```bash
# Is the project active?
git log --format="%ad" --date=short | head -5   # last commits
gh issue list --state open --limit 5            # issue activity
gh pr list --state open --limit 5               # PR activity

# Are PRs actually reviewed and merged?
gh pr list --state closed --limit 20 | grep -v "MERGED"  # rejected PRs

# How long do PRs sit?
gh pr list --state closed --json mergedAt,createdAt --limit 20 \
  | python3 -c "
import json,sys
from datetime import datetime
prs=json.load(sys.stdin)
for p in prs:
  if p['mergedAt']:
    c=datetime.fromisoformat(p['createdAt'].replace('Z','+00:00'))
    m=datetime.fromisoformat(p['mergedAt'].replace('Z','+00:00'))
    print(f'{(m-c).days}d')
" 2>/dev/null | sort -n
```

Add to CODEBASE.md: merge rate, average PR-to-merge time, maintainer
responsiveness. These predict whether your contribution will land.

---

## Common Rationalizations

| Rationalization | Reality |
|----------------|---------|
| "I'll start coding and learn as I go" | You'll violate conventions you haven't discovered yet and waste a review cycle |
| "The README explains everything" | The README explains intentions. Git log explains reality. They often conflict |
| "I know this stack, I know how it works" | Every codebase has implicit rules the stack doesn't enforce |
| "I'll read all the code first, then start" | You'll never start. Map critical paths, not the whole codebase |
| "This code is messy, I should clean it up" | You don't understand it yet. Cleanup before understanding = silent breakage |
| "I can see what this does, I don't need CODEBASE.md" | You'll forget. You'll also hand it to the next person who joins |
| "The Danger Zones need fixing most" | They need fixing eventually. They don't need fixing by someone new to the codebase |
| "I'll skip Phase 5, I remember why I wrote this" | You don't. The git log will prove it. |

---

## Red Flags

- Making changes before completing Phase 0
- First contribution touches a Danger Zone
- "Cleaning up" code before you understand what it does
- Submitting a PR in the wrong style because you skipped convention extraction
- CODEBASE.md has empty Open Questions — that means you're not paying attention
- Treating a large refactor as a safe first contribution
- Abandoning CODEBASE.md after the first week — it becomes more valuable as it grows
- Running return mode in join order — skipping archaeology means you'll misread conventions as intentional

---

## Verification

**Core (all modes):**
- [ ] Can describe what the system does in one paragraph without looking at README
- [ ] Can trace a request from entry point to exit
- [ ] Danger Zones are listed with reasons and "when to touch" guidance
- [ ] Open Questions section exists and is non-empty (actively maintained)
- [ ] CODEBASE.md has all sections populated — not placeholder text

**join / return mode:**
- [ ] Commit message format and PR size norms are documented in CODEBASE.md
- [ ] First safe contribution identified, validated locally, and submitted or in-progress

**return mode:**
- [ ] Archaeology Notes section explains the key decisions and what surprised you
- [ ] Phase 5 ran before Phase 2 — conventions were read through the lens of intent

**audit mode:**
- [ ] Merge rate and average PR-to-merge time documented
- [ ] Go / no-go decision documented in CODEBASE.md with reasoning
