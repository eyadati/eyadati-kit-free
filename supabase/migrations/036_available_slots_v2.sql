-- Phase: Server-side slot generation with no overlapping windows
-- Replaces client-side AvailabilityService with a security definer RPC
-- that sees ALL appointments and generates non-overlapping slot windows.
-- Each slot's duration equals its step size, so no two bookable slots overlap.

create or replace function get_available_slots_v2(
  p_doctor_id uuid,
  p_date date,
  p_duration int default 20
) returns table (
  slot_start_minute int,
  slot_end_minute int,
  slot_duration int
) language plpgsql security definer
as $$
declare
  v_tz text := 'Africa/Algiers';
  v_day_of_week int;
  v_start_time int;
  v_end_time int;
  v_break_start int;
  v_break_end int;
  v_free_start int;
  v_m int;
  v_now timestamptz := now();
  v_cutoff int;
  v_rec record;
begin
  v_day_of_week := extract(dow from p_date)::int;

  select start_time, end_time, break_start, break_end
  into v_start_time, v_end_time, v_break_start, v_break_end
  from doctor_schedule
  where doctor_id = p_doctor_id
    and day_of_week = v_day_of_week
    and is_active = true;

  if v_start_time is null then
    return;
  end if;

  if p_date = v_now::date then
    v_cutoff := extract(hour from v_now at time zone v_tz) * 60 +
                extract(minute from v_now at time zone v_tz) + 30;
  else
    v_cutoff := -1;
  end if;

  v_free_start := v_start_time;

  for v_rec in (
    select start_min, end_min from (
      select
        (extract(hour from scheduled_at at time zone v_tz) * 60 +
         extract(minute from scheduled_at at time zone v_tz))::int as start_min,
        (extract(hour from (scheduled_at + (duration || ' minutes')::interval) at time zone v_tz) * 60 +
         extract(minute from (scheduled_at + (duration || ' minutes')::interval) at time zone v_tz))::int as end_min
      from appointments
      where doctor_id = p_doctor_id
        and status = 'upcoming'
        and scheduled_at >= (p_date at time zone v_tz)
        and scheduled_at < (p_date at time zone v_tz) + interval '1 day'

      union all

      select break_start, break_end
      from doctor_schedule
      where doctor_id = p_doctor_id
        and day_of_week = v_day_of_week
        and is_active = true
        and break_start is not null
        and break_end is not null
    ) x
    where end_min > start_min
    order by start_min
  ) loop
    if v_rec.start_min > v_free_start then
      v_m := v_free_start;
      while v_m + p_duration <= least(v_rec.start_min, v_end_time) loop
        if v_m >= v_cutoff then
          slot_start_minute := v_m;
          slot_end_minute := v_m + p_duration;
          slot_duration := p_duration;
          return next;
        end if;
        v_m := v_m + p_duration;
      end loop;
    end if;

    if v_rec.end_min > v_free_start then
      v_free_start := v_rec.end_min;
    end if;

    if v_free_start >= v_end_time then
      return;
    end if;
  end loop;

  if v_free_start < v_end_time then
    v_m := v_free_start;
    while v_m + p_duration <= v_end_time loop
      if v_m >= v_cutoff then
        slot_start_minute := v_m;
        slot_end_minute := v_m + p_duration;
        slot_duration := p_duration;
        return next;
      end if;
      v_m := v_m + p_duration;
    end loop;
  end if;
end;
$$;

grant execute on function get_available_slots_v2(uuid, date, int) to anon;