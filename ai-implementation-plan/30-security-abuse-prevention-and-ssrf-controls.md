# 30 — Security, Abuse Prevention, and SSRF Controls

## 1) Purpose

Define security architecture and abuse controls for:

1. Migration (verified owned-site),
2. Design recreation (layout-focused),
3. Competitive audit (read-only),

with emphasis on network safety (SSRF), policy enforcement, data handling, and operational controls.

---

## 2) Security Objectives

1. Prevent SSRF and internal network access from crawl pipeline.
2. Enforce strict mode-based permissions and output restrictions.
3. Reduce abuse risk (mass scanning, scraping misuse, policy evasion).
4. Protect stored artifacts, credentials, and user data.
5. Ensure auditable, incident-ready security posture.

---

## 3) Threat Model (High-Level)

## 3.1 Primary threat categories
1. SSRF via crafted URLs or redirects
2. Unauthorized cloning/export of third-party content
3. Resource abuse (large-scale automated crawling/scanning)
4. Data leakage from artifacts/logs
5. Privilege escalation across modes/workspaces
6. Malicious payloads in crawled content affecting workers

## 3.2 Trust boundaries
- client UI ↔ API
- API ↔ policy engine
- worker runtime ↔ external internet
- worker ↔ storage/DB
- export service ↔ user download surface

---

## 4) SSRF Defense Strategy

## 4.1 URL validation gate (pre-fetch)
Reject:
- non-http(s) schemes (`file:`, `ftp:`, `gopher:`, etc.)
- malformed hostnames
- localhost/loopback equivalents
- raw IP URLs unless explicitly allowed by policy

## 4.2 DNS/IP resolution controls
Before request:
1. resolve hostname
2. verify all resolved IPs are public routable
3. block private/link-local/multicast/reserved ranges
4. re-validate after redirect hops

## 4.3 Forbidden address ranges (minimum)
- 127.0.0.0/8
- 10.0.0.0/8
- 172.16.0.0/12
- 192.168.0.0/16
- 169.254.0.0/16
- ::1/128
- fc00::/7
- fe80::/10
- metadata/service addresses as applicable (cloud vendor internal)

## 4.4 Redirect handling protections
- max redirect hops (e.g., 5)
- each hop revalidated against URL + IP policy
- block protocol downgrade/upgrade anomalies as policy dictates

---

## 5) Network Isolation for Crawl Workers

1. run crawl/render workers in isolated containers/VMs.
2. restrict outbound egress via firewall rules.
3. deny inbound access entirely.
4. no access to internal service networks from worker runtime.
5. short-lived execution environment with ephemeral filesystem.

---

## 6) Mode-Based Access Controls

## 6.1 Permission matrix
- Migration: requires verified ownership + elevated role.
- Recreation: allowed with stricter output defaults.
- Audit: read-only outputs only.

## 6.2 Server-side enforcement
Never rely only on UI:
- enforce mode constraints in API and policy engine.
- enforce again at export endpoints and artifact generation.

---

## 7) Abuse Prevention Controls

## 7.1 Rate and quota limits
Apply per:
- user
- workspace
- IP/session
- mode

Limits:
- jobs/day
- concurrent active jobs
- max pages per job
- max runtime per job

## 7.2 Behavioral anomaly detection
Flag patterns:
- repeated blocked target attempts
- broad multi-domain scans
- repeated policy violation actions
- unusual burst behavior across accounts

## 7.3 Progressive enforcement
1. soft throttle
2. temporary block
3. mandatory re-verification/manual review
4. account/workspace suspension path

---

## 8) Crawl Scope and Safety Limits

1. strict domain/path scoping per job.
2. block out-of-scope traversal by default.
3. query parameter loop guards.
4. depth/page/runtime ceilings.
5. max response size ceilings.
6. MIME-type allowlist for persisted artifacts.

---

## 9) Data Protection and Storage Security

## 9.1 Encryption
- encrypt data in transit (TLS)
- encrypt sensitive data at rest (DB + object storage)

## 9.2 Artifact security
- classify artifacts by risk/policy class
- short-lived signed URLs for downloads
- optional one-time download tokens
- immutable audit trail for download events

## 9.3 Secret handling
- no secrets in frontend bundles
- key vault/secret manager for service credentials
- redact secrets from logs and error messages

