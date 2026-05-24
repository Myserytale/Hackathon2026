import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../theme/roeid_theme.dart';
import '../widgets/roeid_ui.dart';
import 'animal_browsing_view.dart';
import 'report_birth_view.dart';
import 'funding_application_view.dart';
import 'report_death_browsing_view.dart';
import 'my_dossiers_view.dart';

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
                _showVetSelectionDialog(context);
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
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.folder_shared,
              label: 'My Grant Dossiers',
              color: Colors.teal,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyDossiersView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchVets(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/users/vets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error fetching vets: $e');
    }
    return [];
  }

  void _showVetSelectionDialog(BuildContext context) async {
    final vets = await _fetchVets(context);

    if (!context.mounted) return;

    if (vets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No veterinarians found. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic>? selectedVet;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Request Vet Visit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a veterinarian to send your visit request to:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'Veterinarian',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.orange),
                ),
                hint: const Text('Choose a vet...'),
                isExpanded: true,
                value: selectedVet,
                items: vets.map((vet) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: vet,
                    child: Text(
                      vet['username'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVet = value;
                  });
                },
              ),
              if (selectedVet != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A notification will be sent to ${selectedVet!['username']} to schedule a farm visit.',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedVet == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vet visit request sent to ${selectedVet!['username']}!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text('Send Request', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendVetRequest(BuildContext context) async {
    try {
      final authService = context.read<AuthService>();
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/incidents'),
        headers: {
          'Content-Type': 'application/json',
          if (authService.token != null) 'Authorization': 'Bearer ${authService.token}',
        },
        body: jsonEncode({
          'type': 'Vet Request',
          'description': 'The farmer has requested a vet visit.',
          'location': 'Farm Headquarters',
          'status': 'PENDING',
          'reportedAt': DateTime.now().toIso8601String(),
        }),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vet visit request sent to the Vet Portal!'),
            backgroundColor: RoeidTheme.success,
          ),
        );
      } else {
        throw Exception('Failed to send request');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not reach backend. Please try again later.'),
            backgroundColor: RoeidTheme.error,
          ),
        );
      }
    }
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
  }

  Widget _dashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color, width: 2),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 20),
        ],
      ),
    );
  }
}
