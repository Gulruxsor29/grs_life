import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/database/database_helper.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../core/widgets/ui_kit.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  Future<File> _backupFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/grs_life_backup.json');
  }

  Future<void> _export(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final settings = context.read<SettingsProvider>();
    try {
      final data = await DatabaseHelper.instance.exportAll();
      final file = await _backupFile();
      await file.writeAsString(jsonEncode({
        'app': 'grs_life',
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'data': data,
      }));
      await settings.setLastBackup(DateTime.now());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.tf('backup_success', {'%s': file.path})),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.tf('backup_failed', {'%s': e.toString()}))),
        );
      }
    }
  }

  Future<void> _restore(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final file = await _backupFile();
    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('backup_no_file'))),
        );
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.t('backup_confirm_title')),
        content: Text(loc.t('backup_confirm_text')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(loc.t('confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final raw = decoded['data'] as Map<String, dynamic>;
      final data = <String, List<Map<String, Object?>>>{};
      raw.forEach((key, value) {
        data[key] = (value as List).map((e) => Map<String, Object?>.from(e as Map)).toList();
      });
      await DatabaseHelper.instance.restore(data);
      if (!context.mounted) return;
      await Future.wait([
        context.read<TaskProvider>().load(),
        context.read<FinanceProvider>().load(),
        context.read<LearningProvider>().load(),
        context.read<GoalProvider>().load(),
        context.read<JournalProvider>().load(),
      ]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('backup_restored'))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.tf('backup_failed', {'%s': e.toString()}))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final last = settings.lastBackup;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.t('backup_title')),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.roseGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.cloud_sync_outlined,
                            color: AppColors.roseGold, size: 21),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          loc.t('backup_title'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.t('backup_description'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${loc.t('backup_last')}: ${last == null ? loc.t('backup_never') : formatDate(last, uz: loc.isUz)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: loc.t('backup_export'),
              icon: Icons.download_rounded,
              onTap: () => _export(context),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _restore(context),
              icon: const Icon(Icons.restore_rounded, size: 18),
              label: Text(loc.t('backup_restore')),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }
}
