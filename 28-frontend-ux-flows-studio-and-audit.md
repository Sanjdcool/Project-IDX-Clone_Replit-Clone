# 28 — Frontend UX Flows: Studio and Audit

## 1) Purpose

Define frontend UX and interaction flows for three modes:

1. **Migrate My Site** (ownership-gated)
2. **Recreate Design (Layout Only)** (URL/screenshot input)
3. **Competitive Audit (Read-Only)**

This spec is focused on implementation: screens, components, state transitions, events, and edge cases.

---

## 2) UX Principles

1. **Mode clarity**: users must always know which mode they are in.
2. **Safe by default**: UI defaults to compliant options.
3. **Progress transparency**: long jobs show clear phased progress.
4. **Review-first**: generated code changes always pass through diff review.
5. **Actionable outputs**: audit mode emphasizes insights, not cloning.

---

## 3) Navigation and Entry Points

## 3.1 Primary entry
Add a new top-level workspace module:
- **“Site Studio”**

Tabs inside Site Studio:
1. Migration
2. Recreation
3. Audit
4. History (all jobs)

## 3.2 Deep links
Support route patterns:
- `/studio/migration`
- `/studio/recreation`
- `/studio/audit`
- `/studio/jobs/:jobId`

---

## 4) Shared UX Building Blocks

1. **Mode Header Banner**
   - mode name + policy reminder
2. **Job Progress Timeline**
   - intake → verification → crawl → extraction → generation/audit
3. **Artifacts Panel**
   - summaries, reports, previews
4. **Policy Notice Card**
   - allowed/blocked actions per mode
5. **Error Resolution Card**
   - clear reason + next action

---

## 5) Flow A — Migration (Owned Site)

## 5.1 Step A1: Setup Screen
Fields:
- target URL
- workspace/project selection
- optional crawl settings (advanced accordion)

CTA:
- `Start Ownership Verification`

Validation:
- URL format
- supported protocol
- no obvious blocked hosts

## 5.2 Step A2: Ownership Verification Screen
Show 3 verification methods:
1. DNS TXT
2. HTML file
3. Meta tag

User action:
- choose method
- copy token instructions
- click `Verify Now`

States:
- pending
- verified
- failed
- expired

## 5.3 Step A3: Start Migration Job
When verified:
- `Start Migration Crawl` button enabled

Display:
- mode constraints summary
- legal attestation checkbox (if required per policy)

## 5.4 Step A4: Crawl & Extraction Progress
Real-time phase updates:
- pages discovered/processed
- duration
- failures and retry counters

UI features:
- collapsible logs
- pause/cancel controls
- partial preview when available

## 5.5 Step A5: Extraction Preview
Panels:
- detected page templates
- component inventory
- token preview (colors/type/spacing)
- low-confidence mapping warnings

CTA:
- `Generate Scaffold`

## 5.6 Step A6: Scaffold Review and Apply
Reuse existing patch review UI:
- file tree and diffs
- selective apply controls
- snapshot notice

CTA:
- `Apply Selected`

## 5.7 Step A7: Validate Build
Offer immediate:
- run build/test in sandbox
- show logs
- one-click fix loop entry if needed

---

## 6) Flow B — Design Recreation (Layout Only)

## 6.1 Step B1: Input Mode Selector
Options:
- URL input
- Screenshot upload

If screenshot:
- support multi-image upload
- drag-drop ordering
- label each image (homepage, section, mobile view, etc.)

## 6.2 Step B2: Recreation Settings
Fields:
- target stack
- style fidelity preference
- content mode (placeholder/rewrite/mixed)
- route strategy (single page vs inferred multipage)

Default:
- placeholder mode

## 6.3 Step B3: Run Recreation Job
Progress phases:
- intake
- crawl/visual analysis
- extraction
- mapping
- generation

## 6.4 Step B4: Layout Mapping Review
Show:
- section-by-section component mapping
- confidence badges
- manual override dropdown per section
- live mini-preview

CTA:
- `Regenerate with Adjustments`

## 6.5 Step B5: Diff and Apply
Same shared diff/apply UX as migration.

---

## 7) Flow C — Competitive Audit (Read-Only)

## 7.1 Step C1: Audit Setup
Fields:
- competitor URL(s)
- optional baseline URL (user site) for comparison
- depth/page limits (preset levels)

## 7.2 Step C2: Run Audit
Progress:
- crawl
- analysis
- scoring
- recommendations

## 7.3 Step C3: Audit Dashboard
Sections:
1. Structure score
2. Performance score
3. SEO score
4. Component complexity summary
5. Findings list by severity
6. Action recommendations

## 7.4 Step C4: Export Report
Allowed exports:
- JSON report
- PDF summary

Explicit note:
- “Read-only mode: no clone/export bundle available.”

---

## 8) Job History UX

