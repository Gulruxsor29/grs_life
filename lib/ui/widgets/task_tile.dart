import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../providers/task_provider.dart';
import 'task_form_sheet.dart';
import '../../core/widgets/ui_kit.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  void _confirmDelete(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.t('delete_item_title')),
        content: Text(loc.t('delete_item_text')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TaskProvider>().delete(task);
            },
            child: Text(
              loc.t('delete'),
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final def = categoryDef(task.category);
    final now = DateTime.now();
    final isOverdue = !task.isDone && task.dueDate.isBefore(now);
    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<TaskProvider>().toggleDone(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: task.isDone ? AppColors.brandGradient : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isDone ? Colors.transparent : def.color.withOpacity(0.7),
                  width: 1.6,
                ),
              ),
              child: task.isDone
                  ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(def.icon, size: 12, color: def.color),
                    const SizedBox(width: 4),
                    Text(
                      loc.t(categoryL10nKey(task.category)),
                      style: TextStyle(fontSize: 11, color: def.color),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      formatTimeOfDay(TimeOfDay.fromDateTime(task.dueDate)),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: priorityColor(task.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Text(
                        loc.t('overdue'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: () => TaskFormSheet.show(context, task: task),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon:
                const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textSecondary),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }
}
