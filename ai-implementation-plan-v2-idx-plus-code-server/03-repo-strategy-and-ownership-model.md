# 03 — Repo Strategy and Ownership Model

## Status
Draft (target: engineering management approval)

## Date
2026-04-16

## Purpose

Define how engineering work is split across repositories, who owns what, how integration is managed, and how to avoid drift while shipping one unified product.

---

## 1) Repositories in Scope

## 1.1 Product Control Plane Repo
- **Repo:** `Sanjdcool/Project-IDX-Clone_Replit-Clone`
- **Role:** Source of truth for product logic and platform control plane.

## 1.2 IDE Runtime Repo
- **Repo:** `Sanjdcool/code-server_IDX-project`
- **Role:** Source of truth for code-server runtime behavior and IDE-specific patches.

---

## 2) Strategy Decision

We will run a **dual-repo product strategy** with explicit contracts, not immediate monorepo consolidation.

### Why dual-repo is chosen
1. Reduces accidental coupling between product logic and IDE internals.
2. Enables independent release cadence per domain.
3. Minimizes large-scale refactor risk during critical product build phase.
4. Keeps code-server fork patch surface constrained and auditable.

### When reconsider monorepo
Only after:
- contracts stabilize,
- runtime patch footprint is low,
- CI/CD and release governance are mature,
- team agrees on benefits outweighing migration cost.

---

## 3) Ownership Matrix

| Capability | Primary Repo | Primary Team | Backup Team |
|---|---|---|---|
| Auth, Org, Projects, Roles | IDX repo | Platform Backend | Security |
| Workspace Metadata + APIs | IDX repo | Platform Backend | Infra |
| AI Chat/Orchestration | IDX repo | AI Team | Platform Backend |
| Billing/Metering/Plans | IDX repo | Product Backend | Finance Ops |
| Web UX Shell + Dashboards | IDX repo | Product Frontend | Platform Frontend |
| Workspace Provisioning Control | IDX repo | Platform Backend | Infra |
| code-server lifecycle behavior | code-server repo | Runtime Team | Platform Backend |
| IDE custom UI patches | code-server repo | Runtime Team | Product Frontend |
| Runtime image build scripts | code-server repo | Runtime/Infra | SRE |
| Proxy routing and workspace ingress | shared infra code (IDX-owned config) | Infra | Platform Backend |
| Telemetry schema contracts | IDX repo (canonical) | SRE/Platform | Runtime Team |

---

## 4) Folder Ownership Conventions

## 4.1 IDX Repo (recommended ownership)

- `frontend/` → Product Frontend Team
- `backend/` → Platform Backend + Product Backend
- `infra/` (if present/add) → Infra/SRE
- `contracts/` (recommended add) → Shared ownership (platform + runtime + security)
- `ai-implementation-plan-v2-idx-plus-code-server/` → Architecture/PMO ownership

## 4.2 code-server Repo (recommended ownership)

- `src/` runtime/editor logic → Runtime Team
- `patches/` → Runtime Team with Architecture approval
- `docs/` integration docs → Runtime + Platform co-owned
- `ci/` runtime pipeline → Runtime + SRE

---

## 5) Integration Contract Governance

All cross-repo integration must be documented and versioned in a shared contract model.

## Required contract categories

1. **Auth/session bridge contract**
2. **Workspace lifecycle contract**
3. **Runtime environment contract**
4. **Proxy routing and access token contract**
5. **Telemetry/event schema contract**
6. **Compatibility/version matrix**

## Contract versioning rule
- Semantic versioning (`major.minor.patch`)
- Breaking changes require:
  - compatibility plan,
  - deprecation window,
  - staged rollout,
  - rollback path.

---

## 6) Branching and Release Model

## 6.1 IDX Repo
- `main` = stable integration branch
- `develop` (optional) = integration staging
- feature branches per ticket/epic
- release branches for major milestones (`release/v2-beta`, etc.)

