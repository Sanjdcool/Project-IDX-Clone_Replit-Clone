# 25 — CI/CD, Release, and Versioning Strategy

## Status
Draft (target: platform + SRE + security + release management sign-off)

## Date
2026-04-16

## Purpose

Define CI/CD architecture, release promotion controls, and versioning strategy for control plane and runtime components of the IDX + code-server integrated platform.

---

## 1) Objectives

1. Ship changes safely with high deployment confidence.
2. Standardize build, test, scan, and promotion workflows.
3. Ensure reproducible artifacts with traceable provenance.
4. Minimize regression risk through gated releases.
5. Enable fast rollback and incident recovery.

---

## 2) Delivery Scope

## In scope
1. Build/test pipelines for all repositories
2. Security and compliance gates
3. Artifact/image versioning and promotion
4. Multi-environment deployment orchestration
5. Release notes and changelog discipline

## Out of scope
1. Vendor-specific CI product migration strategy
2. End-user application CI inside customer workspaces

---

## 3) Pipeline Architecture

## 3.1 Pipeline stages (recommended)

1. **Validate**
   - lint, unit tests, schema checks
2. **Build**
   - compile/package, container image builds
3. **Verify**
   - integration tests, contract tests, smoke tests
4. **Secure**
   - SAST, dependency scan, license checks, image scan
5. **Publish**
   - signed artifact push, SBOM generation
6. **Promote**
   - deploy Dev -> Staging -> Prod with approvals/gates
7. **Observe**
   - post-deploy checks, canary analysis, rollback trigger checks

---

## 4) Branching and Merge Strategy

1. Trunk-based with short-lived feature branches (recommended), or controlled release branches as needed.
2. Protected main branch:
   - required reviews,
   - required checks,
   - signed commits/tags where policy applies.
3. Hotfix branch process documented and audited.

---

## 5) Versioning Model

## 5.1 Control plane services
- semantic versioning: `vMAJOR.MINOR.PATCH`

## 5.2 Runtime images
- semantic runtime tag: `runtime-vMAJOR.MINOR.PATCH`
- optional build metadata: `+<git-sha>`

## 5.3 Internal contracts/schemas
- independent versioning with compatibility policy
- breaking changes require explicit migration plan

---

## 6) Artifact Management and Provenance

1. Immutable artifacts/images after publish.
2. Artifact signing/attestation (recommended/required for prod).
3. Store SBOM per artifact version.
4. Link artifact metadata to commit SHA, build ID, and pipeline run.
5. Retention policy for artifacts by environment and release stage.

---

## 7) Required Quality Gates

Before merge:
- [ ] unit tests pass
- [ ] lint/static checks pass
- [ ] required code review approvals present

Before staging promotion:
- [ ] integration + contract tests pass
- [ ] security and license scans pass policy
- [ ] smoke tests green

Before production promotion:
- [ ] staging soak window criteria met
- [ ] release checklist approved
- [ ] on-call and rollback readiness confirmed
- [ ] change approval policy satisfied

---

## 8) Security and Compliance Gates

1. SAST/secret scanning for source changes.
2. Dependency vulnerability scanning with severity thresholds.
3. Container image scanning and policy enforcement.
4. License compliance checks (Doc 17).
5. Signed artifact verification before deployment.
6. Block promotion on critical unresolved findings unless exception approved.

---

## 9) Deployment Strategies

1. Rolling updates for stateless services.
2. Canary deployments for high-risk/critical services.
3. Blue/green optional for specific components where justified.
4. Progressive exposure with automated health checks.
5. Automated rollback on guardrail breach (error/latency/SLO burn triggers).

---

## 10) Database and Schema Change Policy

1. Backward-compatible migrations preferred.
2. Expand/contract migration pattern for breaking schema evolution.
3. Migration validation in staging with production-like data shape.
4. Rollback/roll-forward strategy documented per migration.

---

## 11) Release Cadence and Trains

1. Define regular release train cadence (e.g., weekly/bi-weekly).
2. Allow controlled out-of-band hotfix releases.
3. Freeze windows before major milestones as needed.
4. Release cutoff and stabilization criteria documented.

---

## 12) Changelog and Release Notes

1. Human-readable release notes per production release.
2. Include:
   - new features,
   - fixes,
   - known issues,
   - migration notes,
   - security-relevant updates.
3. Auto-generate draft notes from PR labels + manual curation.

---

## 13) Rollback and Recovery in CI/CD

1. Quick rollback path to last known good artifact.
2. Config rollback procedure paired with code rollback.
3. Automated rollback triggers configurable by service.
4. Post-rollback verification checklist required.

---

## 14) Metrics and DORA Tracking

Track at minimum:
1. Deployment frequency
2. Lead time for changes
3. Change failure rate
4. Mean time to restore (MTTR)

Also track:
- flaky test rate
- pipeline duration
- gate failure causes
- rollback frequency

---

## 15) Access Control and Governance

1. Least-privilege access to CI/CD and artifact registries.
2. Production deploy permissions restricted and auditable.
3. Break-glass deploy procedure with explicit approval and reason logging.
4. Periodic access review for CI/CD credentials/tokens.

---

## 16) Implementation Checklist

- [ ] Standardize pipeline templates across repos
- [ ] Enforce branch protection and required checks
- [ ] Implement artifact signing + provenance metadata
- [ ] Integrate security/license/SBOM gates
- [ ] Implement staged promotion workflow and approvals
- [ ] Implement canary analysis + automated rollback hooks
- [ ] Define release train cadence and change freeze policy
- [ ] Build CI/CD performance and DORA dashboards

---

## 17) Acceptance Criteria

1. All production changes pass standardized CI/CD gates.
2. Artifact provenance and version traceability are complete.
3. Security and license policies are enforced before promotion.
4. Rollback can be executed rapidly and reliably.
5. Release health is measurable via DORA and platform-specific metrics.

---

## 18) Dependencies

- `17-license-compliance-and-third-party-policy.md`
- `24-environment-strategy-dev-staging-prod.md`
- `26-test-strategy-pyramid-and-quality-gates.md`
- `28-ga-readiness-checklist.md`
- `30-support-runbooks-and-incident-response.md`

---

## 19) Next Document

Proceed to:
`26-test-strategy-pyramid-and-quality-gates.md`