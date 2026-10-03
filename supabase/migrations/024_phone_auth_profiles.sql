-- Migration: Update handle_new_user trigger for phone auth
-- Phone auth via signInWithOtp + verifyOtp creates users with empty
-- raw_user_meta_data. This updated trigger upserts instead of inserts,
-- so when Flutter later calls updateUser(data: {full_name, role, phone})
-- followed by upsert into profiles, the row is properly populated.

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, email, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    new.email,
    coalesce(new.raw_user_meta_data->>'phone', ''),
    coalesce(new.raw_user_meta_data->>'role', 'patient')
  )
  on conflict (id) do update set
    full_name = coalesce(
      new.raw_user_meta_data->>'full_name',
      profiles.full_name
    ),
    email = coalesce(new.email, profiles.email),
    phone = coalesce(
      new.raw_user_meta_data->>'phone',
      profiles.phone
    ),
    role = coalesce(
      new.raw_user_meta_data->>'role',
      profiles.role
    );
  return new;
end;
$$ language plpgsql security definer;