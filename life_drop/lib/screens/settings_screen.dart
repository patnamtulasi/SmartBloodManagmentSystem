import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Preferences'),
          _buildListTile(
            context,
            title: 'Dark Mode',
            icon: LucideIcons.moon,
            trailing: Switch(value: false, onChanged: (v) {}),
          ),
          _buildListTile(
            context,
            title: 'Emergency Alerts',
            icon: LucideIcons.bellRing,
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Account'),
          _buildListTile(context, title: 'Profile details', icon: LucideIcons.user),
          _buildListTile(context, title: 'Digital Donor Card', icon: LucideIcons.creditCard),
          
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About VitalPulse'),
          _buildListTile(context, title: 'Privacy Policy', icon: LucideIcons.shield),
          _buildListTile(context, title: 'Terms of Service', icon: LucideIcons.fileText),
          _buildListTile(context, title: 'App Version 1.0.0', icon: LucideIcons.info),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 20),
        onTap: trailing == null ? () {} : null,
      ),
    );
  }
}
