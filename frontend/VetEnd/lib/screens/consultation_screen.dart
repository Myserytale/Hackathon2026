import 'package:flutter/material.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _notesController = TextEditingController();
  bool _flagIncident = false;
  String _consultationType = 'Health Certificate';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_flagIncident ? 'Biological Incident Flagged to APIA!' : 'Consultation Logged & Certificate Issued.'),
          backgroundColor: _flagIncident ? Colors.red : Colors.green,
        ),
      );
      _tagController.clear();
      _notesController.clear();
      setState(() {
        _flagIncident = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Log Veterinary Consultation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(labelText: 'Animal Tag Number', border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _consultationType,
              decoration: const InputDecoration(labelText: 'Consultation Type', border: OutlineInputBorder()),
              items: ['Health Certificate', 'Routine Checkup', 'Vaccination', 'Illness'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _consultationType = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Clinical Notes', border: OutlineInputBorder()),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Flag Potential Biological Incident', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Alert APIA immediately about a highly contagious disease.'),
              value: _flagIncident,
              onChanged: (val) => setState(() => _flagIncident = val),
              activeColor: Colors.red,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Submit Consultation'),
            ),
          ],
        ),
      ),
    );
  }
}
