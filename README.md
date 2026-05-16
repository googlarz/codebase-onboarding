# codebase-onboarding

**For developers:** You joined a new team. The README says "it's pretty simple." There are 47 open TODOs, a file that's 2,800 lines long, and everyone goes quiet when you ask about the payments module. You could spend three days reading files — or run this and know in an hour what to avoid, who owns what, and what to touch first.

**For non-technical users:** Someone told you the codebase is "in good shape." Before you say that in a board meeting, sign off on a launch, or make a vendor decision — run this. It maps the system in plain language, surfaces the real risk areas, and generates questions you can actually ask in your next engineering meeting without sounding like you're guessing.

---

**Stop guessing. Build the right mental model before you break something.**

New repo. Inherited codebase. Your own code after six months away. The instinct is to start reading files. That's slow, incomplete, and leaves you blind to the things that will actually burn you — the undocumented env var, the file everyone avoids, the test suite that breaks when run in parallel.

This skill does the archaeology. Claude runs the investigation, maps the architecture, hunts for gotchas, generates a working local dev guide, and produces a living `CODEBASE.md`. Then it stays useful: check a file before touching it, catch problems before pushing, map a ticket to the codebase before writing a line.

---

## Seven modes

| Mode | Use when |
|------|----------|
| **join** | First day on a team, inherited repo, colleague's codebase |
| **return** | Your own code you haven't touched in 3+ months |
| **audit** | Evaluating an OSS project before contributing |
| **quick** | Need "what do I avoid" in 15 minutes — no time for full investigation |
| **touch** | About to modify a specific file — get a risk assessment first |
| **preflight** | About to push a PR — catch what reviewers will catch, before review |
| **task** | Assigned a ticket or feature — map it to the codebase before starting |

`quick` is a triage tool — Danger Zones and Gotchas only, no `CODEBASE.md` written.
`touch`, `preflight`, and `task` are ongoing — they require an existing `CODEBASE.md`.

---

## The investigation

```
Phase 0   Bootstrap          README, CI config, open issues, package manifests
          └─ AI detection    Signals that the codebase is largely AI-generated — adjusts assessment lens
Phase 1   Critical Paths     Entry points, data stores, Mermaid architecture diagram
Phase 2   Conventions        What git history reveals vs. what the README claims
Phase 3   Danger Zones       High-churn files, debt clusters, frequently reverted code
Phase 4   Gotcha Detector    Security pre-check first, then: undocumented env vars, pre-commit/CI gaps, test traps
Phase 5   Local Dev Guide    Step-by-step to get it running — real commands, common failures  [technical]
Phase 6   Team Questions     1:1 format with priority tiers  [technical]
          Meeting Questions  Sprint planning / roadmap / board framing  [non-technical]
          └─ Answers loop    When answers arrive: which sections to update, how to close Open Questions
Phase 7   Executive Brief    One-page health summary — framed for your stated goal  [non-technical]
Phase 8   First Contribution Specific file + line + fix — not just a category  [technical]
Phase 8b  Ramp-up Timeline   Week-by-week gates derived from findings — not a template  [technical]
────────────────────────────────────────────────────────────────────────────────────────
Phase 9   Archaeology        return only — why decisions were made, not just what they are
Phase 10  Contributor Signal audit only — merge rate, PR velocity, go/no-go
```

---

## Works for technical and non-technical users

Before any phase runs, Claude asks two questions:

**1. Technical or non-technical?**

- **Technical:** file paths, code snippets, git commands, local dev guide, PR preflight
- **Non-technical:** plain language throughout, shareable architecture diagram, executive brief, questions framed for meetings — not for debugging sessions

**2. What's your goal?**

- **Technical examples:** make a contribution, take ownership, security review, evaluate OSS
- **Non-technical examples:** understand what the system does, assess risk before a launch, prepare for a roadmap or board conversation

The same investigation runs either way. The output is completely different.

---

## What you get

### `CODEBASE.md` — honest by design

Every section carries a confidence tag:

```
✅ Verified   Based on CI config, git history, or explicit documentation
⚠️ Inferred   Based on patterns — likely but not confirmed
❓ Gap        Couldn't assess from code — needs a human answer
```

Gap sections automatically become Team Questions. If something is tagged ❓, there's a corresponding question to ask.

**Example sections:**

