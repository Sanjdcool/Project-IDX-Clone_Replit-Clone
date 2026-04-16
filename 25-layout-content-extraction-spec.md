# 25 — Layout & Content Extraction Specification

## 1) Purpose

Define how crawled pages are transformed into structured, reusable artifacts for:

1. Migration & rebuild (verified owned-site),
2. Design-to-template recreation (layout-centric),
3. Competitive audit (read-only analysis).

This spec focuses on deterministic extraction quality, confidence scoring, and mode-specific output boundaries.

---

## 2) Extraction Goals

1. Convert raw rendered pages into normalized page models.
2. Identify reusable section/component patterns.
3. Extract style/system tokens (typography, spacing, color).
4. Capture content blocks with provenance and confidence.
5. Produce audit-friendly structural insights.

---

## 3) Inputs

From crawl output (per page):
- final URL
- rendered HTML reference
- optional screenshot reference
- basic metadata (title, meta, headings)
- resource map (CSS/JS/images)
- timing/status diagnostics

Optional:
- sitemap hints
- user-supplied screenshot-only input (recreation mode)

---

## 4) Outputs

## 4.1 Page Extraction Record
- `pageId`
- page type candidate (`home`, `listing`, `detail`, `landing`, etc.)
- section list with structure/content/style refs
- detected component instances
- style token bundle
- extraction confidence summary

## 4.2 Site Extraction Bundle
- global nav/footer model
- repeated template candidates
- component inventory
- token system baseline
- content corpus references (mode-filtered)
- quality flags and unresolved ambiguities

---

## 5) Extraction Pipeline Stages

## Stage 1 — DOM Preprocessing
1. Parse rendered DOM snapshot.
2. Remove non-content noise nodes (scripts/style comments/hidden trackers as configured).
3. Normalize whitespace/text nodes.
4. Build DOM tree graph with depth/index metadata.

## Stage 2 — Structural Segmentation
1. Detect macro regions:
   - header/nav
   - hero
   - main content
   - sidebars
   - footer
2. Segment main into candidate sections using:
   - semantic tags,
   - heading boundaries,
   - visual density/DOM subtree heuristics.

## Stage 3 — Component Candidate Detection
Identify repeated UI patterns:
- cards/grids
- CTA blocks
- testimonial blocks
- FAQ accordions
- pricing tables
- forms
- media/text split sections
- nav menus and mega menus

## Stage 4 — Style Token Extraction
Extract candidate design system primitives:
- color palette (primary/secondary/neutral/accent)
- typography scale (font families/sizes/weights/line heights)
- spacing scale (margins/paddings/gaps)
- radius/shadow/border styles
- breakpoint patterns (if inferable)

## Stage 5 — Content Block Classification
Classify text/media blocks:
- heading
- body paragraph
- list
- statistic
- quote/testimonial
- CTA text
- label/form copy
- alt/caption

## Stage 6 — Repetition and Template Inference
Across pages:
- detect repeated skeletons
- infer page templates
- assign page-to-template mapping confidence

## Stage 7 — Mode-Specific Filtering
Apply policy filters:
- migration: richer output set
- recreation: layout-first, safe text defaults
- audit: metadata/analysis artifacts only

---

## 6) Structural Segmentation Rules

## 6.1 Region detection priority
1. semantic tags (`header`, `main`, `nav`, `footer`, `aside`)
2. landmark roles/ARIA
3. CSS class/id heuristics
4. heading hierarchy split
5. DOM subtree visual-density proxy

## 6.2 Section boundary heuristics
Boundary likely if:
- heading level transition (`h1/h2`)
- major container break
- style discontinuity (bg/color/spacing jump)
- repeated card cluster start/end

## 6.3 Section model
Each section:
- `sectionId`
- `sectionTypeCandidate`
- DOM span reference
- content summary
- style signature
- component children
- confidence score

---

## 7) Component Detection Catalog (MVP)

1. Header + Nav
2. Hero
3. Feature grid/cards
4. Stats/counters
5. Testimonials
6. CTA banner
7. FAQ block
8. Contact form
9. Footer columns
10. Blog/article card list
11. Pricing matrix (basic)
12. Image gallery strip

Each detector should emit:
- component type
- bounds/reference
- key props candidate (title, items, CTA label, etc.)
- confidence

---

## 8) Style Token Extraction Spec

## 8.1 Color token strategy
- collect computed colors from major nodes
- cluster by frequency and role likelihood
- output named tokens:
  - `color.primary`
  - `color.secondary`
  - `color.accent`
  - `color.background`
  - `color.text.primary`
  - `color.text.muted`

## 8.2 Typography tokens
Infer:
- base font family
- heading families/weights
- scale map:
  - `font.size.xs/sm/md/lg/xl/...`
- line-height classes by hierarchy level

