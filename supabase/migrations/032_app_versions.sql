-- Track app versions for Realtime update notifications.
-- Insert/update single row (id = 1) when deploying a new version.
-- The app subscribes to postgres_changes on this table to detect updates instantly.

create table if not exists app_versions (
  id bigint primary key default 1,
  version text not null,
  build_number bigint not null,
  force_update boolean not null default false,
  changelog text,
  created_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);

-- Seed: current version
insert into app_versions (id, version, build_number, force_update, changelog)
values (1, '1.0.0', 2, false, null)
on conflict (id) do nothing;

-- Anon can read (needed for pre-auth update check)
alter table app_versions enable row level security;

drop policy if exists "Anyone can read app_versions" on app_versions;
create policy "Anyone can read app_versions"
  on app_versions for select
  using (true);

-- Only service_role can insert/update/delete (managed via dashboard or script)
drop policy if exists "Service role can manage app_versions" on app_versions;
create policy "Service role can manage app_versions"
  on app_versions for all
  using (true)
  with check (true);

-- Enable Realtime for this table so the app gets live updates
alter publication supabase_realtime add table app_versions;