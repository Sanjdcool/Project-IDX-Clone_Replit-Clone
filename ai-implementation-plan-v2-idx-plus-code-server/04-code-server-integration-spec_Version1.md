# 04 — code-server Integration Spec

## Status
Draft (target: platform + runtime sign-off)

## Date
2026-04-16

## Purpose

Define the technical specification for integrating `code-server_IDX-project` as the IDE runtime for the IDX control plane product (`Project-IDX-Clone_Replit-Clone`).

This spec covers:
- integration architecture,
- session/access flow,
- runtime contract,
- embedding/routing behavior,
- lifecycle and health management,
- security and observability requirements.

---

## 1) Integration Goals

1. Provide seamless “Open in IDE” experience from IDX product UI.
2. Support isolated per-workspace runtime sessions.
3. Ensure secure, short-lived authenticated access to IDE routes.
4. Keep code-server customization minimal and maintainable.
5. Enable production reliability (health, restart, telemetry, compatibility).

---

## 2) Non-Goals

1. Rewriting code-server core editor architecture.
2. Implementing real-time multiplayer editor collaboration in initial integration.
3. Replacing control-plane policy with IDE-side authorization.
4. Allowing direct user access to runtime endpoints without proxy controls.

---

## 3) Runtime Packaging Model

## 3.1 Recommended packaging
- Build `code-server` as a runtime container image:
  - base OS hardened image,
  - code-server binary/runtime,
  - minimal approved extensions,
  - bootstrap entrypoint scripts,
  - health/readiness probes.

## 3.2 Runtime image tagging
- Semantic tags: `runtime-v<major>.<minor>.<patch>`
- Optional commit tag for traceability: `runtime-vX.Y.Z+<sha>`
- IDX control plane deploys against explicit approved runtime tags only.

---

## 4) End-to-End User Flow (Open IDE)

1. User clicks **Open IDE** in IDX UI.
2. IDX control plane checks:
   - user auth,
   - workspace membership/permission,
   - plan/quota/policy.
3. If workspace not running, Workspace Manager starts/provisions runtime.
4. Control plane generates short-lived signed IDE access token.
5. Client is redirected or embedded to proxy route:
   - `/w/{workspaceId}/ide`
6. Proxy validates token + workspace binding.
7. Proxy forwards request/websocket to workspace code-server endpoint.
8. code-server serves editor session.
9. Control plane records session start event for audit/metering.

---

## 5) Integration Topology

## 5.1 Logical components

1. IDX Web App (frontend)
2. IDX API (auth/policy/workspace)
3. Workspace Manager
4. IDE Route Gateway/Proxy
5. code-server Runtime (workspace-scoped)
6. Metrics/Logging/Audit services

## 5.2 Network routing pattern

- Public entry:
  - `app.<domain>` (control plane UI/API)
  - `ide.<domain>/w/{workspaceId}/...` (IDE gateway)
- Internal:
  - gateway -> runtime service endpoint by workspace mapping

No direct public exposure of runtime pod/container addresses.

---

## 6) Runtime Contract (Required Environment + Inputs)

At startup, runtime container receives:

1. `WORKSPACE_ID`
2. `PROJECT_ID`
3. `ORG_ID`
4. `USER_ID` (or session principal binding model)
5. `WORKSPACE_ROOT` (e.g., `/workspace`)
6. `IDE_PORT` (default internal port)
7. `RUNTIME_REGION` (optional)
8. `TRACE_CONTEXT` baseline fields (optional but recommended)
9. `ALLOWED_PREVIEW_PORTS` (policy-defined)
10. `SESSION_MODE` (single-user or managed)

Secrets must be injected through secure secret manager/env injection policy, never hardcoded.

---

## 7) Auth and Session Bridging

## 7.1 Token type
- Short-lived signed token (JWT or equivalent), containing:
  - `sub` (user/session principal)
  - `workspace_id`
  - `org_id`
  - `scope` (`ide:connect`)
  - `exp` (very short TTL, e.g., minutes)
  - nonce/jti for replay mitigation

## 7.2 Validation points
1. Gateway validates signature + expiry + route binding.
2. Control plane can introspect if required for high-risk actions.
3. Runtime trusts forwarded identity headers from gateway only (not raw client claims).

---

## 8) Embedding Model (Frontend)

## 8.1 UX options
1. Full-page IDE route (preferred for stability first)
2. Embedded iframe panel mode (optional after baseline stability)

