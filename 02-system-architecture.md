# 02 — System Architecture

## 1) Objective

Define a robust architecture for adding AI-driven app generation to the existing web IDE stack (frontend + backend + Docker sandbox), with clear boundaries for safety, observability, and scale.

## 2) High-Level Architecture

```text
+-------------------+         +----------------------------+         +------------------------+
|   Web Frontend    | <-----> |        Backend API         | <-----> |   LLM Provider(s)      |
| (React + Monaco)  |  WS/HTTP| (Express + Socket Server)  |  HTTPS  | (OpenAI/Anthropic/etc) |
+---------+---------+         +------+---------------------+         +-----------+------------+
          |                          |                                           |
          |                          |                                           |
          |                          v                                           |
          |                 +--------------------+                               |
          |                 | Orchestration Core |                               |
          |                 | (Plan/Patch/Run)   |                               |
          |                 +---------+----------+                               |
          |                           |                                          |
          |                           v                                          |
          |                 +--------------------+                               |
          |                 | Workspace Manager  |                               |
          |                 | (files/snapshots)  |                               |
          |                 +---------+----------+                               |
          |                           |                                          |
          |                           v                                          |
          |                 +--------------------+                               |
          |                 | Sandbox Runtime    |-------------------------------+
          |                 | (Docker containers)|
          |                 +--------------------+
          |
          v
+-------------------+
| Observability     |
| Metrics/Logs/Traces
+-------------------+
```

## 3) Core Components

### 3.1 Frontend (React/Vite)
Responsibilities:
- Chat UX (prompt input, responses, status timeline).
- Diff viewer with selective approval.
- Run controls and live log panel.
- Session history (generation attempts, run/fix cycles).
- Policy feedback (blocked action messages, approval prompts).

### 3.2 API Layer (Express + Socket.IO)
Responsibilities:
- Expose HTTP + WebSocket endpoints.
- Authenticate user/session/workspace.
- Validate incoming payloads (schema + policy).
- Forward long-running tasks to orchestration engine.
- Stream progress events back to clients.

### 3.3 AI Orchestration Core
Responsibilities:
- Build prompt context from workspace + history + logs.
- Call model provider with tool-aware prompt format.
- Enforce structured output schema.
- Convert model output to patch plan.
- Trigger apply/run/fix state transitions.

### 3.4 Workspace Manager
Responsibilities:
- Read/write files safely under workspace root.
- Create snapshots/checkpoints.
- Produce unified diffs.
- Apply patches atomically where possible.
- Roll back to previous checkpoints.

### 3.5 Sandbox Runtime Manager (Docker)
Responsibilities:
- Start/stop isolated containers per workspace/session.
- Execute approved commands.
- Stream stdout/stderr.
- Enforce resource limits (CPU/memory/timeouts).
- Return execution metadata (exit code, timings).

### 3.6 Policy Engine
Responsibilities:
- Path safety checks.
- Command allowlist checks.
- Max file size / file count limits per operation.
- Dangerous pattern detection (optional tiered checks).
- Gate destructive ops behind explicit approval.

### 3.7 Observability Stack
Responsibilities:
- Structured logs for each step.
- Metrics for latency/success/cost.
- Trace IDs spanning frontend action to backend execution.
- Audit events for all AI changes.

## 4) Domain Model (Conceptual)

### Entities

1. **Workspace**
   - `workspaceId`
   - `ownerId`
   - `rootPath`
   - `activeSnapshotId`

2. **AISession**
   - `sessionId`
   - `workspaceId`
   - `status` (idle/generating/reviewing/applying/running/fixing/error)
   - `createdAt`, `updatedAt`

3. **GenerationRequest**
   - `requestId`
   - `sessionId`
   - `prompt`
   - `constraints`
   - `provider`, `model`
   - `tokenUsage`, `costEstimate`

4. **PatchPlan**
   - `patchPlanId`
   - `requestId`
   - `operations[]` (create/update/delete)
   - `summary`
   - `riskLevel`

5. **ApprovalDecision**
   - `decisionId`
   - `patchPlanId`
   - `approvedFiles[]`
   - `rejectedFiles[]`
   - `approvedBy`

6. **RunExecution**
   - `runId`
   - `workspaceId`
   - `commands[]`
   - `status`
   - `exitCode`
   - `logsRef`

7. **FixIteration**
   - `iterationId`
   - `runId`
   - `errorSummary`
   - `patchPlanId`
   - `outcome`

8. **Snapshot**
   - `snapshotId`
   - `workspaceId`
   - `createdBeforeAction` (apply/run/fix)
   - `metadata`

## 5) Lifecycle Flows

## 5.1 Generate Flow (Prompt → Patch Plan)

1. User submits prompt.
2. Backend validates session + constraints.
3. Orchestrator gathers context:
   - project tree,
   - key files,
   - recent edits,
   - current errors (if any).
