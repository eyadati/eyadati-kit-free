-- Eyadati: Add is_test column for test doctor profiles
-- Test doctors are hidden from patients and cannot be booked

-- Add column
alter table public.doctors
  add column if not exists is_test boolean not null default false;

-- Update RLS: hide test doctors from patient view
drop policy if exists "Public can view active doctors" on public.doctors;
create policy "Public can view active doctors"
  on public.doctors for select
  using (
    manual_pause = false
    and is_test = false
  );

-- Update RLS: hide test doctor schedules from patients
drop policy if exists "Public can view active doctor schedules" on public.doctor_schedule;
create policy "Public can view active doctor schedules"
  on public.doctor_schedule for select
  using (
    exists (
      select 1 from public.doctors d
      where d.id = doctor_schedule.doctor_id
        and d.manual_pause = false
        and d.is_test = false
    )
    and is_active = true
  );

-- Update check_doctor_availability: prevent booking test doctors
create or replace function public.check_doctor_availability(doctor_uuid uuid)
returns boolean as $$
declare
  doctor_record record;
begin
  select into doctor_record
    manual_pause,
    is_test
  from public.doctors
  where id = doctor_uuid;

  if not found then
    return false;
  end if;

  if doctor_record.manual_pause = true then
    return false;
  end if;

  if doctor_record.is_test = true then
    return false;
  end if;


  return true;
end;
$$ language plpgsql security definer;