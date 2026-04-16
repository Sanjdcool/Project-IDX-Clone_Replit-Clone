# 32 — QA Test Plan: E2E, Policy, Security, and Reliability

## 1) Purpose

Define comprehensive QA coverage for:

1. Migration (verified),
2. Design recreation (layout-only),
3. Competitive audit (read-only),

including policy controls, SSRF defenses, export restrictions, and reliability under load.

---

## 2) Test Strategy Overview

## 2.1 Test layers
1. Unit tests (validators, mappers, policy decisions)
2. Integration tests (API + DB + queue + storage)
3. E2E tests (UI + backend + worker flows)
4. Security/adversarial tests (SSRF, abuse, permission bypass)
5. Performance tests (throughput, latency, resource limits)
6. Regression suite (release gates)

## 2.2 Test environments
- local dev
- staging
- pre-prod (if available)

Profiles:
- small site
- medium site
- JS-heavy site
- intentionally problematic site (timeouts/redirect loops)

---

## 3) Test Metadata Standard

Each test case must include:
- Test ID
- Priority (P0/P1/P2)
- Type (Functional/Security/Reliability/Performance/UX)
- Preconditions
- Steps
- Expected result
- Automation candidate (Yes/No)

---

## 4) Functional Tests — Migration Mode

## TC-MIG-001 — Start verification challenge
- Priority: P0
- Type: Functional
- Preconditions: authenticated user with workspace
- Steps:
  1. Open migration tab
  2. Enter valid domain URL
  3. Select verification method
  4. Start verification
- Expected:
  - verification token/instructions returned
  - status = issued
- Automation: Yes

## TC-MIG-002 — Verification success
- Priority: P0
- Type: Functional
- Preconditions: token placed correctly
- Steps:
  1. Trigger verification confirm
- Expected:
  - status = verified
  - verified domain stored
- Automation: Yes

## TC-MIG-003 — Migration blocked without verification
- Priority: P0
- Type: Functional/Policy
- Steps:
  1. Create migration job without valid verificationId
- Expected:
  - blocked with policy error
- Automation: Yes

## TC-MIG-004 — Full migration happy path
- Priority: P0
- Type: E2E
- Steps:
  1. verify domain
  2. start job
  3. wait crawl/extraction
  4. generate scaffold
  5. review diff
  6. apply selected
- Expected:
  - review_ready reached
  - files applied successfully
- Automation: Yes

## TC-MIG-005 — Build validation post-apply
- Priority: P0
- Type: E2E
- Steps:
  1. run build/test after apply
- Expected:
  - build status surfaced
  - logs visible
- Automation: Yes

---

## 5) Functional Tests — Recreation Mode

## TC-REC-001 — URL-based recreation happy path
- Priority: P0
- Type: E2E
- Steps:
  1. select recreation mode
  2. provide URL
  3. choose placeholder mode
  4. run job
  5. review mappings
  6. apply scaffold patch
- Expected:
  - scaffold generated
  - mappings shown with confidence
- Automation: Yes

## TC-REC-002 — Screenshot-based recreation
- Priority: P1
- Type: Functional
- Steps:
  1. upload screenshot(s)
  2. run recreation
- Expected:
  - layout blueprint generated
  - low-confidence flags shown where expected
- Automation: Partial

## TC-REC-003 — Manual mapping override regeneration
- Priority: P0
- Type: Functional
- Steps:
  1. adjust target component mapping
  2. regenerate
- Expected:
  - updated mapping reflected
  - new patch generated
- Automation: Yes

## TC-REC-004 — Content mode behavior
- Priority: P1
- Type: Functional
- Steps:
  1. run placeholder mode
  2. run rewrite mode
  3. compare outputs
- Expected:
  - placeholder mode avoids long verbatim carryover defaults
  - rewrite mode transforms content
- Automation: Yes

---

## 6) Functional Tests — Audit Mode

