# 14 — Backend Task Breakdown

## 1) Purpose

Translate the architecture/design docs into concrete backend implementation tasks mapped to modules, functions, endpoint contracts, and delivery sequence.

This is execution-focused and intended for direct sprint planning.

---

## 2) Assumed Existing Stack

- Node.js backend (Express)
- Socket.IO available (or add)
- Docker runtime integration available in project
- Existing auth/session middleware in place

If any item is missing, add a “foundation patch” before Phase 1.

---

## 3) Folder and File Plan (Create/Update)

## 3.1 New backend files

```text
backend/src/
  routes/ai.routes.js
  ai/controller/ai.controller.js
  ai/controller/ai.run.controller.js
  ai/service/ai-orchestrator.service.js
  ai/service/ai-provider.service.js
  ai/service/ai-context.service.js
  ai/service/ai-repair.service.js
  ai/service/ai-session.service.js
  ai/schema/generate-request.schema.js
  ai/schema/patch-plan.schema.js
  ai/schema/apply-request.schema.js
  ai/schema/run-request.schema.js
  ai/schema/fix-request.schema.js
  ai/policy/path-policy.service.js
  ai/policy/command-policy.service.js
  ai/policy/operation-policy.service.js
  ai/prompt/system.prompt.js
  ai/prompt/generate.prompt.js
  ai/prompt/fix.prompt.js
  ai/mapper/ai-response.mapper.js
  ai/mapper/diff.mapper.js
  ai/socket/ai.socket.js
  workspace/snapshot.service.js
  workspace/patch-apply.service.js
  runtime/sandbox.service.js
  runtime/run-log-stream.service.js
  runtime/run-diagnostics.service.js
  audit/audit.service.js
  utils/error-codes.js
  utils/request-context.js
```

## 3.2 Existing files likely to update

```text
backend/src/app.js (or server.js)
backend/src/routes/index.js
backend/src/socket/index.js
backend/src/middleware/auth.js (if extension needed)
backend/src/config/*.js
```

---

## 4) Endpoint-by-Endpoint Task List

## 4.1 POST `/api/ai/generate`

### Controller tasks
- [ ] Parse payload, validate schema.
- [ ] Check user can access `workspaceId`.
- [ ] Create generation request record (`status=started`).
- [ ] Emit socket `ai:generation:started`.

### Service tasks
- [ ] Build context from workspace tree + key files.
- [ ] Build prompt package (system + task + context).
- [ ] Call provider with structured schema.
- [ ] Validate JSON output against `patch-plan.schema`.
- [ ] Run policy checks on each operation.
- [ ] Persist patch plan + operations + diff summaries.
- [ ] Emit `ai:generation:ready`.
- [ ] Return summary payload.

### Failure tasks
- [ ] On schema/provider/policy error:
  - mark request failed
  - emit `ai:generation:failed`
  - return standardized error envelope

---

## 4.2 GET `/api/ai/patch/:patchPlanId`

- [ ] Verify session/workspace ownership.
- [ ] Fetch patch plan + operations + patch_files.
- [ ] Return full response with unified diffs.
- [ ] Handle not-found and forbidden errors.

---

## 4.3 POST `/api/ai/patch/:patchPlanId/apply`

### Controller tasks
- [ ] Validate apply payload.
- [ ] Ensure approved/rejected paths belong to patch plan.
- [ ] Acquire workspace apply lock.
- [ ] Emit `ai:apply:started`.

### Service tasks
- [ ] Create snapshot (if enabled).
- [ ] Apply operations only for approved paths.
- [ ] Enforce path policy again during apply (defense in depth).
- [ ] Write files via patch apply service.
- [ ] Verify filesystem state.
- [ ] Persist apply result + audit.
- [ ] Emit `ai:apply:completed`.

### Failure tasks
- [ ] Rollback snapshot on partial failure (configurable).
- [ ] Emit `ai:apply:failed`.
- [ ] Release workspace lock always.

---

## 4.4 POST `/api/ai/run`

