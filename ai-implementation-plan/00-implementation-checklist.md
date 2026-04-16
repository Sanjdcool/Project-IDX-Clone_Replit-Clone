# 00 — Implementation Checklist

This checklist converts the full AI implementation plan into actionable execution tasks.

Use this as the working tracker for engineering delivery.

---

## 1) Setup and Alignment

- [ ] Confirm product scope for MVP:
  - [ ] Prompt → patch generation
  - [ ] Diff review + selective apply
  - [ ] Snapshot + rollback
  - [ ] Sandbox run + live logs
  - [ ] Manual “Fix with AI”
- [ ] Confirm non-goals (no autonomous mode in MVP).
- [ ] Confirm model provider for MVP.
- [ ] Confirm command allowlist for MVP.
- [ ] Confirm protected files policy (delete behavior, lockfiles, env files).
- [ ] Confirm rollout plan (alpha → beta).

---

## 2) Repository and Module Scaffolding

- [ ] Create backend module structure under `backend/src/ai/*`.
- [ ] Create workspace/snapshot/patch service modules.
- [ ] Create runtime sandbox integration modules.
- [ ] Create socket event namespace for AI flows.
- [ ] Create frontend feature folder `frontend/src/features/ai/*`.
- [ ] Add state stores (session/patch/run/snapshot).
- [ ] Add API client module for AI endpoints.

---

## 3) Contracts and Schemas

- [ ] Define request/response contracts for:
  - [ ] `POST /api/ai/generate`
  - [ ] `GET /api/ai/patch/:id`
  - [ ] `POST /api/ai/patch/:id/apply`
  - [ ] `POST /api/ai/run`
  - [ ] `POST /api/ai/fix`
  - [ ] `POST /api/ai/snapshots/:id/rollback`
- [ ] Define patch operation schema.
- [ ] Define patch plan schema.
- [ ] Define standardized error envelope schema.
- [ ] Add server-side schema validation middleware.
- [ ] Add schema tests (valid + invalid payloads).

---

## 4) LLM Integration (MVP)

- [ ] Implement provider abstraction interface.
- [ ] Implement primary provider adapter.
- [ ] Add prompt templates:
  - [ ] system prompt v1
  - [ ] generation prompt v1
  - [ ] fix prompt v1
- [ ] Implement context builder:
  - [ ] tree summary
  - [ ] key file inclusion
  - [ ] truncation/summarization rules
- [ ] Enforce JSON structured output validation.
- [ ] Add single repair pass on invalid model output.
- [ ] Persist token usage and estimated cost metadata.
- [ ] Tag each request with prompt version.

---

## 5) Policy Engine and Safety

- [ ] Implement path normalization and root-bound enforcement.
- [ ] Block path traversal and symlink escape attempts.
- [ ] Implement command allowlist validator.
- [ ] Add disallowed pattern checks (dangerous shell usage).
- [ ] Add per-request limits:
  - [ ] max files changed
  - [ ] max file size
  - [ ] max operations
- [ ] Require explicit approval for delete operations (or disable deletes in MVP).
- [ ] Add protected path checks (`.git`, `.env`, etc.).
- [ ] Return policy-denial reason codes to frontend.

---

## 6) Patch Lifecycle

- [ ] Build patch plan persistence model.
- [ ] Implement unified diff generation.
- [ ] Implement selective file approval apply.
- [ ] Create snapshot before apply.
- [ ] Implement rollback endpoint.
- [ ] Ensure atomic-ish apply behavior with rollback on failure.
- [ ] Add audit events:
  - [ ] generation created
  - [ ] patch applied
  - [ ] snapshot created
  - [ ] rollback executed

---

## 7) Sandbox Runtime Execution

- [ ] Implement `SandboxService`:
  - [ ] ensure/reuse container per workspace
  - [ ] execute command
  - [ ] stop/cancel run
  - [ ] cleanup idle container
- [ ] Enforce non-root container execution.
- [ ] Apply CPU/memory/timeout limits.
- [ ] Stream logs via Socket.IO (`stdout`/`stderr`).
- [ ] Persist run metadata and exit codes.
- [ ] Parse failures into structured summaries for fix mode.
- [ ] Add run profiles (build/test/dev).

---

## 8) Fix Loop (Manual, MVP)

- [ ] Implement `POST /api/ai/fix`.
- [ ] Build fix context from:
  - [ ] failing command
  - [ ] error summary
  - [ ] recent changed files
- [ ] Generate targeted patch plan (minimal changes).
- [ ] Route fix through same review/apply flow.
- [ ] Allow optional re-run after apply.

