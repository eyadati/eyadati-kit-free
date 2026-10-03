-- Phase 4: Slot Engine Refactor
-- Consolidates schedule into doctor_schedule as single source of truth
-- Adds patients table, per-day breaks, and server-side availability validation

-- ============================================
-- STEP 1: Add per-day break columns to doctor_schedule
-- ============================================
alter table public.doctor_schedule
  add column if not exists break_start time,
  add column if not exists break_end time;

comment on column public.doctor_schedule.break_start is 'Break start time for this specific day (e.g. 12:00)';
comment on column public.doctor_schedule.break_end is 'Break end time for this specific day (e.g. 13:00)';

-- ============================================
-- STEP 2: Remove old schedule columns from doctors
-- These are now managed in doctor_schedule per day
-- ============================================
alter table public.doctors
  drop column if exists opening_at,
  drop column if exists closing_at,
  drop column if exists break_start,
  drop column if exists break_end,
  drop column if exists working_days;

-- ============================================
-- STEP 3: Add unique constraint to prevent duplicate active schedules
-- One active schedule row per doctor per day
-- ============================================
drop index if exists idx_schedule_doctor;
drop index if exists idx_schedule_day;
drop index if exists idx_schedule_active;

create unique index if not exists idx_schedule_unique_active
  on public.doctor_schedule(doctor_id, day_of_week)
  where is_active = true;

create index if not exists idx_schedule_doctor
  on public.doctor_schedule(doctor_id);

create index if not exists idx_schedule_doctor_day
  on public.doctor_schedule(doctor_id, day_of_week)
  where is_active = true;

-- ============================================
-- STEP 4: Add patients table
-- ============================================
drop table if exists public.patients cascade;

