import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_tile.dart';
import '../../core/widgets/ui_kit.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _month;
  DateTime _selected = DateTime.now();
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  Set<int> _daysWithTasks(List<Task> allTasks) {
    final key = monthKeyOf(_month);
    return allTasks
        .where((t) => monthKeyOf(t.dueDate) == key)
        .map((t) => t.dueDate.day)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<TaskProvider>();
    var dayTasks = provider.tasksForDay(_selected);
    if (_categoryFilter != null) {
      dayTasks = dayTasks.where((t) => t.category == _categoryFilter).toList();
    }
    final reminders = provider.upcomingWithReminder();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.roseGold,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () => TaskFormSheet.show(context, initialDate: _selected),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(loc.t('planner_title'), style: Theme.of(context).textTheme.displaySmall),
            ),
            _MonthCalendar(
              month: _month,
              selected: _selected,
              daysWithTasks: _daysWithTasks(provider.tasks),
              onSelectDay: (d) => setState(() => _selected = d),
              onPrevMonth: () => setState(() {
                _month = DateTime(_month.year, _month.month - 1, 1);
                _selected = DateTime(_month.year, _month.month, 1);
              }),
              onNextMonth: () => setState(() {
                _month = DateTime(_month.year, _month.month + 1, 1);
                _selected = DateTime(_month.year, _month.month, 1);
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterPill(
                    label: loc.t('home_view_all'),
                    color: AppColors.roseGold,
                    selected: _categoryFilter == null,
                    onTap: () => setState(() => _categoryFilter = null),
                  ),
                  for (final def in taskCategories)
                    _FilterPill(
                      label: loc.t(categoryL10nKey(def.key)),
                      color: def.color,
                      selected: _categoryFilter == def.key,
                      onTap: () => setState(() => _categoryFilter = def.key),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: dayTasks.isEmpty
                  ? EmptyState(
                      icon: Icons.event_note_rounded,
                      message: loc.t('planner_no_tasks'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      itemCount: dayTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => TaskTile(task: dayTasks[i]),
                    ),
            ),
            if (reminders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(title: loc.t('planner_reminders')),
                    ),
                    SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: reminders.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final task = reminders[i];
                          return GlassCard(
                            blur: false,
                            radius: 18,
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 176,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.notifications_active_rounded,
                                          size: 14, color: AppColors.copper),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${formatDateShort(task.dueDate, uz: loc.isUz)} · ${formatTimeOfDay(TimeOfDay.fromDateTime(task.dueDate))}',
                                          style: const TextStyle(
                                              fontSize: 11, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : AppColors.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: selected ? color.withOpacity(0.8) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.selected,
    required this.daysWithTasks,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final DateTime month;
  final DateTime selected;
  final Set<int> daysWithTasks;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final now = DateTime.now();
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;
    final cells = <int?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var d = 1; d <= daysInMonth; d++) d,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        blur: false,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPrevMonth,
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: Text(
                    monthTitle(month.year, month.month, uz: loc.isUz),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var wd = 1; wd <= 7; wd++)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekdayShort(wd, uz: loc.isUz),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            for (var row = 0; row < cells.length / 7; row++)
              Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: _dayCell(cells[row * 7 + col], now),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(int? day, DateTime now) {
    if (day == null) return const SizedBox.shrink();
    final date = DateTime(month.year, month.month, day);
    final isSelected = sameDay(date, selected);
    final isToday = sameDay(date, now);
    final hasTasks = daysWithTasks.contains(day);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelectDay(date),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.brandGradient : null,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.roseGold.withOpacity(0.7))
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.roseGold.withOpacity(0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.roseGold
                          : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: hasTasks ? AppColors.copper : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
