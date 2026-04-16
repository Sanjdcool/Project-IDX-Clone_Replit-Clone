-- 29 — Data Model, Storage, and Job Schema
-- PostgreSQL schema for:
-- - ownership verification
-- - site processing jobs (migration/recreation/audit)
-- - crawl/extraction/regeneration/audit artifacts
-- - exports/downloads
-- - policy/audit events
--
-- Notes:
-- - UUID primary keys
-- - JSONB for flexible payloads
-- - strict status enums via CHECK constraints
-- - designed to integrate with existing ai_sessions and audit patterns

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------
-- 1) Ownership Verification
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_ownership_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  domain TEXT NOT NULL,
  method TEXT NOT NULL CHECK (method IN ('dns_txt', 'html_file', 'meta_tag')),
  token TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('issued', 'verified', 'failed', 'expired')),
  instructions JSONB NOT NULL DEFAULT '{}'::jsonb,
  attempts_count INTEGER NOT NULL DEFAULT 0,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  verified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ NOT NULL,
  failure_reason TEXT,
  policy_version TEXT NOT NULL DEFAULT '1.0',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_ownership_workspace_id
  ON site_ownership_verifications(workspace_id);
CREATE INDEX IF NOT EXISTS idx_site_ownership_user_id
  ON site_ownership_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_site_ownership_domain
  ON site_ownership_verifications(domain);
CREATE INDEX IF NOT EXISTS idx_site_ownership_status
  ON site_ownership_verifications(status);
CREATE INDEX IF NOT EXISTS idx_site_ownership_expires_at
  ON site_ownership_verifications(expires_at);

CREATE UNIQUE INDEX IF NOT EXISTS uq_site_ownership_active_token
  ON site_ownership_verifications(domain, token)
  WHERE status IN ('issued');

-- ---------------------------------------------------------------------
-- 2) Consent / Legal Acknowledgement
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_feature_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  domain TEXT,
  mode TEXT NOT NULL CHECK (
    mode IN ('migration_verified', 'recreation_layout_only', 'audit_readonly')
  ),
  policy_version TEXT NOT NULL,
  consent_text_hash TEXT NOT NULL,
  accepted BOOLEAN NOT NULL DEFAULT TRUE,
  accepted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_site_feature_consents_workspace_id
  ON site_feature_consents(workspace_id);
CREATE INDEX IF NOT EXISTS idx_site_feature_consents_user_id
  ON site_feature_consents(user_id);
CREATE INDEX IF NOT EXISTS idx_site_feature_consents_mode
  ON site_feature_consents(mode);

-- ---------------------------------------------------------------------
-- 3) Site Jobs
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  session_id UUID, -- optional link to ai_sessions.id
  mode TEXT NOT NULL CHECK (
    mode IN ('migration_verified', 'recreation_layout_only', 'audit_readonly')
  ),
  target_url TEXT,
  target_domain TEXT,
  verification_id UUID REFERENCES site_ownership_verifications(id) ON DELETE SET NULL,
  status TEXT NOT NULL CHECK (
    status IN (
      'created',
      'ownership_pending',
      'ownership_verified',
      'queued',
      'crawling',
      'extracting',
      'generating',
      'auditing',
      'review_ready',
      'report_ready',
      'applied',
      'completed',
      'failed',
      'canceled',
      'blocked'
    )
  ),
  phase TEXT NOT NULL CHECK (
    phase IN (
      'intake',
      'verification',
      'crawl',
      'extraction',
      'generation',
      'audit',
      'finalize'
    )
  ),
  options JSONB NOT NULL DEFAULT '{}'::jsonb,
  progress_percent INTEGER NOT NULL DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
  pages_discovered INTEGER NOT NULL DEFAULT 0,
  pages_processed INTEGER NOT NULL DEFAULT 0,
  trace_id TEXT,
  request_id TEXT,
  policy_version TEXT NOT NULL DEFAULT '1.0',
  error_code TEXT,
  error_message TEXT,
  retryable BOOLEAN,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_jobs_workspace_id
  ON site_jobs(workspace_id);
