# 36 — Permissioning, Feature Flags, and Plan Gates

## 1) Purpose

Define access control and rollout governance for the new features:

1. Migration (verified),
2. Design recreation,
3. Competitive audit (read-only),

including RBAC, feature flags, pricing/plan limits, and staged enablement rules.

---

## 2) Access Control Objectives

1. Ensure only authorized users can run sensitive operations.
2. Restrict high-risk features by role and verification status.
3. Support controlled rollouts through flags.
4. Enforce plan-based quotas and capability tiers.
5. Provide auditable access decisions for compliance/security review.

---

## 3) RBAC Model

## 3.1 Suggested roles
- `viewer`
- `editor`
- `admin`
- `owner`
- `compliance_reviewer` (optional org-level role)

## 3.2 Baseline role capabilities

| Capability | Viewer | Editor | Admin | Owner | Compliance Reviewer |
|---|---:|---:|---:|---:|---:|
| View job history/reports | ✅ | ✅ | ✅ | ✅ | ✅ |
| Run competitive audit | ✅ | ✅ | ✅ | ✅ | ✅ |
| Run design recreation | ❌ | ✅ | ✅ | ✅ | ✅ (view/approve optional) |
| Run migration job | ❌ | ❌ | ✅ | ✅ | Optional approve gate |
| Approve policy-sensitive overrides | ❌ | ❌ | ✅ | ✅ | ✅ |

---

## 4) Mode-Level Permission Rules

## 4.1 `migration_verified`
Required:
- role in `{admin, owner}` (or custom permission grant)
- successful domain ownership verification
- valid policy consent record (if enforced per org policy)

## 4.2 `recreation_layout_only`
Required:
- role in `{editor, admin, owner}`
- policy acknowledgment

## 4.3 `audit_readonly`
Required:
- any authenticated workspace member by default (configurable)

---

## 5) Fine-Grained Permission Keys (Recommended)

Use explicit permission keys for flexibility:

- `site_studio.migration.create`
- `site_studio.migration.apply`
- `site_studio.recreation.create`
- `site_studio.recreation.apply`
- `site_studio.audit.create`
- `site_studio.audit.export`
- `site_studio.exports.download`
- `site_studio.policy.override`
- `site_studio.flags.manage` (admin/owner only)

---

## 6) Feature Flag Architecture

## 6.1 Core flags
- `studio_enabled`
- `studio_migration_enabled`
- `studio_recreation_enabled`
- `studio_audit_enabled`
- `studio_screenshot_recreation_enabled`
- `studio_mapping_override_enabled`
- `studio_export_scaffold_enabled`

## 6.2 Safety flags
- `studio_migration_require_verification` (default true)
- `studio_recreation_placeholder_default` (default true)
- `studio_audit_readonly_enforced` (default true)

## 6.3 Kill switches
- `studio_global_kill`
- `studio_migration_kill`
- `studio_exports_kill`

---

## 7) Plan/Tier Gating Model

## 7.1 Plan examples
- `free`
- `pro`
- `team`
- `enterprise`

## 7.2 Capability gates by plan (example)

| Capability | Free | Pro | Team | Enterprise |
|---|---:|---:|---:|---:|
| Competitive audit | ✅ limited | ✅ | ✅ | ✅ |
| Design recreation URL | ⚠️ limited | ✅ | ✅ | ✅ |
| Screenshot recreation | ❌ | ✅ | ✅ | ✅ |
| Migration mode | ❌ | ⚠️ limited | ✅ | ✅ |
| Advanced mapping override | ❌ | ⚠️ | ✅ | ✅ |
| High page crawl budgets | ❌ | ⚠️ | ✅ | ✅ |

---

## 8) Quotas and Usage Limits

Apply limits by plan and mode:

1. jobs/day
2. concurrent jobs
3. max pages/job
4. max runtime/job
5. exports/day
6. screenshot uploads/job

Example policy:
- free: audit-only low budget
- pro: recreation + limited migration
- team/enterprise: full feature set with larger quotas

---

## 9) Dynamic Policy Gates

Beyond plan/role, enforce dynamic conditions:

1. domain verification state (migration)
2. policy risk level for target URL
3. abuse/anomaly score
4. account/workspace trust status
5. unpaid billing state (if applicable)

If gate fails:
- deny action with deterministic reason code.

---

## 10) Approval Workflows (Optional but Recommended)

For sensitive operations (e.g., migration on high-risk target):
- require secondary approval from admin/owner/compliance reviewer
- maintain approval audit log:
  - approver
  - timestamp
  - reason
  - linked jobId

---

## 11) UI Permission Experience

## 11.1 Visibility rules
- hide unavailable tabs/actions where appropriate
- optionally show locked features with upgrade/explain states

## 11.2 Denial messaging
When blocked:
- explain whether block is due to role/plan/policy/verification
- provide next action:
  - request access
  - verify domain
  - upgrade plan
  - contact admin

## 11.3 Predictive checks
Before job submission:
- show preflight check results (green/yellow/red)

---

## 12) Backend Enforcement Requirements

1. all permission checks server-side (never UI-only).
2. evaluate:
   - auth
   - workspace membership
   - role/permission keys
   - plan gates
   - dynamic policy gates
3. record decision event for allow and deny outcomes.

---

## 13) Audit Logging for Permission Decisions

Each decision event should include:
- userId
- workspaceId
- action
- requested mode
- plan
- permission keys checked
- gate outcomes
- final decision
- reason code
- timestamp

---

## 14) Flag Rollout Strategy

## Stage A (internal)
- enable `studio_enabled` for internal org only
- migration disabled externally

## Stage B (design partners)
- enable audit + recreation for selected workspaces
- migration limited to verified partner accounts

## Stage C (closed beta)
- widen cohort by plan tier
- enable screenshot recreation gradually

## Stage D (GA)
- all stable flags on by default
- retain kill switches

---

## 15) Emergency Controls and Incident Response

1. instant global kill switch for critical incidents.
2. mode-specific disable for targeted risk.
3. export shutdown switch for data-leak concern scenarios.
4. preserve job history and policy events for incident forensics.

---

## 16) Data Model Alignment

This document should align with schema records for:
- user/workspace roles/permissions
- plan entitlements
- feature flag assignments
- permission decision logs
- policy events

---

## 17) Acceptance Criteria

- Role restrictions enforced for all mode actions.
- Migration cannot start without verified ownership and required role.
- Plan quotas and limits enforced deterministically.
- Flag toggles can enable/disable features without redeploy.
- Permission denials are explainable and auditable.
- Kill switches work and are tested.

---

## 18) Admin Controls (Ops Panel Requirements)

Admin panel should support:
1. assign/revoke feature flags by workspace/user
2. update per-plan quotas
3. grant temporary permission exceptions (with expiry)
4. inspect permission decision logs
5. activate kill switches

---

## 19) Testing Requirements for Permission/Gates

1. Role matrix test coverage (all actions).
2. Plan limit boundary tests.
3. Flag state combination tests.
4. Dynamic gate denial tests.
5. Kill switch tests in staging.
6. Audit log completeness tests.

---

## 20) Open Decisions

1. Should migration require owner role only, or admin + explicit permission?
2. Which plans include screenshot recreation at launch?
3. Do we expose locked features in UI or hide completely?
4. Is secondary approval mandatory for high-risk targets?
5. What is default behavior when flag service is unavailable (fail-closed recommended)?