---

## 10) Logging and Audit Security

## 10.1 Mandatory security events
- policy allowed/blocked decisions
- ownership verification attempts/results
- SSRF block events
- export/download requests and outcomes
- permission failures and suspicious patterns

## 10.2 Log hygiene
- redact sensitive headers/query tokens
- avoid storing full raw payloads unnecessarily
- retain structured logs with correlation IDs

---

## 11) Input Sanitization and Validation

1. strict schema validation for all API inputs.
2. sanitize URL and text fields before downstream use.
3. enforce file upload constraints for screenshot mode:
   - type allowlist
   - size limits
   - malware scan pipeline (if available)
4. sanitize generated filenames/paths in codegen outputs.

---

## 12) Content Safety in Worker Execution

1. do not execute arbitrary scripts from crawled pages beyond browser render context.
2. disable dangerous browser capabilities not needed.
3. isolate downloaded assets from host filesystem.
4. treat crawled content as untrusted data everywhere.

---

## 13) Export and Exfiltration Controls

## 13.1 Policy-aware export broker
Export request must check:
- mode
- user role
- artifact class
- ownership status (if required)
- policy version

## 13.2 Deny-by-default on restricted classes
- audit mode cannot export scaffold/raw content bundles.
- recreation mode restricts raw content bundle classes by default.
- migration raw exports only for verified scope.

---

## 14) Session, Auth, and Authorization Hardening

1. require auth on all site-studio endpoints.
2. verify workspace membership and role on each request.
3. bind job ownership to creator/workspace permissions.
4. use short-lived access tokens and secure refresh handling.
5. protect against CSRF for cookie-auth flows where applicable.

---

## 15) Dependency and Supply Chain Security

1. pin versions for crawl/render dependencies.
2. perform vulnerability scanning in CI.
3. track dependency SBOM where possible.
4. patch browser engine/runtime quickly for security advisories.

---

## 16) Secure Defaults by Mode

## Migration
- ownership required
- strict scope lock
- full audit logging enabled

## Recreation
- placeholder content default
- limited artifact classes
- no direct third-party raw export defaults

## Audit
- read-only artifacts only
- export restricted to report classes

---

## 17) Incident Response Playbook (Security Events)

## 17.1 Trigger examples
- SSRF block spike
- policy bypass attempts
- suspicious mass crawl bursts
- unauthorized artifact download pattern

## 17.2 Response steps
1. detect and triage
2. contain (throttle/block)
3. preserve forensic logs
4. investigate scope and root cause
5. remediate and patch
6. notify stakeholders per policy

---

## 18) Security Testing Requirements

## 18.1 Automated tests
- URL validation unit tests
- IP range blocking tests
- redirect re-validation tests
- policy gating integration tests
- RBAC permission tests
- signed URL expiry tests

## 18.2 Adversarial tests
- SSRF payload corpus testing
- DNS rebinding simulation
- open redirect abuse paths
- crawl loop/trap stress tests
- export endpoint abuse attempts

---

## 19) Security KPIs

Track:
- blocked SSRF attempts/day
- policy-blocked actions/day
- suspicious job attempts/day
- mean time to detect security anomalies
- mean time to contain incidents
- % endpoints with full authz checks covered by tests

---

## 20) Compliance and Governance Hooks

1. policy version attached to each job/event.
2. legal consent records linked to sensitive actions.
3. retention/deletion controls for artifacts.
4. periodic access review for privileged roles.
5. incident audit report export for compliance review.

---

## 21) Minimum Launch Security Checklist

- [ ] SSRF protections implemented and tested.
- [ ] Worker network isolation enforced.
- [ ] Mode and RBAC checks server-side complete.
- [ ] Export broker enforces artifact policy class rules.
- [ ] Signed URL download flow implemented with TTL.
- [ ] Security logs and alerts configured.
- [ ] Abuse throttling and quotas active.
- [ ] Incident playbook documented and tested.

---

## 22) Open Security Decisions

1. Should migration mode allow robots override at all in MVP?
2. What default max pages/runtime per mode by plan tier?
3. Which anomaly thresholds auto-trigger temporary suspension?
4. Do we require additional approval for high-risk target classifications?
5. What retention window balances incident forensics and privacy minimization?