import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/blood_type.dart';
import '../models/patient_models.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../services/sos_alarm_service.dart';
import '../services/file_download_service.dart';

/// Top-level helper for opening Google Maps directions from any widget in this file.
Future<void> _launchGoogleMapsDirections(BuildContext context, String destinationName, String address, {double? lat, double? lng}) async {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Row(
        children: [
          const Icon(LucideIcons.navigation, color: AppTheme.skyBlue, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Opening Google Maps to $destinationName...',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );

  Uri uri;
  if (lat != null && lng != null) {
    final dest = Uri.encodeComponent('$destinationName, $address');
    uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$dest');
  } else {
    final dest = Uri.encodeComponent('$destinationName, $address');
    uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$dest');
  }

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  } catch (_) {
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {}
  }
}

class PatientDashboardScreen extends StatefulWidget {
  final int initialTab;
  const PatientDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _greenCorridorActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);
    final patient = mockService.patientProfile;
    final unreadNotifs = mockService.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF0F172A)),
          tooltip: 'Back to Home',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.skyBlueLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.activity, size: 16, color: AppTheme.skyBlue),
                  SizedBox(width: 6),
                  Text(
                    'PATIENT PORTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.skyBlueDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Patient Dashboard',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Emergency SOS Quick Header Badge
          if (mockService.activeEmergencySOS != null)
            GestureDetector(
              onTap: () => _switchTab(1),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRedLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SOS ACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Notifications shortcut
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Color(0xFF0F172A)),
                tooltip: 'Notifications',
                onPressed: () => _switchTab(9),
              ),
              if (unreadNotifs > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadNotifs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.userCircle, color: Color(0xFF0F172A)),
            tooltip: 'Profile & Settings',
            onPressed: () => _switchTab(10),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF475569),
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                indicator: BoxDecoration(
                  color: AppTheme.skyBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.skyBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: const [
                  Tab(icon: Icon(LucideIcons.layoutDashboard, size: 16), text: 'Overview'),
                  Tab(icon: Icon(LucideIcons.alertTriangle, size: 16), text: 'Emergency SOS'),
                  Tab(icon: Icon(LucideIcons.plusCircle, size: 16), text: 'Request Blood'),
                  Tab(icon: Icon(LucideIcons.sparkles, size: 16), text: 'Smart Matching'),
                  Tab(icon: Icon(LucideIcons.search, size: 16), text: 'Availability'),
                  Tab(icon: Icon(LucideIcons.activity, size: 16), text: 'Tracking'),
                  Tab(icon: Icon(LucideIcons.mapPin, size: 16), text: 'Nearby & Map'),
                  Tab(icon: Icon(LucideIcons.building2, size: 16), text: 'Live Hospitals'),
                  Tab(icon: Icon(LucideIcons.history, size: 16), text: 'History'),
                  Tab(icon: Icon(LucideIcons.bell, size: 16), text: 'Notifications'),
                  Tab(icon: Icon(LucideIcons.settings, size: 16), text: 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, mockService, patient),
          _buildEmergencySOSTab(context, mockService, patient),
          _buildRequestBloodTab(context, mockService, patient),
          _buildSmartMatchingTab(context, mockService, patient),
          _buildBloodAvailabilityTab(context, mockService),
          _buildRequestTrackingTab(context, mockService),
          _buildNearbyMapTab(context, mockService),
          _buildLiveHospitalsTab(context, mockService),
          _buildHistoryTab(context, mockService),
          _buildNotificationsTab(context, mockService),
          _buildSettingsTab(context, mockService, patient),
        ],
      ),
    );
  }

  // ================= 1. OVERVIEW TAB =================
  Widget _buildOverviewTab(
    BuildContext context,
    MockDataService mockService,
    PatientProfile patient,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Welcome & Identity Card (Compact iOS Card)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.skyBlueLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.user, size: 22, color: AppTheme.skyBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              patient.bloodType.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              patient.location,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Contact: ${patient.emergencyContactName} (${patient.emergencyContactRelation}) • ${patient.emergencyContactPhone}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.edit3, size: 18, color: AppTheme.skyBlue),
                  tooltip: 'Edit Profile',
                  onPressed: () => _showEditProfileDialog(context, mockService, patient),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // EMERGENCY SOS BANNER CARD (Compact)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryRed,
                  Color(0xFFEF4444),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.alertTriangle, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emergency Blood Need?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mockService.activeEmergencySOS != null
                            ? 'SOS Active: ${mockService.activeEmergencySOS!.id} (${mockService.activeEmergencySOS!.status.label})'
                            : 'Trigger 1-Tap SOS to broadcast to 14+ nearby compatible donors & 3 blood centers.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _switchTab(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    mockService.activeEmergencySOS != null ? 'View SOS' : 'Launch SOS',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // QUICK SHORTCUT CARDS (Compact Responsive Grid)
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 700 ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: MediaQuery.of(context).size.width < 700 ? 2.7 : 2.4,
            children: [
              _buildQuickCard(
                title: 'Request Blood',
                subtitle: 'Submit new requisition',
                icon: LucideIcons.plusCircle,
                iconColor: AppTheme.primaryRed,
                onTap: () => _switchTab(2),
              ),
              _buildQuickCard(
                title: 'Smart Matching',
                subtitle: '${mockService.smartDonors.length} compatible donors',
                icon: LucideIcons.sparkles,
                iconColor: AppTheme.skyBlue,
                onTap: () => _switchTab(3),
              ),
              _buildQuickCard(
                title: 'Track Request',
                subtitle: '${mockService.patientRequests.length} tracked items',
                icon: LucideIcons.activity,
                iconColor: const Color(0xFF10B981),
                onTap: () => _switchTab(5),
              ),
              _buildQuickCard(
                title: 'Nearby Banks & Camps',
                subtitle: '${mockService.nearbyFacilities.length} locations mapped',
                icon: LucideIcons.mapPin,
                iconColor: const Color(0xFF8B5CF6),
                onTap: () => _switchTab(6),
              ),
              _buildQuickCard(
                title: 'Live Indian Hospitals',
                subtitle: '${mockService.indianHospitals.length} hospitals & routes',
                icon: LucideIcons.building2,
                iconColor: const Color(0xFF0EA5E9),
                onTap: () => _switchTab(7),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ACTIVE REQUEST TRACKING PREVIEW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Blood Requests',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => _switchTab(5),
                child: const Text('View All Tracking →', style: TextStyle(color: AppTheme.skyBlue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (mockService.patientRequests.isNotEmpty)
            _buildRequestCard(context, mockService.patientRequests.first, mockService)
          else
            _buildEmptyState('No active blood requests.', LucideIcons.inbox),

          const SizedBox(height: 28),

          // TOP SMART MATCHES PREVIEW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Matched Donors For You',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => _switchTab(3),
                child: const Text('See All Donors →', style: TextStyle(color: AppTheme.skyBlue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...mockService.smartDonors.take(2).map((donor) => _buildDonorMatchCard(context, donor, mockService)),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 2. EMERGENCY SOS TAB =================
  Widget _buildEmergencySOSTab(
    BuildContext context,
    MockDataService mockService,
    PatientProfile patient,
  ) {
    final activeSOS = mockService.activeEmergencySOS;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── CRITICAL EMERGENCY HEADER WITH TRIAGE INFO ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRedLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shieldAlert, color: AppTheme.primaryRed, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'TRAUMA RED CODE • PRIORITY ALPHA',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Emergency Blood Dispatch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Immediate Massive Transfusion Protocol (MTP)',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Triggers maximum priority broadcast to all nearby verified donors, certified blood centers, and hospital trauma desks within a 10 km radius.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 28),

                // Giant Pulsing SOS Button with glow rings
                GestureDetector(
                  onTap: () {
                    // Play emergency siren alarm for 5 seconds
                    SOSAlarmService().playAlarm(durationSeconds: 5);
                    if (activeSOS == null) {
                      _showTriggerSOSModal(context, mockService, patient);
                    } else {
                      mockService.advanceSOSStatus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primaryRed,
                          content: Row(
                            children: [
                              const Icon(LucideIcons.activity, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text('Status Advanced: ${activeSOS.status.label.toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFFFF4D4D),
                          Color(0xFFDC2626),
                          Color(0xFF991B1B),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withValues(alpha: 0.25),
                          blurRadius: 40,
                          spreadRadius: 12,
                        ),
                        BoxShadow(
                          color: AppTheme.primaryRed.withValues(alpha: 0.15),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 36),
                          const SizedBox(height: 6),
                          Text(
                            activeSOS == null ? 'TRIGGER\nSOS' : 'ADVANCE\nSTATUS',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                if (activeSOS != null) ...[
                  // Status badges
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRedLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              'ID: ${activeSOS.id}',
                              style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.skyBlueLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'STATUS: ${activeSOS.status.label.toUpperCase()}',
                          style: const TextStyle(color: AppTheme.skyBlueDark, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ETA: ~8 MIN',
                          style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Icon(LucideIcons.alertTriangle, color: AppTheme.primaryRed, size: 22),
                              SizedBox(width: 10),
                              Text('Cancel Emergency SOS?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
                          ),
                          content: const Text(
                            'This will halt the emergency dispatch, un-notify all alerted donors and blood banks, and close the active trauma protocol. This action cannot be undone.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Keep Active', style: TextStyle(color: Color(0xFF64748B))),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                mockService.cancelEmergencySOS();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF0F172A),
                                    content: Text('Emergency SOS cancelled. All broadcasts halted.'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                              child: const Text('Cancel SOS'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.xCircle, color: Colors.red, size: 16),
                    label: const Text('Cancel Active SOS Broadcast', style: TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ] else ...[
                  const Text(
                    'Tap the button to initiate a new emergency blood dispatch',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── LIVE BROADCAST RADAR (always visible when SOS active) ──
          if (activeSOS != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.radio, color: AppTheme.primaryRed, size: 18),
                      SizedBox(width: 8),
                      Text('Live Emergency Broadcast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Donor/Bank ping status tiles
                  Row(
                    children: [
                      Expanded(
                        child: _buildSOSMetric(
                          icon: LucideIcons.users,
                          color: AppTheme.skyBlue,
                          value: '${activeSOS.matchedDonorsCount}',
                          label: 'Donors Alerted',
                          sublabel: 'Within 5 km radius',
                          onTap: () => _showMatchedDonorsSheet(context, mockService, activeSOS),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSOSMetric(
                          icon: LucideIcons.landmark,
                          color: const Color(0xFF10B981),
                          value: '${activeSOS.nearbyBanksCount}',
                          label: 'Banks Notified',
                          sublabel: 'Cross-matched stock',
                          onTap: () => _showNotifiedBanksSheet(context, mockService, activeSOS),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSOSMetric(
                          icon: LucideIcons.building2,
                          color: const Color(0xFFF59E0B),
                          value: '2',
                          label: 'Hospitals Ready',
                          sublabel: 'Trauma teams ready',
                          onTap: () => _showHospitalStandbySheet(context, mockService, activeSOS),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Emergency response timeline
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildTimelineStep('SOS Broadcast Initiated', 'Sent to all compatible donors & banks', true, AppTheme.primaryRed),
                        _buildTimelineStep('Donor Responses Received', '${activeSOS.matchedDonorsCount > 3 ? 3 : activeSOS.matchedDonorsCount} donors accepted, en route', activeSOS.matchedDonorsCount > 0, const Color(0xFF10B981)),
                        _buildTimelineStep('Blood Bank Reservation', 'Units reserved at nearest certified bank', activeSOS.nearbyBanksCount > 0, AppTheme.skyBlue),
                        _buildTimelineStep('Hospital Trauma Team Alert', 'ER & transfusion team notified', true, const Color(0xFFF59E0B)),
                        _buildTimelineStep('Dispatch In Progress', 'Estimated arrival: 8–12 minutes', activeSOS.status.label != 'Searching', const Color(0xFF8B5CF6)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── SOS DISPATCH PARAMETERS CARD ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dispatch Parameters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Hospital & Department', activeSOS.hospital, LucideIcons.building),
                  _buildDetailRow('Location / Ward', activeSOS.location, LucideIcons.mapPin),
                  _buildDetailRow('Blood Group & Units', '${activeSOS.bloodType.label} • ${activeSOS.unitsRequired} Units (${(activeSOS.unitsRequired * 450).toStringAsFixed(0)} ml)', LucideIcons.droplet),
                  _buildDetailRow('Matched Donors', '${activeSOS.matchedDonorsCount} Compatible Donors in Range', LucideIcons.users),
                  _buildDetailRow('Blood Centers', '${activeSOS.nearbyBanksCount} Facilities Cross-Matched', LucideIcons.landmark),
                  _buildDetailRow('Protocol', 'Massive Transfusion Protocol (MTP)', LucideIcons.shieldCheck),
                  if (activeSOS.notes != null)
                    _buildDetailRow('Clinical Notes', activeSOS.notes!, LucideIcons.fileText),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final telUri = Uri.parse('tel:+91407442000');
                            try {
                              await launchUrl(telUri, mode: LaunchMode.externalApplication);
                            } catch (_) {
                              try { await launchUrl(telUri); } catch (_) {}
                            }
                            if (!context.mounted) return;
                            _showHospitalStandbySheet(context, mockService, activeSOS);
                          },
                          icon: const Icon(LucideIcons.phoneCall, size: 15, color: AppTheme.skyBlue),
                          label: const Text('Call Hospital', style: TextStyle(color: AppTheme.skyBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.skyBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            FileDownloadService.downloadSOSIncidentReport(activeSOS, patient);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.black,
                                content: Text('MTP Incident Log (VitalPulse_EmergencySOS_Incident_${activeSOS.id}.html) downloaded!'),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.download, size: 15, color: AppTheme.primaryRed),
                          label: const Text('Download Log', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryRed),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            mockService.advanceSOSStatus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.skyBlue,
                                content: Text('Status Advanced: ${activeSOS.status.label.toUpperCase()}'),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.arrowRight, size: 15),
                          label: const Text('Advance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.skyBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── EMERGENCY HOTLINES (always visible) ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.phone, color: AppTheme.primaryRed, size: 18),
                    SizedBox(width: 8),
                    Text('Emergency Hotlines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Tap to instantly connect with emergency services', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildHotlineButton('108', 'Ambulance', LucideIcons.siren, AppTheme.primaryRed)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildHotlineButton('112', 'Emergency', LucideIcons.shieldAlert, const Color(0xFFF59E0B))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildHotlineButton('1800', 'VitalPulse', LucideIcons.heartPulse, AppTheme.skyBlue)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── GREEN CORRIDOR ACTIVATION ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _greenCorridorActive ? const Color(0xFFECFDF5) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _greenCorridorActive ? const Color(0xFF10B981) : const Color(0xFFBBF7D0), width: _greenCorridorActive ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.route, color: _greenCorridorActive ? const Color(0xFF059669) : const Color(0xFF16A34A), size: 18),
                        const SizedBox(width: 8),
                        const Text('Green Corridor Protocol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    if (_greenCorridorActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('ACTIVE & CLEAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _greenCorridorActive
                      ? 'Traffic clearance ACTIVE across 4 junctions. Transit time reduced from 24m to 8m.'
                      : 'Request traffic clearance for emergency blood transport from nearest blood bank to hospital.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _greenCorridorActive = !_greenCorridorActive;
                      });
                      if (_greenCorridorActive) {
                        _showGreenCorridorLiveModal(context, activeSOS?.hospital ?? 'Apollo Multi-Specialty Hospital Jubilee Hills');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF0F172A),
                            content: Text('Green Corridor Protocol Deactivated.'),
                          ),
                        );
                      }
                    },
                    icon: Icon(_greenCorridorActive ? LucideIcons.checkCircle2 : LucideIcons.zap, size: 16),
                    label: Text(_greenCorridorActive ? 'Manage Green Corridor / Route Radar' : 'Activate Green Corridor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _greenCorridorActive ? const Color(0xFF059669) : const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── EMERGENCY GUIDELINES ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.info, color: Color(0xFFD97706), size: 18),
                    SizedBox(width: 8),
                    Text('Emergency Guidelines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                  ],
                ),
                SizedBox(height: 10),
                Text('• Ensure patient blood group is verified before triggering SOS', style: TextStyle(fontSize: 12, color: Color(0xFF78350F))),
                SizedBox(height: 4),
                Text('• Cross-matching takes 15–30 minutes; O-negative is universal donor', style: TextStyle(fontSize: 12, color: Color(0xFF78350F))),
                SizedBox(height: 4),
                Text('• Keep attending physician contact details ready', style: TextStyle(fontSize: 12, color: Color(0xFF78350F))),
                SizedBox(height: 4),
                Text('• False SOS alerts may result in account suspension', style: TextStyle(fontSize: 12, color: Color(0xFF78350F))),
                SizedBox(height: 4),
                Text('• Green Corridor is available only in supported metro cities', style: TextStyle(fontSize: 12, color: Color(0xFF78350F))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SOS helper widgets ──
  Widget _buildSOSMetric({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required String sublabel,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
            Text(sublabel, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
            if (onTap != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TAP TO VIEW',
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isActive, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive ? color : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? LucideIcons.check : LucideIcons.clock,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
              size: 12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8))),
                Text(subtitle, style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF64748B) : const Color(0xFFCBD5E1))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineButton(String number, String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () async {
        final clean = number.replaceAll('-', '').replaceAll(' ', '');
        final telUri = Uri.parse('tel:$clean');
        try {
          await launchUrl(telUri, mode: LaunchMode.externalApplication);
        } catch (_) {
          try { await launchUrl(telUri); } catch (_) {}
        }
        if (!mounted) return;
        _showEmergencyHotlineDispatchDialog(context, number, label, color);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(number, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  void _showMatchedDonorsSheet(BuildContext context, MockDataService mockService, EmergencySOSRequest? sos) {
    final donors = mockService.smartDonors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppTheme.skyBlueLight, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.users, color: AppTheme.skyBlue, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('Alerted Emergency Donors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Broadcast dispatched to ${donors.length} compatible ${sos?.bloodType.label ?? "O-"} donors within 5 km', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: donors.length,
                  itemBuilder: (context, i) {
                    final d = donors[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryRedLight,
                            child: Text(d.bloodType.label, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black)),
                                Text('${d.distanceKm} km away • ${d.availability} • Match: ${d.matchPercentage}%', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('● EN ROUTE / ACCEPTED', style: TextStyle(color: Color(0xFF15803D), fontSize: 9.5, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.phoneCall, color: Color(0xFF0284C7), size: 18),
                                tooltip: 'Call Donor',
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final telUri = Uri.parse('tel:${d.phone.replaceAll(' ', '')}');
                                  try {
                                    await launchUrl(telUri, mode: LaunchMode.externalApplication);
                                  } catch (_) {
                                    try { await launchUrl(telUri); } catch (_) {}
                                  }
                                  messenger.showSnackBar(SnackBar(content: Text('Connecting to donor ${d.name}...')));
                                },
                              ),
                              IconButton(
                                icon: const Icon(LucideIcons.messageSquare, color: Color(0xFF10B981), size: 18),
                                tooltip: 'Message Donor',
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final smsUri = Uri.parse('sms:${d.phone.replaceAll(' ', '')}?body=${Uri.encodeComponent("VitalPulse SOS: Need ${sos?.bloodType.label ?? "blood"} urgently at ${sos?.hospital ?? "Hospital"}")}');
                                  try {
                                    await launchUrl(smsUri, mode: LaunchMode.externalApplication);
                                  } catch (_) {
                                    try { await launchUrl(smsUri); } catch (_) {}
                                  }
                                  messenger.showSnackBar(SnackBar(content: Text('SMS prompt opened for ${d.name}')));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotifiedBanksSheet(BuildContext context, MockDataService mockService, EmergencySOSRequest? sos) {
    final banks = mockService.nearbyFacilities.where((f) => f.type == FacilityType.bloodBank || f.type == FacilityType.hospital).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.landmark, color: Color(0xFF16A34A), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text('Notified Blood Centers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Cross-matched inventory reserved for SOS ID: ${sos?.id ?? "VP-SOS-9912"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: banks.length,
                  itemBuilder: (context, i) {
                    final b = banks[i];
                    final units = b.stock[sos?.bloodType ?? BloodType.oNeg] ?? (b.stock.values.isNotEmpty ? b.stock.values.reduce((a, c) => a + c) : 8);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(b.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                                child: Text('${b.distanceKm} km away', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(b.address, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                child: Text('Available: $units Units', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _launchGoogleMapsDirections(context, b.name, b.address, lat: b.latitude, lng: b.longitude);
                                },
                                icon: const Icon(LucideIcons.navigation, size: 14, color: Color(0xFF0284C7)),
                                label: const Text('Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(LucideIcons.phone, size: 16, color: Colors.black),
                                tooltip: 'Call Center',
                                onPressed: () async {
                                  final telUri = Uri.parse('tel:${b.phone.replaceAll(' ', '')}');
                                  try { await launchUrl(telUri, mode: LaunchMode.externalApplication); } catch (_) { try { await launchUrl(telUri); } catch (_) {} }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHospitalStandbySheet(BuildContext context, MockDataService mockService, EmergencySOSRequest? sos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.building2, color: Color(0xFFD97706), size: 22),
                      SizedBox(width: 10),
                      Text('Hospital Trauma Desk Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFDE68A))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.shieldCheck, color: Color(0xFFB45309), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sos?.hospital ?? 'Apollo Multi-Specialty Hospital Jubilee Hills',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Attending Surgeon: Dr. Radhika Menon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF78350F))),
                        Text('ER Bay: #04 (ICU)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final telUri = Uri.parse('tel:+91407442000');
                    try { await launchUrl(telUri, mode: LaunchMode.externalApplication); } catch (_) { try { await launchUrl(telUri); } catch (_) {} }
                  },
                  icon: const Icon(LucideIcons.phoneCall, size: 16),
                  label: const Text('Connect to ER Trauma Desk Hotline', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmergencyHotlineDispatchDialog(BuildContext context, String number, String label, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.phoneCall, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text('Emergency: $label ($number)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connecting your call to National $label Control Desk ($number).', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 16, color: color),
                      const SizedBox(width: 6),
                      Text('Auto-Telemetry Dispatched', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('• Live GPS Coordinates Transmitted to Dispatcher', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                  const Text('• Patient Blood Group & Medical ID Tagged', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                  const Text('• Nearest Paramedic Unit #AMB-782 Alerted', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx);
              _switchTab(6); // Switch to Nearby Map tab
            },
            icon: const Icon(LucideIcons.mapPin, size: 14),
            label: const Text('View On Live Radar', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showGreenCorridorLiveModal(BuildContext context, String hospitalName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.route, color: Color(0xFF16A34A), size: 24),
                      SizedBox(width: 10),
                      Text('Green Corridor Clearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Traffic Control Desk: Hyderabad West', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                        Text('SIGNAL SYNC: 100%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('4 Traffic Junctions Synchronized • Route from Blood Bank to Hospital cleared for emergency siren convoy.', style: TextStyle(fontSize: 12, color: Color(0xFF14532D))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _launchGoogleMapsDirections(context, hospitalName, 'Jubilee Hills, Hyderabad');
                      },
                      icon: const Icon(LucideIcons.navigation, size: 16, color: Color(0xFF16A34A)),
                      label: const Text('Open Route in Maps', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF16A34A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep Active', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.skyBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 3. REQUEST BLOOD TAB =================
  Widget _buildRequestBloodTab(
    BuildContext context,
    MockDataService mockService,
    PatientProfile patient,
  ) {
    return _BloodRequestForm(patient: patient);
  }

  // ================= 4. SMART DONOR MATCHING TAB =================
  Widget _buildSmartMatchingTab(
    BuildContext context,
    MockDataService mockService,
    PatientProfile patient,
  ) {
    final donors = mockService.smartDonors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.skyBlueLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.sparkles, color: AppTheme.skyBlue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Smart Donor Matching',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compatible with patient blood group (${patient.bloodType.label}). Ranked by proximity, health eligibility & availability.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Matches (${donors.length})',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Radius: 10 km',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...donors.map((donor) => _buildDonorMatchCard(context, donor, mockService)),
        ],
      ),
    );
  }

  Widget _buildDonorMatchCard(
    BuildContext context,
    DonorMatch donor,
    MockDataService mockService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRedLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    donor.bloodType.label,
                    style: const TextStyle(
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          donor.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: donor.availability == 'Available Now'
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            donor.availability,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: donor.availability == 'Available Now'
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${donor.distanceKm} km away • ${donor.city}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // Match Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.skyBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${donor.matchPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'MATCH',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Eligibility Tag
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    donor.eligibility,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${donor.name}: ${donor.phone}')),
                    );
                  },
                  icon: const Icon(LucideIcons.phone, size: 14, color: AppTheme.skyBlue),
                  label: const Text('Contact', style: TextStyle(color: AppTheme.skyBlue, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.skyBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request dispatched to ${donor.name}!')),
                    );
                  },
                  icon: const Icon(LucideIcons.send, size: 14),
                  label: const Text('Send Request', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 5. BLOOD AVAILABILITY SEARCH TAB =================
  Widget _buildBloodAvailabilityTab(BuildContext context, MockDataService mockService) {
    return _BloodAvailabilitySearchWidget(mockService: mockService);
  }

  // ================= 6. REQUEST TRACKING TAB =================
  Widget _buildRequestTrackingTab(BuildContext context, MockDataService mockService) {
    final requests = mockService.patientRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Request Tracking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plus, color: AppTheme.skyBlue),
                tooltip: 'New Request',
                onPressed: () => _switchTab(2),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Track each step from submission, matching, blood reservation to fulfillment.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          if (requests.isEmpty)
            _buildEmptyState('No active blood requests to track.', LucideIcons.search)
          else
            ...requests.map((r) => _buildRequestCard(context, r, mockService)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    PatientBloodRequestItem request,
    MockDataService mockService,
  ) {
    final steps = [
      PatientTrackingStatus.pending,
      PatientTrackingStatus.searching,
      PatientTrackingStatus.donorMatched,
      PatientTrackingStatus.bloodReserved,
      PatientTrackingStatus.fulfilled,
    ];

    final currentIndex = steps.indexOf(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.bloodType.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${request.units} Units • ${request.hospital}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: request.priority == RequestPriority.emergency
                      ? AppTheme.primaryRedLight
                      : (request.priority == RequestPriority.urgent
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.priority.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: request.priority == RequestPriority.emergency
                        ? AppTheme.primaryRed
                        : (request.priority == RequestPriority.urgent
                            ? const Color(0xFFD97706)
                            : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Request ID: ${request.id} • Needed by: ${request.requiredDateTime.day}/${request.requiredDateTime.month} ${request.requiredDateTime.hour}:${request.requiredDateTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),

          if (request.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              'Notes: ${request.notes}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ],

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 5-Stage Visual Stepper
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                final isDone = currentIndex >= i && request.status != PatientTrackingStatus.cancelled;
                final isCurrent = currentIndex == i && request.status != PatientTrackingStatus.cancelled;

                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppTheme.skyBlue
                                : (isDone ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent ? AppTheme.skyBlue : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 36,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: currentIndex > i ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          // Simulation & Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Current Status: ${request.status.label}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Cycle next status for testing
                    final nextIndex = (currentIndex + 1) % steps.length;
                    mockService.updateRequestStatus(request.id, steps[nextIndex]);
                  },
                  icon: const Icon(LucideIcons.playCircle, size: 14, color: AppTheme.skyBlue),
                  label: const Text('Simulate Next Status', style: TextStyle(color: AppTheme.skyBlue, fontSize: 12)),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(LucideIcons.download, size: 16, color: Color(0xFF0F172A)),
                  tooltip: 'Download Requisition Slip',
                  onPressed: () {
                    FileDownloadService.downloadPatientRequisitionSlip(request, mockService.patientProfile);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black,
                        content: Text('Requisition Slip (VitalPulse_BloodRequisition_${request.id}.html) downloaded & saved!'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                  tooltip: 'Cancel Request',
                  onPressed: () {
                    mockService.updateRequestStatus(request.id, PatientTrackingStatus.cancelled);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request ${request.id} Cancelled')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 7. NEARBY LOCATIONS & MOCK MAP TAB =================
  Widget _buildNearbyMapTab(BuildContext context, MockDataService mockService) {
    return _NearbyLocationsMapWidget(mockService: mockService);
  }

  // ================= 8. LIVE HOSPITALS & ROUTE NAVIGATION TAB =================
  Widget _buildLiveHospitalsTab(BuildContext context, MockDataService mockService) {
    return _LiveIndianHospitalsWidget(mockService: mockService);
  }

  // ================= 9. HISTORY TAB =================
  Widget _buildHistoryTab(BuildContext context, MockDataService mockService) {
    return _PatientHistoryWidget(mockService: mockService);
  }

  // ================= 9. NOTIFICATIONS TAB =================
  Widget _buildNotificationsTab(BuildContext context, MockDataService mockService) {
    return _PatientNotificationsWidget(mockService: mockService);
  }

  // ================= 10. SETTINGS & PROFILE TAB =================
  Widget _buildSettingsTab(
    BuildContext context,
    MockDataService mockService,
    PatientProfile patient,
  ) {
    return _PatientSettingsWidget(mockService: mockService, patient: patient);
  }

  // ================= HELPER MODALS & DIALOGS =================

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        ],
      ),
    );
  }

  void _showTriggerSOSModal(BuildContext context, MockDataService mockService, PatientProfile patient) {
    final hospitalController = TextEditingController(text: 'Memorial General Trauma Center');
    final locationController = TextEditingController(text: patient.location);
    BloodType selectedType = patient.bloodType;
    int units = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dispatch Emergency SOS',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital & Department',
                      prefixIcon: Icon(LucideIcons.building, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Location / Bed / Ward',
                      prefixIcon: Icon(LucideIcons.mapPin, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<BloodType>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(labelText: 'Blood Group'),
                          items: BloodType.values.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t.label));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedType = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Units Required', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minusCircle),
                                  onPressed: units > 1 ? () => setModalState(() => units--) : null,
                                ),
                                Text('$units Units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(LucideIcons.plusCircle),
                                  onPressed: units < 10 ? () => setModalState(() => units++) : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Play emergency siren alarm for 5 seconds
                        SOSAlarmService().playAlarm(durationSeconds: 5);
                        mockService.triggerEmergencySOS(
                          hospital: hospitalController.text,
                          location: locationController.text,
                          bloodType: selectedType,
                          units: units,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppTheme.primaryRed,
                            content: Text('EMERGENCY SOS DISPATCHED TO 14 DONORS & 3 BLOOD BANKS'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.alertTriangle),
                      label: const Text('BROADCAST EMERGENCY SOS NOW'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, MockDataService mockService, PatientProfile patient) {
    final nameCtrl = TextEditingController(text: patient.name);
    final phoneCtrl = TextEditingController(text: patient.phone);
    final emailCtrl = TextEditingController(text: patient.email);
    final locCtrl = TextEditingController(text: patient.location);
    final ecNameCtrl = TextEditingController(text: patient.emergencyContactName);
    final ecRelCtrl = TextEditingController(text: patient.emergencyContactRelation);
    final ecPhoneCtrl = TextEditingController(text: patient.emergencyContactPhone);
    BloodType bloodType = patient.bloodType;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Edit Patient Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<BloodType>(
                      initialValue: bloodType,
                      decoration: const InputDecoration(labelText: 'Blood Group'),
                      items: BloodType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => bloodType = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                    const SizedBox(height: 10),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                    const SizedBox(height: 10),
                    TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location / City')),
                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(height: 6),
                    TextField(controller: ecNameCtrl, decoration: const InputDecoration(labelText: 'Contact Name')),
                    const SizedBox(height: 10),
                    TextField(controller: ecRelCtrl, decoration: const InputDecoration(labelText: 'Relationship (e.g. Spouse)')),
                    const SizedBox(height: 10),
                    TextField(controller: ecPhoneCtrl, decoration: const InputDecoration(labelText: 'Emergency Phone')),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    mockService.updatePatientProfile(
                      patient.copyWith(
                        name: nameCtrl.text,
                        bloodType: bloodType,
                        phone: phoneCtrl.text,
                        email: emailCtrl.text,
                        location: locCtrl.text,
                        emergencyContactName: ecNameCtrl.text,
                        emergencyContactRelation: ecRelCtrl.text,
                        emergencyContactPhone: ecPhoneCtrl.text,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Patient Profile Updated Successfully!')),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ================= BLOOD REQUEST FORM WIDGET =================
class _BloodRequestForm extends StatefulWidget {
  final PatientProfile patient;
  const _BloodRequestForm({required this.patient});

  @override
  State<_BloodRequestForm> createState() => _BloodRequestFormState();
}

class _BloodRequestFormState extends State<_BloodRequestForm> {
  late BloodType _bloodType;
  int _units = 2;
  final _hospitalController = TextEditingController(text: 'Memorial General Hospital');
  final _notesController = TextEditingController();
  DateTime _requiredDateTime = DateTime.now().add(const Duration(hours: 12));
  RequestPriority _priority = RequestPriority.urgent;

  @override
  void initState() {
    super.initState();
    _bloodType = widget.patient.bloodType;
  }

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.plusCircle, color: AppTheme.skyBlue, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Request Blood Requisition',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fill in blood requirements for automated donor matching and bank reservations.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const Divider(height: 28),

                // Blood Group & Units Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Required Blood Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<BloodType>(
                            initialValue: _bloodType,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(LucideIcons.droplet, size: 18, color: AppTheme.primaryRed),
                            ),
                            items: BloodType.values.map((t) {
                              return DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _bloodType = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Number of Units', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: _units > 1 ? () => setState(() => _units--) : null,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: _units > 1 ? AppTheme.skyBlue.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(LucideIcons.minus, size: 16, color: _units > 1 ? AppTheme.skyBlue : const Color(0xFF94A3B8)),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '$_units',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.black),
                                        ),
                                        Text(
                                          'Units',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black.withValues(alpha: 0.6)),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _units < 10 ? () => setState(() => _units++) : null,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: _units < 10 ? AppTheme.skyBlue.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(LucideIcons.plus, size: 16, color: _units < 10 ? AppTheme.skyBlue : const Color(0xFF94A3B8)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Approx. ${(_units * 450)} ml total volume',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                // Hospital Input
                const Text('Hospital / Medical Center', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _hospitalController,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Enter Hospital Name, Wing, and City',
                    prefixIcon: Icon(LucideIcons.building, size: 18, color: AppTheme.skyBlue),
                  ),
                ),

                const SizedBox(height: 18),
                // Required Date & Time Picker
                const Text('Required Date & Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _requiredDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_requiredDateTime),
                      );
                      if (time != null) {
                        setState(() {
                          _requiredDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 18, color: AppTheme.skyBlue),
                        const SizedBox(width: 12),
                        Text(
                          '${_requiredDateTime.day}/${_requiredDateTime.month}/${_requiredDateTime.year} at ${_requiredDateTime.hour}:${_requiredDateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        const Text('Change', style: TextStyle(color: AppTheme.skyBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                // Priority Selector
                const Text('Priority Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Row(
                  children: RequestPriority.values.map((p) {
                    final isSelected = _priority == p;
                    Color color;
                    if (p == RequestPriority.emergency) {
                      color = AppTheme.primaryRed;
                    } else if (p == RequestPriority.urgent) {
                      color = const Color(0xFFF59E0B);
                    } else {
                      color = const Color(0xFF10B981);
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),
                // Additional Notes
                const Text('Additional Notes / Physician Directives', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Scheduled for surgical operation at 2:00 PM. Cross-match required.',
                  ),
                ),

                const SizedBox(height: 24),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newReq = PatientBloodRequestItem(
                        id: 'REQ-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}',
                        bloodType: _bloodType,
                        units: _units,
                        hospital: _hospitalController.text.trim().isEmpty ? 'General Hospital' : _hospitalController.text,
                        requiredDateTime: _requiredDateTime,
                        priority: _priority,
                        notes: _notesController.text.trim().isEmpty ? null : _notesController.text,
                        status: PatientTrackingStatus.searching,
                        createdAt: DateTime.now(),
                      );
                      mockService.addPatientBloodRequest(newReq);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request ${newReq.id} submitted & live tracking started!')),
                      );
                      _notesController.clear();
                    },
                    icon: const Icon(LucideIcons.checkCheck),
                    label: const Text('SUBMIT BLOOD REQUEST'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= BLOOD AVAILABILITY SEARCH WIDGET =================
class _BloodAvailabilitySearchWidget extends StatefulWidget {
  final MockDataService mockService;
  const _BloodAvailabilitySearchWidget({required this.mockService});

  @override
  State<_BloodAvailabilitySearchWidget> createState() => _BloodAvailabilitySearchWidgetState();
}

class _BloodAvailabilitySearchWidgetState extends State<_BloodAvailabilitySearchWidget> {
  BloodType? _filterBloodType;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final facilities = widget.mockService.nearbyFacilities;

    // Filter results
    final filtered = facilities.where((f) {
      if (f.type == FacilityType.donationCamp) return false;
      final matchesSearch = _searchController.text.isEmpty ||
          f.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          f.address.toLowerCase().contains(_searchController.text.toLowerCase());

      if (_filterBloodType == null) return matchesSearch;
      final hasStock = (f.stock[_filterBloodType!] ?? 0) > 0;
      return matchesSearch && hasStock;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Blood Stock & Inventory',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by city, hospital, or blood bank...',
                    prefixIcon: const Icon(LucideIcons.search, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Select Blood Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: const Text('All Types'),
                          selected: _filterBloodType == null,
                          onSelected: (selected) {
                            setState(() => _filterBloodType = null);
                          },
                        ),
                      ),
                      ...BloodType.values.map((type) {
                        final isSel = _filterBloodType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(type.label),
                            selected: isSel,
                            selectedColor: AppTheme.skyBlue,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (selected) {
                              setState(() => _filterBloodType = selected ? type : null);
                              if (selected) {
                                widget.mockService.addSearchHistoryItem(type, _searchController.text, filtered.length);
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Found Results (${filtered.length} Centers)',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(LucideIcons.alertCircle, size: 36, color: Color(0xFF94A3B8)),
                  SizedBox(height: 8),
                  Text('No blood banks match your search criteria.', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            )
          else
            ...filtered.map((bank) => _buildBankAvailabilityCard(context, bank, _filterBloodType)),
        ],
      ),
    );
  }

  Widget _buildBankAvailabilityCard(BuildContext context, NearbyFacility facility, BloodType? filterType) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: facility.type == FacilityType.bloodBank
                      ? AppTheme.skyBlueLight
                      : AppTheme.primaryRedLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  facility.type == FacilityType.bloodBank ? LucideIcons.landmark : LucideIcons.building2,
                  color: facility.type == FacilityType.bloodBank ? AppTheme.skyBlue : AppTheme.primaryRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${facility.distanceKm} km away • ${facility.address}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.star, size: 12, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      '${facility.rating}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Stock Inventory Pills
          const Text('Available Units by Blood Group:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: facility.stock.entries.map((entry) {
              final isHighlighted = filterType != null && filterType == entry.key;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighlighted ? AppTheme.skyBlue : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${entry.key.label}: ${entry.value}u',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${facility.name}: ${facility.phone}')),
                    );
                  },
                  icon: const Icon(LucideIcons.phone, size: 14, color: AppTheme.skyBlue),
                  label: const Text('Call Bank', style: TextStyle(color: AppTheme.skyBlue, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.skyBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchGoogleMapsDirections(
                      context,
                      facility.name,
                      facility.address,
                      lat: facility.latitude,
                      lng: facility.longitude,
                    );
                  },
                  icon: const Icon(LucideIcons.navigation, size: 14),
                  label: const Text('Directions', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= NEARBY LOCATIONS & MOCK MAP WIDGET =================
class _NearbyLocationsMapWidget extends StatefulWidget {
  final MockDataService mockService;
  const _NearbyLocationsMapWidget({required this.mockService});

  @override
  State<_NearbyLocationsMapWidget> createState() => _NearbyLocationsMapWidgetState();
}

class _NearbyLocationsMapWidgetState extends State<_NearbyLocationsMapWidget> {
  int _selectedTypeIndex = 0; // 0: All, 1: Blood Banks, 2: Hospitals, 3: Camps

  @override
  Widget build(BuildContext context) {
    final allFacilities = widget.mockService.nearbyFacilities;

    final filtered = allFacilities.where((f) {
      if (_selectedTypeIndex == 1) return f.type == FacilityType.bloodBank;
      if (_selectedTypeIndex == 2) return f.type == FacilityType.hospital;
      if (_selectedTypeIndex == 3) return f.type == FacilityType.donationCamp;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Interactive Map Canvas
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80'),
                fit: BoxFit.cover,
                opacity: 0.75,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.mapPin, size: 14, color: AppTheme.skyBlue),
                        SizedBox(width: 4),
                        Text('Live Mock Map & GPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryRed.withValues(alpha: 0.6),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.user, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('You Are Here (New York, NY)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Open Google Maps to nearest blood bank
                      final facilities = widget.mockService.nearbyFacilities;
                      final nearest = facilities.isNotEmpty ? facilities.first : null;
                      if (nearest != null) {
                        _launchGoogleMapsDirections(
                          context,
                          nearest.name,
                          nearest.address,
                          lat: nearest.latitude,
                          lng: nearest.longitude,
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.navigation, size: 14),
                    label: const Text('Find Fast Route', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Filter Segment
          Row(
            children: [
              _buildTypeChip('All Facilities', 0),
              const SizedBox(width: 8),
              _buildTypeChip('Blood Banks', 1),
              const SizedBox(width: 8),
              _buildTypeChip('Hospitals', 2),
              const SizedBox(width: 8),
              _buildTypeChip('Camps', 3),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            'Nearby Centers (${filtered.length})',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          ...filtered.map((fac) => _buildFacilityCard(context, fac)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, int index) {
    final isSel = _selectedTypeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTypeIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppTheme.skyBlue : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                color: isSel ? Colors.white : const Color(0xFF475569),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityCard(BuildContext context, NearbyFacility facility) {
    IconData icon;
    Color color;
    String typeLabel;

    switch (facility.type) {
      case FacilityType.bloodBank:
        icon = LucideIcons.landmark;
        color = AppTheme.skyBlue;
        typeLabel = 'Blood Bank';
        break;
      case FacilityType.hospital:
        icon = LucideIcons.building2;
        color = AppTheme.primaryRed;
        typeLabel = 'Hospital / ER';
        break;
      case FacilityType.donationCamp:
        icon = LucideIcons.tent;
        color = const Color(0xFF10B981);
        typeLabel = 'Donation Camp';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facility.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${facility.distanceKm} km • ${facility.address}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                facility.eventDate != null ? 'Dates: ${facility.eventDate!} (${facility.openHours})' : facility.openHours,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling: ${facility.phone}')),
                    );
                  },
                  icon: const Icon(LucideIcons.phone, size: 14, color: AppTheme.skyBlue),
                  label: const Text('Contact', style: TextStyle(color: AppTheme.skyBlue, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.skyBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _launchGoogleMapsDirections(
                      context,
                      facility.name,
                      facility.address,
                      lat: facility.latitude,
                      lng: facility.longitude,
                    );
                  },
                  icon: const Icon(LucideIcons.map, size: 14),
                  label: const Text('Get Directions', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= LIVE INDIAN HOSPITALS & ROUTE NAVIGATION WIDGET =================
class _LiveIndianHospitalsWidget extends StatefulWidget {
  final MockDataService mockService;
  const _LiveIndianHospitalsWidget({required this.mockService});

  @override
  State<_LiveIndianHospitalsWidget> createState() => _LiveIndianHospitalsWidgetState();
}

class _LiveIndianHospitalsWidgetState extends State<_LiveIndianHospitalsWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String _selectedCity = 'All';
  BloodType? _selectedBloodType;
  bool _filterEmergencyOnly = false;
  bool _filterBloodBankOnly = false;
  bool _filterNABHOnly = false;
  bool _filterGovtOnly = false;

  // Live Navigation State
  IndianHospital? _navigatingHospital;
  int _navStep = 0; // 0: Route Ready, 1: En Route, 2: Green Corridor, 3: Arrived
  bool _isBloodBankNotified = false;
  bool _isAmbulanceAlerted = false;

  final List<String> _cities = [
    'All',
    'Hyderabad',
    'New Delhi',
    'Mumbai',
    'Bengaluru',
    'Vellore',
    'Chandigarh',
    'Kolkata',
    'Lucknow',
    'Ahmedabad',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startLiveRoute(IndianHospital hospital) {
    setState(() {
      _navigatingHospital = hospital;
      _navStep = 0;
      _isBloodBankNotified = false;
      _isAmbulanceAlerted = false;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.navigation, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live GPS navigation mapped to ${hospital.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.skyBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _advanceNavigationStep() {
    if (_navStep < 3) {
      setState(() {
        _navStep++;
      });
      final stepNames = [
        'Route mapped and GPS corridor linked.',
        'En route via emergency lane.',
        'Green Corridor cleared by traffic authorities.',
        'Arrived at Emergency & Blood Transfusion Center!',
      ];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(stepNames[_navStep]),
          backgroundColor: _navStep == 3 ? const Color(0xFF10B981) : AppTheme.skyBlue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _stopLiveRoute() {
    setState(() {
      _navigatingHospital = null;
      _navStep = 0;
    });
  }

  String _calculateDistance(IndianHospital hospital) {
    if (hospital.city.toLowerCase().contains('hyderabad')) {
      final latDiff = (hospital.latitude - 17.4485).abs();
      final lngDiff = (hospital.longitude - 78.3750).abs();
      final dist = 2.1 + (latDiff + lngDiff) * 35;
      return '${dist.toStringAsFixed(1)} km';
    } else {
      final approx = 450 + (hospital.latitude - 17.4485).abs() * 45;
      return '${approx.toStringAsFixed(0)} km (Inter-State)';
    }
  }

  String _calculateETA(IndianHospital hospital) {
    if (hospital.city.toLowerCase().contains('hyderabad')) {
      final latDiff = (hospital.latitude - 17.4485).abs();
      final lngDiff = (hospital.longitude - 78.3750).abs();
      final mins = (8 + (latDiff + lngDiff) * 110).round();
      return '$mins mins';
    } else {
      return 'Air/Rail Transit';
    }
  }

  void _showHospitalDetailsModal(IndianHospital hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.skyBlueLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.building2, color: AppTheme.skyBlue, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${hospital.address}, ${hospital.city}, ${hospital.state}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),
                // Key Metrics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        icon: LucideIcons.bed,
                        label: 'Total Beds',
                        value: '${hospital.totalBeds}',
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        icon: LucideIcons.star,
                        label: 'Patient Rating',
                        value: '${hospital.rating} ★',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        icon: LucideIcons.shieldCheck,
                        label: 'Accreditation',
                        value: hospital.isNABHAccredited ? 'NABH' : 'ISO 9001',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'In-House Blood Bank Stock',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hospital.bloodStock.entries.map((entry) {
                    final isLow = entry.value < 5;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isLow ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLow ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.droplet,
                            size: 14,
                            color: isLow ? AppTheme.primaryRed : const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${entry.key.label}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isLow ? AppTheme.primaryRedDark : const Color(0xFF166534),
                            ),
                          ),
                          Text(
                            '${entry.value} Units',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isLow ? AppTheme.primaryRed : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Specialities & Departments',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: hospital.specialities.map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCallDialog(hospital);
                        },
                        icon: const Icon(LucideIcons.phone, size: 16),
                        label: const Text('Call Desk'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.skyBlue,
                          side: const BorderSide(color: AppTheme.skyBlue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _startLiveRoute(hospital);
                        },
                        icon: const Icon(LucideIcons.navigation, size: 16),
                        label: const Text('Live Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.skyBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  void _showCallDialog(IndianHospital hospital) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.skyBlueLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.phoneCall, color: AppTheme.skyBlue, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Hospital Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(hospital.address, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reception / Helpdesk:', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      Text(hospital.phone, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Emergency Ambulance:', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      Text('108 / 102', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryRed, fontSize: 13)),
                    ],
                  ),
                  if (hospital.hasBloodBank) ...[
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Blood Bank Extension:', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        Text('+91 Ext 404', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981), fontSize: 13)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simulated call to ${hospital.name} (${hospital.phone})'),
                  backgroundColor: AppTheme.skyBlue,
                ),
              );
            },
            icon: const Icon(LucideIcons.phone, size: 14),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.skyBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allHospitals = widget.mockService.indianHospitals;

    // Filtering
    final filtered = allHospitals.where((h) {
      if (_selectedCity != 'All' && !h.city.toLowerCase().contains(_selectedCity.toLowerCase())) {
        return false;
      }
      if (_filterEmergencyOnly && !h.has24x7Emergency) return false;
      if (_filterBloodBankOnly && !h.hasBloodBank) return false;
      if (_filterNABHOnly && !h.isNABHAccredited) return false;
      if (_filterGovtOnly && !h.isGovernment) return false;
      if (_selectedBloodType != null) {
        final stock = h.bloodStock[_selectedBloodType] ?? 0;
        if (stock <= 0) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = h.name.toLowerCase().contains(query);
        final matchesCity = h.city.toLowerCase().contains(query);
        final matchesAddress = h.address.toLowerCase().contains(query);
        final matchesSpec = h.specialities.any((s) => s.toLowerCase().contains(query));
        if (!matchesName && !matchesCity && !matchesAddress && !matchesSpec) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP HEADER BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.skyBlue.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.compass, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Live Indian Healthcare Network',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.activity, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'GPS Corridor Active',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Hospital Route & Emergency Navigation',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Live hospital routing, in-house blood inventory, bed capacities, and direct emergency dispatch across India.',
                  style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your Location: Madhapur, Hitec City, Hyderabad, Telangana',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. ACTIVE LIVE NAVIGATION SIMULATOR CARD (If navigating)
          if (_navigatingHospital != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.skyBlue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.skyBlue.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.skyBlueLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.navigation, color: AppTheme.skyBlue, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACTIVE LIVE ROUTE',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.skyBlue, letterSpacing: 0.5),
                              ),
                              Text(
                                _navigatingHospital!.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _stopLiveRoute,
                        icon: const Icon(LucideIcons.x, size: 18, color: Color(0xFF64748B)),
                        tooltip: 'Exit Navigation',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Route Metrics
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('ETA', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(
                              _calculateETA(_navigatingHospital!),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.skyBlue),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                        Column(
                          children: [
                            const Text('Distance', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Text(
                              _calculateDistance(_navigatingHospital!),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                        Column(
                          children: [
                            const Text('Corridor Status', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Clear Corridor',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Turn-by-Turn Route Steps Preview
                  const Text('Turn-by-Turn Route Guidance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  _buildRouteStepTile(
                    stepNum: 1,
                    instruction: 'Depart from current location on Hitec City Main Road',
                    subtext: 'GPS calibration locked • Head East 400m',
                    isActive: _navStep >= 0,
                    isDone: _navStep > 0,
                  ),
                  _buildRouteStepTile(
                    stepNum: 2,
                    instruction: 'Take Elevated Corridor via Outer Ring Road (Priority Lane)',
                    subtext: 'Traffic signal synchronization active for medical transit',
                    isActive: _navStep >= 1,
                    isDone: _navStep > 1,
                  ),
                  _buildRouteStepTile(
                    stepNum: 3,
                    instruction: 'Merge into ${_navigatingHospital!.name} Medical Enclave',
                    subtext: 'Approaching Emergency Bay 1 & Blood Transfusion Unit',
                    isActive: _navStep >= 2,
                    isDone: _navStep > 2,
                  ),
                  _buildRouteStepTile(
                    stepNum: 4,
                    instruction: 'Arrive at ${_navigatingHospital!.name}',
                    subtext: '${_navigatingHospital!.address} • Blood Bank on Ground Floor',
                    isActive: _navStep >= 3,
                    isDone: _navStep >= 3,
                    isLast: true,
                  ),
                  const SizedBox(height: 16),
                  // Interactive Route Control Buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _advanceNavigationStep,
                        icon: Icon(_navStep < 3 ? LucideIcons.play : LucideIcons.checkCheck, size: 14),
                        label: Text(_navStep < 3 ? 'Simulate Next Route Step' : 'Arrived at Destination'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navStep < 3 ? AppTheme.skyBlue : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isBloodBankNotified = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Alert sent to ${_navigatingHospital!.name} Blood Bank! Required units set on hold.'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        icon: Icon(
                          _isBloodBankNotified ? LucideIcons.checkCircle2 : LucideIcons.bell,
                          size: 14,
                          color: _isBloodBankNotified ? const Color(0xFF10B981) : AppTheme.skyBlue,
                        ),
                        label: Text(
                          _isBloodBankNotified ? 'Blood Bank Alerted ✓' : 'Alert Blood Bank of Arrival',
                          style: TextStyle(
                            color: _isBloodBankNotified ? const Color(0xFF10B981) : AppTheme.skyBlue,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isBloodBankNotified ? const Color(0xFF10B981) : AppTheme.skyBlue,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isAmbulanceAlerted = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ambulance emergency line alerted for dispatch assistance.'),
                              backgroundColor: AppTheme.skyBlue,
                            ),
                          );
                        },
                        icon: Icon(
                          _isAmbulanceAlerted ? LucideIcons.checkCircle2 : LucideIcons.ambulance,
                          size: 14,
                          color: _isAmbulanceAlerted ? const Color(0xFF10B981) : AppTheme.primaryRed,
                        ),
                        label: Text(
                          _isAmbulanceAlerted ? 'Ambulance Standby ✓' : 'Dispatch / Standby Ambulance',
                          style: TextStyle(
                            color: _isAmbulanceAlerted ? const Color(0xFF10B981) : AppTheme.primaryRed,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isAmbulanceAlerted ? const Color(0xFF10B981) : AppTheme.primaryRed,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. SEARCH & FILTER CONTROLS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search hospital name, city, landmark or speciality...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.skyBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                // City Filter Chips
                const Text('Filter by Indian City / Region:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cities.map((city) {
                      final isSelected = _selectedCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCity = city;
                              });
                            }
                          },
                          selectedColor: AppTheme.skyBlue,
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(
                            color: isSelected ? AppTheme.skyBlue : const Color(0xFFE2E8F0),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Feature Toggles Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('24/7 Emergency'),
                        selected: _filterEmergencyOnly,
                        onSelected: (val) => setState(() => _filterEmergencyOnly = val),
                        avatar: const Icon(LucideIcons.activity, size: 14),
                        selectedColor: AppTheme.skyBlueLight,
                        checkmarkColor: AppTheme.skyBlue,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('In-House Blood Bank'),
                        selected: _filterBloodBankOnly,
                        onSelected: (val) => setState(() => _filterBloodBankOnly = val),
                        avatar: const Icon(LucideIcons.droplet, size: 14),
                        selectedColor: AppTheme.skyBlueLight,
                        checkmarkColor: AppTheme.skyBlue,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('NABH Accredited'),
                        selected: _filterNABHOnly,
                        onSelected: (val) => setState(() => _filterNABHOnly = val),
                        avatar: const Icon(LucideIcons.shieldCheck, size: 14),
                        selectedColor: AppTheme.skyBlueLight,
                        checkmarkColor: AppTheme.skyBlue,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Govt / AIIMS'),
                        selected: _filterGovtOnly,
                        onSelected: (val) => setState(() => _filterGovtOnly = val),
                        avatar: const Icon(LucideIcons.building, size: 14),
                        selectedColor: AppTheme.skyBlueLight,
                        checkmarkColor: AppTheme.skyBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Blood Type Filter Dropdown
                Row(
                  children: [
                    const Text('Required Blood Group: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButton<BloodType?>(
                        value: _selectedBloodType,
                        hint: const Text('Any Group', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        underline: const SizedBox(),
                        isDense: true,
                        items: [
                          const DropdownMenuItem<BloodType?>(
                            value: null,
                            child: Text('Any Group', style: TextStyle(fontSize: 12)),
                          ),
                          ...BloodType.values.map(
                            (type) => DropdownMenuItem<BloodType?>(
                              value: type,
                              child: Text('${type.label} Stock', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedBloodType = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. RESULTS HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Hospitals (${filtered.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              if (_searchQuery.isNotEmpty || _selectedCity != 'All' || _filterEmergencyOnly || _filterBloodBankOnly || _filterNABHOnly || _filterGovtOnly || _selectedBloodType != null)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCity = 'All';
                      _selectedBloodType = null;
                      _filterEmergencyOnly = false;
                      _filterBloodBankOnly = false;
                      _filterNABHOnly = false;
                      _filterGovtOnly = false;
                    });
                  },
                  child: const Text('Reset All Filters', style: TextStyle(fontSize: 12, color: AppTheme.skyBlue)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 5. HOSPITAL CARDS LIST
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(LucideIcons.building, size: 48, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  const Text('No hospitals match your filter criteria', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  const Text('Try adjusting city filters or blood group requirement.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedCity = 'All';
                        _selectedBloodType = null;
                        _filterEmergencyOnly = false;
                        _filterBloodBankOnly = false;
                        _filterNABHOnly = false;
                        _filterGovtOnly = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Show All Hospitals'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final hospital = filtered[index];
                final isCurrentNav = _navigatingHospital?.id == hospital.id;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrentNav ? AppTheme.skyBlue : const Color(0xFFE2E8F0),
                      width: isCurrentNav ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Name and Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hospital.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${hospital.landmark.isNotEmpty ? "${hospital.landmark} • " : ""}${hospital.city}, ${hospital.state}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hospital.isGovernment ? const Color(0xFFF0FDF4) : AppTheme.skyBlueLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: hospital.isGovernment ? const Color(0xFFBBF7D0) : AppTheme.skyBlue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  hospital.isGovernment ? 'Government' : 'Super-Speciality',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: hospital.isGovernment ? const Color(0xFF166534) : AppTheme.skyBlueDark,
                                  ),
                                ),
                              ),
                              if (hospital.isNABHAccredited) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.shieldCheck, size: 10, color: Color(0xFF10B981)),
                                      SizedBox(width: 3),
                                      Text(
                                        'NABH',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Metrics & Features Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.star, size: 12, color: Color(0xFFD97706)),
                                const SizedBox(width: 4),
                                Text(
                                  '${hospital.rating} ★',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.bed, size: 12, color: Color(0xFF475569)),
                                const SizedBox(width: 4),
                                Text(
                                  '${hospital.totalBeds} Beds',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                ),
                              ],
                            ),
                          ),
                          if (hospital.has24x7Emergency)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.activity, size: 12, color: Color(0xFF16A34A)),
                                  SizedBox(width: 4),
                                  Text(
                                    '24x7 Emergency',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                                  ),
                                ],
                              ),
                            ),
                          if (hospital.hasBloodBank)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.droplet, size: 12, color: AppTheme.primaryRed),
                                  SizedBox(width: 4),
                                  Text(
                                    'In-House Blood Bank',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryRedDark),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.skyBlueLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.navigation, size: 12, color: AppTheme.skyBlue),
                                const SizedBox(width: 4),
                                Text(
                                  _calculateDistance(hospital),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.skyBlueDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // In-House Blood Bank Stock Bar
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Live Blood Availability Preview:',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                                ),
                                Text(
                                  'Real-time Units',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: hospital.bloodStock.entries.take(6).map((entry) {
                                  final isLow = entry.value < 5;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isLow ? const Color(0xFFFEE2E2) : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isLow ? const Color(0xFFFCA5A5) : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Text(
                                        '${entry.key.label}: ${entry.value}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isLow ? AppTheme.primaryRedDark : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: () => _startLiveRoute(hospital),
                              icon: const Icon(LucideIcons.navigation, size: 14),
                              label: Text(
                                isCurrentNav ? 'En Route (Active)' : 'Start Live Route',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrentNav ? const Color(0xFF10B981) : AppTheme.skyBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: () => _showCallDialog(hospital),
                              icon: const Icon(LucideIcons.phone, size: 13),
                              label: const Text('Call', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF334155),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showHospitalDetailsModal(hospital),
                            icon: const Icon(LucideIcons.info, size: 18, color: AppTheme.skyBlue),
                            tooltip: 'View Full Hospital Specs',
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.skyBlueLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRouteStepTile({
    required int stepNum,
    required String instruction,
    required String subtext,
    required bool isActive,
    required bool isDone,
    bool isLast = false,
  }) {
    final color = isDone
        ? const Color(0xFF10B981)
        : isActive
            ? AppTheme.skyBlue
            : const Color(0xFFE2E8F0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instruction,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= PATIENT HISTORY WIDGET =================
class _PatientHistoryWidget extends StatefulWidget {
  final MockDataService mockService;
  const _PatientHistoryWidget({required this.mockService});

  @override
  State<_PatientHistoryWidget> createState() => _PatientHistoryWidgetState();
}

class _PatientHistoryWidgetState extends State<_PatientHistoryWidget> with SingleTickerProviderStateMixin {
  late TabController _historyTabController;

  @override
  void initState() {
    super.initState();
    _historyTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _historyTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _historyTabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: const [
                Tab(text: 'Requests'),
                Tab(text: 'Emergency SOS'),
                Tab(text: 'Appointments'),
                Tab(text: 'Searches'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _historyTabController,
                children: [
                  _buildRequestsHistory(),
                  _buildSOSHistory(),
                  _buildAppointmentsHistory(),
                  _buildSearchesHistory(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsHistory() {
    final requests = widget.mockService.patientRequests;
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: requests.length,
        itemBuilder: (context, i) {
          final r = requests[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRedLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    r.bloodType.label,
                    style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r.units} Units • ${r.hospital}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Status: ${r.status.label} • Needed: ${r.requiredDateTime.day}/${r.requiredDateTime.month}/${r.requiredDateTime.year}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                      ),
                      if (r.matchedDonorName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Matched Donor: ${r.matchedDonorName}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    r.priority.name.toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSOSHistory() {
    final sos = widget.mockService.activeEmergencySOS;
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (sos != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRedLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.alertTriangle, color: AppTheme.primaryRed, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOS Requisition #${sos.id}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${sos.unitsRequired} Units ${sos.bloodType.label} • ${sos.hospital}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Status: ${sos.status.label} • Donors Alerted: ${sos.matchedDonorsCount}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No emergency SOS records found.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsHistory() {
    final appointments = widget.mockService.appointments;
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        itemBuilder: (context, i) {
          final apt = appointments[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.skyBlueLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.calendar, color: AppTheme.skyBlue, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.facilityName,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${apt.doctorOrDept} • ${apt.purpose}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Date: ${apt.dateTime.day}/${apt.dateTime.month}/${apt.dateTime.year} at ${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: apt.status == 'Confirmed' ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: apt.status == 'Confirmed' ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    apt.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: apt.status == 'Confirmed' ? const Color(0xFF059669) : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchesHistory() {
    final searches = widget.mockService.searchHistory;
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: searches.length,
        itemBuilder: (context, i) {
          final sh = searches[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.search, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sh.bloodType.label} in ${sh.locationQuery}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${sh.foundUnits} available units found in search',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${sh.timestamp.day}/${sh.timestamp.month}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================= NOTIFICATIONS WIDGET =================
class _PatientNotificationsWidget extends StatelessWidget {
  final MockDataService mockService;
  const _PatientNotificationsWidget({required this.mockService});

  @override
  Widget build(BuildContext context) {
    final notifications = mockService.notifications;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications (${notifications.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  mockService.markAllNotificationsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read.')),
                  );
                },
                child: const Text('Mark All Read', style: TextStyle(color: AppTheme.skyBlue)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, i) {
              final notif = notifications[i];
              IconData icon;
              Color color;

              switch (notif.type) {
                case 'donor_matched':
                  icon = LucideIcons.heartPulse;
                  color = AppTheme.primaryRed;
                  break;
                case 'status_changed':
                  icon = LucideIcons.activity;
                  color = AppTheme.skyBlue;
                  break;
                case 'blood_found':
                  icon = LucideIcons.droplets;
                  color = const Color(0xFF10B981);
                  break;
                case 'emergency_response':
                  icon = LucideIcons.siren;
                  color = const Color(0xFFDC2626);
                  break;
                default:
                  icon = LucideIcons.clock;
                  color = const Color(0xFF8B5CF6);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.white : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif.isRead ? const Color(0xFFE2E8F0) : AppTheme.skyBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${notif.timestamp.hour}:${notif.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    if (!notif.isRead)
                      IconButton(
                        icon: const Icon(LucideIcons.check, size: 16, color: AppTheme.skyBlue),
                        onPressed: () => mockService.markNotificationAsRead(notif.id),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ================= SETTINGS & PREFERENCES WIDGET =================
class _PatientSettingsWidget extends StatefulWidget {
  final MockDataService mockService;
  final PatientProfile patient;

  const _PatientSettingsWidget({required this.mockService, required this.patient});

  @override
  State<_PatientSettingsWidget> createState() => _PatientSettingsWidgetState();
}

class _PatientSettingsWidgetState extends State<_PatientSettingsWidget> {
  double _sosRadiusKm = 15.0;

  @override
  void initState() {
    super.initState();
    _sosRadiusKm = widget.mockService.sosRadiusKm;
  }

  void _showFeedback(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, PatientProfile patient) {
    final nameCtrl = TextEditingController(text: patient.name);
    final phoneCtrl = TextEditingController(text: patient.phone);
    final emailCtrl = TextEditingController(text: patient.email);
    final locCtrl = TextEditingController(text: patient.location);
    final emgNameCtrl = TextEditingController(text: patient.emergencyContactName);
    final emgPhoneCtrl = TextEditingController(text: patient.emergencyContactPhone);
    final emgRelCtrl = TextEditingController(text: patient.emergencyContactRelation);
    BloodType selectedBlood = patient.bloodType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setInner) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Patient Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.black),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Blood Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<BloodType>(
                          isExpanded: true,
                          value: selectedBlood,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14),
                          items: BloodType.values.map((b) => DropdownMenuItem(value: b, child: Text(b.label, style: const TextStyle(color: Colors.black)))).toList(),
                          onChanged: (v) {
                            if (v != null) setInner(() => selectedBlood = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Phone Number (+91)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Email Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('City / Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: locCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Emergency Contact Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emgNameCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Emergency Contact Phone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emgPhoneCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Emergency Contact Relation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emgRelCtrl,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('Save Profile Details', style: TextStyle(fontWeight: FontWeight.w900)),
                        onPressed: () {
                          widget.mockService.updatePatientProfile(
                            patient.copyWith(
                              name: nameCtrl.text.trim().isEmpty ? patient.name : nameCtrl.text.trim(),
                              bloodType: selectedBlood,
                              phone: phoneCtrl.text.trim().isEmpty ? patient.phone : phoneCtrl.text.trim(),
                              email: emailCtrl.text.trim().isEmpty ? patient.email : emailCtrl.text.trim(),
                              location: locCtrl.text.trim().isEmpty ? patient.location : locCtrl.text.trim(),
                              emergencyContactName: emgNameCtrl.text.trim().isEmpty ? patient.emergencyContactName : emgNameCtrl.text.trim(),
                              emergencyContactPhone: emgPhoneCtrl.text.trim().isEmpty ? patient.emergencyContactPhone : emgPhoneCtrl.text.trim(),
                              emergencyContactRelation: emgRelCtrl.text.trim().isEmpty ? patient.emergencyContactRelation : emgRelCtrl.text.trim(),
                            ),
                          );
                          Navigator.pop(ctx);
                          _showFeedback('Profile updated: ${nameCtrl.text.trim()}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showThemePickerModal() {
    final themes = [
      'Pure White iOS (Default)',
      'Dark Mode (iOS Midnight)',
      'Clinical Sky Blue Tint',
      'High Contrast Healthcare B&W',
    ];
    final ms = widget.mockService;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select UI Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(height: 6),
              const Text('Instant real-time color theme & accessibility mode update', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              ...themes.map((t) {
                final isSelected = t == ms.selectedTheme;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(LucideIcons.palette, color: isSelected ? const Color(0xFF0284C7) : Colors.black),
                  title: Text(t, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: Colors.black)),
                  trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF0284C7)) : null,
                  onTap: () {
                    final isDark = t.contains('Dark Mode');
                    ms.updateSettings(theme: t, themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
                    Navigator.pop(ctx);
                    _showFeedback('Theme preference active: $t (${isDark ? "Dark Mode ON" : "Light Mode ON"})');
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePickerModal() {
    final languages = [
      'English (India)',
      'हिन्दी (Hindi)',
      'తెలుగు (Telugu)',
      'தமிழ் (Tamil)',
      'मराठी (Marathi)',
      'বাংলা (Bengali)',
      'ಕನ್ನಡ (Kannada)',
      'മലയാളം (Malayalam)',
      'ગુજરાતી (Gujarati)',
    ];
    final ms = widget.mockService;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Regional Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(height: 6),
              const Text('Localized interface terminology and multi-lingual emergency dispatchers', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              ...languages.map((l) {
                final isSelected = l == ms.selectedLanguage;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(LucideIcons.languages, color: isSelected ? const Color(0xFF0284C7) : Colors.black),
                  title: Text(l, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: Colors.black)),
                  trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF0284C7)) : null,
                  onTap: () {
                    ms.updateSettings(language: l);
                    Navigator.pop(ctx);
                    _showFeedback('System language updated to $l');
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final ms = widget.mockService;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          const Text(
            'Patient Settings & Preferences',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 6),
          const Text(
            'Configure real-time alerts, matching radius, emergency SOS, and regional preferences.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // 1. Profile Summary Card (Interactive on tap)
          InkWell(
            onTap: () => _showEditProfileModal(context, patient),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PATIENT PROFILE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.pencil, size: 12, color: Colors.black),
                            SizedBox(width: 4),
                            Text('EDIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          patient.bloodType.label,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${patient.phone} • Email: ${patient.email}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                            ),
                            Text(
                              'City: ${patient.location} • Emergency: ${patient.emergencyContactName} (${patient.emergencyContactRelation}) ${patient.emergencyContactPhone}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Emergency Broadcast Radius Setting
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.navigation, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Emergency SOS Search Radius',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_sosRadiusKm.toInt()} KM',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Instantly broadcast SOS notifications to compatible blood donors and hospitals located within this radial distance.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Slider(
                  value: _sosRadiusKm,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: Colors.black,
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (v) {
                    setState(() => _sosRadiusKm = v);
                  },
                  onChangeEnd: (v) {
                    _showFeedback('Emergency broadcast radius saved: ${v.toInt()} km');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Notification Preferences (Interactive Toggles)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.bellRing, size: 18, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Real-Time Notification Channels',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('SMS Critical Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Direct priority text messages to +91 mobile when matched or SOS activates', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: ms.notifySms,
                  onChanged: (val) {
                    ms.updateSettings(sms: val);
                    _showFeedback(val ? 'SMS Critical Alerts: ENABLED for ${patient.phone}' : 'SMS Critical Alerts: DISABLED');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Push Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Real-time browser / app pop-up alerts for request lifecycle changes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: ms.notifyPush,
                  onChanged: (val) {
                    ms.updateSettings(push: val);
                    _showFeedback(val ? 'Push Notifications: ENABLED' : 'Push Notifications: MUTED');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Audible Emergency Siren Alarm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Play high-priority acoustic tone for life-saving emergency matches', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: ms.notifyEmergencySiren,
                  onChanged: (val) {
                    ms.updateSettings(siren: val);
                    _showFeedback(val ? 'Emergency Siren: ARMED' : 'Emergency Siren: SILENCED');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Email Summaries & Receipts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Detailed blood requisition receipts and regional availability summaries', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: ms.notifyEmail,
                  onChanged: (val) {
                    ms.updateSettings(email: val);
                    _showFeedback(val ? 'Email Digests: ACTIVE (${patient.email})' : 'Email Digests: MUTED');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Regional, Language & Appearance Preferences
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.sliders, size: 18, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Language & System Preferences',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.palette, color: Colors.black),
                  title: const Text('Color Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: Text(ms.selectedTheme, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.black),
                  onTap: _showThemePickerModal,
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.languages, color: Colors.black),
                  title: const Text('Indian Regional Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: Text(ms.selectedLanguage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.black),
                  onTap: _showLanguagePickerModal,
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Live GPS Location Sharing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Share anonymized GPS coordinates for instant smart donor matching', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: ms.shareLocationForMatching,
                  onChanged: (val) {
                    ms.updateSettings(shareLoc: val);
                    _showFeedback(val ? 'Live GPS Location: ENABLED' : 'Live GPS Location: DISABLED');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5. Data Export & Support Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.fileSpreadsheet, size: 18, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Medical Records & Support',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.download, color: Colors.black),
                  title: const Text('Export Transfusion History (Audit Report)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Download encrypted NABH-compliant medical transfusion audit (.html)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  trailing: const Icon(LucideIcons.fileDown, color: Color(0xFF0284C7)),
                  onTap: () {
                    FileDownloadService.downloadPatientTransfusionRecords(ms, patient);
                    _showFeedback('Encrypted Medical Audit (VitalPulse_Transfusion_Audit_${patient.name.replaceAll(' ', '_')}.html) downloaded & saved!');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.phoneCall, color: Color(0xFF0284C7)),
                  title: const Text('24/7 National Blood Transfusion Helpline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Toll Free: 1800-11-2478 / Red Cross Central Desk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  trailing: const Icon(LucideIcons.phoneForwarded, color: Color(0xFF0284C7)),
                  onTap: () async {
                    final uri = Uri.parse('tel:1800112478');
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      try { await launchUrl(uri); } catch (_) {}
                    }
                    _showFeedback('Connecting to National Blood Helpline 1800-11-2478...');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.rotateCcw, color: Color(0xFFDC2626)),
                  title: const Text('Reset All Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                  subtitle: const Text('Restore notification toggles and search radius to initial defaults', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Reset Preferences?', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
                        content: const Text('This will reset your notifications, emergency radius, and system preferences to defaults.', style: TextStyle(color: Colors.black87)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                            onPressed: () {
                              setState(() {
                                _sosRadiusKm = 15.0;
                              });
                              ms.updateSettings(
                                sms: true,
                                push: true,
                                siren: true,
                                email: false,
                                shareLoc: true,
                                autoEmergency: true,
                                theme: 'Pure White iOS (Default)',
                                language: 'English (India)',
                                themeMode: ThemeMode.light,
                                sosRadius: 15.0,
                              );
                              Navigator.pop(ctx);
                              _showFeedback('All patient preferences restored to defaults');
                            },
                            child: const Text('Reset to Defaults', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
