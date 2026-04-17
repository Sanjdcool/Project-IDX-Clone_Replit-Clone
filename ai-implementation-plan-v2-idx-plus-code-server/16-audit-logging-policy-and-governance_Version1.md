# 16 — Audit Logging, Policy, and Governance

## Status
Draft (target: security + compliance + platform sign-off)

## Date
2026-04-16

## Purpose

Define governance-grade audit logging requirements, policy decision tracking, and operational controls to ensure accountability, traceability, and compliance readiness across the IDX + code-server platform.

---

## 1) Governance Objectives

1. Provide complete traceability for user, admin, and system actions.
2. Preserve high-integrity audit trails for security and compliance.
3. Enforce policy decisions consistently and explainably.
4. Support incident investigation and postmortem reconstruction.
5. Establish retention, access, and tamper-resistance standards.

---

## 2) Audit Scope

## In scope
1. Authentication and session events
2. Authorization and policy decisions
3. Workspace lifecycle actions
4. IDE access and route decisions
5. AI tool executions and mutating operations
6. Git operations and code-apply events
7. Admin/security override actions
8. Secret and egress control events (summarized + critical detail)

## Out of scope
1. Full raw user code/content archival in audit logs
2. Replacing product analytics with audit stream

---

## 3) Audit Event Model (Canonical)

Each audit event must include:

- `event_id` (unique, immutable)
- `timestamp` (UTC ISO-8601)
- `event_type`
- `actor_type` (`user|service|admin|system`)
- `actor_id`
- `org_id`
- `project_id` (if applicable)
- `workspace_id` (if applicable)
- `request_id` / `trace_id`
- `resource_type` and `resource_id`
- `action`
- `decision` (`allow|deny|error|info`)
- `policy_id` / `policy_version` (if policy evaluated)
- `reason_code` (stable machine-readable)
- `metadata` (safe, non-sensitive summary)

---

## 4) Event Categories (Required)

1. **Auth events**
   - login success/failure
   - session revoke/expire
2. **Access control events**
   - permission checks
   - policy allow/deny
3. **Workspace events**
   - create/start/stop/delete/snapshot/restore
4. **IDE/route events**
   - IDE connect grant/deny
   - preview exposure changes
5. **AI/tool events**
   - tool call requested/executed/denied
   - mutating file/command/git actions
6. **Security events**
   - token replay detection
   - suspicious behavior and blocks
7. **Admin events**
   - role changes
   - overrides/emergency actions

---

## 5) Policy Decision Logging Requirements

For every policy evaluation log:

1. subject (user/service principal)
2. resource and action requested
3. policy set consulted
4. decision outcome
5. reason code(s)
6. enforcement point (API/gateway/tool broker/etc.)
7. policy version used

This enables deterministic “why was this denied/allowed?” reconstruction.

---

## 6) Data Minimization and Privacy

1. Do not log raw secrets, tokens, or credentials.
2. Do not log full sensitive file contents by default.
3. Use hashed/tokenized references for sensitive identifiers where needed.
4. Keep audit metadata sufficient for forensics without over-collection.
5. Apply privacy and retention rules by data classification.

---

## 7) Tamper Resistance and Integrity

1. Audit stream must be append-only.
2. Immutable storage target or write-once retention controls recommended.
3. Integrity checks/signatures for critical audit batches.
4. Strict access control and separation of duties for audit data.
5. All audit access/read queries are themselves auditable.

---

## 8) Retention and Archival Policy

Define retention by event class and compliance needs:

1. Security-critical events: longer retention
2. Operational events: medium retention
3. High-volume debug-level event subsets: shorter retention/sampled

Include:
- retention schedule,
- archival tier,
- deletion and legal hold exception rules.

---

## 9) Access Governance for Audit Data

1. Role-based access to audit systems (least privilege).
2. Separation:
   - security/compliance readers
   - platform operators
   - limited support visibility
3. Break-glass access with approval + reason capture.
4. Periodic access review and certification process.

---

## 10) Correlation and Traceability Standards

All systems must propagate:
- `request_id`
- `trace_id`
- `workspace_id` (when applicable)
- `org_id` (when applicable)

Goal: reconstruct end-to-end path:
User action -> policy decision -> tool/runtime action -> outcome.

---

## 11) Alerting and Governance Monitoring

Create alerts for:

1. unusual deny spikes
2. repeated unauthorized access attempts
3. high-risk admin override usage
4. missing audit event ingestion from critical services
5. tamper/integrity verification failures

Governance dashboards should expose weekly compliance posture.

---

## 12) Incident and Forensics Readiness

1. Audit queries should support timeline reconstruction.
2. Support exportable forensic bundles with chain-of-custody metadata.
3. Maintain runbooks for:
   - data breach investigation,
   - account compromise,
   - privilege abuse scenarios.
4. Ensure cross-service clock sync for reliable sequencing.

---

## 13) Policy Lifecycle Governance

1. Every policy has owner, version, change log.
2. Policy changes require review and approval workflow.
3. Policy rollout supports staged/canary mode.
4. Rollback path required for faulty policy releases.
5. Policy test suites required before production deployment.

---

## 14) Compliance Readiness Controls

1. Evidence generation:
   - access logs,
   - policy decisions,
   - control operation history.
2. Periodic control validation reports.
3. Mapping of controls to compliance frameworks (as applicable).
4. Documented exception handling process.

---

## 15) Implementation Checklist

- [ ] Define canonical audit schema and event taxonomy
- [ ] Implement audit emitters in all critical services
- [ ] Implement centralized immutable audit ingestion pipeline
- [ ] Implement policy decision logging with stable reason codes
- [ ] Implement audit access RBAC and break-glass workflow
- [ ] Implement retention + archival + legal hold controls
- [ ] Implement integrity verification checks and alerting
- [ ] Build governance and compliance dashboards

---

## 16) Acceptance Criteria

1. Critical user/admin/system actions are fully traceable end to end.
2. Policy allow/deny decisions are explainable and version-linked.
3. Audit records are tamper-resistant and access-controlled.
4. Security/compliance teams can run investigations without missing core evidence.
5. Retention and governance controls are automated and test-validated.

---

## 17) Dependencies

- `05-identity-auth-sso-session-bridging.md`
- `10-ai-agent-tooling-contracts.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `15-secrets-management-and-egress-controls.md`
- `18-observability-slos-and-alerting.md`
- `30-support-runbooks-and-incident-response.md`

---

## 18) Next Document

Proceed to:
`17-license-compliance-and-third-party-policy.md`