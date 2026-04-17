# 14 — Security Isolation and Sandbox Hardening

## Status
Draft (target: security + platform + infra sign-off)

## Date
2026-04-16

## Purpose

Define defense-in-depth security controls for workspace isolation, sandbox hardening, runtime containment, and abuse prevention in the IDX + code-server platform.

---

## 1) Security Objectives

1. Strong tenant and workspace isolation.
2. Minimize sandbox escape and privilege escalation risk.
3. Enforce least privilege across services and runtime.
4. Prevent cross-workspace/network data exposure.
5. Provide auditable security controls and incident response readiness.

---

## 2) Threat Model (High-Level)

Primary threat classes:

1. Cross-tenant access due to auth/routing bugs
2. Sandbox escape from workspace runtime
3. Privilege escalation via misconfigured runtime/container
4. Secret exposure through filesystem/env/log leaks
5. Network abuse (SSRF, scanning, lateral movement)
6. Abuse of command execution/tooling capabilities
7. Supply-chain compromise (images, dependencies, extensions)

---

## 3) Isolation Strategy

## 3.1 Isolation unit
- One isolated runtime per workspace (recommended baseline).

## 3.2 Isolation boundaries
1. Compute boundary (container/pod/VM profile)
2. Filesystem boundary (dedicated volume)
3. Network boundary (namespace policies)
4. Identity boundary (scoped tokens and claims)
5. Process boundary (resource/capability constraints)

---

## 4) Runtime Hardening Baseline

1. Run as non-root user.
2. Drop all unnecessary Linux capabilities.
3. Apply seccomp/apparmor profiles.
4. Read-only root filesystem where feasible.
5. No privileged containers.
6. Disallow host PID/IPC/network namespace sharing.
7. Enforce immutable runtime image policy in production.

---

## 5) Kubernetes/Orchestrator Security Controls (if K8s)

1. Pod Security Standards (restricted baseline).
2. Namespace-per-environment and policy segmentation.
3. NetworkPolicies deny-by-default.
4. Admission controls for security policy enforcement.
5. Image provenance checks (signed images preferred).
6. Resource quotas/limits to prevent noisy-neighbor abuse.

---

## 6) Identity and Access Security

1. Short-lived user/session tokens only.
2. Service-to-service auth via mTLS or signed service tokens.
3. Scope-bound claims (`org_id`, `workspace_id`, `scope`).
4. Strict token audience checks.
5. Replay mitigation (`jti`, short TTL, optional nonce checks).

---

## 7) Filesystem and Data Security

1. One volume per workspace (no shared writable volumes).
2. Encrypted storage at rest.
3. Restricted access to platform metadata directories.
4. Optional secret-file masking policies.
5. Secure deletion workflows for regulatory/tenant deletion events.

---

## 8) Secrets Management

1. No hardcoded secrets in images or repos.
2. Inject secrets at runtime via secret manager.
3. Short-lived credentials preferred over static keys.
4. Secret rotation policy and expiration enforcement.
5. Prevent secret logging (redaction middleware).

---

## 9) Network Egress and SSRF Controls

1. Runtime egress restricted by allowlist policy where possible.
2. Block access to metadata/internal control endpoints.
3. DNS/network policies to reduce exfiltration vectors.
4. Preview/proxy request validation to prevent SSRF abuse.
5. Monitor suspicious outbound patterns.

---

## 10) Command and Tooling Abuse Controls

1. Tool broker policy checks before execution.
2. Restricted command classes and safety prompts for risky actions.
3. Timeout and resource limits on command execution.
4. Rate limiting for tool calls and runtime actions.
5. Abuse scoring and temporary suspension capability for anomalous behavior.

---

## 11) Dependency and Supply Chain Security

1. Pin base images and critical dependencies.
2. Continuous vulnerability scanning (code + images).
3. Signed artifact verification in CI/CD.
4. Extension marketplace policy (allowlist approved extensions).
5. Patch cadence with severity-based SLAs.

---

## 12) Logging, Audit, and Detection

## 12.1 Mandatory security logs
- auth failures/denials
- token validation failures/replay events
- policy denials and overrides
- privileged operation attempts
- network deny events
- suspicious command execution patterns

## 12.2 Detection controls
- anomaly alerts for repeated denied access
- unusual port/process/network behavior
- high-rate automation abuse indicators

---

## 13) Security Testing Requirements

1. SAST and dependency scanning in CI.
2. DAST/security integration tests in staging.
3. Container hardening benchmark checks.
4. Pen-test/red-team scenarios for:
   - route binding bypass,
   - sandbox escape attempts,
   - token replay misuse.
5. Chaos-security drills for incident readiness.

---

## 14) Incident Response Readiness

1. Severity classification matrix (SEV1–SEVx).
2. Security incident runbooks:
   - token/key compromise,
   - cross-tenant access suspicion,
   - runtime escape indicators.
3. Emergency controls:
   - global token revocation,
   - workspace isolation quarantine,
   - high-risk feature kill switch.
4. Forensics-friendly log retention and access controls.

---

## 15) Compliance Alignment (Foundational)

1. Data encryption in transit + at rest.
2. Access control and least-privilege evidence.
3. Audit trail integrity and retention policy.
4. Incident response process documentation.
5. Data retention/deletion controls by policy.

(Advanced compliance program mapped in later governance docs.)

---

## 16) Security Baseline Checklist

- [ ] Non-root runtime enforced
- [ ] Privileged mode disallowed
- [ ] Capability drop list applied
- [ ] Seccomp/apparmor profiles active
- [ ] NetworkPolicies deny-by-default
- [ ] Secret manager integration complete
- [ ] Token replay mitigations enabled
- [ ] Runtime egress restrictions enforced
- [ ] Security scanning gates in CI/CD
- [ ] Incident runbooks tested

---

## 17) Acceptance Criteria

1. Cross-workspace and cross-tenant access is technically blocked by multiple controls.
2. Runtime sandbox meets restricted hardening baseline.
3. Secrets are managed dynamically and not exposed in logs/images.
4. High-risk security events are detected and alertable in near real-time.
5. Incident response playbooks are actionable and tested.

---

## 18) Dependencies

- `05-identity-auth-sso-session-bridging.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `10-ai-agent-tooling-contracts.md`
- `15-secrets-management-and-egress-controls.md`
- `16-audit-logging-policy-and-governance.md`
- `30-support-runbooks-and-incident-response.md`

---

## 19) Next Document

Proceed to:
`15-secrets-management-and-egress-controls.md`