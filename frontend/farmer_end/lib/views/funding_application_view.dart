import 'package:flutter/material.dart';

class FundingApplicationView extends StatefulWidget {
  const FundingApplicationView({super.key});

  @override
  State<FundingApplicationView> createState() => _FundingApplicationViewState();
}

class _FundingApplicationViewState extends State<FundingApplicationView> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  String _farmName = '';
  String _iban = '';

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funding application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('APIA Funding Application'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _submitApplication();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: [
            Step(
              title: const Text('Farm Details'),
              content: Semantics(
                label: 'Enter your farm name',
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (val) => _farmName = val!,
                ),
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Bank Information'),
              content: Semantics(
                label: 'Enter your IBAN for subsidy deposits',
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'IBAN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (val) => _iban = val!,
                ),
              ),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Review & Submit'),
              content: Semantics(
                label: 'Review your application details before submitting',
                child: const Text('Please ensure all documents for your animals are uploaded in the Digital Wallet before submitting this application. Click continue to submit.'),
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}
