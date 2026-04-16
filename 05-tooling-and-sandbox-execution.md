# 05 — Tooling and Sandbox Execution

## 1) Purpose

Define how AI-generated code is executed safely and reliably using containerized sandboxes, including command policies, runtime lifecycle, log streaming, resource isolation, and failure recovery.

---

## 2) Execution Model

AI features must never execute code on host directly.  
All install/build/test/dev commands run inside **workspace-scoped Docker containers**.

## Core principles
1. **Sandbox-only execution**
2. **Least privilege**
3. **Deterministic runtime**
4. **Bounded resources and time**
5. **Full execution audit trail**

---

## 3) Runtime Architecture

```text
+------------------------+
| Backend Orchestrator   |
| (run/fix requests)     |
+-----------+------------+
            |
            v
+------------------------+       +-------------------------+
| Sandbox Manager        |<----->| Docker Engine (daemon)  |
| - container lifecycle  |       | - create/start/exec     |
| - command execution    |       | - logs/stats            |
+-----------+------------+       +-------------------------+
            |
            v
+------------------------+
| Log Stream Service     |
| - stdout/stderr mux    |
| - websocket emission   |
+------------------------+
```

---

## 4) Container Strategy

## 4.1 Scope options

### Option A (MVP recommended): One container per workspace session
- Pros: simpler state continuity, easier caching of `node_modules`.
- Cons: long-lived container management complexity.

### Option B: One ephemeral container per run
- Pros: clean environment each run.
- Cons: slower repeated installs; less continuity.

**MVP recommendation:** Option A with periodic cleanup + idle timeout.

---

## 5) Base Image and Toolchain

Use pinned images to reduce drift.

Example baseline:
- OS: Debian/Ubuntu slim
- Node.js: pinned major/minor
- npm: pinned version
- optional: pnpm/yarn if enabled by policy

## Requirements
- non-root user inside container
- controlled working directory (e.g., `/workspace`)
- no privileged mode
- read/write limited to mounted workspace

---

## 6) Workspace Mounting

Mount host workspace path into container:
- Host: `<workspaceRoot>`
- Container: `/workspace`

Rules:
- read/write within workspace only
- prevent mounting sensitive host directories
- normalize paths before mount
- optionally mount temp cache volume for dependencies

---

## 7) Command Execution Lifecycle

## 7.1 Start run
1. Validate command array against policy.
2. Ensure container exists and is healthy.
3. Emit `ai:run:started`.

## 7.2 Execute commands
For each command:
1. Create exec instance.
2. Stream stdout/stderr incrementally.
3. Track duration and exit code.
4. If command fails:
   - stop sequence (default) OR
   - continue based on run profile.

## 7.3 Complete run
- emit `ai:run:completed`
- persist metadata:
  - commands
  - exit statuses
  - start/end timestamps
  - logs reference
  - parsed error summary

---

## 8) Command Policy Design

## 8.1 Allowlist (MVP)
Allow only safe development commands, e.g.:
- `npm install`
- `npm ci`
- `npm run build`
- `npm run test`
- `npm run dev`
- `node <script>`

(Exact list configurable.)

## 8.2 Denylist examples
- destructive host/system operations
- privilege escalation attempts
- network probing/scanning commands
- shell piping remote scripts (`curl ... | bash`)

## 8.3 Argument filtering
- sanitize command tokens
- optionally enforce command templates
- reject shell metacharacter abuse where policy requires

---

## 9) Resource Limits and Timeouts

Set container and exec limits:

- CPU shares/quota
- memory limit (e.g., 1–2 GB for MVP)
- pids limit
- no swap (optional stricter mode)
- max run timeout per command/profile

Examples:
- install timeout: 5–10 min
- build timeout: 5 min
- test timeout: 5 min
- dev server timeout: session-driven / capped

---

## 10) Network and Security Controls

MVP options:
1. **Restricted outbound network** (preferred where feasible)
2. **Allow package registry access only**
3. **Block sensitive metadata endpoints**

Never run with:
- `--privileged`
- host PID/IPC namespaces
- unrestricted mounts

Optional hardening:
- seccomp profile
- AppArmor/SELinux confinement
- read-only root filesystem (with writable workspace mount)

