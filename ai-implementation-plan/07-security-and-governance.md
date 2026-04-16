# 07 — Security and Governance

## 1) Purpose

Define security controls and governance standards for AI-powered code generation, patch application, and sandbox execution.

This document ensures the platform remains:
- safe for users,
- resistant to abuse,
- auditable for incident response,
- compliant with internal policy expectations.

---

## 2) Security Objectives

1. Prevent unsafe filesystem access and command execution.
2. Protect secrets and sensitive user data.
3. Ensure all AI actions are attributable and reviewable.
4. Reduce blast radius of model mistakes.
5. Enable rapid detection and response to abuse/incidents.

---

## 3) Threat Model (High-Level)

## 3.1 Threat actors
- malicious user trying to escape sandbox
- compromised session/token misuse
- prompt-injection content inside repo files
- abusive AI-generated command suggestions
- accidental destructive edits by normal users

## 3.2 Assets to protect
- host system and infrastructure
- user workspaces and source code
- credentials/API keys/secrets
- service availability
- audit and telemetry integrity

## 3.3 Attack surfaces
- API endpoints (`generate/apply/run/fix/rollback`)
- websocket channels
- workspace file operations
- command execution in containers
- logs and persisted prompts
- third-party model provider traffic

---

## 4) Identity, AuthN, and AuthZ

## 4.1 Authentication
- Require authenticated user session for all AI endpoints.
- Validate token/session on every HTTP + socket request.
- Enforce short-lived tokens where possible.

## 4.2 Authorization
- Workspace-level access control:
  - user can operate only on owned/authorized workspace.
- Session ownership checks for all actions.
- Prevent cross-workspace ID enumeration attacks.

## 4.3 Privilege separation
- Separate service roles:
  - API service role
  - runtime executor role
  - audit writer role
- Minimize permissions per role.

---

## 5) Filesystem Safety Controls

## 5.1 Path normalization
For every operation:
1. normalize path
2. resolve against workspace root
3. verify resolved path begins with workspace root

Reject if:
- `..` traversal escapes root
- absolute paths outside workspace
- symlink escape attempts

## 5.2 Protected paths
Disallow or approval-gate edits for:
- `.git/`
- deployment secrets/configs
- environment key files (`.env*`)
- internal policy configs (as needed)

## 5.3 Write constraints
- max files changed per patch
- max bytes per file
- deny binary writes unless explicitly enabled
- require explicit approval for deletes

---

## 6) Command Execution Security

## 6.1 Allowlist-first policy
Only approved commands can run in sandbox.

## 6.2 Deny risky patterns
Block:
- remote script piping to shell
- package manager global installs
- system admin commands
- scanning/probing/network abuse commands

## 6.3 Runtime isolation
- no privileged containers
- non-root execution
- resource cgroups limits
- bounded network access
- isolated mount namespace

## 6.4 Time/resource controls
- command timeout
- memory/cpu cap
- process count cap
- cancellation support

---

## 7) Prompt and Model Security

## 7.1 Prompt injection resistance
Treat repository content as untrusted context.
- Do not allow repo text to override system policies.
- System prompt must explicitly prioritize platform policy.

## 7.2 Output trust model
LLM output is untrusted until:
1. schema validation passes
2. policy checks pass
3. user approval (for patch application)

## 7.3 Provider controls
- use server-side API keys only
- never expose provider credentials to frontend
- restrict provider endpoints and org scopes where available

---

## 8) Secrets Management

## 8.1 Storage
- store secrets in secure secret manager/environment vault
- never commit secrets to repo

## 8.2 Prompt/log redaction
Before saving prompts/logs:
- redact known token patterns
- scrub env variable values
- apply configurable regex-based redaction

## 8.3 UI exposure
- do not display raw secrets in logs/timeline
- indicate redaction occurred when applicable

---

## 9) Data Governance and Retention

## 9.1 Data categories
- prompts and model outputs
- patch plans and diffs
- run logs
- audit events
- usage metrics

## 9.2 Retention policy (example baseline)
- audit events: long retention (e.g., 90–365 days)
- raw run logs: shorter retention (e.g., 7–30 days)
- summarized metrics: long-term
- sensitive payload snapshots: minimize retention

## 9.3 Deletion and minimization
- store only necessary context for functionality/debugging
- allow user/admin-initiated data cleanup flows

---

## 10) Auditability Requirements

