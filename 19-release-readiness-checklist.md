# 19 — Release Readiness Checklist (Go / No-Go)

## 1) Purpose

Final gate checklist for promoting the AI app-generation feature through:
- Internal Alpha
- Closed Beta
- Public Beta

Use this document in release review meetings.  
Every checked item should have evidence (link to dashboard, PR, test run, or doc).

---

## 2) Release Stages

- **Stage A:** Internal Alpha
- **Stage B:** Closed Beta
- **Stage C:** Public Beta

---

## 3) Gate Rules

- Any unchecked **Critical** item = **No-Go**
- Any open **S0/S1** defect = **No-Go**
- Any unknown status for security controls = **No-Go**
- All sign-off roles required before Stage C

---

## 4) Core Functional Readiness

## 4.1 Prompt → Patch
- [ ] **Critical** User can submit prompt and receive structured patch plan.
- [ ] Patch plan includes summary + operations + diff metadata.
- [ ] Invalid model output is handled gracefully (no crash).

**Evidence:**
- Link:
- Notes:

## 4.2 Diff Review + Selective Apply
- [ ] **Critical** User can inspect per-file diffs.
- [ ] **Critical** User can apply selected files only.
- [ ] Apply result states (`applied/partial/failed`) shown correctly.

**Evidence:**
- Link:
- Notes:

## 4.3 Snapshot + Rollback
- [ ] **Critical** Snapshot is created before apply.
- [ ] **Critical** Rollback restores previous workspace state.
- [ ] Rollback failures return deterministic errors.

**Evidence:**
- Link:
- Notes:

## 4.4 Run + Logs
- [ ] **Critical** Commands run in sandbox and not on host.
- [ ] **Critical** Live stdout/stderr log streaming works.
- [ ] Run completion status includes exit code + duration.

**Evidence:**
- Link:
- Notes:

## 4.5 Fix Loop
- [ ] **Critical** Failed run can trigger “Fix with AI”.
- [ ] Fix returns targeted patch plan.
- [ ] Fix path integrates with standard review/apply cycle.

**Evidence:**
- Link:
- Notes:

---

## 5) Security and Governance Readiness

## 5.1 AuthN / AuthZ
- [ ] **Critical** All AI endpoints require authentication.
- [ ] **Critical** Workspace ownership checks enforced on all operations.
- [ ] Socket subscriptions enforce authorization.

**Evidence:**
- Link:
- Notes:

## 5.2 Path / Command Policy
- [ ] **Critical** Path traversal attempts blocked.
- [ ] **Critical** Out-of-workspace writes blocked.
- [ ] **Critical** Disallowed command patterns blocked.
- [ ] Protected file/path policy active (e.g., `.env`, `.git`).

**Evidence:**
- Link:
- Notes:

## 5.3 Sandbox Hardening
- [ ] **Critical** Non-root execution.
- [ ] **Critical** No privileged container mode.
- [ ] CPU/memory/timeouts enforced.
- [ ] Idle container cleanup policy active.

**Evidence:**
- Link:
- Notes:

## 5.4 Secrets and Data Handling
- [ ] **Critical** Secret redaction active for logs/prompts.
- [ ] Provider keys only on server-side.
- [ ] Data retention policy documented and applied.

**Evidence:**
- Link:
- Notes:

## 5.5 Auditability
- [ ] **Critical** Audit events emitted for generate/apply/run/fix/rollback.
- [ ] Audit events include actor, workspace/session/request IDs, timestamp.
- [ ] Audit lookup capability validated for incident response.

**Evidence:**
- Link:
- Notes:

---

## 6) Reliability and Resilience Readiness

## 6.1 Error Handling
- [ ] **Critical** Standardized error envelope across all AI endpoints.
- [ ] Retryable vs non-retryable errors clearly flagged.
- [ ] Provider timeout and malformed response scenarios handled safely.

**Evidence:**
- Link:
- Notes:

## 6.2 Concurrency / Idempotency
- [ ] Apply/rollback locking prevents conflicting writes.
- [ ] Idempotency keys supported for mutating operations.
- [ ] Duplicate requests do not create duplicate side effects.

**Evidence:**
- Link:
- Notes:

## 6.3 Recovery
- [ ] Container crash recovery validated.
- [ ] Socket reconnect/resync behavior validated.
- [ ] No data corruption in interrupted flows.

**Evidence:**
- Link:
- Notes:

---

## 7) Observability and Operations Readiness

