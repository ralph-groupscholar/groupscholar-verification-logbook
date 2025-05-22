CREATE SCHEMA IF NOT EXISTS gsvl;

CREATE TABLE IF NOT EXISTS gsvl.verification_checks (
  id UUID PRIMARY KEY,
  scholar_name TEXT NOT NULL,
  scholar_id TEXT,
  check_type TEXT NOT NULL,
  status TEXT NOT NULL,
  notes TEXT,
  performed_by TEXT,
  performed_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS verification_checks_status_idx
  ON gsvl.verification_checks (status);

CREATE INDEX IF NOT EXISTS verification_checks_scholar_idx
  ON gsvl.verification_checks (scholar_id);

CREATE INDEX IF NOT EXISTS verification_checks_performed_idx
  ON gsvl.verification_checks (performed_at DESC);
