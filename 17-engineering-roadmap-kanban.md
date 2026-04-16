# 17 — Engineering Roadmap (Kanban-Ready)

## 1) Purpose

A ready-to-copy delivery board for Jira/Trello/Linear:
- Epics
- Stories
- Tasks
- Acceptance criteria
- Suggested labels
- Dependencies

---

## 2) Board Columns (Suggested)

1. **Backlog**
2. **Ready**
3. **In Progress**
4. **Code Review**
5. **QA**
6. **Done**
7. **Blocked**

---

## 3) Label Set (Suggested)

- `area:backend`
- `area:frontend`
- `area:runtime`
- `area:security`
- `area:data`
- `priority:p0`
- `priority:p1`
- `priority:p2`
- `type:epic`
- `type:story`
- `type:task`
- `type:bug`
- `mvp`
- `post-mvp`
- `needs-spec`
- `blocked`

---

## 4) Epic E1 — AI Generation Foundation (`priority:p0`, `mvp`)

## Story E1-S1: Define API + schema contracts
**Labels:** `type:story area:backend priority:p0 mvp`  
**Dependencies:** none

### Tasks
- [ ] Create OpenAPI contract (`11-api-contracts-openapi.yaml`)
- [ ] Implement request validation schemas
- [ ] Add shared error envelope + error codes
- [ ] Add contract tests

### Acceptance Criteria
- All AI endpoints have validated request/response contracts.
- Invalid payloads return consistent error format.

---

## Story E1-S2: Provider abstraction + prompts v1
**Labels:** `type:story area:backend priority:p0 mvp`  
**Dependencies:** E1-S1

### Tasks
- [ ] Implement provider interface
- [ ] Add primary model adapter
- [ ] Add system/generate/fix prompt templates
- [ ] Add prompt version tagging

### Acceptance Criteria
- Backend can call provider with structured schema and parse response.
- Prompt version stored with request metadata.

---

## Story E1-S3: Context builder v1
**Labels:** `type:story area:backend priority:p0 mvp`  
**Dependencies:** E1-S2

### Tasks
- [ ] Build workspace tree summarizer
- [ ] Add relevant file selection logic
- [ ] Add truncation/summarization rules
- [ ] Add context redaction for secrets patterns

### Acceptance Criteria
- Context payload is bounded and includes relevant files.
- Oversized/binary/ignored files excluded.

---

## 5) Epic E2 — Patch Review and Apply (`priority:p0`, `mvp`)

## Story E2-S1: Generate patch plan endpoint
**Labels:** `type:story area:backend priority:p0 mvp`  
**Dependencies:** E1-S2, E1-S3

### Tasks
- [ ] Implement `POST /api/ai/generate`
- [ ] Validate model output schema
- [ ] Persist patch plan + operations
- [ ] Emit generation socket events

### Acceptance Criteria
- Valid prompt returns patch plan with summary and operations.
- Invalid model output fails gracefully with actionable code.

---

## Story E2-S2: Patch details + unified diff
**Labels:** `type:story area:backend area:frontend priority:p0 mvp`  
**Dependencies:** E2-S1

### Tasks
- [ ] Implement `GET /api/ai/patch/:patchPlanId`
- [ ] Build backend diff mapper
- [ ] Render changed files + unified diffs in UI

### Acceptance Criteria
- User can inspect all changed files and diffs.

---

## Story E2-S3: Selective apply + snapshot
**Labels:** `type:story area:backend area:frontend area:runtime priority:p0 mvp`  
**Dependencies:** E2-S2

### Tasks
- [ ] Implement `POST /api/ai/patch/:id/apply`
- [ ] Create snapshot before apply
- [ ] Add apply selections UI
- [ ] Add apply result status events

### Acceptance Criteria
- Only approved files are written.
- Snapshot is created before changes.
- Apply result appears in timeline.

---

## Story E2-S4: Rollback support
**Labels:** `type:story area:backend area:frontend area:runtime priority:p0 mvp`  
**Dependencies:** E2-S3

### Tasks
- [ ] Implement rollback endpoint
- [ ] Implement rollback modal + confirmation UX
- [ ] Add rollback events to timeline/history

### Acceptance Criteria
- Rollback restores prior workspace state reliably.

---

## 6) Epic E3 — Sandbox Run and Logs (`priority:p0`, `mvp`)

## Story E3-S1: Sandbox command execution service
**Labels:** `type:story area:runtime area:backend priority:p0 mvp`  
**Dependencies:** E1-S1

### Tasks
- [ ] Implement container ensure/reuse lifecycle
- [ ] Execute command sequence with timeouts
- [ ] Capture stdout/stderr and exit codes
- [ ] Persist run records

