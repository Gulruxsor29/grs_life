import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/charts.dart';
import '../../models/models.dart';
import '../../providers/finance_provider.dart';
import '../widgets/tx_form_sheet.dart';
import '../../core/widgets/ui_kit.dart';

int? parseAmount(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[\s\u00A0]'), '');
  return int.tryParse(cleaned);
}

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  void _showGoalSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? deadline;

    showModalBottomSheet<void>(
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
                  loc.t('finance_goal_add'),
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.t('finance_goal_name'),
                    hintText: loc.t('finance_goal_name_hint'),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: loc.t('finance_goal_target'),
                    suffixText: currencySuffix(loc.isUz),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: sheetContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year),
                      lastDate: DateTime(DateTime.now().year + 10),
                    );
                    if (picked != null) setSheetState(() => deadline = picked);
                  },
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(
                    deadline == null
                        ? loc.t('goals_target_date')
                        : formatDate(deadline!, uz: loc.isUz),
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: loc.t('save'),
                  icon: Icons.check_rounded,
                  onTap: () {
                    final name = nameController.text.trim();
                    final target = parseAmount(targetController.text);
                    if (name.isEmpty || target == null || target <= 0) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(content: Text(loc.t('error_required'))),
                      );
                      return;
                    }
                    context.read<FinanceProvider>().addGoal(FinancialGoal(
                          name: name,
                          targetAmount: target,
                          deadline: deadline,
                          createdAt: DateTime.now(),
                        ));
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final finance = context.watch<FinanceProvider>();
    final uz = loc.isUz;
    final now = DateTime.now();
    final mk = monthKeyOf(now);

    final expenseTotals = finance.categoryTotals(mk, MoneyEntry.typeExpense);
    final donutSegments = <DonutSegment>[
      for (final e in expenseTotals.entries)
        DonutSegment(value: e.value.toDouble(), color: categoryDef(e.key).color),
    ];
    final sixMonths = finance.lastMonthsTotals(6, MoneyEntry.typeExpense);
    final barData = <BarDatum>[
      for (final e in sixMonths.entries)
        BarDatum(
          label: shortMonth(DateTime.parse('${e.key}-01').month, uz: uz),
          value: e.value.toDouble(),
          highlight: e.key == mk,
        ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text(loc.t('finance_title'), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        loc.t('finance_balance'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => TxFormSheet.show(
                          context,
                          initialType: MoneyEntry.typeIncome,
                        ),
                        icon: const Icon(Icons.add_rounded, color: AppColors.success, size: 22),
                      ),
                    ],
                  ),
                  Text(
                    formatMoney(finance.balance, uz: uz),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.south_west_rounded,
                          color: AppColors.success,
                          label: loc.t('finance_income'),
                          value: formatMoneyShort(finance.monthIncome, uz: uz),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.north_east_rounded,
                          color: AppColors.danger,
                          label: loc.t('finance_expense'),
                          value: formatMoneyShort(finance.monthExpense, uz: uz),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _BudgetCard(),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('finance_chart_month'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (donutSegments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        loc.t('finance_empty_category'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Row(
                      children: [
                        DonutChart(
                          segments: donutSegments,
                          size: 130,
                          strokeWidth: 20,
                          center: Text(
                            formatMoneyShort(finance.monthExpense, uz: uz),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              for (final e in expenseTotals.entries)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: categoryDef(e.key).color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          loc.t(categoryL10nKey(e.key)),
                                          style: const TextStyle(
                                              fontSize: 11.5, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        formatMoneyShort(e.value, uz: uz),
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
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('finance_chart_6months'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  BarChart(data: barData, height: 150),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: loc.t('finance_goals'),
              actionLabel: loc.t('add'),
              onAction: () => _showGoalSheet(context),
            ),
            if (finance.goals.isEmpty)
              GlassCard(
                blur: false,
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Text(
                  loc.t('goals_empty'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              )
            else
              ...finance.goals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FinancialGoalCard(goal: goal),
                  )),
            const SizedBox(height: 20),
            SectionHeader(
              title: loc.t('finance_transactions'),
              actionLabel: loc.t('add'),
              onAction: () => TxFormSheet.show(context, initialType: MoneyEntry.typeExpense),
            ),
            if (finance.entries.isEmpty)
              GlassCard(
                blur: false,
                radius: 20,
                padding: const EdgeInsets.all(20),
                child: Text(
                  loc.t('finance_no_transactions'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              )
            else
              _TransactionsList(entries: finance.entries),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard();

  Future<void> _editBudget(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final finance = context.read<FinanceProvider>();
    final controller = TextEditingController(
      text: finance.currentBudget > 0 ? groupDigits(finance.currentBudget) : '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.t('finance_budget')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: loc.t('finance_amount_hint'),
            suffixText: currencySuffix(loc.isUz),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(loc.t('save')),
          ),
        ],
      ),
    );
    if (result == null) return;
    final amount = parseAmount(result);
    if (amount == null || amount <= 0) return;
    await finance.setBudget(monthKeyOf(DateTime.now()), amount);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final finance = context.watch<FinanceProvider>();
    final uz = loc.isUz;
    final budget = finance.currentBudget;

    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(18),
      child: budget <= 0
          ? Row(
              children: [
                const Icon(Icons.savings_outlined, color: AppColors.copper, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.t('finance_budget_empty'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => _editBudget(context),
                  child: Text(loc.t('finance_budget_set')),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings_outlined, color: AppColors.copper, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.t('finance_budget'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _editBudget(context),
                      icon: const Icon(Icons.edit_outlined,
                          size: 17, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(
                  value: finance.budgetUsage,
                  colors: finance.budgetUsage > 1
                      ? const [AppColors.danger, AppColors.danger]
                      : const [AppColors.roseGold, AppColors.copper],
                ),
                const SizedBox(height: 10),
                Text(
                  finance.budgetUsage > 1
                      ? loc.tf('finance_budget_over', {
                          '%s': formatMoneyShort(finance.monthExpense - budget, uz: uz),
                        })
                      : loc.tf('finance_budget_left', {
                          '%s': formatMoneyShort(budget - finance.monthExpense, uz: uz),
                        }),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: finance.budgetUsage > 1 ? AppColors.danger : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _FinancialGoalCard extends StatelessWidget {
  const _FinancialGoalCard({required this.goal});

  final FinancialGoal goal;

  Future<void> _addProgress(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final finance = context.read<FinanceProvider>();
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.t('finance_goal_add_progress')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: loc.t('finance_goal_amount_hint'),
            suffixText: currencySuffix(loc.isUz),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(loc.t('add')),
          ),
        ],
      ),
    );
    if (result == null) return;
    final amount = parseAmount(result);
    if (amount == null || amount <= 0) return;
    await finance.addToGoalProgress(goal, amount);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final finance = context.watch<FinanceProvider>();
    final uz = loc.isUz;
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
                  goal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _addProgress(context),
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.success, size: 20),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => finance.deleteGoal(goal),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            goal.isComplete
                ? loc.t('finance_goal_done')
                : '${formatMoney(goal.savedAmount, uz: uz)} / ${formatMoney(goal.targetAmount, uz: uz)}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: goal.isComplete ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ProgressBar(
            value: goal.progress,
            colors: goal.isComplete
                ? const [AppColors.success, AppColors.success]
                : const [AppColors.roseGold, AppColors.copper],
          ),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.entries});

  final List<MoneyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final uz = loc.isUz;
    final finance = context.read<FinanceProvider>();
    final widgets = <Widget>[];
    String? lastKey;
    final now = DateTime.now();
    for (final entry in entries) {
      final key = dateKey(entry.date);
      if (key != lastKey) {
        lastKey = key;
        final label = sameDay(entry.date, now)
            ? loc.t('today')
            : sameDay(entry.date, now.subtract(const Duration(days: 1)))
                ? loc.t('yesterday')
                : formatDate(entry.date, uz: uz);
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ));
      }
      widgets.add(_TransactionTile(entry: entry, onDelete: () => finance.deleteEntry(entry)));
    }
    return Column(children: widgets);
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.entry, required this.onDelete});

  final MoneyEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final def = categoryDef(entry.category);
    final color = entry.isIncome ? AppColors.success : AppColors.danger;
    return GlassCard(
      blur: false,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: def.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(def.icon, size: 18, color: def.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t(categoryL10nKey(entry.category)),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (entry.note.isNotEmpty)
                  Text(
                    entry.note,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.isIncome ? '+' : '-'}${formatMoney(entry.amount, uz: loc.isUz)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