### Controller tasks
- [ ] Validate run payload.
- [ ] Policy check commands.
- [ ] Create run record (`status=started`).
- [ ] Emit `ai:run:started`.

### Service tasks
- [ ] Ensure sandbox container for workspace.
- [ ] Execute commands sequentially.
- [ ] Emit per-command events:
  - `ai:run:command_started`
  - `ai:run:log`
  - `ai:run:command_completed`
- [ ] Compute final status.
- [ ] Persist diagnostics and completion.
- [ ] Emit `ai:run:completed`.

---

## 4.5 POST `/api/ai/fix`

### Controller tasks
- [ ] Validate request.
- [ ] Fetch failed run details and log excerpt.
- [ ] Emit `ai:fix:started`.

### Service tasks
- [ ] Build fix context:
  - failing command
  - error summary
  - recent file changes
- [ ] Call provider with fix prompt/schema.
- [ ] Validate and policy-check operations.
- [ ] Persist patch plan.
- [ ] Emit `ai:fix:ready`.

### Failure tasks
- [ ] Emit `ai:fix:failed`.
- [ ] Return retryable/non-retryable error envelope.

---

## 4.6 POST `/api/ai/snapshots/:snapshotId/rollback`

- [ ] Validate ownership.
- [ ] Acquire workspace lock.
- [ ] Emit `ai:rollback:started`.
- [ ] Restore snapshot via snapshot service.
- [ ] Persist rollback event.
- [ ] Emit `ai:rollback:completed` or `ai:rollback:failed`.
- [ ] Release lock.

---

## 5) Service-Level Implementation Tasks

## 5.1 `ai-provider.service.js`

- [ ] Implement provider interface.
- [ ] Add `generateStructured()` method.
- [ ] Parse response safely.
- [ ] Single repair pass for invalid JSON.
- [ ] Return token usage + provider request IDs.

---

## 5.2 `ai-context.service.js`

- [ ] Build workspace file tree summary.
- [ ] Select relevant files heuristically:
  - entrypoints
  - recently edited
  - prompt-keyword matched files
- [ ] Apply context limits (max files, max chars per file).
- [ ] Redact sensitive data patterns.
- [ ] Return context bundle for prompts.

---

## 5.3 `ai-orchestrator.service.js`

- [ ] Central state transitions for generation/fix.
- [ ] Compose prompts.
- [ ] Call provider.
- [ ] Validate/transform model output.
- [ ] Delegate to diff mapper and persistence layer.
- [ ] Emit lifecycle socket events.

---

## 5.4 `patch-apply.service.js`

- [ ] Normalize path and enforce workspace boundary.
- [ ] Apply create/update/delete operations.
- [ ] Ensure writes are atomic-ish per file.
- [ ] Track apply stats (applied/skipped/blocked).
- [ ] Return detailed results.

---

## 5.5 `snapshot.service.js`

- [ ] Create snapshot refs (filesystem/object/gitreference).
- [ ] Restore snapshot contents.
- [ ] Validate snapshot compatibility with workspace.
- [ ] Track metadata and lifecycle events.

---

## 5.6 `sandbox.service.js`

- [ ] Ensure container lifecycle:
  - create/start/reuse/cleanup
- [ ] Exec command with timeout/resource options.
- [ ] Capture stdout/stderr streams.
- [ ] Return exit codes + duration.

---

## 5.7 `run-diagnostics.service.js`

- [ ] Parse common error categories:
  - module not found
  - syntax error
  - type error
  - test failure
- [ ] Build concise error summary for fix prompt.
- [ ] Attach relevant file hints when possible.

---

## 5.8 `audit.service.js`

- [ ] Write standardized audit events.
- [ ] Include actor/workspace/session/request IDs.
- [ ] Ensure error paths also emit events.
- [ ] Support query filters (future admin tooling).

---

## 6) Socket Tasks (`ai.socket.js`)

- [ ] Create namespace `/ai`.
- [ ] Authenticate handshake.
- [ ] Implement room join/leave by `sessionId`.
- [ ] Enforce authorization for room join.
- [ ] Provide helper emitter:
  - `emitToSession(sessionId, eventType, payload)`