### Acceptance Criteria
- Commands run in sandbox only.
- Exit status and duration available per command.

---

## Story E3-S2: Realtime run events + console UI
**Labels:** `type:story area:runtime area:frontend priority:p0 mvp`  
**Dependencies:** E3-S1

### Tasks
- [ ] Implement `ai:run:*` socket events
- [ ] Build run console panel
- [ ] Handle command boundaries and stream separation
- [ ] Add reconnect-safe sequence handling

### Acceptance Criteria
- User sees near realtime logs and final run status.

---

## Story E3-S3: Run profiles + controls
**Labels:** `type:story area:frontend area:backend priority:p1 mvp`  
**Dependencies:** E3-S2

### Tasks
- [ ] Add Build/Test/Dev controls
- [ ] Add command policy checks integration
- [ ] Show policy-denied feedback in UI

### Acceptance Criteria
- Allowed runs execute.
- Disallowed runs are blocked with explicit message.

---

## 7) Epic E4 — AI Fix Loop (`priority:p0`, `mvp`)

## Story E4-S1: Failure diagnostics parser
**Labels:** `type:story area:runtime area:backend priority:p0 mvp`  
**Dependencies:** E3-S1

### Tasks
- [ ] Parse common build/runtime/test errors
- [ ] Generate concise error summary object
- [ ] Store summary with run record

### Acceptance Criteria
- Failed runs return structured diagnostics suitable for fix prompt.

---

## Story E4-S2: Fix endpoint and patch generation
**Labels:** `type:story area:backend priority:p0 mvp`  
**Dependencies:** E4-S1, E1-S2

### Tasks
- [ ] Implement `POST /api/ai/fix`
- [ ] Build fix-context payload
- [ ] Generate structured fix patch plan
- [ ] Persist and emit fix-ready event

### Acceptance Criteria
- “Fix with AI” produces a reviewable patch plan tied to failed run.

---

## Story E4-S3: Fix UX flow
**Labels:** `type:story area:frontend priority:p0 mvp`  
**Dependencies:** E4-S2, E2-S2

### Tasks
- [ ] Add “Fix with AI” action on failed runs
- [ ] Route fix output to Changes tab
- [ ] Preserve timeline linkage run → fix → apply → rerun

### Acceptance Criteria
- User can go from failed run to applied fix in same session flow.

---

## 8) Epic E5 — Security and Governance (`priority:p0`, `mvp`)

## Story E5-S1: Path policy enforcement
**Labels:** `type:story area:security area:backend priority:p0 mvp`

### Tasks
- [ ] Normalize and resolve paths against workspace root
- [ ] Block traversal and symlink escapes
- [ ] Enforce protected path rules

### Acceptance Criteria
- Writes outside workspace are impossible via AI flow.

---

## Story E5-S2: Command allowlist + runtime hardening
**Labels:** `type:story area:security area:runtime area:backend priority:p0 mvp`

### Tasks
- [ ] Implement command parser + allowlist
- [ ] Block dangerous command patterns
- [ ] Enforce non-root, non-privileged containers
- [ ] Add CPU/memory/timeout limits

### Acceptance Criteria
- Unsafe commands cannot execute.
- Sandbox limits enforced in all run paths.

---

## Story E5-S3: AuthZ and rate limiting
**Labels:** `type:story area:security area:backend priority:p0 mvp`

### Tasks
- [ ] Workspace ownership checks on every endpoint
- [ ] Socket room authorization checks
- [ ] Add per-user/session rate limits and quotas

### Acceptance Criteria
- Unauthorized access attempts are blocked and audited.

---

## Story E5-S4: Redaction + audit trail
**Labels:** `type:story area:security area:backend area:data priority:p0 mvp`

### Tasks
- [ ] Add redaction for logs/prompts
- [ ] Persist immutable audit events
- [ ] Add audit query/report utilities (internal)

### Acceptance Criteria
- Critical actions produce audit events.
- Secrets are not persisted in plain logs.

---

## 9) Epic E6 — Observability and Evaluation (`priority:p1`, `mvp`)

## Story E6-S1: Metrics and traces
**Labels:** `type:story area:backend area:runtime area:data priority:p1 mvp`

### Tasks
- [ ] Add counters/histograms for generate/apply/run/fix
- [ ] Propagate traceId/requestId/sessionId
- [ ] Instrument high-latency spans

### Acceptance Criteria
- Core flows visible in dashboards with correlation IDs.

---

## Story E6-S2: Dashboards and alerts
**Labels:** `type:story area:data area:devops priority:p1 mvp`

### Tasks
- [ ] Build workflow funnel dashboard
- [ ] Build runtime health dashboard
- [ ] Build cost/security anomaly panels
- [ ] Configure alert rules

