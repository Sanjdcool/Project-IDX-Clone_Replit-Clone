# 12 — Prompt Orchestration and Guardrails

## Status
Draft (target: AI + security + platform sign-off)

## Date
2026-04-16

## Purpose

Define how prompts are composed, routed, constrained, and audited so AI behavior remains useful, safe, and deterministic across coding workflows in the IDX + code-server platform.

---

## 1) Design Goals

1. High-quality coding assistance with predictable behavior.
2. Safe tool usage under strict policy controls.
3. Deterministic prompt assembly with explainable context.
4. Robust fallback behavior under model/tool failures.
5. Continuous improvement via evaluation and telemetry loops.

---

## 2) Orchestration Scope

## In scope
1. Prompt assembly pipeline
2. Model routing policy
3. Tool-call planning and execution gating
4. Safety/policy guardrails
5. Retry/fallback logic
6. Prompt/version governance

## Out of scope
1. Low-level model hosting internals
2. Billing implementation details
3. Full red-team program design (tracked separately)

---

## 3) Prompt Assembly Pipeline

Per user turn, orchestrator builds a request in this sequence:

1. **System policy layer**
   - product rules, safety constraints, tool policy
2. **Task framing layer**
   - user intent normalization + task objective
3. **Context layer**
   - retrieved code context (from doc 11)
   - active file snippets
   - recent tool outputs
4. **Memory layer**
   - short relevant conversation history
5. **Execution plan layer**
   - whether tools are needed, and in what order
6. **Output contract layer**
   - required response format / structured JSON when applicable

All layers are versioned and traceable.

---

## 4) Prompt Contracts

## 4.1 Input contract (conceptual)
- `request_id`
- `conversation_id`
- `user_id`
- `org_id`
- `workspace_id`
- `task_type`
- `retrieved_context[]`
- `tool_capabilities[]`
- `policy_flags`
- `response_mode`

## 4.2 Output contract (conceptual)
- `assistant_response`
- `tool_calls[]` (if any)
- `confidence` (optional bounded signal)
- `citations` (path/line references)
- `policy_notes` (if constraint affected output)

---

## 5) Model Routing Strategy

## 5.1 Routing dimensions

1. Task class (chat, code edit, debugging, planning)
2. Required reasoning depth
3. Latency target profile
4. Cost budget / plan tier
5. Safety sensitivity level

## 5.2 Fallback path

If primary model fails:
1. retry with bounded attempts,
2. switch to fallback model class,
3. preserve task state and tool trace continuity,
4. return graceful degraded response if needed.

---

## 6) Tool Orchestration Policy

1. Model may **propose** tool calls; broker/policy decides execution.
2. Multi-step tool plans must be bounded by:
   - max tool calls per turn,
   - max cumulative runtime,
   - max mutation scope.
3. Mutating actions may require confirmation policy (see doc 10).
4. Tool outputs are summarized and fed back into subsequent reasoning turns.

---

## 7) Guardrail Layers

## 7.1 Pre-generation guardrails
- input validation/sanitization,
- policy context evaluation,
- sensitive scope detection.

## 7.2 In-generation guardrails
- response schema constraints,
- tool call schema constraints,
- banned content/action checks.

## 7.3 Post-generation guardrails
- output validation,
- sensitive content filter,
- action risk classification before execution.

---

## 8) Safety Policies for Coding Actions

1. Prevent unauthorized cross-workspace references.
2. Block disallowed command suggestions where policy prohibits.
3. Avoid leaking secret-like content from context.
4. Require explicit user confirmation for high-risk changes:
   - mass deletion,
   - credential/config rewrites,
   - deployment-affecting actions.

---

## 9) Prompt Versioning and Change Management

1. Every prompt template has:
   - `prompt_id`,
   - semantic version,
   - owner,
   - changelog.
2. A/B rollout support for prompt revisions.
3. Rollback strategy required for regressions.
4. Contract tests validate format + policy compliance before release.

---

## 10) Hallucination and Uncertainty Handling

1. Prefer “unknown/need more context” over fabricated certainty.
2. Encourage citeable references to files/lines.
3. If tool execution failed, reflect failure explicitly.
4. For destructive suggestions, include explicit risk notes.

---

## 11) Latency and Cost Controls

1. Token budget caps per turn by plan tier.
2. Adaptive context truncation before model call.
3. Max orchestration loop depth per turn.
4. Early-exit strategy for simple requests.
5. Cache reusable intermediate summaries where safe.

---

## 12) Observability Requirements

## 12.1 Metrics
- prompt assembly latency
- model latency and success/failure rates
- tool-call rate per turn
- guardrail block/deny counts
- token usage per layer
- fallback activation rate

## 12.2 Logs/trace fields
- prompt version ids
- model route decision reason
- tool plan summary
- guardrail decisions
- end-to-end request correlation ids

Never log raw secrets or sensitive full file dumps.

---

## 13) Evaluation Loop

1. Offline benchmark suites:
   - bug fix,
   - feature implementation,
   - refactor quality,
   - safe behavior tests.
2. Online evaluation:
   - task success proxy,
   - user satisfaction feedback,
   - regression detection over time.
3. Guardrail regression suite mandatory before release.

---

## 14) Failure Modes and Recovery

## Common failures
1. model timeout
2. invalid tool-call schema
3. context assembly overflow
4. guardrail false positives/overblocking
5. repeated low-quality loops

## Recovery controls
- bounded retries,
- fallback routing,
- safe degraded response mode,
- human escalation markers for repeated failure patterns.

---

## 15) Implementation Checklist

- [ ] Implement prompt layer composer with strict schema contracts
- [ ] Implement routing policy engine (task/cost/latency aware)
- [ ] Implement pre/in/post guardrail middleware
- [ ] Implement tool-call gating + confirmation integration
- [ ] Implement prompt/template version registry
- [ ] Implement fallback model strategy and retry limits
- [ ] Implement prompt telemetry and eval hooks
- [ ] Add rollback controls for prompt releases

---

## 16) Acceptance Criteria

1. Prompt assembly is deterministic, versioned, and auditable.
2. Tool calls are policy-gated and schema-validated.
3. Unsafe actions are blocked or confirmation-gated by policy.
4. Model failures degrade gracefully without breaking user workflow.
5. Evaluation metrics show stable quality and safety trends.

---

## 17) Dependencies

- `10-ai-agent-tooling-contracts.md`
- `11-context-engine-indexing-and-retrieval.md`
- `13-code-apply-git-ops-and-conflict-handling.md`
- `16-audit-logging-policy-and-governance.md`
- `18-observability-slos-and-alerting.md`

---

## 18) Next Document

Proceed to:
`13-code-apply-git-ops-and-conflict-handling.md`