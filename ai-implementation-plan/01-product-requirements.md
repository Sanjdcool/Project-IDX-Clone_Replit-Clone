# 01 — Product Requirements

## 1) Vision

Transform the existing browser IDE into an **AI-native app builder** that can generate, modify, run, and iteratively fix applications from natural language instructions — similar to the experience users expect from Cursor Agent and Replit AI workflows.

## 2) Problem Statement

Current platform capability:
- Users can manually code in-browser (editor + terminal + runtime).

Gap:
- No built-in GenAI assistant to convert product intent into code changes.
- No guided loop for generation → run → diagnose → fix.
- No AI-safe controls for large-scale automated edits.

## 3) Product Goals

1. **Natural-language app generation**
   - User describes desired app.
   - System creates scaffold + core features across multiple files.

2. **Safe code application**
   - All AI edits are shown as structured diffs.
   - User can approve/reject before write.

3. **Execution-aware iteration**
   - Run commands in sandbox.
   - Capture compile/runtime/test failures.
   - Allow one-click AI remediation loop.

4. **Practical developer control**
   - Users can steer generation, lock files, and set constraints.
   - AI actions are traceable and reversible.

5. **Production-ready guardrails**
   - Command allowlists, path safety, secrets protection, rate limits, and audit logs.

## 4) Non-Goals (for MVP)

- Autonomous deployment to cloud providers.
- Cross-repo multi-agent orchestration.
- Fine-tuned custom models.
- Fully unsupervised edits without user checkpoints.
- Native mobile IDE UX.

## 5) Primary Personas

### Persona A: Beginner Builder
- Wants: “Build me a blog app with login.”
- Needs: Strong defaults, low setup friction, guided fixes.

### Persona B: Indie Hacker
- Wants fast scaffolding and iteration.
- Needs: Clear diffs, quick regenerate, reliable run loop.

### Persona C: Experienced Dev
- Wants AI as force multiplier, not replacement.
- Needs: deterministic edits, control over file scope, command policy, and observability.

## 6) Core User Stories

1. **Generate App**
   - As a user, I can enter a prompt and get a multi-file app scaffold generated.

2. **Preview Changes**
   - As a user, I can inspect diffs before changes are written.

3. **Apply Safely**
   - As a user, I can approve all, approve selected files, or reject changes.

4. **Run in Sandbox**
   - As a user, I can run install/build/dev/test commands in isolated environment.

5. **Auto-Fix Errors**
   - As a user, I can send run errors to AI and get targeted fixes.

6. **Iterate by Instruction**
   - As a user, I can ask follow-up changes (“add pagination”, “switch to PostgreSQL”).

7. **Track AI Actions**
   - As a user, I can see what AI changed, which tools it used, and why.

## 7) Functional Requirements

## FR-1 Prompt-to-Plan
- Accept natural language prompt and optional constraints:
  - tech stack preference,
  - package manager,
  - target runtime,
  - design style,
  - feature must-have list.
- Produce:
  - project plan summary,
  - file operation proposal (create/update/delete),
  - execution plan (commands to run).

## FR-2 Structured File Operations
- AI response must be machine-parseable (JSON schema).
- Supported operations:
  - `create_file`,
  - `update_file`,
  - `delete_file` (approval-gated),
  - `rename_file` (optional post-MVP).
- All paths validated against workspace root.

## FR-3 Diff Review
- Show per-file unified diffs.
- Actions:
  - approve all,
  - approve selected,
  - reject all,
  - request regeneration for selected files.

## FR-4 Apply and Snapshot
- Apply approved changes atomically where possible.
- Create checkpoint/snapshot before apply.
- Support rollback to previous checkpoint.

## FR-5 Execution Pipeline
- Run commands in sandbox container:
  - install dependencies,
  - build,
  - test,
  - start dev server (optional).
- Capture:
  - stdout/stderr,
  - exit codes,
  - timestamps,
  - command metadata.

## FR-6 AI Error Repair Loop
- User-triggered “Fix with AI” action.
- System supplies:
  - failing command,
  - logs excerpt,
  - affected files,
  - last patch metadata.
- AI returns patch proposal.
- Same diff/approval cycle applies.

