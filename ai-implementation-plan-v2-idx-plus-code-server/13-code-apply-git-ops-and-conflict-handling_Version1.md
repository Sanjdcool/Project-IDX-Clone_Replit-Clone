# 13 — Code Apply, Git Ops, and Conflict Handling

## Status
Draft (target: platform + AI + security sign-off)

## Date
2026-04-16

## Purpose

Define safe and deterministic workflows for applying AI-generated code changes, managing git operations, and handling conflicts/errors across workspace branches in the IDX + code-server platform.

---

## 1) Design Goals

1. Reliable, reversible code application workflow.
2. Transparent git operations with user control.
3. Strong conflict detection and guided resolution.
4. Auditability of all mutating actions.
5. Compatibility with team branch protection practices.

---

## 2) Scope

## In scope
1. File patch/apply pipeline
2. Change staging and commit workflows
3. Branch management interactions
4. Conflict/error taxonomy and resolution UX
5. Rollback and recovery paths

## Out of scope
1. Full code review platform replacement
2. External Git provider enterprise policy configs
3. Multi-repo monorepo orchestration at org scale (future phase)

---

## 3) Change Application Model

## 3.1 Modes of applying AI changes

1. **Proposed patch mode (default)**
   - AI suggests diffs, user reviews before apply.
2. **Auto-apply mode (guarded)**
   - permitted only under policy + scope limits.
3. **Batch refactor mode**
   - grouped file changes with stricter confirmation rules.

## 3.2 Apply transaction concept

Each apply action is tracked as a transaction:
- `apply_id`
- actor context
- targeted files/paths
- patch summary
- pre-apply repo state (commit ref/hash)
- result status

---

## 4) Patch Validation Pipeline

Before writing files:

1. Validate patch schema/format.
2. Validate path confinement within workspace root.
3. Detect binary/unsupported file patch attempts.
4. Validate patch size and file-count limits.
5. Optional syntax/lint pre-check.
6. Conflict pre-check against current file content hash.

If validation fails, do not partially apply unless explicitly in safe partial mode.

---

## 5) Atomicity and Partial Apply Policy

1. Default: atomic apply for small/medium change sets.
2. For large change sets:
   - optional chunked apply with per-file status.
3. On failure:
   - rollback unapplied/partially applied files to pre-apply snapshot.
4. Persist apply report with success/failure per file and reasons.

---

## 6) Git Workflow Integration

## 6.1 Baseline sequence

1. Ensure clean enough working state policy
2. Apply patch(es)
3. Show diff summary to user
4. Optional auto-stage selected files
5. Commit with generated + editable message
6. Optional push to selected branch/remote

## 6.2 Git context required

- current branch
- upstream tracking status
- uncommitted change summary
- ahead/behind indicators
- merge/rebase in-progress state detection

---

## 7) Branch Strategy and Guardrails

1. Default to feature branch workflow for AI changes (recommended).
2. Prevent direct protected-branch mutation unless explicitly authorized.
3. Enforce branch naming conventions optionally by org policy.
4. Auto-create suggestion branches for major AI refactors.

---

## 8) Conflict Detection Types

1. **File content conflict**
   - target lines changed since context retrieval
2. **Git merge conflict**
   - branch divergence and merge markers
3. **Semantic conflict**
   - patch applies but breaks symbols/contracts (detected by checks)
4. **Policy conflict**
   - action violates protected path/branch rule

---

## 9) Conflict Resolution Workflow

1. Detect and classify conflict type.
2. Surface conflict details with file and line anchors.
3. Offer resolution options:
   - rebase/retry apply,
   - manual edit in IDE,
   - regenerate patch with updated context,
   - abort and rollback.
4. Preserve unresolved patch intents for retry (optional).

---

## 10) Rollback and Recovery

1. Pre-apply snapshot or git stash checkpoint recommended.
2. One-click rollback to pre-apply state.
3. Failed commit/push flows should keep local changes intact by default unless user requests cleanup.
4. Recovery actions are fully audit logged.

---

## 11) Commit Message and Metadata Policy

1. Commit messages may be AI-suggested but user-editable.
2. Commit footer metadata (optional):
   - `Generated-by: <assistant/version>`
   - `Apply-ID: <id>`
3. Respect org policy for commit signing and DCO requirements.
4. Avoid embedding sensitive prompt/context in commit messages.

---

## 12) Push and Remote Operation Policy

1. Push requires credential and branch authorization checks.
2. For protected branches:
   - deny direct push unless policy permits.
3. Optional PR creation handoff:
   - prepare branch + commit summary for PR flow.
4. Handle remote rejection gracefully with actionable guidance.

---

## 13) Quality Gates Before Finalizing Changes

Optional/required by policy:
1. format check
2. lint check
3. unit test subset
4. type check/build check

Failing checks can:
- block auto-commit (strict mode), or
- warn user and allow manual override (flex mode).

---

## 14) Audit and Traceability

Every mutating action logs:

- who initiated it
- workspace/project/branch context
- files touched count
- diff stats (+/- lines, file count)
- commit hash(es) created
- push target and status
- rollback actions (if any)

Raw sensitive code need not be stored in audit logs; store metadata + references.

---

## 15) Error Taxonomy (Git + Apply)

- `APPLY_VALIDATION_*`
- `APPLY_CONFLICT_*`
- `APPLY_ROLLBACK_*`
- `GIT_STATUS_*`
- `GIT_COMMIT_*`
- `GIT_PUSH_*`
- `POLICY_PROTECTED_BRANCH_*`
- `POLICY_PROTECTED_PATH_*`

Must be machine-readable and stable for UI handling.

---

## 16) UX Requirements

1. Clear “proposed changes” panel with per-file diffs.
2. Apply status timeline (queued, applying, completed, failed).
3. Conflict panel with guided actions.
4. Commit/push actions available with policy-aware hints.
5. Rollback button for last apply transaction.

---

## 17) Testing Strategy

1. Unit tests:
   - patch validation/parsing
   - policy enforcement for protected paths/branches
2. Integration tests:
   - apply -> commit -> push happy path
   - conflict path and retry
3. Security tests:
   - path traversal in patches
   - unauthorized protected branch writes
4. Chaos tests:
   - runtime restart during apply
   - network loss during push
5. Regression tests:
   - large multi-file patch stability

---

## 18) Implementation Checklist

- [ ] Implement apply transaction model + persistence
- [ ] Implement patch validator and path confinement checks
- [ ] Implement pre-apply checkpoint/rollback support
- [ ] Implement git context analyzer and guardrails
- [ ] Implement protected branch/path policy hooks
- [ ] Implement conflict classifier and guided resolution APIs
- [ ] Implement commit/push flow with structured errors
- [ ] Implement audit trail for mutating actions

---

## 19) Acceptance Criteria

1. AI code changes can be reviewed and applied reliably.
2. Protected branches/paths are enforced consistently.
3. Conflicts are detected early and resolved with clear workflows.
4. Rollback is available and dependable after failed applies.
5. Git operations are auditable and policy-compliant end to end.

---

## 20) Dependencies

- `10-ai-agent-tooling-contracts.md`
- `12-prompt-orchestration-and-guardrails.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `16-audit-logging-policy-and-governance.md`
- `22-epics-stories-and-team-allocation.md`

---

## 21) Next Document

Proceed to:
`14-security-isolation-and-sandbox-hardening.md`