import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_card.dart';
import 'ledger_screen.dart';
import 'consultation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PendingAlertsView(),
    const ConsultationScreen(),
    const LedgerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bună ziua, Dr. Popescu", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text("Sincronizat cu Cloud Guvernamental", style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthService>().logout(),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pending_actions, size: 32),
            label: "Alerte Pendinte",
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services, size: 32),
            label: "Consultații",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_edu, size: 32),
            label: "Registru Ledger",
          ),
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

    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_all, size: 100, color: AppTheme.primaryAction),
            SizedBox(height: 16),
            Text("Nu există alerte pendinte.", style: TextStyle(fontSize: 24)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: alerts.length,
      itemBuilder: (context, index) => ActionCard(
        alert: alerts[index],
        onReject: () => context.read<DataService>().rejectAlert(alerts[index].id),
      ),
    );
  }
}
