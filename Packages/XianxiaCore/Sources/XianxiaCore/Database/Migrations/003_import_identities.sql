BEGIN IMMEDIATE;
CREATE TABLE book_import_identities (
    book_id TEXT PRIMARY KEY NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    format TEXT NOT NULL CHECK (format IN ('epub', 'txt')),
    sha256 TEXT NOT NULL CHECK (length(sha256) = 64),
    byte_count INTEGER NOT NULL CHECK (byte_count >= 0),
    normalized_sha256 TEXT,
    CHECK (normalized_sha256 IS NULL OR length(normalized_sha256) = 64)
);
-- Nonunique: upgrading must preserve every pre-existing duplicate and its history.
CREATE INDEX import_identity_lookup ON book_import_identities(format, sha256, byte_count, normalized_sha256);
PRAGMA user_version = 3;
COMMIT;
