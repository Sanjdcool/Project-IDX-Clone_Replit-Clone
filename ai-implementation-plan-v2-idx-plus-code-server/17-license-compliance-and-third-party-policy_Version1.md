# 17 — License Compliance and Third-Party Policy

## Status
Draft (target: legal + security + engineering sign-off)

## Date
2026-04-16

## Purpose

Define legal and engineering controls for open-source license compliance, third-party dependency governance, and redistribution obligations across the IDX + code-server integrated platform.

---

## 1) Policy Objectives

1. Ensure compliant use and distribution of third-party software.
2. Prevent accidental introduction of prohibited licenses.
3. Maintain clear attribution, notice, and source-offer obligations.
4. Reduce legal and operational risk from dependency drift.
5. Provide auditable evidence of compliance posture.

---

## 2) Scope

## In scope
1. Runtime dependencies (including code-server fork ecosystem)
2. Backend/frontend dependencies in IDX control plane
3. Container base images and system packages
4. Third-party assets, fonts, icons, templates, snippets
5. Build-time and transitive dependencies
6. Compliance artifacts (SBOM, notices, acknowledgments)

## Out of scope
1. End-customer proprietary code uploaded to workspaces (separate policy)
2. Contractual commercial terms with external vendors (procurement/legal workflow)

---

## 3) License Risk Classification

## 3.1 Classification tiers (example)

1. **Allowed (Green)**
   - permissive licenses compatible with product distribution model
2. **Conditional (Yellow)**
   - allowed only with explicit obligations/controls
3. **Restricted/Prohibited (Red)**
   - not allowed under current business/legal policy

Final classification list maintained by legal/compliance ownership.

---

## 4) Dependency Intake Policy

Before introducing a new dependency:

1. Identify direct license and known transitive risk.
2. Verify package source integrity and maintainer trust signals.
3. Check vulnerability posture and maintenance activity.
4. Confirm compatibility with platform distribution/deployment model.
5. Record approval decision and owner in dependency registry.

No dependency should be added without policy-visible metadata.

---

## 5) code-server Fork Compliance Controls

1. Track upstream license and notice obligations continuously.
2. Maintain fork patch log with rationale and ownership.
3. Reconcile third-party notices after each upstream sync.
4. Preserve required attribution files in runtime distribution artifacts.
5. Review redistribution obligations for any bundled extensions/components.

---

## 6) SBOM and Inventory Requirements

1. Generate SBOMs for:
   - control plane builds,
   - runtime images,
   - release artifacts.
2. Include direct + transitive components where tooling supports.
3. Store SBOMs versioned with release metadata.
4. Support diff-based SBOM comparison across releases.

---

## 7) Notice and Attribution Requirements

1. Maintain up-to-date third-party notices file(s).
2. Include required attribution in product/legal documentation surfaces where needed.
3. Ensure runtime image/package distributions include mandatory notices.
4. Automate notice file regeneration in CI where possible.

---

## 8) Copyleft/Reciprocal License Handling

1. Flag reciprocal/copyleft components for mandatory legal review.
2. Define approved usage patterns and prohibited integration patterns.
3. Prevent accidental static/dynamic linkage patterns that violate policy.
4. Document obligations and engineering constraints when approved conditionally.

---

## 9) Asset and Content Licensing

1. Verify licenses for fonts/icons/images/templates/snippets.
2. Track source and license terms in asset registry.
3. Ensure attribution requirements are fulfilled in UI/docs where required.
4. Prohibit unverified copied assets from external sources.

---

## 10) Policy Enforcement in CI/CD

## Required gates

1. License scan gate (direct + transitive dependencies)
2. SBOM generation gate
3. Notice file consistency gate
4. Prohibited license fail gate
5. Conditional license manual approval workflow

Builds should fail on red-policy violations.

---

## 11) Exception Management

1. Exceptions require legal + security + engineering approval.
2. Exceptions are time-bound with expiry date.
3. Compensating controls and migration plan required.
4. Exception usage tracked and reviewed periodically.

---

## 12) Release Compliance Checklist

Before GA/beta release:

- [ ] latest license scans completed
- [ ] SBOMs generated and archived
- [ ] notice/attribution files updated
- [ ] prohibited license violations resolved
- [ ] conditional licenses approved and documented
- [ ] code-server fork compliance review completed

---

## 13) Governance and Ownership

## 13.1 Roles

1. Legal/Compliance: policy authority and exception approvals
2. Security: tooling integration and risk oversight
3. Engineering: dependency hygiene and remediation execution
4. Release Manager: release gate enforcement

## 13.2 Review cadence

- periodic dependency/license posture reviews (e.g., monthly)
- pre-release compliance review for major milestones

---

## 14) Incident Response for Compliance Violations

1. Detect and classify violation severity.
2. Halt distribution if required by policy.
3. Prepare remediation path:
   - dependency replacement,
   - rollback,
   - notice correction.
4. Document incident and preventive controls update.

---

## 15) Audit Evidence Requirements

Maintain evidence for:
1. dependency approval decisions
2. scan results by release
3. SBOM archives
4. notice file versions
5. exception approvals and expirations

Evidence should be queryable by release/version/date.

---

## 16) Implementation Checklist

- [ ] Define approved/restricted license matrix
- [ ] Integrate automated license scanning in all pipelines
- [ ] Generate and archive SBOMs per release artifact
- [ ] Automate notice file generation/validation
- [ ] Implement dependency registry with ownership metadata
- [ ] Implement exception workflow and expiry alerts
- [ ] Add fork sync compliance checklist for code-server repo
- [ ] Build compliance dashboard and reporting exports

---

## 17) Acceptance Criteria

1. New dependencies cannot bypass license policy checks.
2. Prohibited licenses are blocked before merge/release.
3. Required notices and attributions are accurate and up to date.
4. SBOM and compliance evidence are available for each release.
5. code-server fork updates follow documented compliance controls.

---

## 18) Dependencies

- `03-repo-strategy-and-ownership-model.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `25-ci-cd-release-and-versioning-strategy.md`
- `28-ga-readiness-checklist.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 19) Next Document

Proceed to:
`18-observability-slos-and-alerting.md`