# 06 — Workspace Orchestrator Spec

## Status
Draft (target: platform + infra sign-off)

## Date
2026-04-16

## Purpose

Define the orchestrator responsible for workspace lifecycle management in the integrated product:

- provisioning and scheduling workspace runtimes,
- managing state transitions,
- handling retries/failures/recovery,
- enforcing policy/quota limits,
- exposing deterministic APIs/events to control plane and UI.

---

## 1) Scope

## In scope
1. Workspace create/start/stop/restart/delete/snapshot orchestration
2. Runtime allocation and readiness checks
3. Persistent volume attachment/detachment
4. Route registration handoff to IDE/preview gateway
5. Policy-aware admission control (plan/quota/limits)
6. Lifecycle event publishing and status reconciliation

## Out of scope
1. IDE editor internals (code-server process behavior)
2. AI prompt/orchestration logic
3. Billing price model logic (consumes usage, does not define pricing policy)

---

## 2) Responsibilities

1. Be the **single orchestrator authority** for runtime lifecycle.
2. Maintain canonical lifecycle state machine.
3. Guarantee idempotent operations for repeated requests.
4. Reconcile desired vs actual workspace state continuously.
5. Provide observability and audit-ready event stream.

---

## 3) Architecture Overview

## 3.1 Core components

1. **Workspace API Handler**
   - receives lifecycle commands from control plane.
2. **Admission Controller**
   - validates entitlement, quotas, and safety policies.
3. **Scheduler/Provisioner Adapter**
   - translates desired state into runtime platform actions (K8s/container runtime).
4. **State Store**
   - persistent workspace desired/actual state records.
5. **Reconciler Loop**
   - periodic + event-driven correction engine.
6. **Event Publisher**
   - emits lifecycle events to UI/analytics/audit pipeline.
7. **Route Binder**
   - registers/deregisters IDE + preview route mappings.

---

## 4) Canonical State Machine

## 4.1 States

1. `NEW`
2. `ADMISSION_PENDING`
3. `PROVISIONING`
4. `STARTING`
5. `READY`
6. `DEGRADED`
7. `STOPPING`
8. `STOPPED`
9. `SNAPSHOTTING`
10. `DELETING`
11. `FAILED`

## 4.2 Transition rules (high level)

- `NEW -> ADMISSION_PENDING` on create request
- `ADMISSION_PENDING -> PROVISIONING` if policy passes
- `PROVISIONING -> STARTING` when runtime resources allocated
- `STARTING -> READY` when readiness checks pass
- `READY -> STOPPING` on stop request / policy timeout
- `STOPPING -> STOPPED` after clean termination
- Any active state -> `FAILED` on unrecoverable error
- `READY/STOPPED -> SNAPSHOTTING` on snapshot request
- `STOPPED/FAILED -> DELETING` on delete request

Control plane UI must only display states from this canonical set.

---

## 5) API Contract (Orchestrator-facing)

## 5.1 Required commands

1. `CreateWorkspace`
2. `StartWorkspace`
3. `StopWorkspace`
4. `RestartWorkspace`
5. `DeleteWorkspace`
6. `SnapshotWorkspace`
7. `GetWorkspaceStatus`
8. `ListWorkspaceEvents`

## 5.2 Command metadata requirements

Each command includes:
- `request_id`
- `actor_user_id` (or service principal)
- `org_id`
- `project_id`
- `workspace_id`
- optional `reason_code` / `source` (ui/api/system)

---

## 6) Admission and Policy Checks

Before `PROVISIONING`, orchestrator must enforce:

1. Org plan entitlement check
2. Workspace count quotas
3. CPU/memory/storage budget availability
4. Region/placement policy constraints
5. Security/compliance constraints (if org policy requires)
6. Abuse/rate-limit protections for churn operations

If denied, state remains stable and return explicit policy error code.

---

## 7) Runtime Provisioning Model

## 7.1 Runtime unit

Preferred runtime unit:
- one isolated workspace runtime per workspace ID.

Contains at minimum:
1. code-server process/service
2. workspace filesystem mount
3. optional app runtime process for preview

## 7.2 Provisioning steps

1. Resolve template/compute profile
2. Allocate runtime resources
3. Attach persistent volume
4. Inject runtime env contract
5. Start runtime container/process
6. Wait readiness probe success
7. Register gateway routes
8. Mark `READY`

---

## 8) Storage and Mount Lifecycle

1. Persistent volume per workspace (default isolation).
2. Mount path must be deterministic (e.g., `/workspace`).
3. On stop:
   - flush safe writes,
   - detach/keep volume based on policy.
4. On delete:
   - optional retention window,
   - secure delete workflow as policy dictates.
5. Snapshot operations must be atomic from control-plane perspective.

---

## 9) Route Binding Lifecycle

Orchestrator coordinates with route binder:

1. On `STARTING -> READY`
   - bind IDE route `/w/{workspaceId}/ide`
   - bind preview route base
