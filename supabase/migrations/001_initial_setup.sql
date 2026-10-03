-- Eyadati Database Setup (Reset & Create)
-- This migration drops existing tables and creates fresh ones

-- Drop existing tables and functions if they exist (for clean setup)
drop table if exists public.doctor_schedule cascade;
drop table if exists public.favorites cascade;
drop table if exists public.appointments cascade;
drop table if exists public.doctors cascade;
drop table if exists public.profiles cascade;

drop function if exists public.handle_new_user cascade;
drop function if exists public.update_updated_at cascade;
drop function if exists public.check_doctor_availability cascade;
drop function if exists public.check_slot_availability cascade;
drop function if exists public.book_appointment cascade;

drop function if exists public.check_doctor_availability cascade;
drop function if exists public.check_slot_availability cascade;
drop function if exists public.book_appointment cascade;

-- Enable pgcrypto extension for UUID generation
create extension if not exists "pgcrypto";

-- ============================================
-- PROFILES TABLE
-- Stores all authenticated users
-- ============================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('patient', 'doctor')),
  full_name text not null,
  email text,
  phone text,
  city text,
  avatar_url text,
  created_at timestamptz default now()
);

-- Index for role-based queries
create index idx_profiles_role on public.profiles(role);

-- Enable RLS
alter table public.profiles enable row level security;

-- RLS Policies for profiles
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ============================================
-- DOCTORS TABLE
-- Stores doctor-specific public/business information
-- ============================================
create table public.doctors (
  id uuid primary key references public.profiles(id) on delete cascade,

  specialty text not null,
  address text not null,
  city text,
  maps_link text,

  latitude double precision,
  longitude double precision,

  bio text,
  photo_url text,

  appointment_duration integer not null default 20,
  consultation_duration integer not null default 40,

  opening_at time not null default '09:00:00',
  closing_at time not null default '17:00:00',

  break_start integer,
  break_end integer,

  working_days text[] not null default ARRAY['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'],

  manual_pause boolean default false,

  created_at timestamptz default now()
);

-- Indexes for doctor queries
create index idx_doctors_specialty on public.doctors(specialty);
create index idx_doctors_city on public.doctors(city);
create index idx_doctors_pause on public.doctors(manual_pause);

-- Enable RLS
alter table public.doctors enable row level security;

-- RLS Policies for doctors
create policy "Public can view active doctors"
  on public.doctors for select
  using (
    manual_pause = false
  );

create policy "Doctors can view own doctor profile"
  on public.doctors for select
  using (auth.uid() = id);

create policy "Doctors can update own doctor profile"
  on public.doctors for update
  using (auth.uid() = id);

create policy "Doctors can insert own doctor profile"
  on public.doctors for insert
  with check (auth.uid() = id);

-- ============================================
-- DOCTOR SCHEDULE TABLE
-- Stores specific availability slots for doctors
-- ============================================
create table public.doctor_schedule (
  id uuid primary key default gen_random_uuid(),
  
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  
  day_of_week integer not null check (day_of_week between 0 and 6),
  -- 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  
  start_time time not null,
  end_time time not null,
  
  is_active boolean default true,
  
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  
  constraint valid_time_range check (end_time > start_time)
);

-- Indexes for schedule queries
create index idx_schedule_doctor on public.doctor_schedule(doctor_id);
create index idx_schedule_day on public.doctor_schedule(doctor_id, day_of_week);
create index idx_schedule_active on public.doctor_schedule(is_active) where is_active = true;

-- Enable RLS
alter table public.doctor_schedule enable row level security;

-- RLS Policies for doctor_schedule
create policy "Public can view active doctor schedules"
  on public.doctor_schedule for select
  using (
    exists (
      select 1 from public.doctors d
      where d.id = doctor_schedule.doctor_id
        and d.manual_pause = false
    )
    and is_active = true
  );

create policy "Doctors can view own schedules"
  on public.doctor_schedule for select
  using (auth.uid() = doctor_id);

create policy "Doctors can insert own schedules"
  on public.doctor_schedule for insert
  with check (auth.uid() = doctor_id);

create policy "Doctors can update own schedules"
  on public.doctor_schedule for update
  using (auth.uid() = doctor_id);

create policy "Doctors can delete own schedules"
  on public.doctor_schedule for delete
  using (auth.uid() = doctor_id);

