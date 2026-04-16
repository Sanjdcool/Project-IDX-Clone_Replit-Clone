# 04 — Frontend Design

## 1) Purpose

Define the frontend UX and technical design for AI-assisted app generation in the existing web IDE.

Goals:
- Natural-language generation flow.
- Reviewable and safe patch application.
- Tight run/fix loop with clear visibility.
- Fast, trustworthy, developer-centric UX.

---

## 2) UX Principles

1. **Human control first**
   - AI proposes; user approves.
2. **Progress transparency**
   - Every phase shows status, timing, and action logs.
3. **Minimal friction**
   - One primary workflow: Prompt → Diff → Apply → Run → Fix.
4. **Reversible actions**
   - Snapshot/rollback always available after apply.
5. **Context continuity**
   - Preserve conversation + action timeline in a session.

---

## 3) Information Architecture

## 3.1 Main IDE Layout (Proposed)

```text
+------------------------------------------------------------------------------------+
| Top Bar: Project / Branch / Session Status / Run Controls / AI Usage Indicator     |
+------------------------------+----------------------------------+------------------+
| File Explorer                | Editor Tabs (Monaco)             | AI Panel         |
| (workspace tree)             | Diff Tabs                         | (chat/timeline)  |
|                              |                                  |                  |
|                              |                                  |                  |
+------------------------------+----------------------------------+------------------+
| Terminal / Run Logs (xterm)                                                     |
+------------------------------------------------------------------------------------+
```

## 3.2 AI Panel Tabs

1. **Chat**
   - Prompt input
   - AI replies
   - action buttons (Generate, Regenerate, Fix with AI)

2. **Changes**
   - file list + unified diff preview
   - select/unselect files
   - apply/reject

3. **Runs**
   - run history
   - command status
   - log summaries + failures

4. **History**
   - snapshots, applied patches, rollback actions

---

## 4) Key User Flows

## 4.1 Generate Flow (Primary)

1. User types prompt.
2. Clicks **Generate App**.
3. UI shows generation progress states:
   - preparing context,
   - calling model,
   - validating output,
   - preparing diffs.
4. Changes tab opens with file diffs.
5. User approves selected files.
6. Apply success toast + timeline entry.

## 4.2 Run Flow

1. User clicks **Run Build/Test/Dev**.
2. Terminal panel streams logs in realtime.
3. On success: green status with duration.
4. On failure: actionable error card with **Fix with AI** button.

## 4.3 Fix Flow

1. User clicks **Fix with AI** from failed run.
2. AI generates targeted patch.
3. Diff review opens again.
4. Apply and optional re-run.

## 4.4 Rollback Flow

1. User opens History tab.
2. Select snapshot.
3. Click **Rollback**.
4. Confirm modal with impacted files.
5. Editor reloads updated workspace state.

---

## 5) UI Components (Proposed)

## 5.1 `AIAssistantPanel`
- Container for tabs and chat actions.
- Props:
  - `sessionId`
  - `workspaceId`
  - handlers for generate/apply/run/fix.

## 5.2 `PromptComposer`
- multi-line prompt input.
- optional constraints drawer:
  - stack,
  - TS/JS toggle,
  - locked files,
  - max file changes.
- actions:
  - Generate
  - Stop (for streaming generation where supported).

## 5.3 `AITimeline`
- chronological events:
  - generation started,
  - patch ready,
  - apply done,
  - run failed/success,
  - fix iteration.
- each event includes timestamp + request ID.

## 5.4 `PatchReviewPanel`
- changed files sidebar with status chips:
  - create/update/delete.
- file checkbox selection.
- diff viewer with syntax highlight.
- batch actions:
  - approve all,
  - approve selected,
  - reject all.

## 5.5 `DiffViewer`
- unified diff mode (default).
- split view mode (optional).
- supports large file virtualization.
- line-level context toggle.

## 5.6 `RunConsolePanel`
- command queue display.
- log stream output.
- filter:
  - all/stdout/stderr.
- “copy error summary” action.

## 5.7 `SnapshotHistoryPanel`
- list snapshots with labels:
  - before apply,
  - before fix.
- rollback action and confirmation.

## 5.8 `PolicyWarningBanner`
- shows blocked actions:
  - disallowed command,
  - protected file edit attempt,
  - max file cap exceeded.

---

## 6) Frontend State Model

Use existing state solution (repo includes Zustand dependency).

## 6.1 Suggested stores

1. `aiSessionStore`
   - `sessionId`, `status`, `activeRequestId`
   - `messages[]`
   - `timeline[]`

2. `patchStore`
   - `activePatchPlan`
   - `files[]`
   - `selectedPaths[]`
   - `diffsByPath`

3. `runStore`
   - `runs[]`
   - `activeRunId`
   - `logsByRunId`
   - `parsedErrors`

4. `snapshotStore`
   - `snapshots[]`
   - rollback status

5. `uiStore`
   - panel visibility,
   - current tab,
   - loading states,
   - modals.

---

## 7) API Integration Contract (Frontend Perspective)

