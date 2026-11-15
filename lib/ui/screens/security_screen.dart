import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/ui_kit.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  Future<void> _changePin(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final settings = context.read<SettingsProvider>();
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? error;
    String? pin;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(loc.t('security_change_pin')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: loc.t('security_new_pin'),
                  counterText: '',
                  errorText: error,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: loc.t('security_confirm_pin'),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(loc.t('cancel')),
            ),
            TextButton(
              onPressed: () {
                final pinValue = pinController.text.trim();
                final confirm = confirmController.text.trim();
                if (pinValue.length < 4 || pinValue.length > 6) {
                  setDialogState(() => error = loc.t('security_pin_invalid'));
                  return;
                }
                if (pinValue != confirm) {
                  setDialogState(() => error = loc.t('security_pin_mismatch'));
                  return;
                }
                pin = pinValue;
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(loc.t('save')),
            ),
          ],
        ),
      ),
    );

    if (result == true && pin != null) {
      await settings.setPin(pin!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('security_pin_saved'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.t('security_title')),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            GlassCard(
              blur: false,
              radius: 20,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.roseGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.roseGold, size: 21),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      loc.t('security_pin_enable'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Switch(
                    value: settings.pinEnabled,
                    onChanged: (value) async {
                      if (value) {
                        await _changePin(context);
                      } else {
                        await settings.disablePin();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.t('security_pin_disabled'))),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            if (settings.pinEnabled) ...[
              const SizedBox(height: 12),
              GlassCard(
                blur: false,
                radius: 20,
                padding: const EdgeInsets.all(18),
                onTap: () => _changePin(context),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.copper.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.password_rounded,
                          color: AppColors.copper, size: 21),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        loc.t('security_change_pin'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
