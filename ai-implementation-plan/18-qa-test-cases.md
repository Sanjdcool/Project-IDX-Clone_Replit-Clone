# 18 — QA Test Cases

## 1) Purpose

Detailed test suite for the AI app-generation MVP, covering:
- functional behavior,
- safety policies,
- runtime execution,
- fix loop,
- observability,
- reliability and recovery.

This file includes test IDs for manual/automation tracking in QA tools.

---

## 2) Test Metadata Standard

For each test:
- **Test ID**
- **Priority**: P0/P1/P2
- **Type**: Functional / Security / Reliability / Performance / UX
- **Preconditions**
- **Steps**
- **Expected Result**
- **Automation Candidate**: Yes/No

---

## 3) Core Functional Tests (P0)

## TC-FUNC-001 — Generate patch plan from valid prompt
- **Priority:** P0
- **Type:** Functional
- **Preconditions:**
  - User authenticated
  - Workspace exists and accessible
- **Steps:**
  1. Open AI panel
  2. Enter prompt: “Create a React todo app with login.”
  3. Submit generation
- **Expected Result:**
  - Generation starts and progress events appear
  - Patch plan returned with summary and files changed > 0
  - Changes tab shows file list
- **Automation Candidate:** Yes

---

## TC-FUNC-002 — Generate with constraints
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Same as above
- **Steps:**
  1. Enter prompt
  2. Set constraints: stack=react-node, typescript=true, maxFilesToChange=20
  3. Submit
- **Expected Result:**
  - Response respects constraints
  - Operation count <= maxFilesToChange
- **Automation Candidate:** Yes

---

## TC-FUNC-003 — Fetch patch details endpoint
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Existing patch plan ID
- **Steps:**
  1. Call `GET /api/ai/patch/:patchPlanId`
- **Expected Result:**
  - Returns operations and unified diffs
  - Includes summary and metadata
- **Automation Candidate:** Yes

---

## TC-FUNC-004 — Selective apply approved files only
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Patch with >= 3 changed files
- **Steps:**
  1. Select 2 files
  2. Apply selected
- **Expected Result:**
  - Only selected files are modified
  - Rejected/unselected files unchanged
- **Automation Candidate:** Yes

---

## TC-FUNC-005 — Approve all apply path
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Patch ready
- **Steps:**
  1. Click approve/apply all
- **Expected Result:**
  - All patch operations applied (subject to policy)
  - Apply result status is `applied` or `partial` with details
- **Automation Candidate:** Yes

---

## TC-FUNC-006 — Snapshot creation before apply
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** `createSnapshot=true`
- **Steps:**
  1. Apply patch
  2. Open snapshot history
- **Expected Result:**
  - New snapshot entry created with reason `before_apply`
- **Automation Candidate:** Yes

---

## TC-FUNC-007 — Rollback to snapshot
- **Priority:** P0
- **Type:** Functional
- **Preconditions:**
  - At least one snapshot exists
  - Workspace changed after snapshot
- **Steps:**
  1. Trigger rollback for snapshot
- **Expected Result:**
  - Workspace restored to previous snapshot state
  - Rollback event appears in timeline
- **Automation Candidate:** Yes

---

## TC-FUNC-008 — Start run and receive logs
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Buildable project state
- **Steps:**
  1. Click run build profile
- **Expected Result:**
  - `runId` returned
  - `ai:run:log` events stream to UI
  - Run completion status shown
- **Automation Candidate:** Yes

---

## TC-FUNC-009 — Failed run shows error summary
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Intentionally broken code
- **Steps:**
  1. Run build
- **Expected Result:**
  - Run status = failed
  - Error summary populated and visible
  - “Fix with AI” action available
- **Automation Candidate:** Yes

---

## TC-FUNC-010 — Fix with AI produces patch plan
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Failed run exists
- **Steps:**
  1. Click “Fix with AI”
- **Expected Result:**
  - Fix generation starts
  - New patch plan returned
  - Changes tab opens with fix diff
- **Automation Candidate:** Yes

---

## TC-FUNC-011 — Fix apply then rerun success (happy path)
- **Priority:** P0
- **Type:** Functional
- **Preconditions:** Fix patch generated
- **Steps:**
  1. Apply fix patch
  2. Re-run build
- **Expected Result:**
  - Build succeeds in common scenario
- **Automation Candidate:** Yes

---

## 4) API Contract / Validation Tests (P0/P1)

## TC-API-001 — Missing required generate fields
- **Priority:** P0
- **Type:** Functional
- **Steps:** Call generate without `workspaceId` or `prompt`
- **Expected Result:** 400 with standardized error envelope
- **Automation Candidate:** Yes

