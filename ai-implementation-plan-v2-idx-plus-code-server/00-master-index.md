# AI Implementation Plan V2 — IDX + code-server (Master Index)

## Purpose

This V2 plan defines how to build one production-grade product by integrating:

- `Sanjdcool/Project-IDX-Clone_Replit-Clone` (control plane + product UX), and
- `Sanjdcool/code-server_IDX-project` (browser IDE runtime),

while preserving the existing V1 plan folder unchanged.

This folder is intentionally separate from `ai-implementation-plan/` to avoid disruption.

---

## Repositories in Scope

1. Product/control plane:
   - `Sanjdcool/Project-IDX-Clone_Replit-Clone`
2. IDE runtime:
   - `Sanjdcool/code-server_IDX-project`

---

## Planning Principles (V2)

1. **Service-oriented integration, not codebase collision**  
   Keep repos logically separate; integrate through contracts/APIs.
2. **Production-first architecture**  
   Multi-workspace lifecycle, security isolation, observability, SLOs.
3. **Team execution readiness**  
   Clear epics, ownership boundaries, milestone gates.
4. **Extensibility**  
   Enable future collaboration features, enterprise controls, and scale.
5. **License/upgrade safety**  
   Minimize deep fork drift; isolate code-server customizations.

---

## Document Map (V2)

### Foundation
- `00-master-index.md` (this file)
- `01-hybrid-architecture-decision-record.md`
- `02-system-context-and-service-boundaries.md`
- `03-repo-strategy-and-ownership-model.md`

### Integration and Runtime
- `04-code-server-integration-spec.md`
- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `08-workspace-storage-filesystem-and-snapshots.md`
- `09-runtime-execution-preview-and-port-management.md`

### AI Product Layer
- `10-ai-agent-tooling-contracts.md`
- `11-context-engine-indexing-and-retrieval.md`
- `12-prompt-orchestration-and-guardrails.md`
- `13-code-apply-git-ops-and-conflict-handling.md`

### Security, Compliance, and Governance
- `14-security-isolation-and-sandbox-hardening.md`
- `15-secrets-management-and-egress-controls.md`
- `16-audit-logging-policy-and-governance.md`
- `17-license-compliance-and-third-party-policy.md`

### Platform Reliability and Scale
- `18-observability-slos-and-alerting.md`
- `19-performance-capacity-and-autoscaling.md`
- `20-disaster-recovery-backups-and-failover.md`

### Delivery and Productization
- `21-mvp-scope-definition-v2.md`
- `22-epics-stories-and-team-allocation.md`
- `23-implementation-sequence-90-day-plan.md`
- `24-environment-strategy-dev-staging-prod.md`
- `25-ci-cd-release-and-versioning-strategy.md`
- `26-qa-strategy-e2e-nfr-and-security-tests.md`
- `27-beta-rollout-and-feedback-operations.md`
- `28-ga-readiness-checklist.md`

### Operations and Business Readiness
- `29-pricing-metering-and-quota-enforcement.md`
- `30-support-runbooks-and-incident-response.md`
- `31-risk-register-and-mitigation-tracker.md`
- `32-kpi-dashboard-and-weekly-operating-rhythm.md`

### Migration from Existing V1 Plan
- `33-v1-to-v2-transition-mapping.md`
- `34-cutover-plan-and-deprecation-path.md`
- `35-open-decisions-and-architecture-rfcs.md`

---

## Execution Order (Recommended)

1. `01` → `03` (architecture/repo model decisions)
2. `04` → `09` (runtime and integration backbone)
3. `10` → `13` (AI layer and developer workflows)
4. `14` → `17` (security/compliance hardening)
5. `18` → `20` (reliability/scale controls)
6. `21` → `28` (delivery, QA, rollout)
7. `29` → `35` (business ops, transition, governance)

---

## Definition of Success (V2)

The integrated product is successful when:

1. Users can create a workspace, open IDE, code, run, preview, and deploy in one flow.
2. AI agent can safely read/write files and run controlled commands in workspace context.
3. Multi-tenant isolation and policy enforcement are verifiable and auditable.
4. SLOs and incident response standards are in place before GA.
5. Team can deliver continuously with clear ownership and release safety.

---

## Change Management

- V1 folder remains source of historical planning context.
- V2 folder becomes source of truth for the integrated IDX + code-server product.
- Any major architecture changes after V2 kickoff must be captured in:
  - `35-open-decisions-and-architecture-rfcs.md`.

---

## Next Document

Proceed to:
`01-hybrid-architecture-decision-record.md`