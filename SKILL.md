---
name: codebase-onboarding
description: >
  Systematic orientation in an unfamiliar codebase. Use when joining a new
  team's repo, returning to your own old code after months away, or evaluating
  an OSS project before contributing. Builds a verified mental model — what the
  system does, where data flows, what the implicit conventions are, and which
  files are dangerous to touch first — producing a living CODEBASE.md with
  active modes for PR pre-flight, task mapping, and mid-PR file risk assessment.
version: 1.3.1
---

# Codebase Onboarding

Systematic orientation. Stop guessing. Build the right mental model before
touching anything — then keep it live as you work.

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
| About to modify a specific file mid-ramp | **touch** |
| About to push a PR — catch issues before review | **preflight** |
| Assigned a ticket or feature — map it to the codebase | **task** |

Default to **join** if unclear. `touch`, `preflight`, and `task` are ongoing
modes — they require an existing CODEBASE.md from a prior session.

---

## Intake: Ask First

Before running any orientation phase (join / return / audit), ask two questions.
The answers reshape every phase that follows.

### Question 1: Technical profile

Ask:

> "Are you a developer who can read code and run terminal commands, or are you
> non-technical — a PM, designer, analyst, or executive who needs to understand
> the system without diving into the code itself?"

Then explain the difference:

> **If you're technical:** I'll run shell commands, read source files, trace
> execution paths, and map git history. Output includes code snippets, file
> paths, and conventions — things you can act on directly. You'll also get a
> local dev guide and PR pre-flight support.
>
> **If you're non-technical:** I'll run all the same investigation but translate
> everything into plain language. No code in the output. You'll get a visual
> architecture diagram, priority-ranked questions for your next engineering
> meeting, and an executive brief you can share with stakeholders.

---

### Question 2: Goal

Wait for the answer to Question 1, then tailor the examples:

**If technical:**
> - Make a contribution or fix a specific bug
> - Take ownership — become the go-to maintainer
> - Review for quality, security, or architecture concerns
> - Evaluate an OSS project before contributing
> - Get up to speed after being away for months

**If non-technical:**
> - Understand what the system does and how it fits together
> - Assess risk before a launch, acquisition, or vendor decision
> - Identify what's slowing the team down
> - Have a more informed conversation with engineers
> - Prepare for a roadmap, sprint planning, or board conversation

---

**Profile + Goal → what changes:**

| Profile + Goal | What changes |
|----------------|-------------|
| Technical + contribute | Full workflow: Phases 0–7, local dev guide, Phase 8 |
| Technical + own/maintain | Full depth; extra attention to Danger Zones and authorship |
| Technical + review | Phases 0–6; security/quality lens; skip Phase 8 |
| Technical + evaluate OSS | audit mode — contributor signal, merge rate, PR velocity |
| Non-technical + understand | Phases 0–6; plain language; diagram; executive brief |
| Non-technical + decide | Phases 0–6 + recommendation section in executive brief |
| Non-technical + evaluate | audit mode; go/no-go framing in executive brief |

**Large codebases (>100k LOC):** After Phase 0, ask: "Which subsystem or area is most relevant to your goal?" Scope Phases 1–4 to that area. Investigating a 500k-line Rails monolith end-to-end produces noise, not orientation.

---

## Phase Order by Mode

| Phase | join | return | audit |
|-------|------|--------|-------|
| 0 — Bootstrap | ✓ first | ✓ first | ✓ first |
| 1 — Critical Paths | ✓ | ✓ | ✓ |
| 2 — Conventions | ✓ | ✓ after Phase 9 | ✓ |
| 3 — Danger Zones | ✓ | ✓ after Phase 9 | ✓ |
| 4 — Gotcha Detector | ✓ | ✓ | ✓ |
| 5 — Local Dev Guide | technical only | technical only | skip |
| 6 — Team Questions | technical: 1:1 format | technical: 1:1 format | technical: 1:1 format |
|                    | non-technical: meeting format | non-technical: meeting format | non-technical: meeting format |
| 7 — Executive Brief | non-technical only | non-technical only | non-technical only |
| 8 — First Contribution | technical only | technical only | skip |
| 8b — Ramp-up Timeline | technical only | technical only | skip |
| 9 — Archaeology | skip | ✓ before Phase 2 | skip |
| 10 — Contributor Signal | skip | skip | ✓ |

**In return mode:** run Phase 9 (Archaeology) immediately after Phase 1.

---

## Output: CODEBASE.md

```
CODEBASE.md
├── What This Is          # one-paragraph system description
├── Architecture Map      # Mermaid diagram + component description
├── Critical Paths        # entry points → processing → exit
├── External Integrations # third-party APIs, queues, webhooks — what needs mocking locally
├── Local Dev Guide       # technical only: step-by-step to get it running
├── Conventions           # implicit rules the README doesn't mention
├── Danger Zones          # what not to touch first, and why
├── Gotchas               # what silently burns new contributors
├── Team Questions        # technical: 1:1 format | non-technical: meeting format
├── Executive Brief       # non-technical only: one-page health summary
├── Ramp-up Timeline      # technical only: week-by-week gates derived from findings
├── Open Questions        # still unclear — actively maintained
└── Contribution Log      # join/return: changes + learnings
                          # audit: merge rate, PR velocity, go/no-go
```

### Confidence calibration

Every section carries a confidence tag:

