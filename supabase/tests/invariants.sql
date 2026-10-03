-- ============================================================
-- Eyadati Kit (free tier) — schema invariants
--
-- Verifies the open-core boundary on a freshly reset database:
--   supabase db reset
--   psql "$CI_DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/invariants.sql
--
-- Plain psql (no pgTAP needed): every violation raises an exception,
-- which ON_ERROR_STOP turns into a non-zero exit code.
-- ============================================================

\set ON_ERROR_STOP on

-- 1. Core tables exist and have RLS enabled.
do $$
declare
  tbl text;
  missing text := '';
  no_rls text := '';
  core constant text[] := array[
    'profiles', 'patients', 'doctors', 'appointments',
    'doctor_schedule', 'favorites', 'app_versions'
  ];
begin
  foreach tbl in array core loop
    if to_regclass('public.' || tbl) is null then
      missing := missing || tbl || ' ';
    elsif not exists (
      select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = tbl
        and c.relrowsecurity
    ) then
      no_rls := no_rls || tbl || ' ';
    end if;
  end loop;

  if missing <> '' then
    raise exception 'missing core tables: %', missing;
  end if;
  if no_rls <> '' then
    raise exception 'RLS not enabled on: %', no_rls;
  end if;
end $$;

-- 2. Slot-booking engine functions are present.
do $$
declare
  fn text;
  missing text := '';
begin
  foreach fn in array array[
    'book_appointment', 'get_available_slots_v2', 'appointments_time_range'
  ] loop
    if not exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = fn
    ) then
      missing := missing || fn || ' ';
    end if;
  end loop;

  if missing <> '' then
    raise exception 'missing engine functions: %', missing;
  end if;
end $$;

-- 3. Schedule sanity constraints shipped in 001.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'valid_time_range'
      and conrelid = 'public.doctor_schedule'::regclass
  ) then
    raise exception 'doctor_schedule.valid_time_range check missing';
  end if;

  -- PostgreSQL deparses `between 0 and 6` as `>= 0 AND <= 6`, so match
  -- both renderings (the literal form never appears in pg_get_constraintdef).
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.doctor_schedule'::regclass
      and contype = 'c'
      and (
        pg_get_constraintdef(oid) like '%day_of_week between 0 and 6%'
        or pg_get_constraintdef(oid) like '%day_of_week >= 0%6%'
      )
  ) then
    raise exception 'doctor_schedule day_of_week range check missing';
  end if;
end $$;

-- 4. Open-core boundary: premium artifacts must not exist.
do $$
declare
  t text;
begin
  foreach t in array array[
    'payment_history', 'call_logs', 'push_tokens',
    'patient_notes', 'clinic_groups', 'clinic_group_members'
  ] loop
    if to_regclass('public.' || t) is not null then
      raise exception 'free tier must not contain table %', t;
    end if;
  end loop;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'doctors'
      and column_name in ('subscription_end', 'plan_type')
  ) then
    raise exception
      'free tier must not have doctors.subscription_end / plan_type';
  end if;
end $$;

select 'free tier invariants OK' as result;
