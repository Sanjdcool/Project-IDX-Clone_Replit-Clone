# 33 — Delivery Roadmap, Estimates, and Rollout Plan

## 1) Purpose

Define a practical execution roadmap for implementing:

1. Migration (verified),
2. Design recreation (layout-only),
3. Competitive audit (read-only),

including staffing, sequencing, milestones, risk controls, rollout gates, and go-live criteria.

---

## 2) Delivery Strategy Summary

Use a **phased vertical-slice strategy**:

- Ship secure foundations first (policy, verification, crawl safety).
- Deliver one complete thin slice per mode early.
- Add quality/reliability hardening before broader rollout.
- Gate all rollout by policy/security/QA metrics.

---

## 3) Scope-to-Phase Mapping

## Phase 0 — Foundations (must-have before feature slices)
- legal/policy framework
- ownership verification service
- SSRF/network controls
- base job lifecycle + queue infra
- observability baseline

## Phase 1 — Migration MVP
- verified migration flow end-to-end
- crawl + extraction + scaffold generation
- diff/apply integration
- minimal build validation path

## Phase 2 — Recreation MVP
- URL and screenshot input paths
- layout-centric extraction/mapping
- placeholder content default
- mapping override UX

## Phase 3 — Audit MVP
- read-only analysis pipeline
- scorecards/findings/recommendations
- JSON/PDF report export (policy-safe)

## Phase 4 — Hardening and Scale
- throughput optimization
- failure recovery/auto-resume hardening
- richer dashboards/alerts
- abuse/anomaly refinement

---

## 4) Suggested Timeline (8–12 weeks MVP-to-Beta)

## Week 1–2: Phase 0
- core policy + verification + job framework
- SSRF protections + worker isolation
- basic telemetry and dashboards

## Week 3–5: Phase 1
- migration user flow + backend slice
- crawl/extract/regenerate baseline
- review/apply integration
- internal alpha demo

## Week 6–7: Phase 2
- recreation URL + screenshot flows
- layout mapping review panel
- placeholder/rewrite modes
- QA expansion

## Week 8–9: Phase 3
- audit analysis + report export
- read-only restriction enforcement
- benchmark comparison UI

## Week 10–12: Phase 4
- performance tuning
- reliability drills
- security/adversarial revalidation
- staged beta rollout

---

## 5) Team and Ownership Model

## Core team (recommended minimum)
1. Backend engineer (orchestration/policy/api)
2. Backend/infra engineer (workers/queue/storage)
3. Frontend engineer (studio UX/flows)
4. Full-stack engineer (mapping/codegen integration)
5. QA engineer (automation + adversarial tests)
6. Security reviewer (part-time but early-involved)
7. Product owner/EM

## Ownership by domain
- Verification + Policy: Backend + Security
- Crawl/Extraction: Backend/Infra
- Mapping/Codegen: Full-stack/AI
- Studio UX: Frontend
- Audit analytics: Backend + Frontend
- Observability/alerts: Infra + Backend
- QA gates: QA lead

---

## 6) Work Breakdown by Epic

## Epic E1 — Policy, Verification, and Security Baseline
Deliverables:
- verification APIs/UI
- policy engine mode matrix
- SSRF and network isolation controls
- policy event logging

Estimate:
- 2–3 weeks (parallelizable)

## Epic E2 — Crawl and Extraction Platform
Deliverables:
- crawl workers + frontier manager
- extraction pipeline + confidence scoring
- artifact storage integration

Estimate:
- 2–3 weeks

## Epic E3 — Mapping and Code Generation
Deliverables:
- normalized schema mapper
- component mapping
- scaffold generation + patch packaging

Estimate:
- 2–3 weeks

## Epic E4 — Frontend Studio Flows
Deliverables:
- migration/recreation/audit UI
- progress timeline/history
- mapping review UI
- report UI/export actions

Estimate:
- 2–3 weeks

## Epic E5 — Reliability/Observability/QA Hardening
Deliverables:
- full metrics/dashboards/alerts
- resilience and load tests
- regression automation and release checklist

Estimate:
- 2 weeks

---

## 7) Effort Sizing (Indicative)

