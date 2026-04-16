# 37 — Implementation Sequence Checklist (Execution-Ready)

## 1) Purpose

Provide an exact execution order to implement all planned features safely and efficiently:

- Migration (verified),
- Design recreation,
- Competitive audit (read-only),

with minimal rework and strong policy/security guarantees from day one.

---

## 2) Recommended Execution Order (High Confidence Path)

## Phase 0 — Setup and Alignment (Day 1–3)

- [ ] Confirm scope using files `21` to `36`.
- [ ] Freeze API/data contracts baseline (`27`, `29`).
- [ ] Create project board lanes:
  - Security/Policy
  - Backend Core
  - Workers/Pipeline
  - Frontend Studio
  - QA/Automation
  - Observability/DevOps

- [ ] Define release environments: dev, staging, beta.
- [ ] Assign owners per epic and declare DRI for each area.

**Exit criteria**
- [ ] Team signed off on architecture and delivery plan.
- [ ] Backlog broken into sprint-ready tickets.

---

## Phase 1 — Security + Policy Foundation First (Week 1–2)

### Backend / Security
- [ ] Implement policy engine scaffolding (`22`, `30`).
- [ ] Implement ownership verification APIs (`27`) + DB tables (`29`).
- [ ] Add SSRF-safe URL validation and network guards (`30`).
- [ ] Add mode/action matrix enforcement middleware.
- [ ] Add policy decision event logging (`29` + `30`).

### Frontend
- [ ] Build verification UI shell and policy banners (`28`).
- [ ] Implement mode switcher with guardrail messaging.

### QA
- [ ] Automate P0 policy/security tests:
  - migration blocked without verification
  - SSRF localhost/private-range blocks

**Exit criteria**
- [ ] Migration mode cannot run without verified ownership.
- [ ] SSRF core tests passing in staging.
- [ ] Policy deny/allow logs visible in dashboard.

---

## Phase 2 — Job Orchestration + Crawl Core (Week 2–4)

### Backend / Workers
- [ ] Implement `site_jobs` lifecycle APIs and status polling (`27`, `29`).
- [ ] Implement queue dispatcher + phase state machine (`23`).
- [ ] Implement crawl worker baseline (`24`):
  - URL normalization
  - scope filters
  - depth/page/runtime budgets
  - render strategy with safe defaults

- [ ] Persist crawl artifacts + page metadata tables (`29`).

### DevOps
- [ ] Provision worker autoscaling baseline.
- [ ] Configure job queue metrics and tracing (`31`).

### QA
- [ ] E2E test: create job → crawl progress → completion/partial completion.
- [ ] Reliability test: worker restart and resume checkpoint.

**Exit criteria**
- [ ] Jobs can be created, run, canceled, resumed.
- [ ] Crawl summaries available via API.
- [ ] Observability shows phase transitions and failures.

---

## Phase 3 — Extraction Pipeline (Week 4–5)

### Backend / AI pipeline
- [ ] Implement extraction stages (`25`):
  - structural segmentation
  - component candidate detection
  - token extraction
  - confidence scoring

- [ ] Persist extraction summaries/pages/tokens (`29`).
- [ ] Expose extraction summary endpoint (`27`).

### Frontend
- [ ] Build extraction preview panel:
  - templates
  - components
  - token snapshots
  - confidence buckets

### QA
- [ ] Validate extraction on:
  - static site
  - JS-heavy site
  - low-quality screenshot case

**Exit criteria**
- [ ] Extraction summary is stable and reviewable.
- [ ] Confidence distribution visible and accurate enough for manual review flow.

---

## Phase 4 — Mapping + Code Generation + Patch Pipeline (Week 5–7)

### Backend / Codegen
- [ ] Implement normalized mapping engine (`26`).
- [ ] Implement scaffold generation for primary target stack.
- [ ] Implement manual mapping adjustment endpoint (`27`).
- [ ] Emit patch plan consumable by existing diff/apply flow.

### Frontend
- [ ] Implement mapping review UI with overrides (`28`).
- [ ] Connect regenerate-from-adjustment flow.
- [ ] Integrate generated patch into existing review/apply UX.

### QA
- [ ] E2E: migration and recreation scaffold generation.
- [ ] Validate compile/build baseline after apply.

**Exit criteria**
- [ ] Users can generate scaffold, review diffs, and apply selected files.
- [ ] Manual mapping overrides regenerate correctly.

---

## Phase 5 — Feature Slice Completion by Mode (Week 7–9)

## A) Migration slice hardening
- [ ] End-to-end verified migration happy path stable.
- [ ] Build/test post-apply integration stable.

## B) Recreation slice completion
- [ ] URL input path stable.
- [ ] Screenshot input path stable (if enabled in this stage).
- [ ] Placeholder/rewrite/mixed content modes wired.

## C) Audit slice completion
- [ ] Read-only audit analytics pipeline implemented (`35`).
- [ ] Audit dashboard and findings table live.
- [ ] JSON/PDF report export enabled and policy-safe.

### QA
- [ ] Full mode matrix tests executed.
- [ ] Audit mode blocked from scaffold/raw export classes.

**Exit criteria**
- [ ] All three feature modes function end-to-end.
- [ ] Policy boundaries enforced across all modes.

---

