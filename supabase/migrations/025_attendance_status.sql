-- Migration: Add attendance_status for post-appointment tracking
-- Enables doctors to mark: present, cancelled_with_notice, no_show

alter table public.appointments
add column attendance_status text
check (attendance_status in ('present', 'cancelled_with_notice', 'no_show'));

-- Index for no-show counting
create index idx_appointments_attendance on public.appointments(doctor_id, attendance_status);

-- Update existing completed → present, absent → no_show
update public.appointments set attendance_status = 'present' where status = 'completed';
update public.appointments set attendance_status = 'no_show' where status = 'absent';