## 8.2 Required UX events
- launching workspace
- runtime ready
- ide connected
- connection lost/reconnecting
- permission denied/session expired

These events should feed analytics + support diagnostics.

---

## 9) Workspace Filesystem and Persistence

1. code-server must mount a persistent workspace volume.
2. Required persistence targets:
   - project source files,
   - workspace config/state needed for continuity.
3. Ephemeral caches can remain non-persistent.
4. Snapshot/backup triggers managed by control plane, not IDE UI alone.

---

## 10) Terminal and Command Execution Policy

1. Terminal is enabled within workspace scope.
2. Command execution respects workspace policy and resource limits.
3. Privileged host-level operations are prohibited.
4. Optionally route sensitive operations through Tool Broker for policy auditing.

---

## 11) Preview and Port Forwarding Rules

1. Runtime may expose configured preview ports only.
2. Control plane/gateway maps preview route:
   - `/w/{workspaceId}/preview/{port}`
3. Port allowlist/denylist enforced server-side.
4. Public sharing of preview links must require explicit policy and tokenized access.

---

## 12) Health, Readiness, and Lifecycle

## 12.1 Health endpoints/signals
- runtime process alive
- editor service listening
- workspace volume mounted
- optional dependency checks

## 12.2 Lifecycle states (canonical)
- `PROVISIONING`
- `STARTING`
- `READY`
- `DEGRADED`
- `STOPPING`
- `STOPPED`
- `FAILED`

Control plane owns canonical state machine; runtime reports state signals.

---

## 13) Observability Requirements

## 13.1 Logging
- structured logs (json)
- fields:
  - timestamp
  - workspace_id
  - org_id
  - user/session principal
  - request_id
  - event_type
  - severity

## 13.2 Metrics
- ide startup latency
- connection success/failure rate
- websocket disconnect rate
- runtime restarts/crash loops
- file operation latency (high-level)
- preview availability rate

## 13.3 Tracing
- propagate trace IDs from control plane -> gateway -> runtime where feasible.

---

## 14) Security Controls

1. Strict token TTL and audience/scope checks.
2. No unauthenticated runtime endpoints.
3. Header sanitization at gateway (strip untrusted identity headers).
4. Container hardening:
   - non-root user,
   - dropped capabilities,
   - seccomp/apparmor profiles,
   - read-only root where possible.
5. Egress/network policy restrictions for runtime namespace.
6. Session revocation support on user logout/suspicious activity.

---

## 15) Performance Targets (Initial)

1. Workspace-to-IDE ready (warm): target p95 <= defined in perf doc.
2. Workspace-to-IDE ready (cold): target p95 <= defined in perf doc.
3. IDE connect success rate >= 99.5%.
4. Unexpected disconnect rate below defined threshold.

(Exact values finalized in `19-performance-capacity-and-autoscaling.md`.)

---

## 16) Compatibility and Upgrade Strategy

1. Maintain version matrix:
   - IDX release version ↔ runtime image version.
2. Runtime upgrades promoted through environments:
   - dev -> staging -> beta -> prod.
3. Require integration smoke suite pass before promotion.
4. Keep patch changelog in runtime repo for every divergence from upstream behavior.

---

## 17) Failure Handling and Recovery

## Common failures
1. Workspace not ready in time
2. Token expired during connect
3. Proxy route mapping stale
4. Runtime crash loop
5. Volume mount failure

## Recovery behaviors
- user-facing retry with meaningful state messages,
- automated reconciliation loop for route/runtime mapping,
- restart policy with max retry + failure escalation,
- support diagnostic bundle generation.

---

## 18) Implementation Checklist

- [ ] Define runtime image build and tag policy
- [ ] Implement token issuance + validation path
- [ ] Implement `/w/{workspaceId}/ide` gateway route
- [ ] Wire lifecycle states between manager and runtime
- [ ] Add health/readiness probes and alarms
- [ ] Add structured logs + metrics fields
- [ ] Add integration smoke tests
- [ ] Document compatibility matrix and upgrade runbook

---

## 19) Acceptance Criteria

1. Authenticated user can open IDE from IDX UI with no manual credentials.
2. Workspace isolation is enforced per route/token.
3. Runtime health and lifecycle visible in control plane dashboard.
4. Crash/restart scenarios recover within defined operational bounds.
5. Observability data supports root-cause analysis across control plane and runtime.

---

## 20) Next Documents

- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `08-workspace-storage-filesystem-and-snapshots.md`