## FR-7 Context Awareness
- AI can read project tree and selected files.
- Respect context budget:
  - summarize large files,
  - prioritize relevant files,
  - include recent errors and recent edits.

## FR-8 Conversation Memory
- Store session history:
  - prompts,
  - generated plans,
  - approvals,
  - runs,
  - fix attempts.
- Allow “continue from last step”.

## FR-9 Policy and Safety
- Command policy:
  - allowlist commands for MVP.
- File policy:
  - deny writes outside workspace.
- Content policy:
  - block dangerous suggestions where required.
- Resource limits:
  - token, request, runtime, and concurrency limits.

## FR-10 Basic Analytics
- Track:
  - generation success rate,
  - build success after first pass,
  - average fix loops to green,
  - time-to-runnable-app.

## 8) Non-Functional Requirements

## NFR-1 Performance
- Initial plan response: target < 8s (p50).
- Diff rendering for <= 200 changed files: responsive UI under 2s render target.
- Run log streaming latency: near real-time (< 500ms perceived delay).

## NFR-2 Reliability
- No partial write corruption.
- Retries for transient LLM/API failures with backoff.
- Graceful handling when model unavailable.

## NFR-3 Security
- Secrets never exposed in prompt logs.
- Strict workspace path normalization.
- Sandboxed command execution only.

## NFR-4 Scalability
- Support concurrent sessions per workspace.
- Queue long-running tasks with cancellation support.

## NFR-5 Auditability
- Every AI action linked to:
  - request ID,
  - model/provider,
  - tool calls,
  - file changes,
  - user approval event.

## 9) MVP Scope (Must Have)

- AI chat panel (single workspace session).
- Prompt → structured patch generation.
- Diff preview + selective apply.
- Sandbox run command + log streaming.
- Manual “Fix with AI” loop.
- Snapshot + rollback.
- Basic safety controls (path + command allowlist).
- Basic metrics dashboard/events.

## 10) Post-MVP Scope (Should Have)

- Autonomous multi-step run/fix with stop conditions.
- Template packs (SaaS starter, blog, dashboard, API service).
- Test generation and quality gates.
- Smarter repository-wide refactors.
- Multi-model routing and fallback policies.

## 11) Success Metrics

## Product Metrics
- % prompts that produce runnable app without manual edits.
- Median time from prompt to first successful run.
- User approval rate of AI-generated diffs.
- Retention: users returning for second generation session.

## Quality Metrics
- Build pass rate after generation.
- Avg number of fix iterations to success.
- % sessions requiring rollback.
- % unsafe operation attempts blocked.

## Business/Usage Metrics
- AI requests per active workspace.
- Cost per successful runnable output.
- Session completion rate.

## 12) Acceptance Criteria (MVP Exit)

MVP is accepted when all are true:

1. User can generate a multi-file app from one prompt.
2. User can review and selectively apply AI patches.
3. User can run generated app commands in sandbox and view live logs.
4. On failure, user can trigger AI fix and re-run successfully in common cases.
5. Path traversal and disallowed commands are blocked.
6. All AI-generated changes are auditable and rollback-capable.

## 13) Risks and Mitigations

1. **Low-quality generations**
   - Mitigation: templates + stricter response schema + eval suite.

2. **Run failures due to environment drift**
   - Mitigation: deterministic base images + pinned toolchain defaults.

3. **Unsafe code/commands**
   - Mitigation: policy engine, allowlists, and approval gates.

4. **High inference costs**
   - Mitigation: model tiering, caching summaries, truncation strategy.

5. **Large-context confusion**
   - Mitigation: retrieval ranking + focused context windows + explicit constraints.

## 14) Open Product Decisions

- Which model provider(s) are default for MVP?
- Should file deletes be disabled entirely in MVP?
- Should auto-run happen immediately after apply or require explicit user action?
- What is the default template when user gives vague prompt?
- Should generated projects default to JS or TS?

## 15) Release Recommendation

- Internal alpha (team only) → closed beta (selected users) → public beta.
- Gate public rollout on:
  - stable fix loop performance,
  - security checks,
  - acceptable generation success rate/cost ratio.