Every critical action must emit immutable audit event:
- who initiated action (`userId`)
- workspace/session/request IDs
- what action occurred (generate/apply/run/fix/rollback)
- model/provider + prompt version
- files touched + operation counts
- policy denials and reasons
- timestamp and result

Audit logs must be tamper-evident or append-only where feasible.

---

## 11) Abuse Prevention and Rate Limiting

## 11.1 Quotas
- per-user daily request caps
- per-session burst limits
- concurrent run limits

## 11.2 Rate limiting
Apply endpoint-specific throttles:
- stricter limits on `generate` and `run`
- websocket event flood protection

## 11.3 Abuse detection signals
- repeated blocked command attempts
- high-frequency failure loops
- unusual token/cost spikes
- suspicious path patterns

Trigger:
- temporary lockout
- manual review flag
- elevated challenge flow (if available)

---

## 12) Governance Policies

## 12.1 Human-in-the-loop policy
Mandatory user approval for:
- file deletes
- large patch sets
- sensitive path edits
- high-risk command profiles

## 12.2 Change policy tiers
- Tier 0: low-risk (small UI/code changes)
- Tier 1: medium-risk (multi-file refactor)
- Tier 2: high-risk (deletes/config/runtime changes)

Higher tiers require stronger confirmations and/or admin policy gates.

## 12.3 Model policy
- approved model/provider list
- prompt template version control
- periodic evaluation for regressions

---

## 13) Incident Response Plan (AI Feature Specific)

## 13.1 Incident classes
1. sandbox escape attempt
2. secrets leakage in logs/prompts
3. unauthorized workspace modifications
4. major provider misuse/cost spike
5. persistent policy bypass behavior

## 13.2 Response workflow
1. detect via alerts/audit
2. contain (disable endpoint/session/provider key rotation)
3. investigate with request/session IDs
4. remediate root cause
5. communicate postmortem + fixes

## 13.3 Forensics readiness
- correlate logs by trace/request IDs
- keep policy-decision records
- preserve relevant audit slices for investigation window

---

## 14) Compliance and Legal Considerations (General)

- Document data sent to model providers.
- Offer provider opt-out policy where required.
- Respect repository privacy boundaries.
- Ensure user consent/notice for AI processing and retention.
- Keep policy docs versioned and reviewable.

---

## 15) Security Testing Strategy

## 15.1 Automated tests
- path traversal tests
- command policy bypass tests
- schema validation fuzz tests
- permission boundary tests

## 15.2 Manual testing
- prompt injection red-team cases
- malicious dependency scripts scenarios
- websocket abuse/flood scenarios

## 15.3 Continuous verification
- recurring penetration checks
- dependency vulnerability scans
- container image scanning in CI

---

## 16) Security Observability

Key security metrics:
- blocked command count
- blocked path operation count
- auth failures by endpoint
- suspicious run cancellations/timeouts
- redaction events count
- incident MTTR (mean time to resolve)

Alerts:
- unusual spike in denied operations
- excessive token usage anomalies
- frequent schema/policy failures from single account

---

## 17) Secure Defaults for MVP

- AI apply requires explicit user approval.
- Delete operations disabled by default (or strongly gated).
- Strict command allowlist only.
- No privileged container capabilities.
- Default redaction enabled for logs.
- Conservative quotas active from day one.

---

## 18) Governance Roles and Responsibilities

- **Product Owner**: defines acceptable AI autonomy levels.
- **Backend Lead**: enforces runtime/policy controls.
- **Security Lead**: threat modeling, incident process, policy audits.
- **DevOps/SRE**: runtime hardening, monitoring, alerting.
- **Data/Privacy Owner**: retention and provider data-sharing rules.

---

## 19) Security Exit Criteria for Public Beta

Public beta only when:
1. Path traversal and command bypass tests pass consistently.
2. Audit logs cover 100% critical AI actions.
3. Secret redaction verified across prompt/log pipelines.
4. Quotas and abuse detection active in production.
5. Incident response runbook rehearsed and documented.

---

## 20) MVP Security Checklist

- [ ] AuthN/AuthZ enforced on all AI endpoints/events.
- [ ] Workspace path normalization and root-bound checks.
- [ ] Command allowlist + timeout + resource limits.
- [ ] Non-root, non-privileged sandbox execution.
- [ ] Prompt/log redaction enabled.
- [ ] Audit events for generate/apply/run/fix/rollback.
- [ ] Rate limiting and per-user quotas active.
- [ ] Security tests included in CI.