# 05 — Identity, Auth, SSO, and Session Bridging

## Status
Draft (target: security + platform sign-off)

## Date
2026-04-16

## Purpose

Define the end-to-end identity and access model across:

- IDX control plane (web + APIs),
- workspace lifecycle services,
- IDE gateway/proxy,
- code-server runtime sessions.

This document specifies authentication, authorization, SSO readiness, token exchange, session lifecycle, revocation, and audit requirements.

---

## 1) Security Objectives

1. Enforce least-privilege access to all workspace resources.
2. Ensure IDE access is short-lived, scoped, and route-bound.
3. Prevent token replay and cross-workspace/session hijacking.
4. Support enterprise SSO expansion (OIDC/SAML) without redesign.
5. Ensure full auditability of identity-to-action mapping.

---

## 2) Identity Model (Canonical)

## 2.1 Principal Types

1. **Human User Principal**
   - Authenticated end user (email/social/SSO)
2. **Service Principal**
   - Internal service identity (workspace manager, proxy, tooling broker)
3. **Automation Principal** (optional phase)
   - CI/system automation within bounded scopes

## 2.2 Hierarchy Context

Every authorized action is evaluated in context of:
- `user_id`
- `org_id`
- `project_id` (if applicable)
- `workspace_id` (if applicable)
- `role` + `plan` + policy constraints

---

## 3) Authentication Architecture

## 3.1 Control Plane Auth

Control plane owns primary user authentication via:
- OIDC-compatible provider (recommended),
- secure session cookies or token pair model,
- MFA support (if enterprise plans require).

## 3.2 Session Store Strategy

- Session identifier managed server-side.
- Short-lifetime access token + refresh mechanism (if token-based model used).
- Rotate refresh tokens on use where possible.
- Bind sessions to device/browser fingerprints cautiously (risk-based).

---

## 4) Authorization Architecture

## 4.1 Authorization Layers

1. **API layer authorization**  
   Verify user role/ownership/org membership.
2. **Policy layer authorization**  
   Plan/feature gate/quota checks.
3. **Resource layer authorization**  
   Workspace/project scoped checks.
4. **Runtime route authorization**  
   Gateway validates workspace-bound token.

All four layers must pass for sensitive actions.

## 4.2 Core Permission Domains

- Org administration
- Member management
- Project CRUD
- Workspace lifecycle (create/start/stop/delete)
- IDE connect
- Terminal/command execution
- AI tool actions (read/write/run)
- Snapshot/export/deploy actions

---

## 5) SSO and Federation Plan

## 5.1 Phase Model

1. **Phase A (MVP):**
   - Standard auth provider with OIDC support
2. **Phase B:**
   - Enterprise SSO (OIDC/SAML) per org
3. **Phase C:**
   - SCIM provisioning + advanced enterprise policy controls

## 5.2 Org-level SSO controls

- Enforce SSO for org members
- Domain verification for managed accounts
- Optional just-in-time provisioning
- Role mapping defaults at first login

---

## 6) IDE Session Bridging Model

## 6.1 Why bridging is needed

User authenticates to control plane, but IDE runtime is separate.  
A secure, ephemeral access delegation is required for IDE route access.

## 6.2 Bridge Token (IDE Access Token) Claims

Minimum required claims:
- `iss` (control plane issuer)
- `aud` (`ide-gateway`)
- `sub` (user principal)
- `org_id`
- `project_id` (optional but recommended)
- `workspace_id`
- `scope`: `ide:connect`
- `iat`, `exp` (short TTL)
- `jti` (unique token ID)
- optional `nonce`

## 6.3 TTL policy

- Very short TTL (e.g., minutes, not hours).
- Re-issuance permitted only via authenticated control-plane session.
- Optional silent refresh mechanism through secure control-plane endpoint.

---

## 7) Token Validation and Trust Chain

## 7.1 Validation at Gateway (mandatory)

Gateway validates:
1. signature and issuer
2. audience
3. expiry / not-before
4. jti replay cache check
5. workspace-route binding (`workspace_id` matches path)
6. optional org binding (subdomain/org mapping)

## 7.2 Trust Forwarding to Runtime

After validation, gateway forwards sanitized identity headers:
- `x-user-id`
- `x-org-id`
- `x-workspace-id`
- `x-session-id` (optional)
- `x-request-id`

Runtime must **never** trust raw client-supplied identity headers.

---

## 8) Session Lifecycle

## 8.1 Control Plane Session States

- `ACTIVE`
- `IDLE`
- `REAUTH_REQUIRED`
- `REVOKED`
- `EXPIRED`

## 8.2 IDE Session States

- `CONNECTING`
- `CONNECTED`
- `RENEWAL_PENDING`
- `DISCONNECTED`
- `TERMINATED`

## 8.3 Lifecycle events (audit required)

- login success/failure
- token issued/refreshed/revoked
- ide session opened/closed
- permission denied
- suspicious access blocked

---

## 9) Revocation and Incident Response

## 9.1 Revocation triggers

- user logout
- password/credential reset
- org admin forced sign-out
- suspicious token use/replay detection
- account disablement

## 9.2 Revocation behavior

1. Revoke active control-plane sessions.
2. Invalidate IDE token acceptance (jti denylist or key rotation path).
3. Optionally terminate active IDE websocket sessions.
4. Emit high-priority security event for monitoring.

---

## 10) Multi-Tenant Isolation Requirements

1. Every token must carry tenant/org scope.
2. Gateway path/domain binding must enforce org/workspace mapping.
3. Cross-org workspace access must fail closed by default.
4. Any missing org/workspace claim = deny.
5. Service-to-service calls require explicit tenant context fields.

---

## 11) Service Authentication (Internal)

1. Use mTLS or signed service tokens between:
   - API gateway,
   - workspace manager,
   - proxy/gateway,
   - tool broker.
2. Service tokens must be short-lived and scoped.
3. Rotate service credentials periodically.
4. Deny all unsigned internal privileged calls.

---

## 12) CSRF, XSS, and Session Hijack Defenses

1. Use SameSite/HttpOnly/Secure cookies for browser sessions where applicable.
2. Enforce CSRF protection on state-changing endpoints.
3. Strict CSP and output sanitization to reduce XSS risk.
4. Origin and referer checks on sensitive auth endpoints.
5. Detect abnormal geo/device/session anomalies and step-up auth if needed.

---

## 13) Audit and Compliance Requirements

## 13.1 Must-log identity events

- Authentication attempts (success/failure)
- SSO assertions (when enabled)
- Role/permission changes
- Session/token issuance and revocation
- IDE access grants/denials
- Privileged action attempts in workspace

## 13.2 Log integrity

- Structured immutable audit stream
- Tamper-evident retention strategy
- Access-controlled audit query path

---

## 14) Error Model and User Experience

## 14.1 User-facing auth errors

- session expired
- insufficient permission
- workspace access denied
- organization policy restriction
- reconnect required

## 14.2 Security posture

- Never leak sensitive token validation reasons to clients.
- Internal logs retain full diagnostic reason codes.

---

## 15) Implementation Checklist

- [ ] Define canonical claim schema for access + IDE tokens
- [ ] Implement token mint endpoint for IDE route
- [ ] Implement gateway claim validation middleware
- [ ] Add jti replay protection storage/check
- [ ] Add revocation endpoint + event path
- [ ] Implement sanitized identity header forwarding
- [ ] Add audit events for all auth/session transitions
- [ ] Add enterprise SSO extension points in identity schema

---

## 16) Acceptance Criteria

1. User cannot access IDE route without valid short-lived workspace token.
2. Token replay and cross-workspace route misuse are blocked.
3. Session revocation immediately impacts new IDE connects.
4. Security team can trace user->session->workspace action chain in audit logs.
5. Org-level access constraints are consistently enforced across control plane and IDE entry.

---

## 17) Dependencies

- `04-code-server-integration-spec.md`
- `06-workspace-orchestrator-spec.md`
- `07-ide-routing-proxy-and-network-topology.md`
- `14-security-isolation-and-sandbox-hardening.md`
- `16-audit-logging-policy-and-governance.md`

---

## 18) Next Document

Proceed to:
`06-workspace-orchestrator-spec.md`