# 02 — System Context and Service Boundaries

## Status
Draft (target: architecture + platform sign-off)

## Date
2026-04-16

## Purpose

Define the complete system context for the integrated product and establish strict service boundaries between:

- IDX control plane (`Project-IDX-Clone_Replit-Clone`)
- code-server runtime (`code-server_IDX-project`)
- supporting platform services (proxy, storage, queue, observability, billing, security)

This document is the authoritative boundary reference for engineering implementation and API ownership.

---

## 1) System Context (External + Internal Actors)

## 1.1 External Actors

1. **End User (Developer)**
   - Creates/open projects
   - Launches workspace + IDE
   - Uses AI assistant
   - Runs/previews/deploys apps

2. **Organization Admin**
   - Manages members, roles, quotas, policies
   - Views usage and audit logs

3. **Platform Operators (SRE/DevOps)**
   - Manage clusters, networking, scaling
   - Respond to incidents and alerts

4. **Security/Compliance Team**
   - Reviews audit trails, policy decisions, anomalies

5. **Third-party Providers**
   - LLM API provider
   - Git provider
   - Cloud object storage
   - Billing provider

---

## 1.2 Internal Service Domains

1. **Control Plane Domain** (IDX repo)
2. **Workspace Runtime Domain** (code-server + workspace process)
3. **Routing/Edge Domain** (ingress/proxy/token gate)
4. **Data Domain** (Postgres/Redis/Object store)
5. **Observability Domain** (logs/metrics/traces/alerts)
6. **Governance Domain** (policy/audit/license/usage enforcement)

---

## 2) High-Level Context Diagram (Textual)

1. User interacts with IDX Web App.
2. IDX API authenticates user and authorizes workspace action.
3. Workspace Manager provisions/starts workspace runtime.
4. Proxy issues route binding for workspace IDE + preview.
5. User opens IDE route; token validated at edge.
6. code-server serves editor and terminal over websocket/http.
7. AI requests flow from IDX AI Orchestrator to Workspace Tool Broker.
8. Tool Broker executes file/command ops in workspace sandbox.
9. Events and metrics emitted to observability stack.
10. Usage records persisted for quota/billing and analytics.

---

## 3) Core Boundary Model

## 3.1 Boundary A — Product/Control Plane

**Owned by IDX repo.**

### In scope
- Authentication/authorization
- Organizations/projects/workspaces metadata
- Policy engine (role/plan/quotas)
- Workspace lifecycle API
- AI orchestration, chat state, tool permissions
- Billing/metering
- Product UX and dashboards
- Audit decision logs

### Out of scope
- IDE internals rendering/editor process behavior
- Direct terminal execution without broker/policy
- Raw network ingress management outside approved proxy service

---

## 3.2 Boundary B — Runtime/IDE Plane

**Owned by code-server runtime service.**

### In scope
- IDE server process
- Terminal/editor interface
- Runtime health/readiness
- Workspace-local file and process access (within sandbox)

### Out of scope
- Business policy decisions (plans, org permissions)
- Tenant billing/quota authority
- Global user identity source-of-truth

---

## 3.3 Boundary C — Edge/Proxy Plane

**Shared platform ownership (Infra + Platform Backend).**

### In scope
- TLS termination
- route mapping (`workspaceId -> runtime endpoint`)
- token validation at entry
- websocket support
- request header sanitation and forwarding policy

### Out of scope
- deciding business permissions independent of control plane
- storing durable business metadata

---

## 3.4 Boundary D — Data Plane

### In scope
- Postgres: metadata + relational source-of-truth
- Redis: transient queue/cache/locks
- Object storage: snapshots/artifacts/log bundles

### Out of scope
- policy decision logic
- runtime execution orchestration

---

## 4) Service Catalog and Ownership

| Service | Primary Owner | Secondary Owner | Responsibility |
|---|---|---|---|
| Web Frontend | Product FE Team | Platform FE | UX shell, project/workspace flows |
| API Gateway | Platform Backend | Security | Auth, request validation, routing to internal services |
| Identity Service | Platform Backend | Security | Session/JWT, user/org context |
| Policy Engine | Platform Backend | Security/Product Ops | Role/plan/quota decisions |
| Workspace Manager | Platform Backend | Infra | Create/start/stop/delete/snapshot lifecycle |
| Runtime Provisioner | Infra/Platform | Backend | Container/pod scheduling and runtime wiring |
| IDE Runtime Service | Runtime Team | Platform Backend | code-server lifecycle and health |
| Tool Broker | AI/Platform Backend | Security | controlled file/command execution |
| AI Orchestrator | AI Team | Product Backend | prompt pipeline, tool sequencing |
| Preview Gateway | Infra | Platform Backend | app preview routing and access policy |
| Metering/Billing Service | Product Backend | Finance Ops | usage aggregation, quota billing |
| Audit Service | Security/Platform | Compliance | immutable action/event trail |
| Observability Stack | SRE | All teams | logs/metrics/traces and alerts |

