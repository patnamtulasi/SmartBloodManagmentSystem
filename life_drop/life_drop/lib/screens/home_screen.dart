import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../widgets/compatibility_checker.dart';
import '../widgets/info_sections.dart';
import '../widgets/interactive_directions_map_modal.dart';
import '../widgets/login_dialog.dart';
import '../models/blood_type.dart';
import '../services/mock_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _fluidWaveController;

  @override
  void initState() {
    super.initState();
    // Cardiac rhythm pulse: ~1.2s period
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Fluid wave undulation: ~3s period
    _fluidWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _fluidWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Tooltip(
          message: 'Explore VitalPulse 3D Interactive Landing Page',
          child: GestureDetector(
            onTap: () => context.push('/landing'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                children: [
                  // 3D Animated Liquid Blood Droplet Badge
                  AnimatedBuilder(
                    animation: _heartbeatController,
                    builder: (context, child) {
                      final scale = 1.0 + 0.08 * math.sin(_heartbeatController.value * 2 * math.pi);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            gradient: const RadialGradient(
                              colors: [Colors.white, Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                              center: Alignment(-0.3, -0.3),
                            ),
                            border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.droplets, color: Color(0xFF0284C7), size: 20),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'VitalPulse',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: -0.5,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'INDIA',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 0.8,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Smart Blood Network • Hyderabad, BLR, DEL, MUM',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: Color(0xFF0284C7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.bell, color: Colors.black, size: 20),
              onPressed: () => context.push('/notifications'),
              tooltip: 'Notifications',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 3D Floating Emergency SOS Live Ticker (Indian Hospitals)
            _build3DEmergencyBanner(context, mockService),
            const SizedBox(height: 20),

            // 2. 3D Hero Section with Cardiac Pulse & Floating Erythrocytes
            _build3DHeroSection(context),
            const SizedBox(height: 32),

            // 3. 3D Login Portals (Square Icon Badge + Rectangle Card + "LOGIN" Box)
            _buildLoginPortals(context),
            const SizedBox(height: 36),

            // 4. 3D Live Clinical Blood Reserve Showcase with Fluid Wave Motion
            _build3DBloodReserveShowcase(context),
            const SizedBox(height: 36),

            // 5. Regional Indian Hospitals & Directions Spotlight Map
            _buildIndianHospitalDirectionsSpotlight(context, mockService),
            const SizedBox(height: 36),

            // 6. 3D Interactive Compatibility Checker
            const CompatibilityChecker(),
            const SizedBox(height: 36),

            // 7. 3D Benefits, Medical Facts & Impact Story
            const InfoSections(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ================= 1. 3D EMERGENCY SOS LIVE BANNER =================
  Widget _build3DEmergencyBanner(BuildContext context, MockDataService mockService) {
    return _ThreeDTiltCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFFEF2F2),
              Color(0xFFFFF1F2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 3,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulsing Red Cardiac Flame Beacon
            AnimatedBuilder(
              animation: _heartbeatController,
              builder: (context, child) {
                final scale = 1.0 + 0.12 * math.sin(_heartbeatController.value * 2 * math.pi);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.flame, color: Color(0xFFDC2626), size: 19),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'EMERGENCY SOS • HYDERABAD HITEC CORRIDOR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('• LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE11D48))),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Apollo Hospitals Jubilee Hills: 2 Units O- required immediately for emergency CABG (1.8 km)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 2. 3D HERO SECTION WITH CARDIAC PULSE & ERYTHROCYTES =================
  Widget _build3DHeroSection(BuildContext context) {
    return _ThreeDTiltCard(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFFAFCFF),
              Color(0xFFF0F9FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, -3),
            ),
          ],
          border: Border.all(color: const Color(0xFFBAE6FD), width: 1.6),
        ),
        child: Stack(
          children: [
            // Background 3D Animated Blood Cells (Erythrocytes & ECG Wave)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _heartbeatController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _BloodThemeMotionPainter(
                      progress: _heartbeatController.value,
                    ),
                  );
                },
              ),
            ),

            // Foreground Content
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Badge Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBAE6FD), width: 1.3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0284C7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'AI SMART BLOOD NETWORK • INDIA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0284C7),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.shieldCheck, size: 14, color: Color(0xFF059669)),
                            SizedBox(width: 5),
                            Text(
                              'NABH & ISO Verified',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero Main Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Save Lives with\nPrecision Matching',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'VitalPulse India algorithmically connects voluntary blood donors, emergency patients, and premier hospitals across Hyderabad, Bengaluru, Delhi, and Mumbai in under 7 minutes.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),

                  // 3D Elevated Hero Stat Pedestals
                  Row(
                    children: [
                      _build3DHeroStatPedestal(
                        title: '18,450+',
                        subtitle: 'Verified Donors',
                        icon: LucideIcons.users,
                        color: const Color(0xFF0284C7),
                        lightBg: const Color(0xFFF0F9FF),
                      ),
                      const SizedBox(width: 12),
                      _build3DHeroStatPedestal(
                        title: '99.6%',
                        subtitle: 'Match Precision',
                        icon: LucideIcons.sparkles,
                        color: const Color(0xFF059669),
                        lightBg: const Color(0xFFECFDF5),
                      ),
                      const SizedBox(width: 12),
                      _build3DHeroStatPedestal(
                        title: '< 7 min',
                        subtitle: 'Emergency SOS',
                        icon: LucideIcons.flame,
                        color: const Color(0xFFDC2626),
                        lightBg: const Color(0xFFFEF2F2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DHeroStatPedestal({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color lightBg,
  }) {
    return Expanded(
      child: _ThreeDTiltCard(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                lightBg,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 3. 3D LOGIN PORTALS =================
  Widget _buildLoginPortals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Portal Logins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '4 Access Roles',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your authorized clinical or voluntary dashboard below to proceed',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isMobile ? 0.98 : 0.92,
              children: [
                _buildSquareRectangle3DLoginCard(
                  context,
                  role: 'Donor',
                  subtitle: 'Voluntary Givers',
                  icon: LucideIcons.heartPulse,
                  accentColor: const Color(0xFF059669),
                  lightBgColor: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFA7F3D0),
                  onTap: () => LoginDialog.show(
                    context,
                    role: 'Donor',
                    subtitle: 'Sign in to manage donations, appointments & emergency response',
                    icon: LucideIcons.heartPulse,
                    accentColor: const Color(0xFF059669),
                    lightBgColor: const Color(0xFFECFDF5),
                    borderColor: const Color(0xFFA7F3D0),
                  ),
                ),
                _buildSquareRectangle3DLoginCard(
                  context,
                  role: 'Patient',
                  subtitle: 'Blood Requests',
                  icon: LucideIcons.user,
                  accentColor: const Color(0xFF0284C7),
                  lightBgColor: const Color(0xFFF0F9FF),
                  borderColor: const Color(0xFFBAE6FD),
                  onTap: () => LoginDialog.show(
                    context,
                    role: 'Patient',
                    subtitle: 'Sign in to request blood, track matches & view donors',
                    icon: LucideIcons.user,
                    accentColor: const Color(0xFF0284C7),
                    lightBgColor: const Color(0xFFF0F9FF),
                    borderColor: const Color(0xFFBAE6FD),
                  ),
                ),
                _buildSquareRectangle3DLoginCard(
                  context,
                  role: 'Hospital',
                  subtitle: 'Apollo & Trauma Units',
                  icon: LucideIcons.building2,
                  accentColor: const Color(0xFFE11D48),
                  lightBgColor: const Color(0xFFFFF1F2),
                  borderColor: const Color(0xFFFECDD3),
                  onTap: () => LoginDialog.show(
                    context,
                    role: 'Hospital',
                    subtitle: 'Sign in to manage clinical blood reserves & emergency SOS',
                    icon: LucideIcons.building2,
                    accentColor: const Color(0xFFE11D48),
                    lightBgColor: const Color(0xFFFFF1F2),
                    borderColor: const Color(0xFFFECDD3),
                  ),
                ),
                _buildSquareRectangle3DLoginCard(
                  context,
                  role: 'Blood Bank',
                  subtitle: 'Chiranjeevi & Red Cross',
                  icon: LucideIcons.droplet,
                  accentColor: const Color(0xFF7C3AED),
                  lightBgColor: const Color(0xFFF5F3FF),
                  borderColor: const Color(0xFFDDD6FE),
                  onTap: () => LoginDialog.show(
                    context,
                    role: 'Blood Bank',
                    subtitle: 'Sign in to manage cross-match inventory & supply camps',
                    icon: LucideIcons.droplet,
                    accentColor: const Color(0xFF7C3AED),
                    lightBgColor: const Color(0xFFF5F3FF),
                    borderColor: const Color(0xFFDDD6FE),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSquareRectangle3DLoginCard(
    BuildContext context, {
    required String role,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color lightBgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return _ThreeDTiltCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                lightBgColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: borderColor, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 9),
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 3,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Square shape 3D embossed badge for icon
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 3,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: accentColor),
              ),

              // 2. Role Title & Subtitle
              Column(
                children: [
                  Text(
                    role,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              // 3. Explicit Rectangle Box with "LOGIN" text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 2,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(LucideIcons.arrowRight, size: 14, color: accentColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 4. 3D LIVE CLINICAL BLOOD RESERVE SHOWCASE WITH FLUID WAVES =================
  Widget _build3DBloodReserveShowcase(BuildContext context) {
    final bloodGroups = [
      {'type': BloodType.oNeg, 'units': '12 Units', 'status': 'Critical', 'color': const Color(0xFFDC2626)},
      {'type': BloodType.oPos, 'units': '68 Units', 'status': 'Optimal', 'color': const Color(0xFF059669)},
      {'type': BloodType.aPos, 'units': '54 Units', 'status': 'Optimal', 'color': const Color(0xFF0284C7)},
      {'type': BloodType.aNeg, 'units': '18 Units', 'status': 'Low', 'color': const Color(0xFFD97706)},
      {'type': BloodType.bPos, 'units': '42 Units', 'status': 'Optimal', 'color': const Color(0xFF059669)},
      {'type': BloodType.bNeg, 'units': '14 Units', 'status': 'Low', 'color': const Color(0xFFD97706)},
      {'type': BloodType.abPos, 'units': '28 Units', 'status': 'Normal', 'color': const Color(0xFF7C3AED)},
      {'type': BloodType.abNeg, 'units': '9 Units', 'status': 'Critical', 'color': const Color(0xFFDC2626)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Live Network Blood Reserve',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => context.push('/search'),
              child: const Row(
                children: [
                  Text('Find Donors', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                  SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFF0284C7)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Live clinical blood units verified across Indian blood banks (Hyd, Blr, Del, Mum)',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 4 : 8,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bloodGroups.length,
              itemBuilder: (context, index) {
                final item = bloodGroups[index];
                final type = item['type'] as BloodType;
                final units = item['units'] as String;
                final status = item['status'] as String;
                final color = item['color'] as Color;

                return _ThreeDTiltCard(
                  child: InkWell(
                    onTap: () => _showBloodGroupInfoDialog(context, type),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 2,
                            offset: Offset(0, -1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 3D Circular Vial Badge with Undulating Fluid Wave
                          AnimatedBuilder(
                            animation: _fluidWaveController,
                            builder: (context, child) {
                              return Container(
                                width: 38,
                                height: 38,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: _VialFluidWavePainter(
                                    waveProgress: _fluidWaveController.value,
                                    liquidColor: color,
                                  ),
                                  child: Center(
                                    child: Text(
                                      type.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            units,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ================= 5. REGIONAL INDIAN HOSPITALS & DIRECTIONS SPOTLIGHT =================
  Widget _buildIndianHospitalDirectionsSpotlight(BuildContext context, MockDataService mockService) {
    final facility = mockService.nearbyFacilities.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
            Color(0xFFF0F9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.mapPinned, color: Color(0xFF0284C7), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Indian Hospital Route & Navigation',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Interactive GPS routes with turn-by-turn guidance and traffic indicators',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Route Preview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Closest Clinical Center: Jubilee Hills',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        facility.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      Text(
                        '${facility.landmark} • 1.4 km via Durgam Cheruvu Cable Bridge',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => InteractiveDirectionsMapModal.show(context, facility),
                  icon: const Icon(LucideIcons.navigation, size: 16),
                  label: const Text('Open Map & Directions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBloodGroupInfoDialog(BuildContext context, BloodType type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Icon(LucideIcons.droplets, color: Color(0xFF0284C7), size: 20),
            ),
            const SizedBox(width: 10),
            Text('Blood Group ${type.label}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Can donate red blood cells to:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: BloodType.values
                  .where((r) => type.canDonateTo(r))
                  .map((r) => Chip(
                        label: Text(r.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black)),
                        backgroundColor: const Color(0xFFECFDF5),
                        side: const BorderSide(color: Color(0xFFA7F3D0)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Can safely receive red cells from:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: BloodType.values
                  .where((d) => d.canDonateTo(type))
                  .map((d) => Chip(
                        label: Text(d.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black)),
                        backgroundColor: const Color(0xFFF0F9FF),
                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/search');
            },
            child: const Text('Search in Indian Cities'),
          ),
        ],
      ),
    );
  }
}

// ================= 3D TILT INTERACTIVE CARD WIDGET =================
class _ThreeDTiltCard extends StatefulWidget {
  final Widget child;

  const _ThreeDTiltCard({required this.child});

  @override
  State<_ThreeDTiltCard> createState() => _ThreeDTiltCardState();
}

class _ThreeDTiltCardState extends State<_ThreeDTiltCard> {
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _tiltX = 0.0;
          _tiltY = 0.0;
        });
      },
      onHover: (event) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final size = box.size;
        final local = event.localPosition;

        final normalizedX = (local.dx / size.width - 0.5) * 2.0;
        final normalizedY = (local.dy / size.height - 0.5) * 2.0;

        setState(() {
          _tiltX = (normalizedY * 0.06).clamp(-0.06, 0.06);
          _tiltY = (normalizedX * -0.06).clamp(-0.06, 0.06);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0008)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY)
          ..setTranslationRaw(0.0, _isHovered ? -5.0 : 0.0, 0.0),
        child: widget.child,
      ),
    );
  }
}

// ================= 3D BLOOD THEME MOTION PAINTER =================
class _BloodThemeMotionPainter extends CustomPainter {
  final double progress;

  _BloodThemeMotionPainter({required this.progress});

  // Deterministic aesthetic micro-dots configurations for pop-up motion
  static final List<({double xF, double yF, double r, double phase, Color color})> _dots = [
    (xF: 0.08, yF: 0.28, r: 3.5, phase: 0.12, color: const Color(0xFFEF4444)),
    (xF: 0.18, yF: 0.55, r: 2.8, phase: 0.35, color: const Color(0xFF0284C7)),
    (xF: 0.24, yF: 0.18, r: 4.2, phase: 0.62, color: const Color(0xFFF43F5E)),
    (xF: 0.32, yF: 0.72, r: 2.5, phase: 0.84, color: const Color(0xFF38BDF8)),
    (xF: 0.42, yF: 0.38, r: 3.8, phase: 0.22, color: const Color(0xFFE11D48)),
    (xF: 0.52, yF: 0.85, r: 3.0, phase: 0.48, color: const Color(0xFFF59E0B)),
    (xF: 0.61, yF: 0.22, r: 4.0, phase: 0.73, color: const Color(0xFFEF4444)),
    (xF: 0.68, yF: 0.62, r: 2.6, phase: 0.91, color: const Color(0xFF0284C7)),
    (xF: 0.76, yF: 0.40, r: 3.6, phase: 0.18, color: const Color(0xFFF43F5E)),
    (xF: 0.84, yF: 0.78, r: 3.2, phase: 0.54, color: const Color(0xFF38BDF8)),
    (xF: 0.91, yF: 0.15, r: 4.5, phase: 0.79, color: const Color(0xFFDC2626)),
    (xF: 0.95, yF: 0.50, r: 2.4, phase: 0.33, color: const Color(0xFF0EA5E9)),
    (xF: 0.14, yF: 0.88, r: 3.4, phase: 0.65, color: const Color(0xFFF43F5E)),
    (xF: 0.88, yF: 0.92, r: 2.8, phase: 0.27, color: const Color(0xFFF59E0B)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Cardiac ECG Waveform across the top of hero
    final ecgPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.15)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final ecgPath = Path();
    final yBase = size.height * 0.22;
    ecgPath.moveTo(0, yBase);

    for (double x = 0; x <= size.width; x += 20) {
      final shifted = (x / 200 + progress * 2) % 2;
      double y = yBase;
      if (shifted > 0.8 && shifted < 1.0) {
        y = yBase - 18 * math.sin((shifted - 0.8) / 0.2 * math.pi);
      } else if (shifted >= 1.0 && shifted < 1.2) {
        y = yBase + 10 * math.sin((shifted - 1.0) / 0.2 * math.pi);
      }
      ecgPath.lineTo(x, y);
    }
    canvas.drawPath(ecgPath, ecgPaint);

    // 2. Floating 3D Biconcave Erythrocyte (Red Blood Cell) Particles
    final cellPaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final cellInnerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final cellOffsets = [
      Offset(size.width * 0.12, size.height * (0.35 + 0.06 * math.sin(progress * 2 * math.pi))),
      Offset(size.width * 0.82, size.height * (0.25 + 0.05 * math.cos(progress * 2 * math.pi))),
      Offset(size.width * 0.45, size.height * (0.80 + 0.04 * math.sin(progress * 2 * math.pi + 1))),
      Offset(size.width * 0.70, size.height * (0.75 + 0.07 * math.cos(progress * 2 * math.pi + 2))),
    ];

    for (final pt in cellOffsets) {
      canvas.drawOval(Rect.fromCenter(center: pt, width: 28, height: 22), cellPaint);
      canvas.drawOval(Rect.fromCenter(center: pt, width: 14, height: 10), cellInnerPaint);
    }

    // 3. Aesthetic Popping Blood Theme Micro-Dots / Bioluminescent Particles
    for (final dot in _dots) {
      final cycle = ((progress + dot.phase) % 1.0);
      final popSine = math.sin(cycle * math.pi);
      if (popSine <= 0.01) continue;

      final scale = 0.6 + 0.8 * popSine;
      final alpha = (popSine * 0.38).clamp(0.0, 0.45);
      final yDrift = ((dot.yF * size.height) - (progress * 40 * (1.0 + dot.phase))) % size.height;
      final center = Offset(dot.xF * size.width, yDrift);

      // Subtle Outer Halo
      final haloPaint = Paint()
        ..color = dot.color.withValues(alpha: alpha * 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dot.r * scale * 2.4, haloPaint);

      // Main Pop Dot
      final mainDotPaint = Paint()
        ..color = dot.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dot.r * scale, mainDotPaint);

      // Core Highlight Sparkle
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.75)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, dot.r * scale * 0.35, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BloodThemeMotionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ================= VIAL FLUID WAVE PAINTER =================
class _VialFluidWavePainter extends CustomPainter {
  final double waveProgress;
  final Color liquidColor;

  _VialFluidWavePainter({
    required this.waveProgress,
    required this.liquidColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final wavePaint = Paint()
      ..color = liquidColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final path = Path();
    final yWater = size.height * 0.48;
    path.moveTo(0, size.height);
    path.lineTo(0, yWater);

    for (double x = 0; x <= size.width; x += 4) {
      final y = yWater + 3.0 * math.sin((x / size.width * 2 * math.pi) + (waveProgress * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _VialFluidWavePainter oldDelegate) {
    return oldDelegate.waveProgress != waveProgress || oldDelegate.liquidColor != liquidColor;
  }
}