-- ============================================
-- APPOINTMENTS TABLE
-- Stores both online and manual appointments
-- ============================================
create table public.appointments (
  id uuid primary key default gen_random_uuid(),

  doctor_id uuid not null references public.doctors(id) on delete cascade,
  patient_id uuid references public.profiles(id) on delete set null,

  scheduled_at timestamptz not null,
  duration integer not null,

  status text not null check (
    status in ('upcoming', 'completed', 'cancelled', 'absent')
  ),

  booking_type text not null check (
    booking_type in ('online', 'manual')
  ),

  is_consultation boolean default false,

  patient_name_snapshot text not null,
  patient_phone_snapshot text,

  notes text,

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Indexes for appointment queries
create index idx_appointments_doctor on public.appointments(doctor_id);
create index idx_appointments_patient on public.appointments(patient_id);
create index idx_appointments_date on public.appointments(scheduled_at);
create index idx_appointments_status on public.appointments(status);
create index idx_appointments_doctor_date on public.appointments(doctor_id, scheduled_at);

-- Enable RLS
alter table public.appointments enable row level security;

-- RLS Policies for appointments
create policy "Patients can view own appointments"
  on public.appointments for select
  using (auth.uid() = patient_id);

create policy "Patients can create own appointments"
  on public.appointments for insert
  with check (
    auth.uid() = patient_id
    and booking_type = 'online'
  );

create policy "Patients can cancel own appointments"
  on public.appointments for update
  using (
    auth.uid() = patient_id
    and status = 'upcoming'
  );

create policy "Doctors can view own appointments"
  on public.appointments for select
  using (auth.uid() = doctor_id);

create policy "Doctors can update own appointments"
  on public.appointments for update
  using (auth.uid() = doctor_id);

create policy "Doctors can create manual appointments"
  on public.appointments for insert
  with check (
    auth.uid() = doctor_id
    and booking_type = 'manual'
  );

-- ============================================
-- FAVORITES TABLE
-- Stores patient favorite doctors
-- ============================================
create table public.favorites (
  patient_id uuid not null references public.profiles(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete cascade,
  created_at timestamptz default now(),

  primary key (patient_id, doctor_id)
);

-- Indexes for favorites queries
create index idx_favorites_patient on public.favorites(patient_id);
create index idx_favorites_doctor on public.favorites(doctor_id);

-- Enable RLS
alter table public.favorites enable row level security;

-- RLS Policies for favorites
create policy "Patients can view own favorites"
  on public.favorites for select
  using (auth.uid() = patient_id);

create policy "Patients can add favorites"
  on public.favorites for insert
  with check (auth.uid() = patient_id);

create policy "Patients can remove favorites"
  on public.favorites for delete
  using (auth.uid() = patient_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function: Handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email,
    coalesce(new.raw_user_meta_data->>'role', 'patient')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to create profile on auth signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Function: Update updated_at timestamp
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Trigger for appointments updated_at
drop trigger if exists appointments_updated_at on public.appointments;
create trigger appointments_updated_at
  before update on public.appointments
  for each row execute procedure public.update_updated_at();

-- Trigger for doctor_schedule updated_at
drop trigger if exists doctor_schedule_updated_at on public.doctor_schedule;
create trigger doctor_schedule_updated_at
  before update on public.doctor_schedule
  for each row execute procedure public.update_updated_at();

-- Function: Check doctor availability
create or replace function public.check_doctor_availability(doctor_uuid uuid)
returns boolean as $$
declare
  doctor_record record;
begin
  select into doctor_record
    manual_pause,
  from public.doctors
  where id = doctor_uuid;

  if not found then
    return false;
  end if;

  if doctor_record.manual_pause = true then
    return false;
  end if;


  return true;
end;
$$ language plpgsql security definer;

-- Function: Check slot availability (based on schedule)
create or replace function public.check_schedule_slot_availability(
  doctor_uuid uuid,
  slot_time timestamptz,
  slot_duration integer
)
returns boolean as $$
declare
  v_day_of_week integer;
  v_slot_time time;
  v_has_schedule boolean;
  v_conflict_count integer;
begin
  -- Get the day of week (0=Sunday, 6=Saturday)
  v_day_of_week := extract(dow from slot_time at time zone 'UTC')::integer;
  v_slot_time := (slot_time at time zone 'UTC')::time;
  
  -- Check if doctor has an active schedule slot for this day and time
  select exists (
    select 1 from public.doctor_schedule ds
    where ds.doctor_id = doctor_uuid
      and ds.day_of_week = v_day_of_week
      and ds.is_active = true
      and ds.start_time <= v_slot_time
      and ds.end_time >= v_slot_time + (slot_duration || ' minutes')::interval
  ) into v_has_schedule;
  
  if not v_has_schedule then
    return false;
  end if;
  
  -- Check for appointment conflicts
  select count(*) into v_conflict_count
  from public.appointments a
  where a.doctor_id = doctor_uuid
    and a.status = 'upcoming'
    and (
      (a.scheduled_at, a.scheduled_at + (a.duration || ' minutes')::interval)
      overlaps
      (slot_time, slot_time + (slot_duration || ' minutes')::interval)
    );
  
  return v_conflict_count = 0;
end;
$$ language plpgsql security definer;

-- Function: Book appointment with validation (updated)
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
begin
  select public.check_doctor_availability(p_doctor_id) into v_doctor_active;
  if not v_doctor_active then
    raise exception 'Doctor is not available for booking';
  end if;

  select public.check_schedule_slot_availability(p_doctor_id, p_scheduled_at, p_duration) into v_available;
  if not v_available then
    raise exception 'This time slot is not available or doctor has no schedule for this time';
  end if;

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
    p_patient_name,
    p_patient_phone,
    p_notes
  )
  returning id into v_appointment_id;

  return v_appointment_id;
end;
$$ language plpgsql security definer;

-- Grant permissions
grant usage on schema public to anon;
grant execute on all functions in schema public to anon;
grant select on all tables in schema public to anon;
grant insert on public.appointments to anon;
grant update on public.appointments to anon;
grant delete on public.appointments to anon;
grant insert on public.favorites to anon;
grant delete on public.favorites to anon;