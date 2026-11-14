-- Apply only to an existing V1 database that already has base schema tables.
ALTER TABLE legal_entries ADD COLUMN exact_text TEXT;
ALTER TABLE legal_entries ADD COLUMN text_is_verified INTEGER NOT NULL DEFAULT 0 CHECK(text_is_verified IN (0,1));
ALTER TABLE legal_entries ADD COLUMN limitations TEXT;
ALTER TABLE legal_entries ADD COLUMN plain_explanation TEXT;
ALTER TABLE legal_entries ADD COLUMN applicable_scope TEXT NOT NULL DEFAULT 'jurisdiction-specific';
ALTER TABLE legal_entries ADD COLUMN reviewed_by TEXT;
ALTER TABLE legal_entries ADD COLUMN reviewed_at TEXT;
CREATE TABLE IF NOT EXISTS procedures (id INTEGER PRIMARY KEY AUTOINCREMENT,entry_id INTEGER NOT NULL REFERENCES legal_entries(id) ON DELETE CASCADE,step_number INTEGER NOT NULL,title TEXT NOT NULL,instruction TEXT NOT NULL,authority TEXT,documents TEXT,deadline TEXT,escalation TEXT,citation_url TEXT,status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','verified','retired')),UNIQUE(entry_id,step_number));
CREATE TABLE IF NOT EXISTS judgments (id INTEGER PRIMARY KEY AUTOINCREMENT,entry_id INTEGER NOT NULL REFERENCES legal_entries(id) ON DELETE CASCADE,case_title TEXT NOT NULL,court TEXT NOT NULL,citation TEXT NOT NULL,decided_at TEXT,holding TEXT,binding_scope TEXT,url TEXT NOT NULL,reviewed_at TEXT,status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','verified','retired')));
CREATE INDEX IF NOT EXISTS idx_entries_jurisdiction ON legal_entries(jurisdiction,status);
CREATE INDEX IF NOT EXISTS idx_procedures_entry ON procedures(entry_id,status);
CREATE INDEX IF NOT EXISTS idx_judgments_entry ON judgments(entry_id,status);