## TC-API-002 — Invalid enum in constraints
- **Priority:** P1
- **Type:** Functional
- **Steps:** Send invalid `packageManager`
- **Expected Result:** 400 schema validation error
- **Automation Candidate:** Yes

## TC-API-003 — Invalid patchPlanId fetch
- **Priority:** P1
- **Type:** Functional
- **Steps:** Call GET patch with nonexistent ID
- **Expected Result:** 404 with error code
- **Automation Candidate:** Yes

## TC-API-004 — Apply with path not in patch
- **Priority:** P0
- **Type:** Functional/Security
- **Steps:** Send approved path absent from patch plan
- **Expected Result:** 400/422 rejection
- **Automation Candidate:** Yes

---

## 5) Security and Policy Tests (P0)

## TC-SEC-001 — Path traversal blocked
- **Priority:** P0
- **Type:** Security
- **Preconditions:** Patch includes `../../etc/passwd` path attempt
- **Steps:** Attempt apply
- **Expected Result:** Policy block, no file write
- **Automation Candidate:** Yes

## TC-SEC-002 — Absolute out-of-root path blocked
- **Priority:** P0
- **Type:** Security
- **Steps:** Attempt operation on `/root/.ssh/id_rsa`
- **Expected Result:** Blocked by path policy
- **Automation Candidate:** Yes

## TC-SEC-003 — Protected file edit blocked/gated
- **Priority:** P0
- **Type:** Security
- **Steps:** Attempt edit on `.env`
- **Expected Result:** Blocked or explicit high-risk gate behavior
- **Automation Candidate:** Yes

## TC-SEC-004 — Disallowed command blocked
- **Priority:** P0
- **Type:** Security
- **Steps:** Submit run command `curl x | bash`
- **Expected Result:** 422 policy blocked
- **Automation Candidate:** Yes

## TC-SEC-005 — Unauthorized workspace access denied
- **Priority:** P0
- **Type:** Security
- **Preconditions:** User A token, User B workspace
- **Steps:** Call any AI endpoint for User B workspace
- **Expected Result:** 403 forbidden
- **Automation Candidate:** Yes

## TC-SEC-006 — Rate limit enforced
- **Priority:** P1
- **Type:** Security/Reliability
- **Steps:** Burst generate requests beyond quota
- **Expected Result:** 429 responses with retry guidance
- **Automation Candidate:** Yes

## TC-SEC-007 — Secret redaction in logs
- **Priority:** P0
- **Type:** Security
- **Steps:** Trigger logs containing token-like string
- **Expected Result:** Stored/displayed logs are redacted
- **Automation Candidate:** Partial

---

## 6) Reliability and Recovery Tests (P0/P1)

## TC-REL-001 — Provider timeout handling
- **Priority:** P0
- **Type:** Reliability
- **Steps:** Simulate provider timeout during generate
- **Expected Result:** Graceful failure, retryable error code, no crash
- **Automation Candidate:** Yes

## TC-REL-002 — Invalid model JSON repair pass
- **Priority:** P0
- **Type:** Reliability
- **Steps:** Simulate malformed JSON output
- **Expected Result:** Single repair attempt; if still invalid, deterministic failure code
- **Automation Candidate:** Yes

## TC-REL-003 — Apply lock conflict
- **Priority:** P1
- **Type:** Reliability
- **Steps:** Trigger two apply requests simultaneously for same workspace
- **Expected Result:** One succeeds, one gets conflict/lock error
- **Automation Candidate:** Yes

## TC-REL-004 — Container crash mid-run
- **Priority:** P0
- **Type:** Reliability
- **Steps:** Kill container during command
- **Expected Result:** Run marked infra_error; subsequent run recreates container
- **Automation Candidate:** Yes

## TC-REL-005 — Socket disconnect and reconnect
- **Priority:** P1
- **Type:** Reliability/UX
- **Steps:** Disconnect client during active run, reconnect
- **Expected Result:** UI resyncs state and resumes logs/status context
- **Automation Candidate:** Yes

## TC-REL-006 — Idempotent retry on generate/apply
- **Priority:** P1
- **Type:** Reliability
- **Steps:** Retry same mutating request with same idempotency key
- **Expected Result:** Safe replay/no duplicate side effects
- **Automation Candidate:** Yes

---

## 7) Performance Tests (P1)

## TC-PERF-001 — Generation latency under load
- **Priority:** P1
- **Type:** Performance
- **Steps:** Run concurrent generate requests at target throughput
- **Expected Result:** p95 latency remains within agreed SLO threshold
- **Automation Candidate:** Yes

