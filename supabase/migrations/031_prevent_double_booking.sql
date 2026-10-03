-- Prevent double-booking: exclusion constraint on overlapping appointments per doctor
-- Only active 'upcoming' appointments are checked (cancelled/completed/absent are allowed to overlap)

-- ============================================
-- 1. Install btree_gist extension
-- ============================================
create extension if not exists "btree_gist";

-- ============================================
-- 2. Create immutable helper function for the exclusion constraint
--    (tstzrange is not IMMUTABLE in all PG versions, but a wrapper fn is)
-- ============================================
create or replace function appointments_time_range(scheduled_at timestamptz, duration int)
returns tstzrange
language sql immutable
as $$
  select tstzrange(scheduled_at, scheduled_at + (duration || ' minutes')::interval, '[)');
$$;

-- ============================================
-- 3. Clean up existing overlapping appointments
-- ============================================
do $$
declare
  rec record;
  conflict_count int := 0;
begin
  for rec in
    with overlapping as (
      select
        a1.id as id1,
        a2.id as id2,
        a1.doctor_id,
        a1.scheduled_at as start1,
        a2.scheduled_at as start2,
        a1.created_at as created1,
        a2.created_at as created2
      from public.appointments a1
      join public.appointments a2
        on a1.doctor_id = a2.doctor_id
       and a1.id <> a2.id
       and a1.status = 'upcoming'
       and a2.status = 'upcoming'
       and appointments_time_range(a1.scheduled_at, a1.duration) &&
           appointments_time_range(a2.scheduled_at, a2.duration)
    )
    select distinct on (least(id1::text, id2::text) || greatest(id1::text, id2::text))
      case when created1 > created2 then id1 else id2 end as to_cancel
    from overlapping
    order by least(id1::text, id2::text) || greatest(id1::text, id2::text)
  loop
    update public.appointments
      set status = 'cancelled'
      where id = rec.to_cancel;
    conflict_count := conflict_count + 1;
  end loop;

  raise notice 'Cancelled % overlapping appointment(s) to prepare for exclusion constraint', conflict_count;
end $$;

-- ============================================
-- 4. Add exclusion constraint
-- ============================================
alter table public.appointments
  add constraint appointments_no_overlap
  exclude using gist (
    doctor_id with =,
    appointments_time_range(scheduled_at, duration) with &&
  ) where (status = 'upcoming');