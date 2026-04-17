# 27 — Migration, Cutover, and Rollback Plan

## Status
Draft (target: platform + SRE + product + support sign-off)

## Date
2026-04-16

## Purpose

Define the end-to-end migration and cutover strategy from current state to the integrated IDX + code-server platform, including phased rollout, risk controls, rollback mechanisms, and communication protocols.

---

## 1) Migration Objectives

1. Transition users with minimal disruption.
2. Preserve workspace/project integrity and access continuity.
3. Detect issues early with staged exposure.
4. Maintain rapid rollback capability at every phase.
5. Provide clear operator and user communication throughout cutover.

---

## 2) Migration Scope

## In scope
1. Control plane routing and service cutover
2. Workspace orchestration path migration
3. IDE access path migration
4. Snapshot/metadata compatibility checks
5. Feature flag transitions and cohort rollout
6. Operational support and incident handling during migration

## Out of scope
1. Rewriting historical customer repositories/content
2. Non-MVP legacy feature parity beyond approved scope

---

## 3) Migration Strategy (Phased)

## Phase 0 — Readiness and Dry Runs
- complete runbooks, test plans, and rollback rehearsals
- validate migration tooling in staging
- confirm baseline metrics and alert thresholds

## Phase 1 — Internal/Canary Cohort
- migrate internal users and test cohorts
- validate critical journeys and operational telemetry
- collect defects and harden before broader rollout

## Phase 2 — Limited External Beta Cohort
- gradual onboarding of low-risk external tenants/users
- monitor reliability/security/support signals
- enforce stricter change control during this phase

## Phase 3 — General Cutover
- expand to majority traffic/users once gates pass
- keep rollback path active until stabilization window closes

## Phase 4 — Legacy Path Decommission
- retire old paths/services after stability criteria met
- archive migration artifacts and final reports

---

## 4) Cutover Models

1. **Feature-flag cutover (preferred)**
   - route users by cohort flags/entitlements
2. **Traffic-percentage cutover**
   - gradual increase by percentage or tenant segments
3. **Big-bang cutover** (not preferred; emergency-only with executive sign-off)

Use reversible methods first.

---

## 5) Readiness Gates Before Any Production Cutover

- [ ] MVP beta criteria met (Doc 21)
- [ ] security baseline and audit controls validated
- [ ] backup/restore and DR checks current
- [ ] critical dashboards + alerts operational
- [ ] support/on-call staffing confirmed
- [ ] rollback rehearsed with evidence
- [ ] stakeholder communication plan approved

---

## 6) Data and State Migration Considerations

1. Verify workspace metadata schema compatibility.
2. Validate snapshot format compatibility and restore path.
3. Ensure identity/session mapping continuity.
4. Maintain idempotent migration scripts/jobs.
5. Record migration checkpoints and reconciliation outputs.

---

## 7) User Cohorting and Eligibility Rules

1. Internal users first.
2. Friendly/opt-in beta tenants next.
3. Exclude high-risk tenants/use cases until confidence threshold met.
4. Define automatic cohort pause criteria on incident triggers.

---

## 8) Cutover Runbook (Execution-Day Skeleton)

1. Confirm go/no-go approvals.
2. Freeze high-risk unrelated deploys.
3. Enable cohort flags/traffic shift step N.
4. Run smoke checks for critical journeys.
5. Monitor live metrics, errors, and support signals.
6. If healthy, proceed to next increment.
7. If threshold breached, pause or rollback.
8. Record timeline and decisions in incident/change log.

---

## 9) Rollback Strategy

## 9.1 Rollback triggers (examples)

1. critical journey failure rate beyond threshold
2. security control regression
3. sustained P1/P0 incident condition
4. data integrity mismatch signals
5. severe support ticket surge indicating systemic breakage

## 9.2 Rollback actions

1. revert traffic/feature flags to previous stable path
2. restore prior routing and service endpoints
3. halt migration jobs
4. validate user access and workspace integrity on legacy path
5. publish incident/update communications

Rollback must be executable within defined operational window.

---

## 10) Forward-Fix vs Rollback Decision Framework

Use forward-fix only when:
1. issue is low blast radius,
2. fix is proven low risk and fast,
3. rollback creates greater risk/disruption.

Default to rollback for high-severity unknowns.

---

## 11) Observability and Decision Thresholds

Track during migration:

1. workspace start success rate
2. IDE connect success and websocket stability
3. preview route success rate
4. AI tool success/deny anomaly rates
5. auth/token validation failures
6. latency and error budget burn rate
7. support ticket volume/severity

Predefine threshold bands:
- green (continue),
- yellow (hold/investigate),
- red (rollback).

---

## 12) Roles and Responsibilities During Cutover

1. **Incident Commander** — final operational decisions
2. **Migration Lead** — executes runbook and checkpoints
3. **SRE Lead** — telemetry, reliability, rollback mechanics
4. **Security Lead** — monitors policy/security regressions
5. **App Eng Lead** — hotfix triage and validation
6. **Support Lead** — customer issue intake and comms sync
7. **Comms Coordinator** — status updates and stakeholder notices

---

## 13) Communication Plan

## 13.1 Internal
- launch war room/channel
- checkpoint updates at fixed intervals
- clear decision log entries (time, owner, action)

## 13.2 External (as applicable)
- maintenance/change notifications
- in-progress status updates for disruptions
- post-cutover summary and known issues guidance

---

## 14) Post-Cutover Stabilization

1. Enhanced monitoring window (e.g., 7–14 days).
2. Daily defect/risk review with prioritized fixes.
3. Keep rollback readiness until stabilization exit criteria met.
4. Validate no hidden regressions in lower-frequency workflows.

---

## 15) Decommission Criteria (Legacy Path)

Proceed only when:

- [ ] stabilization window passed without critical incidents
- [ ] key reliability/security metrics stable
- [ ] support volume normalized
- [ ] required data reconciliation complete
- [ ] formal sign-off from engineering, SRE, security, product

Then:
- remove legacy routes/services,
- archive configs and runbooks,
- finalize lessons learned.

---

## 16) Testing and Rehearsal Requirements

1. Staging cutover simulation with production-like topology.
2. Rollback drill with timed objective.
3. Data reconciliation dry run.
4. Failure-injection scenarios during migration rehearsal.
5. Support and communication tabletop exercise.

---

## 17) Implementation Checklist

- [ ] Finalize phased migration plan with cohorts
- [ ] Implement feature flags and traffic controls for cutover
- [ ] Define and codify go/no-go thresholds
- [ ] Prepare cutover and rollback runbooks
- [ ] Complete staging migration + rollback rehearsals
- [ ] Establish migration command center and role roster
- [ ] Publish internal/external communication templates
- [ ] Conduct post-cutover review and decommission plan

---

## 18) Acceptance Criteria

1. Migration can be executed incrementally with measurable safety gates.
2. Rollback is fast, tested, and operationally reliable.
3. Critical user journeys remain protected during cutover.
4. Stakeholders and users receive timely, clear communication.
5. Legacy decommission happens only after objective stabilization evidence.

---

## 19) Dependencies

- `20-disaster-recovery-backups-and-failover.md`
- `21-mvp-scope-definition-v2.md`
- `24-environment-strategy-dev-staging-prod.md`
- `25-ci-cd-release-and-versioning-strategy.md`
- `26-test-strategy-pyramid-and-quality-gates.md`
- `30-support-runbooks-and-incident-response.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 20) Next Document

Proceed to:
`28-ga-readiness-checklist.md`