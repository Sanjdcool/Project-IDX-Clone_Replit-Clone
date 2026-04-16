# 21 — Feature PRD: Site Migration, Design-to-Template Recreation, and Competitive Audit (Read-Only)

## 1) Purpose

Define product requirements for three related capabilities:

1. **Website Migration & Rebuild** (owned-site workflow)
2. **Design-to-Template Recreation** (layout-only generation from URL/screenshot)
3. **Competitive Audit (Read-Only)** (analysis only, no content export/clone)

This PRD is structured to be implementation-ready and aligned with existing AI plan architecture, security controls, and policy governance.

---

## 2) Problem Statement

Users want to quickly modernize websites and generate new site foundations without manually rebuilding every page. Today they face:

- slow manual migration and redesign workflows,
- fragmented tools for crawling, auditing, and rebuilding,
- unclear legal/safety boundaries when using AI-assisted site analysis.

We need a unified capability that accelerates legitimate workflows while explicitly preventing unsafe/deceptive copying use cases.

---

## 3) Product Goals

## Primary goals
1. Reduce time to create a modern, editable site foundation from days/weeks to hours.
2. Support safe **owned-site migration** and **layout-inspired recreation**.
3. Provide high-quality **read-only competitor audits** for benchmarking.
4. Enforce policy boundaries by design (no one-click third-party full clone/export).
5. Integrate into existing AI panel/session/run/apply architecture.

## Non-goals
- Not a tool for copying third-party sites verbatim.
- Not a tool for bypassing protected content or authentication.
- Not a full visual parity guarantee for dynamic JS applications in MVP.
- Not an autonomous “deploy copied site” workflow.

---

## 4) Personas

1. **Founder / PM**
   - wants fast rebuild of existing business website.
   - values speed and safe governance.

2. **Frontend Developer**
   - wants clean generated scaffold mapped to modern components.
   - needs deterministic output and editable code.

3. **Agency Operator**
   - wants migration acceleration for client-owned properties.
   - needs proof of ownership and audit trail.

4. **SEO/Marketing Analyst**
   - wants competitive structure/speed/SEO comparison.
   - needs read-only insights and recommendations.

---

## 5) Feature Set Overview

## A) Website Migration & Rebuild (Owned Site)
Input:
- URL (primary domain) + ownership verification.

Output:
- crawl snapshot (pages/assets metadata),
- extracted structure + content bundle,
- regenerated project scaffold in target stack,
- review/apply workflow with user approval.

MVP restriction:
- migration allowed only after ownership verification success.

---

## B) Design-to-Template Recreation
Input:
- URL **or** screenshot(s).

Process:
- extract layout patterns only (sections/components/style tokens),
- do not preserve source prose verbatim by default,
- generate fresh code and placeholder or rewritten text.

Output:
- clean starter project with editable components,
- style/theme tokens (spacing, typography, palette).

---

## C) Competitive Audit (Read-Only)
Input:
- one or more competitor URLs.

Output:
- structure report (IA, page types, section patterns),
- performance snapshot (CWV-like indicators where measurable),
- SEO/metadata/schema analysis,
- component/UX pattern inventory,
- recommendations report.

Hard restriction:
- no source content export package,
- no code clone output,
- no direct “rebuild from competitor” shortcut.

---

## 6) User Stories

## Migration
1. As an owner, I can verify domain ownership and run a migration job.
2. I can preview discovered pages/assets before regeneration.
3. I can review generated files and selectively apply them.
4. I can roll back if result is unsatisfactory.

## Design-to-template
5. As a builder, I can submit URL/screenshot and get layout-only scaffold.
6. I can choose target stack (e.g., Next.js + Tailwind).
7. I can choose placeholder mode vs AI-rewrite mode for content.

## Competitive audit
8. As an analyst, I can run read-only audit on competitor URL.
9. I can see speed/SEO/components comparisons vs my site.
10. I can export audit report (PDF/JSON) but not cloned source package.

---

## 7) UX Flow Summary

## Flow 1 — Migration
1. User selects “Migrate My Site”
2. Inputs domain URL
3. Completes ownership verification
4. Starts crawl job
5. Reviews extracted pages/coverage
6. Starts regeneration
7. Reviews diff
8. Applies selected files
9. Runs build/test in sandbox

## Flow 2 — Design Recreation
1. User selects “Recreate Design (Layout Only)”
2. Inputs URL or uploads screenshot(s)
3. Chooses stack + design options
4. AI generates section/component scaffold
5. User reviews and applies
6. Iterates via prompts

## Flow 3 — Competitive Audit
1. User selects “Competitor Audit”
2. Inputs competitor URL(s)
3. Runs read-only crawl/analysis
4. Sees benchmark dashboard + recommendations
5. Exports report

---

## 8) Functional Requirements (FR)

## FR-1 Mode Selection and Guardrails
System must support explicit mode selection:
- `migration_owned_site`
- `design_recreation`
- `competitive_audit_readonly`

Each mode applies distinct policy constraints.

