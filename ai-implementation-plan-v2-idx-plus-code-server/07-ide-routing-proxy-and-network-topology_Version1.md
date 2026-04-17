# 07 — IDE Routing, Proxy, and Network Topology

## Status
Draft (target: infra + security sign-off)

## Date
2026-04-16

## Purpose

Define secure network topology and routing architecture for IDE and preview traffic across:

- public edge,
- control plane,
- workspace runtime endpoints,
- internal service mesh/network segments.

This document ensures that IDE access is secure, route-bound, observable, and operationally scalable.

---

## 1) Design Goals

1. Provide stable and low-latency IDE and preview routing.
2. Ensure no direct public access to runtime containers/pods.
3. Enforce workspace and tenant boundary checks at edge.
4. Support websocket traffic reliably (code-server terminal/editor channels).
5. Enable route reconciliation and fault recovery at scale.

---

## 2) Topology Overview

## 2.1 Public Domains (recommended)

1. `app.<domain>`  
   - product web app + control plane APIs
2. `ide.<domain>`  
   - IDE gateway entry for workspace IDE sessions
3. `preview.<domain>` (optional split)  
   - app preview routes

Alternative: single domain with path segmentation is acceptable if policy/observability remain strong.

---

## 2.2 Logical Network Planes

1. **Edge Plane**
   - external ingress, TLS, WAF, DDoS protections
2. **Gateway Plane**
   - workspace route resolver and auth validation
3. **Control Plane**
   - API services, policy, orchestrator
4. **Runtime Plane**
   - workspace runtime pods/containers (code-server + app runtime)
5. **Data Plane**
   - databases, queues, storage
6. **Observability Plane**
   - metrics/logs/traces and alerting backends

---

## 3) Request Routing Model

## 3.1 IDE route pattern

Canonical IDE path:
- `https://ide.<domain>/w/{workspaceId}/ide/...`

Flow:
1. Client requests IDE route.
2. Edge forwards to IDE gateway.
3. IDE gateway validates token + workspace binding.
4. Gateway resolves workspace -> internal runtime endpoint.
5. Gateway proxies HTTP/WebSocket to runtime.
6. Response returns through gateway to client.

---

## 3.2 Preview route pattern

Canonical preview path:
- `https://ide.<domain>/w/{workspaceId}/preview/{port}/...`
or
- `https://preview.<domain>/w/{workspaceId}/{port}/...`

Preview requests must pass same workspace identity and policy checks as IDE routes.

---

## 4) Route Resolution and Mapping

## 4.1 Mapping source

Route binder/orchestrator writes active mapping:
- `workspace_id -> runtime_endpoint`
- status metadata (`READY`, version, last heartbeat)
- optional region/zone info

## 4.2 Mapping consistency requirements

1. Mapping updates must be atomic per workspace.
2. Stale mappings must expire via TTL and heartbeat checks.
3. Route lookup cache must respect short freshness windows.
4. On runtime restart, mapping must be re-asserted before accepting traffic.

---

## 5) Gateway Responsibilities

1. Validate short-lived IDE token.
2. Enforce path-to-workspace claim binding.
3. Enforce org/tenant context constraints.
4. Strip untrusted inbound headers.
5. Inject trusted identity and correlation headers.
6. Proxy websocket and long-lived connections safely.
7. Emit structured access/security logs.
8. Apply rate limits and abuse protections.

---

## 6) Header and Identity Propagation Rules

## 6.1 Trusted outbound headers (gateway -> runtime)

- `x-request-id`
- `x-user-id`
- `x-org-id`
- `x-project-id` (if applicable)
- `x-workspace-id`
- `x-session-id` (optional)
- trace headers (`traceparent`, etc.)

## 6.2 Prohibited behavior

- Never forward client-supplied identity headers unvalidated.
- Never expose internal endpoint addresses in client-visible redirects/errors.

---

## 7) TLS and Certificate Strategy

1. TLS termination at edge (mandatory).
2. Internal mTLS between gateway and runtime services (recommended/required for higher compliance tiers).
3. Automated certificate rotation.
4. HSTS enabled for public domains.
5. Strict TLS versions/ciphers as per security baseline.

---

## 8) WebSocket Support Requirements

