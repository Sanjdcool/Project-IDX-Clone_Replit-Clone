# 18 — Observability, SLOs, and Alerting

## Status
Draft (target: SRE + platform + security sign-off)

## Date
2026-04-16

## Purpose

Define the observability foundation, service level objectives (SLOs), error budgets, and alerting strategy for reliable operation of the IDX + code-server integrated platform.

---

## 1) Reliability Objectives

1. Detect incidents quickly with actionable signals.
2. Maintain user-facing reliability targets across core journeys.
3. Use error budgets to balance feature velocity and stability.
4. Provide end-to-end traceability across control plane and runtime.
5. Enable data-driven operations, capacity planning, and postmortems.

---

## 2) Core User Journeys to Protect

1. Sign in and access project dashboard
2. Create/start workspace successfully
3. Open IDE session
4. Run command and view output
5. Open app preview URL
6. Execute AI-assisted action safely
7. Save code and persist changes
8. Stop/resume workspace without data loss

SLOs are anchored to these journeys.

---

## 3) Telemetry Pillars

## 3.1 Metrics
- service health, latency, throughput, saturation, error rates

## 3.2 Logs
- structured, correlated, policy-aware event records

## 3.3 Traces
- distributed request flow from user action to runtime execution

## 3.4 Events
- lifecycle/security/audit domain events for state transitions

All pillars must share correlation IDs (`request_id`, `trace_id`, `workspace_id`, `org_id` where applicable).

---

## 4) Observability Architecture

1. Instrumentation in all services (control plane, gateway, runtime, tool broker).
2. Central metrics store + dashboards.
3. Central log pipeline with retention tiers.
4. Distributed tracing backend.
5. Alert manager integrated with on-call routing.
6. Long-term storage for audit-critical telemetry subsets.

---

## 5) Proposed SLI/SLO Set (Initial)

> Final numeric targets may be tuned after baseline measurement.

## 5.1 Workspace Lifecycle

1. **SLI:** Workspace start success rate  
   **SLO:** >= 99.5% (rolling 30 days)

2. **SLI:** Workspace start latency p95 (cold/warm tracked separately)  
   **SLO:** Target set per environment/profile

## 5.2 IDE Connectivity

1. **SLI:** IDE connection success rate  
   **SLO:** >= 99.5%

2. **SLI:** IDE websocket stability (unexpected disconnect rate)  
   **SLO:** <= defined threshold

## 5.3 Preview Availability

1. **SLI:** Preview route success rate  
   **SLO:** >= 99.0–99.5% (tiered by plan/env)

2. **SLI:** Preview route latency p95  
   **SLO:** threshold by region/profile

## 5.4 AI Tooling Execution

1. **SLI:** Policy-eligible tool call success rate  
   **SLO:** >= defined threshold

2. **SLI:** Tool execution latency p95 by category  
   **SLO:** bounded by command class

## 5.5 Control Plane APIs

1. **SLI:** API availability for critical endpoints  
   **SLO:** >= 99.9%

2. **SLI:** API latency p95 for critical endpoints  
   **SLO:** endpoint-specific targets

---

## 6) Error Budget Policy

1. Define error budget per SLO over rolling window.
2. Burn-rate monitoring:
   - fast burn (urgent response)
   - slow burn (planned mitigation)
3. If budget exhausted:
   - enforce reliability freeze or reduced feature rollout rate,
   - prioritize stability backlog until recovery.

---

## 7) Golden Signals by Service

For each service track:

1. Latency
2. Traffic
3. Errors
4. Saturation

Apply to:
- API gateway,
- workspace orchestrator,
- IDE gateway/proxy,
- runtime nodes,
- AI orchestration/tool broker,
- storage and queue dependencies.

---

## 8) Structured Logging Standard

Every log record should include:

- timestamp (UTC)
- severity
- service/component
- request_id/trace_id
- org_id/workspace_id/project_id (when applicable)
- event/action
- outcome/status
- error_code (if failure)

Sensitive values must be redacted by policy.

---

## 9) Traceability Standard

1. Propagate trace context across all internal service hops.
2. Instrument key spans:
   - auth check,
   - policy evaluation,
   - workspace provision/start,
   - route bind,
   - tool execution,
   - preview access.
3. Sample intelligently (head/tail strategies) to control cost while preserving incident utility.

---

## 10) Alerting Strategy

## 10.1 Alert classes

1. **Critical (P1):** user-facing outage/security incident/high burn rate
2. **High (P2):** significant degradation with broad impact
3. **Medium (P3):** localized or recoverable issues
4. **Low (P4):** informational/trend warnings

## 10.2 Alert quality rules

- actionable and owned
- include probable impact and runbook link
- avoid noisy non-actionable pages
- deduplicate related alerts

---

## 11) Recommended Alert Catalog (Initial)

1. Workspace start failure rate spike
2. IDE connect failure spike
3. Websocket disconnect anomaly
4. Preview 5xx spike
5. Orchestrator stuck-state backlog growth
6. Token validation failure surge
7. Tool broker denial/error anomaly
8. Storage snapshot/restore failure spike
9. Audit pipeline ingestion lag/drop
10. Error budget fast-burn alert per critical SLO

---

## 12) Dashboards (Required)

1. Executive reliability overview (SLO/error budgets)
2. User journey dashboard (create -> IDE -> run -> preview)
3. Service health dashboard per component
4. Security signal dashboard
5. Cost/telemetry volume dashboard
6. On-call incident triage dashboard

---

## 13) On-Call and Incident Integration

1. Alert routing by service ownership.
2. Escalation policy with time-bound acknowledgments.
3. Runbook linkage mandatory for P1/P2 alerts.
4. Post-incident review includes telemetry gap analysis.
5. Track MTTA/MTTR and recurrence indicators.

---

## 14) Data Retention and Cost Controls

1. Tiered retention:
   - high-cardinality short-term,
   - aggregated long-term.
2. Sampling and cardinality controls for metrics/traces.
3. Log retention by category (operational vs audit-critical).
4. Cost guardrails with telemetry budget monitoring.

---

## 15) Implementation Checklist

- [ ] Define and approve SLI/SLO catalog with owners
- [ ] Instrument all critical services with metrics/logs/traces
- [ ] Implement correlation ID propagation end-to-end
- [ ] Build required dashboards and burn-rate views
- [ ] Configure alert rules with severity and runbook links
- [ ] Establish on-call rotations and escalation policy
- [ ] Implement error budget governance workflow
- [ ] Validate observability in game days and incident drills

---

## 16) Acceptance Criteria

1. Critical user journeys have measurable SLIs and owned SLOs.
2. Alerts are actionable, low-noise, and tied to runbooks.
3. End-to-end tracing supports root-cause analysis across services.
4. Error budgets actively influence release and reliability decisions.
5. Incident response metrics improve over successive cycles.

---

## 17) Dependencies

- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `09-runtime-execution-preview-and-port-management.md`
- `16-audit-logging-policy-and-governance.md`
- `19-performance-capacity-and-autoscaling.md`
- `30-support-runbooks-and-incident-response.md`

---

## 18) Next Document

Proceed to:
`19-performance-capacity-and-autoscaling.md`