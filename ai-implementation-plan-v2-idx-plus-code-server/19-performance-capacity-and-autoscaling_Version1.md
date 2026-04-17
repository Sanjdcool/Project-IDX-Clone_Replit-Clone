# 19 — Performance, Capacity, and Autoscaling

## Status
Draft (target: SRE + infra + platform sign-off)

## Date
2026-04-16

## Purpose

Define performance targets, capacity planning methods, and autoscaling strategies for control plane and workspace runtime layers in the IDX + code-server integrated platform.

---

## 1) Objectives

1. Deliver responsive UX for key developer workflows.
2. Prevent resource exhaustion and noisy-neighbor impact.
3. Scale efficiently with predictable cost behavior.
4. Maintain reliability during spikes and failure scenarios.
5. Align scaling decisions with SLO and error budget policies.

---

## 2) Performance-Critical User Journeys

1. Open dashboard/project list
2. Create/start workspace
3. Connect IDE and terminal
4. Run command and receive output
5. Open and refresh preview URL
6. Execute AI action with tool calls
7. Stop/resume workspace
8. Snapshot/restore operations

All targets should map to one or more of these journeys.

---

## 3) Baseline Performance Targets (Initial)

> Final numbers calibrated after load-testing baseline.

## 3.1 Control plane API
- critical endpoint p95 latency target by endpoint class
- availability target aligned with SLO doc

## 3.2 Workspace startup
- warm start p95 target
- cold start p95 target
- startup success rate threshold

## 3.3 IDE connectivity
- connect handshake p95 target
- websocket stability threshold

## 3.4 Preview
- preview route p95 latency target
- success/error thresholds

## 3.5 AI tool execution
- tool-call latency budget by tool category
- max end-to-end turn latency target bands

---

## 4) Workload Characterization

## 4.1 Demand dimensions

1. Active users (concurrent sessions)
2. Active workspaces
3. Concurrent IDE websocket connections
4. Command execution throughput
5. Preview traffic rate
6. AI tool call volume and burstiness
7. Snapshot frequency and size distribution

## 4.2 Usage profiles

- light individual projects
- medium team projects
- heavy enterprise workloads
- burst events (classrooms, workshops, launch spikes)

---

## 5) Capacity Model

## 5.1 Capacity units (recommended)

1. **Control plane units**
   - requests/sec, CPU/memory, DB QPS
2. **Runtime units**
   - workspace slots per node/pool
3. **Connection units**
   - websocket concurrency per gateway pod
4. **Storage units**
   - IOPS/throughput for volumes and snapshots

## 5.2 Headroom policy

- maintain reserved headroom for burst + failover scenarios.
- separate baseline headroom by environment (prod > staging > dev).

---

## 6) Autoscaling Strategy

## 6.1 Control plane autoscaling

Scale on:
1. CPU/memory
2. request rate
3. p95 latency saturation signals
4. queue depth for async workers

## 6.2 IDE gateway autoscaling

Scale on:
1. active websocket count
2. connection establishment rate
3. proxy latency/error rates
4. CPU/network saturation

## 6.3 Workspace runtime autoscaling

1. Node pool autoscaling based on pending workspace scheduling pressure.
2. Optional warm pool for faster startup latency.
3. Workspace placement policy to reduce fragmentation and hotspot nodes.

---

## 7) Queue and Backpressure Controls

1. Queue lifecycle-heavy operations (create/start/snapshot).
2. Apply admission throttles under high contention.
3. Provide user-visible queue state and ETA hints when delayed.
4. Implement priority classes (e.g., resume > cold create, admin overrides).

---

## 8) Database and Cache Performance

1. Index critical query paths for workspace/project/session lookups.
2. Protect DB with connection pooling and query timeout policies.
3. Cache hot metadata responsibly (bounded TTL + invalidation rules).
4. Separate operational reads from analytical/reporting workloads where possible.

---

## 9) Storage Performance Considerations

1. Match volume classes to workspace profile tiers.
2. Track mount latency, IOPS saturation, throughput bottlenecks.
3. Snapshot upload/download throughput monitoring and retries.
4. Avoid shared storage contention hotspots via placement policies.

---

## 10) Runtime Resource Profiles

Define workspace compute tiers (example):
1. small
2. medium
3. large
4. custom/enterprise

Each tier specifies:
- CPU/memory limits,
- optional burst behavior,
- max processes/ports,
- storage defaults.

---

## 11) Noisy-Neighbor Mitigation

1. Hard resource limits per workspace.
2. Fair scheduling and per-tenant quotas.
3. Detect abusive workloads (CPU thrash, excessive forks, network abuse).
4. Automated throttling/suspension policy for repeated violations.

---

## 12) Load Testing Strategy

## 12.1 Test types

1. steady-state load tests
2. spike tests
3. soak/endurance tests
4. failure-injection tests under load

## 12.2 Scenarios

- mass workspace start at top of hour
- concurrent IDE connect surges
- simultaneous preview traffic spikes
- AI-tool heavy coding session bursts
- snapshot storm conditions

---

## 13) Performance Regression Guardrails

1. Benchmark critical flows in CI/staging.
2. Track regression thresholds per release.
3. Block release when critical regression exceeds policy.
4. Maintain performance changelog and remediation owner.

---

## 14) Cost-Performance Optimization

1. Use autoscaling with floor/ceiling bounds.
2. Evaluate warm pool size vs startup latency trade-off.
3. Right-size default workspace tiers from observed usage.
4. Implement idle workspace policies (auto-stop/hibernate) with UX safeguards.
5. Optimize telemetry sampling to reduce overhead costs.

---

## 15) Failure and Degradation Modes

1. Controlled admission throttling under capacity stress.
2. Graceful degradation of non-critical features first.
3. Preserve core coding loop (open IDE, edit, save, run) as priority.
4. Use circuit breakers/timeouts for unstable dependencies.
5. Fast rollback for scaling policy misconfiguration.

---

## 16) Capacity Review Cadence

1. Weekly trend review:
   - utilization, saturation, growth rates
2. Monthly forecast:
   - projected demand vs provisioned capacity
3. Pre-launch and pre-event readiness checks
4. Post-incident capacity reassessment

---

## 17) Implementation Checklist

- [ ] Define numeric performance targets per critical journey
- [ ] Implement autoscaling policies for all core planes
- [ ] Configure queue/backpressure controls with priority classes
- [ ] Establish runtime tier profiles and quota mapping
- [ ] Build load test suite and recurring schedule
- [ ] Implement regression gates in release pipeline
- [ ] Create capacity forecast dashboard and alerts
- [ ] Run failover + spike game days before beta/GA

---

## 18) Acceptance Criteria

1. Platform meets agreed p95 latency and success targets for core journeys.
2. Autoscaling handles expected burst patterns without prolonged degradation.
3. Capacity exhaustion risks are detected early with actionable alerts.
4. Noisy-neighbor effects are controlled via policy and resource enforcement.
5. Performance regressions are caught before production rollout.

---

## 19) Dependencies

- `18-observability-slos-and-alerting.md`
- `20-disaster-recovery-backups-and-failover.md`
- `21-mvp-scope-definition-v2.md`
- `24-environment-strategy-dev-staging-prod.md`
- `29-pricing-metering-and-quota-enforcement.md`

---

## 20) Next Document

Proceed to:
`20-disaster-recovery-backups-and-failover.md`