## 7.1 Metrics
- [ ] **Critical** Metrics emitted for generate/apply/run/fix outcomes.
- [ ] Latency metrics available (p50/p95/p99).
- [ ] Cost/token usage metrics available.

**Evidence:**
- Link:
- Notes:

## 7.2 Dashboards
- [ ] Workflow funnel dashboard ready.
- [ ] Runtime health dashboard ready.
- [ ] Security/policy dashboard ready.
- [ ] Cost dashboard ready.

**Evidence:**
- Link:
- Notes:

## 7.3 Alerting
- [ ] **Critical** Alerts configured for major failure spikes.
- [ ] Security anomaly alerts configured.
- [ ] On-call routing/escalation path confirmed.

**Evidence:**
- Link:
- Notes:

## 7.4 Runbooks
- [ ] **Critical** Provider outage runbook documented.
- [ ] Sandbox instability runbook documented.
- [ ] Security incident runbook documented.
- [ ] Rollback/emergency disable procedure documented.

**Evidence:**
- Link:
- Notes:

---

## 8) Quality and QA Readiness

## 8.1 Test Coverage
- [ ] **Critical** P0 test cases pass (from `18-qa-test-cases.md`).
- [ ] Regression suite passes on release candidate.
- [ ] No open S0/S1 defects.

**Evidence:**
- Link:
- Notes:

## 8.2 E2E Quality
- [ ] **Critical** Happy path E2E passes.
- [ ] **Critical** Failure��Fix→Green E2E passes.
- [ ] Unsafe operation blocked E2E passes.

**Evidence:**
- Link:
- Notes:

## 8.3 Accessibility / UX Baseline
- [ ] Keyboard navigation validated for primary flow.
- [ ] Error messaging actionable and clear.
- [ ] Long-running states and reconnect states understandable.

**Evidence:**
- Link:
- Notes:

---

## 9) Performance and Cost Readiness

## 9.1 Performance
- [ ] Generation latency within agreed threshold.
- [ ] Diff rendering remains responsive for expected patch sizes.
- [ ] Log streaming remains stable under high output.

**Evidence:**
- Link:
- Notes:

## 9.2 Cost Controls
- [ ] Token limits and request quotas active.
- [ ] Cost per successful session monitored.
- [ ] Budget alert thresholds configured.

**Evidence:**
- Link:
- Notes:

---

## 10) Documentation and Support Readiness

- [ ] API contract doc updated.
- [ ] Socket event contract doc updated.
- [ ] Security policy docs updated.
- [ ] Internal support/troubleshooting guide published.
- [ ] User-facing beta guidance (known limitations) published.

**Evidence:**
- Link:
- Notes:

---

## 11) Stage-Specific Exit Criteria

## Stage A — Internal Alpha Go Criteria
- [ ] Core end-to-end flow works (generate/apply/run/fix basic).
- [ ] Critical security controls enabled.
- [ ] Basic telemetry and logs available.
- [ ] Team-only feature flag enabled.

Decision:
- [ ] Go
- [ ] No-Go
- Date:
- Approver:

---

## Stage B — Closed Beta Go Criteria
- [ ] Alpha issues triaged and major blockers fixed.
- [ ] Regression suite stable across consecutive builds.
- [ ] Dashboards and alerts actively monitored.
- [ ] Support process for pilot users in place.

Decision:
- [ ] Go
- [ ] No-Go
- Date:
- Approver:

---

## Stage C — Public Beta Go Criteria
- [ ] **All critical checklist items complete.**
- [ ] No open S0/S1 defects.
- [ ] Security sign-off complete.
- [ ] QA sign-off complete.
- [ ] Product + Engineering + Ops final approval complete.

Decision:
- [ ] Go
- [ ] No-Go
- Date:
- Approver:

---

## 12) Final Sign-Off Matrix

| Role | Name | Status (Approve/Block) | Date | Notes |
|---|---|---|---|---|
| Product Owner |  |  |  |  |
| Engineering Lead |  |  |  |  |
| Backend Lead |  |  |  |  |
| Frontend Lead |  |  |  |  |
| Runtime/DevOps Lead |  |  |  |  |
| Security Lead |  |  |  |  |
| QA Lead |  |  |  |  |
| On-Call Manager |  |  |  |  |

---

## 13) Go / No-Go Summary

- Release Stage:
- Decision:
- Blocking Items (if any):
- Mitigation Plan:
- Target Re-Review Date: