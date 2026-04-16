# 20 — Master Index

## 1) Purpose

Single navigation file for the entire AI implementation plan.

Use this as:
- a reading guide,
- an execution roadmap,
- a handoff index for product, engineering, QA, and security teams.

---

## 2) Document Inventory

### Planning and Product
1. `00-implementation-checklist.md`  
   Actionable master checklist for implementation.

2. `01-product-requirements.md`  
   Product vision, goals, user stories, MVP acceptance criteria.

### Architecture and Design
3. `02-system-architecture.md`  
   End-to-end architecture, trust boundaries, lifecycle flows.

4. `03-backend-design.md`  
   Backend APIs, orchestration, schemas, policy and persistence patterns.

5. `04-frontend-design.md`  
   Frontend UX architecture, component map, state model, socket handling.

6. `05-tooling-and-sandbox-execution.md`  
   Sandbox runtime model, command policy, resource and logging controls.

7. `06-llm-integration-and-prompts.md`  
   Provider abstraction, prompt templates, context strategy, output contracts.

8. `07-security-and-governance.md`  
   Threat model, policy controls, incident response, governance rules.

9. `08-observability-and-evaluation.md`  
   Metrics, traces, dashboards, alerts, evaluation frameworks.

### Delivery and Execution
10. `09-mvp-delivery-plan.md`  
    Sprint-phased delivery strategy and go/no-go criteria.

11. `10-future-extensions.md`  
    Post-MVP evolution roadmap and strategic expansion themes.

### Contracts and Data
12. `11-api-contracts-openapi.yaml`  
    OpenAPI spec for all core AI endpoints.

13. `12-socket-events-contract.md`  
    Socket.IO event envelope, event types, ordering and reconnect semantics.

14. `13-database-schema.sql`  
    PostgreSQL schema for sessions, patches, runs, fixes, snapshots, audit.

### Team Task Breakdown
15. `14-backend-task-breakdown.md`  
    Backend implementation tasks by endpoint/service/module.

16. `15-frontend-task-breakdown.md`  
    Frontend implementation tasks by component/store/hook.

17. `16-prd-to-engineering-mapping.md`  
    Requirement traceability matrix (PRD → engineering tasks/tests).

18. `17-engineering-roadmap-kanban.md`  
    Ready-to-copy epic/story/task board structure.

### QA and Release
19. `18-qa-test-cases.md`  
    Detailed functional, security, reliability, performance test cases.

20. `19-release-readiness-checklist.md`  
    Final release gate checklist and sign-off template.

---

## 3) Recommended Reading Order (By Role)

## Product Managers
1. `01-product-requirements.md`
2. `09-mvp-delivery-plan.md`
3. `16-prd-to-engineering-mapping.md`
4. `19-release-readiness-checklist.md`
5. `10-future-extensions.md`

## Backend Engineers
1. `02-system-architecture.md`
2. `03-backend-design.md`
3. `06-llm-integration-and-prompts.md`
4. `05-tooling-and-sandbox-execution.md`
5. `14-backend-task-breakdown.md`
6. `11-api-contracts-openapi.yaml`
7. `13-database-schema.sql`

## Frontend Engineers
1. `04-frontend-design.md`
2. `12-socket-events-contract.md`
3. `15-frontend-task-breakdown.md`
4. `11-api-contracts-openapi.yaml`
5. `18-qa-test-cases.md`

## Security / DevOps / SRE
1. `07-security-and-governance.md`
2. `05-tooling-and-sandbox-execution.md`
3. `08-observability-and-evaluation.md`
4. `19-release-readiness-checklist.md`
5. `13-database-schema.sql`

## QA Engineers
1. `01-product-requirements.md`
2. `16-prd-to-engineering-mapping.md`
3. `18-qa-test-cases.md`
4. `19-release-readiness-checklist.md`

---

## 4) Recommended Execution Order (Implementation)

## Phase 0 — Alignment
- `00-implementation-checklist.md`
- `01-product-requirements.md`
- `16-prd-to-engineering-mapping.md`

## Phase 1 — Contracts and Core Architecture
- `02-system-architecture.md`
- `11-api-contracts-openapi.yaml`
- `12-socket-events-contract.md`
- `13-database-schema.sql`

## Phase 2 — Build Core Features
- `03-backend-design.md`
- `04-frontend-design.md`
- `14-backend-task-breakdown.md`
- `15-frontend-task-breakdown.md`

## Phase 3 — Safety and Reliability
- `05-tooling-and-sandbox-execution.md`
- `06-llm-integration-and-prompts.md`
- `07-security-and-governance.md`

## Phase 4 — Measurement and Quality
- `08-observability-and-evaluation.md`
- `18-qa-test-cases.md`

## Phase 5 — Delivery and Launch
- `09-mvp-delivery-plan.md`
- `17-engineering-roadmap-kanban.md`
- `19-release-readiness-checklist.md`

## Phase 6 — Post-MVP Planning
- `10-future-extensions.md`

---

## 5) Milestone-to-Document Mapping

| Milestone | Required Docs |
|---|---|
| API Contract Freeze | `11`, `12`, `03` |
| Data Model Freeze | `13`, `03` |
| MVP Feature Complete | `03`, `04`, `05`, `06`, `14`, `15` |
| Security Baseline Complete | `07`, `05`, `19` |
| Observability Baseline Complete | `08`, `19` |
| QA Sign-off | `18`, `19` |
| Beta Launch Decision | `09`, `19`, `16` |

---

## 6) Operational Cadence (Suggested)

Weekly:
- Update `17-engineering-roadmap-kanban.md` status
- Refresh KPI snapshot from `08-observability-and-evaluation.md`
- Reconcile requirement coverage via `16-prd-to-engineering-mapping.md`
- Re-check release blockers in `19-release-readiness-checklist.md`

---

## 7) Definition of “Plan Complete”

This plan set is complete when:
- all docs exist and are versioned together,
- contracts (`11`, `12`) align with implementation,
- task breakdowns (`14`, `15`, `17`) are actively maintained,
- QA and release gates (`18`, `19`) are adopted in CI/release process.

---

## 8) Suggested Next Action

Start execution with:
1. `00-implementation-checklist.md`
2. `11-api-contracts-openapi.yaml`
3. `14-backend-task-breakdown.md`
4. `15-frontend-task-breakdown.md`

Then schedule a contract review meeting to lock API/event/data contracts before coding at scale.