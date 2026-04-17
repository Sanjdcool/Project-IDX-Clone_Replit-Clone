# 10 — AI Agent Tooling Contracts

## Status
Draft (target: AI + platform + security sign-off)

## Date
2026-04-16

## Purpose

Define the contract between AI orchestration and workspace runtime tools so the agent can safely perform developer actions (read/write files, run commands, inspect outputs, perform git ops) inside isolated workspaces.

---

## 1) Design Goals

1. Deterministic, auditable tool execution.
2. Safe-by-default permissions and policy checks.
3. Workspace-scoped actions only.
4. Clear error semantics for robust agent planning.
5. Compatibility with future multi-model orchestration.

---

## 2) Tooling Architecture

1. **AI Orchestrator** (control plane)
2. **Tool Broker** (policy + execution gateway)
3. **Workspace Runtime Adapter** (exec/file/git bridge)
4. **Audit/Event Pipeline** (immutable records)
5. **Policy Engine** (authorization + rate + risk rules)

---

## 3) Contract Principles

1. Every tool call must include workspace/org/user context.
2. Every mutating tool call requires explicit authorization.
3. All tool outputs are structured (JSON schema).
4. Timeouts and resource limits are mandatory.
5. Tool calls are idempotent where practical or idempotency-keyed.

---

## 4) Required Tool Set (MVP)

## 4.1 File tools
- `fs.list`
- `fs.read`
- `fs.write`
- `fs.patch`
- `fs.mkdir`
- `fs.delete` (guarded)

## 4.2 Command tools
- `exec.run`
- `exec.stream` (optional phase)
- `exec.stop`

## 4.3 Project tools
- `proj.search` (code/text search)
- `proj.tree`
- `proj.diagnostics` (lint/test/build parser optional)

## 4.4 Git tools
- `git.status`
- `git.diff`
- `git.add`
- `git.commit`
- `git.branch`
- `git.checkout`
- `git.push` (guarded/credential policy)

---

## 5) Tool Call Envelope Schema (Conceptual)

Required fields:
- `tool_name`
- `request_id`
- `conversation_id`
- `actor_user_id`
- `org_id`
- `project_id`
- `workspace_id`
- `idempotency_key` (for mutating calls)
- `args` (tool-specific payload)
- `timeout_ms`
- `policy_context` (plan/risk flags)

---

## 6) Tool Result Envelope Schema (Conceptual)

Required fields:
- `request_id`
- `tool_name`
- `status` (`success|error|timeout|denied`)
- `duration_ms`
- `result` (typed payload)
- `error_code` (if not success)
- `error_message_safe`
- `trace_id`
- `side_effect_summary` (mutating tools)

---

## 7) Authorization and Policy Checks

Before execution, Tool Broker must verify:

1. User/session validity
2. Workspace ownership/access scope
3. Tool-specific permission scope
4. Plan/quota limits (token/tool budget, command limits)
5. Risk policy (sensitive path/command restrictions)

If any check fails:
- return `status=denied`,
- include standardized `error_code`,
- emit audit event.

---

## 8) Path and Filesystem Safety Rules

1. Enforce workspace root confinement (no path traversal outside root).
2. Normalize and validate all paths before execution.
3. Block access to restricted platform metadata directories unless explicitly allowed.
4. Large file read/write limits by policy.
5. Optional protected file patterns (e.g., `.env`, secrets files) require higher confirmation policy.

---

## 9) Command Execution Safety Rules

1. Allowlist/denylist command policy (configurable by plan/org).
2. Hard timeout per command.
3. Max stdout/stderr capture limits.
4. Restricted environment variables passed to execution context.
5. Optional human confirmation for high-risk operations:
   - destructive delete,
   - mass refactor across many files,
   - package publish/deploy commands.

---

## 10) Git Operation Rules

1. Git actions are workspace-scoped only.
2. Identity attribution for commits configurable:
   - user identity passthrough,
   - platform bot identity with co-author metadata.
3. Push operations require credential policy + branch protections.
4. Commit messages and diffs logged for audit metadata (content redaction policy applied where needed).

---

## 11) Error Taxonomy (Standardized)

## 11.1 Categories

- `AUTH_*` (auth/session issues)
- `PERMISSION_*` (policy denied)
- `VALIDATION_*` (bad arguments/schema)
- `FS_*` (filesystem errors)
- `EXEC_*` (command runtime errors)
- `GIT_*` (git failures)
- `RATE_LIMIT_*` (quota/throttle)
- `INTERNAL_*` (unexpected system failures)

## 11.2 Requirements

- Stable machine-readable error codes.
- User-safe message for UI.
- Internal diagnostic details in logs only.

---

## 12) Observability and Audit

For every tool call, record:

1. actor + workspace context
2. tool name + args hash (or safe summary)
3. start/end timestamps and duration
4. status + error code
5. side-effect metadata:
   - files changed count
   - commands executed
   - git refs affected

No sensitive secret values should be logged.

---

## 13) Rate Limits and Quotas

1. Per-user concurrent tool call limit.
2. Per-workspace execution budget per interval.
3. Token/compute budget tied to plan.
4. Burst controls for abusive automation loops.
5. Graceful degradation messages on limit breach.

---

## 14) Human-in-the-Loop Controls

Policy may require confirmation for:
- destructive operations,
- wide-scope mutations,
- external network actions,
- deploy/publish commands.

Confirmation contract:
- tool request paused with action summary,
- explicit approve/reject event captured,
- timeout auto-cancel behavior defined.

---

## 15) Versioning and Compatibility

1. Tool schemas versioned independently.
2. Backward compatibility window for clients/agent prompts.
3. Deprecated tools require sunset timeline and migration docs.
4. Contract tests required before tool schema releases.

---

## 16) Testing Strategy

1. Unit tests:
   - schema validation
   - path normalization
   - permission evaluator
2. Integration tests:
   - end-to-end tool execution in sandbox workspace
3. Security tests:
   - path traversal attempts
   - command injection vectors
4. Load tests:
   - concurrent tool runs under quota controls
5. Chaos tests:
   - runtime disconnect mid-tool call
   - broker restarts with in-flight operations

---

## 17) Implementation Checklist

- [ ] Define JSON schemas for tool request/response envelopes
- [ ] Implement tool registry and policy middleware
- [ ] Implement workspace-root path guard and normalization
- [ ] Implement command execution guardrails and timeout handling
- [ ] Implement standardized error taxonomy
- [ ] Implement audit event emission and redaction rules
- [ ] Implement quota/rate limit enforcement
- [ ] Implement contract test suite for tool compatibility

---

## 18) Acceptance Criteria

1. Agent can perform core file/exec/git workflows via structured tools.
2. All tool actions are workspace-scoped and policy-checked.
3. Denied/failed operations return deterministic machine-readable errors.
4. Audit trail is complete and searchable by request/workspace/user.
5. Tool contracts are versioned and validated in CI.

---

## 19) Dependencies

- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`
- `09-runtime-execution-preview-and-port-management.md`
- `12-prompt-orchestration-and-guardrails.md`
- `16-audit-logging-policy-and-governance.md`
- `29-pricing-metering-and-quota-enforcement.md`

---

## 20) Next Document

Proceed to:
`11-context-engine-indexing-and-retrieval.md`