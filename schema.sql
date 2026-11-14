PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS sources (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 title TEXT NOT NULL,
 url TEXT NOT NULL UNIQUE,
 publisher TEXT NOT NULL,
 jurisdiction TEXT NOT NULL CHECK(jurisdiction IN ('PK-FED','PK-PB','PK-SD','PK-KP','PK-BA','PK-ICT','INT')),
 instrument_type TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','verified','retired')),
 reviewed_at TEXT,
 reviewer TEXT,
 notes TEXT
);
CREATE TABLE IF NOT EXISTS legal_entries (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 source_id INTEGER NOT NULL REFERENCES sources(id),
 title TEXT NOT NULL,
 topic TEXT NOT NULL,
 audience TEXT NOT NULL DEFAULT 'everyone',
 jurisdiction TEXT NOT NULL,
 section_ref TEXT,
 summary TEXT NOT NULL,
 effective_date TEXT,
 updated_at TEXT NOT NULL DEFAULT (datetime('now')),
 status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','verified','retired'))
);
CREATE INDEX IF NOT EXISTS idx_entries_status_topic ON legal_entries(status,topic);
CREATE INDEX IF NOT EXISTS idx_sources_status ON sources(status);
CREATE VIRTUAL TABLE IF NOT EXISTS legal_fts USING fts5(title,summary,topic,content='legal_entries',content_rowid='id');
CREATE TRIGGER IF NOT EXISTS legal_ai AFTER INSERT ON legal_entries BEGIN
 INSERT INTO legal_fts(rowid,title,summary,topic) VALUES(new.id,new.title,new.summary,new.topic);
END;
CREATE TRIGGER IF NOT EXISTS legal_ad AFTER DELETE ON legal_entries BEGIN
 INSERT INTO legal_fts(legal_fts,rowid,title,summary,topic) VALUES('delete',old.id,old.title,old.summary,old.topic);
END;
CREATE TRIGGER IF NOT EXISTS legal_au AFTER UPDATE ON legal_entries BEGIN
 INSERT INTO legal_fts(legal_fts,rowid,title,summary,topic) VALUES('delete',old.id,old.title,old.summary,old.topic);
 INSERT INTO legal_fts(rowid,title,summary,topic) VALUES(new.id,new.title,new.summary,new.topic);
END;
CREATE TABLE IF NOT EXISTS rate_limits (bucket TEXT PRIMARY KEY, count INTEGER NOT NULL, expires_at INTEGER NOT NULL);

-- V2: reviewer-controlled, jurisdiction-aware legal research records.
ALTER TABLE legal_entries ADD COLUMN exact_text TEXT;
ALTER TABLE legal_entries ADD COLUMN text_is_verified INTEGER NOT NULL DEFAULT 0 CHECK(text_is_verified IN (0,1));
ALTER TABLE legal_entries ADD COLUMN limitations TEXT;
ALTER TABLE legal_entries ADD COLUMN plain_explanation TEXT;
ALTER TABLE legal_entries ADD COLUMN applicable_scope TEXT NOT NULL DEFAULT 'jurisdiction-specific';
ALTER TABLE legal_entries ADD COLUMN reviewed_by TEXT;
ALTER TABLE legal_entries ADD COLUMN reviewed_at TEXT;
CREATE TABLE IF NOT EXISTS procedures (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 entry_id INTEGER NOT NULL REFERENCES legal_entries(id) ON DELETE CASCADE,
 step_number INTEGER NOT NULL,
 title TEXT NOT NULL,
 instruction TEXT NOT NULL,
 authority TEXT,
 documents TEXT,
 deadline TEXT,
 escalation TEXT,
 citation_url TEXT,
 status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','verified','retired')),
 UNIQUE(entry_id,step_number)
);
CREATE TABLE IF NOT EXISTS judgments (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 entry_id INTEGER NOT NULL REFERENCES legal_entries(id) ON DELETE CASCADE,
 case_title TEXT NOT NULL,
 court TEXT NOT NULL,
 citation TEXT NOT NULL,
 decided_at TEXT,
 holding TEXT,
 binding_scope TEXT,
 url TEXT NOT NULL,
 reviewed_at TEXT,
 status TEXT NOT NULL DEFAULT 'draft' CHECK(status IN ('draft','verified','retired'))
);
CREATE INDEX IF NOT EXISTS idx_entries_jurisdiction ON legal_entries(jurisdiction,status);
CREATE INDEX IF NOT EXISTS idx_procedures_entry ON procedures(entry_id,status);
CREATE INDEX IF NOT EXISTS idx_judgments_entry ON judgments(entry_id,status);
