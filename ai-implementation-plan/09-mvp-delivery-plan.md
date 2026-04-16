# 09 — MVP Delivery Plan

## 1) Purpose

Provide a practical execution plan to deliver the AI app-generation MVP in phased milestones, with owners, dependencies, risks, and go/no-go criteria.

---

## 2) MVP Scope Recap

MVP must include:
1. Prompt → structured patch generation
2. Diff review + selective apply
3. Snapshot + rollback
4. Sandbox run with live logs
5. Manual “Fix with AI” loop
6. Baseline safety controls
7. Baseline observability and audit events

Not included in MVP:
- autonomous multi-step agent mode
- cloud deployment automation
- advanced multi-model routing
- full template marketplace

---

## 3) Delivery Strategy

Use phased rollout:

- **Phase A: Foundations**
- **Phase B: Core AI Workflow**
- **Phase C: Run/Fix Loop**
- **Phase D: Hardening + Beta Readiness**

Recommended cadence: 2-week sprints (adjust per team size).

---

## 4) Work Breakdown Structure (WBS)

## Phase A — Foundations (Sprint 1)

### Objectives
- establish contracts and safe defaults
- scaffold backend/frontend modules

### Tasks
1. Finalize API + event contracts (`generate/apply/run/fix/rollback`)
2. Implement shared schemas (request + patch plan)
3. Implement policy engine skeleton:
   - path policy
   - command policy
4. Add session/state model for AI workflow
5. Frontend scaffolding:
   - AI panel shell
   - state stores
   - timeline component skeleton
6. Add baseline telemetry IDs (`traceId`, `requestId`, `sessionId`)

### Exit criteria
- API contracts documented and testable
- schema validation wired into endpoints
- policy stubs active (fail-closed for unsafe ops)

---

## Phase B — Core AI Workflow (Sprints 2–3)

### Objectives
- ship prompt-to-diff-to-apply loop

### Tasks
1. LLM provider abstraction + first provider implementation
2. Context builder (tree + key files + constraints)
3. Prompt templates v1 (generate/fix/system)
4. Structured response validation + repair pass
5. Patch plan persistence and diff generation
6. Frontend:
   - prompt composer
   - patch review list
   - diff viewer
   - approve/reject actions
7. Snapshot creation before apply
8. Apply service with path enforcement
9. Audit events for generate/apply

### Exit criteria
- user can generate and review multi-file patch
- user can selectively apply files
- snapshot created and rollback endpoint functional

---

## Phase C — Run/Fix Loop (Sprints 4–5)

### Objectives
- complete execution-aware generation lifecycle

### Tasks
1. Sandbox manager integration:
   - ensure container
   - exec commands
   - timeouts and limits
2. Live log streaming over Socket.IO
3. Run history persistence
4. Error parser for fix context extraction
5. `Fix with AI` endpoint + targeted patch generation
6. Frontend:
   - run controls
   - logs panel
   - failure cards + fix trigger
7. Retry and failure handling for provider/runtime errors
8. Audit events for run/fix

### Exit criteria
- user can run generated app commands in sandbox
- logs stream live
- failed run can trigger fix patch proposal and re-apply flow

---

## Phase D — Hardening + Beta Readiness (Sprints 6–7)

### Objectives
- improve reliability, security, observability, and rollout readiness

### Tasks
1. Rate limiting + quotas
2. Full command allowlist enforcement
3. Redaction pipeline for prompts/logs
4. Error-code standardization + UX mapping
5. Metrics dashboards:
   - success funnel
   - latency
   - cost
   - policy denials
6. Alerting setup (critical/warning)
7. Offline eval benchmark run + baseline score
8. Documentation + runbooks
9. Feature flags for staged rollout

### Exit criteria
- SLOs near target on staging
- security checklist satisfied
- eval baseline accepted
- beta release sign-off complete

---

## 5) Suggested Team Responsibilities

## Product
- requirement clarity
- acceptance criteria
- rollout policy and user communication

## Backend
- orchestration, policy, apply, runtime, audit, metrics emitters

## Frontend
- AI panel UX, diff review, run logs, error/fix UX, telemetry client events