## FR-2 Ownership Verification (Migration only)
System must require proof before crawl/rebuild:
- DNS TXT token, or
- HTML file token, or
- meta tag token.

## FR-3 Crawl and Render
System must crawl target URL within configured bounds:
- robots-aware policy behavior (mode-specific),
- JS-rendered page support,
- depth/page/time limits.

## FR-4 Extraction Pipeline
System must extract:
- page templates/sections,
- navigation structures,
- style tokens (colors/type/spacing),
- assets metadata,
- SEO metadata/schema signals.

## FR-5 Regeneration Pipeline
System must convert extraction output into:
- normalized page/component model,
- target stack code scaffold,
- placeholder/rewritten content options.

## FR-6 Review and Apply
Generated output must pass through existing patch review/apply flow:
- per-file diffs,
- selective apply,
- snapshot + rollback.

## FR-7 Read-Only Audit Mode
Audit mode must produce only analytics artifacts:
- no content/code clone bundle,
- no one-click apply into project.

## FR-8 Reporting
System must support report export:
- JSON for machine use,
- PDF/HTML summary for stakeholders.

## FR-9 Job Control
All long-running jobs must support:
- queued execution,
- progress updates,
- cancellation,
- resumable status retrieval.

## FR-10 Full Audit Trail
System must log who initiated what job, scope, and outputs generated.

---

## 9) Non-Functional Requirements (NFR)

## NFR-1 Security
- SSRF-safe URL fetching
- domain/IP allow-deny protections
- sandboxed render workers

## NFR-2 Compliance/Policy
- mode-gated output restrictions
- ownership proof retention with expiry
- legal-safe defaults

## NFR-3 Performance
- small sites (<100 pages): initial result preview within target SLA
- progressive results rather than all-or-nothing completion

## NFR-4 Reliability
- retry strategy on transient fetch failures
- deterministic job states
- idempotent job start with keys

## NFR-5 Scalability
- distributed workers for crawl/extract/rebuild
- bounded resource usage per job/tenant

## NFR-6 Observability
- full metrics/traces/logging for crawl, extraction, generation, apply.

---

## 10) Policy Boundaries (Product-Level)

## Allowed
- migrate own domain after verification,
- extract layout patterns for recreation,
- run read-only audits on public pages.

## Not allowed
- full third-party clone export with original content/code,
- hidden/authenticated scraping without authorization,
- policy bypass via mode switching hacks.

---

## 11) Success Metrics

## Adoption
- % of users initiating feature flows by mode
- migration completion rate
- recreation generation-to-apply rate

## Efficiency
- median time from input URL to first usable scaffold
- reduction in manual rebuild time (self-reported)

## Quality
- first-build success rate of generated scaffold
- user acceptance score of generated structure

## Safety
- % blocked policy violations correctly detected
- zero critical incidents of unauthorized full-copy export

---

## 12) MVP Scope

## In MVP
- migration with ownership verification
- layout-only recreation from URL
- screenshot-based recreation (single-page focus)
- read-only competitor audit baseline
- existing patch review/apply integration
- baseline report export (JSON)

## Out of MVP
- pixel-perfect multi-breakpoint recreation guarantees
- authenticated area crawling
- full enterprise multi-domain portfolio dashboards
- live automated redeploy pipelines

---

## 13) Risks and Mitigations

1. **Legal misuse risk**
   - Mitigation: strict mode gating + ownership proof + output restrictions.

2. **Poor extraction quality on JS-heavy sites**
   - Mitigation: render fallbacks, partial extraction mode, confidence scoring.

3. **Over-promising fidelity**
   - Mitigation: explicit “recreated scaffold” language, confidence indicators.

4. **Resource-intensive crawls**
   - Mitigation: quotas, depth limits, per-job budget ceilings.

5. **SEO trust issues from regenerated content**
   - Mitigation: placeholder defaults + guided rewrite + attribution metadata controls.

---

## 14) Dependencies

- Crawl/render worker infrastructure
- storage layer for crawl artifacts
- policy/ownership verification service
- AI regeneration provider integration
- frontend workflow extensions
- report generation service

---

## 15) Release Milestones

1. **Alpha**
   - migration + verification on owned domains
   - basic extraction/rebuild review

2. **Beta**
   - design recreation from URL/screenshot
   - competitor read-only audits + dashboards

3. **Public**
   - hardened policies, full observability, scale tuning, report exports

---

## 16) Acceptance Criteria (MVP)

- User can verify domain ownership and start migration.
- System crawls and extracts site structure within configured limits.
- User receives generated scaffold and can selectively apply files.
- Design recreation mode outputs layout-focused fresh scaffold.
- Competitive audit mode returns insights without clone/export artifacts.
- All operations are logged with request/session/user metadata.
- Policy violations are blocked with clear error reasons.

---

## 17) Open Questions

1. Which ownership methods are mandatory vs optional for MVP?
2. Should screenshot recreation allow multi-screenshot “flow stitching” in MVP?
3. Should audit mode permit limited HTML snapshot view or only normalized report?
4. Do we require explicit legal acknowledgment per job in UI?
5. What is the maximum page count per tier plan for launch?