1. Gateway must support websocket upgrades reliably.
2. Idle timeout settings tuned for IDE usage patterns.
3. Session keepalive and reconnect strategy defined for transient network drops.
4. Connection limits per workspace/user enforced to prevent abuse.

---

## 9) Network Segmentation and Policy

## 9.1 Segmentation model

- Control plane namespace/network segment
- Runtime namespace/network segment
- Data services private segment
- Observability/private ops segment

## 9.2 Policy principles

1. Deny-by-default east-west traffic.
2. Explicit allow rules for required service communications only.
3. Runtime egress restricted by policy (allowlist model preferred).
4. No direct runtime -> sensitive data plane access unless explicitly needed.

---

## 10) Multi-Region and Placement (Optional Phase)

If multi-region enabled:
1. Route users to nearest/control-plane-approved region.
2. Keep workspace runtime and storage locality aligned.
3. Avoid cross-region data path unless policy requires.
4. Propagate region metadata in route mapping and logs.

---

## 11) High Availability Requirements

1. Edge and gateway deployed in HA mode (multiple replicas/zones).
2. Route mapping store highly available.
3. Orchestrator reconciliation can recover route state after component restarts.
4. Graceful draining on gateway rollout to avoid websocket disruption.

---

## 12) Failure Scenarios and Mitigation

## 12.1 Stale route mapping
- Symptom: 502/timeout on IDE connect.
- Mitigation: TTL + heartbeat validation + automatic re-resolve.

## 12.2 Gateway instance failure
- Symptom: dropped sessions/connections.
- Mitigation: HA replicas + client reconnect + rolling updates with drain.

## 12.3 Token validation outage/dependency issue
- Symptom: false denies or blocked connects.
- Mitigation: local key cache, controlled fail-closed policy, monitored dependency health.

## 12.4 Runtime endpoint not ready
- Symptom: connect loop.
- Mitigation: readiness-gated route activation + user-facing startup state.

---

## 13) Security Controls

1. Enforce strict route binding:
   - token workspace claim must match path workspace id.
2. Anti-replay:
   - short TTL + jti checks at gateway.
3. Request size/rate limits:
   - protect against abuse and DoS patterns.
4. Optional WAF rules for known attack signatures.
5. Sensitive headers and cookies sanitized.
6. Detailed deny reason codes in logs (not exposed to end users).

---

## 14) Observability and Monitoring

## 14.1 Access metrics

- IDE connect attempts/success/failure
- preview connect attempts/success/failure
- websocket upgrade success rate
- p50/p95 latency per route type
- 4xx/5xx split by reason class

## 14.2 Security metrics

- token validation failures by reason
- replay detection events
- cross-workspace mismatch denies
- abnormal connection bursts

## 14.3 Tracing/logging

- request-level tracing from edge -> gateway -> runtime
- correlation with orchestrator events via `workspace_id` + `request_id`

---

## 15) Capacity and Scaling Model

1. Horizontal gateway scaling based on:
   - concurrent websockets
   - request throughput
   - CPU/memory thresholds
2. Runtime scaling per active workspace count.
3. Pre-warm capacity strategy optional for low-latency starts.
4. Define hard caps and queueing policy for launch spikes.

---

## 16) Implementation Checklist

- [ ] Define canonical IDE/preview route schema
- [ ] Implement gateway token + workspace binding middleware
- [ ] Implement route mapping store + TTL semantics
- [ ] Implement websocket proxy support and timeout tuning
- [ ] Add secure header forwarding and sanitization rules
- [ ] Add HA deployment and graceful rollout strategy
- [ ] Add network policies for control/runtime/data segmentation
- [ ] Add routing and security dashboards/alerts

---

## 17) Acceptance Criteria

1. No public direct access path exists to runtime endpoints.
2. IDE and preview routes require valid scoped token and binding checks.
3. Websocket sessions are stable under expected load.
4. Route drift is automatically detected and reconciled.
5. Security/audit logs provide complete access decision trace.

---

## 18) Dependencies

- `04-code-server-integration-spec.md`
- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `18-observability-slos-and-alerting.md`

---

## 19) Next Document

Proceed to:
`08-workspace-storage-filesystem-and-snapshots.md`