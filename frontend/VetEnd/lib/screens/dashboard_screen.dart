import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../theme/roeid_theme.dart';
import '../widgets/roeid_ui.dart';
import '../widgets/action_card.dart';
import 'ledger_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PendingAlertsView(),
    const LedgerScreen(),
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deconectare'),
        content: const Text('Sigur doriți să vă deconectați din portalul veterinar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anulează')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deconectare')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthService>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.roeid.config;

    return Scaffold(
      appBar: RoeidPortalAppBar(
        title: 'Portal Veterinar',
        actions: [
          RoeidStatusBadge(label: brand.badge),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Deconectare',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: RoeidTheme.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sincronizat cu Cloud Guvernamental',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.pending_actions_outlined), selectedIcon: Icon(Icons.pending_actions), label: 'Alerte'),
          NavigationDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: 'Registru'),
        ],
      ),
    );
  }
}

class PendingAlertsView extends StatelessWidget {
  const PendingAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<DataService>().pendingAlerts;
    final brand = context.roeid;

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all, size: 72, color: brand.primary),
            const SizedBox(height: 16),
            Text('Nu există alerte pendinte.', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: alerts.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ActionCard(
          alert: alerts[index],
          onReject: () => context.read<DataService>().rejectAlert(alerts[index].id),
        ),
      ),
    );
  }
}
