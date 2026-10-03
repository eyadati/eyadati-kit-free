# Testing Eyadati Kit (free tier)

This document describes every automated check in this repository, how to run
each layer locally, and which jobs run in CI. The premium kit ships an
extended version of this document covering its payment, SMS, and webhook
testing.

## Test layers at a glance

| Layer | Location | Needs network/DB | Runs in |
|---|---|---|---|
| Dart unit tests (shared core) | `test/core/`, `test/models/` | no | local + CI `dart` job |
| Repository query-shape tests | `test/repositories/` | no (MockClient) | local + CI `dart` job |
| Booking-flow integration test | `test/booking/` | no (in-process mocks) | local + CI `dart` job |
| Free-tier scope tests | `test/core/{providers,routing}/` | no | local + CI `dart` job |
| SQL schema invariants | `supabase/tests/invariants.sql` | local Supabase stack (Docker) | CI `database` job |
| Edge function type-check | `supabase/functions/*/index.ts` | no | CI `edge-functions` job |
| Open-core static verification | `scripts/verify_kit.py` (source repo) | no | pre-release, source repo |

All Dart tests run against **in-memory fakes** (`package:http` `MockClient`,
fake JWT sessions). No test touches a real backend or a real provider.

## Running tests locally

### Dart (all layers)

```sh
flutter pub get
flutter analyze        # gate: errors only (see "Analyzers" below)
flutter test
```

Expected: every test green, zero analyzer **errors**. Info-level lints and a
small set of pre-existing warnings are accepted baseline.

### SQL schema invariants

Requires Docker + the Supabase CLI (not runnable in environments without
Docker):

```sh
supabase start
supabase db reset
eval "$(supabase status -o env)"
psql "${DB_URL:-postgresql://postgres:postgres@127.0.0.1:54322/postgres}" \
  -v ON_ERROR_STOP=1 -f supabase/tests/invariants.sql
```

Because this repo is a CI-friendly substitute for a live database, the
`database` GitHub Actions job runs exactly the commands above on every push.
Every invariant is a `DO` block that `RAISE EXCEPTION`s; `ON_ERROR_STOP`
turns any violation into a failed build.

Without Docker you can still syntax-check SQL with
[pglast](https://pypi.org/project/pglast/):

```sh
pip install pglast
python3 -c "from pathlib import Path; from pglast import parse_sql; \
[parse_sql(p.read_text()) for p in Path('supabase/migrations').glob('*.sql')]; \
print('syntax OK')"
```

### Edge functions (Deno type-check)

Requires [Deno](https://deno.land) 2.x:

```sh
for f in delete-account patient-reset-password; do
  deno check --allow-import "supabase/functions/$f/index.ts"
done
```

## What each test suite pins down

### Shared core (`test/core/`, `test/models/`)

- **time_utils** — weekday math, `dateForWeekday`, Arabic/French date
  formatting, month boundaries.
- **input_validator** — Algerian phone normalization (`05 55 12 34 56` ⇄
  `+213555123456`), email/name/password rules, input sanitization.
- **security_validator** — `sanitizeHtml` entity escaping (quotes included),
  JWT/HMAC helpers, secret redaction.
- **pagination** — `PaginationParams` defaults, `hasPagination` semantics.
- **availability_service** — engine slot generation, breaks, past-slot
  filtering, day selection.
- **schedule_slot_model / appointment_data** — serialization round-trips,
  `fromDatabase` mapping, status enums.

### Repository query-shape tests (`test/repositories/`)

PostgREST query strings are asserted **byte-for-byte** through a capturing
`MockClient`:

- filter encoding (`.eq`, `.ilike`, `.or(...)` with parentheses),
- `.order()` default direction (`created_at.desc.nullslast`),
- `.range()` → `offset` / `limit` query parameters,
- auth guards: no session ⇒ zero HTTP requests.

**Pinned production quirk:** `PaginationParams.hasPagination` is `true` only
when an explicit `limit`/`offset` is supplied — passing `page`/`pageSize`
alone never triggers a server-side `.range()`. This mirrors production
behavior; changing it is a product decision, not a test fix.

### Booking flow (`test/booking/`)

One end-to-end path, entirely in-process:

1. mint a fake JWT and `setSession` (mock `/auth/v1/user`),
2. build a Monday schedule in the availability engine,
3. pick the first valid 30-minute slot (540 minutes = 09:00),
4. `createAppointment` → assert the insert body
   (`patient_name_snapshot` sanitized, `status: 'upcoming'`,
   `booking_type: 'online'`, UTC `scheduled_at`),
5. confirm the booked slot disappears from the engine,
6. negative paths: invalid doctor id, past datetime, missing session —
   each fails **before** any INSERT is issued.

### Free-tier scope tests

- **ports_providers_test** — mock payment/SMS/push ports wire through; no
  subscription concept anywhere in the provider graph.
- **route_scope_test** — no subscription/payment routes; premium pages,
  providers, models, and functions directories are absent; the only entry
  under `lib/core/infrastructure/` is the mock adapter.

### SQL invariants (`supabase/tests/invariants.sql`)

- the 7 core tables exist with RLS enabled,
- engine functions (`book_appointment`, `get_available_slots_v2`,
  `appointments_time_range`) exist,
- `doctor_schedule` time/day CHECK constraints exist,
- **open-core boundary:** no billing/clinic tables and no subscription
  columns on `doctors` — the file enumerates exactly which (it is exempt
  from the deny scan precisely because it must name what it forbids).

## Analyzers and gates

- `flutter analyze` reports info-level lints as part of the accepted
  baseline. CI only fails on lines containing `error •`.
- The open-core source pipeline (`scripts/verify_kit.py`) additionally
  enforces: no premium routes/tables in the free tier, no secrets in any
  tracked file, manifest consistency, workflow YAML validity, and pglast
  parsing of every migration.
- Free-tier deny-scan exemptions: `README.md`, `LICENSE`, `.gitignore`,
  `supabase/config.toml`, and `test/` / `integration_test/` /
  `supabase/tests/` (these legitimately reference premium names in negative
  assertions).

## CI jobs in this repository

- **dart** — `flutter pub get`, error-only analyze gate, `flutter test`,
  `flutter build web --release`.
- **database** — `supabase start` → `supabase db reset` → run
  `supabase/tests/invariants.sql` with `ON_ERROR_STOP=1`.
- **edge-functions** — `deno check` both Edge Functions.

## Known quirks worth knowing before you "fix" a test

1. `.order(col)` without `ascending: true` sends `desc.nullslast` — tests
   assert this because production relies on it.
2. `.or()` filters are wrapped in parentheses by postgrest — assert the
   parentheses, don't strip them.
3. MockClient responses must be constructed with `request: request`;
   postgrest dereferences `response.request!`.
4. gotrue decodes **all three** JWT segments — a dummy signature segment
   must still be valid base64url.
5. `sanitizeHtml("it's")` escapes to `it&#x27;s` (mid-string entity, not
   leading).

## Known limitations (intentional, documented)

1. The upstream SaaS is Algeria-only; this kit is not: phone validation
   accepts international E.164 numbers, the city list lives in
   `lib/core/constants/app_regions.dart` (replace it with your region), and
   adapter credentials come from env. See README → Internationalization.
2. `lib/l10n` ships French (template) + Arabic only — add `app_en.arb` and
   re-run `flutter gen-l10n` to enable English l10n strings.
