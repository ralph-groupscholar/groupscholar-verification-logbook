# Group Scholar Verification Logbook

A Dart CLI that logs scholarship verification checks (identity, residency, income, enrollment) into Postgres and provides filtered views and summaries for operations.

## Features
- Add verification checks with consistent fields and timestamps
- Filter and list recent checks by status, type, or scholar
- Summarize verification volume by status or check type
- Production-ready Postgres schema and seed data

## Tech
- Dart 3.10
- `postgres` driver
- Postgres (shared Group Scholar cluster, schema `gsvl`)

## Setup
Install dependencies:

```bash
dart pub get
```

Configure environment variables (do not commit real secrets):

```bash
export PGHOST=db-acupinir.groupscholar.com
export PGPORT=23947
export PGDATABASE=postgres
export PGUSER=ralph
export PGPASSWORD=your_password_here
export PGSSLMODE=disable
```

Initialize schema + seed data in production:

```bash
psql "postgresql://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE?sslmode=$PGSSLMODE" \
  -f sql/schema.sql
psql "postgresql://$PGUSER:$PGPASSWORD@$PGHOST:$PGPORT/$PGDATABASE?sslmode=$PGSSLMODE" \
  -f sql/seed.sql
```

## Usage

Add a verification check:

```bash
dart run bin/groupscholar_verification_logbook.dart add \
  --scholar "Avery Johnson" \
  --scholar-id "GS-102" \
  --type "Residency" \
  --status "verified" \
  --by "Ralph" \
  --notes "Lease + utility bill received"
```

List recent checks:

```bash
dart run bin/groupscholar_verification_logbook.dart list --limit 10 --status verified
```

Summary for the last 60 days:

```bash
dart run bin/groupscholar_verification_logbook.dart summary --window 60
```

## Tests

```bash
dart test
```
