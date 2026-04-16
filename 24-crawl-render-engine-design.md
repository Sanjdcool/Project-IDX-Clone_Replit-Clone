# 24 — Crawl & Render Engine Design

## 1) Purpose

Specify the crawl/render subsystem for:

- owned-site migration,
- design-to-template recreation,
- competitor audit (read-only),

with mode-aware policy controls, robust JS rendering, and production-safe limits.

---

## 2) Design Objectives

1. Crawl modern JS-heavy sites reliably.
2. Keep crawling safe (SSRF/abuse protections).
3. Respect mode-specific legal/policy constraints.
4. Produce deterministic artifacts for extraction.
5. Support scalable, resumable long-running jobs.

---

## 3) Engine Modes

Each job runs with one crawl profile:

1. **`migration_verified`**
   - broader crawl scope within verified domain
   - richer artifact capture (for rebuild use)

2. **`recreation_layout_only`**
   - layout-first capture, limited content retention defaults

3. **`audit_readonly`**
   - metadata/perf/structure oriented
   - no clone/export artifact class

---

## 4) Core Components

## 4.1 Crawl Orchestrator
- Builds initial frontier.
- Assigns tasks to workers.
- Tracks job state and budgets.

## 4.2 Fetch/Render Worker
- Navigates URL in browser engine (Playwright/Crawlee-based).
- Captures rendered DOM and selected resources.
- Emits per-page result envelope.

## 4.3 Frontier Manager
- URL dedupe/canonicalization.
- Scope allow/deny filters.
- Priority queue logic (seed, nav, sitemap, in-content links).

## 4.4 Robots/Policy Evaluator
- Applies robots strategy by mode.
- Enforces policy-layer URL and action restrictions.

## 4.5 Artifact Writer
- Persists crawl snapshots and metadata.
- Handles retention classes by mode.

## 4.6 Metrics/Trace Emitter
- Emits crawl timings, errors, coverage.

---

## 5) URL Intake and Normalization

## 5.1 Input validation
- only `http/https` allowed
- reject malformed or unsupported schemes
- punycode normalize IDNs where needed

## 5.2 Canonicalization rules
Normalize before frontier dedupe:
- lowercase host
- strip default ports (80/443)
- normalize trailing slash convention
- strip fragment `#...`
- optionally normalize known tracking query params (`utm_*`, `fbclid`, etc.)

## 5.3 Scope derivation
From seed URL derive:
- allowed host(s)
- allowed path prefix (optional)
- subdomain policy (explicit)

---

## 6) Crawl Scope and Limits

## 6.1 Budget controls
Per job:
- max pages
- max depth
- max runtime
- max bytes fetched
- max concurrent tabs

## 6.2 Suggested default profiles (MVP)
- migration verified: medium/high budget
- recreation: medium budget
- audit: low/medium budget

## 6.3 URL filters
Block by default:
- logout/cart/checkout/account action endpoints (mode-dependent)
- obvious trap/query loop patterns
- non-HTML large binary endpoints (unless explicitly needed)

---

## 7) Robots and Access Policy

## 7.1 Mode behavior
- audit/recreation: honor robots by default
- migration verified: policy-configurable, default honor unless explicit override workflow

## 7.2 Explicit overrides
If overrides allowed:
- require stronger user acknowledgment
- emit compliance audit event
- restrict to verified domains only

---

## 8) Rendering Strategy

## 8.1 Navigation lifecycle
Per page:
1. open context/page
2. apply request interception/policies
3. navigate with timeout
4. wait strategy
5. optional interaction steps
6. snapshot/extract raw signals
7. close page/context cleanly

## 8.2 Wait strategies
Use configurable wait mode:
- `domcontentloaded` (fast baseline)
- `networkidle` (for dynamic pages)
- targeted selector wait for known content anchors

## 8.3 Dynamic content handling
Optional per profile:
- scroll to trigger lazy loading
- limited “load more” clicks
- avoid unbounded interaction loops

---

## 9) Request Interception Rules

## 9.1 Security-first blocking
Always block:
- internal network/IP targets
- loopback/link-local/private CIDRs
- unsupported schemes

## 9.2 Performance blocking (mode-dependent)
Can block nonessential resources to improve throughput:
- third-party ads/trackers
- media types not needed for current mode
- extremely large assets over threshold

## 9.3 Data minimization
For audit mode, prefer metadata capture over full asset persistence.

---

## 10) Anti-Loop and Trap Protection

