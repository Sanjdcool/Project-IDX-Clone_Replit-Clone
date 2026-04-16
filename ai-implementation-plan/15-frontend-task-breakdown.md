# 15 — Frontend Task Breakdown

## 1) Purpose

Convert the frontend design into concrete implementation tasks mapped to components, stores, API hooks, socket handling, UX states, and test coverage.

---

## 2) Assumed Frontend Stack

- React (likely Vite-based)
- Monaco editor integration
- Existing file explorer + terminal/log panel
- State management available (Zustand recommended per existing dependencies)

If something is missing, add a small “foundation patch” before Phase 1.

---

## 3) Folder and File Plan (Create/Update)

## 3.1 New files (proposed)

```text
frontend/src/features/ai/
  components/
    AIAssistantPanel.jsx
    PromptComposer.jsx
    GenerationStatusBar.jsx
    AITimeline.jsx
    PatchReviewPanel.jsx
    ChangedFilesList.jsx
    DiffViewer.jsx
    ApplyActionsBar.jsx
    RunConsolePanel.jsx
    RunControls.jsx
    RunHistoryList.jsx
    SnapshotHistoryPanel.jsx
    RollbackConfirmModal.jsx
    PolicyWarningBanner.jsx
    EmptyStateCard.jsx
    ErrorStateCard.jsx
  hooks/
    useAISession.js
    useAIGeneration.js
    usePatchPlan.js
    usePatchApply.js
    useRunExecution.js
    useAIFix.js
    useSnapshots.js
    useSocketAIEvents.js
  api/
    ai.api.js
  store/
    aiSession.store.js
    patch.store.js
    run.store.js
    snapshot.store.js
    ui.store.js
  utils/
    ai-event-normalizer.js
    diff-utils.js
    error-utils.js
    telemetry-utils.js
  constants/
    ai-status.constants.js
    ai-event.constants.js
  types/
    ai.types.js
```

## 3.2 Existing files likely to update

```text
frontend/src/App.jsx (or main layout)
frontend/src/layout/* (to mount AI panel and tabs)
frontend/src/services/socket.js (or equivalent)
frontend/src/components/terminal/* (optional integration)
frontend/src/router/* (if deep link support for session/workspace needed)
```

---

## 4) Main UX Flows and Task Mapping

## 4.1 Prompt → Generate → Review

- [ ] Add AI panel with Chat and Changes tabs.
- [ ] Build prompt composer (textarea + submit).
- [ ] Add optional constraints drawer:
  - stack
  - package manager
  - TS toggle
  - max files to change
  - locked files (optional MVP)
- [ ] Call `POST /api/ai/generate`.
- [ ] Show generation statuses and progress messages.
- [ ] On completion, open Changes tab with patch summary + file list.
- [ ] Load full patch via `GET /api/ai/patch/:id`.

---

## 4.2 Review → Selective Apply

- [ ] Render changed files list with operation badges (create/update/delete).
- [ ] Render unified diff for selected file.
- [ ] Add select/deselect per file.
- [ ] Add actions:
  - approve all
  - apply selected
  - reject all
- [ ] Call `POST /api/ai/patch/:id/apply`.
- [ ] On success:
  - refresh workspace tree/editor content
  - show success toast
  - append timeline event
- [ ] Handle apply conflict and partial apply UI states.

---

## 4.3 Run → Logs → Fix

- [ ] Add run controls (Build/Test/Dev/custom profile if allowed).
- [ ] Call `POST /api/ai/run`.
- [ ] Stream `ai:run:log` events into console UI.
- [ ] Show command boundaries and statuses.
- [ ] On failure show error summary card + “Fix with AI”.
- [ ] Call `POST /api/ai/fix`.
- [ ] Present fix patch in Changes tab for review/apply.

---

## 4.4 Snapshot → Rollback

- [ ] Add Snapshot History tab/list.
- [ ] Show snapshot labels/time/source action.
- [ ] Add rollback button with confirm modal.
- [ ] Call rollback endpoint.
- [ ] Refresh workspace state and timeline.

---

## 5) Component-Level Breakdown

## 5.1 `AIAssistantPanel.jsx`

