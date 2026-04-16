# 31 — Observability, Metrics, and Evaluation

## 1) Purpose

Define the observability and evaluation framework for the new feature suite:

1. Migration (verified),
2. Design recreation (layout-only),
3. Competitive audit (read-only).

This includes logs, metrics, traces, dashboards, alerts, and quality evaluation loops for launch and scale.

---

## 2) Observability Goals

1. Know what’s happening in each job phase in near real time.
2. Detect reliability/security/performance regressions quickly.
3. Measure output quality and user acceptance.
4. Provide evidence for rollout and release gates.
5. Enable root-cause analysis with strong traceability.

---

## 3) Telemetry Layers

1. **Application logs** (structured events)
2. **Metrics** (counters, gauges, histograms)
3. **Traces** (distributed phase spans)
4. **Domain evaluations** (quality scoring + human feedback)
5. **Operational dashboards/alerts**

---

## 4) Correlation Identifiers (Required Everywhere)

Attach to all logs/metrics/traces where possible:

- `traceId`
- `requestId`
- `jobId`
- `workspaceId`
- `userId` (or hashed equivalent by policy)
- `mode`
- `phase`
- `policyVersion`

---

## 5) Structured Logging Spec

## 5.1 Log event schema (minimum)
- timestamp
- level
- service
- eventName
- identifiers (section 4)
- status/outcome
- latencyMs (if applicable)
- errorCode/errorMessage (if failure)
- metadata object

## 5.2 Core event families
1. `verification.*`
2. `site_job.*`
3. `crawl.*`
4. `extraction.*`
5. `mapping.*`
6. `generation.*`
7. `audit.*`
8. `policy.*`
9. `export.*`
10. `security.*`

---

## 6) Metrics Model

## 6.1 Counter metrics
- jobs_created_total{mode}
- jobs_completed_total{mode}
- jobs_failed_total{mode,phase}
- jobs_canceled_total{mode}
- policy_denied_total{mode,rule}
- ssrf_blocked_total
- exports_requested_total{artifactType}
- exports_blocked_total{reason}

## 6.2 Gauge metrics
- active_jobs{mode}
- queue_depth{queueName}
- workers_busy{workerType}
- pending_manual_mapping_count

## 6.3 Histogram metrics
- phase_duration_ms{mode,phase}
- crawl_page_render_ms
- extraction_page_ms
- generation_duration_ms
- report_generation_ms
- export_link_issuance_ms

---

## 7) Phase-Level SLIs/SLO Targets (Initial)

(Values to tune with production baseline)

1. Verification confirmation latency
2. Time to first crawl progress signal
3. Time to extraction summary available
4. Time to regeneration ready (small/medium site buckets)
5. Audit report readiness latency
6. Job completion success rate per mode

---

## 8) Tracing Strategy

## 8.1 Trace boundaries
Create parent span for each job:
- child spans per phase:
  - intake
  - verification
  - crawl
  - extraction
  - generation/audit
  - finalize

## 8.2 Span attributes
- mode
- targetDomain
- pagesAttempted/processed
- failureReason
- policyDecisionsCount
- artifactCount

## 8.3 Error semantics
Mark spans with:
- `error=true`
- standardized `error.code`
- retry attempts info

---

## 9) Dashboard Requirements

## 9.1 Executive dashboard
- adoption by mode
- completion rate
- median end-to-end duration
- top failure reasons
- safety block trends

## 9.2 Operations dashboard
- queue depths
- worker saturation
- p95 phase durations
- retry/dead-letter volume
- error spikes

## 9.3 Quality dashboard
- mapping confidence distribution
- manual-review-required rate
- build-pass-after-apply rate
- user acceptance/apply rate

## 9.4 Security dashboard
- SSRF blocks
- policy denials by rule
- suspicious behavior flags
- blocked export attempts

---

## 10) Alerting Plan

## 10.1 Critical alerts
- job failure rate spike above threshold
- crawl worker crash loop
- queue backlog runaway
- SSRF blocked attempts abnormal spike
- export policy bypass attempt detected

## 10.2 Warning alerts
- p95 phase latency drift
- increased manual mapping rate
- degraded verification success rate
- rising partial-crawl completion rate

## 10.3 Alert metadata
Each alert should include:
- affected mode/phase
- time window
- top candidate root causes
- runbook link

---

## 11) Quality Evaluation Framework

## 11.1 Automated quality signals

### Migration/recreation
- template mapping confidence score
- unresolved mapping count
- generated project compile/lint pass rate
- runtime build/test success after apply

### Audit
- findings completeness score
- recommendation relevance heuristic
- consistency across reruns (stability)

## 11.2 Human review checkpoints
Sample jobs weekly for:
- structural fidelity (recreation)
- usability/editability of generated code
- correctness and usefulness of audit insights
- policy-compliant behavior

## 11.3 User feedback capture
Collect in-product:
- thumbs up/down for output usefulness
- “what’s wrong” tags (mapping/content/perf/policy)
- freeform feedback snippet

---

## 12) Evaluation Datasets

Create curated benchmark sets:

1. **Migration set**: owned sites across static/JS-heavy profiles
2. **Recreation set**: varied landing/page designs
3. **Audit set**: known websites with expected SEO/perf patterns

Track baseline vs release candidate on same set before rollout.

---

## 13) Experimentation and Rollout Metrics

For staged rollout:
- enable feature flags by cohort
- compare:
  - completion rate
  - duration
  - failure rates
  - support tickets per 100 jobs
  - security denials/anomalies

Use canary thresholds to decide promote/rollback.

---

## 14) Data Retention for Observability

1. high-volume logs: short retention + aggregated archive
2. metrics: longer retention for trend analysis
3. traces: sampled retention based on error/latency conditions
4. preserve security events with compliance-defined retention window

---

## 15) Privacy and Redaction in Telemetry

1. avoid storing full sensitive payloads in logs.
2. redact secrets/token-like values.
3. hash or pseudonymize user identifiers if required.
4. ensure screenshots/artifacts are not dumped into logs.
5. enforce least-privilege access to observability systems.

---

## 16) Suggested Instrumentation Points

## API layer
- request accepted/validated
- policy decision outcomes
- job state transitions

## Worker layer
- crawl page lifecycle
- extraction per page
- mapping decisions
- generation file counts
- audit analysis completion

## Export layer
- export requested/approved/denied/downloaded

## UI telemetry
- mode selected
- verify started/succeeded
- mapping overrides applied
- diff apply success
- report export click/completion

---

## 17) Weekly Ops Review Template

1. Adoption by mode
2. Reliability metrics and top incidents
3. Quality deltas (auto + human)
4. Security/anomaly summary
5. User feedback themes
6. Action items and owners

---

## 18) Release Gate Metrics (Must Meet)

Before wider rollout:
- completion success above target baseline
- no critical unresolved security findings
- p95 latency within agreed envelopes
- manual-review rate acceptable for MVP
- zero unauthorized export incidents

---

## 19) Acceptance Criteria

- end-to-end traces available for all job phases
- core metrics and dashboards deployed
- alert rules active with tested routing
- quality evaluation loop producing weekly report
- privacy-safe logging and redaction verified

---

## 20) Open Decisions

1. Log sampling vs full logging at high traffic?
2. Default trace sampling rate and adaptive rules?
3. Exact SLO thresholds by mode for public launch?
4. What fraction of jobs should receive human quality review?
5. Which user feedback signals are mandatory before GA?