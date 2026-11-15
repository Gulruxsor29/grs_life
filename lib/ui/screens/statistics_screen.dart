import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/learning_content.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/task_provider.dart';
import 'learning_screen.dart' show formatDuration;
import '../../core/widgets/ui_kit.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final uz = loc.isUz;
    final taskProvider = context.watch<TaskProvider>();
    final finance = context.watch<FinanceProvider>();
    final learning = context.watch<LearningProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final journalProvider = context.watch<JournalProvider>();
    final now = DateTime.now();
    final mk = monthKeyOf(now);

    final last7 = <BarDatum>[];
    for (var i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final total = taskProvider.totalCountForDay(day);
      final rate = total == 0 ? 0.0 : taskProvider.doneCountForDay(day) / total;
      last7.add(BarDatum(
        label: '${day.day}',
        value: rate * 100,
        highlight: i == 0,
      ));
    }

    final courseMinutes = <DonutSegment>[
      for (final course in CourseCatalog.courses)
        if (learning.minutesForCourse(course.key) > 0)
          DonutSegment(
            value: learning.minutesForCourse(course.key).toDouble(),
            color: course.color,
          ),
    ];

    final income = finance.monthTotal(mk, MoneyEntry.typeIncome);
    final expense = finance.monthTotal(mk, MoneyEntry.typeExpense);
    final savingsRate = income <= 0 ? 0.0 : ((income - expense) / income).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.t('stats_title')),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('stats_completion_rate'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  BarChart(data: last7, height: 140),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: loc.t('stats_total_tasks'),
                    value: '${taskProvider.tasks.length}',
                    icon: Icons.checklist_rounded,
                    color: AppColors.roseGold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: loc.t('stats_completed'),
                    value: '${taskProvider.tasks.where((t) => t.isDone).length}',
                    icon: Icons.task_alt_rounded,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('stats_finance'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _StatRow(
                    label: loc.t('finance_income'),
                    value: formatMoney(income, uz: uz),
                    color: AppColors.success,
                  ),
                  _StatRow(
                    label: loc.t('finance_expense'),
                    value: formatMoney(expense, uz: uz),
                    color: AppColors.danger,
                  ),
                  _StatRow(
                    label: loc.t('finance_balance'),
                    value: formatMoney(income - expense, uz: uz),
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: ProgressBar(value: savingsRate)),
                      const SizedBox(width: 10),
                      Text(
                        '${(savingsRate * 100).round()}% ${loc.t('stats_savings_rate').toLowerCase()}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('stats_hours_by_course'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (courseMinutes.isEmpty)
                    Text(
                      loc.t('learning_no_time'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    )
                  else
                    Row(
                      children: [
                        DonutChart(
                          segments: courseMinutes,
                          size: 120,
                          strokeWidth: 18,
                          center: Text(
                            formatDuration(learning.totalMinutes, loc),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              for (final course in CourseCatalog.courses)
                                if (learning.minutesForCourse(course.key) > 0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 9,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: course.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            loc.t('course_${course.key}'),
                                            style: const TextStyle(
                                                fontSize: 11.5,
                                                color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          formatDuration(
                                              learning.minutesForCourse(course.key), loc),
                                          style: const TextStyle(
                                              fontSize: 11.5, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: loc.t('stats_goals_done'),
                    value: '${goalProvider.doneCount}/${goalProvider.goals.length}',
                    icon: Icons.flag_rounded,
                    color: AppColors.copper,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: loc.t('stats_journal_entries'),
                    value: '${journalProvider.entries.length}',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
