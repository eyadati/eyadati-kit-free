-- Phase 7: Performance Optimization
-- Adds composite indexes, optimized functions, and query improvements

-- ============================================
-- OPTIMIZED INDEXES
-- ============================================

-- Drop existing single-column indexes that will be replaced
drop index if exists idx_appointments_doctor;
drop index if exists idx_appointments_patient;

-- Create composite indexes for common query patterns
-- Appointments: doctor + date for schedule view
create index if not exists idx_appointments_doctor_date_status
  on public.appointments(doctor_id, scheduled_at, status)
  where status = 'upcoming';

-- Appointments: patient + date for patient history
create index if not exists idx_appointments_patient_date
  on public.appointments(patient_id, scheduled_at desc);

-- Appointments: status + date for dashboard queries
create index if not exists idx_appointments_status_date
  on public.appointments(status, scheduled_at);

-- Doctors: composite index for public browsing (most common query)
create index if not exists idx_doctors_visibility
  on public.doctors(manual_pause, created_at desc)
  where manual_pause = false;

-- Doctors: specialty + city for filtered searches
create index if not exists idx_doctors_specialty_city
  on public.doctors(specialty, city);

-- Favorites: patient for quick lookup
create index if not exists idx_favorites_patient_created
  on public.favorites(patient_id, created_at desc);

-- ============================================
-- OPTIMIZED FUNCTIONS
-- ============================================

-- Optimized slot generation function with LIMIT
create or replace function public.get_available_slots(
  p_doctor_id uuid,
  p_date date,
  p_duration integer default 20,
  p_limit integer default 50
)
returns table (
  slot_start timestamptz,
  slot_end timestamptz,
  slot_duration integer
) as $$
declare
  v_doctor record;
  v_day_name text;
  v_slot_start integer;
  v_slot_end integer;
  v_break_start integer;
  v_break_end integer;
  v_working_days text[];
  v_count integer := 0;
  v_hour integer;
  v_minute integer;
begin
  -- Get doctor info
  select into v_doctor
    opening_at, closing_at, break_start, break_end, working_days
  from public.doctors
  where id = p_doctor_id
    and manual_pause = false
;

  if not found then
    return;
  end if;

  -- Check if doctor works on this day
  v_day_name := lower(to_char(p_date, 'Day'));
  v_day_name := trim(v_day_name);
  
  if not (v_doctor.working_days @> array[v_day_name]) then
    return;
  end if;

  v_slot_start := v_doctor.opening_at;
  v_slot_end := v_doctor.closing_at;
  v_break_start := v_doctor.break_start;
  v_break_end := v_doctor.break_end;

  -- Generate slots
  v_hour := v_slot_start;
  while v_hour < v_slot_end loop
    v_minute := 0;
    while v_minute < 60 loop
      -- Skip if exceeded limit
      if v_count >= p_limit then
        return;
      end if;

      declare
        v_start_time timestamptz;
        v_end_time timestamptz;
        v_slot_start_minutes integer;
        v_is_break boolean := false;
        v_is_booked boolean := false;
      begin
        v_start_time := p_date + (v_slot_start || ' hours')::interval + (v_minute || ' minutes')::interval;
        v_end_time := v_start_time + (p_duration || ' minutes')::interval;
        v_slot_start_minutes := v_hour * 60 + v_minute;

        -- Check if in break time
        if v_break_start is not null and v_break_end is not null then
          if v_slot_start_minutes >= v_break_start * 60 
             and v_slot_start_minutes < v_break_end * 60 then
            v_is_break := true;
          end if;
        end if;

        -- Check if slot is in the past
        if v_start_time <= now() then
          v_is_break := true;
        end if;

        -- Check if slot is booked
        if not v_is_break then
          select into v_is_booked
            exists (
              select 1 from public.appointments
              where doctor_id = p_doctor_id
                and status = 'upcoming'
                and scheduled_at < v_end_time
                and scheduled_at + (duration || ' minutes')::interval > v_start_time
            );
        end if;

        -- Return slot if available
        if not v_is_break and not v_is_booked then
          slot_start := v_start_time;
          slot_end := v_end_time;
          slot_duration := p_duration;
          return next;
          v_count := v_count + 1;
        end if;
      end;

      v_minute := v_minute + p_duration;
    end loop;
    v_hour := v_hour + 1;
  end loop;
end;
$$ language plpgsql;

-- Optimized count function for pagination
create or replace function public.count_doctors(
  p_specialty text default null,
  p_city text default null
)
returns integer as $$
declare
  v_count integer;
begin
  select into v_count count(*)
  from public.doctors
  where manual_pause = false
    and (p_specialty is null or specialty ilike '%' || p_specialty || '%')
    and (p_city is null or city ilike '%' || p_city || '%');

  return coalesce(v_count, 0);
end;
$$ language plpgsql;

-- Optimized count function for appointments
create or replace function public.count_appointments(
  p_user_id uuid,
  p_role text default 'patient',
  p_status text default null
)
returns integer as $$
declare
  v_count integer;
begin
  if p_role = 'doctor' then
    select into v_count count(*)
    from public.appointments
    where doctor_id = p_user_id
      and (p_status is null or status = p_status);
  else
    select into v_count count(*)
    from public.appointments
    where patient_id = p_user_id
      and (p_status is null or status = p_status);
  end if;

  return coalesce(v_count, 0);
end;
$$ language plpgsql;

-- ============================================
-- GRANT EXECUTE ON NEW FUNCTIONS
-- ============================================
grant execute on function public.get_available_slots(uuid, date, integer, integer) to anon;
grant execute on function public.count_doctors(text, text) to anon;
grant execute on function public.count_appointments(uuid, text, text) to anon;

-- ============================================
-- ANALYZE TABLES FOR QUERY PLANNER
-- ============================================
analyze public.profiles;
analyze public.doctors;
analyze public.appointments;
analyze public.favorites;