CREATE INDEX IF NOT EXISTS idx_site_jobs_user_id
  ON site_jobs(user_id);
CREATE INDEX IF NOT EXISTS idx_site_jobs_mode
  ON site_jobs(mode);
CREATE INDEX IF NOT EXISTS idx_site_jobs_status
  ON site_jobs(status);
CREATE INDEX IF NOT EXISTS idx_site_jobs_phase
  ON site_jobs(phase);
CREATE INDEX IF NOT EXISTS idx_site_jobs_created_at
  ON site_jobs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_site_jobs_target_domain
  ON site_jobs(target_domain);

-- Idempotency for job creation (optional if provided in options->idempotencyKey)
CREATE UNIQUE INDEX IF NOT EXISTS uq_site_jobs_idempotency
  ON site_jobs((options->>'idempotencyKey'))
  WHERE (options->>'idempotencyKey') IS NOT NULL;

-- ---------------------------------------------------------------------
-- 4) Job Phase Events (durable timeline)
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_job_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  phase TEXT,
  status TEXT,
  sequence INTEGER NOT NULL,
  message TEXT,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_job_events_job_id
  ON site_job_events(job_id);
CREATE INDEX IF NOT EXISTS idx_site_job_events_created_at
  ON site_job_events(created_at);
CREATE UNIQUE INDEX IF NOT EXISTS uq_site_job_events_sequence
  ON site_job_events(job_id, sequence);

-- ---------------------------------------------------------------------
-- 5) Crawl Results
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_crawl_pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  page_url TEXT NOT NULL,
  normalized_url TEXT NOT NULL,
  depth INTEGER NOT NULL DEFAULT 0,
  status_code INTEGER,
  fetch_status TEXT NOT NULL CHECK (
    fetch_status IN ('success', 'failed', 'blocked', 'skipped')
  ),
  render_duration_ms BIGINT,
  fetch_duration_ms BIGINT,
  bytes_fetched BIGINT,
  links_discovered_count INTEGER NOT NULL DEFAULT 0,
  resource_count INTEGER NOT NULL DEFAULT 0,
  title TEXT,
  meta_description TEXT,
  h1 TEXT,
  html_artifact_id UUID,
  screenshot_artifact_id UUID,
  error_code TEXT,
  error_message TEXT,
  confidence_score NUMERIC(5,4),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_crawl_pages_job_id
  ON site_crawl_pages(job_id);
CREATE INDEX IF NOT EXISTS idx_site_crawl_pages_normalized_url
  ON site_crawl_pages(normalized_url);
CREATE INDEX IF NOT EXISTS idx_site_crawl_pages_fetch_status
  ON site_crawl_pages(fetch_status);
CREATE INDEX IF NOT EXISTS idx_site_crawl_pages_depth
  ON site_crawl_pages(depth);

CREATE UNIQUE INDEX IF NOT EXISTS uq_site_crawl_pages_unique_url_per_job
  ON site_crawl_pages(job_id, normalized_url);

CREATE TABLE IF NOT EXISTS site_crawl_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  from_page_id UUID REFERENCES site_crawl_pages(id) ON DELETE SET NULL,
  to_url TEXT NOT NULL,
  normalized_to_url TEXT NOT NULL,
  is_internal BOOLEAN NOT NULL DEFAULT TRUE,
  rel_nofollow BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_crawl_links_job_id
  ON site_crawl_links(job_id);
CREATE INDEX IF NOT EXISTS idx_site_crawl_links_normalized_to_url
  ON site_crawl_links(normalized_to_url);

-- ---------------------------------------------------------------------
-- 6) Extraction Artifacts
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_extractions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  template_count INTEGER NOT NULL DEFAULT 0,
  component_count INTEGER NOT NULL DEFAULT 0,
  confidence_high INTEGER NOT NULL DEFAULT 0,
  confidence_medium INTEGER NOT NULL DEFAULT 0,
  confidence_low INTEGER NOT NULL DEFAULT 0,
  manual_review_required_count INTEGER NOT NULL DEFAULT 0,
  extraction_summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_site_extractions_job_id
  ON site_extractions(job_id);

