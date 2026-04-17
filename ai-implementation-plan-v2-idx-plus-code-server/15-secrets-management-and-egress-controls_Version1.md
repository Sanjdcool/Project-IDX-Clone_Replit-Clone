# 15 — Secrets Management and Egress Controls

## Status
Draft (target: security + infra + platform sign-off)

## Date
2026-04-16

## Purpose

Define end-to-end controls for secret lifecycle management and runtime network egress restrictions in the IDX + code-server platform to prevent credential leakage, unauthorized external access, and data exfiltration.

---

## 1) Security Goals

1. No hardcoded or long-lived unmanaged secrets in code/runtime.
2. Secrets are injected just-in-time with least privilege.
3. Runtime egress is policy-controlled and auditable.
4. High-risk external access patterns are blocked/detected.
5. Secret usage and network actions are traceable for incident response.

---

## 2) Secret Classes

1. **Platform secrets**
   - DB credentials, service keys, signing keys
2. **Tenant/org secrets**
   - deployment keys, API tokens, provider credentials
3. **Workspace ephemeral secrets**
   - short-lived tokens for scoped runtime actions
4. **User-linked secrets**
   - optional user-provided tokens (strict handling policy)

Each class has separate scope, storage policy, and rotation cadence.

---

## 3) Secret Storage Architecture

1. Centralized secret manager (required).
2. Encryption at rest with managed KMS keys.
3. Strict IAM/service-account scoping per environment/service.
4. No secret storage in plaintext config maps/repo files.
5. Secret metadata catalog with owner, scope, expiry, rotation policy.

---

## 4) Secret Injection Model

## 4.1 Injection principles

1. Inject at runtime, not build time.
2. Inject only to authorized workloads.
3. Minimize secret lifetime in process env/memory.
4. Avoid broad environment-wide secret exposure.

## 4.2 Delivery options (ordered preference)

1. Runtime fetch via workload identity + short-lived token
2. Sidecar/agent-based secure injection
3. Ephemeral env var injection (last resort for specific compatibility)

---

## 5) Secret Scope and Access Policy

1. Secrets must be scoped by:
   - environment,
   - org/project/workspace where applicable,
   - action/use-case.
2. Workspace runtime can only access secrets explicitly attached and authorized.
3. Cross-tenant secret access is denied by architecture.
4. Access attempts are logged (success + denied).

---

## 6) Secret Rotation Policy

1. Platform critical secrets: strict periodic rotation + emergency rotation support.
2. Tenant secrets: policy-driven rotation reminders/enforcement.
3. Ephemeral tokens: very short TTL and auto-expiry.
4. Rotation events trigger compatibility checks and audit records.

---

## 7) Secret Redaction and Leak Prevention

1. Redact known secret patterns in logs, traces, and AI tool outputs.
2. Prevent accidental secret echo in UI/assistant responses.
3. Block commit/push flows when secret scanning detects high-confidence leak.
4. Optional pre-snapshot secret scan before export/snapshot completion.

---

## 8) Egress Control Architecture

## 8.1 Egress policy layers

1. Network policy layer (runtime namespace/segment)
2. DNS resolution control
3. HTTP proxy/egress gateway policy (recommended)
4. Application-level allowlist/denylist checks (for specific tools/actions)

## 8.2 Default posture

- Deny-by-default or restricted-allow baseline for runtime workloads (preferred).
- Explicit allow rules for required package registries/endpoints based on profile/policy.

---

## 9) Egress Policy Dimensions

1. Destination domain/IP allowlists
2. Protocol/port restrictions
3. Environment-tier rules (dev/staging/prod)
4. Org/plan-level customization (enterprise options)
5. Time-bound exceptions with approval workflow

---

## 10) SSRF and Internal Access Protections

1. Block access to cloud metadata endpoints.
2. Block internal control-plane/private network ranges unless explicitly required.
3. Normalize/validate outbound URLs for brokered HTTP tools.
4. Deny suspicious redirect chains to internal/private targets.
5. Monitor for repeated blocked internal target attempts.

---

## 11) AI/Tooling-Specific Secret and Egress Controls

1. Tool broker enforces secret-access scope before command/tool execution.
2. AI-generated commands involving external network access may require policy gate.
3. High-risk network actions can require human approval.
4. Tool outputs containing probable secrets are masked before returning to model/user.

---

## 12) Observability and Auditing

## 12.1 Secret audit events
- secret created/updated/rotated/revoked
- secret access granted/denied
- secret injection success/failure
- leak detection incidents

## 12.2 Egress audit events
- allowed outbound connections (sampled/aggregated as needed)
- blocked outbound attempts with reason codes
- anomalous destination patterns

## 12.3 Metrics
- secret access deny rate
- rotation compliance rate
- blocked egress count by policy type
- suspicious egress anomaly count

---

## 13) Incident Response Playbooks (Required)

1. Suspected secret leak
2. Credential misuse/abuse
3. Egress anomaly/exfiltration suspicion
4. Compromised token/service account

Each playbook includes containment, rotation, blast-radius assessment, and post-incident review steps.

---

## 14) Implementation Controls Checklist

- [ ] Integrate centralized secret manager in all environments
- [ ] Enforce no-plaintext secret policy in repos/configs
- [ ] Implement scoped secret injection workflow
- [ ] Implement redaction middleware across logs/tool outputs
- [ ] Implement pre-commit/pre-push secret scanning gates
- [ ] Implement runtime egress restrictions (network + gateway controls)
- [ ] Block metadata/internal endpoint access from runtime
- [ ] Add audit/event pipelines for secret and egress actions
- [ ] Implement emergency rotation runbook and automation hooks

---

## 15) Acceptance Criteria

1. Secrets are never hardcoded or broadly exposed to unauthorized workloads.
2. Secret access is scoped, short-lived where possible, and fully auditable.
3. Runtime outbound traffic is policy-restricted and monitored.
4. SSRF/internal endpoint abuse attempts are blocked by default.
5. Leak detection and response workflows are operationally tested.

---

## 16) Dependencies

- `14-security-isolation-and-sandbox-hardening.md`
- `16-audit-logging-policy-and-governance.md`
- `18-observability-slos-and-alerting.md`
- `30-support-runbooks-and-incident-response.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 17) Next Document

Proceed to:
`16-audit-logging-policy-and-governance.md`