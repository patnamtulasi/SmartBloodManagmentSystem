import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../models/blood_request.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...mockService.activeRequests.map((req) => _buildEmergencyAlert(req)),
          const SizedBox(height: 12),
          _buildStandardNotification(
            title: 'Upcoming Appointment',
            body: 'You have a donation appointment tomorrow at 10:00 AM.',
            icon: LucideIcons.calendar,
            color: Colors.blue,
          ),
          _buildStandardNotification(
            title: 'Eligibility Update',
            body: 'You are now eligible to donate blood again!',
            icon: LucideIcons.checkCircle2,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyAlert(BloodRequest req) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 32),
        title: Text(
          'EMERGENCY: ${req.requestedType.label} Blood Required',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        subtitle: Text('${req.unitsRequired} units needed urgently at ${req.location}.'),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.red),
        onTap: () {},
      ),
    );
  }

  Widget _buildStandardNotification({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(body),
        onTap: () {},
      ),
    );
  }
}
