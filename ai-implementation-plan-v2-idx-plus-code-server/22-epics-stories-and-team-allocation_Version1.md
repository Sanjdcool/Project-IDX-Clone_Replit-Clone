# 22 — Epics, Stories, and Team Allocation

## Status
Draft (target: engineering management + product operations sign-off)

## Date
2026-04-16

## Purpose

Translate MVP scope and architecture into executable delivery structure:
- epics and story groups,
- ownership and staffing model,
- sequencing constraints,
- cross-team dependency management.

---

## 1) Planning Objectives

1. Map every MVP requirement to a tracked epic.
2. Assign clear ownership (DRI + backup owner).
3. Reduce dependency bottlenecks across teams.
4. Enable parallel execution with integration safety.
5. Provide transparent progress tracking for leadership.

---

## 2) Team Topology (Recommended)

1. **Platform Backend Team**
   - control plane APIs, auth integration, policy, orchestrator interfaces
2. **Runtime/IDE Team**
   - code-server integration, runtime image, IDE behavior
3. **Infra/SRE Team**
   - routing, clusters, scaling, reliability, DR
4. **AI Platform Team**
   - prompt orchestration, tooling contracts, context engine
5. **Product Frontend Team**
   - UX flows, IDE launch, status surfaces, AI interaction panels
6. **Security/Compliance Team**
   - hardening, audit, secrets/egress, governance gates
7. **QA/Release Team**
   - end-to-end validation, regression, release readiness

---

## 3) Epic Catalog (MVP-Aligned)

## EPIC A — Identity and Access Foundation
**Primary:** Platform Backend  
**Contributors:** Security, Frontend

Includes:
- session/auth baseline
- IDE token bridging
- permission checks and denial semantics

References: Docs 05, 16

---

## EPIC B — Workspace Lifecycle Orchestration
**Primary:** Platform Backend  
**Contributors:** Infra/SRE, Runtime

Includes:
- lifecycle APIs
- state machine + reconciler
- admission/policy hooks
- route binding coordination

References: Docs 06, 07

---

## EPIC C — IDE Runtime Integration
**Primary:** Runtime/IDE  
**Contributors:** Platform Backend, Frontend

Includes:
- runtime image and bootstrap
- code-server integration points
- health/readiness, lifecycle signals

References: Docs 04, 09

---

## EPIC D — Routing, Proxy, and Preview
**Primary:** Infra/SRE  
**Contributors:** Platform Backend, Security

Includes:
- IDE/preview gateway routes
- websocket support
- token/path binding enforcement
- route mapping consistency

References: Docs 07, 09

---

## EPIC E — Workspace Storage and Snapshots
**Primary:** Platform Backend  
**Contributors:** Infra/SRE, Security

Includes:
- volume lifecycle integration
- snapshot/restore pipeline
- retention/pruning controls

References: Doc 08

---

## EPIC F — AI Tooling and Prompt Orchestration
**Primary:** AI Platform  
**Contributors:** Platform Backend, Runtime, Security

Includes:
- tool broker contracts
- context retrieval pipeline
- prompt guardrails
- safe tool-call execution flow

References: Docs 10, 11, 12, 13

---

## EPIC G — Security Hardening and Governance
**Primary:** Security/Compliance  
**Contributors:** All teams

Includes:
- sandbox hardening baseline
- secrets + egress controls
- audit logging controls
- license compliance gates

References: Docs 14, 15, 16, 17

---

## EPIC H — Observability, Performance, and DR
**Primary:** Infra/SRE  
**Contributors:** Platform Backend, Runtime, AI

Includes:
- telemetry instrumentation
- SLO dashboards and alerts
- load testing + autoscaling
- backup/restore and failover drills

References: Docs 18, 19, 20

---

## EPIC I — MVP Product Experience and Readiness
**Primary:** Product Frontend  
**Contributors:** QA/Release, Platform Backend

Includes:
- core user journeys UX
- status/error surfaces
- feature flags/kill switches
- beta readiness verification

References: Doc 21, 28

---

## 4) Story Template Standard (Required)

Every story should include:

