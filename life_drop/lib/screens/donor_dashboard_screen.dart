import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/donor_models.dart';
import '../models/patient_models.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/donor_donation_receipt_modal.dart';
import '../services/file_download_service.dart';

class DonorDashboardScreen extends StatefulWidget {
  final int initialTab;
  const DonorDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDonorCardBack = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  Future<void> _openGoogleMapsDirections(String destinationName, String address, {double? lat, double? lng}) async {
    if (mounted) {
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
                  'Opening real Google Maps directions to $destinationName...',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

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

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);
    final donor = mockService.donorProfile;
    final unreadNotifs = mockService.donorNotifications.where((n) => !n.isRead).length;

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
                color: AppTheme.primaryRedLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.heartPulse, size: 16, color: AppTheme.primaryRed),
                  SizedBox(width: 6),
                  Text(
                    'DONOR PORTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryRed,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Donor Dashboard',
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
          // Availability Quick Badge Indicator
          GestureDetector(
            onTap: () => _showAvailabilityModal(context, mockService, donor),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: donor.availability == DonorAvailabilityStatus.available
                    ? const Color(0xFFECFDF5)
                    : (donor.availability == DonorAvailabilityStatus.unavailable
                        ? const Color(0xFFFFFBEB)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: donor.availability == DonorAvailabilityStatus.available
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD97706),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: donor.availability == DonorAvailabilityStatus.available
                          ? const Color(0xFF10B981)
                          : const Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    donor.availability == DonorAvailabilityStatus.available ? 'AVAILABLE' : 'PAUSED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: donor.availability == DonorAvailabilityStatus.available
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Digital Donor Card Quick Action
          IconButton(
            icon: const Icon(LucideIcons.creditCard, color: Colors.black),
            tooltip: 'Digital Donor Card',
            onPressed: () => _switchTab(6),
          ),

          // Notifications
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Colors.black),
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
                  Tab(icon: Icon(LucideIcons.alertTriangle, size: 16), text: 'Emergency Calls'),
                  Tab(icon: Icon(LucideIcons.sparkles, size: 16), text: 'Smart Matches'),
                  Tab(icon: Icon(LucideIcons.calendar, size: 16), text: 'Book Slot'),
                  Tab(icon: Icon(LucideIcons.tent, size: 16), text: 'Donation Camps'),
                  Tab(icon: Icon(LucideIcons.history, size: 16), text: 'Donation History'),
                  Tab(icon: Icon(LucideIcons.creditCard, size: 16), text: 'Donor Card'),
                  Tab(icon: Icon(LucideIcons.gitCommit, size: 16), text: 'Activity Timeline'),
                  Tab(icon: Icon(LucideIcons.mapPin, size: 16), text: 'Nearby Centers'),
                  Tab(icon: Icon(LucideIcons.award, size: 16), text: 'Certificate'),
                  Tab(icon: Icon(LucideIcons.zap, size: 16), text: 'Activeness'),
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
          _buildOverviewTab(context, mockService, donor),
          _buildEmergencyCallsTab(context, mockService),
          _buildSmartMatchesTab(context, mockService, donor),
          _buildAppointmentBookingTab(context, mockService),
          _buildDonationCampsTab(context, mockService),
          _buildDonationHistoryTab(context, mockService, donor),
          _buildDigitalDonorCardTab(context, mockService, donor),
          _buildActivityTimelineTab(context, mockService),
          _buildNearbyCentersTab(context, mockService),
          _buildCertificateTab(context, mockService),
          _buildActivenessTab(context, mockService),
          _buildSettingsTab(context, mockService, donor),
        ],
      ),
    );
  }

  // ================= 1. DONOR OVERVIEW TAB =================
  Widget _buildOverviewTab(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donor Profile Card with Actions (Compact iOS Card)
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
                        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.user, size: 22, color: AppTheme.primaryRed),
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
                                donor.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
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
                                  donor.bloodType.label,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Donor ID: ${donor.id} • ${donor.verificationBadge}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${donor.phone} • ${donor.email}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.edit3, color: Colors.black, size: 18),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditDonorProfileModal(context, mockService, donor),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 13, color: Color(0xFF4B5563)),
                        const SizedBox(width: 4),
                        Text(donor.location, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black)),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAvailabilityModal(context, mockService, donor),
                      icon: const Icon(LucideIcons.sliders, size: 13, color: Colors.black),
                      label: Text(donor.availability.label, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Compact Top Summary Cards Grid (Responsive 4 on desktop, 2 on mobile)
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 650 ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: MediaQuery.of(context).size.width < 650 ? 2.5 : 2.1,
            children: [
              _buildTopSummaryCard(
                title: 'Blood Group',
                value: donor.bloodType.label,
                subtitle: 'Universal Donor',
                icon: LucideIcons.droplet,
                color: AppTheme.primaryRed,
              ),
              _buildTopSummaryCard(
                title: 'Availability Status',
                value: donor.availability == DonorAvailabilityStatus.available ? 'Active' : 'Paused',
                subtitle: '${donor.maxTravelDistanceKm.toInt()} km radius set',
                icon: LucideIcons.checkCircle,
                color: const Color(0xFF10B981),
              ),
              _buildTopSummaryCard(
                title: 'Next Eligible Date',
                value: 'Eligible Now',
                subtitle: 'Last donated: 95d ago',
                icon: LucideIcons.calendarCheck,
                color: AppTheme.skyBlue,
              ),
              _buildTopSummaryCard(
                title: 'Total Donations',
                value: '${donor.totalDonations} Donations',
                subtitle: '${donor.donationsThisYear} this calendar year',
                icon: LucideIcons.award,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Compact Donation Eligibility Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981), width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF059669), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Eligibility: Fully Cleared',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Minimum 90-day cooldown completed. Pre-screened with no restrictions.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _switchTab(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Book Slot', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Emergency Blood Requests Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Emergency Blood Calls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              TextButton(
                onPressed: () => _switchTab(1),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text('View All Calls →', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...mockService.donorEmergencyRequests.take(2).map((req) => _buildEmergencyCard(context, req, mockService)),

          const SizedBox(height: 18),

          // Motivational & Factual Contribution Section (Compact)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.award, color: AppTheme.primaryRed, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Donor Impact & Verified Contributions',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildImpactColumn('8 Units', 'Total Units Donated', AppTheme.primaryRed),
                    _buildImpactColumn('2 Camps', 'Donation Camps Attended', AppTheme.skyBlue),
                    _buildImpactColumn('8 Sessions', 'Completed Appointments', const Color(0xFF10B981)),
                    _buildImpactColumn('Tier Gold', 'Community Milestone', const Color(0xFF8B5CF6)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your verified contributions help maintain critical trauma and neonatal reserve levels across regional hospitals.',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactColumn(String val, String label, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF374151), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ================= 2. EMERGENCY BLOOD REQUESTS TAB =================
  Widget _buildEmergencyCallsTab(BuildContext context, MockDataService mockService) {
    final calls = mockService.donorEmergencyRequests;

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
                  decoration: BoxDecoration(color: AppTheme.primaryRedLight, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.siren, color: AppTheme.primaryRed, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Urgent Emergency Blood Calls Matching O-',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Hospitals within your 15 km radius in critical need of compatible blood. Accept or respond later.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Active Emergency Requests (${calls.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 12),
          ...calls.map((req) => _buildEmergencyCard(context, req, mockService)),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, DonorEmergencyRequestItem req, MockDataService mockService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: req.status == DonorRequestStatus.accepted
              ? const Color(0xFF10B981)
              : AppTheme.primaryRed.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(8)),
                child: Text(req.requiredBloodType.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(req.hospitalName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.primaryRedLight, borderRadius: BorderRadius.circular(6)),
                          child: Text(req.urgencyLevel, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w900, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${req.distanceKm} km away • ${req.hospitalLocation}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Clinical Directive: ${req.notes}', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            'Needed by: ${req.requiredDateTime.day}/${req.requiredDateTime.month} at ${req.requiredDateTime.hour}:${req.requiredDateTime.minute.toString().padLeft(2, '0')} • Units: ${req.unitsRequired}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w700),
          ),
          const Divider(height: 20),
          Row(
            children: [
              if (req.status == DonorRequestStatus.accepted) ...[
                const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                const Text('Accepted! Hospital desk notified.', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 13)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling Hospital Emergency Desk: ${req.hospitalPhone}')),
                    );
                  },
                  icon: const Icon(LucideIcons.phone, size: 14, color: Colors.black),
                  label: const Text('Contact Hospital', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => _showAcceptConfirmationDialog(context, mockService, req),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Accept Call', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    mockService.respondLaterDonorEmergencyRequest(req.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text('Request from ${req.hospitalName} postponed to respond later.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Respond Later', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    mockService.declineDonorEmergencyRequest(req.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text('Request from ${req.hospitalName} declined.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Decline', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.phone, size: 16, color: Colors.black),
                  tooltip: 'Contact Hospital Desk',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling: ${req.hospitalPhone}')),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showAcceptConfirmationDialog(BuildContext context, MockDataService mockService, DonorEmergencyRequestItem req) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Emergency Acceptance', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          content: Text(
            'Are you sure you can attend ${req.hospitalName} within the next 60 minutes to donate ${req.unitsRequired} units of ${req.requiredBloodType.label}?\n\nThe hospital clinical trauma team will be immediately notified of your arrival.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                mockService.acceptDonorEmergencyRequest(req.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF10B981),
                    content: Text('EMERGENCY RESPONSE CONFIRMED - Hospital Desk Notified'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed, foregroundColor: Colors.white),
              child: const Text('I Confirm - I Am On My Way', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
  }

  // ================= 3. SMART DONOR MATCHING TAB =================
  Widget _buildSmartMatchesTab(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
    final matches = mockService.donorSmartMatches;

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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.skyBlueLight, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.sparkles, color: AppTheme.skyBlue, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Smart Compatibility Matching',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Requisitions and patients matched based on blood compatibility, your availability slot, travel radius & past donation safety history.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Match percentages represent algorithmic compatibility indicators, not a medical guarantee.',
                        style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('High Compatibility Matches (${matches.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 12),
          ...matches.map((m) => _buildSmartMatchCard(context, m)),
        ],
      ),
    );
  }

  Widget _buildSmartMatchCard(BuildContext context, DonorSmartMatchItem m) {
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                child: Text('${m.matchPercentage}% MATCH', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.patientOrRequestId, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
                    Text('${m.distanceKm} km • ${m.hospitalName}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                child: Text(m.urgency, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Compatibility Rationale: ${m.reasonForMatch}', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
          const Divider(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Slot requisition confirmed for ${m.hospitalName}!')),
                  );
                },
                icon: const Icon(LucideIcons.calendarCheck, size: 14),
                label: const Text('Schedule for this Need', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
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

  // ================= 4. DONATION APPOINTMENT BOOKING TAB =================
  Widget _buildAppointmentBookingTab(BuildContext context, MockDataService mockService) {
    final appointments = mockService.donorAppointments;

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
                  const Text('Donation Appointments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(height: 2),
                  const Text('Find nearby centers, view open slots, book and manage appointments.', style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showBookAppointmentDialog(context, mockService),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Book Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...appointments.map((apt) => _buildDonorAppointmentCard(context, apt, mockService)),
        ],
      ),
    );
  }

  Widget _buildDonorAppointmentCard(BuildContext context, DonorAppointmentItem apt, MockDataService mockService) {
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
              Text(apt.centerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: apt.status == DonorAppointmentStatus.confirmed ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  apt.status.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: apt.status == DonorAppointmentStatus.confirmed ? const Color(0xFF059669) : Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(apt.address, style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Date: ${apt.dateTime.day}/${apt.dateTime.month}/${apt.dateTime.year} at ${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')} • Open Slots: ${apt.availableSlots}',
            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w800),
          ),
          if (apt.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Prep notes: ${apt.notes}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ],
          const Divider(height: 20),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openGoogleMapsDirections(apt.centerName, apt.address),
                icon: const Icon(LucideIcons.navigation, size: 14, color: Colors.black),
                label: const Text('Directions (Google Maps)', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
              ),
              const SizedBox(width: 8),
              if (apt.status != DonorAppointmentStatus.cancelled) ...[
                TextButton(
                  onPressed: () => mockService.cancelDonorAppointment(apt.id),
                  child: const Text('Cancel Slot', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showBookAppointmentDialog(BuildContext context, MockDataService mockService) {
    String center = 'Metropolitan Central Blood Center';
    String address = '140 Healthcare Ave, New York, NY';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3, hours: 2));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Book Donation Appointment', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: center,
                decoration: const InputDecoration(labelText: 'Donation Center'),
                items: const [
                  DropdownMenuItem(value: 'Metropolitan Central Blood Center', child: Text('Metropolitan Central (1.4 km)')),
                  DropdownMenuItem(value: 'American Red Cross Downtown Reserve', child: Text('American Red Cross (3.6 km)')),
                  DropdownMenuItem(value: 'St. Jude Regional Blood Center', child: Text('St. Jude Regional (2.8 km)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    center = val;
                    if (val.contains('Red Cross')) address = '520 W 49th St, NY';
                    if (val.contains('St. Jude')) address = '225 Lexington Ave, NY';
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Scheduled Slot: 3 Days from now, 10:00 AM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.black))),
            ElevatedButton(
              onPressed: () {
                mockService.bookDonorAppointment(
                  centerName: center,
                  address: address,
                  dateTime: selectedDate,
                  notes: 'Whole blood donation slot booked via VitalPulse Donor Portal.',
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appointment confirmed at $center!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('Confirm Appointment', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  // ================= 5. DONATION CAMPS TAB =================
  Widget _buildDonationCampsTab(BuildContext context, MockDataService mockService) {
    final camps = mockService.donorCamps;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming Blood Donation Camps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 4),
          const Text('Community mobile blood drives with certified medical teams, refreshments, and volunteer certificates.', style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          ...camps.map((camp) => _buildCampCard(context, camp, mockService)),
        ],
      ),
    );
  }

  Widget _buildCampCard(BuildContext context, DonorCampItem camp, MockDataService mockService) {
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
              Expanded(
                child: Text(camp.campName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: camp.isRegistered ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  camp.isRegistered ? 'REGISTERED' : 'OPEN SLOTS (${camp.availableSlots})',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: camp.isRegistered ? const Color(0xFF059669) : Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Organizer: ${camp.organizer}', style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Dates: ${camp.date} (${camp.time}) • ${camp.distanceKm} km away', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(camp.location, style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
          const SizedBox(height: 6),
          Text(camp.description, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const Divider(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => mockService.toggleCampRegistration(camp.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: camp.isRegistered ? Colors.red : Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(camp.isRegistered ? 'Cancel Registration' : 'Register for Camp', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => mockService.toggleCampReminder(camp.id),
                icon: Icon(camp.hasReminder ? LucideIcons.bellRing : LucideIcons.bell, size: 14, color: Colors.black),
                label: Text(camp.hasReminder ? 'Reminder Set' : 'Add Reminder', style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 6. DONATION HISTORY TAB =================
  Widget _buildDonationHistoryTab(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
    final history = mockService.donorHistory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Donation History & Certificates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 4),
          const Text('Verified digital records of your whole blood, platelet, and camp contributions. Tap any receipt to view recipient allocation.', style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          // Statistics Header
          Row(
            children: [
              _buildHistoryStatCard('Total Donations', '${history.length} Sessions'),
              const SizedBox(width: 10),
              _buildHistoryStatCard('Units Donated', '${history.length} Units'),
              const SizedBox(width: 10),
              _buildHistoryStatCard('Recent Date', '95d Ago'),
            ],
          ),
          const SizedBox(height: 24),

          ...history.map((rec) => _buildHistoryCard(context, rec, donor)),
        ],
      ),
    );
  }

  Widget _buildHistoryStatCard(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF4B5563))),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, DonorHistoryRecord rec, DonorProfileModel donor) {
    return InkWell(
      onTap: () => DonorDonationReceiptModal.show(context, record: rec, donor: donor),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.primaryRedLight, shape: BoxShape.circle),
              child: const Icon(LucideIcons.checkCheck, color: AppTheme.primaryRed, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.donationCenter, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(
                    '${rec.unitsDonated} Unit (${rec.bloodType.label}) • Date: ${rec.donationDate.day}/${rec.donationDate.month}/${rec.donationDate.year}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.userCheck, size: 11, color: Color(0xFF0284C7)),
                            const SizedBox(width: 4),
                            Text(
                              'Recipient: ${rec.recipientName} (${rec.recipientHospital.split(',').first})',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => DonorDonationReceiptModal.show(context, record: rec, donor: donor),
              icon: const Icon(LucideIcons.receipt, size: 14, color: Colors.white),
              label: const Text('Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 7. DIGITAL DONOR CARD TAB =================
  Widget _buildDigitalDonorCardTab(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
    final qrData = 'https://vitalpulse.org/verify/donor?id=${donor.id}&blood=${donor.bloodType.label}&name=${Uri.encodeComponent(donor.name)}&units=${donor.totalDonations}&status=ELIGIBLE';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.creditCard, color: AppTheme.primaryRed, size: 22),
              const SizedBox(width: 8),
              const Text('Digital Donor Identification Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Official verifiable digital identity credential for clinical registration at hospitals and blood camps.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Front / Back View Switcher Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showDonorCardBack = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_showDonorCardBack ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.idCard, size: 14, color: !_showDonorCardBack ? Colors.white : Colors.black87),
                        const SizedBox(width: 6),
                        Text(
                          'Front View',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: !_showDonorCardBack ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showDonorCardBack = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: _showDonorCardBack ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.barcode, size: 14, color: _showDonorCardBack ? Colors.white : Colors.black87),
                        const SizedBox(width: 6),
                        Text(
                          'Back View (Barcode & Medical)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _showDonorCardBack ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Realistic Physical Card Container (Front or Back)
          GestureDetector(
            onTap: () => setState(() => _showDonorCardBack = !_showDonorCardBack),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A), // Slate 900
                    Color(0xFF1E293B), // Slate 800
                    Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: !_showDonorCardBack
                    ? _buildRealisticCardFront(donor, qrData)
                    : _buildRealisticCardBack(donor),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.repeat, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 5),
              Text(
                'Tap card to flip between Front Identification & Back Medical Barcode',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Action Buttons: Test Scanner, Download, Print, Add to Wallet
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showScanPreviewModal(context, donor, qrData),
                icon: const Icon(LucideIcons.scanLine, size: 15, color: Colors.white),
                label: const Text('Test Scan QR Code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.skyBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  FileDownloadService.downloadDonorCard(donor);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      content: Row(
                        children: [
                          const Icon(LucideIcons.fileCheck, color: AppTheme.skyBlue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Digital Donor Card (VitalPulse_DonorCard_${donor.name.replaceAll(' ', '_')}.html) downloaded & saved!',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.download, size: 15, color: Colors.black),
                label: const Text('Download ID Card', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  FileDownloadService.downloadDonorCard(donor);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      content: const Row(
                        children: [
                          Icon(LucideIcons.printer, color: AppTheme.skyBlue, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Digital ID Card generated & ready for printing!',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.printer, size: 15, color: Colors.black),
                label: const Text('Print Card', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF0F172A),
                      content: Text('Added to Apple Wallet & Google Wallet Passes!'),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.wallet, size: 15, color: Colors.black),
                label: const Text('Add to Wallet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Realistic Front of Card
  Widget _buildRealisticCardFront(DonorProfileModel donor, String qrData) {
    return Container(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: VitalPulse branding + National Program Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.heartPulse, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VitalPulse',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'NATIONAL DONOR REGISTRY',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w800,
                          fontSize: 8.5,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.shieldCheck, color: Color(0xFF34D399), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'VERIFIED VOLUNTARY DONOR',
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // EMV Gold Chip & Contactless Wave
          Row(
            children: [
              // Realistic Gold Metallic Microchip
              Container(
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37), Color(0xFFECC94B), Color(0xFFB7791F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF975A16), width: 0.8),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _EmvChipCircuitPainter(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Contactless NFC Wave Icon
              Transform.rotate(
                angle: 1.57,
                child: const Icon(LucideIcons.wifi, color: Colors.white70, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'VAL: 12/2029 • CAT: VOLUNTARY',
                  style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Card Body: Donor Info + Big Blood Group Emblem
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo / Verified Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.skyBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                ),
                child: const Center(
                  child: Icon(LucideIcons.user, size: 28, color: Color(0xFF38BDF8)),
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: VP-IND-${donor.id}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${donor.totalDonations} UNITS DONATED',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CLEARED FOR DONATION',
                            style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Prominent Blood Group Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRed.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      donor.bloodType.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'RH POSITIVE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),

          // Bottom Bar: REAL Scannable QR Code & Verification Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // REAL Scannable QR Code using qr_flutter
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 74,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.qrCode, color: Color(0xFF38BDF8), size: 13),
                        SizedBox(width: 4),
                        Text(
                          'CLINICAL VERIFICATION QR',
                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Scan with any smartphone or hospital terminal to verify active blood clearance & medical records.',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 9.5, height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SECURE TOKEN: SHA256#${donor.id.hashCode.abs().toRadixString(16).toUpperCase()}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Realistic Back of Card
  Widget _buildRealisticCardBack(DonorProfileModel donor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Magnetic Swipe Stripe
          Container(
            height: 42,
            width: double.infinity,
            color: const Color(0xFF020617), // pitch black magnetic band
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Signature Strip & Emergency Number
                Row(
                  children: [
                    // White Signature Panel
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              donor.name,
                              style: const TextStyle(
                                fontFamily: 'cursive',
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'AUTHORIZED SIGNATURE',
                              style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Security CVC/CID
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CVC: ${donor.id.hashCode.abs() % 900 + 100}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Medical Barcode Graphic (Realistic Code 128 / ISBT 128)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 32),
                        painter: _MedicalBarcodePainter(code: '=VP${donor.id}'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '*=VP-${donor.id}-${donor.bloodType.label}*',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: Colors.black,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Medical Clearance Notes
                Row(
                  children: [
                    const Icon(LucideIcons.heartHandshake, size: 14, color: AppTheme.skyBlue),
                    const SizedBox(width: 6),
                    const Text(
                      'Pledged Organ & Tissue Donor: YES',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('TTI SCREEN: NEGATIVE', style: TextStyle(color: Color(0xFF34D399), fontSize: 8.5, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                const Text(
                  '24/7 National Emergency Blood Helpline: 1800-11-VITAL (84825) • sbtc.gov.in',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This card certifies voluntary donor enrollment under the National Blood Transfusion Council regulations. Misuse is punishable by law.',
                  style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Clinical Scanner Preview Modal
  void _showScanPreviewModal(BuildContext context, DonorProfileModel donor, String qrData) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.scanLine, color: Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terminal QR Scanner', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                  Text('Hospital Clinical Intake Preview', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Donor Name: ${donor.name}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.primaryRed, borderRadius: BorderRadius.circular(4)),
                          child: Text(donor.bloodType.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Donor ID: VP-IND-${donor.id}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                    Text('Verification Status: Certified Active (NABH)', style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                    Text('Total Units Given: ${donor.totalDonations} units', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    Text('Cooldown Status: 95 days elapsed • Ready to donate', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Scanned Raw QR Payload:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  qrData,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('Close Scanner Preview', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  // ================= 8. ACTIVITY TIMELINE TAB =================
  Widget _buildActivityTimelineTab(BuildContext context, MockDataService mockService) {
    final timeline = mockService.donorTimeline;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Donor Activity & Contribution Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 4),
          const Text('Track all profile adjustments, camp attendances, accepted emergency requests, and eligibility resets.', style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          ...timeline.map((item) => _buildTimelineItem(item)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(DonorTimelineItem item) {
    IconData icon;
    Color color;

    switch (item.category) {
      case 'emergency':
        icon = LucideIcons.siren;
        color = AppTheme.primaryRed;
        break;
      case 'donation':
        icon = LucideIcons.heartHandshake;
        color = const Color(0xFF10B981);
        break;
      case 'appointment':
        icon = LucideIcons.calendar;
        color = AppTheme.skyBlue;
        break;
      case 'camp':
        icon = LucideIcons.tent;
        color = const Color(0xFF8B5CF6);
        break;
      default:
        icon = LucideIcons.check;
        color = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black)),
                      Text('${item.timestamp.day}/${item.timestamp.month}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.description, style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 9. NEARBY CENTERS TAB =================
  Widget _buildNearbyCentersTab(BuildContext context, MockDataService mockService) {
    final facilities = mockService.nearbyFacilities;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nearby Donation Centers & Hospitals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 4),
          const Text('Accredited blood banks and health facilities open for walk-in or booked donations.', style: TextStyle(fontSize: 12, color: Color(0xFF1F2937), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          ...facilities.map((fac) => _buildCenterRow(context, fac)),
        ],
      ),
    );
  }

  Widget _buildCenterRow(BuildContext context, NearbyFacility fac) {
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
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.mapPin, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fac.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
                const SizedBox(height: 2),
                Text('${fac.distanceKm} km • ${fac.address}', style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                Text(fac.openHours, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _openGoogleMapsDirections(
              fac.name,
              '${fac.address}, ${fac.city}',
              lat: fac.latitude,
              lng: fac.longitude,
            ),
            icon: const Icon(LucideIcons.mapPin, size: 12, color: Colors.black),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            label: const Text('Directions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ================= 10. SETTINGS & PREFERENCES TAB =================
  Widget _buildSettingsTab(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
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

    void showRadiusPicker() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setInner) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Travel Radius for Emergency Calls',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            '${donor.maxTravelDistanceKm.toInt()} KM',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You will only receive emergency broadcast alerts from hospitals and patients within this travel distance.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: donor.maxTravelDistanceKm,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      activeColor: Colors.black,
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (v) {
                        setInner(() => donor.maxTravelDistanceKm = v);
                        setState(() {});
                      },
                      onChangeEnd: (v) {
                        mockService.updateDonorActiveness(customRadiusKm: v);
                        showFeedback('Travel radius saved: ${v.toInt()} km');
                      },
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Confirm Travel Radius', style: TextStyle(fontWeight: FontWeight.w800)),
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

    void showTimePickerModal() {
      final times = [
        'Anytime 24/7 (Emergency Dispatch)',
        'Weekends Only (Sat - Sun, 9 AM - 6 PM)',
        'Evenings (Mon - Fri, 5 PM - 9 PM)',
        'Mornings Only (7 AM - 12 PM)',
        'By Scheduled Appointment Only',
      ];
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
                const Text('Preferred Donation Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 14),
                ...times.map((t) {
                  final isSelected = donor.availableDaysTimes == t;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(LucideIcons.clock, color: isSelected ? const Color(0xFF0284C7) : Colors.black),
                    title: Text(t, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: Colors.black)),
                    trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF0284C7)) : null,
                    onTap: () {
                      setState(() => donor.availableDaysTimes = t);
                      Navigator.pop(ctx);
                      showFeedback('Donation availability updated: $t');
                    },
                  );
                }),
              ],
            ),
          );
        },
      );
    }

    void showNotificationChannelModal() {
      final channels = [
        'WhatsApp + SMS Priority Dispatch',
        'App Push Notifications Only',
        'Direct Emergency Phone Calls',
        'Email Transfusion Alerts',
      ];
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
                const Text('Select Alert Channel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 14),
                ...channels.map((c) {
                  final isSelected = donor.preferredNotificationMethod == c;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(LucideIcons.messageSquare, color: isSelected ? const Color(0xFF0284C7) : Colors.black),
                    title: Text(c, style: TextStyle(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: Colors.black)),
                    trailing: isSelected ? const Icon(LucideIcons.check, color: Color(0xFF0284C7)) : null,
                    onTap: () {
                      setState(() => donor.preferredNotificationMethod = c);
                      Navigator.pop(ctx);
                      showFeedback('Preferred alert channel updated to: $c');
                    },
                  );
                }),
              ],
            ),
          );
        },
      );
    }

    void showEditDonorProfileModal() {
      final nameCtrl = TextEditingController(text: donor.name);
      final phoneCtrl = TextEditingController(text: donor.phone);
      final emailCtrl = TextEditingController(text: donor.email);
      final locCtrl = TextEditingController(text: donor.location);

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
                      const Text('Edit Donor Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                      IconButton(icon: const Icon(LucideIcons.x, color: Colors.black), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: nameCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Phone (+91)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: phoneCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: emailCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('City / Locality', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: locCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        setState(() {
                          donor.name = nameCtrl.text.trim().isEmpty ? donor.name : nameCtrl.text.trim();
                          donor.phone = phoneCtrl.text.trim().isEmpty ? donor.phone : phoneCtrl.text.trim();
                          donor.email = emailCtrl.text.trim().isEmpty ? donor.email : emailCtrl.text.trim();
                          donor.location = locCtrl.text.trim().isEmpty ? donor.location : locCtrl.text.trim();
                        });
                        Navigator.pop(ctx);
                        showFeedback('Donor profile saved: ${donor.name}');
                      },
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
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
          const Text('Donor Settings & Privacy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 6),
          const Text(
            'Configure your donation broadcast radius, schedule preferences, and notification channels.',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Profile Summary Card
          InkWell(
            onTap: showEditDonorProfileModal,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(donor.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(donor.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                        Text('${donor.phone} • ${donor.email}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
                        Text(donor.location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.pencil, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Availability preferences
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Availability & Broadcast Preferences', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.navigation, color: Colors.black),
                  title: const Text('Travel Radius for Emergency Calls', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  subtitle: Text('${donor.maxTravelDistanceKm.toInt()} km from home/office location', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.black),
                  onTap: showRadiusPicker,
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.clock, color: Colors.black),
                  title: const Text('Preferred Times', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  subtitle: Text(donor.availableDaysTimes, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.black),
                  onTap: showTimePickerModal,
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.messageSquare, color: Colors.black),
                  title: const Text('Notification Channel', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  subtitle: Text(donor.preferredNotificationMethod, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  trailing: const Icon(LucideIcons.chevronRight, color: Colors.black),
                  onTap: showNotificationChannelModal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Privacy & Support
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Support & Legal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.award, color: Colors.black),
                  title: const Text('Download Digital Donor Card & Certificate', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  subtitle: const Text('Instant printable card & certificate with QR authentication', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 12)),
                  onTap: () {
                    FileDownloadService.downloadDonorCard(donor);
                    FileDownloadService.downloadCertificate(donor, cert: mockService.donorCertificate);
                    showFeedback('Digital Donor Card & Life-Saver Certificate downloaded and saved to device storage!');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.helpCircle, color: Colors.black),
                  title: const Text('Donor Help Center & FAQ', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  subtitle: const Text('Eligibility criteria, recovery guidelines & Indian SBTC norms', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 12)),
                  onTap: () {
                    showFeedback('Donor Care Support Desk: 1800-11-2478 (Toll-Free)');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.shieldCheck, color: Colors.black),
                  title: const Text('Data Protection & Medical Confidentiality', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  subtitle: const Text('DISHA & HIPAA compliant medical records encryption', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 12)),
                  onTap: () {
                    showFeedback('Your donor health records are encrypted and protected under Indian Medical Standards.');
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

  // ================= MODALS =================

  void _showAvailabilityModal(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
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
              const Text('Update Availability Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981)),
                title: const Text('Available to Donate', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                subtitle: const Text('Broadcast active emergency calls and smart donor matches'),
                onTap: () {
                  mockService.setDonorAvailability(DonorAvailabilityStatus.available);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.pauseCircle, color: Color(0xFFF59E0B)),
                title: const Text('Temporarily Unavailable', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                subtitle: const Text('Pause notifications while traveling or busy'),
                onTap: () {
                  mockService.setDonorAvailability(DonorAvailabilityStatus.unavailable);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.alertCircle, color: Colors.red),
                title: const Text('Not Eligible Currently', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                subtitle: const Text('Within post-donation rest or doctor restriction'),
                onTap: () {
                  mockService.setDonorAvailability(DonorAvailabilityStatus.ineligible);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDonorProfileModal(BuildContext context, MockDataService mockService, DonorProfileModel donor) {
    final nameCtrl = TextEditingController(text: donor.name);
    final phoneCtrl = TextEditingController(text: donor.phone);
    final emailCtrl = TextEditingController(text: donor.email);
    final locCtrl = TextEditingController(text: donor.location);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Donor Profile', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 10),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location / City')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.black))),
            ElevatedButton(
              onPressed: () {
                mockService.updateDonorProfileDetails(
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  email: emailCtrl.text,
                  location: locCtrl.text,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donor Profile Updated!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }

  // ================= CERTIFICATE CUSTOMIZER TAB =================
  Widget _buildCertificateTab(BuildContext context, MockDataService mockService) {
    final cert = mockService.donorCertificate;
    final titleCtrl = TextEditingController(text: cert.customTitle);
    final pledgeCtrl = TextEditingController(text: cert.customPledgeMessage);
    final sigCtrl = TextEditingController(text: cert.signatureTitle);

    final themes = ['Gold Royal', 'Sapphire Clinical', 'Emerald Vitality', 'Platinum Minimal'];
    final themeColors = {
      'Gold Royal': const Color(0xFFD4A017),
      'Sapphire Clinical': const Color(0xFF2563EB),
      'Emerald Vitality': const Color(0xFF059669),
      'Platinum Minimal': const Color(0xFF6B7280),
    };

    return StatefulBuilder(
      builder: (context, setInnerState) {
        final activeColor = themeColors[cert.certificateTheme] ?? const Color(0xFFD4A017);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Certificate Customizer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(height: 4),
              const Text('Design and customize your blood donation certificate', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              // Live Certificate Preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: activeColor.withValues(alpha: 0.4), width: 2),
                  boxShadow: [
                    BoxShadow(color: activeColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    if (cert.includeWatermark)
                      Icon(LucideIcons.droplets, size: 40, color: activeColor.withValues(alpha: 0.15)),
                    const SizedBox(height: 8),
                    Text('VITALPULSE LIFESAVER SOCIETY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: activeColor, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(cert.customTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: activeColor)),
                    const SizedBox(height: 12),
                    Text('Presented to', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(cert.donorName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                    const SizedBox(height: 4),
                    Text('Blood Group: ${cert.bloodGroup}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(cert.customPledgeMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: activeColor, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Units Donated: ${cert.unitsDonated}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                            Text('Date: ${cert.issueDate}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(cert.centerName, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                            Text(cert.signatureTitle, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                    if (cert.includeQrVerification) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.qrCode, size: 14, color: Colors.black),
                            const SizedBox(width: 6),
                            Text('Verify: ${cert.certificateId}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Theme Selector
              const Text('CERTIFICATE THEME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: themes.map((theme) {
                  final isSelected = cert.certificateTheme == theme;
                  final color = themeColors[theme]!;
                  return GestureDetector(
                    onTap: () {
                      setInnerState(() {
                        cert.certificateTheme = theme;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(theme, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: isSelected ? color : Colors.black)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Editable Fields
              const Text('CERTIFICATE TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Certificate of Humanitarian Lifesaver',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                onChanged: (v) => setInnerState(() { cert.customTitle = v; }),
              ),
              const SizedBox(height: 16),

              const Text('PLEDGE MESSAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: pledgeCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'In recognition of selfless donation...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                onChanged: (v) => setInnerState(() { cert.customPledgeMessage = v; }),
              ),
              const SizedBox(height: 16),

              const Text('SIGNATURE TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: sigCtrl,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
                onChanged: (v) => setInnerState(() { cert.signatureTitle = v; }),
              ),
              const SizedBox(height: 20),

              // Toggles
              _buildCertToggle('Include QR Verification Code', cert.includeQrVerification, (v) {
                setInnerState(() { cert.includeQrVerification = v; });
              }),
              const SizedBox(height: 10),
              _buildCertToggle('Include Background Watermark', cert.includeWatermark, (v) {
                setInnerState(() { cert.includeWatermark = v; });
              }),
              const SizedBox(height: 24),

              // Save & Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final donor = mockService.donorProfile;
                        mockService.updateDonorCertificate(
                          customTitle: titleCtrl.text,
                          certificateTheme: cert.certificateTheme,
                          customPledgeMessage: pledgeCtrl.text,
                          signatureTitle: sigCtrl.text,
                          includeQrVerification: cert.includeQrVerification,
                          includeWatermark: cert.includeWatermark,
                        );
                        FileDownloadService.downloadCertificate(donor, cert: cert);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Row(
                              children: [
                                const Icon(LucideIcons.fileCheck, color: AppTheme.skyBlue, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Certificate customized & downloaded for ${donor.name}!',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: const Text('Save & Download Certificate', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: IconButton(
                      icon: const Icon(LucideIcons.download, color: Colors.black),
                      tooltip: 'Download Certificate',
                      onPressed: () {
                        final donor = mockService.donorProfile;
                        FileDownloadService.downloadCertificate(donor, cert: cert);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: const Row(
                              children: [
                                Icon(LucideIcons.fileCheck, color: AppTheme.skyBlue, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Life-Saver Certificate downloaded and saved to your device!',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: IconButton(
                      icon: const Icon(LucideIcons.share2, color: Colors.black),
                      tooltip: 'Share Certificate',
                      onPressed: () {
                        final donor = mockService.donorProfile;
                        FileDownloadService.downloadCertificate(donor, cert: cert);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.black,
                            content: Text('Certificate downloaded & shareable certificate ready to send!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.black,
          ),
        ],
      ),
    );
  }

  // ================= ACTIVENESS SETTINGS TAB =================
  Widget _buildActivenessTab(BuildContext context, MockDataService mockService) {
    final act = mockService.donorActiveness;

    final freqPlans = [
      'Standard (Every 90 Days)',
      'High-Impact (Every 60 Days)',
      'Bi-Annual Hero (Twice a year)',
      'On-Demand Emergency Only',
      'Weekend Warrior',
    ];
    final freqIcons = {
      'Standard (Every 90 Days)': LucideIcons.clock,
      'High-Impact (Every 60 Days)': LucideIcons.zap,
      'Bi-Annual Hero (Twice a year)': LucideIcons.calendar,
      'On-Demand Emergency Only': LucideIcons.alertTriangle,
      'Weekend Warrior': LucideIcons.sun,
    };

    final allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final reminderOptions = ['1 Day Before', '3 Days Before', '1 Week Before', '2 Weeks Before'];
    final mottoCtrl = TextEditingController(text: act.personalMotto);

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Donation Activeness', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(height: 4),
              const Text('Configure your donation frequency, availability, and commitment', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              // Yearly Progress Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.target, size: 20, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        const Text('YEARLY PLEDGE PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
                        const Spacer(),
                        Text('${mockService.donorProfile.donationsThisYear} / ${act.yearlyPledgeUnits}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: act.yearlyPledgeUnits > 0 ? (mockService.donorProfile.donationsThisYear / act.yearlyPledgeUnits).clamp(0.0, 1.0) : 0,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mockService.donorProfile.donationsThisYear >= act.yearlyPledgeUnits
                          ? '🎉 Pledge completed! You are a champion!'
                          : '${act.yearlyPledgeUnits - mockService.donorProfile.donationsThisYear} more donation(s) to reach your yearly pledge.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Frequency Plan Selector
              const Text('DONATION FREQUENCY PLAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              ...freqPlans.map((plan) {
                final isSelected = act.frequencyPlan == plan;
                return GestureDetector(
                  onTap: () => setInnerState(() { act.frequencyPlan = plan; }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black.withValues(alpha: 0.04) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? Colors.black : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(freqIcons[plan] ?? LucideIcons.clock, size: 18, color: isSelected ? Colors.black : const Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(plan, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: Colors.black))),
                        if (isSelected) const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF059669)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Toggles
              const Text('BROADCAST & MATCHING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              _buildCertToggle('Allow Emergency SOS Broadcasts', act.allowEmergencySosBroadcasts, (v) {
                setInnerState(() { act.allowEmergencySosBroadcasts = v; });
              }),
              const SizedBox(height: 8),
              _buildCertToggle('Allow Smart Matching Radius Expansion', act.allowMatchingRadiusExpansions, (v) {
                setInnerState(() { act.allowMatchingRadiusExpansions = v; });
              }),
              const SizedBox(height: 16),

              // Radius Slider
              const Text('MATCHING RADIUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Custom Radius', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                        Text('${act.customRadiusKm.toInt()} km', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                      ],
                    ),
                    Slider(
                      value: act.customRadiusKm,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      activeColor: Colors.black,
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (v) => setInnerState(() { act.customRadiusKm = v; }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Yearly Pledge Counter
              const Text('YEARLY DONATION PLEDGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.minus, color: Colors.black),
                      onPressed: act.yearlyPledgeUnits > 1 ? () => setInnerState(() { act.yearlyPledgeUnits--; }) : null,
                    ),
                    const SizedBox(width: 16),
                    Text('${act.yearlyPledgeUnits}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
                    const Text(' units/year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(LucideIcons.plus, color: Colors.black),
                      onPressed: act.yearlyPledgeUnits < 12 ? () => setInnerState(() { act.yearlyPledgeUnits++; }) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preferred Days
              const Text('PREFERRED DONATION DAYS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allDays.map((day) {
                  final isSelected = act.preferredDonationDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      setInnerState(() {
                        if (isSelected) {
                          act.preferredDonationDays.remove(day);
                        } else {
                          act.preferredDonationDays.add(day);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.black : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(day.substring(0, 3), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : Colors.black)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Reminder Frequency
              const Text('REMINDER FREQUENCY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: reminderOptions.contains(act.reminderFrequency) ? act.reminderFrequency : reminderOptions.first,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14),
                    items: reminderOptions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.black)))).toList(),
                    onChanged: (v) { if (v != null) setInnerState(() { act.reminderFrequency = v; }); },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Personal Motto
              const Text('PERSONAL MOTTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextField(
                controller: mottoCtrl,
                maxLines: 2,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    mockService.updateDonorActiveness(
                      frequencyPlan: act.frequencyPlan,
                      allowEmergencySosBroadcasts: act.allowEmergencySosBroadcasts,
                      allowMatchingRadiusExpansions: act.allowMatchingRadiusExpansions,
                      customRadiusKm: act.customRadiusKm,
                      yearlyPledgeUnits: act.yearlyPledgeUnits,
                      preferredDonationDays: List.from(act.preferredDonationDays),
                      reminderFrequency: act.reminderFrequency,
                      personalMotto: mottoCtrl.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activeness settings saved!')));
                  },
                  icon: const Icon(LucideIcons.save, size: 16),
                  label: const Text('Save Activeness Settings', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

class _EmvChipCircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF78350F).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, paint);

    canvas.drawLine(Offset(size.width * 0.35, 3), Offset(size.width * 0.35, size.height - 3), paint);
    canvas.drawLine(Offset(size.width * 0.65, 3), Offset(size.width * 0.65, size.height - 3), paint);
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.5), Offset(size.width * 0.65, size.height * 0.5), paint);
    canvas.drawLine(Offset(3, size.height * 0.5), Offset(size.width * 0.35, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.5), Offset(size.width - 3, size.height * 0.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MedicalBarcodePainter extends CustomPainter {
  final String code;
  _MedicalBarcodePainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final widths = [2.0, 1.0, 3.0, 1.5, 4.0, 1.0, 2.5, 1.5, 3.0, 2.0, 1.0, 3.5, 1.0, 2.0, 4.0, 1.5, 2.0, 3.0, 1.0, 2.5, 3.5, 1.5, 2.0, 1.0, 3.0, 2.0, 4.0, 1.0, 2.0, 3.0];
    final spaces = [1.5, 2.0, 1.0, 2.5, 1.5, 2.0, 1.0, 2.0, 1.5, 1.0, 2.5, 1.0, 2.0, 1.5, 1.0, 2.0, 1.5, 1.0, 2.0, 1.5, 1.0, 2.0, 1.5, 1.0, 2.0, 1.5, 2.0, 1.0, 2.0, 1.5];

    double currentX = 8.0;
    for (int i = 0; i < widths.length && currentX < size.width - 12; i++) {
      final w = widths[i];
      canvas.drawRect(Rect.fromLTWH(currentX, 2, w, size.height - 4), blackPaint);
      currentX += w + (i < spaces.length ? spaces[i] : 2.0);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

