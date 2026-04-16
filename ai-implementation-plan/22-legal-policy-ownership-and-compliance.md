# 22 — Legal Policy, Ownership Verification, and Compliance Controls

## 1) Purpose

Define enforceable legal and policy controls for the new feature set:

1. Website Migration (owned-site only)
2. Design-to-Template Recreation (layout-focused)
3. Competitive Audit (read-only)

This document translates legal/compliance requirements into product, backend, and UX enforcement rules.

---

## 2) Policy Design Principles

1. **Legitimate-use first**: enable migration, auditing, and inspiration workflows.
2. **Default-safe outputs**: avoid raw third-party copy/export by default.
3. **Proof-gated actions**: require ownership proof for higher-risk operations.
4. **Mode isolation**: each mode has explicit allowed/blocked actions.
5. **Auditability**: every sensitive action must be traceable.
6. **Minimization**: store only required artifacts for limited durations.

---

## 3) Feature Modes and Compliance Profiles

## 3.1 `migration_owned_site` (highest privilege)
Allowed:
- full crawl within verified domain scope
- extraction of structure/content/assets for rebuild
- generation of editable scaffold and apply pipeline

Required:
- successful ownership verification
- explicit user attestation of rights
- legal acceptance log

Blocked:
- crawling non-verified domains in migration mode

---

## 3.2 `design_recreation` (medium privilege)
Allowed:
- extraction of visual structure/layout patterns
- generation of fresh code and placeholder/rewritten content

Default constraints:
- do not auto-copy long-form source content verbatim
- no bulk asset export package from unverified domains

May allow:
- limited style token extraction (palette, spacing, typography)

---

## 3.3 `competitive_audit_readonly` (lowest output risk)
Allowed:
- structure/performance/SEO/component analysis of public pages
- reporting and benchmarking output

Blocked:
- source code/content export bundle
- direct “rebuild this competitor site” output path

---

## 4) Ownership Verification Policy (Migration Mode)

## 4.1 Accepted methods (MVP)
At least one must pass:

1. DNS TXT token verification
2. HTML file token at `/.well-known/...`
3. meta tag token in `<head>`

## 4.2 Verification lifecycle
- token generated per verification attempt
- token has expiry (e.g., 24h)
- verification status stored with timestamp and method
- revalidation required after configurable TTL (e.g., 30–90 days)

## 4.3 Ownership scope rules
- verification binds to exact domain scope (and optionally subdomains if explicitly verified)
- migration job can only target verified scope
- redirects to external domains require policy decision (block by default)

---

## 5) User Attestations and Consent

Before first sensitive job, user must confirm:

1. they own/control or are authorized to process the target site
2. they accept legal responsibility for submitted targets
3. they agree not to use feature for unauthorized copying

Store immutable consent record:
- userId
- target domain
- consent version
- timestamp
- IP/session metadata (as policy permits)

---

## 6) Allowed vs Blocked Action Matrix

| Action | Migration (verified) | Design recreation | Competitive audit |
|---|---|---|---|
| Crawl public HTML | ✅ | ✅ | ✅ |
| Crawl JS-rendered pages | ✅ | ✅ | ✅ |
| Export raw site content bundle | ✅ (verified scope only) | ❌ default | ❌ |
| Generate fresh scaffold | ✅ | ✅ | ❌ |
| Verbatim long content reuse | ⚠️ review-gated | ❌ default | ❌ |
| SEO/perf report export | ✅ | ✅ | ✅ |
| Direct deploy copied site flow | ❌ | ❌ | ❌ |

---

## 7) Content and Asset Handling Policy

## 7.1 Content handling
- migration mode may ingest source text only for verified domains
- recreation mode should default to placeholder/rewritten text
- audit mode stores extracted summaries, not full reusable content packages

## 7.2 Asset handling
- verified migration can collect assets needed for rebuild workflow
- recreation mode should prefer placeholders/user-provided assets where possible
- audit mode stores only metadata (size/type/perf) by default

## 7.3 Sensitive path/content handling
Always block collection/extraction of:
- auth-only/private areas (without explicit authorized flow)
- secrets/config exposures
- forms containing personal or protected data fields

---

## 8) Robots, Terms, and Public Access Considerations

