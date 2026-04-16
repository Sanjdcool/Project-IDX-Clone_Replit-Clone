# 26 — Component Mapping & Code Generation Engine

## 1) Purpose

Define the engine that converts extracted site models into fresh, editable code scaffolds for:

- owned-site migration rebuild,
- design-to-template recreation,

while integrating with existing patch review/apply workflows and respecting policy mode constraints.

---

## 2) Goals

1. Transform extraction artifacts into normalized internal page/component schema.
2. Map detected structures to target design system components.
3. Generate maintainable project code (not raw copied source).
4. Preserve confidence-aware human review for ambiguous mappings.
5. Produce deterministic patch plans for diff/apply pipeline.

---

## 3) Inputs and Outputs

## 3.1 Inputs
- extracted site bundle (pages/sections/components/tokens/confidence)
- mode (`migration_verified`, `recreation_layout_only`)
- target stack profile (e.g., Next.js + Tailwind + TS)
- generation options:
  - content mode (`placeholder`, `rewrite`, `mixed`)
  - route strategy
  - component reuse strictness

## 3.2 Outputs
- generated project blueprint
- file tree + source files
- mapping report (what mapped, what fell back)
- patch operations for existing review/apply flow
- unresolved/manual-review item list

---

## 4) Engine Architecture

```text
Extracted Bundle
     │
     ▼
┌──────────────────────────────┐
│ Normalizer                   │
│ - canonical schema           │
│ - clean/merge structures     │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ Mapper                       │
│ - section→component mapping  │
│ - props inference            │
│ - fallback templates         │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ Token Translator             │
│ - style tokens to stack      │
│ - theme generation           │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ Code Generator               │
│ - routes/pages/layouts       │
│ - component files            │
│ - content/data modules       │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ Patch Planner                │
│ - create/update ops          │
│ - metadata + rationale       │
└──────────────────────────────┘
```

---

## 5) Normalized Internal Schema

## 5.1 Core entities
1. `SiteModel`
2. `PageModel`
3. `SectionModel`
4. `ComponentModel`
5. `ThemeTokenModel`
6. `ContentSlotModel`

## 5.2 Canonicalization rules
- unify section type names (`hero`, `feature_grid`, `cta`, etc.)
- normalize heading and text slot structure
- collapse duplicate adjacent structural blocks
- preserve source references for traceability

---

## 6) Mapping Strategy

## 6.1 Mapping levels
1. **Direct map**: high-confidence section/component to known internal component
2. **Composite map**: multiple extracted fragments combine into one target component
3. **Fallback map**: generic section template when confidence low

## 6.2 Priority logic
- prefer reusable design-system primitives
- minimize one-off generated bespoke blocks
- maintain semantic correctness over visual mimicry when conflict arises

## 6.3 Mapping confidence
Each mapping decision includes:
- selected target component
- source section/component refs
- confidence score
- alternate candidates

---

## 7) Component Library Contract

Engine maps only to approved component set (MVP baseline):
- `Navbar`
- `Hero`
- `FeatureGrid`
- `StatsStrip`
- `TestimonialSection`
- `PricingTable`
- `FAQSection`
- `CTASection`
- `ContactForm`
- `Footer`

If no fit:
- map to `GenericSection` with structured slots and TODO flags.

---

## 8) Props and Slot Inference

## 8.1 Prop categories
- textual props (title/subtitle/body/ctaLabel)
- media props (image/icon refs)
- data arrays (features, testimonials, FAQ items)
- behavior props (variant/theme/alignment)

## 8.2 Inference sources
- extracted content blocks
- heading hierarchy
- list structures
- link/button candidates
- style signatures

## 8.3 Missing prop handling
- fill placeholders with deterministic defaults
- mark unresolved props in mapping report for UI review

---

## 9) Content Generation Modes

## 9.1 Placeholder mode (default-safe recreation)
- generate neutral placeholder copy
- preserve structure without carrying long source prose

## 9.2 Rewrite mode
- transform extracted text into fresh content through AI rewrite pipeline
- maintain section intent and length targets
- tag rewritten blocks with provenance metadata

## 9.3 Mixed mode
- key headers preserved/reframed
- body copy placeholders for manual editing

