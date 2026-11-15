import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../../core/widgets/ui_kit.dart';

int? parseAmount(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[\s\u00A0]'), '');
  return int.tryParse(cleaned);
}

class TxFormSheet extends StatefulWidget {
  const TxFormSheet({super.key, required this.initialType, this.entry});

  final String initialType;
  final MoneyEntry? entry;

  static Future<void> show(BuildContext context, {required String initialType, MoneyEntry? entry}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: TxFormSheet(initialType: initialType, entry: entry),
      ),
    );
  }

  @override
  State<TxFormSheet> createState() => _TxFormSheetState();
}

class _TxFormSheetState extends State<TxFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late String _type;
  late String _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _amount = TextEditingController(text: entry == null ? '' : groupDigits(entry.amount));
    _note = TextEditingController(text: entry?.note ?? '');
    _type = entry?.type ?? widget.initialType;
    _category = entry?.category ?? (_type == MoneyEntry.typeIncome ? 'salary' : 'food');
    _date = entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      final allowed = type == MoneyEntry.typeIncome ? incomeCategories : expenseCategories;
      if (!allowed.any((c) => c.key == _category)) {
        _category = allowed.first.key;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 5),
      lastDate: DateTime(_date.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final loc = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.t('error_amount'))));
      return;
    }
    final entry = MoneyEntry(
      type: _type,
      amount: amount,
      category: _category,
      note: _note.text.trim(),
      date: _date,
      createdAt: widget.entry?.createdAt ?? DateTime.now(),
    );
    final provider = context.read<FinanceProvider>();
    if (widget.entry != null) {
      provider.deleteEntry(widget.entry!);
    }
    provider.addEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final categories = _type == MoneyEntry.typeIncome ? incomeCategories : expenseCategories;
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
              Row(
                children: [
                  Expanded(
                    child: _TypeToggle(
                      label: loc.t('finance_type_income'),
                      color: AppColors.success,
                      selected: _type == MoneyEntry.typeIncome,
                      onTap: () => _setType(MoneyEntry.typeIncome),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TypeToggle(
                      label: loc.t('finance_type_expense'),
                      color: AppColors.danger,
                      selected: _type == MoneyEntry.typeExpense,
                      onTap: () => _setType(MoneyEntry.typeExpense),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: loc.t('finance_amount'),
                  hintText: loc.t('finance_amount_hint'),
                  suffixText: currencySuffix(loc.isUz),
                ),
                validator: (v) =>
                    (v == null || parseAmount(v) == null || parseAmount(v)! <= 0)
                        ? loc.t('error_amount')
                        : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _note,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: loc.t('finance_note'),
                  hintText: loc.t('finance_note_hint'),
                ),
              ),
              const SizedBox(height: 18),
              Text(loc.t('task_category'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final def in categories)
                    GestureDetector(
                      onTap: () => setState(() => _category = def.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _category == def.key ? def.color.withOpacity(0.18) : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _category == def.key
                                ? def.color.withOpacity(0.8)
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(def.icon, size: 14, color: def.color),
                            const SizedBox(width: 6),
                            Text(
                              loc.t(categoryL10nKey(def.key)),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    _category == def.key ? def.color : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(formatDate(_date, uz: loc.isUz)),
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

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withOpacity(0.8) : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
