BEGIN IMMEDIATE;
CREATE TABLE removed_books (
    book_id TEXT PRIMARY KEY NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    removed_at REAL NOT NULL
);
CREATE INDEX removed_books_by_date ON removed_books(removed_at);
PRAGMA user_version = 2;
COMMIT;
