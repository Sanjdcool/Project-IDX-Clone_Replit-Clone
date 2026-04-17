# 26 — Test Strategy Pyramid and Quality Gates

## Status
Draft (target: QA + engineering + SRE + security sign-off)

## Date
2026-04-16

## Purpose

Define a practical, risk-based testing strategy and quality gate framework for the IDX + code-server integrated platform to ensure safe, reliable releases.

---

## 1) Quality Objectives

1. Catch defects early at the lowest-cost test layer.
2. Protect critical user journeys with strong end-to-end validation.
3. Prevent regressions in security, reliability, and data integrity.
4. Enforce measurable release gates tied to risk.
5. Improve engineering velocity by reducing flaky/low-signal tests.

---

## 2) Test Pyramid Model

## 2.1 Unit Tests (foundation, highest volume)

Focus:
- pure logic, validators, policy evaluators, state transitions, mappers.

Target characteristics:
- fast, deterministic, isolated,
- run on every PR,
- high signal, low maintenance.

## 2.2 Integration Tests (middle layer)

Focus:
- service-to-service contracts,
- DB/cache/queue interactions,
- tool broker + runtime adapter interactions,
- auth/policy/routing integration points.

Target characteristics:
- moderate runtime,
- realistic dependencies (mocked externals where appropriate),
- required for merge/promotion gates.

## 2.3 End-to-End Tests (top layer, smaller set)

Focus:
- critical user journeys:
  1. sign in -> start workspace -> open IDE
  2. edit -> run -> preview
  3. AI-assisted code change -> review/apply
  4. snapshot -> restore

Target characteristics:
- fewer but high-value,
- run in staging and pre-release gates,
- production-like environment assumptions.

---

## 3) Additional Test Types (Cross-Cutting)

1. **Contract tests**
   - API/tool schema compatibility across services.
2. **Security tests**
   - authz bypass, path traversal, secret leakage, SSRF attempts.
3. **Performance/load tests**
   - startup latency, websocket scale, preview throughput.
4. **Chaos/resilience tests**
   - component restarts, dependency outages, network faults.
5. **Migration tests**
   - schema evolution and rollback safety.
6. **Accessibility and UX validation** (for critical user paths).

---

## 4) Coverage Prioritization by Risk

Highest priority test coverage:

1. Auth/session and permission enforcement
2. Workspace lifecycle and reconciler correctness
3. Route binding and IDE access controls
4. File mutation and git apply conflict handling
5. Snapshot/restore integrity
6. Audit event generation and policy decision logging

Lower-risk features can use lighter initial coverage with planned hardening.

---

## 5) Quality Gates by Stage

## 5.1 Pull Request Gate (mandatory)

- [ ] unit tests pass
- [ ] lint/static analysis pass
- [ ] changed-component integration smoke pass
- [ ] security checks (SAST/secrets) pass
- [ ] required reviewers approved

## 5.2 Pre-Merge/Main Gate

- [ ] full integration suite pass for impacted areas
- [ ] contract tests pass
- [ ] no critical flaky test unresolved in impacted suite

## 5.3 Staging Promotion Gate

- [ ] critical E2E suite pass
- [ ] security integration tests pass
- [ ] migration checks pass
- [ ] release notes + risk review updated

## 5.4 Production Promotion Gate

- [ ] staging soak criteria met
- [ ] no open P0/P1 unapproved defects
- [ ] rollback validation complete
- [ ] sign-offs captured (engineering, QA, security as required)

---

## 6) Test Data Strategy

1. Deterministic fixtures for unit/integration tests.
2. Synthetic/anonymized datasets for staging E2E.
3. Seed scripts for reproducible environment setup.
4. Strict separation of test vs production data.
5. Data reset/cleanup workflows for repeatability.

---

## 7) Environment Strategy for Testing

1. Unit tests: local + CI ephemeral runners.
2. Integration tests: CI environment with controlled service dependencies.
3. E2E tests: staging environment with prod-like routing/auth/storage.
4. Performance and chaos: scheduled runs in dedicated test windows/environments.

---

## 8) Flaky Test Management Policy

1. Track flaky tests with owner and incident ID.
2. Quarantine policy:
   - temporarily isolate known flaky tests with explicit expiry.
3. Flaky threshold alerts trigger remediation sprint priority.
4. No long-term acceptance of flaky tests in release-critical suites.

---

## 9) Defect Severity and Exit Criteria

## Severity model (example)

- **P0:** critical outage/data/security impact
- **P1:** major user journey degradation
- **P2:** moderate functional issue/workaround exists
- **P3:** minor issue/cosmetic

Release exit rules:
1. No open P0.
2. P1 only with explicit risk acceptance and mitigation plan.
3. P2/P3 triaged and scheduled.

---

## 10) Automation and Tooling Requirements

1. Unified test runner/reporting across repos where feasible.
2. Per-PR impact analysis to run relevant suites efficiently.
3. Historical trend dashboards:
   - pass rate,
   - duration,
   - flake rate,
   - defect escape rate.
4. Artifact retention for failed test debugging (logs/screenshots/traces).

---

## 11) Reliability and Regression Safeguards

1. Regression suite for previously fixed high-severity bugs.
2. Canaries and synthetic probes post-deploy.
3. Error budget linkage to release gating.
4. Mandatory post-incident test additions for escaped defects.

---

## 12) Security Validation Requirements

1. AuthN/AuthZ negative tests for protected paths and APIs.
2. Tooling sandbox boundary tests (path/command restrictions).
3. Secrets redaction and leak prevention tests.
4. Dependency and image vulnerability gate checks.
5. Periodic penetration testing before major milestones.

---

## 13) Performance Gate Baselines

Define and enforce thresholds for:

1. workspace start p95
2. IDE connect success and latency
3. preview success/latency
4. tool execution latency bands
5. system saturation indicators under expected load

Performance regressions beyond threshold block promotion unless approved exception.

---

## 14) Reporting and Governance Cadence

1. Daily CI health report
2. Weekly quality review (defects, flakiness, escapes)
3. Milestone quality sign-off (M1/M2/M3)
4. Beta/GA readiness quality report with objective evidence

---

## 15) Implementation Checklist

- [ ] Define risk-based test matrix mapped to MVP journeys
- [ ] Implement mandatory PR/merge/staging/prod quality gates
- [ ] Build contract test suite for critical service/tool interfaces
- [ ] Build critical E2E suite for top user journeys
- [ ] Implement flaky test tracking and quarantine workflow
- [ ] Integrate security/performance checks into promotion gates
- [ ] Create quality dashboards and trend reporting
- [ ] Establish defect severity policy and release exit criteria

---

## 16) Acceptance Criteria

1. Quality gates are automated, measurable, and consistently enforced.
2. Critical user journeys are protected by stable automated tests.
3. Security and performance regressions are detected before production.
4. Flaky tests are actively managed and reduced over time.
5. Release decisions are supported by objective quality evidence.

---

## 17) Dependencies

- `18-observability-slos-and-alerting.md`
- `21-mvp-scope-definition-v2.md`
- `24-environment-strategy-dev-staging-prod.md`
- `25-ci-cd-release-and-versioning-strategy.md`
- `28-ga-readiness-checklist.md`
- `30-support-runbooks-and-incident-response.md`

---

## 18) Next Document

Proceed to:
`27-migration-cutover-and-rollback-plan.md`