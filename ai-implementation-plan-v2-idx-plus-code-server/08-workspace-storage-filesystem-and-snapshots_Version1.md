# 08 — Workspace Storage, Filesystem, and Snapshots

## Status
Draft (target: platform + infra + security sign-off)

## Date
2026-04-16

## Purpose

Define storage architecture for workspace code/data persistence, filesystem isolation, snapshotting, restore workflows, and retention controls for the integrated IDX + code-server product.

---

## 1) Design Goals

1. Durable workspace persistence across start/stop cycles.
2. Strict per-workspace filesystem isolation.
3. Fast, reliable snapshot and restore workflows.
4. Cost-aware tiering and lifecycle retention.
5. Auditability and recovery readiness for production operations.

---

## 2) Storage Planes

## 2.1 Active Workspace Filesystem Plane
- Backing persistent volume per workspace (recommended default).
- Mounted into runtime at deterministic path (e.g., `/workspace`).

## 2.2 Snapshot/Artifact Plane
- Object storage for snapshot bundles, artifacts, logs, and exports.
- Snapshot metadata persisted in relational DB.

## 2.3 Metadata Plane
- Postgres (or equivalent) as source of truth for:
  - workspace storage profile
  - snapshot catalog
  - retention policy mappings
  - restore job states

---

## 3) Workspace Filesystem Model

## 3.1 Mount Contract

At runtime boot, orchestrator ensures:
- workspace volume attached,
- mount path present (`WORKSPACE_ROOT`),
- UID/GID permissions consistent with runtime user model,
- ownership and access policy enforced before IDE ready.

## 3.2 Directory layout (recommended baseline)

- `/workspace/<project-root>` — user source code
- `/workspace/.idx-meta` — platform metadata (restricted)
- `/workspace/.cache` — ephemeral/rebuildable cache (policy-dependent)
- `/workspace/.snap-hooks` — optional pre/post snapshot scripts (controlled)

---

## 4) Isolation and Access Controls

1. One volume per workspace by default (strong isolation).
2. No cross-workspace shared writable mount.
3. Runtime identity cannot mount arbitrary other workspace volumes.
4. File-level permissions set to least privilege.
5. Internal service access to workspace contents requires explicit scoped authorization.

---

## 5) Data Classes and Persistence Policy

| Data Class | Persistence | Location | Notes |
|---|---|---|---|
| Source code/project files | Durable | Workspace volume | Core data |
| IDE ephemeral caches | Best-effort | Local ephemeral / cache volume | Can be rebuilt |
| Build artifacts (optional) | Policy-based | Artifact store or workspace | Depends on plan/profile |
| Logs/diagnostics bundles | Durable (short/medium retention) | Object storage | For support/incident use |
| Snapshot bundles | Durable | Object storage | Versioned + checksummed |

---

## 6) Snapshot Architecture

## 6.1 Snapshot types

1. **Filesystem snapshot** (required MVP)
   - capture workspace source + selected metadata
2. **Extended snapshot** (future)
   - includes richer runtime context/config if needed

## 6.2 Snapshot trigger paths

- user-initiated snapshot
- pre-stop snapshot (optional policy)
- scheduled snapshot (plan-dependent)
- pre-risk operations (optional guardrail)

---

## 7) Snapshot Lifecycle

1. Request accepted (`SNAPSHOTTING` state).
2. Filesystem consistency checkpoint initiated.
3. Snapshot package created (tar/manifest or storage-native snapshot model).
4. Bundle uploaded to object storage.
5. Integrity checksum + metadata recorded.
6. Snapshot marked `READY` or `FAILED` with reason.

---

## 8) Restore Lifecycle

1. User/admin requests restore target snapshot.
2. Orchestrator validates authorization + compatibility.
3. Workspace enters maintenance/restart flow.
4. Existing volume state archived or replaced per policy.
5. Snapshot extracted/applied.
6. Validation checks run (manifest/hash/permissions).
7. Workspace restarted and marked ready.

---

## 9) Snapshot Metadata Schema (conceptual)

Required fields:
- `snapshot_id`
- `workspace_id`
- `org_id`
- `project_id`
- `created_by`
- `created_at`
- `snapshot_type`
- `storage_uri`
- `checksum`
- `size_bytes`
- `status` (`PENDING|READY|FAILED|DELETED`)
- `retention_policy_id`
- `error_code` (nullable)
- `source_runtime_version`

