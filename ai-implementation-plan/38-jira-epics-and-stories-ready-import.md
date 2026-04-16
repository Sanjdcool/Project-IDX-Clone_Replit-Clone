# 38 — Jira Epics and Stories (Ready Import)

## 1) Purpose

This file provides a Jira-ready backlog structure for the full implementation plan (files 21–37), including:

- Epics
- Stories
- Subtasks
- Acceptance criteria
- Dependencies
- Suggested sprint sequencing
- Priority and estimate hints

Use this as a copy/paste source for Jira CSV/manual entry.

---

## 2) Recommended Jira Project Setup

## Issue Types
- Epic
- Story
- Task
- Sub-task
- Bug
- Spike

## Custom Fields (recommended)
- `Feature Mode` (Migration / Recreation / Audit / Shared)
- `Policy Risk` (Low / Medium / High)
- `Security Review Required` (Yes/No)
- `Rollout Stage` (Alpha / Beta / GA)
- `Service Area` (Frontend / Backend / Worker / Infra / QA / Security / Data)

---

## 3) Epic List

## EPIC-1 — Policy, Ownership Verification, and Compliance Foundation
**Goal:** Enforce legal-safe controls and ownership-gated migration.

## EPIC-2 — Job Orchestration, API Contracts, and Data Model
**Goal:** Implement robust job lifecycle and backend contracts.

## EPIC-3 — Crawl and Render Engine
**Goal:** Build safe, scalable crawl/render pipeline.

## EPIC-4 — Extraction Pipeline (Layout/Content/Token Intelligence)
**Goal:** Produce structured extraction artifacts with confidence scoring.

## EPIC-5 — Mapping and Code Generation Engine
**Goal:** Generate clean scaffold + patch plans from extraction output.

## EPIC-6 — Frontend Site Studio UX
**Goal:** Deliver mode-based UI flows, status, mapping review, and history.

## EPIC-7 — Competitive Audit (Read-Only) Analytics
**Goal:** Deliver scorecards/findings/recommendations with safe exports.

## EPIC-8 — Permissioning, Plan Gates, and Feature Flags
**Goal:** Control access by role, plan, and rollout flags.

## EPIC-9 — Security Hardening and Abuse Prevention
**Goal:** Complete SSRF defenses, export safety, anomaly controls.

## EPIC-10 — Observability, QA Automation, and Release Readiness
**Goal:** Ship dashboards, alerts, regression suites, and rollout gates.

---

## 4) Stories by Epic

## EPIC-1 — Policy, Ownership Verification, and Compliance Foundation

### STORY-1.1 Define mode/action policy matrix service
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- API-level policy decision endpoint available.
- Supports allow/deny by mode + action + context.
- Returns deterministic reason codes.
- Emits policy decision events.

### STORY-1.2 Build ownership verification challenge issuance
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Supports DNS TXT, HTML file, meta tag methods.
- Challenge token generated with expiry.
- Instructions payload returned.

### STORY-1.3 Build ownership verification confirmation flow
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Verification status transitions issued → verified/failed/expired.
- Domain scope stored and retrievable.
- Failure reasons surfaced.

### STORY-1.4 Persist legal consent records by policy version
**Priority:** P1  
**Estimate:** 3 pts  
**Acceptance Criteria:**
- Consent table writes include user/workspace/domain/mode/policy version.
- Consent status queryable during job preflight.

### STORY-1.5 Implement policy denial UX contract
**Priority:** P1  
**Estimate:** 3 pts  
**Acceptance Criteria:**
- Standard error envelope for policy denials.
- UI-ready remediation hint included.

---

## EPIC-2 — Job Orchestration, API Contracts, and Data Model

### STORY-2.1 Implement site job create/status/cancel endpoints
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Supports all 3 modes.
- Validates required fields per mode.
- Cancel transitions handled safely.

### STORY-2.2 Implement phase-based job state machine
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Valid transitions enforced.
- Durable job events written in sequence.
- Resume-ready checkpoints supported.

### STORY-2.3 Implement DB schema migration package
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Tables from file 29 created with indexes/constraints.
- Migration rollback tested.
- Seed fixtures available.

### STORY-2.4 Implement exports registry and signed URL broker
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Allowed export classes listed by job/mode.
- Signed links expire as configured.
- Blocked exports return policy errors.

---