Responsibilities:
- host tabs (Chat, Changes, Runs, History)
- display top-level session status
- switch views based on state

Tasks:
- [ ] Build panel shell with tab navigation.
- [ ] Wire stores and hooks.
- [ ] Add loading/empty/error wrappers.

---

## 5.2 `PromptComposer.jsx`

Responsibilities:
- capture prompt text
- constraints controls
- submit/cancel states

Tasks:
- [ ] Enter-to-submit (configurable), Shift+Enter for newline.
- [ ] Disable submit while generating.
- [ ] Show input validation errors.
- [ ] Add “Regenerate” quick action.

---

## 5.3 `GenerationStatusBar.jsx`

Responsibilities:
- render live generation phase and progress

Tasks:
- [ ] Map socket progress stages to UI labels.
- [ ] Show spinner + timestamp + requestId (optional debug tooltip).

---

## 5.4 `AITimeline.jsx`

Responsibilities:
- chronological event feed for AI actions

Tasks:
- [ ] Show event icon, label, time.
- [ ] Group events by request.
- [ ] Handle retries and failures clearly.

---

## 5.5 `PatchReviewPanel.jsx`

Responsibilities:
- central diff review experience

Tasks:
- [ ] Integrate `ChangedFilesList` + `DiffViewer`.
- [ ] Persist selected file and selected paths.
- [ ] Show patch metadata (files changed, risk level, summary).
- [ ] Add apply action bar and confirmation dialog.

---

## 5.6 `DiffViewer.jsx`

Responsibilities:
- render unified diff safely and performantly

Tasks:
- [ ] Support syntax highlighting.
- [ ] Virtualize large diffs.
- [ ] Handle very large files with “collapsed” mode.
- [ ] Escape content to avoid injection.

---

## 5.7 `RunConsolePanel.jsx`

Responsibilities:
- display live logs and command status

Tasks:
- [ ] Merge log chunks in order.
- [ ] Distinguish stdout/stderr visually.
- [ ] Add auto-scroll toggle.
- [ ] Add copy-to-clipboard for error excerpts.
- [ ] Handle reconnect log continuation UX.

---

## 5.8 `RunControls.jsx`

Responsibilities:
- trigger build/test/dev run profiles

Tasks:
- [ ] disable while run active
- [ ] show cancel button if backend supports cancel
- [ ] display policy-denied messages gracefully

---

## 5.9 `SnapshotHistoryPanel.jsx`

Responsibilities:
- list snapshots and execute rollback

Tasks:
- [ ] fetch/list snapshots
- [ ] rollback confirmation modal
- [ ] loading/progress state during rollback
- [ ] post-rollback success/error notification

---

## 6) Store Design Tasks (Zustand-style)

## 6.1 `aiSession.store.js`

State:
- `sessionId`
- `status`
- `activeRequestId`
- `timeline[]`
- `messages[]`

Tasks:
- [ ] add actions for status transitions
- [ ] append timeline events
- [ ] handle reset on workspace switch

---

## 6.2 `patch.store.js`

State:
- `activePatchPlan`
- `files[]`
- `selectedPaths[]`
- `currentFilePath`
- `loading`

Tasks:
- [ ] load patch details
- [ ] toggle file selection
- [ ] select all/deselect all
- [ ] clear after apply/reject

---

## 6.3 `run.store.js`

State:
- `activeRunId`
- `runs[]`
- `logsByRunId`
- `commandStates[]`
- `errorSummary`

Tasks:
- [ ] append logs by sequence
- [ ] mark command start/completion
- [ ] compute run derived states

---

## 6.4 `snapshot.store.js`

State:
- `snapshots[]`
- `rollbackState`

Tasks:
- [ ] set snapshots
- [ ] optimistic rollback status
- [ ] refresh snapshot list post-action

---

## 6.5 `ui.store.js`

State:
- active AI tab
- open modals
- toasts/notifications
- debug mode (optional)

Tasks:
- [ ] centralize UI toggles
- [ ] avoid component-local duplication

---

## 7) API Integration Tasks (`ai.api.js`)

