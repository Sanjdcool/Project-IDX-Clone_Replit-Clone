# 01 — Hybrid Architecture Decision Record (IDX Control Plane + code-server Runtime)

## Status
**Proposed → Accepted (target at architecture review sign-off)**

## Date
2026-04-16

## Decision Owners
- Product Engineering Lead
- Platform/Infra Lead
- Security Lead
- Application Architect

---

## 1) Decision Summary

We will build the product as a **hybrid platform architecture**:

- `Project-IDX-Clone_Replit-Clone` becomes the **control plane + product experience**.
- `code-server_IDX-project` becomes the **IDE runtime service layer** for workspace editing.

We will **not** merge both repositories into one monolithic codebase at this stage.  
Integration will be contract-driven (auth/session, workspace lifecycle, proxy routing, telemetry).

---

## 2) Context

The current planning and design work in V1 focused primarily on IDX-side capabilities.  
Now the product scope requires a full developer platform experience comparable in workflow to modern cloud IDE products:

- launch workspace,
- open browser IDE,
- generate/edit code with AI assistance,
- run/preview applications,
- manage project lifecycle safely at team scale.

A runtime IDE engine is mandatory. `code-server` provides the fastest and most reliable path to production-grade browser editing while the IDX app provides product orchestration and AI workflow UX.

---

## 3) Architecture Decision

## 3.1 Control Plane (IDX repo responsibility)

The IDX product repo owns:

1. User/org/project/workspace data model
2. Identity, access control, plan/quota enforcement
3. Workspace lifecycle API (create/start/stop/delete/snapshot)
4. AI orchestration layer and tool policy
5. Runtime command broker and job/event timeline
6. Billing/metering, usage analytics
7. Web product UX shell and dashboards

## 3.2 Runtime Plane (code-server repo responsibility)

The code-server runtime repo owns:

1. Browser IDE server process
2. Editor extension/runtime compatibility
3. File editing protocol and terminal UI
4. IDE boot lifecycle hooks
5. Workspace container entrypoint integration points
6. Runtime health/readiness signaling

## 3.3 Integration Layer (explicit contracts)

Both planes are integrated via:

- Signed short-lived workspace access tokens
- Secure reverse proxy routes to per-workspace IDE endpoints
- Workspace metadata/env contract
- Structured event telemetry and correlation IDs
- Version compatibility matrix and upgrade policy

---

## 4) Why this decision

## Benefits

1. **Separation of concerns**
   - Product logic evolves independently from IDE internals.

2. **Faster product delivery**
   - Team builds features instead of rebuilding an editor stack.

3. **Operational control**
   - Runtime can be scaled independently from control plane APIs.

4. **Upgrade strategy**
   - code-server updates can be tracked and merged with controlled patch surface.

5. **Security boundary clarity**
   - Easier to reason about control-plane trust vs runtime sandbox trust.

## Tradeoffs

1. Additional integration complexity (auth proxy, token exchange, routing).
2. Requires disciplined contract/version management.
3. Some duplicated operational overhead across repos/pipelines.

---

## 5) Alternatives Considered

## Alternative A — Full monorepo merge immediately
**Rejected (for now).**  
High coupling and migration risk; slows near-term execution.

## Alternative B — Build custom editor from scratch
**Rejected.**  
Time-to-market and maintenance burden too high.

## Alternative C — Keep IDX-only architecture without embedded IDE runtime
**Rejected.**  
Cannot deliver complete developer platform workflow expectations.

---

## 6) Non-Negotiable Constraints

1. **Per-workspace isolation** must be enforceable at runtime.
2. **Short-lived signed tokens only** for IDE access; no long-lived shared credentials.
3. **Server-side authorization checks** on all workspace actions.
4. **Correlated audit logs** across control plane and runtime.
5. **Minimal patch policy** in code-server fork to reduce drift risk.

---

## 7) Integration Boundaries (authoritative)

1. IDX control plane must never directly trust client-side workspace identity claims.
2. code-server runtime must not own business policy decisions (plans, quotas, role policy).
3. Workspace lifecycle source-of-truth remains in IDX control plane DB.
4. Proxy layer enforces tenant/workspace route binding and token checks.
5. All privileged actions (snapshot, delete, publish/deploy, secret injection) require control-plane authorization.

---

## 8) High-Level Component Topology

1. **Web App/API (IDX)**  
   ↔ AuthN/AuthZ, Projects, Workspaces, AI, Usage
2. **Workspace Manager (IDX service)**  
   ↔ Scheduler/orchestrator, container provisioning
3. **Workspace Runtime**  
   - code-server container
   - app runtime container/process
4. **Edge/Proxy**  
   ↔ route binding, TLS, token validation, websocket support
5. **Data Plane**
   - Postgres (metadata)
   - Redis (queues/state)
   - Object storage (snapshots/artifacts/log bundles)
6. **Observability**
   - logs, metrics, traces, alerting

---

## 9) Security Impact

Positive:
- Clear trust boundaries and policy enforcement points
- Better auditability and controlled token exchange

Risks:
- Token forwarding/proxy misconfiguration
- Cross-workspace routing leakage if mapping logic is flawed
- Runtime egress abuse without strict policy

Mitigation:
- defense-in-depth checks (gateway + service + runtime)
- automated policy tests in CI/CD
- continuous security telemetry and anomaly alerting

---

## 10) Operational Impact

1. Separate CI/CD pipelines needed for control-plane and runtime.
2. Version compatibility checks required before rollout.
3. Staged rollout strategy (dev → staging → beta) needed for integration changes.
4. Incident handling playbooks must include cross-service troubleshooting.

---

## 11) Delivery Impact (90-day framing)

- **Weeks 1–3:** contracts, auth bridge, lifecycle API baseline
- **Weeks 4–6:** embed IDE + workspace run/preview loop + AI file ops
- **Weeks 7–9:** org/team controls, Git workflows, quotas/metering
- **Weeks 10–12:** hardening, scale tests, beta launch gates

---

## 12) Acceptance Criteria for this ADR

This decision is accepted when:

1. Architecture review approves repo boundary model.
2. Integration contracts are documented and versioned.
3. Security signs off on token + proxy model.
4. Platform team signs off on runtime patch/upgrade policy.
5. Delivery roadmap aligns with this topology and ownership split.

---

## 13) Follow-up Documents (Required)

- `02-system-context-and-service-boundaries.md`
- `03-repo-strategy-and-ownership-model.md`
- `04-code-server-integration-spec.md`
- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`

---

## 14) Open Questions

1. Single container vs sidecar model for runtime preview services?
2. Workspace warm pool strategy needed for launch latency targets?
3. Snapshot granularity (filesystem-only vs full environment state)?
4. Minimum extension set allowed in runtime for initial beta?
5. Multi-region support needed before GA or post-GA?

Track and resolve in:
`35-open-decisions-and-architecture-rfcs.md`