2. On `STOPPING/STOPPED/FAILED`
   - revoke route bindings
   - invalidate active short-lived connect tokens as needed

Route registration success is part of `READY` criteria.

---

## 10) Reconciler Design

## 10.1 Reconciliation triggers

1. periodic timer
2. lifecycle command arrival
3. runtime health event
4. route binding mismatch detection
5. storage attach/mount signal mismatch

## 10.2 Reconciliation actions

- restart stuck transitions beyond timeout
- repair missing route bindings for ready workspaces
- mark failed if repeated recovery threshold exceeded
- emit anomaly events for operator visibility

---

## 11) Timeout and Retry Policy

## 11.1 Timeouts (configurable)
- admission timeout
- provisioning timeout
- startup/readiness timeout
- stop timeout
- snapshot timeout
- delete timeout

## 11.2 Retry classes

1. **Transient infra errors** -> bounded retries with backoff
2. **Policy denials** -> no retry until condition changes
3. **Configuration errors** -> fail fast with actionable error
4. **Unknown runtime state** -> reconciliation + operator alert

All retries must be idempotent and event-logged.

---

## 12) Failure Modes and Recovery

## Common failure types

1. volume attach failure
2. image pull/start failure
3. readiness probe timeout
4. route binding failure
5. resource quota exhaustion
6. orchestrator crash/restart mid-transition

## Recovery strategy

- persist desired state before action execution
- transactional state transitions where possible
- resume unfinished operations on orchestrator restart
- emit explicit failure reasons to UI and audit stream
- provide operator “force reconcile” and “force stop” controls

---

## 13) Concurrency and Idempotency

1. Workspace-level operation lock required (`workspace_id` mutex/distributed lock).
2. Reject/queue conflicting commands during active transition.
3. Duplicate command with same idempotency key returns prior result.
4. At-least-once event delivery is acceptable if consumers are idempotent.

---

## 14) Event Model

## 14.1 Lifecycle events (required)

- `workspace.create.requested`
- `workspace.admission.approved|denied`
- `workspace.provisioning.started|failed`
- `workspace.starting.started|failed`
- `workspace.ready`
- `workspace.stopping.started|completed|failed`
- `workspace.snapshot.started|completed|failed`
- `workspace.deleting.started|completed|failed`
- `workspace.failed`
- `workspace.reconciled`

## 14.2 Event payload minimum fields

- `event_id`
- `timestamp`
- `workspace_id`
- `org_id`
- `project_id`
- `state_before`
- `state_after`
- `request_id`
- `actor`
- `error_code` (if applicable)

---

## 15) Security and Isolation Requirements

1. Orchestrator actions must be authorized by control plane policy.
2. No cross-workspace volume attachment.
3. Resource limits enforced per workspace profile.
4. Runtime namespace/network policy assigned at provision time.
5. Secrets scoped per workspace and short-lived where possible.

---

## 16) Metrics and SLO Inputs

Required orchestrator metrics:
1. workspace creation success rate
2. start success rate
3. start latency p50/p95/p99
4. failure rate by stage
5. reconcile actions count and outcome
6. restart loops per workspace
7. stuck state duration histogram

These feed SLO dashboards in `18-observability-slos-and-alerting.md`.

---

## 17) Operational Interfaces

## 17.1 Operator actions
- force stop
- force delete
- force reconcile
- clear stale route binding
- retry failed stage

## 17.2 Guardrails
- operator overrides require audit reason
- high-risk actions gated by elevated role

---

## 18) Testing Requirements

1. Unit tests: state transitions + policy checks
2. Contract tests: API and event schema
3. Integration tests: provision/start/ready route bind
4. Chaos tests: runtime crash, storage failure, network loss
5. Load tests: burst workspace starts and stop storms

---

## 19) Implementation Checklist

- [ ] Implement canonical state machine and transition validator
- [ ] Add workspace-level operation locking and idempotency keys
- [ ] Implement admission policy adapter
- [ ] Implement provisioner + storage + route binder adapters
- [ ] Implement reconciler with timeout recovery
- [ ] Emit structured lifecycle events
- [ ] Add metrics/tracing for each transition stage
- [ ] Implement operator control APIs with audit logging

---

## 20) Acceptance Criteria

1. Workspace lifecycle operations are deterministic and auditable.
2. Repeated API calls do not create duplicate runtimes.
3. `READY` is achieved only when runtime + route bindings are valid.
4. Failure states include actionable reason codes and recovery paths.
5. Reconciler can heal common drift conditions without manual intervention.

---

## 21) Dependencies

- `04-code-server-integration-spec.md`
- `05-identity-auth-sso-session-bridging.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `08-workspace-storage-filesystem-and-snapshots.md`
- `18-observability-slos-and-alerting.md`

---

## 22) Next Document

Proceed to:
`07-ide-routing-proxy-and-network-topology.md`