- [ ] `generatePatch(payload)`
- [ ] `getPatchPlan(patchPlanId)`
- [ ] `applyPatch(patchPlanId, payload)`
- [ ] `runCommands(payload)`
- [ ] `fixRun(payload)`
- [ ] `rollbackSnapshot(snapshotId)`
- [ ] uniform error parsing to `ErrorEnvelope`
- [ ] request cancellation support (where useful)

---

## 8) Socket Handling Tasks (`useSocketAIEvents.js`)

- [ ] connect to `/ai` namespace
- [ ] subscribe to session room
- [ ] map all events to store updates:
  - generation events
  - apply events
  - run events
  - fix events
  - rollback events
- [ ] sequence-based stale event rejection
- [ ] reconnect handling:
  - request sync
  - restore active loading states

---

## 9) UX State Coverage Checklist

- [ ] Idle (no AI action yet)
- [ ] Generating in progress
- [ ] Patch ready for review
- [ ] Applying in progress
- [ ] Run in progress
- [ ] Run failed (with fix CTA)
- [ ] Fix in progress
- [ ] Error state with retry guidance
- [ ] Policy blocked state with clear reason
- [ ] Reconnect in progress state

---

## 10) Notifications and Feedback

- [ ] Toasts for:
  - generation ready
  - apply success/fail
  - run success/fail
  - fix patch ready
  - rollback success/fail
- [ ] Inline banners for policy violations
- [ ] persistent error cards for retryable failures

---

## 11) Performance Tasks

- [ ] Virtualize changed-file lists.
- [ ] Virtualize large log streams.
- [ ] Debounce expensive UI filters/search.
- [ ] Memoize diff rendering where possible.
- [ ] Batch high-frequency socket updates.
- [ ] Avoid rerendering Monaco/editor unnecessarily.

---

## 12) Accessibility Tasks

- [ ] keyboard navigation for tabs and file list
- [ ] ARIA labels for action buttons
- [ ] focus trap for modals
- [ ] visible focus indicators
- [ ] status announcements (live regions) for long-running operations

---

## 13) Security Tasks (Frontend)

- [ ] never store provider keys in client
- [ ] escape untrusted content in logs/messages/diffs
- [ ] do not trust client-side path/command validation as authoritative
- [ ] sanitize markdown/HTML display (if message rendering added)

---

## 14) Telemetry Tasks (Frontend)

Track events:
- [ ] `ai_prompt_submitted`
- [ ] `ai_generation_ready_viewed`
- [ ] `ai_patch_apply_clicked`
- [ ] `ai_patch_apply_succeeded`
- [ ] `ai_run_started`
- [ ] `ai_run_failed`
- [ ] `ai_fix_requested`
- [ ] `ai_rollback_triggered`

Attach dimensions:
- workspace/session/request IDs
- patch size
- elapsed durations
- failure codes (if any)

---

## 15) Frontend Test Plan

## Unit tests
- [ ] stores actions/reducers behavior
- [ ] event normalizer
- [ ] error mapper utilities

## Component tests
- [ ] PromptComposer interactions
- [ ] PatchReview selection logic
- [ ] RunConsole incremental log rendering
- [ ] Rollback modal flow

## Integration tests
- [ ] generate -> view patch -> apply
- [ ] run -> fail -> fix flow
- [ ] socket reconnect and state recovery

## E2E tests
- [ ] happy path full loop
- [ ] policy-denied UX
- [ ] apply conflict UX

---

## 16) Suggested Sprint Mapping

## Sprint 1
- AI panel shell + stores + API client scaffolding
- socket hook foundation
- basic prompt submit

## Sprint 2
- generation progress + patch review UI
- diff viewer + selection + apply action

## Sprint 3
- run controls + live log console
- run status and failure cards

## Sprint 4
- fix flow UI
- snapshot history + rollback
- error/policy states hardening

## Sprint 5
- performance pass
- accessibility pass
- telemetry + test stabilization

---

## 17) Frontend Definition of Done

Frontend MVP done when:

1. User can submit prompt and see generation progress.
2. User can review diffs and selectively apply files.
3. User can run commands and view live logs.
4. User can trigger fix flow after failures.
5. User can rollback from snapshot history.
6. UX includes clear handling for loading, errors, policy denials, reconnects.
7. Core telemetry events are emitted.