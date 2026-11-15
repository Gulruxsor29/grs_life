import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../providers/goal_provider.dart';
import '../../core/widgets/ui_kit.dart';

Future<void> showGoalForm(BuildContext context, {PersonalGoal? goal}) {
  final loc = AppLocalizations.of(context);
  final titleController = TextEditingController(text: goal?.title ?? '');
  final descController = TextEditingController(text: goal?.description ?? '');
  DateTime? targetDate = goal?.targetDate;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                goal == null ? loc.t('goals_add') : loc.t('edit'),
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: loc.t('goals_title_hint'),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: loc.t('goals_description'),
                  hintText: loc.t('goals_description_hint'),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: sheetContext,
                    initialDate: targetDate ?? DateTime.now(),
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime(DateTime.now().year + 10),
                  );
                  if (picked != null) setSheetState(() => targetDate = picked);
                },
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(
                  targetDate == null
                      ? loc.t('goals_target_date')
                      : formatDate(targetDate!, uz: loc.isUz),
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: loc.t('save'),
                icon: Icons.check_rounded,
                onTap: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text(loc.t('error_required'))),
                    );
                    return;
                  }
                  final provider = context.read<GoalProvider>();
                  if (goal == null) {
                    provider.add(PersonalGoal(
                      title: title,
                      description: descController.text.trim(),
                      targetDate: targetDate,
                      createdAt: DateTime.now(),
                    ));
                  } else {
                    provider.update(goal.copyWith(
                      title: title,
                      description: descController.text.trim(),
                      targetDate: targetDate,
                    ));
                  }
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<GoalProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.t('goals_title')),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.roseGold,
        foregroundColor: Colors.white,
        onPressed: () => showGoalForm(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: provider.goals.isEmpty
            ? EmptyState(icon: Icons.flag_outlined, message: loc.t('goals_empty'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: provider.goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _GoalCard(goal: provider.goals[i]),
              ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final PersonalGoal goal;

  Future<void> _addProgress(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final provider = context.read<GoalProvider>();
    var value = goal.progress.toDouble();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(loc.t('goals_add_progress')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${value.round()}%',
                style: const TextStyle(
                  color: AppColors.roseGold,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Slider(
                value: value,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (v) => setDialogState(() => value = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.t('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(value.round()),
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    await provider.setProgress(goal, result);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<GoalProvider>();
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: goal.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: goal.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _addProgress(context),
                icon: const Icon(Icons.tune_rounded, size: 19, color: AppColors.roseGold),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => showGoalForm(context, goal: goal),
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => provider.toggleDone(goal),
                icon: Icon(
                  goal.isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: goal.isDone ? AppColors.success : AppColors.textSecondary,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(loc.t('delete_item_title')),
                      content: Text(loc.t('delete_item_text')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: Text(loc.t('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          child: Text(
                            loc.t('delete'),
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) await provider.delete(goal);
                },
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 19, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (goal.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                goal.description,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ),
          if (goal.targetDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text(
                    formatDate(goal.targetDate!, uz: loc.isUz),
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(child: ProgressBar(value: goal.progress / 100)),
              const SizedBox(width: 10),
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
        ],
      ),
    );
  }
}
