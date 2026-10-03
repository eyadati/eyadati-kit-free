-- Add limit of 2 upcoming appointments per patient
-- Prevents spam by rejecting bookings when patient already has 2 upcoming

create or replace function book_appointment(
  p_doctor_id uuid,
  p_scheduled_at timestamptz,
  p_duration int,
  p_patient_name_snapshot text,
  p_patient_phone_snapshot text default null,
  p_is_consultation boolean default false,
  p_notes text default null
) returns jsonb
language plpgsql
security definer
as $$
declare
  v_patient_id uuid;
  v_appointment_id uuid;
  v_reminder_at timestamptz;
  v_delta interval;
  v_overlap boolean;
begin
  v_patient_id := auth.uid();
  if v_patient_id is null then
    return jsonb_build_object('error', 'not_authenticated');
  end if;

  if p_doctor_id is null then
    return jsonb_build_object('error', 'invalid_doctor');
  end if;

  if p_scheduled_at <= now() then
    return jsonb_build_object('error', 'invalid_appointment_date');
  end if;

  if p_duration < 5 or p_duration > 180 then
    return jsonb_build_object('error', 'invalid_duration');
  end if;

  if p_patient_name_snapshot is null or trim(p_patient_name_snapshot) = '' then
    return jsonb_build_object('error', 'invalid_patient_name');
  end if;

  -- Limit patient to 2 upcoming appointments at a time
  if (select count(*) from appointments
      where patient_id = v_patient_id
        and status = 'upcoming'
        and scheduled_at > now()) >= 2 then
    return jsonb_build_object('error', 'max_appointments_reached');
  end if;

  perform pg_advisory_xact_lock(hashtext('book_appt_' || p_doctor_id::text)::bigint);

  select exists(
    select 1
    from appointments
    where doctor_id = p_doctor_id
      and status = 'upcoming'
      and appointments_time_range(scheduled_at, duration) &&
          appointments_time_range(p_scheduled_at, p_duration)
  ) into v_overlap;

  if v_overlap then
    return jsonb_build_object('error', 'slot_unavailable');
  end if;

  v_delta := p_scheduled_at - now();
  if v_delta > interval '6 hours' then
    v_reminder_at := p_scheduled_at - interval '6 hours';
  elsif v_delta > interval '2 hours' then
    v_reminder_at := p_scheduled_at - interval '2 hours';
  else
    v_reminder_at := null;
  end if;

  insert into appointments (
    doctor_id, patient_id, scheduled_at, duration, status,
    booking_type, is_consultation, patient_name_snapshot,
    patient_phone_snapshot, notes, reminder_at
  ) values (
    p_doctor_id, v_patient_id, p_scheduled_at, p_duration, 'upcoming',
    'online', p_is_consultation, p_patient_name_snapshot,
    p_patient_phone_snapshot, p_notes, v_reminder_at
  )
  returning id into v_appointment_id;

  return jsonb_build_object('id', v_appointment_id::text);
end;
$$;