# 24 — Environment Strategy (Dev, Staging, Prod)

## Status
Draft (target: platform + SRE + security sign-off)

## Date
2026-04-16

## Purpose

Define environment architecture, promotion flow, configuration isolation, and operational controls for Development, Staging, and Production environments for the IDX + code-server platform.

---

## 1) Objectives

1. Ensure safe, repeatable promotion of changes across environments.
2. Prevent configuration drift and cross-environment contamination.
3. Provide realistic pre-production validation before release.
4. Enforce stronger controls as changes move toward production.
5. Support rapid rollback and incident containment.

---

## 2) Environment Definitions

## 2.1 Development (Dev)

Purpose:
- rapid iteration, feature development, early integration tests.

Characteristics:
- lower stability guarantees,
- synthetic/test data only,
- feature flags frequently toggled,
- relaxed scale and retention settings.

## 2.2 Staging

Purpose:
- production-like validation for release candidates.

Characteristics:
- near-prod topology and policies,
- realistic workload simulation,
- release gating tests,
- restricted access and tighter change control than dev.

## 2.3 Production (Prod)

Purpose:
- customer-facing stable service.

Characteristics:
- highest security/reliability controls,
- strict change windows/policies,
- audited access and operational procedures,
- full SLO/alerting/on-call enforcement.

---

## 3) Isolation Requirements

1. Separate cloud accounts/projects/subscriptions per environment (preferred).
2. Separate clusters/namespaces and network boundaries.
3. Separate data stores and storage buckets.
4. Separate secrets and key material.
5. No direct credential reuse across environments.
6. Strictly controlled cross-environment access paths.

---

## 4) Configuration Management Strategy

1. Infrastructure-as-code as source of truth.
2. Environment overlays for config differences (not ad hoc edits).
3. Versioned configuration with review/approval workflow.
4. Drift detection and reconciliation automation.
5. Sensitive config values sourced from secret manager, never plaintext.

---

## 5) Promotion and Release Flow

Recommended path:
1. Feature branch -> Dev deploy
2. Integration validation in Dev
3. Release candidate cut -> Staging deploy
4. Staging validation + sign-offs
5. Controlled production rollout (canary/percentage/region-based)
6. Post-deploy verification and monitoring

No direct Dev -> Prod shortcuts for MVP-critical components.

---

## 6) Environment Parity Guidelines

1. Staging should mirror Prod for:
   - core architecture,
   - auth/routing/security policies,
   - runtime and storage classes (as close as feasible).
2. Acceptable differences:
   - smaller scale/capacity,
   - anonymized/non-prod datasets,
   - reduced external integrations where necessary (documented).

---

## 7) Data Policy by Environment

## Dev
- synthetic/test fixtures only,
- ephemeral or short retention,
- no production customer data.

## Staging
- anonymized/sanitized representative data where needed,
- controlled retention,
- strict access auditing.

## Prod
- full policy/compliance controls,
- retention and deletion rules enforced,
- backup and DR policy fully active.

---

## 8) Access Control Model

1. RBAC by environment with least privilege.
2. Prod access limited to authorized on-call/ops roles.
3. Break-glass access with approvals + audit reason.
4. Periodic access reviews and automatic offboarding hooks.
5. Separate service accounts per environment and service.

---

## 9) Security Controls by Environment

## Dev
- baseline controls enabled; some flexibility for iteration.

## Staging
- security controls near-prod equivalent; mandatory for release sign-off.

## Prod
- strict enforcement:
  - hardened runtime policies,
  - egress restrictions,
  - full audit logging,
  - alerting and incident response integration.

---

## 10) Testing Strategy per Environment

## Dev
- unit/integration tests
- early end-to-end smoke
- developer validation loops

## Staging
- full regression suite
- security and policy validation
- performance/load and chaos subsets
- release-candidate acceptance tests

## Prod
- smoke checks post-deploy
- continuous SLO monitoring
- synthetic probes for critical journeys

---

## 11) Observability and Alerting Segmentation

1. Distinct telemetry namespaces per environment.
2. Environment-tagged metrics/logs/traces.
3. Alert routing differs by environment severity:
   - Dev: team channels
   - Staging: pre-prod release channels
   - Prod: on-call paging + incident process
4. Prevent alert noise bleed-over between environments.

---

## 12) Deployment and Change Controls

1. CI/CD enforces environment-specific gates.
2. Staging approval required before production promotion.
3. Production deploy policies:
   - change window rules,
   - canary/gradual rollout,
   - automated rollback triggers.
4. Emergency hotfix path documented with tighter audit requirements.

---

## 13) Rollback Strategy

1. Versioned artifacts and immutable image tags.
2. One-click rollback to last known good version.
3. Config rollback paired with code rollback when needed.
4. Rollback drills performed periodically in staging.

---

## 14) Environment Readiness Checklists

## Dev readiness
- [ ] core services deployable
- [ ] basic telemetry available
- [ ] test data seeded

## Staging readiness
- [ ] prod-like topology validated
- [ ] release test suite passing
- [ ] security controls enabled
- [ ] rollback verified

## Prod readiness
- [ ] SLO dashboards and alerts active
- [ ] on-call coverage confirmed
- [ ] DR dependencies healthy
- [ ] change approvals complete

---

## 15) Common Failure Modes and Preventive Controls

1. Config drift -> enforce IaC + drift detection
2. Secret mismatch -> environment-scoped secret validation
3. Undetected staging-prod parity gaps -> parity audits
4. Risky direct prod changes -> protected branches + approvals
5. Incomplete rollback readiness -> scheduled rollback exercises

---

## 16) Governance and Ownership

1. Environment owners assigned (engineering + SRE).
2. Promotion authority matrix documented.
3. Security sign-off required for major control changes.
4. Release manager accountable for stage gate evidence.

---

## 17) Implementation Checklist

- [ ] Provision isolated env infrastructure and identity boundaries
- [ ] Implement config overlay and drift detection tooling
- [ ] Define and enforce CI/CD promotion gates
- [ ] Implement environment-specific RBAC and access reviews
- [ ] Implement telemetry/alert segmentation by environment
- [ ] Document hotfix and rollback procedures
- [ ] Run parity audit between staging and production
- [ ] Establish environment readiness scorecards

---

## 18) Acceptance Criteria

1. Dev, staging, and prod are clearly isolated and policy-compliant.
2. Promotion flow is controlled, auditable, and consistently followed.
3. Staging provides meaningful production-confidence validation.
4. Production changes are reversible with tested rollback paths.
5. Environment governance reduces release and security risk.

---

## 19) Dependencies

- `18-observability-slos-and-alerting.md`
- `19-performance-capacity-and-autoscaling.md`
- `20-disaster-recovery-backups-and-failover.md`
- `25-ci-cd-release-and-versioning-strategy.md`
- `28-ga-readiness-checklist.md`
- `30-support-runbooks-and-incident-response.md`

---

## 20) Next Document

Proceed to:
`25-ci-cd-release-and-versioning-strategy.md`