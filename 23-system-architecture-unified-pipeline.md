# 23 — System Architecture: Unified Pipeline (Migration, Recreation, Audit)

## 1) Purpose

Define the technical architecture for a unified feature pipeline supporting:

1. **Owned-site Migration & Rebuild**
2. **Design-to-Template Recreation (URL/Screenshot)**
3. **Competitive Audit (Read-Only)**

This architecture is implementation-oriented and designed to plug into your existing AI orchestration, patch review/apply, sandbox run, security, and observability layers.

---

## 2) High-Level Architecture

```text
                   ┌──────────────────────────────┐
                   │ Frontend Studio (New)        │
                   │ - Mode selection             │
                   │ - Verify ownership           │
                   │ - Crawl/extract progress     │
                   │ - Preview + diff review      │
                   │ - Audit dashboards           │
                   └──────────────┬───────────────┘
                                  │
                                  ▼
┌────────────────────────────────────────────────────────────────────┐
│ API Gateway / Orchestrator                                        │
│ - AuthN/AuthZ                                                     │
│ - Policy pre-checks                                               │
│ - Job lifecycle (create/start/cancel/status)                      │
│ - Mode gating                                                     │
└──────────────┬─────────────────────┬──────────────────────────────┘
               │                     │
               ▼                     ▼
   ┌──────────────────────┐   ┌────────────────────────────┐
   │ Ownership Service    │   │ Policy Engine              │
   │ - DNS/meta/file proof│   │ - Mode restrictions        │
   │ - Verification state │   │ - Export controls          │
   └───────────┬──────────┘   └──────────────┬─────────────┘
               │                              │
               └──────────────┬───────────────┘
                              ▼
                    ┌──────────────────────┐
                    │ Job Queue / Worker   │
                    │ Dispatcher            │
                    └──────────┬───────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
┌────────────────┐   ┌────────────────────┐  ┌─────────────────────��
│ Crawl Workers  │   │ Extraction Workers │  │ Audit Workers       │
│ (Playwright/   │   │ - Layout/content   │  │ - SEO/perf/IA comps │
│ Crawlee stack) │   │ - Style tokens     │  │ - Benchmark reports │
└───────┬────────┘   └─────────┬──────────┘  └──────────┬──────────┘
        │                      │                        │
        └──────────────┬───────┴───────────────┬────────┘
                       ▼                       ▼
            ┌──────────────────────┐  ┌─────────────────────────┐
            │ Artifact Store       │  │ Metadata DB             │
            │ - raw snapshots      │  │ - jobs/state/events     │
            │ - extracted bundles  │  │ - pages/assets/meta     │
            │ - generated scaffold │  │ - ownership/audit logs  │
            └───────────┬──────────┘  └─────────────┬───────────┘
                        │                           │
                        ▼                           ▼
                ┌──────────────────────────────────────────┐
                │ Regeneration/Mapping Engine             │
                │ - normalize site model                  │
                │ - map to target components              │
                │ - produce patch plan                    │
                └───────────────┬──────────────────────────┘
                                ▼
                     ┌─────────────────────────┐
                     │ Existing AI Patch Flow  │
                     │ - diff review           │
                     │ - selective apply       │
                     │ - snapshot/rollback     │
                     │ - sandbox run/fix       │
                     └─────────────────────────┘
```

---

## 3) Architectural Goals

1. Reuse existing AI platform primitives where possible.
2. Isolate crawl/extract workloads into dedicated workers.
3. Enforce policy/ownership before expensive operations.
4. Provide progressive, observable job states to UI.
5. Keep mode outputs safely bounded by policy.

---

## 4) Core Services and Responsibilities

## 4.1 Orchestrator API Service
- Accepts job requests.
- Validates mode, permissions, ownership requirements.
- Emits job lifecycle events.
- Coordinates phase transitions.

## 4.2 Ownership Verification Service
- Issues verification tokens.
- Validates DNS/meta/file checks.
- Stores verification state with expiry.
- Exposes verification status API.

## 4.3 Crawl Service
- Fetches page graph and render artifacts.
- Supports JS-heavy rendering via browser engine.
- Applies crawl budgets (depth/pages/time).
- Produces normalized crawl output.

## 4.4 Extraction Service
- Converts crawl artifacts to structured model:
  - page types,
  - section/component candidates,
  - style/theme tokens,
  - content blocks.

## 4.5 Audit Service
- Computes read-only analysis:
  - structure,
  - performance metrics,
  - SEO/schema metadata,
  - comparative deltas.

## 4.6 Regeneration/Mapping Service
- Maps extracted structure to internal component schema.
- Generates target-stack code skeleton.
- Produces patch plan for existing review/apply flow.

## 4.7 Policy Engine
- Centralized allow/deny decisions by mode/action.
- Enforces export restrictions and scope boundaries.
- Returns deterministic policy denial codes.

## 4.8 Artifact Store
- Stores raw snapshots and derived artifacts.
- Provides signed retrieval for allowed outputs.

## 4.9 Metadata and State DB
- Stores jobs, phases, events, and references.
- Links artifacts to policy/version/ownership context.

---

## 5) Unified Pipeline Phases

## Phase 0 — Intake & Validation
- Input normalization (URL/screenshot/job options).
- Policy pre-check.
- Ownership requirement check by mode.

## Phase 1 — Discovery/Crawl
- URL frontier setup.
- Render/fetch pages under budgets.
- Record crawl coverage and failure reasons.

