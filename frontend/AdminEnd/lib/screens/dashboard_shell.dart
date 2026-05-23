import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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

    return Container(
      width: 280,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: const Row(
              children: [
                Icon(Icons.account_balance, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'APIA Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text(
            'Administrație Centrală APIA',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Regiunea: NORD-VEST (CLUJ)',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user?.name ?? 'Utilizator',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                user?.role ?? 'Specialist',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Color(0xFFEEEEEE),
            child: Icon(Icons.person, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
