import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Visualization & Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildChart('Incidents by Region', {'Cluj': 40, 'Bihor': 25, 'Arad': 15, 'Timis': 80})),
              const SizedBox(width: 24),
              Expanded(child: _buildChart('Funding Distribution (k€)', {'Dairy': 120, 'Meat': 85, 'Poultry': 45, 'Mixed': 60})),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(String title, Map<String, double> data) {
    final double maxVal = data.values.reduce((a, b) => a > b ? a : b);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((e) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(e.value.toString(), style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: (e.value / maxVal) * 200,
                        color: const Color(0xFF0277BD),
                      ),
                      const SizedBox(height: 8),
                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
