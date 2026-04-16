# 16 — PRD to Engineering Mapping

## 1) Purpose

Map each Product Requirement (from `01-product-requirements.md`) to concrete engineering tasks, deliverables, and acceptance tests across backend/frontend/runtime/security.

Use this as the single source for scope traceability and release sign-off.

---

## 2) Legend

- **PRD Ref**: Requirement ID from `01-product-requirements.md`
- **Eng Owner**: Primary team (Backend / Frontend / Runtime / Security / Data)
- **Core Deliverables**: Key technical outputs
- **Acceptance Tests**: Verifiable checks for done criteria
- **Status**: `Not Started | In Progress | Blocked | Done` (fill during execution)

---

## 3) Functional Requirements Mapping

## FR-1 Prompt-to-Plan

**Requirement:** Accept natural language prompt + constraints and return project plan + operations + run suggestions.

- **Eng Owner:** Backend + Frontend
- **Core Deliverables:**
  - `POST /api/ai/generate`
  - Prompt composer UI + constraints drawer
  - Provider abstraction + prompt templates
  - Structured response schema validation
- **Acceptance Tests:**
  - Submit prompt with constraints and receive valid patch plan.
  - Run suggestions returned when relevant.
  - Invalid payload rejected with clear error envelope.
- **Status:** Not Started

---

## FR-2 Structured File Operations

**Requirement:** Machine-parseable operations (`create/update/delete`) with safe path handling.

- **Eng Owner:** Backend + Security
- **Core Deliverables:**
  - `patch-plan.schema`
  - operation-policy service
  - path-policy service
  - policy denial error codes
- **Acceptance Tests:**
  - Model response failing schema is rejected.
  - Path traversal attempts are blocked.
  - Unsupported operation type is rejected.
- **Status:** Not Started

---

## FR-3 Diff Review

**Requirement:** Unified diffs + selective approval/rejection.

- **Eng Owner:** Frontend + Backend
- **Core Deliverables:**
  - `GET /api/ai/patch/:id`
  - `PatchReviewPanel`, `DiffViewer`, selection actions
  - file-level approve/reject state
- **Acceptance Tests:**
  - User can view per-file diffs.
  - User can apply selected subset only.
  - User can reject all changes.
- **Status:** Not Started

---

## FR-4 Apply and Snapshot

**Requirement:** Apply approved changes, create checkpoint, support rollback.

- **Eng Owner:** Backend + Runtime
- **Core Deliverables:**
  - `POST /api/ai/patch/:id/apply`
  - snapshot service
  - `POST /api/ai/snapshots/:id/rollback`
- **Acceptance Tests:**
  - Snapshot created before apply.
  - Approved files are written; rejected files untouched.
  - Rollback restores previous state.
- **Status:** Not Started

---

## FR-5 Execution Pipeline

**Requirement:** Run install/build/test/dev in sandbox with logs and metadata.

- **Eng Owner:** Runtime + Backend + Frontend
- **Core Deliverables:**
  - `POST /api/ai/run`
  - sandbox service with command policy
  - log stream events (`ai:run:*`)
  - run history UI
- **Acceptance Tests:**
  - Commands run only in sandbox container.
  - Live stdout/stderr appears in UI.
  - Exit code and duration are persisted and displayed.
- **Status:** Not Started

---

## FR-6 AI Error Repair Loop

**Requirement:** Trigger fix from failed run and route through same diff/apply cycle.

- **Eng Owner:** Backend + Frontend
- **Core Deliverables:**
  - `POST /api/ai/fix`
  - fix prompt template
  - run diagnostics parser
  - fix CTA in run failure UX
- **Acceptance Tests:**
  - Failed run produces error summary.
  - Fix request returns targeted patch plan.
  - Fix patch can be reviewed/applied and re-run.
- **Status:** Not Started

---

## FR-7 Context Awareness

**Requirement:** AI reads project context with budget-aware inclusion.

- **Eng Owner:** Backend
- **Core Deliverables:**
  - context builder service
  - file relevance ranking
  - truncation/summarization rules
- **Acceptance Tests:**
  - Context excludes oversized/irrelevant files beyond limits.
  - Key files and recent edits are included for typical prompts.
- **Status:** Not Started

---

## FR-8 Conversation Memory

**Requirement:** Persist prompts, plans, approvals, runs, fixes, resume state.

- **Eng Owner:** Backend + Frontend + Data
- **Core Deliverables:**
  - DB tables for sessions/events/runs/patches
  - session timeline API/events
  - timeline/history UI
- **Acceptance Tests:**
  - Reloading session restores latest timeline state.
  - Prior requests and results are viewable.
- **Status:** Not Started

---

## FR-9 Policy and Safety

**Requirement:** Command/file safety, path controls, rate and resource limits.

- **Eng Owner:** Security + Backend + Runtime
- **Core Deliverables:**
  - command allowlist
  - path guard + protected paths
  - runtime limits (CPU/memory/timeout)
  - per-user rate limiting
- **Acceptance Tests:**
  - Disallowed commands blocked with clear reason.
  - Writes outside workspace blocked.
  - Resource exhaustion attempts are contained.
- **Status:** Not Started

---

## FR-10 Basic Analytics

**Requirement:** Track generation success, build success, fix-loop count, time-to-runnable.

