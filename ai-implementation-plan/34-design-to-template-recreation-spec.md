# 34 — Design-to-Template Recreation Specification

## 1) Purpose

Define the detailed product and engineering specification for **Design-to-Template Recreation**:

- input via URL and/or screenshot(s),
- extract **layout and design patterns only**,
- generate fresh, editable code scaffold,
- use placeholder or rewritten content modes by default,
- integrate with review/apply pipeline safely.

---

## 2) Feature Definition

Design-to-Template Recreation is a workflow that reconstructs the **structure, visual rhythm, and component layout** of a reference source into your target stack and component system, without promoting verbatim source replication defaults.

---

## 3) Objectives

1. Convert inspiration/reference pages into implementable templates rapidly.
2. Preserve layout intent (sections/components/style tokens), not raw source code.
3. Produce clean code aligned to internal architecture standards.
4. Provide confidence-aware manual mapping controls.
5. Maintain policy-safe defaults for content and asset handling.

---

## 4) Input Modes

## 4.1 URL Mode
User provides public URL.

Pipeline:
- crawl/render selected page(s)
- extract structure/components/tokens
- generate scaffold

## 4.2 Screenshot Mode
User uploads screenshot(s) of target design.

Pipeline:
- visual segmentation
- section/block inference
- token approximation
- generate scaffold with lower confidence metadata

## 4.3 Hybrid Mode (URL + Screenshot)
Use URL extraction as base and screenshots for visual disambiguation and style refinement.

---

## 5) Output Definition

## 5.1 Primary outputs
1. generated page/component scaffold
2. theme/style token configuration
3. route/page structure (if multipage inferred)
4. mapping report with confidence

## 5.2 Secondary outputs
- unresolved mapping list
- manual override suggestions
- patch plan for diff/apply

---

## 6) Supported Recreation Scenarios (MVP)

1. Single marketing landing page recreation.
2. Multi-section homepage recreation.
3. Simple multi-page informational site recreation.
4. Screenshot-based static layout starter.

Not in MVP:
- fully interactive app dashboards with complex runtime behavior replication,
- exact animation parity guarantees,
- authenticated/private page reconstruction.

---

## 7) UX Flow (Detailed)

## Step 1 — Select Recreation Mode
User enters Site Studio > Recreation tab.

## Step 2 — Choose Input Type
- URL
- Screenshot(s)
- Hybrid

## Step 3 — Configure Generation Settings
- target stack (required)
- content mode: placeholder/rewrite/mixed
- route strategy: single-page/inferred multipage
- style fidelity slider (low/medium/high)

## Step 4 — Start Recreation Job
Job created and enters phases:
- intake
- crawl/visual analysis
- extraction
- mapping
- generation

## Step 5 — Review Mapping
UI shows section-by-section mapping with:
- confidence badge
- selected component
- alternate component options
- manual prop overrides

## Step 6 — Regenerate (optional)
User adjusts mappings and regenerates incrementally.

## Step 7 — Diff Review and Apply
Generated scaffold enters existing patch review/apply flow.

---

## 8) Functional Requirements

## FR-REC-1 Input Handling
System must accept URL and image uploads and validate each input type.

## FR-REC-2 Layout Extraction
System must identify major structural sections and component candidates.

## FR-REC-3 Token Approximation
System must infer visual tokens:
- color palette
- typography scale
- spacing rhythm
- border/radius style hints

## FR-REC-4 Content Mode Enforcement
System must honor content mode choice:
- placeholder default for safe output
- rewrite optional
- mixed mode for practical middle ground

## FR-REC-5 Mapping Review
System must expose confidence and allow per-section mapping overrides.

## FR-REC-6 Incremental Regeneration
System must regenerate only impacted sections/pages where feasible.

## FR-REC-7 Patch Integration
System must emit patch plan for standard review/apply pipeline.

---

## 9) Non-Functional Requirements

1. Responsive UI even for large section trees.
2. Deterministic output for same input/settings.
3. Clear phase progress reporting for long jobs.
4. Memory/runtime limits for visual analysis workers.
5. Auditable mapping and generation decision history.

---

## 10) Extraction and Mapping Rules (Recreation-Specific)

## 10.1 Section priority order
1. nav/header
2. hero
3. feature/content sections
4. social proof/testimonial
5. CTA
6. footer

## 10.2 Component selection policy
- prefer canonical internal components
- fallback to generic section component when low confidence
- avoid one-off component fragmentation

## 10.3 Confidence thresholds
- High: auto-map and preselect
- Medium: auto-map but highlight for review
- Low: require manual confirmation before apply

---

## 11) Content Strategy Modes

## 11.1 Placeholder (default)
- synthetic headings/body copy
- realistic but neutral CTA text
- no source-longform carryover by default

## 11.2 Rewrite
- transformed text preserving intent
- configurable tone/length
- provenance metadata for rewritten slots

## 11.3 Mixed
- preserve key heading intent
- placeholder for body sections requiring manual brand customization

---

## 12) Asset Handling Rules

1. In recreation mode, avoid raw asset archive export as default.
2. Use placeholders when asset rights/quality are uncertain.
3. Allow user replacement workflow in mapping preview.
4. Track all media references with source/provenance metadata.

---

## 13) Screenshot Analysis Specification (MVP)

## 13.1 Accepted formats
- PNG, JPG, WEBP
- max file size and dimensions policy enforced

## 13.2 Analysis outputs
- block segmentation map
- guessed section types
- color clusters
- text region hints (optional OCR-assisted)
- confidence summary

## 13.3 Limitations to surface in UI
- semantic uncertainty
- inaccessible hidden states/interactions
- no reliable source content extraction

---

## 14) Generated Project Contract

Must include:
- clean folder structure
- reusable section components
- theme token file
- page composition files
- content data file(s)
- lint/format compatibility with selected stack profile

---

## 15) Error Handling and Recovery

Common failure scenarios:
1. URL fetch/render failure
2. screenshot unreadable/low quality
3. low-confidence mapping overload
4. codegen template incompatibility

UX behavior:
- clear stage-specific errors
- recommended corrective action
- retry/regenerate controls

---

## 16) Observability Events (Recreation)

Emit:
- recreation_input_type_selected
- recreation_job_started
- recreation_extraction_completed
- recreation_mapping_override_applied
- recreation_regenerated
- recreation_patch_review_opened
- recreation_patch_applied

Include:
- input type
- mode
- confidence profile
- unresolved count
- generation duration

---

## 17) Security and Policy Controls (Recreation)

1. enforce mode constraints from policy engine.
2. block restricted export classes.
3. validate screenshot uploads against type/size.
4. sanitize filenames and embedded metadata.
5. retain audit logs for mapping/generation actions.

---

## 18) QA Acceptance Criteria

- URL recreation produces scaffold with section/component mapping.
- Screenshot recreation produces usable starter layout with confidence flags.
- Mapping override and incremental regeneration work end-to-end.
- Placeholder mode avoids direct long-form carryover defaults.
- Diff/apply integration works with rollback safety.
- Policy restrictions on export are enforced.

---

## 19) Performance Targets (Indicative)

1. Single-page URL recreation: first preview within acceptable SLA.
2. Screenshot recreation: block map preview quickly, full scaffold shortly after.
3. Regenerate-from-overrides: significantly faster than full rerun where possible.

---

## 20) Open Decisions

1. Should screenshot OCR be on by default or optional?
2. How many screenshots should MVP support per job?
3. Which target stacks are supported at initial launch?
4. Should style fidelity slider affect token strictness only or also component granularity?
5. Minimum confidence threshold for auto-apply suggestion?