4. LLM called with structured output contract.
5. Response validated against schema.
6. Patch plan stored and returned for review.

## 5.2 Review & Apply Flow

1. Frontend displays unified diffs.
2. User approves all or selected files.
3. Workspace manager:
   - creates snapshot,
   - applies approved ops,
   - verifies post-apply integrity.
4. Result status emitted to client.

## 5.3 Run Flow

1. User triggers run (or auto-run policy).
2. Policy engine validates command set.
3. Sandbox manager executes commands in container.
4. Log stream emitted over Socket.IO.
5. Exit status and diagnostics saved.

## 5.4 Fix Flow (Error → AI Repair)

1. User clicks “Fix with AI”.
2. Orchestrator builds fix context:
   - failing command,
   - error logs excerpt,
   - changed files,
   - dependency metadata.
3. LLM returns targeted patch.
4. Same review/apply cycle repeats.
5. Optional re-run and success check.

## 6) Trust Boundaries

1. **Client boundary**
   - Never trust frontend-provided file paths or commands.
   - Recompute/validate all server-side.

2. **Model boundary**
   - LLM output treated as untrusted proposal.
   - Must pass schema, policy, and user approval checks.

3. **Execution boundary**
   - All command execution inside sandbox only.
   - No host shell execution from AI path.

4. **Secret boundary**
   - Provider keys and sensitive env vars never sent to client or model prompt.
   - Redact logs before persistence/display.

## 7) Data Flow Details

## 7.1 Context Packing Strategy
Inputs to generation:
- minimal project map,
- top relevant files,
- active user objective,
- style/stack constraints,
- recent diagnostics.

Output from model:
- structured operations + rationale + run suggestions.

## 7.2 Patch Application Strategy
- Normalize all paths.
- Reject writes outside workspace.
- Validate content size/type.
- Apply per-file operation with transaction-like bookkeeping.
- If failure mid-apply, rollback to snapshot.

## 7.3 Execution Data Strategy
- Capture logs incrementally.
- Persist only bounded logs (with truncation and raw artifact pointer).
- Parse error summaries (build/runtime/test).

## 8) API and Event Surface (Overview)

### HTTP (example)
- `POST /api/ai/generate`
- `POST /api/ai/patch/:id/apply`
- `POST /api/ai/run`
- `POST /api/ai/fix`
- `POST /api/ai/snapshots/:id/rollback`

### WebSocket events (example)
- `ai:generation:started`
- `ai:generation:progress`
- `ai:generation:ready`
- `ai:apply:completed`
- `ai:run:log`
- `ai:run:completed`
- `ai:fix:ready`
- `ai:error`

(Exact contracts defined in backend design doc.)

## 9) Reliability Patterns

- Idempotent apply endpoint via request IDs.
- Retry transient LLM failures with exponential backoff.
- Circuit breaker for provider instability.
- Queue and cancel long-running tasks.
- Timeout guards:
  - generation timeout,
  - apply timeout,
  - run timeout.

## 10) Scalability Strategy

- Stateless API nodes + shared session store.
- Queue-based workers for heavy tasks (generation/run).
- Separate execution workers for sandbox operations.
- Horizontal scaling by workspace/session isolation.

## 11) Security Controls (Architecture Level)

- Strict input schema validation.
- Policy engine before any write/execute action.
- Workspace path sandboxing (`realpath` checks).
- Command allowlist with argument filtering.
- Rate limiting per user/session.
- Full audit trail (who approved what, when).

## 12) Failure Modes and Recovery

1. Model returns invalid structure
   - Response rejected; ask model for repair or return actionable error.

2. Patch apply conflict/failure
   - Auto rollback snapshot; return conflict details.

3. Container execution failure
   - Return infra error + remediation hint; keep logs.

4. Partial network disconnect
   - Resume session state from server; fetch latest status snapshot.

5. Provider outage
   - Fallback model/provider if configured; else fail gracefully.

## 13) Suggested Technology Additions

- Validation: `zod` or `ajv`.
- Diffs: `diff` / `unidiff`.
- Queue: `bullmq` (or lightweight in-memory queue for MVP).
- Tracing: OpenTelemetry.
- Metrics: Prometheus-compatible counters/histograms.
- Persistent store (optional MVP): PostgreSQL/Redis for sessions/log pointers.

## 14) MVP Architecture Constraints

For MVP simplicity:
- Single active AI session per workspace.
- No autonomous multi-step loop by default.
- Manual user approval before apply.
- Manual trigger for fix iteration.
- Bounded context size and bounded log retention.

## 15) Architecture Exit Criteria (for implementation readiness)

Architecture is implementation-ready when:
1. API/event contracts are frozen for MVP.
2. Patch schema and policy rules are finalized.
3. Snapshot/rollback behavior is deterministic.
4. Sandbox command policy is approved.
5. Observability events are defined for all major transitions.