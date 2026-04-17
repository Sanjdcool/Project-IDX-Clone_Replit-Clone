# 09 — Runtime Execution, Preview, and Port Management

## Status
Draft (target: platform + runtime + security sign-off)

## Date
2026-04-16

## Purpose

Define how workspace runtime processes are executed, how app previews are exposed, and how ports are managed securely and reliably in the IDX + code-server integrated platform.

---

## 1) Design Goals

1. Enable reliable in-workspace command execution for build/run/test workflows.
2. Provide secure, user-friendly preview URLs for running apps.
3. Enforce strict port exposure controls and tenant isolation.
4. Support observability and policy enforcement for runtime process actions.
5. Provide deterministic behavior under restart/failure conditions.

---

## 2) Scope

## In scope
1. Runtime command execution model
2. Process lifecycle and supervision
3. Preview service routing
4. Port detection/registration/exposure policy
5. Port-level authorization and sharing controls
6. Runtime execution telemetry and guardrails

## Out of scope
1. CI/CD pipeline design (covered elsewhere)
2. Full deployment platform strategy
3. Advanced collaborative runtime editing semantics

---

## 3) Runtime Execution Model

## 3.1 Execution contexts

Each workspace supports at least:

1. **Interactive context**
   - User terminal commands via IDE session
2. **Managed context**
   - Control-plane/tool-broker initiated commands (AI actions, tasks)
3. **System context**
   - Platform-managed bootstrap/health scripts

All contexts must be attributed to an actor and logged.

## 3.2 Command categories

1. Build commands
2. Run/start-dev-server commands
3. Test commands
4. Utility commands (format/lint/install)
5. Restricted commands (high-risk operations requiring explicit policy)

---

## 4) Process Supervision

1. Runtime includes process supervisor for managed workloads.
2. Track process metadata:
   - pid/process id (logical + system),
   - command,
   - start time,
   - actor context,
   - exit code/state.
3. Detect crash loops and enforce restart/backoff policy.
4. Ensure orphaned process cleanup on workspace stop/delete.

---

## 5) Command Execution Guardrails

1. Max execution timeouts by command type.
2. CPU/memory/resource limits per workspace profile.
3. Concurrency limits for managed command jobs.
4. Policy denylist/allowlist for sensitive commands (as needed).
5. Kill switch for runaway resource consumption.

---

## 6) Preview Architecture

## 6.1 Preview entry model

Preview route pattern:
- `/w/{workspaceId}/preview/{port}/...`
(or equivalent approved domain/path pattern)

## 6.2 Preview activation flow

1. Runtime process starts listening on local port.
2. Port detector registers candidate port with control plane.
3. Policy engine validates exposure eligibility.
4. Gateway binds preview route to runtime port.
5. User accesses preview URL under authenticated session/token policy.

---

## 7) Port Discovery and Registration

## 7.1 Port detection methods

1. Runtime-side listener detection (preferred)
2. Explicit declaration from managed run task config
3. User-declared port mapping (optional workflow)

## 7.2 Port metadata tracked

- `workspace_id`
- `port`
- `protocol` (http/ws/tcp where applicable)
- `visibility` (`private`, `org`, `public` where allowed)
- `registered_by` (user/system/managed task)
- `process_ref`
- `last_seen_at`
- `status` (`pending`, `active`, `blocked`, `closed`)

---

## 8) Port Exposure Policy

## 8.1 Default policy

1. Ports are private by default.
2. Only allowlisted port ranges can be exposed.
3. Public exposure disabled unless plan/policy explicitly allows.
4. Sensitive/system ports always blocked.

## 8.2 Visibility levels (recommended)

1. `private` — current authorized workspace user(s) only
2. `org` — authenticated org members (optional)
3. `public` — explicit opt-in + warning + policy checks (optional tiered feature)

---

## 9) Authentication and Authorization for Preview Access

1. Preview access must pass workspace/org policy checks.
2. Token/session must be validated at gateway for private/org visibility.
3. Public previews require:
   - explicit user action,
   - policy eligibility,
   - revocable share token/URL model,
   - audit logging of share lifecycle events.

---

## 10) Protocol and Traffic Handling

