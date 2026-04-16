# 06 — LLM Integration and Prompts

## 1) Purpose

Define how to integrate LLMs for:
- app generation,
- targeted fixes,
- controlled multi-file edits,

while ensuring:
- schema-valid outputs,
- predictable behavior,
- safe operations,
- cost and latency control.

---

## 2) Integration Goals

1. **Deterministic machine-readable output** (JSON schema).
2. **Separation of concerns**:
   - prompt building,
   - provider call,
   - output validation,
   - policy gating.
3. **Model-provider portability** via abstraction.
4. **Context efficiency** with relevance filtering/summarization.
5. **Reliable repair path** when model output is invalid.

---

## 3) Provider Abstraction

Define a common provider interface:

```ts
interface StructuredLLMProvider {
  generateStructured(input: {
    model: string;
    systemPrompt: string;
    userPrompt: string;
    jsonSchema: object;
    temperature?: number;
    maxTokens?: number;
    metadata?: Record<string, any>;
  }): Promise<{
    rawText: string;
    parsed: any | null;
    usage?: { inputTokens?: number; outputTokens?: number; totalTokens?: number };
    providerRequestId?: string;
  }>;
}
```

Implementations:
- `OpenAIProvider` (MVP likely)
- `AnthropicProvider` (post-MVP optional)
- `MockProvider` for tests

---

## 4) Modes of LLM Operation

## 4.1 Generation Mode
Input:
- user prompt,
- workspace tree summary,
- selected key files,
- constraints.

Output:
- `PatchPlan` JSON:
  - summary,
  - operations[] (create/update/delete),
  - run suggestions.

## 4.2 Fix Mode
Input:
- failing command + exit code,
- error summary + relevant log excerpt,
- recent changed files,
- constraints (minimal targeted changes).

Output:
- focused patch plan with minimal file set.

## 4.3 Refine/Regenerate Mode
Input:
- user feedback (“use TypeScript”, “keep existing API routes”),
- previous plan metadata.

Output:
- revised patch plan.

---

## 5) Structured Output Contract

Model must return **JSON only** matching schema.

## 5.1 PatchPlan schema (concept)

```json
{
  "type": "object",
  "required": ["summary", "operations"],
  "properties": {
    "summary": { "type": "string" },
    "rationale": { "type": "string" },
    "runSuggestions": {
      "type": "array",
      "items": { "type": "string" }
    },
    "operations": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "required": ["op", "path"],
        "properties": {
          "op": {
            "type": "string",
            "enum": ["create_file", "update_file", "delete_file"]
          },
          "path": { "type": "string" },
          "content": { "type": "string" },
          "reason": { "type": "string" }
        }
      }
    }
  }
}
```

Validation pipeline:
1. JSON parse
2. schema validate
3. policy validate
4. workspace conflict checks

---

## 6) Prompt Framework

Use 3-part composition:

1. **System prompt**  
   Defines role, rules, safety constraints, output format requirements.

2. **Task prompt**  
   User objective + constraints + expected behavior for this mode.

3. **Context payload**  
   Curated repo/project context and diagnostics.

---

## 7) System Prompt (Template)

```text
You are an expert software engineering assistant.
You must return strictly valid JSON matching the provided schema.
Do not include markdown, explanations, or code fences.

Rules:
1) Only propose file operations within workspace paths.
2) Minimize unnecessary changes.
3) Prefer deterministic edits and maintain existing project style.
4) For fixes, target root cause from provided errors.
5) If information is missing, make conservative assumptions and note them in rationale.
6) Never output secrets.
```

---

## 8) Generation Prompt (Template)

```text
Objective:
{{user_prompt}}

Constraints:
- Stack: {{stack}}
- Package manager: {{package_manager}}
- TypeScript: {{typescript}}
- Locked files: {{locked_files}}
- Max files to change: {{max_files}}

Project context:
- Tree summary:
{{tree_summary}}

- Key files:
{{selected_files_with_content_or_summaries}}

Return:
- summary
- rationale
- runSuggestions
- operations[] according to schema
```

---

## 9) Fix Prompt (Template)

```text
The previous run failed.

Failing command:
{{failing_command}}

Exit code:
{{exit_code}}

Error summary:
{{error_summary}}

Relevant log excerpt:
{{log_excerpt}}

Recently changed files:
{{recent_files}}

Rules:
- Make minimal targeted edits.
- Avoid broad refactors.
- Preserve existing architecture unless needed to fix failure.
- Return only JSON patch plan matching schema.
```

