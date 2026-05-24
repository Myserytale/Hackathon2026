import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/roeid_theme.dart';
import '../widgets/roeid_ui.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deconectare'),
        content: const Text('Sigur doriți să vă deconectați din portalul APIA?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deconectare'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      drawer: !isDesktop ? const Sidebar() : null,
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopHeader(),
                Expanded(
                  child: Container(
                    color: RoeidTheme.background,
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final brand = context.roeid.config;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [brand.primaryDark, brand.primary],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'ROeID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(brand.icon, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        brand.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _NavItem(
            icon: Icons.dashboard,
            label: 'Coada Subvenții',
            isSelected: location == '/',
            onTap: () => context.go('/'),
          ),
          _NavItem(
            icon: Icons.history,
            label: 'Audit Transparență',
            isSelected: location == '/ledger',
            onTap: () => context.go('/ledger'),
          ),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'Data Analytics',
            isSelected: location == '/analytics',
            onTap: () => context.go('/analytics'),
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.logout,
            label: 'Deconectare',
            isSelected: false,
            onTap: () => DashboardShell._confirmLogout(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        selected: isSelected,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white60,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: isSelected ? Colors.white.withAlpha(26) : null,
      ),
    );
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final brand = context.roeid.config;

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: RoeidTheme.surface,
        border: Border(bottom: BorderSide(color: RoeidTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 28,
            decoration: BoxDecoration(
              color: brand.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Administrație Centrală APIA',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          RoeidStatusBadge(label: 'Regiunea: NORD-VEST'),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(user?.name ?? 'Utilizator', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(user?.role ?? 'Specialist', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: brand.primary.withValues(alpha: 0.12),
            child: Icon(Icons.person, size: 20, color: brand.primaryDark),
          ),
        ],
      ),
    );
  }
}
