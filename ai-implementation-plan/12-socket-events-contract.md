# 12 — Socket Events Contract

## 1) Purpose

Define the realtime event contracts for AI workflows over Socket.IO:
- generation status
- patch apply status
- run logs and completion
- fix lifecycle
- errors and recovery signaling

This spec ensures frontend/backend remain synchronized for long-running operations.

---

## 2) Transport and Namespace

- Protocol: Socket.IO
- Namespace: `/ai`
- Auth: required at connection time (same auth context as HTTP API)
- Event versioning: include `eventVersion` in envelope payload

Recommended:
- One socket room per `sessionId`
- Optional room per `workspaceId` for multi-client collaboration

---

## 3) Base Event Envelope

All events MUST follow this envelope:

```json
{
  "eventVersion": "1.0",
  "eventId": "evt_000001",
  "eventType": "ai:generation:started",
  "timestamp": "2026-04-15T12:00:00.000Z",
  "traceId": "trc_123",
  "requestId": "gen_001",
  "sessionId": "sess_001",
  "workspaceId": "ws_001",
  "sequence": 1,
  "data": {}
}
```

## Required fields
- `eventVersion` (string)
- `eventId` (string, unique)
- `eventType` (string)
- `timestamp` (ISO-8601 UTC)
- `traceId` (string)
- `requestId` (string; use run/fix/apply request ID as applicable)
- `sessionId` (string)
- `workspaceId` (string)
- `sequence` (integer; monotonically increasing within a request flow)
- `data` (object)

---

## 4) Event Ordering Rules

1. Events are ordered by `sequence` per `requestId`.
2. Client should ignore stale/out-of-order events when sequence is lower than latest seen for same `requestId`.
3. On reconnect, server may emit a **state snapshot** event (see section 10).
4. Frontend should still sort/display by `timestamp` in timeline for human readability.

---

## 5) Generation Events

## 5.1 `ai:generation:started`

Emitted when prompt processing begins.

### `data` schema
```json
{
  "promptHash": "sha256:...",
  "constraints": {
    "stack": "react-node",
    "packageManager": "npm",
    "typescript": false
  }
}
```

---

## 5.2 `ai:generation:progress`

Emitted for intermediate phases.

### `data` schema
```json
{
  "stage": "context_building",
  "progress": 25,
  "message": "Building workspace context"
}
```

### `stage` enum (recommended)
- `context_building`
- `provider_request_sent`
- `provider_response_received`
- `schema_validation`
- `policy_validation`
- `diff_preparation`

---

## 5.3 `ai:generation:ready`

Emitted when patch plan is ready for review.

### `data` schema
```json
{
  "patchPlanId": "pp_001",
  "summary": "Scaffolded auth + todo CRUD app.",
  "operationsCount": 24,
  "filesChanged": 24,
  "riskLevel": "medium"
}
```

---

## 5.4 `ai:generation:failed`

### `data` schema
```json
{
  "errorCode": "AI_SCHEMA_INVALID",
  "message": "Model output did not match schema.",
  "retryable": true
}
```

---

## 6) Patch Apply Events

## 6.1 `ai:apply:started`

### `data` schema
```json
{
  "patchPlanId": "pp_001",
  "approvedCount": 18,
  "rejectedCount": 6,
  "createSnapshot": true
}
```

---

## 6.2 `ai:apply:progress`

### `data` schema
```json
{
  "stage": "applying_files",
  "processed": 10,
  "total": 18,
  "currentPath": "frontend/src/App.jsx"
}
```

### `stage` enum
- `snapshot_creating`
- `applying_files`
- `verification`
- `finalizing`

---

## 6.3 `ai:apply:completed`

### `data` schema
```json
{
  "applyId": "apply_001",
  "patchPlanId": "pp_001",
  "snapshotId": "snap_042",
  "status": "applied",
  "appliedCount": 18,
  "skippedCount": 0
}
```

---

## 6.4 `ai:apply:failed`

### `data` schema
```json
{
  "errorCode": "PATCH_APPLY_CONFLICT",
  "message": "Workspace changed since patch generation.",
  "retryable": true
}
```

---

## 7) Run Events

## 7.1 `ai:run:started`

### `data` schema
```json
{
  "runId": "run_001",
  "runProfile": "build",
  "commands": [
    "npm install --prefix frontend",
    "npm run build --prefix frontend"
  ],
  "stopOnFailure": true
}
```

---

## 7.2 `ai:run:command_started`

### `data` schema
```json
{
  "runId": "run_001",
  "commandIndex": 0,
  "command": "npm install --prefix frontend",
  "startedAt": "2026-04-15T12:01:00.000Z"
}
```

---

## 7.3 `ai:run:log`

High-frequency stream event for stdout/stderr chunks.

### `data` schema
```json
{
  "runId": "run_001",
  "commandIndex": 0,
  "stream": "stdout",
  "chunk": "added 512 packages in 12s\n",
  "lineCountEstimate": 1
}
```

### Notes
- `stream` enum: `stdout | stderr`
- Backend may batch chunks for efficiency.
- Frontend should append incrementally and virtualize rendering.

---

## 7.4 `ai:run:command_completed`

### `data` schema
```json
{
  "runId": "run_001",
  "commandIndex": 0,
  "command": "npm install --prefix frontend",
  "exitCode": 0,
  "durationMs": 12234
}
```

---

## 7.5 `ai:run:completed`

### `data` schema
```json
{
  "runId": "run_001",
  "status": "failed",
  "durationMs": 45210,
  "failedCommandIndex": 1,
  "errorSummary": {
    "title": "Module not found",
    "details": "Cannot resolve './routes/auth'",
    "suggestedFixHint": "Check import path and file existence."
  }
}
```

