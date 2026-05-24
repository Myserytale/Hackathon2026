import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/roeid_theme.dart';
import '../widgets/roeid_ui.dart';
import 'animal_browsing_view.dart';
import 'report_birth_view.dart';
import 'funding_application_view.dart';
import 'report_death_browsing_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.roeid.config;

    return Scaffold(
      appBar: RoeidPortalAppBar(
        title: 'Farm Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(brand.icon, size: 40, color: brand.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Manage animals, reports, and subsidy applications.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  RoeidStatusBadge(label: brand.badge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          RoeidActionTile(
            icon: Icons.list_alt,
            label: 'View My Animals',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnimalBrowsingView()),
              );
            },
          ),
          const SizedBox(height: 16),
          RoeidActionTile(
            icon: Icons.add_chart,
            label: 'Report Births / Deaths',
            accent: brand.primaryDark,
            onPressed: () => _showReportActionDialog(context),
          ),
          const SizedBox(height: 16),
          RoeidActionTile(
            icon: Icons.medical_services_outlined,
            label: 'Contact the Vet',
            accent: const Color(0xFF1565C0),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Request Vet Visit'),
                  content: const Text(
                    'A notification will be sent to your assigned veterinarian to schedule a farm visit.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vet visit request sent successfully!'),
                            backgroundColor: RoeidTheme.success,
                          ),
                        );
                      },
                      child: const Text('Send Request'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          RoeidActionTile(
            icon: Icons.monetization_on_outlined,
            label: 'Apply for Subsidy (APIA)',
            accent: const Color(0xFF5E35B1),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FundingApplicationView()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReportActionDialog(BuildContext context) {
    final brand = context.roeid;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What would you like to report?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(backgroundColor: brand.primary, child: const Icon(Icons.child_care, color: Colors.white)),
              title: const Text('New Birth', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Add a newborn animal to inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportBirthView()));
              },
            ),
            ListTile(
              leading: CircleAvatar(backgroundColor: RoeidTheme.error, child: const Icon(Icons.error_outline, color: Colors.white)),
              title: const Text('Animal Death', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Remove a deceased animal from inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportDeathBrowsingView()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to disconnect from the farmer portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Provider.of<AuthService>(context, listen: false).logout();
    }
  }
}
