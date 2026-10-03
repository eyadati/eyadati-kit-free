-- Enforce minimum appointment_duration of 20 minutes at DB level
alter table public.doctors
  add constraint appointment_duration_min_check
  check (appointment_duration >= 20);