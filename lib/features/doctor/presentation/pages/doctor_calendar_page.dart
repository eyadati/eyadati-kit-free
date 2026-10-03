import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:eyadati_kit/core/constants/app_colors.dart';
import 'package:eyadati_kit/core/constants/app_breakpoints.dart';
import 'package:eyadati_kit/core/theme/text_styles.dart';
import 'package:eyadati_kit/core/routing/route_names.dart';
import 'package:eyadati_kit/core/utils/phone_launcher.dart';
import 'package:eyadati_kit/models/appointment_data.dart';
import 'package:eyadati_kit/models/schedule_slot_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/doctor_provider.dart';
import '../widgets/doctor_add_appointment_dialog.dart';
import '../widgets/appointment_details_sheet.dart';
import '../widgets/doctor_day_list_view.dart';
import '../widgets/doctor_week_strip.dart';

class DoctorCalendarPage extends ConsumerStatefulWidget {
  final VoidCallback? onBellPressed;
  final ValueNotifier<DateTime> selectedDateNotifier;

  DoctorCalendarPage({
    super.key,
    this.onBellPressed,
    ValueNotifier<DateTime>? selectedDateNotifier,
  }) : selectedDateNotifier = selectedDateNotifier ?? ValueNotifier(DateTime.now());

  @override
  ConsumerState<DoctorCalendarPage> createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends ConsumerState<DoctorCalendarPage>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  final CalendarController _calendarController = CalendarController();
  final _CalendarDataSource _dataSource = _CalendarDataSource([]);

  bool _isExpanded = true;

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _syncSelectedDate() {
    widget.selectedDateNotifier.value = _focusedDay;
  }