1. Query parameter explosion detection.
2. URL pattern repetition limits.
3. Calendar/pagination trap heuristics.
4. Per-template repetition cap (same path shape).
5. Frontier backpressure when error rate spikes.

---

## 11) Error Taxonomy and Retry Policy

## 11.1 Error classes
- network timeout
- DNS failure
- TLS error
- render crash
- blocked by policy
- blocked by robots
- anti-bot/challenge encountered

## 11.2 Retry strategy
- retry transient classes with exponential backoff
- do not retry permanent policy denials
- cap retries per URL and per job

## 11.3 Partial completion
Jobs can complete with partial coverage and explicit coverage report.

---

## 12) Crawl Output Envelope (Per Page)

Each crawled page emits:

- `pageId`
- final URL
- status code / navigation outcome
- fetch/render durations
- discovered links (normalized)
- resource summary (counts/sizes/types)
- rendered HTML reference (if permitted by mode)
- title/meta/h1 quick fields
- screenshot reference (if enabled)
- confidence and warnings

---

## 13) Artifact Classes by Mode

## Migration verified
- rendered HTML snapshot refs
- DOM and resource maps
- optional screenshot and key asset refs

## Recreation layout-only
- structure-focused artifact set
- limited text capture defaults
- style token candidate refs

## Audit readonly
- metrics and structural summaries
- optional sampled HTML refs for diagnostics
- report-oriented artifacts only

---

## 14) Worker Runtime and Isolation

1. Run browser workers in isolated containers.
2. Constrain CPU/memory/timeouts.
3. Disable privileged runtime features.
4. Use ephemeral work directories.
5. Enforce outbound network policy.

---

## 15) Parallelism and Throughput

## 15.1 Concurrency controls
- per-job tab concurrency
- per-tenant max active jobs
- global worker pool limits

## 15.2 Backpressure
Slow/fail-heavy jobs should auto-throttle frontier processing.

## 15.3 Fair scheduling
Weighted queue to prevent one large crawl from starving others.

---

## 16) Job Checkpointing and Resume

Persist phase checkpoints:
- frontier state snapshot
- processed URL set hash/state
- page result cursor
- budget usage counters

On crash/restart:
- reload checkpoint
- continue from durable frontier state
- avoid reprocessing completed URLs

---

## 17) Sitemap and Seed Expansion

## 17.1 Seed sources
- user seed URL
- discovered internal nav links
- optional sitemap ingestion

## 17.2 Sitemap strategy
- parse sitemap index and child sitemaps
- dedupe against frontier
- assign priority based on path/page type hints

---

## 18) Observability for Crawl Engine

Track per job:
- pages attempted/succeeded/failed
- coverage ratio
- avg/p95 render time
- bytes fetched
- block reasons distribution
- retry counts
- timeout rate

Emit traces around:
- navigation
- wait phase
- interaction phase
- artifact write phase

---

## 19) Configuration Surface (MVP)

Expose safe config options per job:
- max pages/depth/runtime
- wait strategy
- screenshot capture toggle
- sitemap assist toggle
- interaction profile (`none`, `light`)
- resource blocking profile

Hide dangerous low-level flags from end users.

---

## 20) Security Controls Specific to Crawling

1. SSRF guard on every outbound request target.
2. DNS rebinding protection (resolve + connect checks).
3. Strict URL scheme allowlist.
4. Header sanitization.
5. Request timeout and body size ceilings.
6. Forbidden response persistence classes (sensitive leakage prevention).

---

## 21) Acceptance Tests (Crawl Engine)

1. Static site crawl completes within budget.
2. JS-heavy site yields rendered content with target selectors present.
3. Scope filters prevent off-domain traversal.
4. Trap protection stops unbounded URL loops.
5. Policy blocks internal/private IP targets.
6. Resume after worker restart continues correctly.
7. Audit mode output does not include restricted artifact classes.

---

## 22) Implementation Phases

## Phase A
- basic frontier + render + artifact write
- strict limits and safety rails

## Phase B
- dynamic interaction profile
- sitemap ingestion
- checkpoint/resume hardening

## Phase C
- advanced heuristics (trap detection, adaptive waits)
- throughput optimization and fairness tuning

---

## 23) Open Crawl Design Decisions

1. Default wait strategy per mode (`domcontentloaded` vs `networkidle`)?
2. Should screenshots be on by default for audit mode?
3. Which query params are canonicalized vs retained?
4. How aggressive should third-party resource blocking be for recreation fidelity?
5. Do we support authenticated crawl in post-MVP only?