---

## 5) Canonical Data Ownership Rules

1. User/org/project/workspace metadata → **IDX control plane DB**
2. Workspace route bindings → **Proxy mapping store (ephemeral + validated)**
3. Runtime health state → **runtime service + metrics store**
4. Policy decisions and deny reasons → **control plane policy logs**
5. AI conversation metadata and tool history → **control plane**
6. File contents/code → **workspace filesystem/object snapshot**
7. Billing usage aggregates → **metering store (from control plane events)**

---

## 6) Communication Contracts (Service-to-Service)

## Required Protocol Principles

1. Every internal request includes:
   - `x-request-id`
   - `x-workspace-id` (when applicable)
   - `x-org-id` (when applicable)
   - `x-user-id` (subject, signed context)

2. All privileged service actions require:
   - service identity authentication (mTLS or signed service token)
   - explicit authorization scope check

3. Async operations must emit:
   - started/progress/completed/failed events
   - deterministic error codes

---

## 7) Boundary Guardrails (Hard Rules)

1. Runtime service cannot directly mutate org/project policy tables.
2. Proxy cannot grant access without validated workspace token.
3. AI tool broker cannot execute commands without policy check.
4. Control plane cannot assume runtime readiness without health confirmation.
5. No cross-workspace filesystem access through shared mounts.
6. No direct user traffic to internal runtime endpoints (must traverse edge controls).

---

## 8) Failure Domains and Isolation

## Failure Domain 1 — Control Plane API degradation
- Impact: new workspace ops blocked; running IDE sessions may continue.
- Mitigation: degraded mode, cached route validity window, retry policies.

## Failure Domain 2 — Runtime node/pod failure
- Impact: active workspace interruption.
- Mitigation: restart/resume policy, checkpoint restoration, user-facing recovery messaging.

## Failure Domain 3 — Proxy/routing failure
- Impact: IDE/preview unreachable.
- Mitigation: HA ingress, route reconciliation loop, synthetic probes.

## Failure Domain 4 — Redis/queue instability
- Impact: delayed async jobs/events.
- Mitigation: retry DLQ, idempotent handlers, backpressure controls.

## Failure Domain 5 — Object storage latency/outage
- Impact: snapshot/artifact operations degraded.
- Mitigation: queued retries + partial functionality fallback.

---

## 9) Security Boundaries by Plane

| Plane | Trust Level | Primary Threats | Controls |
|---|---|---|---|
| Control Plane | High | auth bypass, privilege escalation | RBAC/ABAC, signed tokens, audit logs |
| Runtime Plane | Medium | sandbox escape, command abuse | container isolation, seccomp, egress policy |
| Edge Plane | High | route hijack, token replay | short TTL tokens, strict host/path policy, TLS |
| Data Plane | High | exfiltration, corruption | encryption at rest/in transit, backups, least privilege |
| AI Tooling Plane | Medium-High | unsafe code execution | policy gates, allowlisted tools, bounded execution |

---

## 10) SLA/SLO Boundary Expectations (Initial)

1. Control plane API availability: target 99.9%
2. IDE route connection success: target 99.5%
3. Workspace launch (cold start) p95 target: defined in performance doc
4. AI tool execution success (non-user-error) target: defined in AI ops doc
5. Audit event delivery completeness: 100%

(Exact values finalized in `18-observability-slos-and-alerting.md` and `19-performance-capacity-and-autoscaling.md`.)

---

## 11) Implementation Handshake Checklist

Before development begins per team:

- [ ] Service ownership accepted
- [ ] API contracts versioned
- [ ] Required headers/context schema finalized
- [ ] Auth token exchange flow approved
- [ ] Error code taxonomy standardized
- [ ] Observability fields standardized
- [ ] Runbooks linked for each service owner

---

## 12) Change Control for Boundaries

Any boundary change requires:
1. ADR update (`01-hybrid-architecture-decision-record.md`)
2. Affected contract document update
3. Security review if auth/routing/runtime privileges are impacted
4. Versioned rollout plan with backward compatibility window

---

## 13) Next Documents

- `03-repo-strategy-and-ownership-model.md`
- `04-code-server-integration-spec.md`
- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`