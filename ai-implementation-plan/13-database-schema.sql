-- 13 — Database Schema (PostgreSQL)
-- Purpose:
--   Persistent storage for AI sessions, generation requests, patch plans, apply results,
--   run executions, fix iterations, snapshots, audit events, and usage accounting.
--
-- Notes:
--   - UUIDs are used as primary keys.
--   - Timestamps are UTC.
--   - JSONB used for flexible payloads.
--   - Add RLS/tenant partitioning as needed for your platform.

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------
-- 1) Core Session Tables
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ai_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (
    status IN ('idle', 'generating', 'reviewing', 'applying', 'running', 'fixing', 'error', 'closed')
  ),
  title TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_sessions_workspace_id ON ai_sessions(workspace_id);
CREATE INDEX IF NOT EXISTS idx_ai_sessions_user_id ON ai_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_sessions_status ON ai_sessions(status);
CREATE INDEX IF NOT EXISTS idx_ai_sessions_created_at ON ai_sessions(created_at DESC);

-- ---------------------------------------------------------------------
-- 2) Generation Requests
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS generation_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  request_type TEXT NOT NULL CHECK (request_type IN ('generate', 'fix', 'refine')),
  prompt TEXT NOT NULL,
  constraints JSONB NOT NULL DEFAULT '{}'::jsonb,
  context_summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  provider TEXT,
  model TEXT,
  prompt_version TEXT,
  temperature NUMERIC(4,3),
  max_tokens INTEGER,
  token_usage JSONB NOT NULL DEFAULT '{}'::jsonb,
  cost_estimate_usd NUMERIC(12,6),
  status TEXT NOT NULL CHECK (status IN ('started', 'completed', 'failed')),
  error_code TEXT,
  error_message TEXT,
  trace_id TEXT,
  idempotency_key TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_generation_requests_session_id ON generation_requests(session_id);
