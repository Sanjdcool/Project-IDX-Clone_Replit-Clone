# 39 — Weekly Execution Dashboard Template (PM/EM Operating Doc)

## 1) Purpose

A weekly operating dashboard for PM/EM/Tech Leads to run execution for:

- Migration (verified),
- Design recreation,
- Competitive audit (read-only),

from build through beta/GA.

Use this doc in weekly review meetings and async status updates.

---

## 2) Weekly Snapshot (Top Section)

**Week of:** `YYYY-MM-DD`  
**Reporting period:** `YYYY-MM-DD → YYYY-MM-DD`  
**Release stage:** `Alpha / Closed Beta / Broader Beta / GA Prep`  
**Overall status:** `Green / Yellow / Red`  
**Executive summary (3 bullets max):**
1. 
2. 
3. 

**Top 3 priorities next week:**
1. 
2. 
3. 

---

## 3) KPI Scorecard (Weekly)

| KPI | Target | This Week | Last Week | Trend | Status |
|---|---:|---:|---:|---|---|
| Jobs created (all modes) |  |  |  | ↑/↓/→ | G/Y/R |
| Job completion rate (%) |  |  |  | ↑/↓/→ | G/Y/R |
| Migration completion rate (%) |  |  |  | ↑/↓/→ | G/Y/R |
| Recreation apply rate (%) |  |  |  | ↑/↓/→ | G/Y/R |
| Audit report completion rate (%) |  |  |  | ↑/↓/→ | G/Y/R |
| p95 end-to-end duration (min) |  |  |  | ↑/↓/→ | G/Y/R |
| Policy denial false-negative incidents | 0 |  |  | ↑/↓/→ | G/Y/R |
| Critical security incidents | 0 |  |  | ↑/↓/→ | G/Y/R |
| P0 regression pass rate (%) | 100 |  |  | ↑/↓/→ | G/Y/R |

---

## 4) Delivery Progress by Epic

| Epic | Owner | Planned % | Actual % | Delta | Status | Notes |
|---|---|---:|---:|---:|---|---|
| EPIC-1 Policy/Verification |  |  |  |  | G/Y/R |  |
| EPIC-2 Jobs/API/Data |  |  |  |  | G/Y/R |  |
| EPIC-3 Crawl/Render |  |  |  |  | G/Y/R |  |
| EPIC-4 Extraction |  |  |  |  | G/Y/R |  |
| EPIC-5 Mapping/Codegen |  |  |  |  | G/Y/R |  |
| EPIC-6 Frontend Studio |  |  |  |  | G/Y/R |  |
| EPIC-7 Audit Analytics |  |  |  |  | G/Y/R |  |
| EPIC-8 Permissioning/Flags |  |  |  |  | G/Y/R |  |
| EPIC-9 Security/Abuse |  |  |  |  | G/Y/R |  |
| EPIC-10 Obs/QA/Release |  |  |  |  | G/Y/R |  |

---

## 5) Milestone & Gate Tracker

| Milestone/Gate | Planned Date | Current Forecast | Status | Blocking Issues | Decision |
|---|---|---|---|---|---|
| M1 Secure Foundation Complete |  |  | G/Y/R |  | Go/Hold |
| M2 Migration Alpha Ready |  |  | G/Y/R |  | Go/Hold |
| M3 Recreation Alpha Ready |  |  | G/Y/R |  | Go/Hold |
| M4 Audit Alpha Ready |  |  | G/Y/R |  | Go/Hold |
| M5 Beta Readiness |  |  | G/Y/R |  | Go/Hold |
| GA Readiness |  |  | G/Y/R |  | Go/Hold |

---

## 6) Quality & QA Dashboard

## 6.1 Regression status
| Suite | Pass % | Fail Count | New Failures | Owner | ETA Fix |
|---|---:|---:|---:|---|---|
| P0 Security/Policy |  |  |  |  |  |
| P0 Core E2E |  |  |  |  |  |
| Migration E2E |  |  |  |  |  |
| Recreation E2E |  |  |  |  |  |
| Audit E2E |  |  |  |  |  |
| Reliability/Recovery |  |  |  |  |  |

## 6.2 Defect summary
| Severity | Open | New | Closed | Net | Trend |
|---|---:|---:|---:|---:|---|
| S0 |  |  |  |  | ↑/↓/→ |
| S1 |  |  |  |  | ↑/↓/→ |
| S2 |  |  |  |  | ↑/↓/→ |
| S3 |  |  |  |  | ↑/↓/→ |

---

## 7) Security & Compliance Dashboard

| Metric | Target | This Week | Last Week | Status | Notes |
|---|---:|---:|---:|---|---|
| SSRF blocks detected | n/a |  |  | G/Y/R |  |
| Unauthorized export attempts blocked | 100% |  |  | G/Y/R |  |
| Migration without verification incidents | 0 |  |  | G/Y/R |  |
| Policy decision log completeness | 100% |  |  | G/Y/R |  |
| High-risk anomalies triaged within SLA | 100% |  |  | G/Y/R |  |

