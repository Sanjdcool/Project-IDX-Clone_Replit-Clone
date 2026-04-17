# 23 — 90-Day Delivery Roadmap and Milestones

## Status
Draft (target: engineering leadership + product sign-off)

## Date
2026-04-16

## Purpose

Define a practical 90-day execution roadmap to deliver MVP readiness for the IDX + code-server integrated platform, with phased milestones, dependency gates, and measurable outcomes.

---

## 1) Roadmap Objectives

1. Deliver MVP-critical user journeys within 90 days.
2. Sequence work to de-risk integration early.
3. Enforce security/reliability gates before beta.
4. Provide clear weekly milestones and ownership.
5. Maintain adaptability via risk-based scope controls.

---

## 2) Planning Assumptions

1. Teams and epic ownership as defined in Doc 22.
2. MVP scope baseline fixed per Doc 21.
3. Critical architecture decisions from Docs 04–20 are accepted.
4. Cross-team dependency management is active weekly.
5. Feature flags available for controlled rollout.

---

## 3) Milestone Overview (90 Days)

## Milestone M1 (Days 1–30): Foundation + Integration Spine
Goal: establish core platform-to-runtime path with secure access and lifecycle control.

## Milestone M2 (Days 31–60): AI Workflow + Hardening
Goal: enable safe AI-assisted coding loop with storage, routing, and policy controls maturing.

## Milestone M3 (Days 61–90): Reliability + Beta Readiness
Goal: validate scale/reliability/security, complete runbooks, and pass beta entrance criteria.

---

## 4) Detailed Phase Plan

## 4.1 Days 1–30 (M1)

### Primary outcomes
1. Auth/session baseline and IDE token bridge operational.
2. Workspace orchestrator state machine and route binding functional.
3. code-server runtime integration working end-to-end.
4. Basic IDE launch journey functional in staging.
5. Baseline observability instrumentation enabled.

### Target epic focus
- EPIC A, B, C, D (core path)
- EPIC H starts (instrumentation baseline)
- EPIC G security baseline starts in parallel

### Exit criteria for M1
- [ ] User can sign in, start workspace, open IDE in staging.
- [ ] Token/path workspace binding enforced.
- [ ] Core lifecycle states visible in UI/API.
- [ ] Initial dashboards/log correlation functioning.
- [ ] Top critical integration risks identified with mitigation owners.

---

## 4.2 Days 31–60 (M2)

### Primary outcomes
1. Snapshot/restore baseline complete.
2. AI tooling contracts + prompt orchestration MVP-ready.
3. Code apply + git workflow (safe path) operational.
4. Preview routing and port policy controls enforced.
5. Security controls (secrets/egress/audit) significantly hardened.

### Target epic focus
- EPIC E, F, G lead
- EPIC D and B hardening continues
- EPIC I UX iteration for core developer loop

### Exit criteria for M2
- [ ] AI can perform safe file edit + command workflows with audit logs.
- [ ] Snapshot create/restore works for representative projects.
- [ ] Preview access policy works (private default).
- [ ] Audit events cover critical mutating and access actions.
- [ ] Security baseline checklist majority complete.

---

## 4.3 Days 61–90 (M3)

### Primary outcomes
1. Performance/load validation and autoscaling tuning complete.
2. DR backup/restore drill executed successfully.
3. SLOs/alerts/error budget workflow operational.
4. Beta readiness checklist substantially complete.
5. Launch recommendation package prepared.

### Target epic focus
- EPIC H + G finalization
- EPIC I readiness, docs, support handoff
- Cross-epic stabilization and defect burn-down

### Exit criteria for M3
- [ ] Must-have user journeys pass consistently.
- [ ] P0/P1 issues resolved or formally risk-accepted.
- [ ] On-call/runbooks/support workflows operational.
- [ ] Beta entrance criteria from Doc 21 met.
- [ ] Leadership go/no-go decision ready with evidence.

---

