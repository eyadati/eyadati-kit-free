-- Enable Realtime for tables used by onPostgresChanges subscriptions
-- Without this, all realtime callbacks silently fail.

do $$
begin
  alter publication supabase_realtime add table public.appointments;
  alter publication supabase_realtime add table public.doctor_schedule;
  alter publication supabase_realtime add table public.doctors;
exception
  when duplicate_object then null;
end $$;