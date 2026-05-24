import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import 'funding_application_view.dart';

class MyDossiersView extends StatefulWidget {
  const MyDossiersView({super.key});

  @override
  State<MyDossiersView> createState() => _MyDossiersViewState();
}

class _MyDossiersViewState extends State<MyDossiersView> {
  List<dynamic> _dossiers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDossiers();
  }

  Future<void> _fetchDossiers() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    
    // Hardcoded farmer ID 1 for Hackathon demo purposes
    // In a real app, the ID comes from auth token
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/grant-dossiers/farmer/1'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _dossiers = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching dossiers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf(int dossierId, String docType) async {
    final url = Uri.parse('http://localhost:8080/api/grant-dossiers/$dossierId/download/$docType');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eroare la descărcarea documentului.')),
        );
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'PENDING_VET':
        color = Colors.orange;
        label = 'Așteaptă Veterinarul';
        icon = Icons.medical_services_outlined;
        break;
      case 'RETURNED_TO_FARMER':
        color = Colors.red;
        label = 'Respins de Veterinar';
        icon = Icons.error_outline;
        break;
      case 'PENDING_APIA':
        color = Colors.blue;
        label = 'Așteaptă Validare APIA';
        icon = Icons.account_balance;
        break;
      case 'APPROVED':
        color = Colors.green;
        label = 'Dosar Aprobat!';
        icon = Icons.check_circle;
        break;
      case 'RETURNED_TO_VET':
        color = Colors.redAccent;
        label = 'Respins de APIA';
        icon = Icons.warning_amber;
        break;
      case 'DRAFT_FERMIER':
      default:
        color = Colors.grey;
        label = 'Draft (Netrimis)';
        icon = Icons.drafts;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosarele Mele (Istoric)'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dossiers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchDossiers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dossiers.length,
                    itemBuilder: (context, index) {
                      final dossier = _dossiers[index];
                      final animalTag = dossier['animal']?['tagNumber'] ?? 'N/A';
                      final createdAt = dossier['createdAt'] != null 
                          ? dossier['createdAt'].toString().substring(0, 10) 
                          : 'Necunoscut';
                      final status = dossier['status'] ?? 'DRAFT_FERMIER';
                      final dossierId = dossier['id'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grant SCZ Vițel',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text('#$dossierId', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.pets, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('Crotalie: $animalTag', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('Data depunerii: $createdAt', style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildStatusChip(status),
                              
                              if (status == 'RETURNED_TO_FARMER')
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(color: Colors.red.shade200),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info, color: Colors.red),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Veterinarul a constatat o problemă cu acest dosar. Vă rugăm să-l editați și să-l retrimiteți.',
                                          style: TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FundingApplicationView(initialData: dossier as Map<String, dynamic>),
                                            ),
                                          );
                                        },
                                        child: const Text('Editează'),
                                      )
                                    ],
                                  ),
                                ),
                                
                              const Divider(height: 32),
                              const Text('Documente:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (dossier['farmerDocumentUrl'] != null)
                                    ActionChip(
                                      avatar: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                                      label: const Text('Cererea Mea'),
                                      onPressed: () => _downloadPdf(dossierId, 'farmer'),
                                      backgroundColor: Colors.grey.shade100,
                                    ),
                                  if (dossier['vetDocumentUrl'] != null)
                                    ActionChip(
                                      avatar: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                                      label: const Text('Formular F1 (Vet)'),
                                      onPressed: () => _downloadPdf(dossierId, 'vet'),
                                      backgroundColor: Colors.grey.shade100,
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Nu aveți niciun dosar depus.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // The home screen will navigate to FundingApplicationView if needed
            },
            child: const Text('Înapoi la meniul principal'),
          )
        ],
      ),
    );
  }
}
