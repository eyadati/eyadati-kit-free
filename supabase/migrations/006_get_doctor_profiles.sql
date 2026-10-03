drop function if exists public.get_doctor_profiles(uuid[]);

create or replace function public.get_doctor_profiles(doctor_ids uuid[])
returns table(
  id uuid,
  full_name text,
  avatar_url text,
  phone text
)
language sql
security definer
set search_path = public
stable
as $$
  select p.id, p.full_name, p.avatar_url, p.phone
  from public.profiles p
  where p.id = any(doctor_ids);
$$;