---

## 10) Retention and Lifecycle Policies

## 10.1 Policy dimensions

- max snapshot count per workspace
- retention duration by plan tier
- immutable retention locks (enterprise/compliance option)
- auto-prune rules (oldest-first, non-pinned first)

## 10.2 Default posture (example)
- keep recent N snapshots,
- retain critical tagged snapshots longer,
- auto-expire untagged snapshots after policy window.

---

## 11) Cost Management Strategy

1. Storage tiering:
   - hot storage for recent snapshots
   - colder tier for older snapshots
2. Compression for snapshot bundles.
3. Deduplication strategy (future enhancement).
4. Usage metering integrated with billing/quota controls.
5. Snapshot size warnings and policy guardrails in UI.

---

## 12) Consistency and Integrity Controls

1. Hash/checksum generated at snapshot creation and verified on restore.
2. Manifest includes file listing + metadata.
3. Partial snapshot failures must be marked unusable.
4. Restore must fail closed on integrity mismatch.
5. Integrity audit job runs periodically for high-value snapshots (optional).

---

## 13) Security and Compliance Controls

1. Encrypt data at rest (volumes + object storage).
2. Encrypt data in transit for all snapshot transfers.
3. Access to snapshot objects is service-scoped and short-lived.
4. Snapshot access operations are audit logged.
5. Optional secret scanning before snapshot export (plan-dependent).
6. Secure deletion pathways for regulatory deletion requests.

---

## 14) Workspace Deletion and Data Disposal

1. Soft-delete window optional by plan/policy.
2. Hard-delete includes:
   - volume teardown,
   - object snapshot cleanup (unless retention lock),
   - metadata tombstone and audit record.
3. Deletion operations require elevated authorization and confirmation flows.

---

## 15) Performance Targets (initial)

1. Workspace attach/mount success >= target SLO.
2. Snapshot completion latency:
   - p50/p95 by size band tracked.
3. Restore success rate >= target SLO.
4. Data integrity failure rate near-zero with immediate alerting.

(Exact SLO values finalized in observability/performance docs.)

---

## 16) Failure Modes and Recovery

## Common failures
1. Volume attach timeout
2. Snapshot upload failure
3. Corrupted/incomplete snapshot manifest
4. Restore extraction failure
5. Object store transient outage

## Recovery controls
- bounded retries with exponential backoff,
- resumable upload where supported,
- failed snapshot quarantined (not restorable),
- automated operator alerts and runbook links.

---

## 17) Operational Tooling Requirements

1. Snapshot catalog UI with filters/status and restore actions.
2. Storage usage dashboard by org/project/workspace.
3. Operator tools:
   - force retry snapshot job
   - validate snapshot integrity
   - recover failed restore safely
4. Automated policy compliance job (retention/pruning audits).

---

## 18) Testing Strategy

1. Unit tests:
   - metadata state transitions
   - retention pruning logic
2. Integration tests:
   - snapshot create/restore lifecycle
   - mount/permission correctness
3. Chaos tests:
   - object storage interruptions
   - partial upload failures
4. Security tests:
   - unauthorized snapshot access attempts
   - cross-workspace restore denial checks

---

## 19) Implementation Checklist

- [ ] Define storage profiles (workspace volume classes)
- [ ] Implement snapshot job pipeline + metadata schema
- [ ] Implement restore workflow with safety checkpoints
- [ ] Add retention policy engine and pruning jobs
- [ ] Add checksum/manifest integrity validation
- [ ] Add encrypted storage and secure access policies
- [ ] Add storage usage metering hooks
- [ ] Add snapshot/restore dashboards and alerts

---

## 20) Acceptance Criteria

1. Workspace files persist reliably across lifecycle transitions.
2. Snapshot and restore are user-accessible, auditable, and policy-controlled.
3. Snapshot integrity is verified automatically.
4. No cross-workspace data exposure is possible via storage workflows.
5. Retention and cost controls prevent unbounded storage growth.

---

## 21) Dependencies

- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `16-audit-logging-policy-and-governance.md`
- `29-pricing-metering-and-quota-enforcement.md`

---

## 22) Next Document

Proceed to:
`09-runtime-execution-preview-and-port-management.md`