## 6.2 code-server Repo
- `main` tracks runtime branch for product
- upstream sync branches for periodic merge/rebase strategy
- isolated feature branches for patches
- tag runtime builds used by IDX control plane (`runtime-vX.Y.Z`)

---

## 7) Upstream Sync Policy (code-server fork)

To prevent long-term drift:

1. Keep patches minimal and documented.
2. Sync upstream regularly (recommended every 2–4 weeks).
3. Maintain patch changelog with rationale and owner.
4. Run compatibility test suite before promoting new runtime image.
5. Avoid invasive modifications unless product-critical.

---

## 8) CI/CD Ownership Split

## IDX pipeline responsibilities
- API/web build and tests
- contract tests against runtime mocks/real runtime staging
- migration and backend deployment
- security scans and API policy checks

## code-server pipeline responsibilities
- runtime compile/build/test
- IDE patch validation
- runtime image publishing
- vulnerability scanning for runtime image

## cross-repo integration pipeline (required)
- run end-to-end smoke tests:
  - workspace launch
  - IDE connection
  - file edit/save
  - run/preview
  - AI tool operation
- run compatibility matrix checks (IDX version x runtime version)

---

## 9) Pull Request and Review Governance

## Mandatory reviewers

### IDX repo PRs affecting integration
- Platform Backend reviewer
- Runtime Team reviewer
- Security reviewer (if auth/routing/policy touched)

### code-server PRs affecting platform behavior
- Runtime Team reviewer
- Platform Backend reviewer
- SRE reviewer (if deployment/runtime infra touched)

## PR policy
- No direct merge to protected branches.
- CI green + required approvals only.
- For boundary/contract changes, link to ADR or RFC.

---

## 10) Decision Authority Model (RACI-style summary)

| Decision Area | Responsible | Accountable | Consulted | Informed |
|---|---|---|---|---|
| Product experience | Product FE/BE | Product Eng Lead | Platform/AI | All teams |
| Runtime internals | Runtime Team | Platform Architect | SRE/Security | Product teams |
| Auth/security boundaries | Platform/Security | Security Lead | Runtime/Infra | All teams |
| Infra topology | Infra/SRE | Infra Lead | Platform/Runtime | Product teams |
| Contract schema changes | Platform + Runtime | Architect | Security/SRE | All teams |
| Release go/no-go | QA + Eng Leads | CTO/Head Eng | Security/Product | Stakeholders |

---

## 11) Repo-to-Repo Dependency Rules

1. IDX repo must consume **tagged runtime versions** only (not arbitrary commit SHAs in production).
2. Runtime repo cannot assume unpublished IDX APIs.
3. Integration config changes must be backward-compatible within approved window.
4. Any emergency hotfix requiring both repos must use coordinated release playbook.

---

## 12) Documentation Standards

Each repo must include:

1. Architecture overview
2. Local dev setup
3. Integration points
4. Version compatibility table
5. Troubleshooting guide
6. Security considerations
7. Change log for integration-impacting updates

---

## 13) Risk Controls for Ownership Model

| Risk | Control |
|---|---|
| Ambiguous ownership | explicit ownership matrix + codeowners |
| Integration breakage | contract tests + matrix compatibility gates |
| Runtime fork drift | upstream sync cadence + patch policy |
| Slow cross-team merges | required reviewers + weekly architecture sync |
| Security regressions | boundary-specific threat modeling + CI security checks |

---

## 14) Exit Criteria for this Document

This ownership model is considered implemented when:

- [ ] CODEOWNERS defined in both repos
- [ ] Contract versioning process documented
- [ ] Cross-repo CI integration pipeline active
- [ ] Release/tag promotion workflow established
- [ ] Upstream sync procedure for code-server operational

---

## 15) Next Documents

- `04-code-server-integration-spec.md`
- `05-identity-auth-sso-session-bridging.md`
- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`