```markdown
## Danger Zones ✅ Verified

| File / Area         | Why dangerous                         | When to touch  |
|---------------------|---------------------------------------|----------------|
| src/core/engine.go  | 2,847 lines, 47 TODOs, in 89% of PRs | After 4+ weeks |
| migrations/         | Schema changes need team coordination | Never solo     |
| auth/               | No tests, last touched 18 months ago  | With review    |

## Gotchas ✅ Verified

- `STRIPE_WEBHOOK_SECRET` required but absent from `.env.example` —
  payments fail silently without it
- Pre-commit runs `eslint --fix`; CI runs `eslint` — passes locally,
  fails CI if you don't re-stage after the hook fires
- `auth/` tests share a singleton — `pytest -n 4` causes random failures;
  always run `pytest -p no:xdist auth/`

## Local Dev Guide ✅ Verified

1. `cp .env.example .env`
2. Set missing variables:
   - `STRIPE_WEBHOOK_SECRET` — ask alice@example.com for the dev key
   - `JWT_SECRET` — any 32-char string works locally
3. `npm install`
4. `docker-compose up -d postgres redis`
5. `npm run db:migrate`
6. `node scripts/seed.sh`   ← not in README; required for tests
7. `npm run dev`            → http://localhost:3000

Verify: `curl http://localhost:3000/health` → `{"status":"ok"}`
```

### Architecture Map — generated in Phase 1

For engineers:
```mermaid
graph LR
    Client -->|HTTP| API[api/routes.go]
    API --> Auth[auth/middleware.go]
    Auth --> Handler[handlers/user.go]
    Handler --> DB[(postgres)]
    Handler --> Cache[(redis)]
```

For non-technical stakeholders — same investigation, plain language:
```mermaid
graph LR
    User -->|sends request| API[Web API]
    API --> Auth[Login Check]
    Auth --> Logic[Business Logic]
    Logic --> DB[(Database)]
    Logic --> Cache[(Fast Cache)]
```

### Team Questions — prioritised

**For technical users (1:1 format):**
```markdown
### 🔴 Blocking (ask in the first hour)
1. `STRIPE_WEBHOOK_SECRET` is in code but not `.env.example`. Shared dev key?
2. CI runs `pytest -x`, README says `make test`. Which for local dev?

### 🟡 Important (this week)
3. `payments/sync.go` reverted 3× in 6 months — active fix, or avoided?

### 🟢 Nice-to-know
4. `core/engine.go` is 2,400 lines — plan to split it, or intentional?
```

**For non-technical users (meeting format):**
```markdown
### For your next sprint planning
- The payment module has broken 3 times this year — what's the risk
  if we ship features that touch it this sprint?

### For a board or investor conversation
- How would you describe the overall health of the engineering foundation?
```

### Ramp-up Timeline — technical only

Generated after Phase 8. Every checkpoint references actual files, people, and question numbers found during the investigation — not generic milestones.

```markdown
## Ramp-up Timeline ⚠️ Inferred

### Week 1 — get oriented and unblocked
  □ Local dev running: `curl http://localhost:3000/health` → {"status":"ok"}
  □ STRIPE_WEBHOOK_SECRET and JWT_SECRET added to .env (ask alice@example.com)
  □ Can explain Client → API → Auth → Handler → DB without CODEBASE.md
  □ Blocking team questions answered (questions 1 and 2 — see Team Questions 🔴)
  □ First safe contribution submitted (target: test_auth.py line 47)

### Week 2 — know how the team works
  □ First PR merged without commit message feedback (conventional commits format)
  □ PR size within team norm (under 400 lines, based on git log)
  □ Know who to ping: auth → alice@example.com, payments/API → bob@example.com
  □ Important questions answered (questions 3–5 — see Team Questions 🟡)

### Week 4 — own the codebase
  □ Can name all 3 Danger Zones without looking at CODEBASE.md
  □ Touch mode no longer needed outside Danger Zones
  □ Ready to review a teammate's PR for convention compliance
  □ CODEBASE.md updated with anything that was wrong or missing
```

Return mode adds a **recovery gate at end of Week 1**: archaeology complete, changes since your absence absorbed, prior mental model assumptions flagged as outdated.

---

### Executive Brief — non-technical only

```markdown
## Executive Brief

### Codebase health
| Area | Status | Business impact |
|------|--------|----------------|
| Core engine | 🔴 High risk | Changes here are slow and bug-prone |
| Payments | 🟡 Unstable | Has broken 3× in 6 months |
| Auth | 🟡 Untested | No safety net; bugs affect all users |
| API | 🟢 Healthy | Well-maintained, stable |

### Top risks
1. Payment processing has broken and been reverted three times — any change
   here carries meaningful risk of customer-facing outage.
2. Authentication has no automated tests — bugs affect every user.

### Overall assessment
Medium risk. The API layer is healthy, but two critical areas (payments
and auth) need investment before safely shipping major new features.
```

---

## Quick mode

> *"Quick mode — I need to make a change in the next hour."*

No CODEBASE.md written. Runs Bootstrap + Danger Zones + Gotchas only. Output is a single briefing:

```
Quick Briefing: payments-api

⚠️  This is triage, not orientation. Run join mode when you have time.

DON'T TOUCH FIRST
  migrations/   — irreversible schema changes, never solo
  auth/         — no tests, 3 reverts in 6 months, get review first
  .env files    — shared config, changes affect everyone immediately

GOTCHAS TO KNOW NOW
  STRIPE_WEBHOOK_SECRET missing from .env.example — payments fail silently
  Pre-commit runs eslint --fix; CI runs eslint — re-stage after hook fires
  auth/ tests share a singleton — run pytest -p no:xdist, not pytest -n 4