## 8.3 Spacing tokens
Infer frequently used spacing values:
- margin/padding clusters
- gap clusters
- section vertical rhythm token

## 8.4 Token confidence
Each token includes:
- source frequency
- page coverage
- confidence score

---

## 9) Content Handling Rules by Mode

## Migration (verified)
- include structured content blocks with source refs
- retain richer text corpus for rebuild mapping

## Recreation
- keep layout/content slots
- default to placeholder or rewritten content pipeline
- avoid direct long-form verbatim carryover by default

## Audit
- preserve summary metrics and samples
- do not output reusable raw content bundle

---

## 10) Template Inference

## 10.1 Template signature
For each page:
- ordered section type sequence
- key component multiset
- style signature hash

## 10.2 Clustering
Cluster pages by signature similarity:
- derive `templateId`
- assign `templateConfidence`
- identify outliers requiring manual mapping

## 10.3 Use in downstream generation
Template clusters drive:
- page scaffold generation
- route grouping
- shared component extraction

---

## 11) Confidence Scoring Framework

Compute confidence at:
1. Section level
2. Component level
3. Page template mapping
4. Token inference
5. Overall page extraction

Use weighted scoring from:
- detector agreement
- feature completeness
- cross-page consistency
- heuristic conflicts/ambiguities

Threshold categories:
- `high` (auto-map candidate)
- `medium` (review recommended)
- `low` (manual mapping required)

---

## 12) Ambiguity and Conflict Resolution

Examples:
- same block matches `feature_grid` and `pricing_table`
- heading hierarchy inconsistent
- heavy CSS-in-JS obfuscates style inference

Resolution:
1. keep top candidate + alternates
2. lower confidence
3. mark `needsManualReview=true`
4. surface in UI mapping review panel

---

## 13) Screenshot-Only Extraction Path (Recreation)

When no crawl DOM is available:
1. visual layout analysis from screenshot
2. detect blocks/regions heuristically:
   - nav
   - hero
   - cards
   - CTA/footer
3. infer style approximations (color/type scale)
4. emit lower-confidence layout blueprint

Limitations:
- no reliable content extraction
- no semantic DOM certainty
- must require user review/edit before apply

---

## 14) Extraction Data Schemas (Conceptual)

## 14.1 `ExtractedPage`
- id, url, templateCandidate
- sections[]
- components[]
- styleTokensRef
- contentBlocksRef
- confidenceSummary

## 14.2 `ExtractedSection`
- id, typeCandidate, domRef
- headingText
- contentBlockIds[]
- componentIds[]
- styleSignature
- confidence

## 14.3 `ComponentInstance`
- id, componentType
- propsCandidate (key/value map)
- childCount
- sourceRef
- confidence

## 14.4 `TokenBundle`
- colors[]
- typography[]
- spacing[]
- radii/shadows[]
- confidence

---

## 15) Quality Validation Rules

Extraction quality checks:
1. Required macro regions found on page?
2. Section coverage ratio over main content above threshold?
3. Template assignment consistency across similar URLs?
4. Token bundle completeness above threshold?
5. Invalid/empty components flagged and excluded?

If below thresholds:
- downgrade to partial extraction state
- require manual mapping step

---

## 16) Integration Contracts

Downstream consumers:
1. Regeneration/mapping engine
2. Audit analytics engine
3. Frontend extraction preview UI

Must provide stable references:
- page/section/component IDs
- artifact URIs
- confidence and issue flags

---

## 17) Performance Considerations

1. Extraction per page must be bounded by CPU/time limits.
2. Large DOMs processed with streaming/segmented passes where possible.
3. Cache repeated stylesheet/resource analyses across same domain.
4. Parallelize cross-page template clustering in batches.

---

## 18) Security and Safety in Extraction

1. Never execute untrusted scripts during extraction stage.
2. Read from rendered snapshot artifacts, not live script execution.
3. Strip suspicious embedded payloads from persisted extraction output.
4. Apply mode filters before artifact write.

---

## 19) Observability for Extraction

Track:
- pages extracted / minute
- average extraction duration
- detector success rates
- confidence distribution
- ambiguity/manual-review rates
- failure reason taxonomy

Emit per-page extraction summary event for UI progress streaming.

---

## 20) Acceptance Criteria

- Engine produces normalized section/component model for majority of target pages.
- Style token extraction yields usable base token set in common site types.
- Template clustering identifies reusable page archetypes.
- Confidence scoring and ambiguity flags are present and surfaced.
- Mode-specific content restrictions are enforced at extraction output stage.

---

## 21) Open Decisions

1. Which component detectors are mandatory for MVP vs beta?
2. Should we include OCR fallback for screenshot text hints?
3. Do we compute visual segmentation from screenshot in all modes or recreation only?
4. What minimum confidence triggers auto-map without manual review?
5. Should token inference prioritize computed style or source CSS declarations?