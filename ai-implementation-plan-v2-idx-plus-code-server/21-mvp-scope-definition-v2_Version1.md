# 21 — MVP Scope Definition (V2)

## Status
Draft (target: product + engineering + design sign-off)

## Date
2026-04-16

## Purpose

Define the exact MVP scope for the IDX + code-server integrated platform, including what is in, what is out, release gates, and success criteria for beta readiness.

---

## 1) MVP Outcome Statement

Deliver a reliable, secure, single-workflow cloud development experience where a user can:

1. create/open a project,
2. start a workspace,
3. open IDE in browser,
4. edit code with AI assistance,
5. run and preview app,
6. save progress with persistent storage,
7. perform basic git workflows.

---

## 2) MVP Principles

1. Prioritize end-to-end reliability over breadth.
2. Default to secure-by-design and least privilege.
3. Ship smallest lovable developer loop first.
4. Use explicit guardrails for mutating AI actions.
5. Defer non-essential complexity to post-MVP phases.

---

## 3) MVP In-Scope Capabilities

## 3.1 Core Platform

- User authentication (baseline, non-enterprise SSO acceptable for MVP)
- Project and workspace creation
- Workspace lifecycle (start/stop/restart/delete)
- Workspace persistence (volume-backed)
- Browser IDE access via secure route binding

## 3.2 IDE + Runtime

- code-server integration with stable editor/terminal
- Workspace-scoped command execution
- Preview routing for app ports (private by default)
- Basic runtime health/status surfaced in UI

## 3.3 AI Developer Workflow

- AI chat interface in product
- File read/write/patch tools
- Command execution tools with policy checks
- Basic git helper tools (status/diff/add/commit)
- Guardrails + confirmation for high-risk operations

## 3.4 Data and Recovery

- Snapshot create + restore (filesystem level)
- Core observability (metrics/logs/traces)
- Audit events for critical actions

## 3.5 Security Baseline

- Short-lived scoped IDE access tokens
- Workspace isolation controls
- Secret management baseline
- Egress restrictions baseline
- Structured policy-deny behavior

---

## 4) MVP Out-of-Scope (Explicit)

1. Real-time multiplayer collaborative editing
2. Marketplace-scale extension ecosystem
3. Advanced enterprise SSO (SAML/SCIM) full rollout
4. Multi-region active-active global architecture
5. Public preview sharing by default
6. Full CI/CD and deployment platform replacement
7. Large-scale org governance automation features
8. Fine-tuned model training/custom model hosting
9. Mobile-native IDE experience

These are tracked as post-MVP roadmap candidates.

---

## 5) MVP User Roles Supported

1. **Individual developer** (primary)
2. **Small team member** (secondary)
3. **Org admin-lite** (basic member/project controls)

Full enterprise admin controls can be phased post-MVP.

---

## 6) Must-Have User Journeys (Release-Critical)

1. Sign in -> create project -> start workspace -> open IDE.
2. Edit files -> run app -> open preview -> iterate.
3. Ask AI to modify code -> review/apply changes safely.
4. Commit code changes to branch from workspace.
5. Stop workspace -> resume later with persisted files intact.
6. Create and restore snapshot successfully.

If any journey is unreliable, MVP is not launch-ready.

---

## 7) MVP Non-Functional Requirements

1. Reliability targets aligned with initial SLOs for core journeys.
2. Security controls from docs 05/14/15 active and validated.
3. Audit logging for critical identity/mutation/admin actions.
4. Operational dashboards and on-call runbooks available.
5. Performance acceptable for defined initial concurrency targets.

---

## 8) MVP Feature Flags and Rollout Controls

1. AI mutating actions behind controllable feature flags.
2. Preview visibility controls default private.
3. Risky actions gated by confirmation policy.
4. Runtime/image version rollout with staged promotion.
5. Kill switch for unstable subsystems (AI tools, preview exposure, etc.).

---

## 9) Dependencies Required Before MVP Launch

1. Control plane + runtime integration complete (Doc 04).
2. Auth/session bridging and token validation complete (Doc 05).
3. Orchestrator lifecycle reliability complete (Doc 06).
4. Routing/proxy hardening complete (Doc 07).
5. Storage/snapshot baseline complete (Doc 08).
6. Security baseline and audit controls complete (Docs 14–16).
7. Observability + alerting operational (Doc 18).

---

## 10) MVP Risks to Track

1. Workspace startup latency under burst load.
2. Route/token edge-case failures causing IDE connect issues.
3. AI tool misuse or false-positive guardrail blocking.
4. Snapshot restore edge-case integrity failures.
5. Runtime drift from upstream code-server updates.

Each mapped to mitigation owners in risk register.

---

## 11) Beta Entrance Criteria

To enter beta:

- [ ] All must-have user journeys pass end-to-end tests
- [ ] P0/P1 security findings resolved or formally accepted with mitigation
- [ ] Error budget burn stable within agreed threshold
- [ ] On-call rotation + incident runbooks active
- [ ] Backup/restore drill completed successfully
- [ ] Legal/license compliance checks passed
- [ ] Product support docs and known-limits docs published

---

## 12) MVP Success Metrics (Initial)

1. Workspace start success rate
2. IDE connection success rate
3. AI-assisted task completion proxy rate
4. Preview success rate
5. Snapshot restore success rate
6. 7-day retention of active users (product KPI)
7. Critical incident frequency and MTTR trend

---

## 13) De-scope Rules (If Timeline Pressure)

If needed to protect launch quality, de-scope in this order:

1. Advanced git automation beyond basic flow
2. Extended snapshot features (keep core snapshot/restore)
3. Non-critical UI polish and advanced customization
4. Optional AI automation chains (retain safe core tooling)

Do **not** de-scope core security, audit, or reliability controls.

---

## 14) Implementation Checklist

- [ ] Freeze MVP feature list and ownership
- [ ] Map all MVP features to epics/stories with estimates
- [ ] Define and automate MVP acceptance test suite
- [ ] Configure launch feature flags and kill switches
- [ ] Validate non-functional requirements in staging
- [ ] Run beta readiness review and sign-off meeting
- [ ] Publish MVP known limitations and support playbooks

---

## 15) Acceptance Criteria

1. MVP scope is unambiguous and approved by product/engineering/security.
2. All in-scope capabilities are testable and mapped to owners.
3. Out-of-scope items are explicitly deferred with roadmap traceability.
4. Beta entrance criteria are measurable and enforced.
5. Launch decision can be made on objective readiness evidence.

---

## 16) Dependencies

- `04` through `20` (architecture, security, reliability, DR foundation)
- `22-epics-stories-and-team-allocation.md`
- `23-90-day-delivery-roadmap-and-milestones.md`
- `28-ga-readiness-checklist.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 17) Next Document

Proceed to:
`22-epics-stories-and-team-allocation.md`