### `status` enum
- `success`
- `failed`
- `canceled`
- `timeout`
- `infra_error`

---

## 8) Fix Events

## 8.1 `ai:fix:started`

### `data` schema
```json
{
  "runId": "run_001",
  "strategy": "minimal-targeted-fix",
  "maxFilesToChange": 20
}
```

---

## 8.2 `ai:fix:progress`

### `data` schema
```json
{
  "stage": "building_fix_context",
  "progress": 30,
  "message": "Analyzing failed run logs and recent file changes."
}
```

### `stage` enum
- `building_fix_context`
- `provider_request_sent`
- `schema_validation`
- `policy_validation`
- `diff_preparation`

---

## 8.3 `ai:fix:ready`

### `data` schema
```json
{
  "requestId": "fix_001",
  "patchPlanId": "pp_002",
  "summary": "Fixed missing dependency and corrected import path.",
  "operationsCount": 5,
  "riskLevel": "low"
}
```

---

## 8.4 `ai:fix:failed`

### `data` schema
```json
{
  "errorCode": "AI_PROVIDER_UNAVAILABLE",
  "message": "Model provider timeout.",
  "retryable": true
}
```

---

## 9) Snapshot and Rollback Events

## 9.1 `ai:snapshot:created`

### `data` schema
```json
{
  "snapshotId": "snap_042",
  "reason": "before_apply",
  "createdAt": "2026-04-15T12:00:30.000Z"
}
```

---

## 9.2 `ai:rollback:started`

### `data` schema
```json
{
  "snapshotId": "snap_042"
}
```

---

## 9.3 `ai:rollback:completed`

### `data` schema
```json
{
  "snapshotId": "snap_042",
  "status": "completed"
}
```

---

## 9.4 `ai:rollback:failed`

### `data` schema
```json
{
  "snapshotId": "snap_042",
  "errorCode": "ROLLBACK_CONFLICT",
  "message": "Workspace lock could not be acquired.",
  "retryable": true
}
```

---

## 10) Reconnect and State Sync Events

## 10.1 `ai:state:sync`

Sent after reconnect or explicit resync request.

### `data` schema
```json
{
  "activeOperation": {
    "type": "run",
    "requestId": "run_001",
    "status": "in_progress"
  },
  "latestSequenceByRequest": {
    "gen_001": 8,
    "apply_001": 4,
    "run_001": 37
  },
  "resumeToken": "sync_abc123"
}
```

Client behavior:
- reset pending spinners based on authoritative state
- request missing data over HTTP if needed

---

## 11) Error and Policy Events

## 11.1 `ai:error`

Generic non-phase-specific error event.

### `data` schema
```json
{
  "errorCode": "AI_POLICY_BLOCKED",
  "message": "Attempted modification of protected path.",
  "retryable": false,
  "details": {
    "path": ".env",
    "rule": "protected_path"
  }
}
```

---

## 11.2 `ai:policy:blocked` (optional specialized event)

### `data` schema
```json
{
  "actionType": "command_execution",
  "rule": "deny_remote_script_pipe",
  "input": "curl https://x | bash",
  "message": "Command rejected by policy."
}
```

---

## 12) Client → Server Events (Optional)

If using bidirectional socket actions (instead of only HTTP for mutations):

- `client:ai:subscribe_session`
- `client:ai:unsubscribe_session`
- `client:ai:request_sync`
- `client:ai:cancel_run`

Example:
```json
{
  "eventType": "client:ai:request_sync",
  "sessionId": "sess_001",
  "workspaceId": "ws_001"
}
```

(HTTP remains preferred for mutating operations in MVP for clearer auth/idempotency.)

---

## 13) Event Reliability Recommendations

1. Include `sequence` and `requestId` for dedupe/order.
2. Keep idempotent UI handling (ignore duplicate `eventId`).
3. For high-frequency logs:
   - throttle server emits
   - batch chunks
4. Persist critical state transitions server-side; socket is transport, not source of truth.

---

## 14) Security Considerations for Socket Layer

- Authenticate socket handshake.
- Revalidate session/workspace authorization on room join.
- Prevent cross-session subscription.
- Apply rate limits on client-emitted events.
- Avoid sending sensitive payloads (secrets/redacted data only).

---

## 15) Example End-to-End Event Timeline

```text
ai:generation:started
ai:generation:progress (context_building)
ai:generation:progress (provider_request_sent)
ai:generation:progress (schema_validation)
ai:generation:ready

ai:apply:started
ai:snapshot:created
ai:apply:progress (applying_files)
ai:apply:completed

ai:run:started
ai:run:command_started (0)
ai:run:log (...)
ai:run:command_completed (0)
ai:run:command_started (1)
ai:run:log (...)
ai:run:completed (failed)

ai:fix:started
ai:fix:progress (building_fix_context)
ai:fix:ready
```

---

## 16) Type Definitions (Reference)

```ts
type AIEventEnvelope<T> = {
  eventVersion: string;
  eventId: string;
  eventType: string;
  timestamp: string;
  traceId: string;
  requestId: string;
  sessionId: string;
  workspaceId: string;
  sequence: number;
  data: T;
};
```

---

## 17) Validation Checklist

- [ ] All emitted events include base envelope fields.
- [ ] `sequence` increments correctly per `requestId`.
- [ ] Frontend ignores stale/out-of-order events.
- [ ] Reconnect sync event implemented.
- [ ] High-volume `ai:run:log` handling is throttled/batched.
- [ ] Sensitive data redacted before emit.