## 8.1 Jobs list
Columns:
- job ID
- mode
- target
- status
- created by
- created at
- last updated
- quick actions

Filters:
- mode
- status
- date range
- workspace

## 8.2 Job detail
- phase timeline
- artifacts
- logs
- policy events
- retry/cancel actions (if valid)

---

## 9) State Management Design

## 9.1 Stores (suggested)
1. `studioMode.store`
2. `verification.store`
3. `siteJob.store`
4. `mappingReview.store`
5. `auditReport.store`
6. `studioUi.store`

## 9.2 Core state fields
- activeMode
- currentJobId
- phase/status/progress
- artifacts
- warnings/errors
- manual mapping adjustments
- export availability

---

## 10) API Integration Points

Frontend consumes endpoints from file 27:

- verification start/confirm
- create job
- get job status
- cancel job
- crawl summary
- extraction summary
- regenerate
- mapping adjust
- audit report
- list exports/download link

Polling or socket strategy:
- poll status endpoint initially (MVP)
- optional real-time sockets in later phase

---

## 11) UX for Policy and Guardrails

## 11.1 Mode badges
Persistent visual indicator:
- `Migration (Verified)`
- `Recreation (Layout Only)`
- `Audit (Read-Only)`

## 11.2 Guardrail messaging
Examples:
- “Ownership verification required to continue.”
- “This mode cannot export clone artifacts.”
- “Low-confidence mappings need your review.”

## 11.3 Denial handling
On policy error:
- show concise reason
- show remediation action
- deep link to policy details/help

---

## 12) Error and Edge Case UX

1. Verification token expired
   - show `Regenerate Token`

2. Crawl blocked/partial
   - show partial coverage and retry controls

3. Extraction low confidence
   - auto-open mapping review mode

4. Generation failed
   - show failure stage + retry option

5. Export blocked by policy
   - hide disallowed export options and explain why

---

## 13) Accessibility Requirements

- keyboard navigation across all step panels
- aria labels for status and controls
- live region updates for long-running phase changes
- color + icon redundancy for confidence/status badges
- modal focus trap and accessible close actions

---

## 14) Performance UX Requirements

1. Incremental rendering for large findings lists.
2. Virtualized job log viewer.
3. Lazy-load deep artifact details.
4. Debounced search/filters on history list.
5. Optimistic UI for non-destructive toggles.

---

## 15) Analytics & Telemetry Events

Track:
- `studio_mode_selected`
- `verification_started`
- `verification_succeeded`
- `site_job_created`
- `site_job_canceled`
- `extraction_preview_opened`
- `mapping_adjusted`
- `scaffold_generated`
- `patch_apply_from_studio`
- `audit_report_viewed`
- `audit_report_exported`

Include:
- mode
- workspaceId
- jobId
- duration to milestone
- success/failure code

---

## 16) UI Components to Build

1. `StudioModeSwitcher`
2. `VerificationMethodCard`
3. `VerificationStatusPanel`
4. `SiteJobProgressTimeline`
5. `CrawlCoveragePanel`
6. `ExtractionPreviewPanel`
7. `MappingReviewGrid`
8. `TokenPreviewCard`
9. `AuditScoreDashboard`
10. `FindingsTable`
11. `ExportArtifactsPanel`
12. `PolicyGuardrailBanner`
13. `JobHistoryTable`
14. `JobDetailsDrawer`

---

## 17) Suggested Folder Structure

```text
frontend/src/features/site-studio/
  components/
    StudioModeSwitcher.jsx
    VerificationMethodCard.jsx
    SiteJobProgressTimeline.jsx
    ExtractionPreviewPanel.jsx
    MappingReviewGrid.jsx
    AuditScoreDashboard.jsx
    FindingsTable.jsx
    ExportArtifactsPanel.jsx
    ...
  hooks/
    useVerification.js
    useSiteJobs.js
    useExtractionSummary.js
    useRegeneration.js
    useAuditReport.js
  api/
    siteStudio.api.js
  store/
    studioMode.store.js
    verification.store.js
    siteJob.store.js
    mappingReview.store.js
    auditReport.store.js
  utils/
    confidence-utils.js
    policy-message-utils.js
```

---

## 18) Acceptance Criteria

- User can complete migration flow from verification to apply.
- Recreation flow supports URL and screenshot entry paths.
- Audit flow shows scores/findings and exports report.
- Mode-specific restrictions are clear and enforced in UI.
- Job history and details are discoverable and filterable.
- Low-confidence mappings are editable and regenerable.
- All major state transitions surface meaningful user feedback.

---

## 19) Open UX Decisions

1. Wizard-style single flow vs tabbed independent flow per mode?
2. Should mapping review include live side-by-side preview in MVP?
3. Polling interval defaults vs adaptive polling?
4. How much advanced crawl config is exposed in MVP UI?
5. Should audit findings include “quick apply suggestion” links into recreation flow?