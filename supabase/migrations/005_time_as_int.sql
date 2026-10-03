-- Phase 6: Store schedule times as integer (minutes from midnight)
-- This migration converts PostgreSQL 'time' columns to 'integer' for faster comparison
-- and aligns with Dart-side ScheduleSlot model (int instead of String)

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_name = 'doctor_schedule'
      and column_name = 'start_time'
      and data_type = 'time without time zone'
  ) then
    -- Convert doctor_schedule time columns to integer
    ALTER TABLE doctor_schedule
      ALTER COLUMN start_time TYPE integer
        USING extract(hour from start_time)::integer * 60 + extract(minute from start_time)::integer,
      ALTER COLUMN end_time TYPE integer
        USING extract(hour from end_time)::integer * 60 + extract(minute from end_time)::integer,
      ALTER COLUMN break_start TYPE integer
        USING extract(hour from break_start)::integer * 60 + extract(minute from break_start)::integer,
      ALTER COLUMN break_end TYPE integer
        USING extract(hour from break_end)::integer * 60 + extract(minute from break_end)::integer;
  end if;
end $$;

-- Add constraints for valid time ranges (0-1439 minutes = 00:00 to 23:59)
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'check_start_time_range'
  ) then
    ALTER TABLE doctor_schedule
      ADD CONSTRAINT check_start_time_range CHECK (start_time >= 0 AND start_time < 1440);
  end if;
  if not exists (
    select 1 from pg_constraint where conname = 'check_end_time_range'
  ) then
    ALTER TABLE doctor_schedule
      ADD CONSTRAINT check_end_time_range CHECK (end_time > 0 AND end_time <= 1440);
  end if;
  if not exists (
    select 1 from pg_constraint where conname = 'check_break_range'
  ) then
    ALTER TABLE doctor_schedule
      ADD CONSTRAINT check_break_range CHECK (
        (break_start IS NULL AND break_end IS NULL) OR
        (break_start >= 0 AND break_start < 1440 AND break_end > 0 AND break_end <= 1440 AND break_start < break_end)
      );
  end if;
end $$;

-- Add computed total minutes column (useful for queries)
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_name = 'doctor_schedule'
      and column_name = 'total_minutes'
  ) then
    ALTER TABLE doctor_schedule ADD COLUMN total_minutes integer
      GENERATED ALWAYS AS (
        (end_time - start_time) -
        CASE WHEN break_start IS NOT NULL AND break_end IS NOT NULL
        THEN (break_end - break_start) ELSE 0 END
      ) STORED;
  end if;
end $$;

COMMENT ON COLUMN doctor_schedule.total_minutes IS 'Total available minutes after breaks';
COMMENT ON COLUMN doctor_schedule.start_time IS 'Minutes from midnight (0-1439)';
COMMENT ON COLUMN doctor_schedule.end_time IS 'Minutes from midnight (0-1439)';