---

## 11) Logging and Streaming

## 11.1 Log capture
- capture stdout/stderr separately
- timestamp each chunk
- tag by `runId`, `commandIndex`

## 11.2 Log transport
- stream via Socket.IO event `ai:run:log`
- buffer recent logs in memory for fast reconnect
- persist complete logs to file/object storage if large

## 11.3 Log truncation
- enforce max log size in API response
- keep pointer/reference to full artifact

## 11.4 Redaction
- redact known secret patterns before persistence/display

---

## 12) Error Parsing for Fix Loop

After failed command:
- parse log tail with heuristics:
  - module not found
  - type errors
  - syntax errors
  - test assertion failures
- generate compact `errorSummary`:
  - failing command
  - likely file hints
  - key excerpts
- pass summary into AI fix prompt context

---

## 13) Snapshot Integration

Before patch apply (and optionally before risky runs):
- create snapshot metadata and/or filesystem checkpoint.

After run failure:
- snapshot not mandatory, but track linkage:
  - `runId -> patchPlanId -> snapshotId`

Rollback action should restore workspace consistency quickly.

---

## 14) Concurrency and Queueing

For each workspace:
- allow at most one active run at a time (MVP).
- queue subsequent run requests.
- allow cancel action for active run.

Global:
- worker queue for run jobs.
- backpressure when container capacity is reached.

---

## 15) Health and Lifecycle Management

## 15.1 Container health checks
- lightweight command (`node -v`, workspace stat)
- periodic checks for idle sessions

## 15.2 Idle cleanup
- stop/remove idle containers after timeout
- preserve workspace files on host mount
- emit session notice before cleanup if needed

## 15.3 Recovery
- if container crashes:
  - mark run failed with infra reason
  - auto-recreate container on next run request

---

## 16) Suggested Backend Services

1. `SandboxService`
   - `ensureContainer(workspaceId)`
   - `execCommand(runId, cmd, opts)`
   - `stopRun(runId)`
   - `disposeContainer(workspaceId)`

2. `RunPolicyService`
   - `validateCommands(commands)`
   - returns approved/rejected with reasons

3. `RunLogStreamService`
   - multiplex stdout/stderr to socket events
   - support reconnect replay window

4. `RunDiagnosticsService`
   - parse failures for AI fix context

---

## 17) Example Run Profiles

## profile: `quick-build`
```json
{
  "commands": [
    "npm install --prefix frontend",
    "npm run build --prefix frontend"
  ],
  "stopOnFailure": true,
  "timeoutMsPerCommand": 300000
}
```

## profile: `full-check`
```json
{
  "commands": [
    "npm install --prefix frontend",
    "npm install --prefix backend",
    "npm run build --prefix frontend",
    "npm run test --prefix backend"
  ],
  "stopOnFailure": true
}
```

## profile: `dev-preview`
```json
{
  "commands": [
    "npm install --prefix frontend",
    "npm run dev --prefix frontend"
  ],
  "stopOnFailure": true,
  "devServer": true
}
```

---

## 18) Observability for Runtime

Track metrics:
- run start/success/failure count
- per-command duration histograms
- timeout count
- container restart count
- queue wait time
- average logs size per run

Trace spans:
- request accepted
- policy validation
- container ensure
- command exec
- log stream
- completion

---

## 19) Failure Modes and Mitigations

1. **Dependency install timeout**
   - Mitigation: retry once, cache dependencies, better base image.

2. **Container OOM**
   - Mitigation: increase memory cap per profile or optimize commands.

3. **Run hangs**
   - Mitigation: timeout + termination + mark as failed.

4. **Log flood**
   - Mitigation: chunk throttling and truncation strategy.

5. **Policy false positives**
   - Mitigation: clear error messaging + policy exceptions workflow (admin-controlled).

---

## 20) MVP Checklist (Execution)

- [ ] Commands run only in containerized sandbox.
- [ ] Command allowlist enforced server-side.
- [ ] Live logs stream to frontend.
- [ ] Exit codes/timings persisted.
- [ ] Failed runs produce structured error summaries.
- [ ] One-click “Fix with AI” can consume these summaries.
- [ ] Idle containers cleaned up safely.