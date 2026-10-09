import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/blood_type.dart';
import '../models/hospital_models.dart';
import '../models/patient_models.dart';
import '../services/mock_data_service.dart';
import '../services/file_download_service.dart';
import '../theme/app_theme.dart';

class HospitalDashboardScreen extends StatefulWidget {
  final int initialTab;
  const HospitalDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<HospitalDashboardScreen> createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final unreadNotifs = mockService.hospitalNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
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
                  Icon(LucideIcons.building2, size: 16, color: AppTheme.skyBlue),
                  SizedBox(width: 6),
                  Text(
                    'HOSPITAL CLINICAL DESK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.skyBlueDark,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hospital Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Emergency Requests Active Counter Badge
          if (mockService.hospitalEmergencyRequestsCount > 0)
            GestureDetector(
              onTap: () => _switchTab(2), // Jump to Emergency Management Tab
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
                    Text(
                      '${mockService.hospitalEmergencyRequestsCount} EMERGENCY SOS',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Notifications Shortcut
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Colors.black),
                tooltip: 'Hospital Alerts',
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
            icon: const Icon(LucideIcons.settings, color: Colors.black),
            tooltip: 'Hospital Settings',
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
                unselectedLabelColor: Colors.black,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: const [
                  Tab(icon: Icon(LucideIcons.layoutDashboard, size: 16), text: 'Overview'),
                  Tab(icon: Icon(LucideIcons.filePlus2, size: 16), text: 'Patient Requests'),
                  Tab(icon: Icon(LucideIcons.alertTriangle, size: 16), text: 'Emergencies'),
                  Tab(icon: Icon(LucideIcons.boxes, size: 16), text: 'Blood Inventory'),
                  Tab(icon: Icon(LucideIcons.users, size: 16), text: 'Donor Search'),
                  Tab(icon: Icon(LucideIcons.truck, size: 16), text: 'Bank Transfers'),
                  Tab(icon: Icon(LucideIcons.userCheck, size: 16), text: 'Patients'),
                  Tab(icon: Icon(LucideIcons.calendar, size: 16), text: 'Appointments'),
                  Tab(icon: Icon(LucideIcons.barChart3, size: 16), text: 'Analytics'),
                  Tab(icon: Icon(LucideIcons.bell, size: 16), text: 'Alerts'),
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
          _buildOverviewTab(context, mockService),
          _buildPatientRequestsTab(context, mockService),
          _buildEmergencyManagementTab(context, mockService),
          _buildInventoryTab(context, mockService),
          _buildDonorSearchTab(context, mockService),
          _buildBloodBankCoordinationTab(context, mockService),
          _buildPatientManagementTab(context, mockService),
          _buildAppointmentsTab(context, mockService),
          _buildReportsAnalyticsTab(context, mockService),
          _buildNotificationsTab(context, mockService),
          _HospitalSettingsWidget(mockService: mockService),
        ],
      ),
    );
  }

  // ================= 1. HOSPITAL OVERVIEW TAB =================
  Widget _buildOverviewTab(BuildContext context, MockDataService mockService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital Identity Banner (Compact iOS Card)
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
                    child: Icon(LucideIcons.building, size: 22, color: AppTheme.skyBlue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mockService.hospitalName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'LEVEL 1 TRAUMA',
                              style: TextStyle(color: Color(0xFF059669), fontSize: 9.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'License: ${mockService.hospitalLicenseId} • ${mockService.hospitalLocation}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 6 Essential Overview Metric Cards (Compact Responsive Grid)
          const Text(
            'Hospital Live Vitals & Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 700 ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: MediaQuery.of(context).size.width < 700 ? 2.5 : 2.1,
            children: [
              _buildMetricCard(
                title: 'Total Blood Units',
                value: '${mockService.hospitalTotalBloodUnits} Units',
                subtitle: 'Active Hospital Reserve',
                icon: LucideIcons.droplets,
                color: AppTheme.primaryRed,
                onTap: () => _switchTab(3),
              ),
              _buildMetricCard(
                title: 'Pending Requests',
                value: '${mockService.hospitalPendingRequestsCount} Requisitions',
                subtitle: 'Needs blood assignment',
                icon: LucideIcons.clock,
                color: const Color(0xFFF59E0B),
                onTap: () => _switchTab(1),
              ),
              _buildMetricCard(
                title: 'Emergency SOS',
                value: '${mockService.hospitalEmergencyRequestsCount} Critical',
                subtitle: 'Immediate action required',
                icon: LucideIcons.alertTriangle,
                color: AppTheme.primaryRed,
                onTap: () => _switchTab(2),
              ),
              _buildMetricCard(
                title: 'Low-Stock Groups',
                value: '${mockService.hospitalLowStockCount} Groups',
                subtitle: 'Below threshold limit',
                icon: LucideIcons.alertCircle,
                color: const Color(0xFFDC2626),
                onTap: () => _switchTab(3),
              ),
              _buildMetricCard(
                title: 'Expiring Blood Units',
                value: '${mockService.hospitalExpiringUnitsCount} Units',
                subtitle: 'Expiring within 7 days',
                icon: LucideIcons.calendarClock,
                color: const Color(0xFF8B5CF6),
                onTap: () => _switchTab(3),
              ),
              _buildMetricCard(
                title: 'Appointments Today',
                value: '${mockService.hospitalUpcomingAppointmentsCount} Scheduled',
                subtitle: 'Transfusion & Crossmatches',
                icon: LucideIcons.calendarCheck,
                color: AppTheme.skyBlue,
                onTap: () => _switchTab(7),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // EMERGENCY SOS ACTION ALERT
          if (mockService.hospitalEmergencyRequestsCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.primaryRed, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRedLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.siren, color: AppTheme.primaryRed, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CRITICAL TRAUMA ALERT ACTIVE',
                          style: TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mockService.hospitalEmergencyRequestsCount} emergency blood requests need immediate donor alerts or transfer dispatch.',
                          style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _switchTab(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Manage SOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // QUICK ACTIONS & SHORTCUTS
          const Text(
            'Clinical Desk Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionShortcut(
                  label: 'New Requisition',
                  icon: LucideIcons.filePlus,
                  color: AppTheme.skyBlue,
                  onTap: () => _showNewRequestDialog(context, mockService),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionShortcut(
                  label: 'Request Transfer',
                  icon: LucideIcons.truck,
                  color: const Color(0xFF10B981),
                  onTap: () => _showRequestTransferDialog(context, mockService),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionShortcut(
                  label: 'Search Donors',
                  icon: LucideIcons.users,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _switchTab(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionShortcut(
                  label: 'Full Inventory',
                  icon: LucideIcons.boxes,
                  color: AppTheme.primaryRed,
                  onTap: () => _switchTab(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // RECENT PATIENT BLOOD REQUESTS PREVIEW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Patient Requisitions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () => _switchTab(1),
                child: const Text('View All Requisitions →', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...mockService.hospitalRequests.take(3).map((req) => _buildHospitalRequestCard(context, req, mockService)),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionShortcut({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 2. PATIENT BLOOD REQUESTS TAB =================
  Widget _buildPatientRequestsTab(BuildContext context, MockDataService mockService) {
    final requests = mockService.hospitalRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Blood Requisitions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create, track, and assign blood units for hospital inpatients & surgeries.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      FileDownloadService.downloadHospitalPatientRequisitionsCsv(mockService);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hospital Patient Requisitions Register (.csv) downloaded & saved!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.fileSpreadsheet, size: 15, color: Colors.black),
                    label: const Text('Export CSV', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12.5)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1.4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showNewRequestDialog(context, mockService),
                    icon: const Icon(LucideIcons.plus, size: 16, color: Colors.black),
                    label: const Text('Create Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlueLight,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...requests.map((req) => _buildHospitalRequestCard(context, req, mockService)),
        ],
      ),
    );
  }

  Widget _buildHospitalRequestCard(
    BuildContext context,
    HospitalPatientBloodRequest req,
    MockDataService mockService,
  ) {
    Color priorityColor;
    switch (req.priority) {
      case HospitalRequestPriority.emergency:
        priorityColor = AppTheme.primaryRed;
        break;
      case HospitalRequestPriority.urgent:
        priorityColor = const Color(0xFFD97706);
        break;
      case HospitalRequestPriority.normal:
        priorityColor = const Color(0xFF059669);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: req.priority == HospitalRequestPriority.emergency
              ? AppTheme.primaryRed.withValues(alpha: 0.6)
              : const Color(0xFFE2E8F0),
          width: req.priority == HospitalRequestPriority.emergency ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Patient info & Priority badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.bloodType.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
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
                          req.patientName,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            req.patientRefId,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ward: ${req.departmentOrWard} • Req ID: ${req.id}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  req.priority.name.toUpperCase(),
                  style: TextStyle(color: priorityColor, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Row 2: Status, Units, and Needed Date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UNITS REQUIRED / ASSIGNED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                    const SizedBox(height: 2),
                    Text(
                      '${req.assignedUnits} / ${req.unitsRequired} Units Allocated',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: req.assignedUnits >= req.unitsRequired ? const Color(0xFF059669) : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REQUIRED BY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                    const SizedBox(height: 2),
                    Text(
                      '${req.requiredDateTime.day}/${req.requiredDateTime.month} at ${req.requiredDateTime.hour}:${req.requiredDateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REQUEST STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                    const SizedBox(height: 2),
                    Text(
                      req.status.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (req.clinicalNotes != null) ...[
            const SizedBox(height: 10),
            Text(
              'Clinical Notes: ${req.clinicalNotes}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500),
            ),
          ],

          const SizedBox(height: 14),

          // Row 3: Action Buttons
          Row(
            children: [
              if (req.status != HospitalRequestStatus.fulfilled) ...[
                OutlinedButton.icon(
                  onPressed: () => mockService.reserveUnitsForHospitalRequest(req.id, 1),
                  icon: const Icon(LucideIcons.lock, size: 14, color: Colors.black),
                  label: const Text('Reserve 1 Unit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => mockService.fulfillHospitalRequest(req.id),
                  icon: const Icon(LucideIcons.checkCheck, size: 14),
                  label: const Text('Mark Fulfilled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              OutlinedButton.icon(
                onPressed: () => mockService.notifyCompatibleDonorsForHospital(req.id),
                icon: const Icon(LucideIcons.bell, size: 14, color: AppTheme.skyBlue),
                label: const Text('Alert Donors', style: TextStyle(color: AppTheme.skyBlue, fontWeight: FontWeight.w800, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.skyBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  FileDownloadService.downloadHospitalRequisitionSlip(req, mockService);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Requisition Voucher (Hospital_Blood_Requisition_${req.id}.html) downloaded!'),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
                icon: const Icon(LucideIcons.download, size: 14, color: Colors.black),
                label: const Text('Voucher', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const Spacer(),
              if (req.priority == HospitalRequestPriority.emergency && !req.isEscalated)
                ElevatedButton.icon(
                  onPressed: () => mockService.escalateHospitalRequest(req.id),
                  icon: const Icon(LucideIcons.siren, size: 14),
                  label: const Text('Escalate Delay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 3. EMERGENCY REQUEST MANAGEMENT TAB =================
  Widget _buildEmergencyManagementTab(BuildContext context, MockDataService mockService) {
    final emergencyRequests = mockService.hospitalRequests
        .where((r) => r.priority == HospitalRequestPriority.emergency)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryRed, width: 1.6),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRedLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.alertOctagon, color: AppTheme.primaryRed, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Priority Response Desk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Emergency requests appear first with high priority. Fast-action controls to notify donors, contact blood centers, reserve stock, and escalate delays.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Active Emergency Requisitions (${emergencyRequests.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 12),

          if (emergencyRequests.isEmpty)
            _buildEmptyState('No active emergency requests at this moment.', LucideIcons.checkCircle2)
          else
            ...emergencyRequests.map((req) => _buildHospitalRequestCard(context, req, mockService)),
        ],
      ),
    );
  }

  // ================= 4. BLOOD INVENTORY TAB =================
  Widget _buildInventoryTab(BuildContext context, MockDataService mockService) {
    final inventory = mockService.hospitalInventory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hospital Blood Bank Inventory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time tracking of all 8 blood groups: Available, Reserved, Used, and Expiring.',
                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      FileDownloadService.downloadHospitalInventoryCsv(mockService);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hospital Blood Inventory Register (.csv) downloaded & saved!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.fileSpreadsheet, size: 15, color: Colors.black),
                    label: const Text('Export CSV', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12.5)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1.4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showRequestTransferDialog(context, mockService),
                    icon: const Icon(LucideIcons.truck, size: 16, color: Colors.black),
                    label: const Text('Requisition Stock', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlueLight,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Inventory Table / Cards for all 8 Blood Types
          ...inventory.values.map((group) => _buildInventoryGroupCard(context, group, mockService)),
        ],
      ),
    );
  }

  Widget _buildInventoryGroupCard(
    BuildContext context,
    HospitalInventoryGroup group,
    MockDataService mockService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: group.isCritical
              ? AppTheme.primaryRed
              : (group.isLowStock ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0)),
          width: group.isCritical || group.isLowStock ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRedLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    group.bloodType.label,
                    style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w900, fontSize: 16),
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
                          'Blood Group ${group.bloodType.label}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        if (group.isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRedLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('CRITICAL LOW', style: TextStyle(color: AppTheme.primaryRed, fontSize: 10, fontWeight: FontWeight.w900)),
                          )
                        else if (group.isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('LOW STOCK', style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Minimum Threshold: ${group.minThreshold} Units',
                      style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showEditInventoryDialog(context, mockService, group.bloodType),
                icon: const Icon(LucideIcons.slidersHorizontal, size: 14, color: Colors.black),
                label: const Text('Edit Counts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddStockDialog(context, mockService, group.bloodType),
                icon: const Icon(LucideIcons.plus, size: 14, color: Colors.black),
                label: const Text('Add Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.skyBlueLight,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // 4 Unit Columns: Available, Reserved, Used, Expiring (Interactive and Editable)
          Row(
            children: [
              _buildInventorySubMetric(
                'AVAILABLE',
                '${group.availableUnits}',
                Colors.black,
                () => _showEditInventoryDialog(context, mockService, group.bloodType),
              ),
              _buildInventorySubMetric(
                'RESERVED',
                '${group.reservedUnits}',
                const Color(0xFFD97706),
                () => _showEditInventoryDialog(context, mockService, group.bloodType),
              ),
              _buildInventorySubMetric(
                'USED (30D)',
                '${group.usedUnits}',
                const Color(0xFF059669),
                () => _showEditInventoryDialog(context, mockService, group.bloodType),
              ),
              _buildInventorySubMetric(
                'EXPIRING (7D)',
                '${group.expiringUnits}',
                const Color(0xFFDC2626),
                () => _showEditInventoryDialog(context, mockService, group.bloodType),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySubMetric(String title, String val, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(width: 3),
                  const Icon(LucideIcons.pencil, size: 9, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                val,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 5. DONOR SEARCH TAB =================
  Widget _buildDonorSearchTab(BuildContext context, MockDataService mockService) {
    return _HospitalDonorSearchWidget(mockService: mockService);
  }

  // ================= 6. BLOOD BANK COORDINATION TAB =================
  Widget _buildBloodBankCoordinationTab(BuildContext context, MockDataService mockService) {
    final transfers = mockService.bloodBankTransfers;
    final bloodBanks = mockService.nearbyFacilities.where((f) => f.type == FacilityType.bloodBank).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Regional Blood Bank Transfers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordinate transfer requisitions, live courier tracking & stock integration.',
                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showRequestTransferDialog(context, mockService),
                icon: const Icon(LucideIcons.plus, size: 16, color: Colors.black),
                label: const Text('Send Transfer Request', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.skyBlueLight,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1.4),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text('Active & Recent Transfers', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 12),

          ...transfers.map((t) => _buildTransferCard(context, t, mockService)),

          const SizedBox(height: 28),
          const Text('Connected Regional Blood Banks', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 12),

          ...bloodBanks.map((bank) => _buildConnectedBankCard(context, bank, mockService)),
        ],
      ),
    );
  }

  Widget _buildTransferCard(BuildContext context, BloodBankTransferItem transfer, MockDataService mockService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.skyBlue, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      transfer.bloodType.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${transfer.units} Units • ${transfer.bloodBankName}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: transfer.status == TransferStatus.confirmed
                      ? const Color(0xFFECFDF5)
                      : (transfer.status == TransferStatus.inTransit ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transfer.status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: transfer.status == TransferStatus.confirmed ? const Color(0xFF059669) : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Transfer ID: ${transfer.id} • Courier: ${transfer.transportCourier}',
            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
          ),
          if (transfer.status != TransferStatus.confirmed) ...[
            const SizedBox(height: 4),
            Text(
              'ETA: ${transfer.etaMinutes > 0 ? "${transfer.etaMinutes} mins" : "Arrived"}',
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryRed, fontWeight: FontWeight.w800),
            ),
          ],
          const Divider(height: 20),
          Row(
            children: [
              if (transfer.status != TransferStatus.confirmed) ...[
                ElevatedButton.icon(
                  onPressed: () => mockService.advanceTransferStatus(transfer.id),
                  icon: const Icon(LucideIcons.arrowRight, size: 14),
                  label: const Text('Advance Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => mockService.confirmTransferDelivery(transfer.id),
                  icon: const Icon(LucideIcons.check, size: 14),
                  label: const Text('Confirm & Integrate Stock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                const Text('Delivered & Integrated into Hospital Stock', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedBankCard(BuildContext context, NearbyFacility bank, MockDataService mockService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.skyBlueLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.landmark, color: AppTheme.skyBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
                const SizedBox(height: 2),
                Text('${bank.distanceKm} km away • ${bank.phone}', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              mockService.requestBloodBankTransfer(
                bloodBankName: bank.name,
                bloodType: BloodType.oNeg,
                units: 2,
                courier: 'Rapid City Courier',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Transfer requisition sent to ${bank.name}')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Request Units', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ================= 7. PATIENT MANAGEMENT TAB =================
  Widget _buildPatientManagementTab(BuildContext context, MockDataService mockService) {
    final patients = mockService.hospitalPatients;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Registry & Clinical Blood Records',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage inpatient blood records, assigned units, emergency flags, and attending doctor directives.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          ...patients.map((p) => _buildPatientRecordCard(context, p, mockService)),
        ],
      ),
    );
  }

  Widget _buildPatientRecordCard(BuildContext context, HospitalPatientRecord p, MockDataService mockService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppTheme.skyBlueLight, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    p.bloodType.label,
                    style: const TextStyle(color: AppTheme.skyBlueDark, fontWeight: FontWeight.w900, fontSize: 14),
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
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${p.age} yrs)',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        if (p.isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.primaryRedLight, borderRadius: BorderRadius.circular(6)),
                            child: const Text('EMERGENCY', style: TextStyle(color: AppTheme.primaryRed, fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref ID: ${p.patientRefId} • Ward: ${p.ward}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text('${p.assignedUnits} Units', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                    const Text('ASSIGNED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text('Diagnosis: ${p.diagnosis}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 4),
          Text('Attending Physician: ${p.attendingPhysician}', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ================= 8. APPOINTMENT MANAGEMENT TAB =================
  Widget _buildAppointmentsTab(BuildContext context, MockDataService mockService) {
    final appointments = mockService.hospitalAppointments;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfusion & Crossmatch Schedule',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage upcoming patient appointments: Confirm, Reschedule, or Complete.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...appointments.map((apt) => _buildHospitalAppointmentCard(context, apt, mockService)),
        ],
      ),
    );
  }

  Widget _buildHospitalAppointmentCard(BuildContext context, HospitalAppointmentItem apt, MockDataService mockService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.skyBlue, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      apt.bloodType.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${apt.patientName} (${apt.patientRefId})',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: apt.status == HospitalAppointmentStatus.confirmed
                      ? const Color(0xFFECFDF5)
                      : (apt.status == HospitalAppointmentStatus.completed ? const Color(0xFFF1F5F9) : const Color(0xFFFFFBEB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apt.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: apt.status == HospitalAppointmentStatus.confirmed ? const Color(0xFF059669) : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Procedure: ${apt.procedureType} • Room: ${apt.room}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 2),
          Text(
            'Scheduled: ${apt.dateTime.day}/${apt.dateTime.month}/${apt.dateTime.year} at ${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600),
          ),
          if (apt.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Directives: ${apt.notes}', style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563))),
          ],
          const Divider(height: 20),
          Row(
            children: [
              if (apt.status != HospitalAppointmentStatus.completed) ...[
                OutlinedButton(
                  onPressed: () => mockService.confirmHospitalAppointment(apt.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Confirm', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: apt.dateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null && context.mounted) {
                      mockService.rescheduleHospitalAppointment(apt.id, date);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment Rescheduled')),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF64748B)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reschedule', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => mockService.completeHospitalAppointment(apt.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Mark Completed', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: Colors.red),
                  tooltip: 'Cancel Appointment',
                  onPressed: () => mockService.cancelHospitalAppointment(apt.id),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ================= 9. REPORTS AND ANALYTICS TAB =================
  Widget _buildReportsAnalyticsTab(BuildContext context, MockDataService mockService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clinical Blood Analytics & Reports',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Comprehensive audit of blood demand by group, usage, emergency velocities, and wastage tracking.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      FileDownloadService.downloadHospitalTransfusionAuditCsv(mockService);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hospital Transfusion Audit (.csv) exported & saved!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.fileSpreadsheet, size: 14, color: Colors.black),
                    label: const Text('Transfusions (CSV)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1.3),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      FileDownloadService.downloadHospitalClinicalReport(mockService);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('NABH Clinical Transfusion Audit (.html) downloaded & saved!'),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.download, size: 14, color: Colors.black),
                    label: const Text('Download Audit (HTML)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlueLight,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4 Main KPI Cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsStatCard(
                  title: 'Fulfillment Rate',
                  value: '96.8%',
                  subtitle: '+2.4% vs last month',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsStatCard(
                  title: 'Emergency Requests',
                  value: '42 Handled',
                  subtitle: 'Avg response: 14 min',
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsStatCard(
                  title: 'Inventory Turnover',
                  value: '18.4 Days',
                  subtitle: 'Optimal circulation',
                  color: AppTheme.skyBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsStatCard(
                  title: 'Expiry & Wastage',
                  value: '1.1%',
                  subtitle: 'Well under 2.5% ceiling',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Blood Demand & Usage Distribution Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blood Demand by Blood Group (Last 30 Days)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                ),
                const SizedBox(height: 16),
                _buildAnalyticsBar('O+ (Universal RBC Recipient)', 0.38, '185 Units (38%)', AppTheme.primaryRed),
                _buildAnalyticsBar('A+ (Cardio & Orthopedic)', 0.23, '110 Units (23%)', AppTheme.skyBlue),
                _buildAnalyticsBar('O- (Universal Emergency RBC)', 0.19, '94 Units (19%)', const Color(0xFFEF4444)),
                _buildAnalyticsBar('B+ (General Trauma)', 0.17, '84 Units (17%)', const Color(0xFFF59E0B)),
                _buildAnalyticsBar('AB+ / Rare Groups', 0.08, '40 Units (8%)', const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsBar(String title, double factor, String countText, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
              Text(countText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 10. NOTIFICATIONS TAB =================
  Widget _buildNotificationsTab(BuildContext context, MockDataService mockService) {
    final notifs = mockService.hospitalNotifications;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hospital Clinical Alerts (${notifs.length})',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
              ),
              TextButton(
                onPressed: () => mockService.markAllHospitalNotificationsRead(),
                child: const Text('Mark All Read', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (context, i) {
              final notif = notifs[i];
              IconData icon;
              Color color;

              switch (notif.type) {
                case 'emergency':
                  icon = LucideIcons.siren;
                  color = AppTheme.primaryRed;
                  break;
                case 'low_stock':
                  icon = LucideIcons.alertTriangle;
                  color = const Color(0xFFD97706);
                  break;
                case 'transfer_update':
                  icon = LucideIcons.truck;
                  color = AppTheme.skyBlue;
                  break;
                case 'donor_response':
                  icon = LucideIcons.userCheck;
                  color = const Color(0xFF10B981);
                  break;
                default:
                  icon = LucideIcons.calendarClock;
                  color = const Color(0xFF8B5CF6);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif.isCritical ? AppTheme.primaryRed : const Color(0xFFE2E8F0),
                    width: notif.isCritical ? 1.6 : 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
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
                              fontWeight: notif.isRead ? FontWeight.w700 : FontWeight.w900,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${notif.timestamp.hour}:${notif.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (!notif.isRead)
                      IconButton(
                        icon: const Icon(LucideIcons.check, size: 16, color: Colors.black),
                        onPressed: () => mockService.markHospitalNotificationRead(notif.id),
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

  // ================= MODALS & DIALOGS =================

  Widget _buildEmptyState(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context, MockDataService mockService) {
    final patientRefCtrl = TextEditingController(text: 'PAT-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}');
    final patientNameCtrl = TextEditingController();
    final wardCtrl = TextEditingController(text: 'Surgery Suite OR 4');
    final notesCtrl = TextEditingController();
    BloodType bloodType = BloodType.oNeg;
    int units = 2;
    HospitalRequestPriority priority = HospitalRequestPriority.urgent;
    DateTime requiredDate = DateTime.now().add(const Duration(hours: 4));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.filePlus, color: AppTheme.skyBlueDark, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Create Patient Requisition',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 17),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Info
                      const Text('PATIENT DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: patientRefCtrl,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'Patient ID',
                                labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: patientNameCtrl,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'Patient Full Name',
                                labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                                hintText: 'e.g. Rahul Sharma',
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: wardCtrl,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Ward / Operating Theater',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Blood Group Selection
                      const Text('REQUIRED BLOOD GROUP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: BloodType.values.map((t) {
                          final isSel = bloodType == t;
                          return GestureDetector(
                            onTap: () => setDialogState(() => bloodType = t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.black : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSel ? Colors.black : const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                t.label,
                                style: TextStyle(
                                  color: isSel ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Units Stepper
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UNITS REQUIRED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                              Text('Whole Blood / Packed RBC', style: TextStyle(fontSize: 10, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minus, size: 16, color: Colors.black),
                                  onPressed: units > 1 ? () => setDialogState(() => units--) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '$units Units',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.plus, size: 16, color: Colors.black),
                                  onPressed: units < 12 ? () => setDialogState(() => units++) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Priority Selection
                      const Text('CLINICAL PRIORITY LEVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: HospitalRequestPriority.values.map((p) {
                          final isSel = priority == p;
                          Color pColor;
                          switch (p) {
                            case HospitalRequestPriority.emergency:
                              pColor = AppTheme.primaryRed;
                              break;
                            case HospitalRequestPriority.urgent:
                              pColor = const Color(0xFFD97706);
                              break;
                            case HospitalRequestPriority.normal:
                              pColor = const Color(0xFF059669);
                              break;
                          }
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setDialogState(() => priority = p),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? pColor.withValues(alpha: 0.15) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? pColor : const Color(0xFFE2E8F0),
                                    width: isSel ? 1.6 : 1.0,
                                  ),
                                ),
                                child: Text(
                                  p.name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isSel ? pColor : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Clinical Notes
                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Clinical Directives / Surgery Notes',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          hintText: 'e.g. Emergency CABG pre-op crossmatch',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (patientNameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the patient full name.')),
                      );
                      return;
                    }
                    mockService.createHospitalPatientRequest(
                      patientRefId: patientRefCtrl.text,
                      patientName: patientNameCtrl.text,
                      ward: wardCtrl.text,
                      bloodType: bloodType,
                      unitsRequired: units,
                      priority: priority,
                      requiredDate: requiredDate,
                      clinicalNotes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Requisition created for ${patientNameCtrl.text} ($units Units of ${bloodType.label})!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.fileCheck2, size: 16, color: Colors.black),
                  label: const Text('Create Requisition', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlueLight,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRequestTransferDialog(BuildContext context, MockDataService mockService) {
    String bankName = 'Chiranjeevi Blood Centre & Eye Bank';
    BloodType bloodType = BloodType.oNeg;
    int units = 4;
    String courier = '108 GVK EMRI Priority Ambulance #24';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.truck, color: AppTheme.skyBlueDark, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Request Blood Bank Transfer',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 17),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TARGET REGIONAL BLOOD BANK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: bankName,
                        decoration: const InputDecoration(
                          labelText: 'Select Blood Bank',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Chiranjeevi Blood Centre & Eye Bank', child: Text('Chiranjeevi Blood Centre (1.4 km)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                          DropdownMenuItem(value: 'Indian Red Cross Society', child: Text('Indian Red Cross Society (3.6 km)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                          DropdownMenuItem(value: 'Rotary Central Blood Bank', child: Text('Rotary Central Blood Bank (2.8 km)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                          DropdownMenuItem(value: 'State Blood Transfusion Council', child: Text('State Transfusion Council (4.1 km)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => bankName = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text('BLOOD GROUP TO TRANSFER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: BloodType.values.map((t) {
                          final isSel = bloodType == t;
                          return GestureDetector(
                            onTap: () => setDialogState(() => bloodType = t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.black : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSel ? Colors.black : const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                t.label,
                                style: TextStyle(
                                  color: isSel ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UNITS TO TRANSFER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                              Text('Cold-chain transport verified', style: TextStyle(fontSize: 10, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minus, size: 16, color: Colors.black),
                                  onPressed: units > 1 ? () => setDialogState(() => units--) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '$units Units',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.plus, size: 16, color: Colors.black),
                                  onPressed: units < 25 ? () => setDialogState(() => units++) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text('COURIER TRANSPORT LOGISTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: courier,
                        decoration: const InputDecoration(
                          labelText: 'Transport Carrier',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: '108 GVK EMRI Priority Ambulance #24', child: Text('108 GVK EMRI Priority Ambulance (ETA ~12m)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                          DropdownMenuItem(value: 'Apollo MedSpeed Cold-Chain Van', child: Text('Apollo MedSpeed Cold-Chain Van (ETA ~20m)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                          DropdownMenuItem(value: 'Government Emergency Medical Courier', child: Text('Govt Emergency Medical Courier (ETA ~30m)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => courier = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    mockService.requestBloodBankTransfer(
                      bloodBankName: bankName,
                      bloodType: bloodType,
                      units: units,
                      courier: courier,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Requisition for $units units of ${bloodType.label} dispatched to $bankName!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.send, size: 16, color: Colors.black),
                  label: const Text('Send Transfer Request', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlueLight,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= INVENTORY COUNT ACCURACY EDITOR DIALOG =================
  void _showEditInventoryDialog(BuildContext context, MockDataService mockService, BloodType initialBloodType) {
    BloodType bloodType = initialBloodType;
    final currentGroup = mockService.hospitalInventory[bloodType];
    int available = currentGroup?.availableUnits ?? 10;
    int reserved = currentGroup?.reservedUnits ?? 2;
    int used = currentGroup?.usedUnits ?? 50;
    int expiring = currentGroup?.expiringUnits ?? 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final group = mockService.hospitalInventory[bloodType];

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.slidersHorizontal, color: AppTheme.skyBlueDark, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adjust Stock: ${bloodType.label}',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 17),
                        ),
                        const Text(
                          'Ensure 100% accurate clinical records',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blood Type Switcher
                      const Text('SELECT BLOOD GROUP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: BloodType.values.map((t) {
                          final isSel = bloodType == t;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                bloodType = t;
                                final g = mockService.hospitalInventory[t];
                                available = g?.availableUnits ?? 10;
                                reserved = g?.reservedUnits ?? 2;
                                used = g?.usedUnits ?? 50;
                                expiring = g?.expiringUnits ?? 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.black : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSel ? Colors.black : const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                t.label,
                                style: TextStyle(
                                  color: isSel ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 1. Available Units Stepper
                      _buildCountAdjustmentRow(
                        title: 'AVAILABLE UNITS (IN RESERVE)',
                        subtitle: 'Blood units ready for immediate assignment',
                        color: Colors.black,
                        count: available,
                        onDecrement: available > 0 ? () => setDialogState(() => available--) : null,
                        onIncrement: () => setDialogState(() => available++),
                      ),
                      const SizedBox(height: 12),

                      // 2. Reserved Units Stepper
                      _buildCountAdjustmentRow(
                        title: 'RESERVED UNITS (MATCHED / LOCKED)',
                        subtitle: 'Allocated for active inpatients or surgery ORs',
                        color: const Color(0xFFD97706),
                        count: reserved,
                        onDecrement: reserved > 0 ? () => setDialogState(() => reserved--) : null,
                        onIncrement: () => setDialogState(() => reserved++),
                      ),
                      const SizedBox(height: 12),

                      // 3. Used Units Stepper
                      _buildCountAdjustmentRow(
                        title: 'USED UNITS (LAST 30 DAYS)',
                        subtitle: 'Administered in transfusions & procedures',
                        color: const Color(0xFF059669),
                        count: used,
                        onDecrement: used > 0 ? () => setDialogState(() => used--) : null,
                        onIncrement: () => setDialogState(() => used++),
                      ),
                      const SizedBox(height: 12),

                      // 4. Expiring Units Stepper
                      _buildCountAdjustmentRow(
                        title: 'EXPIRING UNITS (WITHIN 7 DAYS)',
                        subtitle: 'Requires priority rotation or transfusion audit',
                        color: const Color(0xFFDC2626),
                        count: expiring,
                        onDecrement: expiring > 0 ? () => setDialogState(() => expiring--) : null,
                        onIncrement: () => setDialogState(() => expiring++),
                      ),

                      const SizedBox(height: 16),

                      // Stock status insight box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.checkCircle, size: 16, color: AppTheme.skyBlueDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Total ${bloodType.label} Inventory: ${available + reserved} units. Threshold is ${group?.minThreshold ?? 10} units.',
                                style: const TextStyle(fontSize: 11.5, color: Colors.black, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    mockService.updateHospitalInventoryStock(
                      bloodType: bloodType,
                      availableUnits: available,
                      reservedUnits: reserved,
                      usedUnits: used,
                      expiringUnits: expiring,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${bloodType.label} inventory data updated accurately! (Avail: $available, Res: $reserved, Used: $used, Exp: $expiring)'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.checkCheck, size: 16, color: Colors.black),
                  label: const Text('Save Accurate Stock Data', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlueLight,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCountAdjustmentRow({
    required String title,
    required String subtitle,
    required Color color,
    required int count,
    required VoidCallback? onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 1),
                Text(subtitle, style: const TextStyle(fontSize: 9.5, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.minus, size: 15, color: Colors.black),
                onPressed: onDecrement,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 36),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plus, size: 15, color: Colors.black),
                onPressed: onIncrement,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, MockDataService mockService, BloodType initialBloodType) {
    BloodType bloodType = initialBloodType;
    int units = 2;
    String source = 'Blood Bank Transfer';
    final batchCtrl = TextEditingController(text: 'BATCH-${DateTime.now().millisecondsSinceEpoch % 100000}');

    final sources = [
      'Blood Bank Transfer',
      'Donation Camp Collection',
      'Direct Donor Walk-in',
      'Emergency Reserve Dispatch',
      'Inter-Hospital Transfer',
      'Red Cross Regional Supply',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.packagePlus, color: AppTheme.skyBlueDark, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Add Blood Stock', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 17)),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blood Type Selection
                      const Text('BLOOD GROUP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<BloodType>(
                        initialValue: bloodType,
                        decoration: const InputDecoration(
                          labelText: 'Select Blood Group',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: BloodType.values.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => bloodType = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Units to Add
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UNITS TO ADD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                              Text('Units to integrate into reserve', style: TextStyle(fontSize: 10, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minus, size: 16, color: Colors.black),
                                  onPressed: units > 1 ? () => setDialogState(() => units--) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '$units Units',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.plus, size: 16, color: Colors.black),
                                  onPressed: units < 50 ? () => setDialogState(() => units++) : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Source Dropdown
                      const Text('SOURCE REPOSITORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: source,
                        decoration: const InputDecoration(
                          labelText: 'Stock Source',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: sources.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => source = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Batch Reference
                      TextField(
                        controller: batchCtrl,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Batch / Reference ID',
                          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.5)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Current stock info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.info, size: 16, color: AppTheme.skyBlueDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Current ${bloodType.label} stock: ${mockService.hospitalInventory[bloodType]?.availableUnits ?? 0} units. After adding: ${(mockService.hospitalInventory[bloodType]?.availableUnits ?? 0) + units} units.',
                                style: const TextStyle(fontSize: 11.5, color: Colors.black, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    mockService.addHospitalInventoryStock(
                      bloodType: bloodType,
                      units: units,
                      source: '$source (Ref: ${batchCtrl.text})',
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ $units units of ${bloodType.label} added to inventory from $source!'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.packagePlus, size: 16, color: Colors.black),
                  label: const Text('Add to Inventory', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.skyBlueLight,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ================= HOSPITAL DONOR SEARCH WIDGET =================
class _HospitalDonorSearchWidget extends StatefulWidget {
  final MockDataService mockService;
  const _HospitalDonorSearchWidget({required this.mockService});

  @override
  State<_HospitalDonorSearchWidget> createState() => _HospitalDonorSearchWidgetState();
}

class _HospitalDonorSearchWidgetState extends State<_HospitalDonorSearchWidget> {
  BloodType? _filterBloodType;
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final donors = widget.mockService.smartDonors;

    final filtered = donors.where((d) {
      final matchesSearch = _searchCtrl.text.isEmpty ||
          d.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
          d.city.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      if (_filterBloodType == null) return matchesSearch;
      return matchesSearch && d.bloodType == _filterBloodType;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hospital Direct Donor Search & Broadcast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search donor by name, district, or hospital proximity...',
                    prefixIcon: Icon(LucideIcons.search, size: 18),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Filter by Blood Group', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: const Text('All Donors'),
                          selected: _filterBloodType == null,
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(color: _filterBloodType == null ? Colors.white : Colors.black, fontWeight: FontWeight.w800),
                          onSelected: (selected) => setState(() => _filterBloodType = null),
                        ),
                      ),
                      ...BloodType.values.map((type) {
                        final isSel = _filterBloodType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(type.label),
                            selected: isSel,
                            selectedColor: Colors.black,
                            labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.w800),
                            onSelected: (selected) => setState(() => _filterBloodType = selected ? type : null),
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
          Text('Found Compatible Donors (${filtered.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 12),

          ...filtered.map((donor) => _buildDonorRow(donor)),
        ],
      ),
    );
  }

  Widget _buildDonorRow(DonorMatch donor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppTheme.primaryRedLight, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    donor.bloodType.label,
                    style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w900, fontSize: 15),
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
                        Text(donor.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: donor.availability == 'Available Now' ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            donor.availability,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: donor.availability == 'Available Now' ? const Color(0xFF059669) : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${donor.distanceKm} km away • ${donor.city}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                child: Text('${donor.matchPercentage}% MATCH', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Eligibility: ${donor.eligibility}', style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${donor.name}: ${donor.phone}')),
                  );
                },
                icon: const Icon(LucideIcons.phone, size: 14, color: Colors.black),
                label: const Text('Call Donor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('High-priority hospital alert transmitted to ${donor.name}!')),
                  );
                },
                icon: const Icon(LucideIcons.send, size: 14),
                label: const Text('Send Alert Notification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= 11. HOSPITAL SETTINGS WIDGET =================
class _HospitalSettingsWidget extends StatefulWidget {
  final MockDataService mockService;
  const _HospitalSettingsWidget({required this.mockService});

  @override
  State<_HospitalSettingsWidget> createState() => _HospitalSettingsWidgetState();
}

class _HospitalSettingsWidgetState extends State<_HospitalSettingsWidget> {
  double _hospitalMinThreshold = 15.0;
  bool _autoAmbulanceDispatch = true;
  bool _fastTrackCrossMatch = true;
  bool _doctorOnCallPager = true;
  String _hospitalContactPhone = '+91 40 2360 7777';
  String _emergencyHotline = '+91 91000 10800';
  String _ambulanceDesk = '+91 40 1066';

  @override
  Widget build(BuildContext context) {
    final mockService = widget.mockService;
    void showFeedback(String msg) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      );
    }

    void showEditHospitalModal() {
      final phoneCtrl = TextEditingController(text: _hospitalContactPhone);
      final hotlineCtrl = TextEditingController(text: _emergencyHotline);
      final ambCtrl = TextEditingController(text: _ambulanceDesk);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
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
                      const Text('Edit Hospital Clinical Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                      IconButton(icon: const Icon(LucideIcons.x, color: Colors.black), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('General Hospital Desk (+91)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: phoneCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Emergency Blood Requisition Hotline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: hotlineCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Ambulance Fleet Dispatch Desk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: ambCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        setState(() {
                          _hospitalContactPhone = phoneCtrl.text.trim().isEmpty ? _hospitalContactPhone : phoneCtrl.text.trim();
                          _emergencyHotline = hotlineCtrl.text.trim().isEmpty ? _emergencyHotline : hotlineCtrl.text.trim();
                          _ambulanceDesk = ambCtrl.text.trim().isEmpty ? _ambulanceDesk : ambCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                        showFeedback('Hospital contact numbers saved successfully!');
                      },
                      child: const Text('Save Contact Details', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hospital Clinical Desk Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: showEditHospitalModal,
                icon: const Icon(LucideIcons.pencil, size: 14),
                label: const Text('Edit Contacts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Configure emergency dispatch triggers, inventory thresholds, and regional blood bank sync.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Hospital Identity Card
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
                    const Text('HOSPITAL CREDENTIALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.8)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF10B981))),
                      child: const Text('NABH ACCREDITED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(mockService.hospitalName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 4),
                Text('License: ${mockService.hospitalLicenseId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
                Text('Location: ${mockService.hospitalLocation}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                const Divider(color: Color(0xFFE2E8F0), height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Emergency Hotline', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black87)),
                          Text(_emergencyHotline, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ambulance Fleet Desk', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black87)),
                          Text(_ambulanceDesk, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Inventory Threshold Alarm
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
                    const Text('Critical Blood Stock Alarm Limit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: Text('${_hospitalMinThreshold.toInt()} UNITS', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('When total available whole blood units in hospital ER drop below this threshold, automatic requisitions are broadcast to regional blood banks.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 12),
                Slider(
                  value: _hospitalMinThreshold,
                  min: 5,
                  max: 40,
                  divisions: 7,
                  activeColor: Colors.black,
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (v) => setState(() => _hospitalMinThreshold = v),
                  onChangeEnd: (v) => showFeedback('Critical stock buffer threshold set to ${v.toInt()} units'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Emergency Protocols
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
                const Text('Clinical Emergency Protocols', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Auto-Dispatch Ambulance for Level-1 SOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Automatically assign nearest trauma ambulance when trauma team confirms SOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: _autoAmbulanceDispatch,
                  onChanged: (v) {
                    setState(() => _autoAmbulanceDispatch = v);
                    showFeedback(v ? 'Auto-Dispatch Ambulance: ACTIVE' : 'Auto-Dispatch Ambulance: MANUAL');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Fast-Track Pre-Transfusion Cross-Matching', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Expedite O-negative universal donor release within 10 minutes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: _fastTrackCrossMatch,
                  onChanged: (v) {
                    setState(() => _fastTrackCrossMatch = v);
                    showFeedback(v ? 'Fast-Track Protocol: ENGAGED' : 'Fast-Track Protocol: STANDARD');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Duty Hematologist Priority Mobile Pager', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Instant high-frequency audio alert to on-duty blood bank medical officer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: _doctorOnCallPager,
                  onChanged: (v) {
                    setState(() => _doctorOnCallPager = v);
                    showFeedback(v ? 'Doctor Pager: ONLINE' : 'Doctor Pager: MUTED');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Network Sync & Audits
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
                const Text('Regional Network & Clinical Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.radio, color: Colors.black),
                  title: const Text('Ping Regional Blood Bank Grid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Verify live connection to State Blood Transfusion Council grid (e-RaktKosh)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.black),
                  onTap: () {
                    showFeedback('State Blood Transfusion Council Grid: CONNECTED (3 blood banks synchronized)');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.fileSpreadsheet, color: Colors.black),
                  title: const Text('Export Hospital Monthly Transfusion Audit (HTML & CSV)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Generate NABH & Directorate of Health Services compliant clinical register & audit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                  trailing: const Icon(LucideIcons.download, color: Colors.black),
                  onTap: () {
                    FileDownloadService.downloadHospitalTransfusionAuditCsv(widget.mockService);
                    FileDownloadService.downloadHospitalClinicalReport(widget.mockService);
                    showFeedback('Exporting Hospital Clinical Audit Report (HTML) & Transfusion Register (CSV)...');
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