## EPIC-3 — Crawl and Render Engine

### STORY-3.1 Build URL intake normalization and scoping module
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- URL canonicalization implemented.
- Scope derived from seed and mode policy.
- Duplicate URL suppression functional.

### STORY-3.2 Build crawl frontier manager with budgets
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Depth/page/runtime limits enforced.
- Trap detection baseline active.
- Frontier dedupe correctness validated.

### STORY-3.3 Implement render worker with wait strategies
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- domcontentloaded/networkidle modes supported.
- Render artifacts persisted.
- Per-page telemetry emitted.

### STORY-3.4 Implement checkpoint/resume support for crawl jobs
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Worker restart resumes from checkpoint.
- No runaway duplicate processing.

---

## EPIC-4 — Extraction Pipeline

### STORY-4.1 Implement structural segmentation engine
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Macro regions detected (header/main/footer etc.).
- Section boundaries inferred consistently.
- Section model persisted.

### STORY-4.2 Implement component candidate detectors (MVP set)
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- At least 10 core section/component types detected.
- Confidence score attached per detection.

### STORY-4.3 Implement style token extraction
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Color/typography/spacing tokens generated.
- Confidence and source frequency metrics available.

### STORY-4.4 Implement template clustering across pages
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Template IDs assigned with confidence.
- Outliers flagged for manual review.

---

## EPIC-5 — Mapping and Code Generation Engine

### STORY-5.1 Implement normalized mapping layer
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Extracted section/component maps to internal schema.
- Fallback mapping path exists for low confidence.

### STORY-5.2 Implement scaffold generator for primary stack
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Generates routes/pages/components/theme tokens.
- Output is lint/type/build friendly baseline.

### STORY-5.3 Implement content modes (placeholder/rewrite/mixed)
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Content mode setting respected.
- Placeholder default active for recreation mode.

### STORY-5.4 Implement patch planner adapter to existing apply flow
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Generated changes represented as patch operations.
- Diff/apply pipeline consumes output without conversion hacks.

### STORY-5.5 Implement mapping adjustment + incremental regeneration
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Per-section overrides accepted.
- Regeneration updates impacted files.

---

## EPIC-6 — Frontend Site Studio UX

### STORY-6.1 Build Site Studio shell with mode tabs
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Migration/Recreation/Audit/History tabs functional.
- Mode banner and guardrails always visible.

### STORY-6.2 Build migration verification and launch flow UI
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Verification method UI complete.
- Migration CTA disabled until verification success.

### STORY-6.3 Build job progress timeline and logs panel
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Phase updates reflect backend states.
- Cancel and retry actions wired.

### STORY-6.4 Build extraction preview + token preview UI
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Templates/components/tokens visible.
- Confidence indicators rendered.

### STORY-6.5 Build mapping review and override panel
**Priority:** P1  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Override component selection works.
- Regenerate action updates preview and patch.

### STORY-6.6 Build audit dashboard and findings explorer
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Scores/findings/recommendations visible.
- Filters by severity/category work.

### STORY-6.7 Build job history and detail views
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Filter/search supported.
- Job detail timeline/artifacts accessible.

---

## EPIC-7 — Competitive Audit (Read-Only) Analytics

### STORY-7.1 Implement audit analysis pipeline
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Structure/performance/SEO/component scoring produced.
- Findings include evidence and recommendations.

### STORY-7.2 Implement optional baseline comparison
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Delta comparisons generated when baseline URL supplied.

### STORY-7.3 Implement report exports (JSON/PDF)
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Exports generated and downloadable via signed URLs.
- Export events logged.

### STORY-7.4 Enforce audit read-only output restrictions
**Priority:** P0  
**Estimate:** 3 pts  
**Acceptance Criteria:**
- Scaffold/raw bundle exports denied in audit mode.

---

## EPIC-8 — Permissioning, Plan Gates, and Feature Flags

### STORY-8.1 Implement permission keys and role matrix checks
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Server-side permission checks for all endpoints.
- Role matrix enforced by mode/action.

### STORY-8.2 Implement plan-based limits and quotas
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Max jobs/pages/runtime by plan enforced.
- Limit denial codes standardized.

### STORY-8.3 Implement feature flags and kill switches
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Global/mode/export kill switches operational.
- Flag changes effective without redeploy.

---

## EPIC-9 — Security Hardening and Abuse Prevention