**Security review notes:**
- 
- 

---

## 8) Reliability & Performance Dashboard

| Metric | Target | This Week | Last Week | Trend | Status |
|---|---:|---:|---:|---|---|
| Queue depth p95 |  |  |  | ↑/↓/→ | G/Y/R |
| Worker failure rate (%) |  |  |  | ↑/↓/→ | G/Y/R |
| Resume success after worker crash (%) |  |  |  | ↑/↓/→ | G/Y/R |
| Crawl p95 page render time (ms) |  |  |  | ↑/↓/→ | G/Y/R |
| Extraction p95 duration/page (ms) |  |  |  | ↑/↓/→ | G/Y/R |
| Generation p95 duration/job (ms) |  |  |  | ↑/↓/→ | G/Y/R |

---

## 9) Product Usage & User Feedback

| Signal | This Week | Last Week | Trend | Notes |
|---|---:|---:|---|---|
| Active workspaces using Site Studio |  |  | ↑/↓/→ |  |
| Mode usage: Migration (%) |  |  | ↑/↓/→ |  |
| Mode usage: Recreation (%) |  |  | ↑/↓/→ |  |
| Mode usage: Audit (%) |  |  | ↑/↓/→ |  |
| Output thumbs-up rate (%) |  |  | ↑/↓/→ |  |
| Top complaint theme |  |  |  |  |

**Top feedback themes this week:**
1. 
2. 
3. 

---

## 10) Rollout & Feature Flag Status

| Flag | Current State | Cohort | Planned Change | Risk | Owner |
|---|---|---|---|---|---|
| studio_enabled |  |  |  | Low/Med/High |  |
| studio_migration_enabled |  |  |  | Low/Med/High |  |
| studio_recreation_enabled |  |  |  | Low/Med/High |  |
| studio_audit_enabled |  |  |  | Low/Med/High |  |
| studio_screenshot_recreation_enabled |  |  |  | Low/Med/High |  |
| studio_exports_kill |  |  |  | Low/Med/High |  |

**Rollout decision this week:** `Expand / Hold / Roll back`  
**Reason:** 

---

## 11) RAID Log (Risks, Assumptions, Issues, Dependencies)

## Risks
| ID | Risk | Impact | Likelihood | Owner | Mitigation | Status |
|---|---|---|---|---|---|---|
| R-1 |  | High/Med/Low | High/Med/Low |  |  | Open/Closed |

## Assumptions
| ID | Assumption | Owner | Validation Date | Status |
|---|---|---|---|---|
| A-1 |  |  |  | Valid/Invalid |

## Issues
| ID | Issue | Severity | Owner | ETA | Status |
|---|---|---|---|---|---|
| I-1 |  | S0/S1/S2/S3 |  |  | Open/Closed |

## Dependencies
| ID | Dependency | Team | Needed By | Status | Notes |
|---|---|---|---|---|---|
| D-1 |  |  |  | On Track/At Risk |  |

---

## 12) Decisions Needed (Leadership/Stakeholder)

| Decision | Needed By | Options | Recommendation | Owner |
|---|---|---|---|---|
|  |  |  |  |  |

---

## 13) Action Items for Next Week

| Action | Owner | Due Date | Priority | Success Criteria |
|---|---|---|---|---|
|  |  |  | P0/P1/P2 |  |

---

## 14) Meeting Cadence Template

## Weekly Execution Review (60 min)
1. KPI + gate status (10m)
2. Epic progress and blockers (15m)
3. QA/security/reliability review (15m)
4. Rollout/flags decision (10m)
5. Action assignment (10m)

## Daily async update format
- Yesterday:
- Today:
- Blockers:
- Risk level (G/Y/R):

---

## 15) Red/Yellow/Green Definitions (Standardize)

**Green**  
- On track, no gate risks, no unresolved P0/P1 blockers.

**Yellow**  
- At risk on timeline/quality/reliability but recoverable with mitigation.

**Red**  
- Release gate blocked, security/quality threshold missed, or critical issue unresolved.

---

## 16) Copy/Paste Weekly Report Snippet (Slack/Email)

```text
Weekly Site Studio Update (Week of YYYY-MM-DD)

Overall: [Green/Yellow/Red]
Stage: [Alpha/Beta/GA Prep]

Highlights:
1) ...
2) ...
3) ...

Metrics:
- Completion Rate: X% (WoW: +/-%)
- P95 E2E Duration: Xm (WoW: +/-%)
- P0 Regression Pass: X%
- Security Incidents: X

Risks/Blockers:
- ...
- ...

Rollout Decision:
- [Expand/Hold/Rollback], because ...

Top Actions Next Week:
1) ...
2) ...
3) ...
```

---

## 17) Usage Notes

- Update this doc every week before review meeting.
- Keep values comparable week-over-week (same definitions).
- Link to source dashboards, Jira filters, and incident reports in your internal version.
- If status is Yellow/Red, always include explicit recovery plan with owner/date.