- [ ] Add optional sync event on reconnect.

---

## 7) Policy Engine Tasks

## 7.1 Path policy
- [ ] `validatePathInWorkspace(workspaceRoot, path)`
- [ ] reject traversal/symlink escapes
- [ ] protected path checks

## 7.2 Command policy
- [ ] tokenized command parser
- [ ] allowlist checks
- [ ] deny risky patterns

## 7.3 Operation policy
- [ ] max file count
- [ ] max file size
- [ ] delete operation gating
- [ ] locked file enforcement

---

## 8) Error Handling and Codes

Create centralized error codes:

- `AI_PROVIDER_UNAVAILABLE`
- `AI_SCHEMA_INVALID`
- `AI_POLICY_BLOCKED`
- `PATCH_APPLY_CONFLICT`
- `WORKSPACE_LOCK_FAILED`
- `RUN_COMMAND_BLOCKED`
- `RUN_TIMEOUT`
- `SNAPSHOT_RESTORE_FAILED`
- `AUTH_FORBIDDEN_WORKSPACE`

Tasks:
- [ ] define code map
- [ ] define retryable flag per code
- [ ] ensure consistent envelope across all endpoints

---

## 9) Database Integration Tasks

Assuming schema in `13-database-schema.sql`.

- [ ] Add repository/data-access layer for each table.
- [ ] Wire transaction boundaries for:
  - apply + snapshot metadata
  - run start/finish
  - fix generation records
- [ ] Add cleanup jobs:
  - old idempotency keys
  - old transient logs (if needed)

---

## 10) Idempotency and Locking

- [ ] Add `Idempotency-Key` support for mutating endpoints:
  - generate
  - apply
  - run
  - fix
- [ ] Add workspace-level lock for apply and rollback.
- [ ] Optional run lock to avoid concurrent runs in same workspace.

---

## 11) Observability Tasks (Backend)

- [ ] Structured logs with context IDs.
- [ ] Metrics counters/histograms:
  - generate latency/success
  - apply success/failure
  - run outcomes
  - fix outcomes
  - policy denials
- [ ] Trace spans for each phase.
- [ ] Alert hooks for critical failure spikes.

---

## 12) Security Tasks (Backend)

- [ ] Auth check on all AI routes.
- [ ] Workspace ownership check on all actions.
- [ ] Secret redaction in logs and persisted prompt data.
- [ ] Rate limiting by user/session/IP.
- [ ] Input schema strict mode (no unknown fields if desired).

---

## 13) Test Breakdown

## 13.1 Unit tests
- [ ] schemas
- [ ] path policy
- [ ] command policy
- [ ] context builder truncation
- [ ] diagnostics parser

## 13.2 Integration tests
- [ ] generate → patch fetch
- [ ] apply selected files
- [ ] run + log stream + completion
- [ ] fix from failed run
- [ ] rollback snapshot

## 13.3 Negative tests
- [ ] invalid schema responses from provider
- [ ] disallowed command attempts
- [ ] traversal path attempts
- [ ] unauthorized workspace access
- [ ] lock conflict on apply

---

## 14) Suggested Sprint Mapping

## Sprint 1
- route/controller scaffolding
- schemas
- policies
- provider abstraction + mock

## Sprint 2
- generate pipeline
- patch persistence
- patch fetch + diff response

## Sprint 3
- apply + snapshot + rollback
- audit integration

## Sprint 4
- sandbox run + log streaming
- run diagnostics

## Sprint 5
- fix pipeline + reliability hardening
- idempotency + locks + performance improvements

---

## 15) “Definition of Done” by Module

## AI Generate
- [ ] returns valid patch plan
- [ ] policy filtered
- [ ] diff preview available

## Apply
- [ ] only approved files applied
- [ ] snapshot created
- [ ] rollback functional

## Run
- [ ] commands validated
- [ ] logs streamed
- [ ] completion persisted

## Fix
- [ ] failed run context consumed
- [ ] targeted patch produced

## Platform Reliability
- [ ] consistent errors
- [ ] observability complete
- [ ] security controls enforced