1. HTTP/HTTPS previews first-class support.
2. WebSocket proxy support for frameworks requiring live reload channels.
3. Timeouts and keepalive tuned for dev-server patterns.
4. Response size/rate controls to reduce abuse patterns.

---

## 11) Security Controls

1. Strict workspace-to-port binding in route layer.
2. Prevent SSRF through preview proxy route misuse.
3. Enforce host/path normalization and sanitization.
4. Block loopback/internal metadata endpoint access from exposed paths where required.
5. Apply abuse protections:
   - rate limits,
   - request throttling,
   - anomaly detection.

---

## 12) Runtime-to-Gateway Contract

Required events/calls from runtime plane:

1. `port.opened`
2. `port.updated`
3. `port.closed`
4. `process.started`
5. `process.exited`
6. `process.crashloop_detected`

Each event includes workspace identity, actor context, and correlation IDs.

---

## 13) UX Requirements

1. Preview panel lists active ports and status.
2. One-click open/copy preview URL.
3. Clear visibility indicators (private/org/public).
4. User controls to stop/restart associated run process.
5. Actionable error messages:
   - port blocked,
   - process not running,
   - policy denied,
   - token expired.

---

## 14) Failure Modes and Recovery

## Common failures
1. Port opened but not routable (stale mapping)
2. Runtime process exits unexpectedly
3. Gateway route registration fails
4. Conflicting port occupancy
5. Unauthorized preview access attempts

## Recovery
- automatic route reconciliation,
- restart/retry managed processes with backoff,
- conflict resolution UI + guidance,
- immediate deny + audit on auth violations.

---

## 15) Observability Requirements

## 15.1 Metrics

- command execution success/failure rate
- command latency by category
- process crash loop counts
- active preview routes count
- preview request success/error rates
- port registration latency and failures

## 15.2 Logs

- actor-attributed command execution logs
- port exposure/visibility change logs
- gateway access decision logs for preview endpoints

## 15.3 Traces

- end-to-end trace: user action -> command -> port registration -> preview route -> response

---

## 16) Resource and Quota Controls

1. Limit concurrent active preview ports per workspace.
2. Limit background process count by profile.
3. CPU/memory hard limits enforced at runtime layer.
4. Long-running idle process policy (auto-suspend/notify).
5. Quota breach actions:
   - deny new process start,
   - degrade optional functionality,
   - notify user/admin.

---

## 17) Compliance and Audit Requirements

Audit events required for:

1. managed command execution requests/results
2. preview visibility changes
3. public share creation/revocation (if enabled)
4. policy denials and override actions
5. operator interventions on runtime processes

---

## 18) Testing Strategy

1. Unit tests:
   - port policy evaluator
   - command guardrail enforcement
2. Integration tests:
   - run command -> preview route availability
   - websocket preview behavior
3. Security tests:
   - unauthorized preview access
   - blocked port exposure attempts
4. Load tests:
   - many simultaneous previews/processes
5. Chaos tests:
   - process crashes, gateway restarts, route store churn

---

## 19) Implementation Checklist

- [ ] Implement process supervisor metadata + lifecycle hooks
- [ ] Implement port detection and registration pipeline
- [ ] Implement preview routing with workspace-bound checks
- [ ] Implement visibility model + policy enforcement
- [ ] Implement command guardrails (timeout, limits, deny rules)
- [ ] Add preview UX controls and state indicators
- [ ] Add metrics/logging/tracing instrumentation
- [ ] Add reconciliation + recovery logic for route/process drift

---

## 20) Acceptance Criteria

1. Users can run app processes and access previews reliably from IDE workflow.
2. Port exposure is policy-controlled and private by default.
3. Unauthorized preview access is blocked with auditable logs.
4. Runtime process failures are detected and surfaced with recovery options.
5. Preview and command flows meet defined reliability and latency targets.

---

## 21) Dependencies

- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `10-ai-agent-tooling-contracts.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `18-observability-slos-and-alerting.md`
- `29-pricing-metering-and-quota-enforcement.md`

---

## 22) Next Document

Proceed to:
`10-ai-agent-tooling-contracts.md`