## Phase 2 — Extraction
- DOM segmentation and section detection.
- style token extraction.
- content block classification.
- component candidate graph generation.

## Phase 3 — Mode Branch

### Migration branch
- content+layout+asset reconstruction package
- regeneration candidate + patch generation

### Recreation branch
- layout-focused mapping
- fresh code + placeholder/rewritten content

### Audit branch
- no clone artifacts
- analysis report package only

## Phase 4 — Review/Output
- migration/recreation: patch preview and selective apply
- audit: dashboard/report export

## Phase 5 — Post-Processing
- telemetry aggregation
- artifact retention tagging
- policy-compliant cleanup

---

## 6) Mode-Specific Execution Paths

## 6.1 Migration (verified)
```text
verify ownership -> crawl full scope -> extract -> regenerate scaffold
-> patch review/apply -> run/test -> finalize
```

## 6.2 Design recreation
```text
intake URL/screenshot -> extract layout patterns -> map to template system
-> generate fresh scaffold + placeholders -> patch review/apply
```

## 6.3 Competitive audit
```text
read-only crawl -> compute structure/SEO/perf/component metrics
-> benchmark report -> export report only
```

---

## 7) Data Flow Contracts (Conceptual)

## Crawl Artifact
- page URL
- rendered HTML snapshot reference
- resource map (CSS/JS/images)
- fetch timings/status
- links discovered

## Extraction Artifact
- page model (type/sections)
- style token set
- component candidates
- content block references
- confidence scores

## Regeneration Artifact
- normalized project blueprint
- file graph
- generated source refs
- patch operations list

## Audit Artifact
- KPI summary
- issue findings list
- benchmark comparisons
- recommendations

---

## 8) Job State Machine

```text
created
  -> policy_validated
  -> ownership_pending (migration only)
  -> ownership_verified
  -> queued
  -> crawling
  -> extracting
  -> generating | auditing
  -> review_ready | report_ready
  -> applied (if code path)
  -> completed
  -> failed | canceled
```

Rules:
- migration cannot transition to `queued` until ownership verified.
- audit cannot transition to generation/apply states.
- cancellation allowed from queued/running states with cleanup workflow.

---

## 9) Worker Topology

## 9.1 Queue design
- `crawl_queue`
- `extract_queue`
- `generate_queue`
- `audit_queue`
- `cleanup_queue`

## 9.2 Scaling strategy
- scale crawl workers by browser capacity
- scale extraction workers by CPU
- scale generation workers by model throughput
- apply tenant quotas to prevent noisy neighbors

## 9.3 Fault handling
- retry transient failures with capped attempts
- move poison jobs to dead-letter queue
- expose retry-from-phase for operators

---

## 10) Integrating with Existing AI Stack

Reuse existing modules:
- patch plan schema and diff viewers
- selective apply, snapshot, rollback
- sandbox run/fix loop
- telemetry/audit infrastructure

New modules:
- verification service
- crawl/extract pipeline
- audit analyzer
- regeneration mapper

---

## 11) Performance and Capacity Baselines (Initial)

(Indicative targets for MVP planning)
- small site (≤100 pages): first extraction preview within ~5–15 min
- medium site (≤500 pages): staged preview chunks, full run longer
- report generation should stream partial findings as ready

---

## 12) Security Boundaries in Architecture

1. Crawl workers run in isolated network sandbox.
2. URL fetch pipeline protected against SSRF/internal IP access.
3. Artifact access via signed short-lived URLs.
4. Policy checks executed both pre-job and pre-export.
5. All phase transitions audited with policy version.

---

## 13) Observability Hooks

Emit events/spans for:
- job phase start/end
- crawl page processed
- extraction confidence metrics
- policy denials
- generation/apply lifecycle
- report export/download

Core dimensions:
- mode
- domain
- workspace/org
- jobId
- phase
- duration
- success/failure code

---

## 14) Failure Modes and Recovery

1. Crawl failures due to anti-bot/rate limits
   - degrade gracefully, report partial coverage.

2. JS render instability
   - fallback to static fetch + lower-confidence extraction.

3. Low-confidence mapping
   - require manual section mapping review in UI.

4. Policy conflicts mid-pipeline
   - stop phase, mark as blocked, preserve safe artifacts only.

5. Worker crash
   - resume from last durable phase checkpoint.

---

## 15) Deployment Architecture (MVP Suggestion)

- API/Orchestrator service
- Verification service
- Crawl worker pool
- Extraction worker pool
- Audit worker pool
- Generation/mapper service
- Postgres metadata DB
- Object storage for artifacts
- Redis/queue broker

---

## 16) Architecture Acceptance Criteria

- Mode isolation is enforced by service and policy layers.
- Ownership gating blocks unauthorized migration starts.
- Pipeline phase states are durable and resumable.
- Audit mode cannot produce clone/export artifacts.
- Migration/recreation outputs integrate with existing patch/apply flow.
- End-to-end traces exist across all major services.

---

## 17) Open Architecture Decisions

1. Single queue with phase routing vs dedicated queues per phase?
2. Browser pool strategy (shared contexts vs isolated per-job)?
3. Do we store raw rendered HTML for all pages or sampled subset by default?
4. Confidence-threshold UX: auto-accept high-confidence mappings?
5. Multi-region worker deployment needed at MVP or post-beta?