## Phase 6 — Permissioning, Flags, and Plan Gates (Week 9–10)

### Backend
- [ ] Implement RBAC permission keys (`36`).
- [ ] Implement plan-based quotas/limits.
- [ ] Implement feature flag checks in API layer.
- [ ] Implement kill switches.

### Frontend
- [ ] Lock/hide UI by role/plan/flag.
- [ ] Show actionable denial reasons (verify/upgrade/request access).

### QA
- [ ] Role matrix tests.
- [ ] Plan limit boundary tests.
- [ ] Flag combination tests.
- [ ] Kill switch drill in staging.

**Exit criteria**
- [ ] Access is deterministic and auditable.
- [ ] Feature can be progressively rolled out safely.

---

## Phase 7 — Observability, Performance, and Security Hardening (Week 10–11)

### Observability
- [ ] Finalize dashboards/alerts (`31`).
- [ ] Add phase p95/p99 latency tracking.
- [ ] Enable anomaly alerts (policy blocks, SSRF spikes, export denials).

### Performance
- [ ] Load test queue and workers.
- [ ] Tune concurrency, retries, and backpressure.

### Security
- [ ] Run adversarial SSRF corpus.
- [ ] Run permission bypass test suite.
- [ ] Validate signed export URL expiry and access boundaries.

**Exit criteria**
- [ ] SLO baselines met in staging.
- [ ] No open critical security defects.

---

## Phase 8 — Beta Rollout (Week 11–12)

- [ ] Enable flags for internal users.
- [ ] Run closed beta with design partners.
- [ ] Monitor completion/failure/support metrics daily.
- [ ] Collect structured feedback and prioritize fixes.

**Exit criteria**
- [ ] Regression suite pass.
- [ ] Stable beta metrics over agreed observation window.

---

## 3) Parallel Work Plan (Who Builds What)

## Track A — Security/Policy
Files: `22`, `30`, `36`  
Starts immediately, never fully pauses.

## Track B — Backend Core + Data
Files: `23`, `27`, `29`  
Starts Week 1; unblocks all other tracks.

## Track C — Crawl/Extraction/Generation
Files: `24`, `25`, `26`, `34`, `35`  
Starts once core job orchestration is available.

## Track D — Frontend Studio UX
Files: `28`  
Starts in parallel with mocked APIs, then switches to real endpoints.

## Track E — QA + Observability
Files: `31`, `32`  
Starts early with test scaffolds; ramps through all phases.

---

## 4) Sprint Checklist Template (Reusable)

For each sprint, enforce:

- [ ] API contract update reviewed.
- [ ] DB migration reviewed and rollback tested.
- [ ] Unit + integration tests added.
- [ ] Security checks for new endpoints.
- [ ] Frontend state/error UX covered.
- [ ] Observability events added.
- [ ] QA cases mapped to changes.
- [ ] Documentation updated.

---

## 5) Critical Path Dependencies

1. Policy + verification must land before migration rollout.
2. Crawl outputs must stabilize before extraction tuning.
3. Extraction contracts must stabilize before mapping/codegen.
4. Mapping output must be patch-compatible before UX completion.
5. Plan gates/flags must be live before beta expansion.

---

## 6) Release Gates (Must Pass)

## Gate A — Internal Alpha
- [ ] migration verified flow works end-to-end
- [ ] SSRF protections validated
- [ ] core telemetry present

## Gate B — Closed Beta
- [ ] recreation + audit stable
- [ ] mode policy boundaries validated
- [ ] no open S0/S1 defects

## Gate C — GA Readiness
- [ ] reliability and latency targets met
- [ ] security/adversarial suite pass
- [ ] support runbooks complete
- [ ] kill switch drill passed

---

## 7) First 30 Engineering Tickets (Starter Backlog)

1. Policy middleware skeleton
2. Verification token issuance endpoint
3. Verification confirm endpoint
4. Verification DB schema migration
5. Site job create/status/cancel endpoints
6. Job state machine service
7. Queue dispatcher baseline
8. Crawl worker URL validator
9. SSRF CIDR block module
10. Redirect revalidation module
11. Crawl page persistence
12. Crawl summary endpoint
13. Extraction pipeline scaffold
14. Section segmentation module
15. Component detector baseline
16. Token extraction module
17. Extraction summary endpoint
18. Mapping engine v1
19. Codegen template pack (primary stack)
20. Patch planner adapter
21. Mapping override endpoint
22. Frontend Site Studio shell
23. Verification UI flow
24. Job progress timeline UI
25. Extraction preview panel
26. Mapping review panel
27. Audit dashboard shell
28. Export panel with policy responses
29. Observability dashboard v1
30. QA automation suite bootstrap

---

## 8) Risk-Based “Stop the Line” Conditions

Pause rollout immediately if any occur:
- critical SSRF or permission bypass discovered
- audit mode can export restricted artifacts
- migration runs without verified ownership
- repeated data leakage event in logs/artifacts
- critical queue/worker failure causing widespread job corruption

---

## 9) Final Execution Note

If timeline pressure increases, **do not** drop:
1. policy enforcement,
2. SSRF controls,
3. export restrictions,
4. observability minimums.

Instead reduce:
- screenshot advanced capabilities,
- multi-target audit complexity,
- non-critical UX polish.

This keeps release safe and reversible.