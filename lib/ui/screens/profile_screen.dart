import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../../providers/goal_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import 'backup_screen.dart';
import 'goals_screen.dart';
import 'journal_screen.dart';
import 'security_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final journalProvider = context.watch<JournalProvider>();
    final learning = context.watch<LearningProvider>();
    final name = settings.userName.isEmpty ? loc.t('default_user') : settings.userName;

    final menuItems = [
      (Icons.flag_outlined, loc.t('profile_goals'), const GoalsScreen()),
      (Icons.menu_book_outlined, loc.t('profile_journal'), const JournalScreen()),
      (Icons.insert_chart_outlined_rounded, loc.t('profile_statistics'), const StatisticsScreen()),
      (Icons.language_rounded, loc.t('profile_language'), const SettingsScreen()),
      (Icons.lock_outline_rounded, loc.t('profile_security'), const SecurityScreen()),
      (Icons.cloud_sync_outlined, loc.t('profile_backup'), const BackupScreen()),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text(loc.t('profile_title'), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.roseGold.withOpacity(0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 2),
                        Text(
                          loc.t('tagline'),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editName(context),
                    icon:
                        const Icon(Icons.edit_outlined, size: 19, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                for (final item in menuItems)
                  GlassCard(
                    blur: false,
                    radius: 20,
                    padding: const EdgeInsets.all(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => item.$3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppColors.glassGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Icon(item.$1, size: 19, color: AppColors.roseGold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              blur: false,
              radius: 20,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('stats_title'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MiniCount(
                        label: loc.t('stats_completed'),
                        value: '${taskProvider.tasks.where((t) => t.isDone).length}',
                      ),
                      _MiniCount(
                        label: loc.t('stats_goals_done'),
                        value: '${goalProvider.doneCount}',
                      ),
                      _MiniCount(
                        label: loc.t('stats_journal_entries'),
                        value: '${journalProvider.entries.length}',
                      ),
                      _MiniCount(
                        label: loc.t('stats_total_hours'),
                        value:
                            '${(learning.totalMinutes / 60).toStringAsFixed(1)} ${loc.t('hours_suffix')}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '${loc.t('app_name')} · ${loc.t('settings_version')} 1.0.0',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editName(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: settings.userName);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.t('profile_edit_name')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: loc.t('profile_name_hint')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              settings.setUserName(controller.text);
              Navigator.of(dialogContext).pop();
            },
            child: Text(loc.t('save')),
          ),
        ],
      ),
    );
  }
}

class _MiniCount extends StatelessWidget {
  const _MiniCount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.roseGold,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
