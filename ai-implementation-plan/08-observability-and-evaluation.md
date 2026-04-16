# 08 — Observability and Evaluation

## 1) Purpose

Define how to measure, monitor, and improve the AI app-generation system across:
- reliability,
- quality,
- latency,
- safety,
- cost.

This document covers both runtime observability and offline/online evaluation.

---

## 2) Observability Goals

1. Detect failures early and debug quickly.
2. Track user-visible performance and success.
3. Understand model quality and drift over time.
4. Control costs and prevent abuse.
5. Enable data-driven prompt/model iteration.

---

## 3) Telemetry Model

Every major action must have correlated telemetry using:
- `traceId`
- `requestId`
- `sessionId`
- `workspaceId`
- `userId` (where permitted)
- `phase` (generate/apply/run/fix/rollback)

## 3.1 Event taxonomy

Core event types:
- `ai.generate.requested`
- `ai.generate.completed`
- `ai.generate.failed`
- `ai.patch.reviewed`
- `ai.patch.applied`
- `ai.patch.apply_failed`
- `ai.run.started`
- `ai.run.completed`
- `ai.run.failed`
- `ai.fix.requested`
- `ai.fix.completed`
- `ai.fix.failed`
- `ai.snapshot.created`
- `ai.snapshot.rollback`

---

## 4) Logging Standards

Use structured JSON logs (no ad-hoc text-only logs for core flows).

Mandatory fields:
- timestamp
- level
- service/module
- `traceId`, `requestId`
- action name
- duration (if completed)
- status (success/failure)
- error code (if failed)
- model/provider metadata (if AI phase)

## Redaction
- redact secrets/tokens/env values before persistence
- avoid logging full file contents unless explicitly debug-enabled with controls

---

## 5) Metrics Framework

## 5.1 Product metrics
- generation success rate
- apply success rate
- run success rate
- fix success within N iterations
- time-to-first-runnable-app (TTFRA)
- rollback frequency

## 5.2 System metrics
- API p50/p95/p99 latency per endpoint
- socket delivery lag
- queue depth and wait time
- container startup time
- command runtime distributions
- error rate by service/module

## 5.3 AI metrics
- schema-valid response rate
- policy-block rate
- average changed files per plan
- token usage per request
- cost per successful run outcome

## 5.4 Security metrics
- denied path attempts
- denied command attempts
- authz failures
- suspicious usage patterns

---

## 6) Service Level Objectives (SLOs)

Example MVP SLOs (adjust after baseline):

1. `POST /api/ai/generate` success rate ≥ 97% (excluding client/network aborts)
2. Generation p95 latency ≤ 15s
3. Apply success rate ≥ 99%
4. Run log stream delivery delay p95 ≤ 1s
5. Mean time to detect critical failures < 5 min
6. Mean time to acknowledge incidents < 15 min

---

## 7) Dashboards (Minimum Set)

## 7.1 AI Workflow Dashboard
- generate/apply/run/fix funnel
- conversion between stages
- failure reasons by code

## 7.2 Runtime Health Dashboard
- container counts, starts, crashes
- run queue depth
- command timeout/OOM rates

## 7.3 Quality Dashboard
- first-pass build success rate
- avg fix iterations to success
- patch size vs success correlation

## 7.4 Cost Dashboard
- token and provider cost by day/user/workspace
- cost per successful runnable output
- anomaly detection panels

## 7.5 Security Dashboard
- blocked operations
- auth failures
- abuse flags and rate-limit hits

---

## 8) Tracing Design

Instrument distributed traces across:
1. frontend action (optional trace header)
2. API request
3. context builder
4. provider call
5. schema/policy validation
6. patch apply
7. sandbox run
8. fix iteration

Add span attributes:
- model, promptVersion, token counts
- operations count
- command count
- result code

---

## 9) Alerting Strategy

## 9.1 Critical alerts
- provider outage or high failure spike
- apply failures above threshold
- run infrastructure failure burst
- security denial surge anomaly

## 9.2 Warning alerts
- latency regression
- schema failure trend up
- cost spike over baseline
- queue backlog growth

Alert payload should include:
- timeframe
- affected endpoints/phases
- top error codes
- example request IDs for triage

---

## 10) Evaluation Framework