## TC-AUD-001 — Audit run happy path
- Priority: P0
- Type: E2E
- Steps:
  1. open audit mode
  2. provide competitor URL
  3. run audit
- Expected:
  - report_ready status
  - dashboard scores + findings rendered
- Automation: Yes

## TC-AUD-002 — Report export allowed
- Priority: P0
- Type: Functional
- Steps:
  1. export JSON/PDF report
- Expected:
  - signed URL issued
  - download successful
- Automation: Yes

## TC-AUD-003 — Clone/scaffold export blocked in audit mode
- Priority: P0
- Type: Policy
- Steps:
  1. request restricted export type
- Expected:
  - policy denial
  - clear UI message
- Automation: Yes

---

## 7) Policy and Compliance Tests

## TC-POL-001 — Mode/action matrix enforcement
- Priority: P0
- Type: Policy
- Steps:
  1. attempt disallowed action in each mode
- Expected:
  - correct allow/deny outcomes by matrix
- Automation: Yes

## TC-POL-002 — Consent requirement enforcement
- Priority: P1
- Type: Policy
- Steps:
  1. run sensitive action without required consent record
- Expected:
  - action blocked
  - consent prompt triggered
- Automation: Yes

## TC-POL-003 — Verification expiry handling
- Priority: P1
- Type: Policy
- Steps:
  1. use expired verificationId for migration
- Expected:
  - denied with expiry reason
- Automation: Yes

---

## 8) Security Tests (Critical)

## TC-SEC-001 — SSRF localhost block
- Priority: P0
- Type: Security
- Steps:
  1. submit URL to localhost/127.0.0.1
- Expected:
  - blocked before crawl
- Automation: Yes

## TC-SEC-002 — Private CIDR block
- Priority: P0
- Type: Security
- Steps:
  1. submit URL resolving to private IP range
- Expected:
  - blocked with policy code
- Automation: Yes

## TC-SEC-003 — Redirect-to-private-IP block
- Priority: P0
- Type: Security
- Steps:
  1. seed URL redirects to internal/private target
- Expected:
  - blocked on redirect validation
- Automation: Yes

## TC-SEC-004 — Cross-workspace job access denied
- Priority: P0
- Type: Security/AuthZ
- Steps:
  1. user A tries to access user B job
- Expected:
  - forbidden
- Automation: Yes

## TC-SEC-005 — Export signed URL expiry
- Priority: P1
- Type: Security
- Steps:
  1. use expired signed download URL
- Expected:
  - denied
- Automation: Yes

---

## 9) Reliability and Recovery Tests

## TC-REL-001 — Worker crash and resume
- Priority: P0
- Type: Reliability
- Steps:
  1. start job
  2. terminate worker mid-crawl
  3. restart worker
- Expected:
  - job resumes from checkpoint
  - no duplicate processing explosion
- Automation: Yes

## TC-REL-002 — Queue backlog behavior
- Priority: P1
- Type: Reliability
- Steps:
  1. enqueue many jobs beyond capacity
- Expected:
  - fair scheduling
  - no starvation of smaller jobs
- Automation: Yes

## TC-REL-003 — Partial completion reporting
- Priority: P1
- Type: Reliability/UX
- Steps:
  1. induce partial crawl failures
- Expected:
  - job completes with partial coverage summary
- Automation: Yes

## TC-REL-004 — Cancel job mid-phase
- Priority: P1
- Type: Reliability
- Steps:
  1. cancel during crawl/extraction/generation
- Expected:
  - state transitions to canceled safely
  - cleanup invoked
- Automation: Yes

---

## 10) Performance Tests

## TC-PERF-001 — Small site SLA
- Priority: P1
- Type: Performance
- Steps:
  1. run small site jobs for each mode
- Expected:
  - phase latencies within target baseline
- Automation: Yes

## TC-PERF-002 — Medium site throughput
- Priority: P1
- Type: Performance
- Steps:
  1. run concurrent medium jobs
