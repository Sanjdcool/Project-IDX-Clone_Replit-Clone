# 11 — Context Engine, Indexing, and Retrieval

## Status
Draft (target: AI + platform sign-off)

## Date
2026-04-16

## Purpose

Define how the platform builds and serves high-quality context for AI coding workflows across workspace files, project metadata, execution history, and user intent—while keeping latency, cost, and safety under control.

---

## 1) Design Goals

1. Deliver relevant code context with low latency.
2. Minimize token usage via smart retrieval and compression.
3. Keep context workspace-scoped and access-controlled.
4. Support hybrid retrieval (symbolic + semantic + recency).
5. Provide deterministic, debuggable context assembly for every AI turn.

---

## 2) Context Engine Scope

## In scope
1. Workspace file indexing
2. Symbol extraction and dependency references
3. Semantic retrieval pipeline
4. Recent activity/context memory
5. Prompt-ready context assembly
6. Relevance scoring and truncation policy

## Out of scope
1. LLM provider routing logic (covered in orchestration doc)
2. Long-term org-wide knowledge graph (future phase)
3. External internet retrieval by default (policy-controlled extension)

---

## 3) Context Sources

1. **Workspace source files**
2. **Project structure/tree metadata**
3. **Git status/diff context**
4. **Build/test/lint outputs**
5. **User conversation history (bounded window)**
6. **Tool execution history (recent actions)**
7. **Policy and environment metadata (safe subset only)**

---

## 4) Indexing Architecture

## 4.1 Index types

1. **Lexical index**
   - exact token/text/symbol lookup
2. **Structural index**
   - file tree, language boundaries, module relationships
3. **Semantic index**
   - embeddings/chunk similarity for intent-based retrieval
4. **Recency index**
   - last edited/read/executed files and commands

## 4.2 Index ownership

- Built per workspace by default.
- Optional shared project-level cache with strict access controls.
- Index lifecycle linked to workspace lifecycle + change events.

---

## 5) Chunking Strategy

1. Chunk by language-aware boundaries where possible:
   - functions/classes/sections first
2. Fallback chunking by token budget with overlap.
3. Include chunk metadata:
   - file path,
   - line ranges,
   - symbol names,
   - hash/version stamp,
   - last modified timestamp.

Avoid naive giant file ingestion into prompts.

---

## 6) Change Detection and Re-indexing

1. File watcher events trigger incremental re-indexing.
2. Bulk rebuild on:
   - branch switch,
   - massive refactor,
   - index corruption detection.
3. Debounce rapid file saves to avoid index thrash.
4. Re-index priority:
   - active/open files first,
   - recently edited files next,
   - background full sync later.

---

## 7) Retrieval Pipeline (Per AI Turn)

1. Parse user intent (task type + scope hints).
2. Fetch candidate files/chunks via:
   - lexical/symbol match,
   - semantic similarity,
   - recency weighting.
3. Score and rank candidates.
4. Apply policy filters (access/sensitive paths).
5. Build compact context pack with citations/line anchors.
6. Enforce token budget and truncation strategy.
7. Return context bundle to prompt orchestrator.

---

## 8) Ranking and Relevance Model

## 8.1 Scoring signals

1. lexical/symbol match confidence
2. semantic similarity score
3. recency weight (recent edits/open files)
4. proximity to error stack/build failures
5. same-module dependency closeness
6. prior accepted context usefulness signal (future optimization)

## 8.2 Tie-break rules

- prefer smaller, precise chunks over broad noisy files,
- prefer user-active branch/worktree scope,
- avoid duplicate near-identical chunks.

---

## 9) Token Budgeting and Context Compression

1. Define total prompt context budget tiers (by plan/model).
2. Reserve budget slices:
   - system/tool instructions,
   - user turn,
   - retrieved code context,
   - conversation memory.
3. Compression strategy:
   - summarize low-priority chunks,
   - include full text for top-ranked chunks,
   - drop least relevant items first.
4. Always preserve path + line anchors for explainability.

---

## 10) Conversation Memory Policy

1. Maintain short rolling memory window for chat continuity.
2. Promote key decisions/artifacts into structured memory notes.
3. Expire stale memory beyond retention window.
4. Keep memory workspace-scoped unless explicit project-level share policy.

---

## 11) Security and Access Controls

1. Retrieval strictly scoped to authorized workspace/project context.
2. Sensitive file patterns can be masked, excluded, or gated.
3. No cross-tenant index access.
4. Embedding/index stores must be encrypted at rest.
5. Retrieval requests and sensitive-access denials are audit-logged.

---

## 12) Failure Handling

## Common failure cases
1. Index not ready
2. Partial index corruption
3. Embedding service timeout
4. Retrieval returns low-confidence/no context
5. Token budget overflow during assembly

## Recovery behavior
- degrade gracefully to lexical + active file context,
- background re-index trigger,
- explicit low-confidence signal to orchestrator,
- avoid hallucinated confidence claims.

---

## 13) Observability Requirements

## 13.1 Metrics

- index build time (full/incremental)
- retrieval latency p50/p95/p99
- context hit quality proxy metrics
- empty retrieval rate
- token usage by context source
- re-index error rate

## 13.2 Logs/traces

- retrieval request id -> selected chunks (safe metadata)
- ranking score summaries
- truncation decisions
- end-to-end trace from user turn to model request

---

## 14) Quality Evaluation Framework

1. Offline eval set:
   - bug fix tasks
   - refactor tasks
   - feature add tasks
2. Measure:
   - retrieval precision@k
   - answer success/task completion rates
   - token efficiency
   - latency impact
3. Continuous eval on sampled anonymized sessions (policy-compliant).

---

## 15) Data Retention and Privacy

1. Define retention windows for:
   - index entries,
   - embeddings,
   - retrieval logs.
2. Support deletion requests:
   - workspace/project/org-level purge.
3. Redact or hash sensitive fields in logs.
4. Avoid storing raw secrets in context caches.

---

## 16) Implementation Checklist

- [ ] Define chunk schema and metadata format
- [ ] Implement incremental indexing pipeline
- [ ] Implement hybrid retrieval scorer (lexical + semantic + recency)
- [ ] Implement token budgeting and truncation policy
- [ ] Implement structured memory module
- [ ] Add security/path filters and sensitive-file policies
- [ ] Add retrieval observability dashboards
- [ ] Build offline evaluation harness

---

## 17) Acceptance Criteria

1. AI responses consistently reference relevant workspace code context.
2. Retrieval latency remains within product SLO targets.
3. Token usage is controlled and explainable.
4. Context assembly is auditable per request.
5. Unauthorized/sensitive context is never leaked across boundaries.

---

## 18) Dependencies

- `10-ai-agent-tooling-contracts.md`
- `12-prompt-orchestration-and-guardrails.md`
- `16-audit-logging-policy-and-governance.md`
- `18-observability-slos-and-alerting.md`
- `31-risk-register-and-mitigation-tracker.md`

---

## 19) Next Document

Proceed to:
`12-prompt-orchestration-and-guardrails.md`