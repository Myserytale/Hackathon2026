import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'animal_browsing_view.dart';
import 'report_birth_view.dart';
import 'funding_application_view.dart';
import 'report_death_browsing_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Management'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _dashboardButton(
              context,
              icon: Icons.list_alt,
              label: 'View My Animals',
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnimalBrowsingView()),
                );
              },
            ),
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.add_chart,
              label: 'Report Births/Deaths',
              color: Colors.blue,
              onPressed: () {
                _showReportActionDialog(context);
              },
            ),
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.medical_services,
              label: 'Contact the Vet',
              color: Colors.orange,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Request Vet Visit'),
                    content: const Text(
                      'A notification will be sent to your assigned veterinarian (vet_ana) to schedule a farm visit.\n\nThis feature uses the SSE notification system.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vet visit request sent successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Send Request', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.monetization_on,
              label: 'Apply for Subsidy (APIA)',
              color: Colors.purple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FundingApplicationView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportActionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What would you like to report?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.child_care, color: Colors.white),
              ),
              title: const Text('New Birth', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Add a new newborn animal to inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportBirthView()),
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.error_outline, color: Colors.white),
              ),
              title: const Text('Animal Death', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Remove a deceased animal from inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportDeathBrowsingView()),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: onPressed == null ? Colors.grey[300] : color.withOpacity(0.1),
        foregroundColor: onPressed == null ? Colors.grey[600] : color,
        elevation: 0,
        side: BorderSide(
          color: onPressed == null ? Colors.grey[400]! : color,
          width: 2,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title feature coming soon!')),
    );
  }
}