Use T-shirt + point blend:

- E1: L
- E2: L
- E3: L
- E4: L
- E5: M/L

Total:
- ~10–14 engineer-weeks core build
- plus QA/security hardening window

(Exact estimate depends on existing platform reuse and team parallel capacity.)

---

## 8) Dependency Graph

1. E1 must start first (hard dependency for safe progress).
2. E2 can begin in parallel after minimal E1 policy contracts.
3. E3 depends on E2 extraction output contracts.
4. E4 depends on E1 APIs and E2/E3 summaries.
5. E5 spans all epics but intensifies after slices are integrated.

---

## 9) Milestones and Exit Criteria

## M1 — Secure Foundation Complete
- verification + policy controls live
- SSRF tests passing
- job lifecycle functional

## M2 — Migration Alpha Ready
- verified migration end-to-end works
- patch review/apply works
- no critical security gaps

## M3 — Recreation Alpha Ready
- URL and screenshot recreation pipeline working
- mapping review functional

## M4 — Audit Alpha Ready
- read-only reports generated
- restricted exports blocked reliably

## M5 — Beta Readiness
- regression suite pass
- load/reliability metrics acceptable
- observability and runbooks complete

---

## 10) Rollout Plan

## Stage A — Internal Alpha (team-only)
- feature flag restricted
- low concurrency limits
- intensive telemetry and manual QA

## Stage B — Design Partners / Closed Beta
- selected workspaces
- controlled quotas
- weekly feedback/review cadence

## Stage C — Broader Beta
- expanded workspace cohort
- stronger autoscaling
- strict incident response SLOs

## Stage D — General Availability (GA)
- all release gates met
- no critical unresolved risks
- support/playbooks/documentation complete

---

## 11) Feature Flags and Kill Switches

Flags:
- `studio_migration_enabled`
- `studio_recreation_enabled`
- `studio_audit_enabled`
- `studio_screenshot_recreation_enabled`
- `studio_export_scaffold_enabled`

Kill switches:
- mode-level disable
- export-level disable
- worker queue pause per mode

---

## 12) Risk Register and Mitigation Plan

1. **Security/policy bypass risk**
   - mitigation: deny-by-default enforcement + adversarial tests.

2. **Extraction quality variance**
   - mitigation: confidence thresholds + manual mapping review.

3. **Resource cost spikes**
   - mitigation: strict budgets/quotas + autoscaling policies.

4. **Long-running job UX frustration**
   - mitigation: progressive results + robust timeline/status.

5. **Scope creep across all 3 modes**
   - mitigation: strict MVP boundaries and phased release.

---

## 13) Readiness Checklists by Stage

## Alpha checklist
- [ ] policy + SSRF critical tests pass
- [ ] migration happy path works
- [ ] basic telemetry visible

## Closed beta checklist
- [ ] recreation + audit flows stable
- [ ] export restrictions validated
- [ ] regression suite stable for P0 tests

## GA checklist
- [ ] no open S0/S1 issues
- [ ] SLOs met for key phases
- [ ] alerts/runbooks active
- [ ] support and docs complete

---

## 14) Operational Cadence

Weekly:
1. roadmap checkpoint (progress/blockers)
2. quality and security review
3. telemetry/performance review
4. user feedback triage
5. risk register update

Bi-weekly:
- release train decision (promote/hold/rollback)

---

## 15) Success Metrics by Rollout Stage

## Alpha
- migration completion > baseline target
- critical policy tests 100% pass

## Closed beta
- recreation acceptance rate improving trend
- audit report usefulness feedback positive trend

## GA
- stable completion and latency SLOs
- low incident rate
- low policy-violation false negatives

---

## 16) Handoff Deliverables Before GA

1. final architecture and runbooks
2. production dashboards/alert ownership
3. QA regression artifacts
4. security review sign-off
5. support escalation matrix
6. customer-facing documentation

---

## 17) Open Planning Decisions

1. exact sprint length and team allocation?
2. whether screenshot recreation launches in same beta cohort?
3. maximum page limits by plan tier at GA?
4. what SLAs are publicly committed at launch?
5. which post-MVP enhancements move into next roadmap cycle first?