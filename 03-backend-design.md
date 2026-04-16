# 03 — Backend Design

## 1) Purpose

Define the backend implementation for AI-assisted app generation:
- prompt handling,
- structured patch creation,
- approval-aware file application,
- sandbox run/fix loop,
- safety and auditability.

This design assumes existing backend stack: **Node.js + Express + Socket.IO + Docker runtime integration**.

---

## 2) Backend Module Layout (Proposed)

```text
backend/src/
  ai/
    controller/
      ai.controller.js
      ai.run.controller.js
    service/
      ai-orchestrator.service.js
      ai-context.service.js
      ai-provider.service.js
      ai-repair.service.js
    schema/
      generate-request.schema.js
      patch-plan.schema.js
      apply-request.schema.js
      run-request.schema.js
    prompts/
      system.prompt.js
      generate.prompt.js
      fix.prompt.js
    policy/
      ai-policy.service.js
      command-policy.js
      path-policy.js
    mapper/
      ai-response.mapper.js
      diff.mapper.js
  workspace/
    workspace.service.js
    snapshot.service.js
    patch-apply.service.js
    tree.service.js
  runtime/
    sandbox.service.js
    run-log-stream.service.js
  session/
    ai-session.service.js
  audit/
    audit.service.js
  sockets/
    ai.socket.js
  routes/
    ai.routes.js
```

---

## 3) API Endpoints (MVP)

## 3.1 Generate Patch Plan

**POST** `/api/ai/generate`

### Request
```json
{
  "workspaceId": "ws_123",
  "sessionId": "sess_001",
  "prompt": "Create a React todo app with auth and dark theme.",
  "constraints": {
    "stack": "react-node",
    "packageManager": "npm",
    "typescript": false,
    "lockedFiles": ["package-lock.json"],
    "maxFilesToChange": 60
  }
}
```

### Response
```json
{
  "requestId": "gen_001",
  "patchPlanId": "pp_001",
  "summary": "Scaffolded frontend and backend auth flow with todo CRUD.",
  "operationsCount": 24,
  "riskLevel": "medium",
  "diffPreview": {
    "files": [
      {
        "path": "frontend/src/App.jsx",
        "changeType": "update",
        "additions": 120,
        "deletions": 14
      }
    ]
  }
}
```

---

## 3.2 Get Patch Plan Details

**GET** `/api/ai/patch/:patchPlanId`

Returns full operation list and unified diffs for review.

---

## 3.3 Apply Approved Patch

**POST** `/api/ai/patch/:patchPlanId/apply`

### Request
```json
{
  "workspaceId": "ws_123",
  "sessionId": "sess_001",
  "approvedPaths": [
    "frontend/src/App.jsx",
    "frontend/src/pages/Login.jsx",
    "backend/src/routes/auth.js"
  ],
  "rejectedPaths": [
    "frontend/package.json"
  ],
  "createSnapshot": true
}
```

### Response
```json
{
  "applyId": "apply_001",
  "snapshotId": "snap_0042",
  "appliedCount": 18,
  "skippedCount": 6,
  "status": "applied"
}
```

---

## 3.4 Run Commands

**POST** `/api/ai/run`

### Request
```json
{
  "workspaceId": "ws_123",
  "sessionId": "sess_001",
  "commands": [
    "npm install --prefix frontend",
    "npm run build --prefix frontend"
  ],
  "runProfile": "build"
}
```

### Response
```json
{
  "runId": "run_001",
  "status": "started"
}
```

Logs stream via Socket.IO.

---

## 3.5 Fix Failed Run with AI

**POST** `/api/ai/fix`

### Request
```json
{
  "workspaceId": "ws_123",
  "sessionId": "sess_001",
  "runId": "run_001",
  "strategy": "minimal-targeted-fix",
  "maxFilesToChange": 20
}
```

### Response
```json
{
  "requestId": "fix_001",
  "patchPlanId": "pp_002",
  "summary": "Adjusted import paths and missing dependency.",
  "operationsCount": 5
}
```

---

## 3.6 Rollback Snapshot

**POST** `/api/ai/snapshots/:snapshotId/rollback`

---

## 4) Socket.IO Event Contract (MVP)

Namespace suggestion: `/ai`

### Server → Client
- `ai:generation:started`
- `ai:generation:progress`
- `ai:generation:ready`
- `ai:apply:started`
- `ai:apply:completed`
- `ai:run:started`
- `ai:run:log`
- `ai:run:completed`
- `ai:fix:started`
- `ai:fix:ready`
- `ai:error`

### Example payload
```json
{
  "eventId": "evt_1009",
  "sessionId": "sess_001",
  "timestamp": "2026-04-15T13:00:00.000Z",
  "data": {}
}
```

---

## 5) Orchestration Pipeline

## 5.1 Generation Pipeline

1. Validate input schema.
2. Authorize workspace/session ownership.
3. Build AI context:
   - file tree summary,
   - relevant files,
   - prior chat,
   - user constraints.
4. Call provider with structured response requirement.
5. Validate model response against `patch-plan.schema`.
6. Enforce policy on returned operations.
7. Compute unified diffs.
8. Persist patch plan + audit entry.
9. Emit `ai:generation:ready`.

## 5.2 Apply Pipeline

1. Validate approved/rejected paths.
2. Re-check policy for approved ops.
3. Create snapshot.
4. Apply operations through patch service.
5. Verify filesystem state.
6. Persist apply result + audit.
7. Emit `ai:apply:completed`.