Two layers:
1. **Offline eval suite** (pre-release/prompt changes)
2. **Online eval monitoring** (production behavior)

## 10.1 Offline benchmark set (curated)
Include representative tasks:
- React SPA scaffold
- full-stack CRUD app
- auth + protected routes
- API integration
- bug-fix scenarios from real logs
- dependency/version mismatch repairs

Each task includes:
- prompt
- constraints
- expected quality rubric
- pass/fail checks

## 10.2 Online evaluation
- sample completed sessions for scoring
- track trend lines:
  - build success
  - user acceptance of patches
  - rollback rates
  - manual override frequency

---

## 11) Quality Rubric for Generated Output

Score each run (0–5 or pass/fail per category):
1. Functional correctness
2. Build/test success
3. Scope adherence (matches prompt/constraints)
4. Minimality of changes
5. Code quality/readability
6. Security/policy compliance

Composite quality score can drive:
- prompt updates,
- model routing choices,
- release gates.

---

## 12) Experimentation (A/B) Guidelines

Experiment candidates:
- prompt template versions
- model versions
- context selection strategies
- fix-mode strictness

Rules:
- isolate one major variable when possible
- maintain stable evaluation set
- compare by statistically meaningful sample size
- include cost and latency, not just success rate

---

## 13) Drift and Regression Detection

Detect drift by monitoring:
- schema validity drop
- first-pass success decline
- increased fix-loop count
- cost increase per success
- slower generation without quality gain

On drift:
1. freeze rollout
2. compare against last stable prompt/model
3. rollback prompt/model config if needed

---

## 14) Data Collection Boundaries

Collect only data needed for:
- functionality
- debugging
- quality improvement
- security auditing

Avoid:
- unnecessary raw file content retention
- storing sensitive user data in plain logs
- unbounded log retention

Use sampling for high-volume events where possible.

---

## 15) Example KPI Targets (MVP → Beta)

## MVP targets
- first-pass runnable success: ≥ 40%
- fix-to-success within 2 iterations: ≥ 60%
- median time prompt→build result: ≤ 4 min
- schema-valid outputs: ≥ 95%

## Beta targets
- first-pass runnable success: ≥ 60%
- fix-to-success within 2 iterations: ≥ 75%
- median time prompt→build result: ≤ 3 min
- schema-valid outputs: ≥ 98%

(Adjust with real baseline.)

---

## 16) Feedback Loops

## 16.1 User feedback
Capture:
- thumbs up/down on patch quality
- reason tags (wrong scope, broken build, poor style, etc.)
- optional free-text feedback

## 16.2 Developer feedback loop
Weekly review:
- top recurring failures
- top costly prompt patterns
- policy false positives
- backlog of prompt/schema improvements

---

## 17) Operational Runbooks

Create runbooks for:
1. Provider degradation
2. Schema failures spike
3. Sandbox instability
4. Cost anomaly
5. Security incident indicators

Each runbook includes:
- detection query/dashboard
- immediate mitigations
- rollback steps
- escalation owner

---

## 18) Release Gates Using Evaluation

Before promoting MVP → beta:
- pass offline benchmark threshold
- no critical security telemetry gaps
- acceptable cost per successful session
- stable latency/error trends for defined window (e.g., 7 days)

Before broad rollout:
- demonstrated regression controls
- incident runbooks tested
- alert noise tuned

---

## 19) Tooling Suggestions

- Metrics: Prometheus/Grafana or managed equivalent
- Logs: ELK/OpenSearch/datadog-like stack
- Tracing: OpenTelemetry + Jaeger/Tempo/vendor APM
- Feature flags/experiments: LaunchDarkly or internal flags
- Data analysis: warehouse + scheduled quality reports

---

## 20) Observability & Evaluation Checklist (MVP)

- [ ] Structured logs for all AI workflow phases.
- [ ] Correlated trace/request/session IDs end-to-end.
- [ ] Dashboards for workflow, runtime, quality, cost, security.
- [ ] Alerts for critical failures and anomaly spikes.
- [ ] Offline evaluation set and baseline scores.
- [ ] Online quality KPIs tracked from day one.
- [ ] Feedback capture integrated in UI.
- [ ] Release gate criteria documented and enforced.