CREATE INDEX IF NOT EXISTS idx_generation_requests_workspace_id ON generation_requests(workspace_id);
CREATE INDEX IF NOT EXISTS idx_generation_requests_user_id ON generation_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_generation_requests_status ON generation_requests(status);
CREATE INDEX IF NOT EXISTS idx_generation_requests_created_at ON generation_requests(created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS uq_generation_requests_idempotency_key
  ON generation_requests(idempotency_key)
  WHERE idempotency_key IS NOT NULL;

-- ---------------------------------------------------------------------
-- 3) Patch Plans and Operations
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS patch_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  generation_request_id UUID NOT NULL REFERENCES generation_requests(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  summary TEXT NOT NULL,
  rationale TEXT,
  run_suggestions JSONB NOT NULL DEFAULT '[]'::jsonb,
  risk_level TEXT NOT NULL DEFAULT 'medium' CHECK (risk_level IN ('low', 'medium', 'high')),
  operations_count INTEGER NOT NULL DEFAULT 0,
  files_changed_count INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL CHECK (status IN ('ready', 'applied', 'partially_applied', 'rejected', 'superseded', 'invalid')),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_patch_plans_generation_request_id ON patch_plans(generation_request_id);
CREATE INDEX IF NOT EXISTS idx_patch_plans_session_id ON patch_plans(session_id);
CREATE INDEX IF NOT EXISTS idx_patch_plans_workspace_id ON patch_plans(workspace_id);
CREATE INDEX IF NOT EXISTS idx_patch_plans_status ON patch_plans(status);
CREATE INDEX IF NOT EXISTS idx_patch_plans_created_at ON patch_plans(created_at DESC);

CREATE TABLE IF NOT EXISTS patch_operations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patch_plan_id UUID NOT NULL REFERENCES patch_plans(id) ON DELETE CASCADE,
  op TEXT NOT NULL CHECK (op IN ('create_file', 'update_file', 'delete_file')),
  path TEXT NOT NULL,
  content TEXT,
  reason TEXT,
  content_sha256 TEXT,
  size_bytes INTEGER,
  order_index INTEGER NOT NULL,
  policy_status TEXT NOT NULL DEFAULT 'pending' CHECK (policy_status IN ('pending', 'allowed', 'blocked')),
  policy_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_patch_operations_patch_plan_id ON patch_operations(patch_plan_id);
CREATE INDEX IF NOT EXISTS idx_patch_operations_path ON patch_operations(path);
CREATE INDEX IF NOT EXISTS idx_patch_operations_policy_status ON patch_operations(policy_status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_patch_operations_order
  ON patch_operations(patch_plan_id, order_index);

CREATE TABLE IF NOT EXISTS patch_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patch_plan_id UUID NOT NULL REFERENCES patch_plans(id) ON DELETE CASCADE,
  path TEXT NOT NULL,
  change_type TEXT NOT NULL CHECK (change_type IN ('create', 'update', 'delete')),
  additions INTEGER NOT NULL DEFAULT 0,
  deletions INTEGER NOT NULL DEFAULT 0,
  unified_diff TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_patch_files_patch_plan_id ON patch_files(patch_plan_id);
CREATE INDEX IF NOT EXISTS idx_patch_files_path ON patch_files(path);

-- ---------------------------------------------------------------------
-- 4) Approval and Apply Results
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS approval_decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patch_plan_id UUID NOT NULL REFERENCES patch_plans(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  approved_by_user_id TEXT NOT NULL,
  approved_paths JSONB NOT NULL DEFAULT '[]'::jsonb,
  rejected_paths JSONB NOT NULL DEFAULT '[]'::jsonb,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_approval_decisions_patch_plan_id ON approval_decisions(patch_plan_id);
CREATE INDEX IF NOT EXISTS idx_approval_decisions_session_id ON approval_decisions(session_id);
CREATE INDEX IF NOT EXISTS idx_approval_decisions_workspace_id ON approval_decisions(workspace_id);

CREATE TABLE IF NOT EXISTS apply_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patch_plan_id UUID NOT NULL REFERENCES patch_plans(id) ON DELETE CASCADE,
  approval_decision_id UUID REFERENCES approval_decisions(id) ON DELETE SET NULL,
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  snapshot_id UUID,
  status TEXT NOT NULL CHECK (status IN ('started', 'applied', 'partial', 'failed', 'rolled_back')),
  applied_count INTEGER NOT NULL DEFAULT 0,
  skipped_count INTEGER NOT NULL DEFAULT 0,
  blocked_count INTEGER NOT NULL DEFAULT 0,
  error_code TEXT,
  error_message TEXT,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_apply_results_patch_plan_id ON apply_results(patch_plan_id);
CREATE INDEX IF NOT EXISTS idx_apply_results_session_id ON apply_results(session_id);
CREATE INDEX IF NOT EXISTS idx_apply_results_workspace_id ON apply_results(workspace_id);
CREATE INDEX IF NOT EXISTS idx_apply_results_status ON apply_results(status);
CREATE INDEX IF NOT EXISTS idx_apply_results_started_at ON apply_results(started_at DESC);

-- ---------------------------------------------------------------------
-- 5) Snapshots and Rollbacks
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  created_by_user_id TEXT NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN ('before_apply', 'before_fix', 'manual', 'pre_run', 'other')),
  storage_type TEXT NOT NULL DEFAULT 'filesystem' CHECK (storage_type IN ('filesystem', 'object_storage', 'git_ref')),
  storage_ref TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_snapshots_session_id ON snapshots(session_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_workspace_id ON snapshots(workspace_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_created_at ON snapshots(created_at DESC);

ALTER TABLE apply_results
  ADD CONSTRAINT fk_apply_results_snapshot
  FOREIGN KEY (snapshot_id) REFERENCES snapshots(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS rollback_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  snapshot_id UUID NOT NULL REFERENCES snapshots(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  triggered_by_user_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('started', 'completed', 'failed')),
  error_code TEXT,
  error_message TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_rollback_events_snapshot_id ON rollback_events(snapshot_id);
CREATE INDEX IF NOT EXISTS idx_rollback_events_session_id ON rollback_events(session_id);
CREATE INDEX IF NOT EXISTS idx_rollback_events_workspace_id ON rollback_events(workspace_id);

-- ---------------------------------------------------------------------
-- 6) Run Executions and Logs
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS run_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  apply_result_id UUID REFERENCES apply_results(id) ON DELETE SET NULL,
  run_profile TEXT,
  commands JSONB NOT NULL DEFAULT '[]'::jsonb,
  stop_on_failure BOOLEAN NOT NULL DEFAULT TRUE,
  status TEXT NOT NULL CHECK (
    status IN ('started', 'running', 'success', 'failed', 'canceled', 'timeout', 'infra_error')
  ),
  failed_command_index INTEGER,
  duration_ms BIGINT,
  log_storage_ref TEXT,
  error_summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  trace_id TEXT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_run_executions_session_id ON run_executions(session_id);
CREATE INDEX IF NOT EXISTS idx_run_executions_workspace_id ON run_executions(workspace_id);
CREATE INDEX IF NOT EXISTS idx_run_executions_user_id ON run_executions(user_id);
CREATE INDEX IF NOT EXISTS idx_run_executions_status ON run_executions(status);
CREATE INDEX IF NOT EXISTS idx_run_executions_started_at ON run_executions(started_at DESC);

CREATE TABLE IF NOT EXISTS run_command_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_execution_id UUID NOT NULL REFERENCES run_executions(id) ON DELETE CASCADE,
  command_index INTEGER NOT NULL,
  command_text TEXT NOT NULL,
  exit_code INTEGER,
  duration_ms BIGINT,
  status TEXT NOT NULL CHECK (status IN ('started', 'success', 'failed', 'timeout', 'canceled')),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_run_command_results_run_execution_id ON run_command_results(run_execution_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_run_command_results_idx
  ON run_command_results(run_execution_id, command_index);

-- Optional persisted log chunks (for medium scale)
CREATE TABLE IF NOT EXISTS run_log_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_execution_id UUID NOT NULL REFERENCES run_executions(id) ON DELETE CASCADE,
  command_index INTEGER NOT NULL,
  stream TEXT NOT NULL CHECK (stream IN ('stdout', 'stderr')),
  sequence INTEGER NOT NULL,
  chunk TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_run_log_chunks_run_execution_id ON run_log_chunks(run_execution_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_run_log_chunks_seq
  ON run_log_chunks(run_execution_id, command_index, stream, sequence);

-- ---------------------------------------------------------------------
-- 7) Fix Iterations
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS fix_iterations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES ai_sessions(id) ON DELETE CASCADE,
  workspace_id TEXT NOT NULL,
  run_execution_id UUID NOT NULL REFERENCES run_executions(id) ON DELETE CASCADE,
  generation_request_id UUID NOT NULL REFERENCES generation_requests(id) ON DELETE CASCADE,
  patch_plan_id UUID NOT NULL REFERENCES patch_plans(id) ON DELETE CASCADE,
  strategy TEXT NOT NULL CHECK (strategy IN ('minimal-targeted-fix', 'balanced', 'aggressive')),
  iteration_number INTEGER NOT NULL DEFAULT 1,
  outcome TEXT NOT NULL CHECK (outcome IN ('ready', 'applied', 'succeeded_after_rerun', 'failed', 'abandoned')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fix_iterations_session_id ON fix_iterations(session_id);
CREATE INDEX IF NOT EXISTS idx_fix_iterations_workspace_id ON fix_iterations(workspace_id);
CREATE INDEX IF NOT EXISTS idx_fix_iterations_run_execution_id ON fix_iterations(run_execution_id);

-- ---------------------------------------------------------------------
-- 8) Audit Events
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  actor_user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL,
  session_id UUID REFERENCES ai_sessions(id) ON DELETE SET NULL,
  request_id TEXT,
  trace_id TEXT,
  severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical')),
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_events_workspace_id ON audit_events(workspace_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_session_id ON audit_events(session_id);
CREATE INDEX IF NOT EXISTS idx_audit_events_event_type ON audit_events(event_type);
CREATE INDEX IF NOT EXISTS idx_audit_events_created_at ON audit_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_events_actor_user_id ON audit_events(actor_user_id);

-- ---------------------------------------------------------------------
-- 9) Usage and Cost Accounting
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ai_usage_daily (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usage_date DATE NOT NULL,
  user_id TEXT NOT NULL,
  workspace_id TEXT NOT NULL,
  requests_count INTEGER NOT NULL DEFAULT 0,
  input_tokens BIGINT NOT NULL DEFAULT 0,
  output_tokens BIGINT NOT NULL DEFAULT 0,
  total_tokens BIGINT NOT NULL DEFAULT 0,
  estimated_cost_usd NUMERIC(14,6) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_ai_usage_daily_key
  ON ai_usage_daily(usage_date, user_id, workspace_id);

CREATE INDEX IF NOT EXISTS idx_ai_usage_daily_user_id ON ai_usage_daily(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_usage_daily_workspace_id ON ai_usage_daily(workspace_id);
CREATE INDEX IF NOT EXISTS idx_ai_usage_daily_usage_date ON ai_usage_daily(usage_date DESC);

-- ---------------------------------------------------------------------
-- 10) Idempotency Keys (Generic)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS idempotency_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT NOT NULL,
  user_id TEXT NOT NULL,
  endpoint TEXT NOT NULL,
  request_hash TEXT NOT NULL,
  response_status INTEGER,
  response_body JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_idempotency_user_endpoint_key
  ON idempotency_keys(user_id, endpoint, key);

CREATE INDEX IF NOT EXISTS idx_idempotency_expires_at ON idempotency_keys(expires_at);

-- ---------------------------------------------------------------------
-- 11) Updated At Trigger Helper
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ai_sessions_updated_at ON ai_sessions;
CREATE TRIGGER trg_ai_sessions_updated_at
BEFORE UPDATE ON ai_sessions
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_ai_usage_daily_updated_at ON ai_usage_daily;
CREATE TRIGGER trg_ai_usage_daily_updated_at
BEFORE UPDATE ON ai_usage_daily
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ---------------------------------------------------------------------
-- 12) Helpful Views
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW v_session_latest_status AS
SELECT
  s.id AS session_id,
  s.workspace_id,
  s.user_id,
  s.status,
  s.updated_at,
  (
    SELECT COUNT(*) FROM generation_requests gr WHERE gr.session_id = s.id
  ) AS generation_count,
  (
    SELECT COUNT(*) FROM run_executions re WHERE re.session_id = s.id
  ) AS run_count
FROM ai_sessions s;

CREATE OR REPLACE VIEW v_run_failure_summary AS
SELECT
  re.id AS run_id,
  re.workspace_id,
  re.user_id,
  re.status,
  re.failed_command_index,
  re.error_summary,
  re.started_at,
  re.completed_at
FROM run_executions re
WHERE re.status IN ('failed', 'timeout', 'infra_error');

COMMIT;