---

## 10) Context Construction Strategy

## 10.1 Inclusion priority
1. User prompt + constraints.
2. File tree overview.
3. Entry points (`package.json`, app root, routes, config).
4. Recently modified files.
5. Error logs (fix mode).
6. Small set of highly relevant files.

## 10.2 Exclusion rules
- binary files
- lockfiles (unless explicitly allowed)
- generated/vendor directories
- secrets/env values

## 10.3 Size controls
- max files included
- max chars per file
- summarize oversized files
- include path + summary when full content omitted

---

## 11) Response Repair Strategy

If model output invalid:
1. Run one “repair” pass with strict instruction:
   - “Return valid JSON matching schema exactly.”
2. If still invalid:
   - fail gracefully with `AI_SCHEMA_INVALID`
   - prompt user to retry or simplify request.

Do not auto-loop endlessly.

---

## 12) Model Selection and Routing

MVP:
- single primary model for generation + fix.

Post-MVP routing:
- fast/cheap model for simple edits,
- stronger model for multi-file scaffolding,
- fallback model when primary unavailable.

Routing inputs:
- prompt complexity,
- repo size,
- prior failure rate,
- latency/cost budget.

---

## 13) Temperature and Determinism

Suggested defaults:
- generation: `temperature 0.2–0.4`
- fix mode: `temperature 0.0–0.2`

Use lower temperature for:
- schema reliability
- reproducible patch output
- precise bug fixes

---

## 14) Token and Cost Management

Track per request:
- input tokens
- output tokens
- estimated cost
- retries/repair attempts

Cost controls:
- max tokens per response
- context truncation with summaries
- reject overly broad prompts (or request clarification)
- per-user/session quotas

---

## 15) Prompt Safety and Guardrails

System-level safeguards:
- forbid non-workspace paths.
- forbid unsafe commands in run suggestions.
- discourage dependency bloat unless required.
- require concise rationale.

Post-output safeguards:
- policy check every operation
- block/delete sensitive path edits
- enforce max file-change count

---

## 16) Example Structured Response (Valid)

```json
{
  "summary": "Create a React todo app with basic auth and protected routes.",
  "rationale": "Added auth context, login page, route guards, and todo CRUD UI with API client.",
  "runSuggestions": [
    "npm install --prefix frontend",
    "npm run build --prefix frontend"
  ],
  "operations": [
    {
      "op": "create_file",
      "path": "frontend/src/context/AuthContext.jsx",
      "content": "/* file content */",
      "reason": "Provide auth state and login/logout helpers."
    },
    {
      "op": "update_file",
      "path": "frontend/src/App.jsx",
      "content": "/* updated content */",
      "reason": "Add protected routes and navigation."
    }
  ]
}
```

---

## 17) Versioning Prompt Contracts

Maintain prompt version IDs:

- `GEN_PROMPT_V1`
- `FIX_PROMPT_V1`
- `SYSTEM_PROMPT_V1`

Store version ID with each generation/fix request for audit and reproducibility.

When prompts evolve:
- bump version
- compare success metrics before/after

---

## 18) Evaluation Strategy for Prompt Quality

Track:
- schema pass rate
- apply success rate
- build/test pass after first generation
- fix success rate in 1 iteration
- average changed files per successful result

Run benchmark prompt set:
- small app scaffold
- API + UI integration
- auth flow
- known failure repair scenarios

---

## 19) Failure Handling UX Messages (Backend-driven)

Standardized reason codes:
- `AI_PROVIDER_UNAVAILABLE`
- `AI_SCHEMA_INVALID`
- `AI_POLICY_BLOCKED`
- `AI_CONTEXT_TOO_LARGE`
- `AI_TIMEOUT`

Frontend displays user-friendly action:
- retry
- simplify prompt
- adjust scope
- review blocked items

---

## 20) MVP LLM Integration Checklist

- [ ] Provider abstraction implemented.
- [ ] Structured JSON schema enforced.
- [ ] Generate and fix prompts implemented with versioning.
- [ ] Context builder with truncation/summarization.
- [ ] Invalid-output repair pass (single retry).
- [ ] Token/cost logging in request metadata.
- [ ] Post-response policy gate before any write.
- [ ] Clear error codes for frontend UX.