CREATE TABLE IF NOT EXISTS site_extracted_pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  extraction_id UUID NOT NULL REFERENCES site_extractions(id) ON DELETE CASCADE,
  crawl_page_id UUID REFERENCES site_crawl_pages(id) ON DELETE SET NULL,
  page_url TEXT NOT NULL,
  template_candidate TEXT,
  confidence_score NUMERIC(5,4),
  needs_manual_review BOOLEAN NOT NULL DEFAULT FALSE,
  section_count INTEGER NOT NULL DEFAULT 0,
  component_count INTEGER NOT NULL DEFAULT 0,
  style_signature_hash TEXT,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_extracted_pages_extraction_id
  ON site_extracted_pages(extraction_id);
CREATE INDEX IF NOT EXISTS idx_site_extracted_pages_template_candidate
  ON site_extracted_pages(template_candidate);
CREATE INDEX IF NOT EXISTS idx_site_extracted_pages_needs_manual_review
  ON site_extracted_pages(needs_manual_review);

CREATE TABLE IF NOT EXISTS site_style_token_bundles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  extraction_id UUID NOT NULL REFERENCES site_extractions(id) ON DELETE CASCADE,
  token_format TEXT NOT NULL DEFAULT 'v1',
  colors JSONB NOT NULL DEFAULT '{}'::jsonb,
  typography JSONB NOT NULL DEFAULT '{}'::jsonb,
  spacing JSONB NOT NULL DEFAULT '{}'::jsonb,
  radii_shadows JSONB NOT NULL DEFAULT '{}'::jsonb,
  confidence_score NUMERIC(5,4),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_site_style_token_bundles_extraction_id
  ON site_style_token_bundles(extraction_id);

-- ---------------------------------------------------------------------
-- 7) Regeneration and Mapping
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_regenerations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  extraction_id UUID NOT NULL REFERENCES site_extractions(id) ON DELETE CASCADE,
  target_stack TEXT NOT NULL,
  content_mode TEXT NOT NULL CHECK (content_mode IN ('placeholder', 'rewrite', 'mixed')),
  route_strategy TEXT NOT NULL DEFAULT 'inferred' CHECK (route_strategy IN ('inferred', 'simplified')),
  status TEXT NOT NULL CHECK (status IN ('started', 'completed', 'failed', 'review_ready')),
  files_generated INTEGER NOT NULL DEFAULT 0,
  unresolved_mappings INTEGER NOT NULL DEFAULT 0,
  patch_plan_id UUID,
  generation_summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_site_regenerations_job_id
  ON site_regenerations(job_id);
CREATE INDEX IF NOT EXISTS idx_site_regenerations_status
  ON site_regenerations(status);

CREATE TABLE IF NOT EXISTS site_mapping_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  regeneration_id UUID NOT NULL REFERENCES site_regenerations(id) ON DELETE CASCADE,
  page_id TEXT NOT NULL,
  section_id TEXT NOT NULL,
  target_component TEXT NOT NULL,
  props_override JSONB NOT NULL DEFAULT '{}'::jsonb,
  adjusted_by_user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_mapping_adjustments_regeneration_id
  ON site_mapping_adjustments(regeneration_id);

-- ---------------------------------------------------------------------
-- 8) Competitive Audit Reports
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_audit_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  structure_score NUMERIC(6,2),
  performance_score NUMERIC(6,2),
  seo_score NUMERIC(6,2),
  component_complexity_score NUMERIC(6,2),
  summary JSONB NOT NULL DEFAULT '{}'::jsonb,
  findings JSONB NOT NULL DEFAULT '[]'::jsonb,
  comparisons JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_site_audit_reports_job_id
  ON site_audit_reports(job_id);