### STORY-9.1 Implement SSRF defenses with redirect revalidation
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- Private/internal ranges blocked.
- Redirect chain revalidated every hop.

### STORY-9.2 Implement worker network isolation policies
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Worker egress restrictions active.
- No internal service access from crawl runtime.

### STORY-9.3 Implement abuse detection and throttling
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Suspicious patterns detected.
- Progressive throttling actions supported.

### STORY-9.4 Implement security event alerting
**Priority:** P1  
**Estimate:** 3 pts  
**Acceptance Criteria:**
- SSRF/policy/export anomaly alerts routed with runbook links.

---

## EPIC-10 — Observability, QA Automation, and Release Readiness

### STORY-10.1 Implement core telemetry schema and instrumentation
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Correlation IDs on logs/traces/metrics.
- Phase-level metrics available.

### STORY-10.2 Build operational dashboards and alerts
**Priority:** P0  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Executive, ops, quality, and security dashboards live.
- Critical alerts enabled and tested.

### STORY-10.3 Implement automated P0 regression suite
**Priority:** P0  
**Estimate:** 8 pts  
**Acceptance Criteria:**
- P0 policy/security/flow tests run in CI.
- Must-pass gating enforced before release.

### STORY-10.4 Execute load and reliability qualification
**Priority:** P1  
**Estimate:** 5 pts  
**Acceptance Criteria:**
- Defined concurrency tests pass.
- Worker crash/resume and queue backlog behavior validated.

### STORY-10.5 Beta rollout readiness checklist and sign-off
**Priority:** P0  
**Estimate:** 3 pts  
**Acceptance Criteria:**
- All release gates documented and approved by Eng/QA/Security/Product.

---

## 5) Suggested Subtasks Template (for each Story)

Use this subtask set repeatedly:

1. API/Service design update
2. DB migration/update
3. Core implementation
4. Unit tests
5. Integration tests
6. Observability instrumentation
7. Security review (if required)
8. Documentation update
9. QA validation

---

## 6) Dependencies (Cross-Epic)

- EPIC-1 blocks migration launch paths in EPIC-6/EPIC-5.
- EPIC-2 blocks EPIC-3/4/5 API integration.
- EPIC-3 outputs are inputs to EPIC-4.
- EPIC-4 outputs are inputs to EPIC-5.
- EPIC-8 must be in place before broad beta rollout.
- EPIC-9 and EPIC-10 are release-critical for GA.

---

## 7) Sprint Sequencing Suggestion

## Sprint 1
- EPIC-1 core + EPIC-2 foundation + EPIC-9 SSRF baseline

## Sprint 2
- EPIC-3 crawl core + EPIC-6 studio shell + EPIC-10 telemetry baseline

## Sprint 3
- EPIC-4 extraction + EPIC-5 mapping/codegen initial + EPIC-6 previews

## Sprint 4
- EPIC-5 finalize + EPIC-7 audit + EPIC-8 flags/permissions

## Sprint 5
- EPIC-9 hardening + EPIC-10 regression/load + beta readiness

---

## 8) Definition of Done (Global)

A story is done only if:

- [ ] Functional acceptance criteria met
- [ ] Unit/integration tests pass
- [ ] Security checks completed (when applicable)
- [ ] Observability added
- [ ] Documentation updated
- [ ] QA sign-off captured

---

## 9) Import-Friendly CSV Skeleton (copy and adapt)

```csv
Issue Type,Summary,Description,Epic Link,Priority,Story Points,Labels
Epic,"EPIC-1 Policy, Ownership Verification, Compliance Foundation","Enforce legal-safe controls and ownership-gated migration",,Highest,,
Story,"STORY-1.1 Define mode/action policy matrix service","Implement policy decision service with deterministic deny codes","EPIC-1",Highest,5,"backend,policy,security"
Story,"STORY-1.2 Build ownership verification challenge issuance","Support DNS/HTML/meta verification challenge creation","EPIC-1",Highest,5,"backend,verification"
Story,"STORY-2.1 Implement site job create/status/cancel endpoints","Create job APIs for migration/recreation/audit","EPIC-2",Highest,8,"backend,api"
...
```

---

## 10) Final Notes

- Keep P0 security/policy items at top of every sprint.
- Do not advance rollout stage unless P0 regression is green.
- Use file `37` as execution order and this file as backlog source of truth.