## 5) Week-by-Week Execution Map (High-Level)

## Weeks 1–2
- finalize contracts (auth, orchestrator, routing)
- stand up integration environments
- implement minimal end-to-end IDE connect path

## Weeks 3–4
- lifecycle reconciliation hardening
- runtime health/readiness and route stability
- initial security controls and observability dashboards

## Weeks 5–6
- storage snapshot pipeline
- AI tooling broker + basic prompt orchestration
- preview/port management policy enforcement

## Weeks 7–8
- code apply/git conflict handling UX
- audit governance and deny reason taxonomy
- initial load/performance tests and fixes

## Weeks 9–10
- autoscaling and capacity tuning
- DR backup/restore simulation
- security hardening gap closure

## Weeks 11–12
- beta checklist validation
- full regression and resilience drills
- docs/runbooks/support readiness
- launch recommendation report

---

## 6) Critical Dependency Gates

1. **Gate G1:** Auth + token bridge complete before broad IDE rollout.
2. **Gate G2:** Orchestrator + routing stability before AI mutation features.
3. **Gate G3:** Storage/snapshot baseline before beta data durability sign-off.
4. **Gate G4:** Security/audit controls before external beta exposure.
5. **Gate G5:** Observability/SLO/alerts before GA decision path.

No milestone exit without satisfying relevant gates.

---

## 7) Risk Management in Roadmap

## Top roadmap risks
1. Integration instability across orchestrator/gateway/runtime.
2. Security hardening delays affecting beta timeline.
3. AI tool safety regressions requiring policy tightening.
4. Performance bottlenecks under burst concurrency.
5. Cross-team dependency slippage.

## Mitigation pattern
- maintain 10–20% sprint buffer,
- run weekly risk review,
- enforce fast escalation for blocked critical path items,
- de-scope non-critical features per Doc 21 rules.

---

## 8) Milestone Metrics

Track per milestone:

1. Planned vs completed story points
2. Critical defect open/close trend
3. Core journey pass rate
4. SLO indicator trend (where available)
5. Security findings aging
6. Test pass/fail and flaky test rate
7. Change failure rate (deploy/regression)

---

## 9) Governance and Reporting Cadence

1. Weekly engineering milestone review
2. Weekly dependency/risk sync (cross-functional)
3. Bi-weekly leadership status update
4. Monthly architecture/security checkpoint
5. Milestone exit review with evidence pack

---

## 10) Resourcing Guidance by Milestone

## M1
- heavier Platform Backend + Runtime + Infra allocation

## M2
- heavier AI Platform + Security + Platform allocation

## M3
- heavier SRE/QA/Release + cross-team stabilization focus

Rebalance staffing at each milestone boundary using throughput and blocker data.

---

## 11) Change Control During 90 Days

1. Scope changes require product + engineering approval.
2. Any new feature entering MVP scope must identify displaced work.
3. Security/reliability must-not-cut items cannot be traded off without executive sign-off.
4. Maintain decision log for roadmap changes and rationale.

---

## 12) Deliverables by Day 90

- [ ] MVP feature set implemented (as scoped)
- [ ] Security baseline controls operational
- [ ] Observability + SLO + alerting operational
- [ ] DR and backup validation completed
- [ ] Runbooks/support docs complete
- [ ] Beta readiness evidence and go/no-go recommendation

---

## 13) Acceptance Criteria

1. Roadmap phases are realistic, dependency-aware, and owner-assigned.
2. Milestone gates are measurable and enforced.
3. Teams can track weekly progress against objective outcomes.
4. Risks are actively managed with documented mitigations.
5. Day-90 output supports an evidence-based beta launch decision.

---

## 14) Dependencies

- `21-mvp-scope-definition-v2.md`
- `22-epics-stories-and-team-allocation.md`
- `24-environment-strategy-dev-staging-prod.md`
- `28-ga-readiness-checklist.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 15) Next Document

Proceed to:
`24-environment-strategy-dev-staging-prod.md`