create table public.patients (
  id uuid primary key references public.profiles(id) on delete cascade,

  full_name text not null,
  phone text,
  date_of_birth date,
  gender text,
  address text,
  city text,

  emergency_contact text,
  emergency_phone text,

  blood_type text,
  allergies text,
  medical_history text,
  notes text,

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

comment on table public.patients is 'Patient profiles with medical information';
comment on column public.patients.blood_type is 'e.g. A+, O-, B+';
comment on column public.patients.allergies is 'Comma-separated list of known allergies';
comment on column public.patients.medical_history is 'General medical history and conditions';

-- Indexes for patient queries
create index if not exists idx_patients_name on public.patients(lower(full_name));
create index if not exists idx_patients_phone on public.patients(phone);
create index if not exists idx_patients_city on public.patients(city);

-- RLS for patients
alter table public.patients enable row level security;

create policy "Patients can view own profile"
  on public.patients for select
  using (auth.uid() = id);

create policy "Doctors can view patients"
  on public.patients for select
  using (
    exists (
      select 1 from public.appointments a
      where a.patient_id = auth.uid()
        and a.doctor_id = public.patients.id
    )
    or exists (
      select 1 from public.doctors d
      where d.id = auth.uid()
    )
  );

create policy "Patients can update own profile"
  on public.patients for update
  using (auth.uid() = id);

create policy "Patients can insert own profile"
  on public.patients for insert
  with check (auth.uid() = id);

-- ============================================
-- STEP 5: Add appointment_type column if not exists
-- ============================================
alter table public.appointments
  add column if not exists appointment_type text
  default 'standard'
  check (appointment_type in ('standard', 'consultation'));

comment on column public.appointments.appointment_type is 'Type: standard or consultation';

-- ============================================
-- STEP 6: Server-side slot availability validation
-- Replaces the old check_slot_availability with clean overlap logic
-- ============================================
drop function if exists public.check_slot_availability(uuid, timestamptz, integer);

create or replace function public.check_slot_availability(
  p_doctor_id uuid,
  p_scheduled_at timestamptz,
  p_duration integer
)
returns boolean as $$
declare
  v_day_of_week integer;
  v_slot_start time;
  v_slot_end time;
  v_has_schedule boolean;
  v_conflict_count integer;
  v_is_paused boolean;
  v_break_overlap boolean;
begin
  -- Check doctor is not paused
  select into v_is_paused
    coalesce(manual_pause, false)
  from public.doctors
  where id = p_doctor_id;

  if v_is_paused then
    return false;
  end if;



  -- Get day of week (PostgreSQL: 0=Sunday, 1=Monday...6=Saturday)
  v_day_of_week := extract(dow from p_scheduled_at at time zone 'UTC')::integer;
  v_slot_start := (p_scheduled_at at time zone 'UTC')::time;
  v_slot_end := (v_slot_start + (p_duration || ' minutes')::interval)::time;

  -- Check if doctor has active schedule for this day
  select exists (
    select 1 from public.doctor_schedule ds
    where ds.doctor_id = p_doctor_id
      and ds.day_of_week = v_day_of_week
      and ds.is_active = true
      and ds.start_time <= v_slot_start
      and ds.end_time >= v_slot_end
  ) into v_has_schedule;

  if not v_has_schedule then
    return false;
  end if;

  -- Check break time overlap
  select exists (
    select 1 from public.doctor_schedule ds
    where ds.doctor_id = p_doctor_id
      and ds.day_of_week = v_day_of_week
      and ds.is_active = true
      and ds.break_start is not null
      and ds.break_end is not null
      and ds.break_start < v_slot_end
      and ds.break_end > v_slot_start
  ) into v_break_overlap;

  if v_break_overlap then
    return false;
  end if;

  -- Check for appointment conflicts (overlap rule)
  select count(*) into v_conflict_count
  from public.appointments a
  where a.doctor_id = p_doctor_id
    and a.status in ('upcoming', 'pending')
    and (
      (a.scheduled_at at time zone 'UTC')::time <
        (p_scheduled_at at time zone 'UTC' + (p_duration || ' minutes')::interval)::time
      and
      (a.scheduled_at at time zone 'UTC' + ((a.duration || ' minutes')::interval))::time >
        (p_scheduled_at at time zone 'UTC')::time
    );

  if v_conflict_count > 0 then
    return false;
  end if;

  return true;
end;
$$ language plpgsql security definer;

-- ============================================
-- STEP 7: Updated book_appointment function with validation
-- ============================================
drop function if exists public.book_appointment(
  uuid, uuid, timestamptz, integer, text, text, boolean, text
);

create or replace function public.book_appointment(
  p_doctor_id uuid,
  p_patient_id uuid,
  p_scheduled_at timestamptz,
  p_duration integer,
  p_patient_name text,
  p_patient_phone text,
  p_is_consultation boolean default false,
  p_notes text default null
)
returns uuid as $$
declare
  v_appointment_id uuid;
  v_available boolean;
begin
  -- Validate inputs
  if p_patient_name is null or length(trim(p_patient_name)) = 0 then
    raise exception 'Patient name is required';
  end if;

  if p_duration < 5 or p_duration > 180 then
    raise exception 'Invalid duration. Must be between 5 and 180 minutes';
  end if;

  if p_scheduled_at < (now() + interval '30 minutes') then
    raise exception 'Appointment must be at least 30 minutes in the future';
  end if;

  -- Check slot availability using overlap logic
  select public.check_slot_availability(p_doctor_id, p_scheduled_at, p_duration) into v_available;
  if not v_available then
    raise exception 'This time slot is not available. Please choose another time.';
  end if;

  -- Create the appointment
  insert into public.appointments (
    doctor_id,
    patient_id,
    scheduled_at,
    duration,
    status,
    booking_type,
    is_consultation,
    appointment_type,
    patient_name_snapshot,
    patient_phone_snapshot,
    notes
  ) values (
    p_doctor_id,
    p_patient_id,
    p_scheduled_at,
    p_duration,
    'pending',
    'online',
    p_is_consultation,
    case when p_is_consultation then 'consultation' else 'standard' end,
    trim(p_patient_name),
    trim(coalesce(p_patient_phone, '')),
    trim(coalesce(p_notes, ''))
  )
  returning id into v_appointment_id;

  return v_appointment_id;
end;
$$ language plpgsql security definer;

-- ============================================
-- STEP 8: Updated create_manual_appointment function
-- ============================================
drop function if exists public.create_manual_appointment(
  uuid, timestamptz, integer, text, text, text
);

create or replace function public.create_manual_appointment(
  p_doctor_id uuid,
  p_scheduled_at timestamptz,
  p_duration integer,
  p_patient_name text,
  p_patient_phone text,
  p_notes text default null
)
returns uuid as $$
declare
  v_appointment_id uuid;
  v_available boolean;
  v_user_id uuid;
begin
  v_user_id := auth.uid();

  -- Validate doctor owns this action
  if v_user_id != p_doctor_id then
    raise exception 'Only the doctor can create manual appointments';
  end if;

  -- Validate inputs
  if p_patient_name is null or length(trim(p_patient_name)) = 0 then
    raise exception 'Patient name is required';
  end if;

  if p_duration < 5 or p_duration > 180 then
    raise exception 'Invalid duration';
  end if;

  if p_scheduled_at < (now() + interval '30 minutes') then
    raise exception 'Appointment must be at least 30 minutes in the future';
  end if;

  -- Check slot availability
  select public.check_slot_availability(p_doctor_id, p_scheduled_at, p_duration) into v_available;
  if not v_available then
    raise exception 'This time slot is not available. Please choose another time.';
  end if;

  -- Create the manual appointment
  insert into public.appointments (
    doctor_id,
    scheduled_at,
    duration,
    status,
    booking_type,
    is_consultation,
    appointment_type,
    patient_name_snapshot,
    patient_phone_snapshot,
    notes
  ) values (
    p_doctor_id,
    p_scheduled_at,
    p_duration,
    'upcoming',
    'manual',
    false,
    'standard',
    trim(p_patient_name),
    trim(coalesce(p_patient_phone, '')),
    trim(coalesce(p_notes, ''))
  )
  returning id into v_appointment_id;

  return v_appointment_id;
end;
$$ language plpgsql security definer;

-- ============================================
-- STEP 9: Updated get_available_slots SQL function
-- Now uses doctor_schedule as source of truth
-- ============================================
drop function if exists public.get_available_slots(uuid, date, integer, integer);

create or replace function public.get_available_slots(
  p_doctor_id uuid,
  p_date date,
  p_duration integer default 20,
  p_limit integer default 100
)
returns table (
  slot_start timestamptz,
  slot_end timestamptz,
  slot_duration integer
) as $$
declare
  v_day_of_week integer;
  v_slot_count integer := 0;
  v_row record;
  v_start_minutes integer;
  v_end_minutes integer;
  v_break_start_minutes integer;
  v_break_end_minutes integer;
  v_m integer;
  v_slot_start_time time;
  v_slot_end_time time;
begin
  -- Get day of week
  v_day_of_week := extract(dow from p_date)::integer;

  -- Iterate through each schedule row for this day
  for v_row in
    select start_time, end_time, break_start, break_end
    from public.doctor_schedule
    where doctor_id = p_doctor_id
      and day_of_week = v_day_of_week
      and is_active = true
  loop
    -- Parse start/end times to minutes
    v_start_minutes := (
      extract(hour from v_row.start_time)::integer * 60 +
      extract(minute from v_row.start_time)::integer
    );
    v_end_minutes := (
      extract(hour from v_row.end_time)::integer * 60 +
      extract(minute from v_row.end_time)::integer
    );

    -- Parse break times to minutes
    if v_row.break_start is not null and v_row.break_end is not null then
      v_break_start_minutes := (
        extract(hour from v_row.break_start)::integer * 60 +
        extract(minute from v_row.break_start)::integer
      );
      v_break_end_minutes := (
        extract(hour from v_row.break_end)::integer * 60 +
        extract(minute from v_row.break_end)::integer
      );
    else
      v_break_start_minutes := null;
      v_break_end_minutes := null;
    end if;

    -- Generate slots at interval intervals
    v_m := v_start_minutes;
    while v_m + p_duration <= v_end_minutes loop
      -- Skip if past limit
      if v_slot_count >= p_limit then
        return;
      end if;

      -- Skip if slot is in the past
      if p_date + (v_m || ' minutes')::interval < now() then
        v_m := v_m + p_duration;
        continue;
      end if;

      -- Skip if slot overlaps break time
      if v_break_start_minutes is not null and v_break_end_minutes is not null then
        if v_m < v_break_end_minutes and (v_m + p_duration) > v_break_start_minutes then
          v_m := v_m + p_duration;
          continue;
        end if;
      end if;

      -- Skip if slot conflicts with existing appointments
      if not exists (
        select 1 from public.appointments a
        where a.doctor_id = p_doctor_id
          and a.status in ('upcoming', 'pending')
          and date(a.scheduled_at) = p_date
          and (
            extract(hour from a.scheduled_at)::integer * 60 + extract(minute from a.scheduled_at)::integer
              < v_m + p_duration
          )
          and (
            extract(hour from a.scheduled_at)::integer * 60 + extract(minute from a.scheduled_at)::integer + a.duration
              > v_m
          )
      ) then
        slot_start := p_date + (v_m || ' minutes')::interval;
        slot_end := slot_start + (p_duration || ' minutes')::interval;
        slot_duration := p_duration;
        return next;
        v_slot_count := v_slot_count + 1;
      end if;

      v_m := v_m + p_duration;
    end loop;
  end loop;
end;
$$ language plpgsql security definer;

-- ============================================
-- STEP 10: Add updated_at trigger for patients
-- ============================================
drop trigger if exists patients_updated_at on public.patients;
create trigger patients_updated_at
  before update on public.patients
  for each row execute procedure public.update_updated_at();

-- ============================================
-- STEP 11: Grant permissions
-- ============================================
grant usage on schema public to anon;
grant execute on all functions in schema public to anon;
grant select on all tables in schema public to anon;
grant insert on public.appointments to anon;
grant update on public.appointments to anon;
grant delete on public.appointments to anon;
grant insert on public.favorites to anon;
grant delete on public.favorites to anon;

-- ============================================
-- STEP 12: Update appointments table comment
-- ============================================
comment on table public.appointments is 'Occupied time blocks - NOT pre-generated slots. Slots are computed dynamically from doctor_schedule.';

-- ============================================
-- STEP 13: Analyze tables
-- ============================================
analyze public.doctor_schedule;
analyze public.appointments;
analyze public.patients;