## 7.1 Generate
- `POST /api/ai/generate`
- optimistic UI:
  - add pending timeline entry
  - disable duplicate generate button until completion/error.

## 7.2 Fetch Patch Details
- `GET /api/ai/patch/:id`
- populate `patchStore`.

## 7.3 Apply
- `POST /api/ai/patch/:id/apply`
- payload from selected paths.
- on success:
  - refresh file tree/editor buffers,
  - add snapshot event.

## 7.4 Run
- `POST /api/ai/run`
- subscribe to socket logs by `runId`.

## 7.5 Fix
- `POST /api/ai/fix`
- returns new patch plan for review.

## 7.6 Rollback
- `POST /api/ai/snapshots/:id/rollback`
- invalidate caches and refresh workspace files.

---

## 8) Socket Event Handling

Subscribe to `/ai` namespace.

Events to handle:
- `ai:generation:started/progress/ready`
- `ai:apply:started/completed`
- `ai:run:started/log/completed`
- `ai:fix:started/ready`
- `ai:error`

Rules:
- ignore stale events (mismatched session/request IDs).
- keep event order per request using timestamps/sequence numbers.
- show reconnect indicator on socket disconnect.

---

## 9) UX States and Edge Cases

## 9.1 Loading states
- generating, applying, running, fixing.
- each with cancel/close behavior where possible.

## 9.2 Empty states
- no patch yet,
- no runs yet,
- no snapshots yet.

## 9.3 Error states
- model unavailable,
- schema validation failed,
- policy blocked,
- network/socket interruption.

Each error should show:
- concise reason,
- suggested next action,
- request ID for support/debugging.

## 9.4 Conflict states
- workspace changed after patch generated:
  - show “patch outdated” warning,
  - offer regenerate with fresh context.

---

## 10) Accessibility Requirements

- Keyboard-first navigation:
  - prompt submit, tab switches, diff file selection.
- ARIA labels for all actionable controls.
- Terminal and log areas accessible with screen readers where feasible.
- Color contrast compliant status indicators.
- Focus management for modals/toasts.

---

## 11) Performance Requirements (Frontend)

- Diff list render target: <= 200ms for common patch sizes.
- Use virtualization for large file lists/log streams.
- Debounce prompt autosave and search/filter inputs.
- Batch store updates for high-frequency socket logs.
- Lazy load heavy components (diff view/editor extras).

---

## 12) Suggested Component File Structure

```text
frontend/src/
  features/ai/
    components/
      AIAssistantPanel.jsx
      PromptComposer.jsx
      AITimeline.jsx
      PatchReviewPanel.jsx
      DiffViewer.jsx
      RunConsolePanel.jsx
      SnapshotHistoryPanel.jsx
      PolicyWarningBanner.jsx
    hooks/
      useAISession.js
      useAIGeneration.js
      usePatchApply.js
      useRunExecution.js
      useSocketAIEvents.js
    api/
      ai.api.js
    store/
      aiSession.store.js
      patch.store.js
      run.store.js
      snapshot.store.js
    utils/
      diff.utils.js
      error.utils.js
      event.utils.js
    types/
      ai.types.js
```

---

## 13) Example UI Event Timeline

```text
[12:00:01] User prompt submitted
[12:00:02] Generation started (req: gen_001)
[12:00:06] Patch ready (24 files changed)
[12:00:20] User approved 18 files
[12:00:21] Apply completed (snapshot: snap_42)
[12:00:30] Run started (run_001)
[12:00:45] Build failed (missing dependency)
[12:00:50] Fix requested (fix_001)
[12:00:57] Fix patch ready (5 files)
[12:01:10] Apply completed
[12:01:22] Build succeeded
```

---

## 14) Design Tokens / Visual Guidance (Optional MVP)

- Status colors:
  - success: green,
  - warning: amber,
  - error: red,
  - pending: blue.
- Diff colors:
  - additions/deletions with accessible contrast.
- Consistent iconography for generate/apply/run/fix/rollback.

---

## 15) Frontend Security Considerations

- Never trust client-side validation alone.
- Do not expose provider keys in frontend.
- Escape/render untrusted AI text safely.
- Prevent XSS in log/diff renderers.
- Redact secrets in visible logs where backend provides redaction hints.

---

## 16) Telemetry Events (Frontend)

Track:
- `ai_prompt_submitted`
- `ai_patch_view_opened`
- `ai_patch_apply_clicked`
- `ai_patch_apply_success`
- `ai_run_started`
- `ai_run_failed`
- `ai_fix_requested`
- `ai_rollback_triggered`

Attach:
- `workspaceId`, `sessionId`, `requestId`,
- patch size,
- duration.

---

## 17) MVP Frontend Definition of Done

Frontend MVP is done when:
1. User can prompt AI and receive patch proposals.
2. User can review and selectively apply diffs.
3. User can run commands and view live logs.
4. User can trigger AI fix on failures.
5. User can view timeline and rollback from snapshots.
6. All major states/errors are clearly represented in UI.