## DevOps/SRE
- container runtime reliability, observability stack, alerting, scaling plans

## Security
- threat model review, policy checks, abuse controls, incident runbooks

---

## 6) Dependencies

1. Stable Docker runtime environment
2. LLM provider credentials + quota
3. telemetry stack availability
4. workspace snapshot mechanism
5. auth/session system integration

Blocking dependency examples:
- no provider quota => generation testing blocked
- no container limits => security sign-off blocked

---

## 7) Risks and Mitigations

## Risk 1: Model outputs invalid schema frequently
Mitigation:
- strict JSON schema enforcement
- repair pass
- prompt tuning + evaluation regression checks

## Risk 2: High runtime failure rates
Mitigation:
- pinned base images
- deterministic run profiles
- better error parsing + targeted fix prompts

## Risk 3: Unsafe ops slip through
Mitigation:
- fail-closed policies
- deny deletes by default
- audit and alert on policy bypass attempts

## Risk 4: Costs exceed budget
Mitigation:
- token caps
- context trimming/summarization
- request quotas
- route complex tasks to stronger model only when needed

## Risk 5: Slow UX under large diffs/logs
Mitigation:
- frontend virtualization
- chunked streaming
- payload size controls

---

## 8) Timeline Example (7 Sprints)

- Sprint 1: foundations
- Sprint 2: generation path part 1
- Sprint 3: generation path part 2 + apply
- Sprint 4: sandbox run integration
- Sprint 5: fix loop + reliability pass
- Sprint 6: security/observability hardening
- Sprint 7: beta prep + evaluations + launch checklist

(Condense or expand based on team capacity.)

---

## 9) Milestone Artifacts

At each milestone, produce:

1. **Demo recording**
2. **Acceptance test report**
3. **Known issues list**
4. **Risk register update**
5. **Metrics snapshot**
6. **Decision log** (changes in scope/policy)

---

## 10) QA and Test Plan (MVP)

## Functional tests
- prompt generation path
- selective apply path
- run/fix loop
- rollback flow

## Policy tests
- path traversal rejection
- disallowed command rejection
- protected file edit behavior

## Reliability tests
- provider timeout simulation
- socket disconnect/reconnect
- container crash recovery

## UX tests
- large diff performance
- long log stream rendering
- error messaging clarity

---

## 11) Rollout Plan

## Stage 1: Internal Alpha
- team-only feature flag
- heavy telemetry and manual review
- daily triage of failures

## Stage 2: Closed Beta
- selected users/workspaces
- quota limits and feedback collection
- weekly quality/cost reviews

## Stage 3: Public Beta
- broader access
- tighter automated monitoring
- incident response on-call active

---

## 12) Go/No-Go Criteria for Beta

Go only if:
1. End-to-end workflow stable in staging
2. security checks passed
3. key SLOs within tolerance
4. rollback and incident runbooks tested
5. support documentation ready

No-go triggers:
- unresolved critical security bugs
- unstable apply/run causing data loss risk
- unacceptable cost per successful session
- severe provider reliability issues without fallback

---

## 13) Definition of Done (MVP)

MVP is done when all conditions hold:

1. User can generate an app patch from natural language.
2. User can inspect and selectively apply diff.
3. Snapshots are created and rollback works.
4. Commands run in sandbox with live logs.
5. Failed runs can be fixed via AI patch loop.
6. Baseline safety controls are enforced server-side.
7. Observability dashboards and alerts are operational.
8. Audit trail exists for all critical actions.

---

## 14) Post-MVP Immediate Backlog (Priority Order)

1. autonomous multi-step repair mode (approval checkpoints)
2. template-aware generation starters
3. smarter context retrieval
4. multi-model routing
5. collaboration features (shared sessions/history)

---

## 15) Delivery Checklist

- [ ] Contracts frozen (API/event/schema/policy)
- [ ] Generation + apply shipped behind feature flag
- [ ] Run + fix loop functional
- [ ] Security baseline completed
- [ ] Observability dashboards + alerts live
- [ ] Offline eval baseline documented
- [ ] Beta readiness review completed