- **Eng Owner:** Backend + Data + Frontend
- **Core Deliverables:**
  - metrics emitters
  - dashboards
  - telemetry events
- **Acceptance Tests:**
  - KPI dashboard shows required metrics.
  - Metrics correlated by request/session/workspace IDs.
- **Status:** Not Started

---

## 4) Non-Functional Requirements Mapping

## NFR-1 Performance

- **Owner:** Frontend + Backend + Runtime
- **Deliverables:**
  - optimized diff/log rendering
  - socket batching
  - endpoint latency instrumentation
- **Acceptance Tests:**
  - p95 generation latency within target window.
  - log stream perceived delay within target.
- **Status:** Not Started

---

## NFR-2 Reliability

- **Owner:** Backend + Runtime
- **Deliverables:**
  - idempotency keys
  - retries/backoff
  - lock management for apply/rollback
- **Acceptance Tests:**
  - repeated request with same idempotency key is safe.
  - transient provider errors handled with retry strategy.
- **Status:** Not Started

---

## NFR-3 Security

- **Owner:** Security + Backend + Runtime
- **Deliverables:**
  - redaction pipeline
  - authz checks
  - sandbox hardening controls
- **Acceptance Tests:**
  - secrets not present in stored prompts/logs.
  - unauthorized workspace access denied.
- **Status:** Not Started

---

## NFR-4 Scalability

- **Owner:** Backend + Runtime + DevOps
- **Deliverables:**
  - queue for long-running jobs
  - workspace-level concurrency controls
  - worker scaling strategy
- **Acceptance Tests:**
  - concurrent sessions handled without cross-impact.
  - backlog forms gracefully under load.
- **Status:** Not Started

---

## NFR-5 Auditability

- **Owner:** Backend + Security
- **Deliverables:**
  - audit event service
  - immutable event schema
  - traceability across phases
- **Acceptance Tests:**
  - every apply/run/fix action has audit event with actor and timestamp.
- **Status:** Not Started

---

## 5) User Story to Task Mapping

## Story: Generate App
- Backend: generate endpoint + provider + schema
- Frontend: prompt composer + status UI
- Test: prompt returns patch plan and summary

## Story: Preview Changes
- Backend: patch details + diffs
- Frontend: file list + diff panel
- Test: accurate per-file change display

## Story: Apply Safely
- Backend: apply + snapshot + policies
- Frontend: selection + apply actions
- Test: only approved files changed

## Story: Run in Sandbox
- Runtime: command execution and log stream
- Frontend: live log console
- Test: run metadata captured and displayed

## Story: Auto-Fix Errors
- Backend: fix endpoint + diagnostics context
- Frontend: fix CTA + patch loop
- Test: failed run can produce and apply fix plan

## Story: Iterate by Instruction
- Backend: session continuity + refine flow
- Frontend: follow-up prompt continuity
- Test: second prompt builds on prior state

## Story: Track AI Actions
- Backend: audit + timeline events
- Frontend: timeline/history UI
- Test: complete event chain visible per session

---

## 6) MVP Exit Criteria Traceability Matrix

| MVP Exit Criterion | Primary Technical Proof | Verification Method | Owner |
|---|---|---|---|
| Generate multi-file app from one prompt | `POST /ai/generate` + patch persistence | Integration test + demo | Backend |
| Review and selectively apply patches | patch details + apply endpoint + diff UI | E2E test | Frontend/Backend |
| Run commands and view live logs | sandbox + socket run events | E2E test + runtime logs | Runtime |
| Trigger AI fix from failure | `POST /ai/fix` + diagnostics parser | E2E failure scenario | Backend |
| Block unsafe paths/commands | policy services | security test suite | Security |
| Auditability and rollback | audit events + snapshots | audit query + rollback test | Backend |

---

## 7) Sprint-Level Delivery Mapping (Suggested)

## Sprint 1
- FR-1, FR-2 foundations
- contract/schema/policy scaffolding

## Sprint 2
- FR-1 completion + FR-3
- initial diff review UI

## Sprint 3
- FR-4 completion
- snapshot/rollback baseline

## Sprint 4
- FR-5 execution pipeline
- run logs UI

## Sprint 5
- FR-6 fix loop + FR-8 history baseline

## Sprint 6
- FR-9 hardening + NFR-3 security

## Sprint 7
- FR-10 analytics + NFR observability/reliability polish

---

## 8) QA Traceability Checklist

For each PRD requirement:
- [ ] At least one unit or integration test exists.
- [ ] At least one acceptance test scenario documented.
- [ ] At least one owner assigned.
- [ ] Status updated weekly.

---

## 9) Risks in Traceability

1. **Requirement drift**
   - Mitigation: weekly PRD-to-task review.

2. **Feature shipped without measurable KPI**
   - Mitigation: metric definition mandatory before merge.

3. **Security controls implemented late**
   - Mitigation: policy tasks in Sprint 1 baseline.

4. **UX parity gaps between backend capability and UI**
   - Mitigation: endpoint/component pairing in sprint planning.

---

## 10) Sign-Off Template

Use this section during release readiness:

- Product sign-off: [ ]
- Backend sign-off: [ ]
- Frontend sign-off: [ ]
- Runtime/DevOps sign-off: [ ]
- Security sign-off: [ ]
- QA sign-off: [ ]
- Final MVP go-live approved: [ ]

Date:
Release candidate:
Notes: