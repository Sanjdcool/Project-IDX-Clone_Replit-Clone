# 35 — Competitive Audit (Read-Only) Specification

## 1) Purpose

Define the full specification for **Competitive Audit (Read-Only)** mode:

- analyze structure, speed, SEO, and component patterns,
- compare target(s) against baseline site (optional),
- provide actionable recommendations,
- explicitly prevent clone/export pathways.

---

## 2) Feature Definition

Competitive Audit is a read-only analysis workflow that evaluates public website characteristics and returns benchmarking insights, without producing site clone bundles or code-rebuild artifacts.

---

## 3) Objectives

1. Deliver clear competitive intelligence for product, SEO, and UX teams.
2. Surface prioritized opportunities (quick wins vs strategic fixes).
3. Provide consistent scoring methodology and traceable findings.
4. Ensure strict read-only policy enforcement.

---

## 4) Scope

## In scope
- URL-based crawl of public pages
- structure/IA analysis
- performance diagnostics (observable page-level metrics)
- SEO metadata/schema checks
- component/pattern inventory
- report generation/export (JSON/PDF)

## Out of scope
- scaffold/code generation
- raw clone package export
- private/authenticated content analysis in MVP
- legal interpretation advice

---

## 5) Input Model

## Required
- target competitor URL (single in MVP baseline; optional multi-target extension)

## Optional
- baseline URL (your own site) for side-by-side comparison
- crawl budget profile (small/medium/deep)
- focus areas:
  - structure
  - performance
  - SEO
  - components/accessibility

---

## 6) Output Model

## 6.1 Executive Summary
- overall scorecard
- top strengths
- top weaknesses
- priority recommendations

## 6.2 Detailed Sections
1. Site structure & information architecture
2. Performance snapshot
3. SEO & metadata health
4. Component and UX pattern inventory
5. Risk/opportunity matrix
6. Action plan by priority

## 6.3 Export Formats
- JSON (machine-readable)
- PDF (stakeholder-ready)

No clone/code/raw content export classes allowed.

---

## 7) Audit Dimensions and Scoring

## 7.1 Structure Score
Evaluate:
- navigation depth
- page template consistency
- internal link clarity
- content hierarchy quality

## 7.2 Performance Score
Evaluate:
- load timing proxies (where measurable)
- page weight/resource mix
- render bottlenecks (high-level)
- asset optimization indicators

## 7.3 SEO Score
Evaluate:
- title/meta quality/uniqueness
- heading structure
- canonical and indexability signals
- schema presence/quality
- image alt usage baseline

## 7.4 Component Complexity Score
Evaluate:
- component diversity
- repeated reusable patterns
- consistency of UI blocks
- probable maintainability complexity

---

## 8) Findings Model

Each finding must include:
- `severity` (info/low/medium/high/critical)
- `category` (structure/performance/seo/accessibility/components)
- `title`
- `description`
- `evidence` (page refs/metrics)
- `recommendation`
- `effortEstimate` (S/M/L)
- `impactEstimate` (S/M/L)

---

## 9) Recommendation Framework

## 9.1 Priority buckets
1. Quick wins (high impact, low effort)
2. Medium-term improvements
3. Strategic architecture improvements

## 9.2 Recommendation template
- problem summary
- observed evidence
- expected benefit
- implementation direction
- validation method

---

## 10) Baseline Comparison Logic (Optional)

When baseline URL provided:
- compute target vs baseline deltas for each score dimension
- highlight:
  - where baseline outperforms target
  - where target outperforms baseline
- produce “adopt/avoid” pattern suggestions

---

## 11) Crawl and Analysis Constraints (Audit Mode)

1. honor read-only mode restrictions.
2. no codegen/regeneration path.
3. no raw content bundle export.
4. restricted artifact class (`report_only`).
5. budget limits by plan and job settings.

---

## 12) UI Flow for Audit Mode

1. audit setup form
2. run audit job
3. phase timeline/progress
4. summary dashboard
5. findings explorer (filter/sort)
6. recommendations action list
7. export panel (JSON/PDF)

---

## 13) Dashboard Requirements

## 13.1 Top cards
- structure score
- performance score
- SEO score
- component complexity score

## 13.2 Findings table
Filters:
- severity
- category
- page path
- effort/impact

## 13.3 Visuals
- score radar/stacked bars
- category trend bars (if repeated runs)
- top-page issue concentration chart

---

## 14) Re-run and Trend Support

Store prior audit reports to enable:
- historical comparison by domain
- trend lines for repeated audits
- regression detection (score drops)

---

## 15) Policy Enforcement (Critical)

Audit mode must enforce:
1. `generation` endpoints disabled for audit jobs.
2. clone/scaffold export classes blocked.
3. any restricted export request returns policy-denied response.
4. explicit read-only indicator in UI and API payloads.

---

## 16) Data Handling and Privacy

1. store only necessary analysis artifacts.
2. avoid unnecessary long-form content retention.
3. redact sensitive query tokens in logs.
4. apply retention windows for audit artifacts.
5. secure report downloads with signed URLs.

---

## 17) Observability Events (Audit)

Emit:
- audit_job_created
- audit_crawl_completed
- audit_analysis_completed
- audit_report_ready
- audit_finding_viewed
- audit_export_requested
- audit_export_blocked (if policy denied)

---

## 18) API Contract Alignment

Must align to OpenAPI file:
- create site job with `audit_readonly`
- get job status
- get audit report
- list exports
- create download link (only allowed report types)

---

## 19) QA Acceptance Criteria

- audit job runs end-to-end and reaches `report_ready`.
- scorecards render with populated findings.
- export JSON/PDF works through signed URL flow.
- restricted export types are blocked in audit mode.
- baseline comparison works when optional baseline URL is provided.
- findings contain actionable recommendation fields.

---

## 20) Performance and Reliability Targets

1. first meaningful summary available early (progressive readiness preferred).
2. full report generation within target SLA for small/medium scope.
3. stable behavior under concurrent audit jobs.
4. graceful partial reporting if some pages fail crawl.

---

## 21) Risks and Mitigations

1. **Score interpretability risk**
   - mitigation: transparent scoring factors and evidence links.

2. **False confidence in recommendations**
   - mitigation: include confidence/coverage indicators.

3. **Mode misuse expectations**
   - mitigation: repeated read-only messaging + blocked paths.

4. **Incomplete crawl coverage**
   - mitigation: surface coverage ratio prominently in report.

---

## 22) Open Decisions

1. Should multi-competitor comparison launch in MVP or beta?
2. How many pages should default audit budget include?
3. Do we expose raw metric formulas in UI or only in export metadata?
4. Should recommendations include estimated business impact values?
5. How frequently should trend snapshots be retained for historical comparisons?