### Acceptance Criteria
- On-call can detect major regressions within minutes.

---

## Story E6-S3: Offline eval baseline
**Labels:** `type:story area:data area:backend priority:p1 mvp`

### Tasks
- [ ] Curate benchmark prompt suite
- [ ] Define scoring rubric
- [ ] Run baseline and publish report

### Acceptance Criteria
- Baseline quality metrics documented before beta gate.

---

## 10) Epic E7 — Frontend UX Completion (`priority:p0`, `mvp`)

## Story E7-S1: AI panel and timeline
**Labels:** `type:story area:frontend priority:p0 mvp`

### Tasks
- [ ] Build tabbed AI panel
- [ ] Build timeline with status icons and timestamps
- [ ] Add loading/empty/error states

### Acceptance Criteria
- All AI workflow stages are visible in panel timeline.

---

## Story E7-S2: Diff review performance and usability
**Labels:** `type:story area:frontend priority:p0 mvp`

### Tasks
- [ ] Virtualize changed file list
- [ ] Optimize diff rendering for large patches
- [ ] Add keyboard navigation and accessibility labels

### Acceptance Criteria
- Large patch review remains responsive and accessible.

---

## Story E7-S3: Run/fix UX polish
**Labels:** `type:story area:frontend priority:p1 mvp`

### Tasks
- [ ] Improve log filtering/search
- [ ] Add failure cards with actionable next steps
- [ ] Improve reconnection status messaging

### Acceptance Criteria
- Run failure to fix flow is clear and low-friction.

---

## 11) Epic E8 — Data Layer and Reliability (`priority:p1`, `mvp`)

## Story E8-S1: DB schema and repositories
**Labels:** `type:story area:backend area:data priority:p1 mvp`

### Tasks
- [ ] Apply `13-database-schema.sql`
- [ ] Implement repository layer per core table
- [ ] Add transaction boundaries for apply/run/fix

### Acceptance Criteria
- Session, patch, run, fix, snapshot, and audit records persist reliably.

---

## Story E8-S2: Idempotency and locking
**Labels:** `type:story area:backend priority:p1 mvp`

### Tasks
- [ ] Add idempotency key support for mutating endpoints
- [ ] Add workspace lock for apply/rollback
- [ ] Add concurrent run guard per workspace

### Acceptance Criteria
- Duplicate mutating calls are safe.
- Conflicting operations return deterministic errors.

---

## 12) Epic E9 — QA and Release Readiness (`priority:p0`, `mvp`)

## Story E9-S1: Automated test suite
**Labels:** `type:story area:qa area:backend area:frontend priority:p0 mvp`

### Tasks
- [ ] Unit tests for schema/policy/parsers
- [ ] Integration tests for all endpoints
- [ ] E2E test for full prompt→green build path

### Acceptance Criteria
- CI includes stable tests for core workflows and negative paths.

---

## Story E9-S2: Security and failure drills
**Labels:** `type:story area:security area:devops priority:p0 mvp`

### Tasks
- [ ] Run traversal/command bypass test scenarios
- [ ] Run provider outage simulation
- [ ] Run sandbox crash recovery drill
- [ ] Validate incident runbook

### Acceptance Criteria
- Team can detect, contain, and recover from critical scenarios.

---

## Story E9-S3: Beta go/no-go checklist
**Labels:** `type:story area:product area:engineering priority:p0 mvp`

### Tasks
- [ ] Collect KPI baseline (quality/cost/latency/security)
- [ ] Verify MVP exit criteria in staging
- [ ] Final sign-offs (Product/Eng/Security/QA)

### Acceptance Criteria
- Formal go/no-go documented with evidence links.

---

## 13) Optional Post-MVP Epics

## Epic P1 — Autonomous Multi-Step Agent
- planner-executor loop
- stop conditions + budgets
- approval checkpoints

## Epic P2 — Template Ecosystem
- starter packs
- prompt routing to templates
- org-level custom templates

## Epic P3 — Multi-Model Routing
- complexity-based model selection
- fallback policies
- cost-aware routing

## Epic P4 — Collaboration Features
- shared sessions
- reviewer approvals
- team audit dashboards

---

## 14) Dependency Map (Quick)

- E1 precedes E2/E4
- E2 precedes E4
- E3 precedes E4
- E5 should run in parallel from start (do not postpone)
- E6 starts early for instrumentation, completes before beta
- E9 gates release

---

## 15) Weekly Operating Cadence (Suggested)

- **Mon**: planning + dependency unblock
- **Wed**: architecture/quality review
- **Fri**: demo + KPI snapshot + risk update

Track every story with:
- owner
- ETA
- blocked reason (if any)
- link to PR/tests/demo