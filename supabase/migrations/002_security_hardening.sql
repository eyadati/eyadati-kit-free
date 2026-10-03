-- Phase 6: Security Hardening
-- Adds security constraints and input validation functions

-- ============================================
-- SECURITY FUNCTIONS
-- ============================================

-- Function to validate appointment date is not in the past
create or replace function public.validate_appointment_date(p_scheduled_at timestamptz)
returns boolean as $$
begin
  if p_scheduled_at < now() then
    return false;
  end if;
  if p_scheduled_at < now() + interval '30 minutes' then
    return false;
  end if;
  return true;
end;
$$ language plpgsql security definer;

-- Function to validate duration is within acceptable range
create or replace function public.validate_duration(p_duration integer)
returns boolean as $$
begin
  if p_duration < 5 then
    return false;
  end if;
  if p_duration > 180 then
    return false;
  end if;
  return true;
end;
$$ language plpgsql security definer;

-- Function to validate working hours
create or replace function public.validate_working_hours(
  p_opening_at integer,
  p_closing_at integer
)
returns boolean as $$
begin
  if p_opening_at < 0 or p_opening_at > 23 then
    return false;
  end if;
  if p_closing_at < 0 or p_closing_at > 23 then
    return false;
  end if;
  if p_opening_at >= p_closing_at then
    return false;
  end if;
  return true;
end;
$$ language plpgsql security definer;

-- Function to validate user can only access their own data
create or replace function public.validate_user_access(
  p_user_id uuid,
  p_owner_id uuid
)
returns boolean as $$
begin
  return p_user_id = p_owner_id;
end;
$$ language plpgsql security definer;

-- Function to validate doctor can only modify their own appointments
create or replace function public.validate_doctor_appointment_access(
  p_user_id uuid,
  p_doctor_id uuid,
  p_status text
)
returns boolean as $$
begin
  if p_status != 'upcoming' then
    return false;
  end if;
  return p_user_id = p_doctor_id;
end;
$$ language plpgsql security definer;

-- Function to validate manual appointment creation
create or replace function public.validate_manual_appointment(
  p_user_id uuid,
  p_doctor_id uuid,
  p_booking_type text
)
returns boolean as $$
begin
  if p_booking_type = 'manual' then
    return p_user_id = p_doctor_id;
  end if;
  return true;
end;
$$ language plpgsql security definer;

-- ============================================
-- UPDATED BOOK APPOINTMENT FUNCTION
-- ============================================
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
  v_doctor_active boolean;
  v_valid_date boolean;
  v_valid_duration boolean;
begin
  -- Validate appointment date
  select public.validate_appointment_date(p_scheduled_at) into v_valid_date;
  if not v_valid_date then
    raise exception 'Invalid appointment date. Must be at least 30 minutes in the future.';
  end if;

  -- Validate duration
  select public.validate_duration(p_duration) into v_valid_duration;
  if not v_valid_duration then
    raise exception 'Invalid duration. Must be between 5 and 180 minutes.';
  end if;

  -- Validate patient name is not empty
  if p_patient_name is null or length(trim(p_patient_name)) = 0 then
    raise exception 'Patient name is required';
  end if;

  -- Check if doctor is active
  select public.check_doctor_availability(p_doctor_id) into v_doctor_active;
  if not v_doctor_active then
    raise exception 'Doctor is not available for booking';
  end if;

  -- Check if slot is available
  select public.check_slot_availability(p_doctor_id, p_scheduled_at, p_duration) into v_available;
  if not v_available then
    raise exception 'This time slot is not available';
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
    patient_name_snapshot,
    patient_phone_snapshot,
    notes
  ) values (
    p_doctor_id,
    p_patient_id,
    p_scheduled_at,
    p_duration,
    'upcoming',
    'online',
    p_is_consultation,
    trim(p_patient_name),
    trim(p_patient_phone),
    trim(coalesce(p_notes, ''))
  )
  returning id into v_appointment_id;

  return v_appointment_id;
end;
$$ language plpgsql security definer;

-- ============================================
-- UPDATED MANUAL APPOINTMENT FUNCTION
-- ============================================
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
  v_valid_date boolean;
  v_valid_duration boolean;
  v_user_id uuid;
begin
  -- Get current user
  v_user_id := auth.uid();

  -- Validate user is the doctor
  if v_user_id != p_doctor_id then
    raise exception 'Only the doctor can create manual appointments';
  end if;

  -- Validate appointment date
  select public.validate_appointment_date(p_scheduled_at) into v_valid_date;
  if not v_valid_date then
    raise exception 'Invalid appointment date';
  end if;

  -- Validate duration
  select public.validate_duration(p_duration) into v_valid_duration;
  if not v_valid_duration then
    raise exception 'Invalid duration';
  end if;

  -- Validate patient name
  if p_patient_name is null or length(trim(p_patient_name)) = 0 then
    raise exception 'Patient name is required';
  end if;

  -- Check if slot is available
  select public.check_slot_availability(p_doctor_id, p_scheduled_at, p_duration) into v_available;
  if not v_available then
    raise exception 'This time slot is not available';
  end if;

  -- Create the appointment
  insert into public.appointments (
    doctor_id,
    scheduled_at,
    duration,
    status,
    booking_type,
    is_consultation,
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
    trim(p_patient_name),
    trim(p_patient_phone),
    trim(coalesce(p_notes, ''))
  )
  returning id into v_appointment_id;

  return v_appointment_id;
end;
$$ language plpgsql security definer;

-- ============================================
-- ENHANCED RLS POLICIES
-- ============================================

-- Drop existing appointment policies
drop policy if exists "Patients can create own appointments" on public.appointments;
drop policy if exists "Patients can cancel own appointments" on public.appointments;

-- New stricter appointment policies
create policy "Patients can create online appointments"
  on public.appointments for insert
  with check (
    auth.uid() = patient_id
    and booking_type = 'online'
    and status = 'upcoming'
  );

create policy "Patients can cancel own upcoming appointments"
  on public.appointments for update
  using (
    auth.uid() = patient_id
    and status = 'upcoming'
  );

create policy "Doctors can delete own appointments"
  on public.appointments for delete
  using (auth.uid() = doctor_id);

-- Grant execute on new functions
grant execute on function public.validate_appointment_date(timestamptz) to anon;
grant execute on function public.validate_duration(integer) to anon;
grant execute on function public.validate_working_hours(integer, integer) to anon;
grant execute on function public.validate_user_access(uuid, uuid) to anon;
grant execute on function public.validate_doctor_appointment_access(uuid, uuid, text) to anon;
grant execute on function public.validate_manual_appointment(uuid, uuid, text) to anon;
grant execute on function public.book_appointment(uuid, uuid, timestamptz, integer, text, text, boolean, text) to anon;
grant execute on function public.create_manual_appointment(uuid, timestamptz, integer, text, text, text) to anon;