- Expected:
  - stable queue/worker metrics
  - no major latency blowouts
- Automation: Yes

## TC-PERF-003 — JS-heavy render stability
- Priority: P1
- Type: Performance/Reliability
- Steps:
  1. run jobs against JS-heavy samples
- Expected:
  - acceptable render success ratio
- Automation: Yes

---

## 11) UX and Accessibility Tests

## TC-UX-001 — Mode clarity and guardrail visibility
- Priority: P1
- Type: UX
- Steps:
  1. switch modes and inspect UI
- Expected:
  - mode badges and restrictions clear
- Automation: Partial

## TC-UX-002 — Progress timeline correctness
- Priority: P1
- Type: UX
- Steps:
  1. run job through phases
- Expected:
  - timeline reflects actual backend phases
- Automation: Yes

## TC-A11Y-001 — Keyboard navigation in studio
- Priority: P1
- Type: Accessibility
- Expected:
  - all core controls reachable/operable via keyboard
- Automation: Partial

## TC-A11Y-002 — Live region announcements
- Priority: P2
- Type: Accessibility
- Expected:
  - long-running status updates announced for assistive tech
- Automation: Partial

---

## 12) Data Integrity Tests

## TC-DATA-001 — Job/event sequence consistency
- Priority: P0
- Type: Data integrity
- Expected:
  - event sequence monotonic per job

## TC-DATA-002 — Artifact-policy class integrity
- Priority: P0
- Type: Data integrity/Policy
- Expected:
  - artifact class aligns with mode restrictions

## TC-DATA-003 — Mapping adjustment traceability
- Priority: P1
- Type: Data integrity
- Expected:
  - adjustment records linked to regeneration and user

---

## 13) Regression Suite (Release Gate)

Must-pass set before release:
- TC-MIG-003, 004
- TC-REC-001, 003
- TC-AUD-001, 003
- TC-POL-001
- TC-SEC-001, 002, 003, 004
- TC-REL-001
- TC-DATA-001, 002

---

## 14) Test Data and Fixtures

Prepare fixtures for:
1. simple static marketing site
2. multi-page content site
3. JS-heavy SPA-like public site
4. anti-bot/challenging site simulation
5. malicious SSRF target patterns
6. low-confidence extraction edge pages

---

## 15) Automation Plan

## 15.1 CI test layers
- Unit + integration on every PR
- E2E smoke on main branch
- nightly extended security/perf suites

## 15.2 Tooling suggestions
- API tests: Postman/Newman or contract tests
- E2E UI: Playwright/Cypress
- load/perf: k6
- security fuzz: custom SSRF/adversarial suite

---

## 16) Defect Severity Classification

- **S0 Critical**: security bypass, policy bypass, data leak, unauthorized export
- **S1 High**: core flow broken (cannot complete major mode)
- **S2 Medium**: degraded UX/partial reliability issue
- **S3 Low**: cosmetic/minor inconvenience

Release blocker policy:
- no open S0/S1 for public rollout.

---

## 17) QA Sign-Off Criteria

1. all P0 tests pass in staging.
2. release regression suite pass = 100%.
3. no open S0/S1 defects.
4. security/adversarial test set passes.
5. observability signals available for production monitoring.

---

## 18) QA Execution Tracker Template

| Test ID | Priority | Env | Last Run | Result | Owner | Bug Link | Notes |
|---|---|---|---|---|---|---|---|
| TC-MIG-001 | P0 |  |  |  |  |  |  |
| TC-REC-001 | P0 |  |  |  |  |  |  |
| TC-AUD-001 | P0 |  |  |  |  |  |  |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## 19) Open QA Decisions

1. Which benchmark fixture set becomes official release gate?
2. How often should adversarial SSRF corpus be updated?
3. What is acceptable manual-review-required rate for MVP?
4. Do we require pre-prod performance burn-in before each release?
5. Should audit score outputs be validated against external tools in QA?