-- ---------------------------------------------------------------------
-- 9) Artifact Registry and Exports
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_artifacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  artifact_type TEXT NOT NULL CHECK (
    artifact_type IN (
      'raw_html',
      'screenshot',
      'crawl_summary',
      'extraction_bundle',
      'mapping_report',
      'scaffold_bundle',
      'audit_report_json',
      'audit_report_pdf'
    )
  ),
  storage_type TEXT NOT NULL DEFAULT 'object_storage' CHECK (
    storage_type IN ('object_storage', 'filesystem', 'db_inline')
  ),
  storage_ref TEXT NOT NULL,
  size_bytes BIGINT,
  checksum_sha256 TEXT,
  policy_class TEXT NOT NULL CHECK (
    policy_class IN ('report_only', 'scaffold_code', 'raw_content_bundle')
  ),
  allowed_in_mode JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_site_artifacts_job_id
  ON site_artifacts(job_id);
CREATE INDEX IF NOT EXISTS idx_site_artifacts_artifact_type
  ON site_artifacts(artifact_type);
CREATE INDEX IF NOT EXISTS idx_site_artifacts_policy_class
  ON site_artifacts(policy_class);

CREATE TABLE IF NOT EXISTS site_export_downloads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES site_jobs(id) ON DELETE CASCADE,
  artifact_id UUID NOT NULL REFERENCES site_artifacts(id) ON DELETE CASCADE,
  requested_by_user_id TEXT NOT NULL,
  signed_url TEXT,
  status TEXT NOT NULL CHECK (status IN ('created', 'downloaded', 'expired', 'blocked')),
  expires_at TIMESTAMPTZ NOT NULL,
  downloaded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_export_downloads_job_id
  ON site_export_downloads(job_id);
CREATE INDEX IF NOT EXISTS idx_site_export_downloads_status
  ON site_export_downloads(status);
CREATE INDEX IF NOT EXISTS idx_site_export_downloads_expires_at
  ON site_export_downloads(expires_at);

-- ---------------------------------------------------------------------
-- 10) Policy Events / Compliance Audit
-- ---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS site_policy_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID REFERENCES site_jobs(id) ON DELETE SET NULL,
  workspace_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  mode TEXT,
  action TEXT NOT NULL,
  outcome TEXT NOT NULL CHECK (outcome IN ('allowed', 'blocked')),
  policy_rule_id TEXT NOT NULL,
  policy_version TEXT NOT NULL,
  target_url TEXT,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_site_policy_events_job_id
  ON site_policy_events(job_id);
CREATE INDEX IF NOT EXISTS idx_site_policy_events_workspace_id
  ON site_policy_events(workspace_id);
CREATE INDEX IF NOT EXISTS idx_site_policy_events_user_id
  ON site_policy_events(user_id);
CREATE INDEX IF NOT EXISTS idx_site_policy_events_created_at
  ON site_policy_events(created_at DESC);

-- ---------------------------------------------------------------------
-- 11) Generic Updated-At Trigger
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_updated_at_generic()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_site_jobs_updated_at ON site_jobs;
CREATE TRIGGER trg_site_jobs_updated_at
BEFORE UPDATE ON site_jobs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_generic();

-- ---------------------------------------------------------------------
-- 12) Helpful Views
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW v_site_job_overview AS
SELECT
  j.id AS job_id,
  j.workspace_id,
  j.user_id,
  j.mode,
  j.status,
  j.phase,
  j.progress_percent,
  j.pages_discovered,
  j.pages_processed,
  j.created_at,
  j.updated_at,
  j.completed_at
FROM site_jobs j;

CREATE OR REPLACE VIEW v_site_job_crawl_health AS
SELECT
  p.job_id,
  COUNT(*) AS total_pages,
  COUNT(*) FILTER (WHERE p.fetch_status = 'success') AS success_pages,
  COUNT(*) FILTER (WHERE p.fetch_status = 'failed') AS failed_pages,
  COUNT(*) FILTER (WHERE p.fetch_status = 'blocked') AS blocked_pages,
  AVG(p.render_duration_ms) AS avg_render_duration_ms
FROM site_crawl_pages p
GROUP BY p.job_id;

CREATE OR REPLACE VIEW v_site_policy_block_summary AS
SELECT
  workspace_id,
  mode,
  policy_rule_id,
  COUNT(*) AS blocked_count,
  MAX(created_at) AS last_blocked_at
FROM site_policy_events
WHERE outcome = 'blocked'
GROUP BY workspace_id, mode, policy_rule_id;

COMMIT;