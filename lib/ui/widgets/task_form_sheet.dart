import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../providers/task_provider.dart';
import '../../core/widgets/ui_kit.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.task, this.initialDate});

  final Task? task;
  final DateTime? initialDate;

  static Future<void> show(BuildContext context, {Task? task, DateTime? initialDate}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: TaskFormSheet(task: task, initialDate: initialDate),
      ),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _note;
  late String _category;
  late int _priority;
  late DateTime _date;
  late TimeOfDay _time;
  int? _reminderMinutes;
  bool? _reminderExpanded;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _note = TextEditingController(text: task?.note ?? '');
    _category = task?.category ?? 'work';
    _priority = task?.priority ?? 1;
    final base = task?.dueDate ?? widget.initialDate ?? DateTime.now();
    _date = DateTime(base.year, base.month, base.day);
    _time = TimeOfDay.fromDateTime(task?.dueDate ?? base.add(const Duration(hours: 1)));
    _reminderMinutes = task?.reminderMinutes;
    _reminderExpanded = task?.reminderMinutes != null;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 2),
      lastDate: DateTime(_date.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final loc = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<TaskProvider>();
    final due = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final existing = widget.task;
    if (existing == null) {
      provider.add(Task(
        title: _title.text.trim(),
        note: _note.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: due,
        reminderMinutes: _reminderExpanded == true ? _reminderMinutes : null,
        createdAt: DateTime.now(),
      ));
    } else {
      provider.update(existing.copyWith(
        title: _title.text.trim(),
        note: _note.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: due,
        reminderMinutes: _reminderExpanded == true ? _reminderMinutes : null,
      ));
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(existing == null ? loc.t('planner_add_task') : loc.t('save'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final editing = widget.task != null;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editing ? loc.t('planner_edit_task') : loc.t('planner_add_task'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: loc.t('task_title'), hintText: loc.t('task_title_hint')),
                validator: (v) => (v == null || v.trim().isEmpty) ? loc.t('error_required') : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: InputDecoration(labelText: loc.t('task_note'), hintText: loc.t('task_note_hint')),
              ),
              const SizedBox(height: 18),
              Text(loc.t('task_category'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final def in taskCategories)
                    _ChoiceChip(
                      label: loc.t(categoryL10nKey(def.key)),
                      icon: def.icon,
                      color: def.color,
                      selected: _category == def.key,
                      onTap: () => setState(() => _category = def.key),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(loc.t('task_priority'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var p = 0; p <= 2; p++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: p < 2 ? 8 : 0),
                        child: _PriorityChip(
                          label: loc.t(priorityL10nKey(p)),
                          color: priorityColor(p),
                          selected: _priority == p,
                          onTap: () => setState(() => _priority = p),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event_outlined, size: 18),
                      label: Text(formatDateShort(_date, uz: loc.isUz)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(formatTimeOfDay(_time)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.t('task_reminder'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Switch(
                    value: _reminderExpanded ?? false,
                    onChanged: (v) => setState(() {
                      _reminderExpanded = v;
                      if (v && _reminderMinutes == null) _reminderMinutes = 15;
                    }),
                  ),
                ],
              ),
              if (_reminderExpanded ?? false)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final minutes in const [5, 15, 30, 60])
                      _ChoiceChip(
                        label: loc.t('reminder_$minutes'),
                        icon: Icons.notifications_none_rounded,
                        color: AppColors.roseGold,
                        selected: _reminderMinutes == minutes,
                        onTap: () => setState(() => _reminderMinutes = minutes),
                      ),
                  ],
                ),
              const SizedBox(height: 24),
              GradientButton(
                label: loc.t('save'),
                icon: Icons.check_rounded,
                onTap: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withOpacity(0.8) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color.withOpacity(0.8) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