## 5.3 Run Pipeline

1. Validate command allowlist.
2. Start container (or reuse session container).
3. Execute commands sequentially.
4. Stream logs live.
5. Persist output and parsed diagnostics.
6. Emit completion event.

## 5.4 Fix Pipeline

1. Pull failing run logs and changed files.
2. Build targeted repair prompt context.
3. Request structured patch response.
4. Validate + policy-check.
5. Save patch for review/apply.

---

## 6) Data Schemas (Core)

## 6.1 Patch Operation Schema

```json
{
  "type": "object",
  "required": ["op", "path"],
  "properties": {
    "op": { "enum": ["create_file", "update_file", "delete_file"] },
    "path": { "type": "string", "minLength": 1 },
    "content": { "type": "string" },
    "reason": { "type": "string" }
  },
  "allOf": [
    {
      "if": { "properties": { "op": { "const": "create_file" } } },
      "then": { "required": ["content"] }
    },
    {
      "if": { "properties": { "op": { "const": "update_file" } } },
      "then": { "required": ["content"] }
    }
  ]
}
```

## 6.2 Patch Plan Schema (top-level)

```json
{
  "type": "object",
  "required": ["summary", "operations"],
  "properties": {
    "summary": { "type": "string" },
    "runSuggestions": {
      "type": "array",
      "items": { "type": "string" }
    },
    "operations": {
      "type": "array",
      "items": { "$ref": "#/definitions/PatchOperation" },
      "maxItems": 500
    }
  }
}
```

---

## 7) Provider Abstraction

Create an interface so models are swappable:

```js
class AIProvider {
  async generateStructured({ systemPrompt, userPrompt, jsonSchema, temperature, model }) {}
}
```

Implementations:
- `OpenAIProvider`
- `AnthropicProvider` (future)
- `MockProvider` (tests/local)

Rules:
- provider response must be schema-valid.
- invalid responses trigger one repair attempt with “return valid JSON only”.

---

## 8) Context Builder Rules

Priority order:
1. User prompt + explicit constraints.
2. Recently changed files.
3. Relevant app entry points.
4. Error logs (for fix mode).
5. Dependency manifests.

Limits:
- max file count per request,
- max chars/tokens per file,
- summarization for large files.

Never include:
- secrets/env values,
- large binary files,
- ignored/vendor folders.

---

## 9) Policy Enforcement

## 9.1 Path Policy
- normalize and resolve absolute path.
- ensure path starts with workspace root.
- deny hidden/system paths if configured.
- deny `.git/`, host mounts, parent traversal.

## 9.2 Command Policy
Allowlist MVP examples:
- `npm install`
- `npm run build`
- `npm run test`
- `npm run dev` (optional with timeout)
- `node <file>`

Deny examples:
- `curl | bash`
- `rm -rf /`
- package manager global installs
- network-scanning commands

## 9.3 Operation Policy
- max changed files per patch.
- max content bytes per file.
- `delete_file` requires explicit user approval.
- lock protected files from edits.

---

## 10) Persistence Design (MVP-friendly)

Minimal tables/collections:

1. `ai_sessions`
2. `generation_requests`
3. `patch_plans`
4. `patch_operations`
5. `apply_results`
6. `run_executions`
7. `fix_iterations`
8. `snapshots`
9. `audit_events`

If DB is not ready, start with JSON/event logs + filesystem metadata, then migrate.

---

## 11) Error Handling Strategy

Standard error envelope:

```json
{
  "error": {
    "code": "AI_SCHEMA_INVALID",
    "message": "Model output did not match required patch schema.",
    "requestId": "gen_001",
    "retryable": true
  }
}
```

Error classes:
- validation errors (400),
- auth errors (401/403),
- conflict errors (409),
- policy violations (422),
- provider/runtime errors (502/503),
- internal errors (500).

---

## 12) Idempotency & Concurrency

- Accept `Idempotency-Key` on generate/apply.
- Reject concurrent apply for same workspace with lock.
- Session state machine prevents invalid transitions:
  - e.g., cannot apply while another apply is running.
- Queue run/fix jobs per workspace.

---

## 13) Observability Hooks

Emit structured logs with:
- `requestId`, `sessionId`, `workspaceId`,
- `phase` (generate/apply/run/fix),
- latency,
- token usage,
- model/provider,
- operation counts,
- policy denials.

Metrics:
- generation latency histogram,
- schema failure counter,
- apply success/failure ratio,
- run success ratio,
- fix loop success ratio.

---

## 14) Security Notes

- Do not trust model-suggested commands.
- redact secrets in logs/prompts.
- avoid sending complete workspace blindly.
- enforce per-user quotas.
- store audit trail for every applied AI operation.

---

## 15) Suggested Implementation Order

1. Add schema + policy modules.
2. Implement `POST /api/ai/generate` with mocked provider.
3. Add diff rendering payload and patch persistence.
4. Implement `POST /apply` with snapshot support.
5. Implement `POST /run` + log streaming.
6. Implement `POST /fix`.
7. Add metrics/audit.
8. Harden error handling + idempotency.

---

## 16) Definition of Done (Backend MVP)

Backend MVP is done when:
1. Generate returns valid structured patch plans.
2. Apply writes only approved, policy-compliant changes.
3. Run executes allowed commands in sandbox and streams logs.
4. Fix flow produces targeted patch plans from failures.
5. Snapshot rollback works.
6. All actions are auditable with request/session IDs.