---

## 9) Frontend UX Delivery

## AI Panel
- [ ] Build AI panel with tabs:
  - [ ] Chat
  - [ ] Changes
  - [ ] Runs
  - [ ] History

## Prompt and Generation
- [ ] Add prompt composer with constraints drawer.
- [ ] Add generation progress statuses.
- [ ] Add timeline events.

## Diff Review
- [ ] Show changed file list with operation type.
- [ ] Add per-file selection.
- [ ] Render unified diffs with good performance.
- [ ] Add approve selected / approve all / reject all actions.

## Run and Fix
- [ ] Add run controls.
- [ ] Add live log panel.
- [ ] Add failure card and “Fix with AI” action.
- [ ] Add run history.

## Snapshot and Rollback
- [ ] Add snapshot history view.
- [ ] Add rollback confirmation and action flow.

---

## 10) Observability and Telemetry

- [ ] Add structured logging in backend AI modules.
- [ ] Propagate `traceId/requestId/sessionId`.
- [ ] Add metrics:
  - [ ] generation latency/success
  - [ ] apply success
  - [ ] run success/failure
  - [ ] fix success
  - [ ] policy denials
  - [ ] token/cost usage
- [ ] Add dashboards:
  - [ ] AI funnel
  - [ ] runtime health
  - [ ] quality
  - [ ] cost
  - [ ] security
- [ ] Add alerts:
  - [ ] provider outage/failure spikes
  - [ ] run failure spikes
  - [ ] high policy-denial anomalies
  - [ ] cost anomalies

---

## 11) Security Hardening

- [ ] Ensure all AI endpoints require auth.
- [ ] Validate workspace ownership on every action.
- [ ] Add server-side rate limits and quotas.
- [ ] Add prompt/log redaction for secrets.
- [ ] Add audit logging for all critical operations.
- [ ] Add security tests:
  - [ ] path traversal attempts
  - [ ] command bypass attempts
  - [ ] unauthorized workspace access attempts
- [ ] Add incident runbook for AI feature failures.

---

## 12) Testing Plan

## Unit tests
- [ ] schema validators
- [ ] policy engine (path/command)
- [ ] response mappers
- [ ] diff/apply logic

## Integration tests
- [ ] generate → review → apply
- [ ] apply with partial approval
- [ ] run command + logs
- [ ] fix generation from failure logs
- [ ] rollback

## E2E tests
- [ ] prompt to runnable app (happy path)
- [ ] failed run then fix success
- [ ] blocked unsafe action messaging

## Reliability tests
- [ ] provider timeout simulation
- [ ] invalid schema response handling
- [ ] sandbox crash recovery
- [ ] socket reconnect behavior

---

## 13) Evaluation and Quality Gates

- [ ] Build offline benchmark prompt suite.
- [ ] Define quality rubric and scoring process.
- [ ] Record baseline metrics before beta.
- [ ] Add regression checks for prompt/model updates.
- [ ] Define go/no-go thresholds:
  - [ ] schema validity rate
  - [ ] first-pass runnable success
  - [ ] fix success in <=2 iterations
  - [ ] cost per successful session

---

## 14) Release and Rollout

## Alpha
- [ ] Feature flag enabled for internal users.
- [ ] Daily triage of failed sessions.
- [ ] Prompt/policy quick iteration loop.

## Closed Beta
- [ ] Limited user rollout.
- [ ] Quotas enforced.
- [ ] Weekly quality + cost reviews.

## Public Beta
- [ ] Security and observability sign-off complete.
- [ ] Runbooks tested.
- [ ] Support docs and user guidance published.

---

## 15) Ownership Tracker (Fill In)

| Area | Owner | Backup | Status |
|---|---|---|---|
| API contracts |  |  |  |
| LLM provider integration |  |  |  |
| Policy engine |  |  |  |
| Patch apply/snapshot |  |  |  |
| Sandbox runtime |  |  |  |
| Frontend AI panel |  |  |  |
| Diff review UX |  |  |  |
| Run/fix UX |  |  |  |
| Observability |  |  |  |
| Security hardening |  |  |  |
| QA/E2E |  |  |  |

---

## 16) Final MVP Readiness Checklist

- [ ] End-to-end flow works in staging.
- [ ] Security checks pass.
- [ ] Observability and alerts active.
- [ ] Benchmark quality at/above threshold.
- [ ] Rollback proven in test runs.
- [ ] Incident runbooks documented.
- [ ] Product sign-off complete.