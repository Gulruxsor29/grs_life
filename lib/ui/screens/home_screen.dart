import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../providers/finance_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_tile.dart';
import '../../core/widgets/ui_kit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final finance = context.watch<FinanceProvider>();
    final learning = context.watch<LearningProvider>();
    final goalProvider = context.watch<GoalProvider>();

    final now = DateTime.now();
    final hour = now.hour;
    final greetingKey = hour < 5
        ? 'greeting_night'
        : hour < 12
            ? 'greeting_morning'
            : hour < 17
                ? 'greeting_afternoon'
                : hour < 22
                    ? 'greeting_evening'
                    : 'greeting_night';
    final name = settings.userName.isEmpty ? loc.t('default_user') : settings.userName;

    final todayTasks = taskProvider.todayTasks;
    final doneCount = todayTasks.where((t) => t.isDone).length;
    final progress = todayTasks.isEmpty ? 0.0 : doneCount / todayTasks.length;
    final activeGoals = goalProvider.activeGoals;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.tf(greetingKey, {'%s': name}),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${weekdayName(now, uz: loc.isUz)}, ${formatDate(now, uz: loc.isUz)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roseGold.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.isEmpty ? 'G' : name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GlassCard(
            child: Row(
              children: [
                RingProgress(
                  progress: progress,
                  size: 96,
                  strokeWidth: 10,
                  center: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('home_daily_progress'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.tf('home_tasks_done', {
                          '%s': '$doneCount / ${todayTasks.length}',
                        }),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        todayTasks.isEmpty
                            ? loc.t('home_no_tasks')
                            : progress >= 1
                                ? loc.t('home_all_done')
                                : '${todayTasks.length - doneCount} ${loc.t('nav_planner').toLowerCase()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  blur: false,
                  radius: 20,
                  padding: const EdgeInsets.all(16),
                  onTap: () => onNavigate(2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded,
                              size: 15, color: AppColors.copper),
                          const SizedBox(width: 6),
                          Text(
                            loc.t('home_balance'),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatMoneyShort(finance.balance, uz: loc.isUz),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${formatMoneyShort(finance.monthIncome, uz: loc.isUz)}',
                        style: const TextStyle(color: AppColors.success, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  blur: false,
                  radius: 20,
                  padding: const EdgeInsets.all(16),
                  onTap: () => onNavigate(3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school_rounded, size: 15, color: AppColors.roseGold),
                          const SizedBox(width: 6),
                          Text(
                            loc.t('home_study_today'),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${learning.todayMinutes} ${loc.t('minutes_suffix')}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(learning.overallProgress * 100).round()}% ${loc.t('learning_overall').toLowerCase()}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: loc.t('home_tasks_today'),
            actionLabel: loc.t('home_view_all'),
            onAction: () => onNavigate(1),
          ),
          if (todayTasks.isEmpty)
            GlassCard(
              blur: false,
              radius: 20,
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  const Icon(Icons.task_alt_rounded, color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.t('home_no_tasks'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => TaskFormSheet.show(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.roseGold),
                  ),
                ],
              ),
            )
          else
            ...todayTasks.take(4).map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskTile(task: task),
                )),
          const SizedBox(height: 16),
          SectionHeader(
            title: loc.t('home_active_goals'),
            actionLabel: loc.t('home_view_all'),
            onAction: () => onNavigate(4),
          ),
          if (activeGoals.isEmpty)
            GlassCard(
              blur: false,
              radius: 20,
              padding: const EdgeInsets.all(22),
              child: Text(
                loc.t('home_no_goals'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ...activeGoals.take(3).map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    blur: false,
                    radius: 20,
                    padding: const EdgeInsets.all(16),
                    onTap: () => onNavigate(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${goal.progress}%',
                              style: const TextStyle(
                                color: AppColors.roseGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ProgressBar(value: goal.progress / 100),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
