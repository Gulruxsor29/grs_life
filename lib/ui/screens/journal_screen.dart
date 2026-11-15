import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ui_kit.dart';
import '../../models/models.dart';
import '../../providers/journal_provider.dart';

Future<void> showJournalForm(BuildContext context, {JournalEntry? entry}) {
  final loc = AppLocalizations.of(context);
  final titleController = TextEditingController(text: entry?.title ?? '');
  final contentController = TextEditingController(text: entry?.content ?? '');
  String mood = entry?.mood ?? 'good';

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
                entry == null ? loc.t('journal_add') : loc.t('edit'),
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: loc.t('task_title'),
                  hintText: loc.t('journal_entry_title_hint'),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: loc.t('journal_content'),
                  hintText: loc.t('journal_content_hint'),
                ),
              ),
              const SizedBox(height: 16),
              Text(loc.t('journal_mood'), style: Theme.of(sheetContext).textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in moods)
                    GestureDetector(
                      onTap: () => setSheetState(() => mood = m.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: mood == m.key ? m.color.withOpacity(0.16) : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: mood == m.key
                                ? m.color.withOpacity(0.8)
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(m.icon, size: 15, color: m.color),
                            const SizedBox(width: 6),
                            Text(
                              loc.t('mood_${m.key}'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: mood == m.key ? m.color : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: loc.t('save'),
                icon: Icons.check_rounded,
                onTap: () {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();
                  if (title.isEmpty || content.isEmpty) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      SnackBar(content: Text(loc.t('error_required'))),
                    );
                    return;
                  }
                  final provider = context.read<JournalProvider>();
                  final now = DateTime.now();
                  if (entry == null) {
                    provider.add(JournalEntry(
                      title: title,
                      content: content,
                      mood: mood,
                      createdAt: now,
                      updatedAt: now,
                    ));
                  } else {
                    provider.update(JournalEntry(
                      id: entry.id,
                      title: title,
                      content: content,
                      mood: mood,
                      createdAt: entry.createdAt,
                      updatedAt: now,
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

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<JournalProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.t('journal_title')),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.roseGold,
        foregroundColor: Colors.white,
        onPressed: () => showJournalForm(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: provider.entries.isEmpty
            ? EmptyState(icon: Icons.menu_book_outlined, message: loc.t('journal_empty'))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: provider.entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final entry = provider.entries[i];
                  final mood = moodDef(entry.mood);
                  return GlassCard(
                    blur: false,
                    radius: 20,
                    padding: const EdgeInsets.all(16),
                    onTap: () => showJournalForm(context, entry: entry),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: mood.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(mood.icon, color: mood.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                entry.content,
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formatDate(entry.createdAt, uz: loc.isUz),
                                style: const TextStyle(
                                    fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => provider.delete(entry),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