1. Problem statement
2. Scope and non-scope
3. Technical notes/contract references
4. Acceptance criteria (testable)
5. Security/privacy considerations
6. Observability requirements
7. Rollout/rollback notes
8. Dependency links
9. Story points / effort estimate
10. Owner + reviewer

---

## 5) Suggested Story Breakdown by Epic

## EPIC A (sample)
- A1: Auth/session baseline integration
- A2: IDE access token mint/validate flow
- A3: Permission deny reason taxonomy
- A4: Session revoke propagation to IDE gateway

## EPIC B (sample)
- B1: Workspace state machine implementation
- B2: Idempotent lifecycle command handling
- B3: Reconciler timeout recovery logic
- B4: Route binder integration and readiness gating

## EPIC F (sample)
- F1: Tool request/response schema implementation
- F2: Workspace path confinement guard
- F3: Prompt layer composer + versioning
- F4: Context retrieval ranking baseline
- F5: Apply/diff/rollback workflow integration

(Continue similarly in tracker for all epics.)

---

## 6) Dependency Graph (High-Level)

1. EPIC A precedes secure completion of C/D/F.
2. EPIC B + D are required before stable IDE launch journeys.
3. EPIC E required for persistence and snapshot acceptance criteria.
4. EPIC G controls must be embedded throughout (not end-loaded).
5. EPIC H instrumentation starts early, not post-build.
6. EPIC I depends on A–H maturity for beta sign-off.

---

## 7) Staffing and Allocation Model (Example)

Use percentage allocation per sprint window:

- Platform Backend: 30%
- Runtime/IDE: 20%
- Infra/SRE: 20%
- AI Platform: 15%
- Product Frontend: 10%
- Security/Compliance: embedded 5% + review gates
- QA/Release: embedded across all streams

Adjust based on bottlenecks and milestone phase.

---

## 8) Capacity Planning and Throughput

1. Estimate velocity per team from recent sprint history.
2. Reserve capacity buffer for unplanned integration defects (10–20% recommended).
3. Track planned vs completed story points weekly.
4. Trigger scope/risk review if variance exceeds threshold for 2 consecutive iterations.

---

## 9) Cross-Team Operating Cadence

1. Weekly architecture/dependency sync
2. Twice-weekly integration triage standup (during critical phases)
3. Security design review checkpoint each sprint
4. Release readiness review at milestone boundaries

---

## 10) Definition of Ready (DoR)

Story is ready when:
- acceptance criteria are explicit,
- dependencies identified,
- API/contracts linked,
- test approach defined,
- owner assigned.

---

## 11) Definition of Done (DoD)

Story is done when:
- code merged with required approvals,
- tests pass (unit/integration as applicable),
- observability hooks included,
- security checks passed,
- docs/runbook updates included where relevant.

---

## 12) Risk-Based Prioritization Rules

Prioritize first:
1. critical path dependencies,
2. security and data integrity controls,
3. high user-impact reliability items.

Defer:
- low-impact polish,
- non-critical automation,
- optional advanced UX.

---

## 13) Tracking and Reporting

## Required views
1. Epic burn-up dashboard
2. Dependency blocker board
3. Security findings aging report
4. Beta readiness checklist status
5. Risk register linkage by epic

---

## 14) Implementation Checklist

- [ ] Create epics A–I in tracking system
- [ ] Create story templates with required metadata
- [ ] Assign DRI + backup owner for each epic
- [ ] Map dependencies and critical path milestones
- [ ] Establish team capacity allocations
- [ ] Stand up weekly reporting dashboards
- [ ] Link stories to MVP acceptance criteria
- [ ] Add risk IDs to high-risk stories

---

## 15) Acceptance Criteria

1. Every MVP requirement is mapped to an owned epic/story.
2. Team ownership and review responsibilities are unambiguous.
3. Dependencies are visible and actively managed.
4. Delivery progress is measurable through shared dashboards.
5. Planning model supports confident beta timeline forecasting.

---

## 16) Dependencies

- `21-mvp-scope-definition-v2.md`
- `23-90-day-delivery-roadmap-and-milestones.md`
- `24-environment-strategy-dev-staging-prod.md`
- `28-ga-readiness-checklist.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 17) Next Document

Proceed to:
`23-90-day-delivery-roadmap-and-milestones.md`