Suggested prompt for your change:
  "In api/middleware.go, [your change]. Be minimal. Don't touch auth/."
```

---

## Touch mode

> *"I'm about to modify `auth/middleware.go` — run touch mode."*

Checks CODEBASE.md staleness first. If it's older than 4 weeks, warns before using its data.

```
Before You Touch: auth/middleware.go

Risk level: HIGH — listed in Danger Zones

Recent commits:
  3 days ago   fix: token expiry edge case       alice@example.com
  2 weeks ago  REVERT: "refactor auth flow" — broke staging

Who to ping: alice@example.com (14 of last 20 commits)

Known issues:
  Line 47   TODO  refresh token rotation not implemented
  Line 203  FIXME breaks with multiple active sessions

Tests covering this:
  tests/auth/middleware_test.go
  tests/integration/session_test.go

  Run these now, before editing, to establish a baseline.
  A failure before you start is not your bug. A failure after is.

Watch out for:
  Session singleton on line 89 — caused the revert two weeks ago

Suggested prompt for your next message:
  "In auth/middleware.go, [your change]. Be minimal.
   Don't touch the session singleton on line 89."
```

---

## Preflight mode

> *"Run preflight on my current changes."*

Checks CODEBASE.md staleness first. Every ❌ includes the corrected version and exact command. Every ⚠️ includes the specific action and the relevant CODEBASE.md reference. The verdict is a sequence to execute, not a list to interpret.

```
PR Pre-flight: feat/add-rate-limiting
Branch: feat/add-rate-limiting (3 source files, 0 test files changed)

────────────────────────────────────────
COMMIT MESSAGE
────────────────────────────────────────
❌ Doesn't follow conventional commits (used in 28 of last 30 commits)

   Current:  "add rate limiting"
   Fix to:   "feat(api): add rate limiting to middleware"

   Command:  git commit --amend -m "feat(api): add rate limiting to middleware"

────────────────────────────────────────
FILES CHANGED
────────────────────────────────────────
✅ api/routes.go — not a Danger Zone
✅ api/middleware.go — not a Danger Zone

⚠️  auth/middleware.go — DANGER ZONE
   Why: No tests, last touched 18 months ago, security-sensitive
   Action: alice@example.com must review (14 of last 20 commits here)
   Watch for: session singleton on line 89 — caused a revert last month

────────────────────────────────────────
PR SIZE
────────────────────────────────────────
⚠️  430 lines changed — team norm is under 400 (based on last 30 merged PRs)

   Consider splitting: rate limiting logic vs. test files

────────────────────────────────────────
TEST COVERAGE
────────────────────────────────────────
❌ No test files in diff (convention: every commit that touches source touches tests)

   Add tests to:
     api/middleware.go  → tests/api/middleware_test.go
     auth/middleware.go → tests/auth/middleware_test.go

   Pattern to follow: tests/api/logging_test.go
   (added with "feat(api): add request logging" — same structure)

────────────────────────────────────────
GOTCHAS
────────────────────────────────────────
⚠️  Pre-commit runs eslint --fix; CI runs eslint without fix
   After hook fires: git add api/middleware.go && git push

⚠️  auth/ tests share a singleton — don't run with -n
   Use: pytest -p no:xdist tests/auth/

────────────────────────────────────────
VERDICT: ⚠️ ADDRESS BEFORE PUSHING
────────────────────────────────────────
  1. git commit --amend -m "feat(api): add rate limiting to middleware"
  2. Add tests to tests/api/middleware_test.go and tests/auth/middleware_test.go
     (follow tests/api/logging_test.go)
  3. Re-stage after pre-commit hook fires, then push
```

---

## Task mode

> *"I need to add rate limiting to the API — where do I start?"*

```
Task: Add rate limiting to the API

Relevant files:
  api/routes.go       — entry point; where rate limiting hooks in
  api/middleware.go   — existing pattern to follow ← start here

Danger Zone proximity:
  auth/middleware.go  ⚠️  adjacent — avoid unless necessary

Similar past work:
  "feat(api): add request logging middleware" — bob@example.com, 3 months ago
  Same pattern: middleware.go, not routes.go

Conventions:
  Every new middleware needs an integration test in tests/api/

Who to loop in: bob@example.com (owns api/, built existing middleware)

Risk level: LOW — api/ is not a Danger Zone, pattern is established
```

---

## Install

```bash
mkdir -p ~/.claude/skills/codebase-onboarding
curl -o ~/.claude/skills/codebase-onboarding/SKILL.md \
  https://raw.githubusercontent.com/googlarz/codebase-onboarding/main/SKILL.md
```

---

## Usage

```
/codebase-onboarding join       # new team or repo
/codebase-onboarding return     # your own code after months away
/codebase-onboarding audit      # evaluating OSS before contributing
/codebase-onboarding quick      # 15-minute triage — danger zones + gotchas only
/codebase-onboarding touch      # before modifying a file
/codebase-onboarding preflight  # before pushing a PR
/codebase-onboarding task       # when starting any new piece of work
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
