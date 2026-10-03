

alter table public.appointments drop column if exists fcm_reminder_sent;
alter table public.appointments drop column if exists fcm_reminder_scheduled_at;

drop index if exists idx_appointments_fcm_reminder;