## TC-PERF-002 — Diff rendering large patch
- **Priority:** P1
- **Type:** Performance/UX
- **Preconditions:** Patch with ~200 files
- **Steps:** Open changes tab and switch files rapidly
- **Expected Result:** UI responsive with no severe jank/crash
- **Automation Candidate:** Partial

## TC-PERF-003 — Log streaming high volume
- **Priority:** P1
- **Type:** Performance
- **Steps:** Run noisy command output (large logs)
- **Expected Result:** Console remains usable; chunks processed in order
- **Automation Candidate:** Yes

---

## 8) UX and Accessibility Tests (P1/P2)

## TC-UX-001 — Keyboard-only patch review
- **Priority:** P1
- **Type:** UX/Accessibility
- **Steps:** Navigate tabs/files/apply actions via keyboard only
- **Expected Result:** All primary actions accessible without mouse
- **Automation Candidate:** Partial

## TC-UX-002 — Error message clarity
- **Priority:** P1
- **Type:** UX
- **Steps:** Trigger schema error, policy block, provider error
- **Expected Result:** User sees actionable messages with retry/next steps
- **Automation Candidate:** Partial

## TC-UX-003 — Loading and empty states
- **Priority:** P2
- **Type:** UX
- **Steps:** New session with no patch/run history
- **Expected Result:** Helpful empty states and no broken UI sections
- **Automation Candidate:** Yes

---

## 9) Observability and Audit Tests (P0/P1)

## TC-OBS-001 — Required trace fields present
- **Priority:** P0
- **Type:** Observability
- **Steps:** Execute full generate→apply→run flow
- **Expected Result:** logs include traceId/requestId/sessionId/workspaceId
- **Automation Candidate:** Yes

## TC-OBS-002 — Metrics emitted for core phases
- **Priority:** P1
- **Type:** Observability
- **Steps:** Run multiple flows with success/failure
- **Expected Result:** counters/histograms updated for each phase
- **Automation Candidate:** Yes

## TC-OBS-003 — Audit trail completeness
- **Priority:** P0
- **Type:** Security/Observability
- **Steps:** Generate, apply, run, fix, rollback
- **Expected Result:** Audit events exist for all critical actions
- **Automation Candidate:** Yes

---

## 10) End-to-End Scenario Tests (P0)

## TC-E2E-001 — Happy path app generation
- **Priority:** P0
- **Type:** E2E
- **Steps:**
  1. Prompt for simple app
  2. Review and apply all
  3. Run build
- **Expected Result:** Build succeeds, timeline complete
- **Automation Candidate:** Yes

## TC-E2E-002 — Failure then AI fix to green
- **Priority:** P0
- **Type:** E2E
- **Steps:**
  1. Generate app
  2. Trigger failing run
  3. Fix with AI
  4. Apply fix
  5. Re-run
- **Expected Result:** Re-run succeeds in known-fix scenario
- **Automation Candidate:** Yes

## TC-E2E-003 — Unsafe operation blocked end-to-end
- **Priority:** P0
- **Type:** E2E/Security
- **Steps:**
  1. Attempt disallowed command or path
- **Expected Result:** Blocked by policy and clearly communicated in UI
- **Automation Candidate:** Yes

---

## 11) Regression Suite (Run Every Release Candidate)

Must-run tests before beta/public rollouts:
- TC-FUNC-001, 004, 006, 008, 010
- TC-SEC-001, 004, 005, 007
- TC-REL-001, 002, 004
- TC-OBS-001, 003
- TC-E2E-001, 002, 003

---

## 12) Environment Matrix

Run selected suite across:

1. **Local dev**
2. **Staging**
3. **Pre-prod (if available)**

And profiles:
- small workspace
- medium workspace
- large workspace (stress)

---

## 13) Defect Severity Guide

- **S0 Critical:** security bypass, data corruption, rollback failure
- **S1 High:** core flow broken (generate/apply/run/fix unusable)
- **S2 Medium:** degraded UX, partial feature failure
- **S3 Low:** cosmetic/minor usability issue

---

## 14) Exit Criteria for QA Sign-off

QA sign-off only when:
1. All P0 tests pass.
2. No open S0/S1 defects.
3. Security and audit tests pass.
4. E2E happy path and fix path both stable.
5. Regression suite pass rate meets release standard.

---

## 15) Execution Tracking Template

Use this table in your test management tool:

| Test ID | Owner | Env | Last Run | Result | Bug Link | Notes |
|---|---|---|---|---|---|---|
| TC-FUNC-001 |  |  |  |  |  |  |
| TC-FUNC-002 |  |  |  |  |  |  |
| ... |  |  |  |  |  |  |