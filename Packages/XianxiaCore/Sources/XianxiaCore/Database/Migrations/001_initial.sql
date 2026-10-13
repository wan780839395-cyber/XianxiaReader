BEGIN IMMEDIATE;
CREATE TABLE books (
    id TEXT PRIMARY KEY NOT NULL,
    payload BLOB NOT NULL,
    imported_at REAL NOT NULL
);
CREATE TABLE chapters (
    id TEXT PRIMARY KEY NOT NULL,
    book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    ordinal INTEGER NOT NULL CHECK (ordinal >= 0),
    payload BLOB NOT NULL,
    UNIQUE(book_id, ordinal)
);
CREATE TABLE reading_positions (
    book_id TEXT PRIMARY KEY NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    progression REAL CHECK (progression IS NULL OR (progression >= 0 AND progression <= 1)),
    updated_at REAL NOT NULL,
    payload BLOB NOT NULL
);
CREATE TABLE bookmarks (
    id TEXT PRIMARY KEY NOT NULL,
    book_id TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    created_at REAL NOT NULL,
    payload BLOB NOT NULL
);
CREATE INDEX bookmarks_by_book ON bookmarks(book_id, created_at);
CREATE INDEX books_by_import_date ON books(imported_at);
PRAGMA user_version = 1;
COMMIT;