  @override
  void initState() {
    super.initState();
    _syncSelectedDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(doctorProvider);
      _updateDataSource(state);
      ref.listenManual(doctorProvider, (_, next) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _updateDataSource(next);
        });
      });
    });
  }

  (int startHour, int endHour) _getVisibleHours(DoctorState state) {
    if (state.scheduleSlots.isEmpty) return (8, 20);
    int earliest = 24;
    int latest = 0;
    for (final slot in state.scheduleSlots) {
      if (!slot.isActive) continue;
      if (slot.startTime < earliest) earliest = slot.startTime;
      if (slot.endTime > latest) latest = slot.endTime;
    }
    if (earliest == 24) return (8, 20);
    final start = earliest ~/ 60;
    final end = (latest / 60).ceil();
    final minRange = 6;
    int adjustedEnd = end;
    if (end - start < minRange) {
      adjustedEnd = start + minRange;
    }
    return (start.clamp(6, 22), adjustedEnd.clamp(start + 1, 23));
  }

  double _getTimeIntervalHeight(double screenWidth) {
    if (screenWidth < 600) return 70;
    if (screenWidth < 900) return 80;
    return 90;
  }

  String _formatWeekRange() {
    final months = [
      '',
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    final startOfWeek = _focusedDay.subtract(
      Duration(days: _focusedDay.weekday % 7),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    if (startOfWeek.month == endOfWeek.month) {
      return '${startOfWeek.day} - ${endOfWeek.day} ${months[startOfWeek.month]} ${startOfWeek.year}';
    } else if (startOfWeek.year == endOfWeek.year) {
      return '${startOfWeek.day} ${months[startOfWeek.month]} - ${endOfWeek.day} ${months[endOfWeek.month]} ${startOfWeek.year}';
    }
    return '${startOfWeek.day} ${months[startOfWeek.month]} ${startOfWeek.year} - ${endOfWeek.day} ${months[endOfWeek.month]} ${endOfWeek.year}';
  }

  void _previousWeeks() {
    setState(() {
      _focusedDay = _focusedDay.subtract(const Duration(days: 7));
      _syncSelectedDate();
    });
    _calendarController.displayDate = _focusedDay;
  }

  void _nextWeeks() {
    setState(() {
      _focusedDay = _focusedDay.add(const Duration(days: 7));
      _syncSelectedDate();
    });
    _calendarController.displayDate = _focusedDay;
  }

  void _updateDataSource(DoctorState doctorState) {
    final appointments = doctorState.allAppointments
        .map(
          (apt) => _AppointmentWrapper(
            id: apt.id,
            startTime: apt.startTime,
            endTime: apt.endTime,
            patientName: apt.patientName,
            status: apt.status,
            isConsultation: apt.isConsultation,
            duration: apt.duration,
            notes: apt.notes,
            patientPhone: apt.patientPhone,
            patientAvatar: apt.patientAvatar,
            patientId: apt.patientId,
            bookingType: apt.bookingType,
            doctorId: apt.doctorId,
            doctorName: apt.doctorName,
          ),
        )
        .toList();
    _dataSource.updateAppointments(appointments);
  }

  void _showAddAppointmentDialog(DateTime day, {DateTime? initialTime}) {
    showDialog(
      context: context,
      builder: (ctx) => DoctorAddAppointmentDialog(
        initialDate: day,
        initialTime: initialTime,
      ),
    );
  }

  List<TimeRegion> _buildBreakRegions(
    List<ScheduleSlot> slots,
    DateTime focusedDay,
  ) {
    final regions = <TimeRegion>[];
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday % 7),
    );

    for (final slot in slots) {
      if (!slot.hasBreak) continue;
      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        if (day.weekday % 7 != slot.dayOfWeek) continue;
        if (!day.isAfter(DateTime.now().subtract(const Duration(days: 1))))
          continue;

        final breakStart = DateTime(
          day.year,
          day.month,
          day.day,
          slot.breakStart! ~/ 60,
          slot.breakStart! % 60,
        );
        final breakEnd = DateTime(
          day.year,
          day.month,
          day.day,
          slot.breakEnd! ~/ 60,
          slot.breakEnd! % 60,
        );

        regions.add(
          TimeRegion(
            startTime: breakStart,
            endTime: breakEnd,
            color: AppColors.textHint.withValues(alpha: 0.08),
            enablePointerInteraction: false,
            text: 'Pause',
            textStyle: AppTextStyles.labelSmall,
          ),
        );
      }
    }
    return regions;
  }

  Widget _buildCardsRow(DoctorState doctorState, double screenWidth) {
    final isMobile = AppBreakpoints.isMobile(screenWidth);
    final upcomingList = doctorState.upcomingAppointmentsList;
    final nextAppointment = upcomingList.isNotEmpty ? upcomingList.first : null;

    final monthCount = doctorState.monthAppointmentsCount;
    final onlinePct = monthCount > 0
        ? (doctorState.monthOnlineCount * 100 ~/ monthCount)
        : 0;

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Ce mois',
                      '$monthCount',
                      '$onlinePct% en ligne',
                      LucideIcons.calendar,
                      AppColors.secondary,
                      isMobile: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNextAppointmentCard(nextAppointment, isMobile: true)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildStatCard(
                'Ce mois',
                '$monthCount',
                '$onlinePct% en ligne',
                LucideIcons.calendar,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildNextAppointmentCard(nextAppointment)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String? subtitle,
    IconData icon,
    Color color, {
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isMobile ? 14 : 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: (isMobile ? AppTextStyles.badge : AppTextStyles.labelSmall).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.badge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextAppointmentCard(AppointmentData? appointment, {bool isMobile = false}) {
    if (appointment == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 8 : 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.clock,
                color: AppColors.primary,
                size: isMobile ? 14 : 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '--',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Prochain RDV',
              style: (isMobile ? AppTextStyles.badge : AppTextStyles.labelSmall).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final timeStr =
        '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')}';
    final dateStr =
        '${appointment.startTime.day}/${appointment.startTime.month}';
    final typeColor = appointment.isConsultation
        ? AppColors.consultationColor
        : AppColors.primary;
    final typeLabel = appointment.isConsultation ? 'Consultation' : 'RDV';

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              typeLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: typeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appointment.patientName,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$dateStr à $timeStr',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final (startHour, endHour) = _getVisibleHours(doctorState);
    final breakRegions = _buildBreakRegions(
      doctorState.scheduleSlots,
      _focusedDay,
    );
    final isMobile = AppBreakpoints.isMobile(screenWidth);

    final pendingCount = doctorState.allAppointments
        .where((a) => a.status == 'upcoming' && a.bookingType == 'online')
        .length;

    return Column(
      children: [
        _buildTopHeader(pendingCount, doctorState.isTest),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildCardsRow(doctorState, screenWidth),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isMobile
                  ? _buildMobileDayView(doctorState)
                  : _buildTabletCalendar(
                      doctorState, startHour, endHour, breakRegions, screenWidth),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDayView(DoctorState doctorState) {
    final dayAppointments = doctorState.getAppointmentsForDay(_focusedDay);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: DoctorWeekStrip(
            selectedDate: _focusedDay,
            appointments: doctorState.allAppointments,
            onDateSelected: (date) {
      setState(() {
        _focusedDay = date;
        _syncSelectedDate();
      });
      _calendarController.displayDate = date;
            },
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(doctorProvider.notifier).refresh(),
            child: DoctorDayListView(
              selectedDate: _focusedDay,
              appointments: dayAppointments,
              startHour: _getVisibleHours(doctorState).$1,
              endHour: _getVisibleHours(doctorState).$2,
              onAppointmentTap: (apt) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (c) => AppointmentDetailsSheet(appointment: apt),
                );
              },
              onCallPatient: (apt) {
                if (AppBreakpoints.isMobile(MediaQuery.of(context).size.width)) {
                  launchUrl(Uri.parse('tel:${apt.patientPhone}'));
                }
              },
              onSmsPatient: (apt) {
                if (AppBreakpoints.isMobile(MediaQuery.of(context).size.width)) {
                  final msg = 'Bonjour ${apt.patientName}, rappel de votre rendez-vous le '
                      '${apt.startTime.day}/${apt.startTime.month} à '
                      '${apt.startTime.hour.toString().padLeft(2, '0')}:${apt.startTime.minute.toString().padLeft(2, '0')}. Merci.';
                  launchSmsUrl(apt.patientPhone!, msg, context);
                }
              },
              onEmptySlotTap: (time) {
                _showAddAppointmentDialog(_focusedDay, initialTime: time);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletCalendar(
    DoctorState doctorState,
    int startHour,
    int endHour,
    List<TimeRegion> breakRegions,
    double screenWidth,
  ) {
    return SfCalendarTheme(
      data: SfCalendarThemeData(
        backgroundColor: AppColors.white,
        todayHighlightColor: AppColors.primary,
        selectionBorderColor: AppColors.primary,
        cellBorderColor: AppColors.primary.withValues(alpha: 0.65),
        viewHeaderBackgroundColor: AppColors.white,
        timeTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textHint,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: SfCalendar(
        controller: _calendarController,
        dataSource: _dataSource,
        view: CalendarView.week,
        initialDisplayDate: _focusedDay,
        showCurrentTimeIndicator: true,
        headerHeight: 0,
        todayHighlightColor: AppColors.primary,
        specialRegions: breakRegions,
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: startHour.toDouble(),
          endHour: endHour.toDouble(),
          timeInterval: const Duration(hours: 1),
          timeIntervalHeight: _getTimeIntervalHeight(screenWidth),
          timeFormat: 'H a',
          timeRulerSize: 60,
          dayFormat: 'EEE',
          dateFormat: 'd',
        ),
        selectionDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textHint,
          ),
          dateTextStyle: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        appointmentBuilder: (context, details) {
          final apt = details.appointments.first as _AppointmentWrapper;
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (c) => AppointmentDetailsSheet(
                  appointment: AppointmentData(
                    id: apt.id,
                    startTime: apt.startTime,
                    endTime: apt.endTime,
                    patientName: apt.patientName,
                    status: apt.status,
                    isConsultation: apt.isConsultation,
                    duration: apt.duration,
                    notes: apt.notes,
                    patientPhone: apt.patientPhone,
                    patientAvatar: apt.patientAvatar,
                    patientId: apt.patientId,
                    bookingType: apt.bookingType,
                    doctorId: apt.doctorId,
                    doctorName: apt.doctorName,
                  ),
                ),
              );
            },
            child: Tooltip(
              richMessage: WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: apt.status == 'cancelled'
                        ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: apt.status == 'cancelled'
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.primaryLight,
                        child: Text(
                          apt.patientName.isNotEmpty
                              ? apt.patientName[0].toUpperCase()
                              : 'P',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: apt.status == 'cancelled'
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                apt.patientName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: apt.status == 'cancelled'
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (apt.status == 'cancelled') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Annulé',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${apt.isConsultation ? "Consultation" : "RDV"} • ${apt.startTime.hour}:${apt.startTime.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: apt.status == 'cancelled'
                                  ? AppColors.error.withValues(alpha: 0.7)
                                  : AppColors.textHint,
                            ),
                          ),
                          if (apt.patientPhone != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '📞 ${apt.patientPhone}',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              waitDuration: const Duration(milliseconds: 300),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: _buildAppointmentWidget(apt, details.bounds),
            ),
          );
        },
        onTap: (CalendarTapDetails details) {
          if (details.appointments == null || details.appointments!.isEmpty) {
            if (details.date != null) {
              showDialog(
                context: context,
                builder: (ctx) => DoctorAddAppointmentDialog(
                  initialDate: details.date!,
                ),
              );
            }
          }
        },
        onViewChanged: (details) {
          if (details.visibleDates.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _focusedDay =
                    details.visibleDates[details.visibleDates.length ~/ 2];
                _syncSelectedDate();
              });
            });
          }
        },
      ),
    );
  }

  Widget _buildTopHeader(int pendingCount, bool isTest) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Eyadati',
                style: (isMobile ? AppTextStyles.titleMedium : AppTextStyles.titleLarge).copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              if (isTest)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TEST',
                    style: AppTextStyles.badge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          if (!isMobile) const Spacer(),
          if (!isMobile)
            IconButton(
              icon: const Icon(LucideIcons.chevronLeft, size: 25),
              onPressed: _previousWeeks,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          if (!isMobile) ...[
            const SizedBox(width: 4),
            Text(
              _formatWeekRange(),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(LucideIcons.chevronRight, size: 25),
              onPressed: _nextWeeks,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          ],
          const Spacer(),
          IconButton(
            icon: Stack(
              children: [
                const Icon(LucideIcons.bell, color: AppColors.textPrimary),
                if (pendingCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: widget.onBellPressed,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.settings,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.push(RouteNames.doctorSettings),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 250),
                turns: _isExpanded ? 0.5 : 0,
                child: const Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentWidget(_AppointmentWrapper apt, Rect bounds) {
    Color bgColor;
    Color textColor;
    Color accentColor;
    bool isCancelled = apt.status == 'cancelled';

    if (isCancelled) {
      bgColor = AppColors.error.withValues(alpha: 0.15);
      textColor = AppColors.error;
      accentColor = AppColors.error;
    } else if (apt.bookingType == 'home') {
      bgColor = AppColors.aptHomeVisit;
      textColor = AppColors.aptHomeVisitText;
      accentColor = AppColors.aptHomeVisitText;
    } else if (apt.isConsultation) {
      bgColor = AppColors.aptInPerson;
      textColor = AppColors.aptInPersonText;
      accentColor = AppColors.aptInPersonText;
    } else {
      bgColor = AppColors.aptVideoCall;
      textColor = AppColors.aptVideoCallText;
      accentColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isCancelled
            ? Border.all(
                color: AppColors.error.withValues(alpha: 0.4),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: double.infinity,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    '${apt.startTime.hour}:${apt.startTime.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    apt.patientName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isCancelled
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (isCancelled) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Annulé',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _AppointmentWrapper extends Appointment {
  @override
  final String id;
  final String patientName;
  final String status;
  final bool isConsultation;
  final int duration;
  @override
  final String? notes;
  final String? patientPhone;
  final String? patientAvatar;
  final String? patientId;
  final String bookingType;
  final String doctorId;
  final String doctorName;

  _AppointmentWrapper({
    required this.id,
    required DateTime startTime,
    required DateTime endTime,
    required this.patientName,
    required this.status,
    required this.isConsultation,
    required this.duration,
    this.notes,
    this.patientPhone,
    this.patientAvatar,
    this.patientId,
    this.bookingType = 'online',
    this.doctorId = '',
    this.doctorName = '',
  }) : super(
         id: id,
         startTime: startTime,
         endTime: endTime,
         subject: patientName,
         notes: notes,
         color: isConsultation
             ? AppColors.consultationColor
             : AppColors.primary,
       );

  @override
  Color get color {
    if (status == 'cancelled') {
      return AppColors.error.withValues(alpha: 0.7);
    }
    return isConsultation ? AppColors.consultationColor : AppColors.primary;
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }

  void updateAppointments(List<Appointment> appointments) {
    this.appointments = appointments;
    notifyListeners(CalendarDataSourceAction.reset, appointments);
  }
}