| Tag | Meaning |
|-----|---------|
| ✅ Verified | Based on CI config, git history, or explicit documentation |
| ⚠️ Inferred | Based on patterns — likely but not confirmed |
| ❓ Gap | Couldn't assess from code — needs human confirmation |

Gap sections automatically feed into Team Questions. If you wrote ❓, there
must be a corresponding question.

Update CODEBASE.md at the end of each phase. Do not defer.

---

## Phase 0: Bootstrap

```
1. README.md / README.rst    → what does it claim to do?
2. CLAUDE.md / AGENTS.md     → what has an AI already learned here?
3. CONTRIBUTING.md           → what does the team care about?
4. package.json / go.mod /
   pyproject.toml / Cargo.toml → language, deps, run scripts
5. Makefile / justfile        → available commands
6. .github/workflows/         → what CI runs — the ground truth
```

CI is the most honest documentation. If it conflicts with the README, CI wins.

```bash
ls -la && head -50 README.md
ls .github/workflows/ 2>/dev/null
grep -E "run:|script:" .github/workflows/*.yml 2>/dev/null | head -20
gh issue list --state open --limit 5 2>/dev/null
gh pr list --state open --limit 5 2>/dev/null
```

**Gate:** Write "What This Is" in CODEBASE.md with a confidence tag. One
paragraph, no jargon. Can't write it? Read more — don't proceed.

---

## Phase 1: Map the Critical Paths

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

# Monorepo
ls packages/ apps/ services/ 2>/dev/null | head -20

# External integrations — what does this system call out to?
grep -rnil "stripe\|twilio\|sendgrid\|mailgun\|sentry\|datadog\|launchdarkly\|segment\|mixpanel\|amplitude\|aws\|s3\|sqs\|sns\|pubsub\|kafka\|rabbitmq" \
  --include="*.go" --include="*.ts" --include="*.py" --include="*.js" \
  | grep -v "node_modules\|.git\|vendor\|test\|spec" | head -15
grep -rn "baseURL\|base_url\|API_URL\|WEBHOOK_URL\|SERVICE_URL" \
  --include="*.env*" --include="*.example" --include="*.ts" --include="*.go" -h \
  | grep -v "^#" | sort -u | head -10
```

Trace each entry point one level deep: format in → transformation → format out.
Write **Critical Paths**, **Architecture Map**, and **External Integrations** in CODEBASE.md.

**External Integrations** — list what the system calls out to and what that means locally:

```markdown
## External Integrations ⚠️ Inferred

| Service | Purpose | Local behavior |
|---------|---------|---------------|
| Stripe  | Payments | Needs STRIPE_WEBHOOK_SECRET; use test mode keys |
| Twilio  | SMS alerts | Requests succeed but no SMS sent in dev |
| S3      | File storage | LocalStack or mock needed; fails silently otherwise |
| Redis   | Job queue | docker-compose starts it; required for background jobs |
```

If an integration has no local substitute, mark it ❓ Gap and add a Team Question.

### Architecture Map — generated for all users

**Technical users** (file paths, data flow):
```mermaid
graph LR
    Client -->|HTTP| API[api/routes.go]
    API --> Auth[auth/middleware.go]
    Auth --> Handler[handlers/user.go]
    Handler --> DB[(postgres)]
    Handler --> Cache[(redis)]
```

**Non-technical users** (plain labels, same structure):
```mermaid
graph LR
    User -->|sends request| API[Web API]
    API --> Auth[Login Check]
    Auth --> Logic[Business Logic]
    Logic --> DB[(Database)]
    Logic --> Cache[(Fast Cache)]
```

Cap at 10 nodes. The diagram is the most shareable artifact — a stakeholder
can paste it into Notion or a slide deck directly.

---

## Phase 2: Extract Conventions

```bash
git log --format="%s" -30
git log --format="%s" | grep -oE "^[a-z]+(\([^)]+\))?" | sort | uniq -c | sort -rn | head -10
git log --format="%s" | grep -i "test\|spec\|fix" | wc -l
git log --format="%s" | grep -i "wip\|todo\|tmp" | wc -l
git log --format=format: --name-only | grep -v "^$" | sort | uniq -c | sort -rn | head -15
git log --format="%ae" --follow -- src/ | sort | uniq -c | sort -rn | head -10
```

Extract what a contributor would get wrong without being told:
- Commit message format (conventional commits? ticket prefix? freeform?)
- PR size norm (focused or batched?)
- Test discipline (every commit touches tests, or separate?)
- Branch naming, squash vs merge, rebase policy

Write **Conventions** with a confidence tag. Prioritise implicit rules — the
README already covers the explicit ones.

---

## Phase 3: Map the Danger Zones

```bash
git log --format=format: --name-only | grep -v "^$" | sort | uniq -c | sort -rn | head -20
grep -rn "TODO\|FIXME\|HACK\|XXX" \
  --include="*.go" --include="*.ts" --include="*.py" --include="*.js" \
  | awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -10