---

## 10) Theme/Token Translation

## 10.1 Token conversion
Convert extracted token bundle to target stack theme config:
- colors -> theme palette
- typography -> font scale config
- spacing -> spacing scale
- radius/shadows -> style utilities

## 10.2 Conflict resolution
If ambiguous tokens:
- choose stable defaults
- include token override file for quick user edits

## 10.3 Output examples
- `theme.ts` / `tailwind.config` extension
- `styles/tokens.css` or equivalent

---

## 11) Route and Page Generation

## 11.1 Route strategies
- inferred from URL paths + template clusters
- optional simplified route mode for MVP

## 11.2 Page scaffolding
Generate:
- shared layout shell
- page-level composition file
- section/component imports
- content data source references

## 11.3 Shared templates
Pages with same template cluster should reuse component arrangements and data schemas.

---

## 12) File Generation Layout (Example)

```text
src/
  app|pages/
    index.tsx
    about.tsx
    services.tsx
  components/
    layout/
      Navbar.tsx
      Footer.tsx
    sections/
      Hero.tsx
      FeatureGrid.tsx
      CTASection.tsx
      ...
  data/
    pages/
      home.json
      about.json
  styles/
    tokens.css
  config/
    theme.ts
```

---

## 13) Determinism and Reproducibility

1. Same input + same options should produce stable output.
2. Use deterministic ordering for sections/files.
3. Record generator version and mapping policy version in metadata.
4. Include hash of input extraction bundle for traceability.

---

## 14) Patch Plan Generation

Generate operations:
- `create_file`
- `update_file`
- (optional) `delete_file` only where policy allows

Each operation includes:
- path
- content
- rationale
- source mapping references
- risk label

Patch plan is emitted into existing diff/review/apply flow.

---

## 15) Manual Review Hooks

When confidence below threshold:
- mark section/page `manualReviewRequired=true`
- provide suggested component alternatives
- expose editable mapping panel in frontend
- regenerate affected files on user adjustments

---

## 16) Quality Controls

## 16.1 Structural quality
- page renders with valid component tree
- required sections (header/footer/main) present unless intentionally omitted

## 16.2 Code quality
- lint/format pass
- type checks for TS targets
- no unresolved imports

## 16.3 UX quality
- responsive baseline classes
- semantic markup defaults
- accessibility baseline (headings/aria labels on key controls)

---

## 17) Integration with Existing Runtime

After generation:
1. produce patch
2. user reviews diffs
3. apply selected files
4. run build/test via sandbox
5. optional AI fix loop for broken builds

---

## 18) Mode-Specific Constraints

## Migration verified
- may map richer content and assets
- preserve more detail where confidence high

## Recreation layout-only
- prioritize structural recreation
- default to placeholders/rewrites
- avoid high-fidelity textual carryover by default

## Audit mode
- no code generation path enabled

---

## 19) Performance Targets (MVP Indicative)

- small site scaffold generation: near-real-time after extraction
- medium site generation: staged by template cluster/page batches
- regeneration from manual mapping edits should be incremental where possible

---

## 20) Observability for Mapping/Codegen

Track:
- sections mapped by confidence bucket
- fallback component usage rate
- unresolved mapping count
- generation duration by page/template
- build-pass rate after apply
- user acceptance/apply rates

---

## 21) Error Handling

Common error classes:
1. invalid extraction bundle schema
2. token translator conflicts
3. code generation template failure
4. patch packaging failure

Behavior:
- fail with detailed diagnostics
- keep partial artifacts for debugging
- allow retry after corrected mapping/options

---

## 22) Acceptance Criteria

- Extracted pages map to valid internal components with confidence reporting.
- Generated project compiles in baseline target stack for majority MVP cases.
- Low-confidence areas are surfaced for human adjustment.
- Patch output is consumable by existing review/apply pipeline.
- Mode constraints are enforced (no generation in audit mode).

---

## 23) Open Decisions

1. Single universal component library vs stack-specific libraries?
2. How aggressive should auto-mapping be at medium confidence?
3. Should generated content live inline in components or separate data files by default?
4. What minimum code quality gates block patch emission?
5. Do we support multi-framework output in MVP or one canonical stack first?