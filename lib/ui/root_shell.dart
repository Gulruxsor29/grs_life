import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import 'lock_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  bool _unlocked = false;

  void _goTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    if (settings.pinEnabled && !_unlocked) {
      return LockScreen(onSuccess: () => setState(() => _unlocked = true));
    }
    final loc = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onNavigate: _goTab),
            const PlannerScreen(),
            const FinanceScreen(),
            const LearningScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavBar(loc),
    );
  }

  Widget _buildNavBar(AppLocalizations loc) {
    final items = [
      (Icons.space_dashboard_rounded, loc.t('nav_home')),
      (Icons.calendar_month_rounded, loc.t('nav_planner')),
      (Icons.account_balance_wallet_rounded, loc.t('nav_finance')),
      (Icons.school_rounded, loc.t('nav_learning')),
      (Icons.person_rounded, loc.t('nav_profile')),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavItem(
                icon: items[i].$1,
                label: items[i].$2,
                selected: i == _index,
                onTap: () => _goTab(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.brandGradient : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.roseGold.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