find . -type f \( -name "*.go" -o -name "*.ts" -o -name "*.py" -o -name "*.js" \) \
  ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/vendor/*" \
  -exec wc -l {} + 2>/dev/null | sort -rn | head -15
git log --format="%s" | grep -i "revert\|rollback" | head -10
```

Write **Danger Zones** as a table:

```
| File / Area         | Why dangerous                         | When to touch  |
|---------------------|---------------------------------------|----------------|
| src/core/engine.go  | 2,847 lines, 47 TODOs, in 89% of PRs | After 4+ weeks |
| migrations/         | Schema changes need team coordination | Never solo     |
| auth/               | No tests, last touched 18 months ago  | With review    |
```

---

## Phase 4: Gotcha Detector

**(all modes)**

Hunts for what silently burns every new contributor — not in the README, not
in the git log, not mentioned by anyone.

```bash
# Env vars in code but missing from .env.example
grep -rn "process\.env\." --include="*.ts" --include="*.js" -h \
  | grep -oE 'process\.env\.[A-Z_]+' | sort -u > /tmp/env_used.txt
grep -rn "os\.environ\|os\.Getenv" --include="*.py" --include="*.go" -h \
  | grep -oE '[A-Z_]{3,}' | sort -u >> /tmp/env_used.txt
grep -v "^#" .env.example .env.sample 2>/dev/null | cut -d= -f1 | sort > /tmp/env_documented.txt
comm -23 <(sort -u /tmp/env_used.txt) /tmp/env_documented.txt | head -10

# Pre-commit vs CI divergence
cat .pre-commit-config.yaml 2>/dev/null | grep -A1 "  - id:"
ls .git/hooks/ 2>/dev/null | grep -v "\.sample"

# Tests with global state (break when parallelised)
grep -rn "global\|singleton\|module.*cache\|shared.*state" \
  --include="*.test.*" --include="*_test.*" -l | head -10

# Unreferenced setup scripts
find . \( -name "setup.sh" -o -name "bootstrap.sh" -o -name "seed.sh" \
  -o -name "init.sh" \) ! -path "*/.git/*" ! -path "*/node_modules/*" 2>/dev/null \
  | while read f; do
      grep -ql "$(basename $f)" README.md CONTRIBUTING.md 2>/dev/null \
      || echo "UNREFERENCED: $f"
    done

# Port conflicts in tests
grep -rn "localhost\|127\.0\.0\.1\|:8080\|:3000" \
  --include="*.test.*" --include="*_test.*" -l | head -10

# Flaky test markers and skips
grep -rn "@pytest.mark.flaky\|@pytest.mark.skip\|it\.skip\|xit(\|xdescribe(\|\.todo(\|t\.Skip(" \
  --include="*.test.*" --include="*_test.*" -l | head -10

# Approximate test suite run time from CI logs
grep -B2 -A2 -i "test\|pytest\|jest\|go test" .github/workflows/*.yml 2>/dev/null \
  | grep -i "timeout\|minutes\|took\|elapsed" | head -5
```

Write **Gotchas** — specific, not generic:

```markdown
## Gotchas ✅ Verified

- `STRIPE_WEBHOOK_SECRET` required but absent from `.env.example` —
  payments fail silently without it
- Pre-commit runs `eslint --fix`; CI runs `eslint` — passes locally,
  fails CI if you don't re-stage after the hook fires
- `auth/` tests share a singleton connection — `pytest -n 4` causes
  random failures; always run `pytest -p no:xdist auth/`
- `scripts/seed.sh` must run before tests — not in README; fails with
  a cryptic foreign key error if skipped
- 14 tests marked `@pytest.mark.flaky` in `tests/payments/` — they pass
  on retry; don't treat a single failure there as a regression
- Full test suite takes ~12 minutes; run `pytest tests/unit/` (~45s) for
  fast local feedback, CI runs the full suite
```

If nothing found: write `## Gotchas ✅ Verified — None found`. That's signal too.

---

## Phase 5: Local Dev Guide

**(technical users only — join and return modes)**

Synthesise everything found across Phases 0–4 into a step-by-step guide for
getting the codebase running locally. This is the document every new contributor
wishes existed on day one.

```bash
# Runtime requirements from manifests
cat package.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('engines',''))" 2>/dev/null
cat .tool-versions 2>/dev/null    # asdf versions
cat .nvmrc 2>/dev/null            # Node version
cat .python-version 2>/dev/null   # Python version
cat go.mod 2>/dev/null | head -5  # Go version

# Docker / service dependencies
cat docker-compose.yml 2>/dev/null | grep -E "image:|ports:" | head -20

# Migration count and order
ls -1 migrations/ db/migrations/ 2>/dev/null | wc -l
ls -1 migrations/ db/migrations/ 2>/dev/null | head -5

# Available run scripts
cat package.json 2>/dev/null | python3 -c \
  "import json,sys; [print(k,':',v) for k,v in json.load(sys.stdin).get('scripts',{}).items()]" 2>/dev/null
grep -E "^[a-zA-Z].*:" Makefile 2>/dev/null | head -20
```

Write **Local Dev Guide** as an ordered list a new contributor can follow
verbatim. Every step must be a real command or a real instruction — no vague
"configure your environment" steps:

```markdown
## Local Dev Guide ✅ Verified

### Prerequisites
- Node.js 18+ (required by package.json engines)
- PostgreSQL 14+ (from docker-compose.yml)
- Redis 7+ (from docker-compose.yml)

### Setup
1. `cp .env.example .env`
2. Set these missing variables (not in .env.example — see Gotchas):
   - `STRIPE_WEBHOOK_SECRET` — ask alice@example.com for the dev key
   - `JWT_SECRET` — any 32-char random string works locally
3. `npm install`
4. `docker-compose up -d postgres redis`
5. `npm run db:migrate`         ← runs 47 migrations
6. `node scripts/seed.sh`       ← not in README; required for tests
7. `npm run dev`                → starts on http://localhost:3000

### Verify
`curl http://localhost:3000/health` → should return `{"status":"ok"}`

### Run tests
`npm test`                      ← what CI runs (not `make test` in README)
`pytest -p no:xdist auth/`      ← auth/ specifically (parallel breaks it)

### Common failures
- Migrations fail → PostgreSQL not running or DATABASE_URL not set
- Tests fail randomly → run auth/ without parallelism (see above)
- Stripe errors → STRIPE_WEBHOOK_SECRET missing from .env
```

---

## Phase 6: Team Questions

**(all modes — content varies by profile)**

Every phase surfaces things code can't answer. After Phases 1–5 (or Phase 9 in
return mode), review every ❓ Gap tag and every unexplained anomaly. Generate
the **Team Questions** section — format depends on profile.

### For technical users — 1:1 format

Three priority tiers. Criteria: blast radius if you get it wrong.

```
🔴 Blocking  — can't write safe code without this. Ask in the first hour.
🟡 Important — affects how you work this week. Ask in your first 1:1.
🟢 Nice-to-know — useful context, not urgent.
```

Questions must be specific — not "why is X like this" but "X has no tests and
was last touched 18 months ago — is that intentional or a known gap?"

**Example:**
```markdown
## Team Questions ✅ Verified

### 🔴 Blocking
1. `STRIPE_WEBHOOK_SECRET` is in code but not in `.env.example`. Shared
   dev key, or do I set up my own Stripe account?
2. CI runs `pytest -x`, README says `make test`. Which for local dev?

### 🟡 Important
3. `payments/sync.go` reverted 3× in 6 months — active fix, or avoided?
4. Auth has no tests, last touched 18 months ago — known gap or stable?

### 🟢 Nice-to-know
5. `core/engine.go` is 2,400 lines — plan to break it up, or intentional?
```

Aim for 2–4 blocking, 3–5 important, 2–4 nice-to-know. Under 5 total means
you weren't paying attention. Over 12 means you're not filtering.

### For non-technical users — meeting format

Generate questions framed for group settings, not a 1:1 with an engineer.
Group by the meeting type most relevant to the user's stated goal:

```markdown
## Team Questions ✅ Verified

### For your next sprint planning
- The payment module has broken and been reverted 3 times this year —
  is there work scheduled to fix it, and what's at risk if we ship
  features that touch it this sprint?
- Are there any areas the team is actively avoiding due to risk?

### For your next roadmap review
- Which parts of the system carry the most technical risk for our
  planned features — where are we most likely to hit unexpected slowdowns?
- Is there tech debt that needs investment before we can safely build X?

### For a board or investor conversation
- How would you describe the overall health of the engineering foundation?
- What's the one area of the codebase that worries the team most, and
  what's the plan for it?
```

---

## Phase 7: Executive Brief

**(non-technical users only — all modes)**

After Phase 6, synthesise all findings into a single-page document in business
language. This is what gets shared with directors, investors, or stakeholders
making decisions about this codebase.

No code. No file paths. No technical jargon. Every finding translated to
business impact.

**Format:**

```markdown
## Executive Brief ✅ Verified

### What this system does
[One sentence. What it does, who uses it, what it enables.]

### Codebase health summary

| Area | Status | Business impact |
|------|--------|----------------|
| Core engine | 🔴 High risk | Changes here are slow and bug-prone |
| Payments | 🟡 Unstable | Has broken 3× in 6 months; customer-facing risk |
| Authentication | 🟡 Untested | No safety net; bugs affect all users |
| API layer | 🟢 Healthy | Well-maintained, stable |

### Top risks — in plain language
1. **Payment instability:** The payment processing module has broken and
   been reverted three times in six months. Any new work touching payments
   carries a meaningful risk of customer-facing outage.
2. **Untested authentication:** Login and session management have no
   automated tests. Bugs here affect every user and are hard to catch
   before they reach production.
3. **Core engine debt:** The central processing layer has significant
   known debt. Adding features or fixing bugs there takes longer than
   it should and is prone to unexpected breakage.

### Recommended questions for your next engineering conversation
1. What's the plan for the payment instability — is there a fix in
   progress, and what's the timeline?
2. Is there a roadmap for adding test coverage to authentication?
3. Which debt area is costing the most in engineer time right now,
   and where should we invest first?

### Overall assessment
[One sentence tied to the user's stated goal from intake:]

- **"assess risk before launch"** → Is this safe to ship this sprint, or does
  something need fixing first? Name the blocker if there is one.
- **"evaluate before acquisition/vendor decision"** → Go, no-go, or go with
  conditions. State the condition explicitly.
- **"prepare for roadmap/board conversation"** → What's the single most
  important engineering investment needed, and what business outcome does
  it unlock?
- **"understand what the system does"** → One sentence on what it is,
  who it serves, and how healthy the foundation is.
```

---

## Phase 8: First Safe Contribution

**(technical users — join and return modes only)**

Find a specific candidate — file, line, fix — not just a category.

```bash
# Failing tests
npm test 2>&1 | grep -E "FAIL|✗|Error" | head -20
pytest --tb=no -q 2>&1 | grep -E "FAILED|ERROR" | head -20
go test ./... 2>&1 | grep -E "FAIL|panic" | head -20

# Lint / type errors
npm run lint 2>&1 | head -30
npx tsc --noEmit 2>&1 | head -30
golangci-lint run 2>&1 | head -30
ruff check . 2>&1 | head -30

# Good first issues
gh issue list --label "good first issue" --limit 10 2>/dev/null
gh issue list --label "help wanted" --limit 10 2>/dev/null

# Broken doc examples
grep -rn "^\`\`\`" docs/ README.md --include="*.md" -A5 \
  | grep -E "^\$ |^> " | head -20
```

Output: one candidate with file + line + what's wrong + fix + why it's safe.
Nothing found → say so explicitly.

```
✗ Refactor (too much blast radius)
✗ New feature (approach not clear yet)
✗ Anything in a Danger Zone
✗ Cleanup you don't fully understand yet
```

```bash
git diff --stat   # verify no Danger Zone files in the diff
```

Claude finds and drafts. Human runs CI, reviews, submits.

Write what was learned in **Contribution Log**.

---

## Phase 8b: Ramp-up Timeline

**(technical users — join and return modes only)**

After Phases 0–8, generate a week-by-week plan derived from what was actually
found — not generic onboarding advice. Every checkpoint is grounded in the
specific state of this codebase.

**How to derive each week:**

- **Week 1** — driven by: local dev guide complexity, blocking team questions,
  first safe contribution target
- **Week 2** — driven by: convention count and strictness, PR process signals
  from git log, important team questions still open
- **Week 4** — driven by: number of danger zones, critical path complexity,
  depth of archaeology (return mode), authorship breadth

Checkboxes must be specific to this codebase — not "understand the system" but
"can explain the auth → handler → DB path without looking at CODEBASE.md."

**Example output:**

```markdown
## Ramp-up Timeline ⚠️ Inferred

### Week 1 — get oriented and unblocked

Technical gates:
  □ Local dev running and health check passes
  □ STRIPE_WEBHOOK_SECRET and JWT_SECRET added to .env (ask alice@)
  □ All 47 migrations run, seed data loaded, tests passing locally

Knowledge gates:
  □ Can explain what the system does without looking at CODEBASE.md
  □ Can trace a request from Client → API → Auth → Handler → DB
  □ Blocking team questions answered (2 of them — see Team Questions 🔴)

Contribution gate:
  □ First safe contribution submitted (target: test_auth.py line 47)

### Week 2 — know how the team works

Convention gates:
  □ First PR reviewed and merged without commit message feedback
  □ Conventional commits format used without checking CODEBASE.md
  □ PR size within team norm (< 400 lines based on git log analysis)

Relationship gates:
  □ Important team questions answered (3 of them — see Team Questions 🟡)
  □ Know who to ping for auth (alice@), payments (bob@), API (bob@)

### Week 4 — own the codebase

Depth gates:
  □ Can name all Danger Zones without looking at CODEBASE.md
  □ Touch mode no longer needed for files outside Danger Zones
  □ Can review someone else's PR for convention compliance

Contribution gate:
  □ Second contribution: something outside the "safe" category
  □ CODEBASE.md updated with anything that was wrong or missing

### Return mode only — recovery gate (end of Week 1)
  □ Archaeology complete: key decisions documented in CODEBASE.md
  □ "What changed while I was away" fully absorbed
  □ Know which prior mental model assumptions are now wrong
```

Write this as **Ramp-up Timeline** in CODEBASE.md immediately after Team
Questions. For return mode, include the recovery gate. Adjust timelines if the
codebase is unusually large (>100k lines → add a week) or simple (<5k lines →
compress weeks 1–2 into one).

---

## Phase 9: Archaeology

**(return mode only — run before Phases 2 and 3)**

**If CODEBASE.md already exists from a prior session, start here:**

Read CODEBASE.md and compare its claims against current reality before running any commands. Ask: what has drifted since this was written?

```bash
# When was CODEBASE.md last updated?
git log --follow --format="%ad %s" --date=short -- CODEBASE.md | head -5

# What changed in the codebase since then?
git log --since="$(git log --follow -- CODEBASE.md \
  --format='%ad' --date=short | head -1)" \
  --format=format: --name-only | grep -v "^$" \
  | sort | uniq -c | sort -rn | head -20

# Did any Danger Zones get touched heavily?
# (cross-reference against CODEBASE.md Danger Zones section)
```

Mark outdated CODEBASE.md sections as `⚠️ Stale` before continuing. This is the most valuable output of return mode — knowing what the old mental model got wrong.

```bash
git log --all --format="%ad %s" --date=short | head -40
find . -name "ADR*" -o -name "DECISION*" -o -path "*/docs/*.md" 2>/dev/null | head -10
git stash list
git log --all --oneline --decorate | head -20
find . -name "*.todo" -o -name "NOTES*" -o -name "SCRATCH*" 2>/dev/null
git log --format="%s" | grep -i "fix\|revert\|hotfix\|broke" | head -10
```

Add **Archaeology Notes** to CODEBASE.md:
- What you rediscovered that still makes sense
- What you'd do differently now
- What you found that surprised you
- What CODEBASE.md claimed that's no longer true (mark those sections ⚠️ Stale)

Then continue to Phase 2. Archaeology reframes what you'll see there.

---

## Phase 10: Contributor Signal

**(audit mode only)**

```bash
git log --format="%ad" --date=short | head -5
gh issue list --state open --limit 5
gh pr list --state open --limit 5
gh pr list --state closed --limit 20 | grep -v "MERGED"
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
responsiveness, and go/no-go recommendation with reasoning.

---

## Touch Mode: Before You Modify Anything

**Requires an existing CODEBASE.md. Invoke at any time:**

**If CODEBASE.md doesn't exist:** Run a reduced assessment from `git log` and file inspection alone — Danger Zone lookup unavailable, but commit history, authorship, and known issues are still accessible. Output a warning: "No CODEBASE.md — running limited touch assessment. Run join mode for full context." Offer to run join before proceeding.

**If CODEBASE.md exists:** Check when it was last updated before using it.
```bash
git log --follow --format="%ar" -- CODEBASE.md | head -1
```
If older than 4 weeks, warn: "⚠️ CODEBASE.md last updated [X] — Danger Zone and convention data may be stale. Proceed with caution or run return mode first."

> "I'm about to modify `[file or area]` — run touch mode."

```bash
git log --follow -20 --oneline -- [file]
git log --follow --format="%ae" -- [file] | sort | uniq -c | sort -rn | head -5
grep -n "TODO\|FIXME\|HACK\|XXX" [file] | head -10
grep -rn "[filename_without_ext]" --include="*.test.*" --include="*_test.*" -l | head -10
git log --follow --format="%s" -- [file] | grep -i "revert\|rollback" | head -5
grep -F "[file]" CODEBASE.md | head -5
```

**Output format:**

```
Before You Touch: auth/middleware.go

Risk level: HIGH — listed in Danger Zones

Recent commits:
  3 days ago   fix: token expiry edge case       alice@example.com
  2 weeks ago  REVERT: "refactor auth flow" — broke staging
  1 month ago  fix: race condition in session validation

Who to ping: alice@example.com (14 of last 20 commits here)

Known issues:
  Line 47   TODO  refresh token rotation not implemented
  Line 203  FIXME breaks with multiple active sessions

Tests covering this:
  tests/auth/middleware_test.go
  tests/integration/session_test.go

  Run these now, before editing, to establish a baseline:
  pytest tests/auth/middleware_test.go tests/integration/session_test.go
  A failure before you start is not your bug. A failure after is.

Watch out for:
  Session singleton on line 89 has non-obvious global state —
  this is what caused the revert two weeks ago

Suggested prompt for your next message:
  "In auth/middleware.go, [describe your specific change].
   Be minimal — only change what's needed for [your goal].
   Don't touch the session singleton on line 89."
```

---

## Preflight Mode: Before You Push

**Requires an existing CODEBASE.md. Invoke before opening a PR:**

**If CODEBASE.md doesn't exist:** Preflight cannot assess Danger Zones, conventions, or file ownership without it. Run a minimal check: branch name, commit message format from git log patterns, presence of test files in diff, credential scan. Output: "No CODEBASE.md — running minimal preflight. Danger Zone check unavailable. Run join mode first for full coverage." Do not generate a PR description without CODEBASE.md context.

**If CODEBASE.md exists:** Check staleness first — convention and Danger Zone data older than 4 weeks may no longer reflect reality.
```bash
git log --follow --format="%ar" -- CODEBASE.md | head -1
```
If stale, prepend a warning to the preflight output.

> "Run preflight on my current changes."

```bash
# What's in the diff?
git diff HEAD --name-only
git diff HEAD --stat

# Commit message
git log --format="%s" -1

# Branch name
git rev-parse --abbrev-ref HEAD

# Tests in the diff?
git diff HEAD --name-only | grep -iE "test|spec" | head -10
git diff HEAD --name-only | grep -viE "test|spec" | head -10

# Who last owned the touched files?
for f in $(git diff HEAD --name-only); do
  echo "--- $f ---"
  git log --follow --format="%ae" -- "$f" | sort | uniq -c | sort -rn | head -3
done

# PR size vs. team norm (from Phase 2 Conventions)
git diff HEAD --stat | tail -1   # e.g. "3 files changed, 412 insertions(+), 18 deletions(-)"

# Any Danger Zone files in diff?
# (cross-reference git diff HEAD --name-only against CODEBASE.md Danger Zones)

# Gotchas relevant to changed files?
# (cross-reference touched paths against CODEBASE.md Gotchas)
```

### Output format — every flag includes the fix

Each ❌ must include: what's wrong, the corrected version, the exact action to
take, and why it matters. ⚠️ includes context and what to watch for. ✅ is brief.

```
PR Pre-flight: feat/add-rate-limiting
Branch: feat/add-rate-limiting (3 source files, 0 test files changed)

────────────────────────────────────────────────────────
COMMIT MESSAGE
────────────────────────────────────────────────────────
❌ Doesn't follow conventional commits (team uses this in 28 of last 30 commits)

   Current:  "add rate limiting"
   Fix to:   "feat(api): add rate limiting to middleware"
             └─ type(scope): description
             Types in use: feat, fix, chore, docs, refactor
             Scopes in use: api, auth, payments, db

   Command:  git commit --amend -m "feat(api): add rate limiting to middleware"

────────────────────────────────────────────────────────
FILES CHANGED
────────────────────────────────────────────────────────
✅ api/routes.go — not a Danger Zone
✅ api/middleware.go — not a Danger Zone

⚠️  auth/middleware.go — DANGER ZONE
   Why: No tests, last touched 18 months ago, security-sensitive
   Action: Confirm this file needed changing. If yes:
     → alice@example.com must review (14 of last 20 commits here)
     → Watch for: session singleton on line 89 — caused a revert last month
     → Reference: CODEBASE.md Danger Zones, entry 3

────────────────────────────────────────────────────────
PR SIZE
────────────────────────────────────────────────────────
⚠️  430 lines changed — team norm is under 400 (based on last 30 merged PRs)

   Consider splitting: rate limiting logic vs. test files
   or: api/ changes vs. auth/ changes (different reviewers anyway)

────────────────────────────────────────────────────────
TEST COVERAGE
────────────────────────────────────────────────────────
❌ No test files in diff (convention: every commit that touches source touches tests)

   Files changed without tests:
     api/middleware.go  → add tests to: tests/api/middleware_test.go
     auth/middleware.go → add tests to: tests/auth/middleware_test.go

   Closest existing test to follow:
     tests/api/logging_test.go  (added with "feat(api): add request logging")
     Pattern: TestMiddlewareName_ActionExpectedBehaviour

   Why it matters: CI will pass without tests, but this convention is
   enforced in code review — you'll get a comment.

────────────────────────────────────────────────────────
GOTCHAS AFFECTING CHANGED FILES
────────────────────────────────────────────────────────
⚠️  Pre-commit runs eslint --fix on api/ files; CI runs eslint without fix
   Action: After pre-commit hook fires, re-stage changed files before pushing
   Command: git add api/middleware.go && git push

⚠️  auth/ tests share a singleton — don't run them with -n flag
   Command: pytest -p no:xdist tests/auth/ (not pytest -n 4 tests/auth/)

────────────────────────────────────────────────────────
REVIEWERS
────────────────────────────────────────────────────────
Required:  alice@example.com → auth/middleware.go (Danger Zone, her area)
Suggested: bob@example.com   → api/ (12 of last 20 commits to api/)

────────────────────────────────────────────────────────
PR DESCRIPTION (draft — edit before posting)
────────────────────────────────────────────────────────
Title: feat(api): add rate limiting to middleware

## What
Added configurable rate limiting to the API middleware layer. Requests
exceeding the threshold return 429 Too Many Requests with a Retry-After
header.

## Why
[Fill in — why is this change needed now?]

## What to test
- [ ] Rate limit triggers correctly after N requests within window
- [ ] 429 response includes Retry-After header
- [ ] Requests within limit pass through without delay
- [ ] auth/middleware.go behaviour unchanged (verify existing auth tests pass)

## Notes for reviewers
- auth/middleware.go is touched (Danger Zone — alice@ required)
- No auth logic changed; rate limit call added before existing auth check
- Pre-commit will run eslint --fix; re-stage before pushing

────────────────────────────────────────────────────────
VERDICT
────────────────────────────────────────────────────────
⚠️  ADDRESS BEFORE PUSHING (2 items)

  1. Fix commit message:
     git commit --amend -m "feat(api): add rate limiting to middleware"

  2. Add tests — at minimum a happy-path test for each changed middleware:
     → tests/api/middleware_test.go
     → tests/auth/middleware_test.go
     Follow pattern in tests/api/logging_test.go

  Then: re-stage after pre-commit hook fires, then push.
```

**Verdict levels:**
- `✅ READY TO PUSH` — all checks pass; list what was verified
- `⚠️ ADDRESS BEFORE PUSHING` — fixable issues; list exact steps in order
- `❌ DO NOT PUSH` — Danger Zone touched without required reviewer, or breaking convention with no justification

Every fix in the verdict must be a concrete action — a command to run, a file
to edit, a person to add. Never "consider adding tests." Always "add a test to
`tests/api/middleware_test.go` following the pattern in `logging_test.go`."

---

## Task Mode: Map a Ticket to the Codebase

**Requires an existing CODEBASE.md. Invoke when starting any new piece of work:**

**If CODEBASE.md doesn't exist:** Run a degraded version from git history and file naming alone: find the most relevant files via `git log --all -S "[keyword]"`, identify recent contributors, flag obviously risky file types (migrations, auth, CI). Output: "No CODEBASE.md — running degraded task mode. Danger Zone context and convention history unavailable. Consider running join mode first."

**If CODEBASE.md exists:** Check staleness — task mapping based on 4-month-old Danger Zones may point you at files that are no longer risky (or miss ones that are now).
```bash
git log --follow --format="%ar" -- CODEBASE.md | head -1
```
If stale, flag it before the task output.

> "I've been assigned to add rate limiting to the API."
> "I need to fix the payment retry logic — what do I need to know?"
> "I'm picking up ticket #47 — where do I start?"

Task mode maps intent to the codebase using CODEBASE.md as the lens:

1. **Identify relevant files** — from Architecture Map and Critical Paths, where does this work live?
2. **Flag proximity to Danger Zones** — is the work adjacent to anything risky?
3. **Surface applicable conventions** — what does the team's pattern say about how to do this?
4. **Find similar past work** — has this been done before? Who did it?
5. **Identify who to loop in** — from authorship and expertise signals

```bash
# Has this kind of work been done before?
git log --format="%s %h" | grep -i "[keyword from task]" | head -10

# Who touched the relevant area last?
git log --follow --format="%ae" -- [relevant path] | sort | uniq -c | sort -rn | head -5

# Any open issues related?
gh issue list --search "[keyword]" --limit 5 2>/dev/null
```

**Output format:**

```
Task: Add rate limiting to the API

Relevant files:
  api/routes.go         — entry point; rate limiting hooks here
  api/middleware.go     — existing middleware pattern to follow ← start here

Danger Zone proximity:
  auth/middleware.go    ⚠️  adjacent — avoid touching unless necessary

Similar past work:
  "feat(api): add request logging middleware" — 3 months ago, bob@example.com
  Follow the same pattern: middleware.go, not routes.go

Conventions that apply:
  Every new middleware needs an integration test in tests/api/
  Middleware naming: [action]Middleware (e.g. rateLimitMiddleware)

Who to loop in:
  bob@example.com — built existing middleware, owns api/ (last 20 commits)

Risk level: LOW
  api/ is not a Danger Zone. Pattern is established. Bob can review.

Suggested first step:
  Read api/middleware.go (the logging middleware) — it's the template
  for what you're about to build.

Suggested starting prompt:
  "In api/middleware.go, following the same pattern as the logging
   middleware, add a rate limiting middleware. Don't touch
   auth/middleware.go. Add a test in tests/api/middleware_test.go."
```

---

## Keeping CODEBASE.md Current

Run when the codebase feels like it's drifted:

```bash
# What changed since CODEBASE.md was last updated?
git log --since="$(git log --follow -- CODEBASE.md \
  --format='%ad' --date=short | head -1)" \
  --format=format: --name-only | grep -v "^$" \
  | sort | uniq -c | sort -rn | head -20

# Danger Zones touched?
git log --since="2 weeks ago" -- src/core/ auth/ migrations/ --oneline | head -10

# CI changed?
git log --since="2 weeks ago" -- .github/workflows/ --oneline | head -5

# New large files?
find . -type f \( -name "*.go" -o -name "*.ts" -o -name "*.py" \) \
  ! -path "*/node_modules/*" ! -path "*/.git/*" \
  -newer CODEBASE.md -exec wc -l {} + 2>/dev/null | sort -rn | head -10
```

**Update when:** Danger Zone modified heavily, CI changed, new large file appeared,
new contributor joined, conventions visibly violated in recent PRs.

**Cadence:** weekly first month, monthly after.

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
| "I'll skip the local dev guide, I'll figure it out" | You'll spend 3 hours on a missing env var that's already in the Gotchas section |
| "I'll think of questions as they come up" | You won't — you'll be heads-down in code |
| "I don't need preflight, I've read the conventions" | Your mental model of conventions is probabilistic. Preflight is deterministic |
| "I know what this ticket needs, I don't need task mode" | You know the feature. You don't know which files to avoid |

---

## Red Flags

- Making changes before completing Phase 0
- Skipping the local dev guide and spending hours on setup instead
- First contribution touches a Danger Zone
- Team Questions are generic ("why is X written this way?") not specific
- Team Questions have no priority tiers — everything looks equally urgent
- Executive Brief uses technical jargon — if an exec can't read it, rewrite it
- CODEBASE.md sections have no confidence tags
- Pushing a PR without running preflight when touching a Danger Zone
- Starting a task without running task mode when the scope is unclear
- Abandoning CODEBASE.md after week one — it becomes more valuable as it grows
- Running return mode in join order — skipping archaeology misreads conventions

---

## Verification

**Core (all modes):**
- [ ] Can describe what the system does in one paragraph without looking at README
- [ ] Can trace a request from entry point to exit
- [ ] Architecture Map contains a Mermaid diagram (plain labels for non-technical)
- [ ] External Integrations table present — even if empty
- [ ] Every CODEBASE.md section has a confidence tag (✅ / ⚠️ / ❓)
- [ ] Gotchas section present — even if "none found"
- [ ] Danger Zones listed with reasons and "when to touch" guidance
- [ ] Open Questions section exists and is non-empty

**Technical users:**
- [ ] Local Dev Guide is an ordered list of real commands — no vague steps
- [ ] Local Dev Guide includes "verify it works" check and common failures
- [ ] Team Questions: 3 tiers, 5–12 questions total, all specific
- [ ] Phase 8 produced file + line + fix — not a category
- [ ] Ramp-up Timeline checkboxes reference actual file names and question numbers — not generic milestones
- [ ] Return mode Ramp-up includes recovery gate at end of Week 1

**Non-technical users:**
- [ ] Architecture diagram uses plain language labels
- [ ] Team Questions framed for group meetings, not 1:1s
- [ ] Executive Brief has no code, no file paths, no jargon
- [ ] Executive Brief overall assessment is framed for the user's stated goal — not generic

**return mode:**
- [ ] Archaeology Notes explains key decisions and what surprised you
- [ ] Phase 9 ran before Phase 2
- [ ] If CODEBASE.md existed, outdated sections marked ⚠️ Stale before updating

**audit mode:**
- [ ] Merge rate and PR-to-merge time documented
- [ ] Go/no-go decision with explicit reasoning

**Ongoing modes:**
- [ ] Touch: CODEBASE.md staleness checked before running
- [ ] Touch: risk level assessed before any Danger Zone modification
- [ ] Touch: covering tests listed with "run first" baseline instruction
- [ ] Touch: ends with a suggested scoped prompt for the next message
- [ ] Touch: if no CODEBASE.md, warning issued and join mode offered
- [ ] Preflight: CODEBASE.md staleness checked before running
- [ ] Preflight: PR size checked against team norm from Phase 2
- [ ] Preflight: every ❌ includes corrected version + exact command to fix it
- [ ] Preflight: every ⚠️ includes specific action and relevant CODEBASE.md reference
- [ ] Preflight: PR description draft included before verdict
- [ ] Preflight verdict lists fixes in execution order — not a list to interpret
- [ ] Preflight: if no CODEBASE.md, minimal check only with clear warning
- [ ] Task: CODEBASE.md staleness checked before running
- [ ] Task: relevant files, Danger Zone proximity, and reviewer identified before starting
- [ ] Task: ends with a suggested scoped starting prompt
- [ ] Task: if no CODEBASE.md, degraded mode with clear warning