## 8.1 Robots treatment by mode
- audit/recreation: honor robots by default
- migration owned-site: configurable policy (still recommend honor by default unless explicit override with confirmation)

## 8.2 Terms and legal sensitivity flags
For each target, run policy pre-check:
- detect signs of restricted use notices
- classify risk level (`low/medium/high`)
- require stronger confirmation for medium/high-risk targets

---

## 9) Data Retention and Deletion Policy

## 9.1 Retention categories
1. Verification records
2. Crawl artifacts
3. Extraction artifacts
4. Generated code/report artifacts
5. Audit logs

## 9.2 Suggested retention baseline
- verification proofs: 90 days (or per legal policy)
- crawl/extraction temp artifacts: 7–30 days
- generated outputs: user-controlled retention
- audit logs: 90–365 days

## 9.3 Deletion controls
- user-triggered deletion for job artifacts
- admin purge tools for compliance events
- hard-delete workflow for expired temporary artifacts

---

## 10) Privacy and PII Controls

1. Minimize collection to technical page data needed for feature.
2. Detect and redact obvious sensitive tokens in logs/artifacts.
3. Avoid storing form submission data.
4. Mask user-identifying query parameters in stored URLs where possible.
5. Encrypt sensitive records at rest and in transit.

---

## 11) Enforcement Architecture

## 11.1 Policy engine checkpoints
Enforce at:
1. job creation
2. crawl request routing
3. extraction output packaging
4. generation pipeline output stage
5. export/download endpoints

## 11.2 Denial model
Fail closed with reason codes:
- `POLICY_OWNERSHIP_REQUIRED`
- `POLICY_MODE_RESTRICTED`
- `POLICY_EXPORT_BLOCKED`
- `POLICY_SCOPE_VIOLATION`
- `POLICY_HIGH_RISK_TARGET`

---

## 12) Export and Download Controls

## 12.1 Artifact classes
- `report_only` (safe in all modes)
- `scaffold_code` (migration/recreation only)
- `raw_content_bundle` (migration verified only)
- `asset_archive` (migration verified only, optional gating)

## 12.2 Download security
- signed URLs with short TTL
- one-time download option for sensitive artifacts
- access scoped to initiating user/team permissions

---

## 13) Team/Role Permissioning (RBAC)

Roles:
- `owner`
- `admin`
- `editor`
- `viewer`
- `compliance_reviewer` (optional)

Example permissions:
- viewers can run audit reports only
- editors can run recreation
- migration mode requires admin/owner + verified domain

---

## 14) Incident and Abuse Response

## 14.1 Triggers
- repeated attempts to run migration on unverified domains
- repeated blocked export attempts in audit mode
- suspicious high-volume crawl patterns across unrelated domains

## 14.2 Actions
1. temporary feature lock for user/org
2. require re-verification and manual review
3. escalate to compliance/security queue
4. preserve relevant audit trail slice

---

## 15) Compliance UX Requirements

UI must clearly show:
- current mode and restrictions
- what data will be collected
- what outputs are allowed/blocked
- reason when an action is denied
- ownership verification status and expiry

---

## 16) Required Audit Events

Emit immutable events for:
- verification token issued/validated/expired
- mode selected
- job created/started/completed/blocked
- blocked action with policy rule id
- export generated/downloaded

Event fields (minimum):
- userId, workspaceId, orgId
- target domain/url
- mode
- action
- outcome
- policy rule id
- timestamp

---

## 17) Compliance Acceptance Criteria (MVP)

- migration jobs cannot run without verified ownership.
- audit mode cannot produce clone/export artifacts.
- recreation mode outputs are layout-oriented with safe defaults.
- policy denials are explicit and logged.
- retention/deletion jobs function as configured.
- legal consent records are versioned and retrievable.

---

## 18) Policy Versioning and Change Management

- maintain `POLICY_VERSION` identifiers
- include policy version in every job record
- when policy changes:
  - require re-acceptance for relevant users
  - migrate jobs to new enforcement behavior only where safe
  - log effective date and change notes

---

## 19) Open Decisions

1. Should verified migration allow optional robots override with enhanced warning?
2. Do we allow any raw HTML export for recreation mode under enterprise plans?
3. What exact TTL should ownership proofs use by default?
4. Is legal consent required per-job or per-domain per-policy-version?
5. Which jurisdictions require stricter data retention defaults?