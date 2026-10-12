import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

/// Premium iOS-inspired 3D Landing Page for VitalPulse.
/// Showcases 3D entrance perspective transitions, interactive 3D hero holographic droplet,
/// gyroscopic orbital rings, interactive 3D tilt feature cards, live network stats, and clinical workflows.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _orbitController;
  late AnimationController _entrance3DController;
  final ScrollController _scrollController = ScrollController();

  Offset _heroMousePos = Offset.zero;
  int? _hoveredFeatureIndex;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _entrance3DController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _orbitController.dispose();
    _entrance3DController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    final entranceCurved = CurvedAnimation(
      parent: _entrance3DController,
      curve: Curves.easeOutCubic,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : (isTablet ? 24 : 16),
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Title
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = 1.0 + 0.06 * _pulseController.value;
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'VitalPulse',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFECDD3)),
                                  ),
                                  child: const Text(
                                    'INDIA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 8.5,
                                      color: Color(0xFFDC2626),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Smart Blood Donation Network',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Actions
                Row(
                  children: [
                    if (isDesktop) ...[
                      TextButton(
                        onPressed: () {
                          _scrollController.animateTo(
                            600,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          '3D Showcase',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _scrollController.animateTo(
                            1200,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Features',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _scrollController.animateTo(
                            1800,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'How It Works',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],

                    // Back to App / Home button
                    OutlinedButton.icon(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      icon: const Icon(LucideIcons.arrowLeft, size: 15, color: Colors.black),
                      label: const Text('Enter App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: entranceCurved,
        builder: (context, child) {
          final progress = entranceCurved.value;
          // Elegant scale-up + fade entrance (no harsh perspective tilt)
          final scale = 0.92 + (0.08 * progress);
          final translateY = (1.0 - progress) * 24.0;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(0, 0, scale)
              ..setEntry(1, 1, scale)
              ..setEntry(1, 3, translateY),
            child: Opacity(
              opacity: progress.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. HERO SECTION WITH 3D INTERACTIVE VISUALS
              _buildHero(context, isDesktop, isTablet),

              // 2. LIVE NETWORK STATS BAR
              _buildLiveStatsBar(context, isDesktop),

              // 3. CORE PLATFORM PILLARS (FEATURES WITH 3D HOVER TILT)
              _buildFeaturePillars(context, isDesktop, isTablet),

              // 4. HOW IT WORKS (3-STEP PIPELINE)
              _buildHowItWorks(context, isDesktop),

              // 5. EMERGENCY SOS & IMPACT STORIES
              _buildImpactSection(context, isDesktop),

              // 6. CALL TO ACTION & FOOTER
              _buildFooter(context, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 1. HERO SECTION WITH 3D VISUALS =================
  Widget _buildHero(BuildContext context, bool isDesktop, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : (isTablet ? 32 : 20),
        vertical: isDesktop ? 48 : 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFEFF6FF),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // 3D Glass Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                      'AI-POWERED 3D SMART BLOOD NETWORK • INDIA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0369A1),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Hero Headline
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isDesktop ? 44 : (isTablet ? 32 : 25),
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1.0,
                    height: 1.15,
                  ),
                  children: const [
                    TextSpan(text: 'Every Drop Counts.\n'),
                    TextSpan(
                      text: 'Every Second Matters.',
                      style: TextStyle(
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'VitalPulse bridges voluntary donors, trauma centers, patients, and regional blood banks through automated real-time matching, live reserve vaults, and zero-delay SOS dispatch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 15.5 : 13.5,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 3D Interactive Showcase Visual
              _build3DHeroShowcase(isDesktop),

              const SizedBox(height: 32),

              // CTA Buttons
              Wrap(
                spacing: 14,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    icon: const Icon(LucideIcons.heartPulse, size: 16, color: Colors.black),
                    label: const Text(
                      'Enter VitalPulse App',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.skyBlueLight,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _scrollController.animateTo(
                        780,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.black),
                    label: const Text(
                      'Explore 3D Platform Features',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 3D HERO INTERACTIVE SHOWCASE =================
  Widget _build3DHeroShowcase(bool isDesktop) {
    return MouseRegion(
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          final local = event.localPosition;
          setState(() {
            // Normalized -1.0 to 1.0 for authentic 3D parallax
            _heroMousePos = Offset(
              ((local.dx / size.width) - 0.5) * 2,
              ((local.dy / size.height) - 0.5) * 2,
            );
          });
        }
      },
      onExit: (_) {
        setState(() {
          _heroMousePos = Offset.zero;
        });
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_orbitController, _pulseController, _floatController]),
        builder: (context, child) {
          final floatOffset = math.sin(_floatController.value * math.pi * 2) * 6.0;
          final pulseVal = _pulseController.value;
          final pulseScale = 1.0 + 0.06 * math.sin(pulseVal * math.pi * 2);
          final orbitAngle = _orbitController.value * math.pi * 2;

          // 3D Perspective Tilt Matrix
          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0008)
            ..rotateX(-_heroMousePos.dy * 0.08)
            ..rotateY(_heroMousePos.dx * 0.10)
            ..setEntry(1, 3, floatOffset);

          // Orbit satellite metadata (4 key donor groups in 3D space)
          final satellites = [
            (label: 'O- Universal', color: const Color(0xFFEF4444), tag: 'URGENT'),
            (label: 'A+ High Demand', color: const Color(0xFF0EA5E9), tag: 'ACTIVE'),
            (label: 'B+ Reserve', color: const Color(0xFF10B981), tag: 'READY'),
            (label: 'AB+ Plasma', color: const Color(0xFF8B5CF6), tag: 'OPTIMAL'),
          ];

          // Compute orbital positions with depth Z
          final orbitRadiusX = isDesktop ? 190.0 : 140.0;
          final orbitRadiusY = 46.0;
          final tiltAngle = 0.28; // slight 3D orbital inclination

          List<Widget> backSatellites = [];
          List<Widget> frontSatellites = [];

          for (int i = 0; i < satellites.length; i++) {
            final angle = orbitAngle + (i * math.pi / 2);
            final x = math.cos(angle) * orbitRadiusX;
            final yRaw = math.sin(angle) * orbitRadiusY;
            final z = math.sin(angle); // -1.0 (back) to +1.0 (front)

            // Tilt transformation
            final y = yRaw * math.cos(tiltAngle) - (z * 12);

            final satScale = 0.78 + (0.32 * ((z + 1.0) / 2.0));
            final satOpacity = (0.55 + (0.45 * ((z + 1.0) / 2.0))).clamp(0.0, 1.0);

            final satWidget = Transform.translate(
              offset: Offset(x, y),
              child: Transform.scale(
                scale: satScale,
                child: Opacity(
                  opacity: satOpacity,
                  child: _buildOrbitalSatellitePill(
                    satellites[i].label,
                    satellites[i].color,
                    satellites[i].tag,
                    isFront: z >= 0,
                  ),
                ),
              ),
            );

            if (z < 0) {
              backSatellites.add(satWidget);
            } else {
              frontSatellites.add(satWidget);
            }
          }

          return Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: Container(
              width: isDesktop ? 720 : double.infinity,
              height: isDesktop ? 300 : 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFF0F9FF), // Ice Sky Blue
                    Color(0xFFE0F2FE), // Soft Sky Tint
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    blurRadius: 36,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFBAE6FD),
                  width: 1.8,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 1. Radar Grid & Sweep Canvas
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CustomPaint(
                        painter: _VitalRadarGridPainter(sweepAngle: orbitAngle),
                      ),
                    ),
                  ),

                  // 2. Animated Real-time ECG Heartbeat Waveform at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 90,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                      child: CustomPaint(
                        painter: _EkgHeartbeatWavePainter(progress: _orbitController.value),
                      ),
                    ),
                  ),

                  // 3. Staggered Ultrasound Cardiac Sonic Waves (expanding outward)
                  ...List.generate(2, (index) {
                    final waveProgress = ((pulseVal + (index * 0.5)) % 1.0);
                    final ringSize = 100.0 + (waveProgress * 110.0);
                    final ringOpacity = ((1.0 - waveProgress) * 0.28).clamp(0.0, 1.0);

                    return Container(
                      width: ringSize,
                      height: ringSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0284C7).withValues(alpha: ringOpacity * 0.6),
                          width: 1.4,
                        ),
                      ),
                    );
                  }),

                  // 4. Back Orbit Satellites (rendered behind center sphere)
                  ...backSatellites,

                  // 5. 3D Ambient Glow Behind Droplet
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                          blurRadius: 44,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // 6. 3D Central Lifesaving VitalCore Droplet/Sphere
                  Transform.scale(
                    scale: pulseScale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFFCA5A5),
                            Color(0xFFEF4444),
                            Color(0xFFDC2626),
                            Color(0xFF991B1B),
                          ],
                          stops: [0.0, 0.20, 0.50, 0.80, 1.0],
                          center: Alignment(-0.35, -0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2.4),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Inner pulse icon
                          const Icon(
                            LucideIcons.heartPulse,
                            color: Colors.white,
                            size: 40,
                          ),
                          // Specular Glint Highlight (top left)
                          Positioned(
                            top: 14,
                            left: 18,
                            child: Container(
                              width: 14,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 7. Front Orbit Satellites (rendered in front of center sphere)
                  ...frontSatellites,

                  // 8. 3D Floating Glass HUD Badge 1: Top Left (AI Match Radar)
                  Positioned(
                    left: isDesktop ? 26 : 14,
                    top: 22,
                    child: Transform.translate(
                      offset: Offset(-_heroMousePos.dx * 10, -_heroMousePos.dy * 7),
                      child: _build3DFloatingBadge(
                        icon: LucideIcons.sparkles,
                        iconColor: const Color(0xFF38BDF8),
                        title: '99.8% AI Match',
                        subtitle: 'Proximity & Rh Engine',
                        tag: 'REAL-TIME',
                      ),
                    ),
                  ),

                  // 9. 3D Floating Glass HUD Badge 2: Top Right (Critical SOS)
                  Positioned(
                    right: isDesktop ? 26 : 14,
                    top: 22,
                    child: Transform.translate(
                      offset: Offset(-_heroMousePos.dx * 14, -_heroMousePos.dy * 9),
                      child: _build3DFloatingBadge(
                        icon: LucideIcons.siren,
                        iconColor: const Color(0xFFF43F5E),
                        title: '< 14 Min Critical SOS',
                        subtitle: 'Zero-Delay Trauma Link',
                        tag: 'LIVE',
                      ),
                    ),
                  ),

                  // 10. 3D Floating Glass HUD Badge 3: Bottom Center (Live Vault Reserves)
                  Positioned(
                    bottom: 18,
                    child: Transform.translate(
                      offset: Offset(-_heroMousePos.dx * 8, -_heroMousePos.dy * 5),
                      child: _build3DFloatingBadge(
                        icon: LucideIcons.shieldCheck,
                        iconColor: const Color(0xFF34D399),
                        title: '450+ Blood Vaults Synced',
                        subtitle: '8 Blood Types Real-Time',
                        tag: 'ACTIVE',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrbitalSatellitePill(String label, Color color, String tag, {required bool isFront}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isFront ? 0.96 : 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFront ? color.withValues(alpha: 0.7) : const Color(0xFFCBD5E1),
          width: isFront ? 1.5 : 1.0,
        ),
        boxShadow: isFront
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isFront ? Colors.black : const Color(0xFF475569),
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DFloatingBadge({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 7.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 2. LIVE STATS BAR =================
  Widget _buildLiveStatsBar(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Wrap(
            spacing: 32,
            runSpacing: 20,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildStatItem('24,500+', 'VERIFIED DONORS', LucideIcons.users),
              _buildStatItem('450+', 'CONNECTED HOSPITALS', LucideIcons.building2),
              _buildStatItem('14 Mins', 'AVG SOS RESPONSE', LucideIcons.zap),
              _buildStatItem('98.4%', 'DEMAND FULFILLED', LucideIcons.shieldCheck),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF38BDF8)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              val,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= 3. CORE PLATFORM PILLARS (3D HOVER TILT) =================
  Widget _buildFeaturePillars(BuildContext context, bool isDesktop, bool isTablet) {
    final features = [
      (
        icon: LucideIcons.sparkles,
        accentColor: const Color(0xFF0284C7),
        tag: 'AI MATCH',
        title: 'Smart Donor Matching',
        desc: 'Proximity and Rh compatibility engine calculates exact matches and alerts registered donors within 5 km.',
      ),
      (
        icon: LucideIcons.siren,
        accentColor: const Color(0xFFDC2626),
        tag: 'SOS DISPATCH',
        title: 'Zero-Delay Emergency SOS',
        desc: 'One-touch trauma broadcasting for ICUs and emergency surgeries with rapid dispatch status tracking.',
      ),
      (
        icon: LucideIcons.boxes,
        accentColor: const Color(0xFF059669),
        tag: 'VAULT SYNC',
        title: 'Live Blood Vault Inventory',
        desc: 'Real-time monitoring of available, reserved, used, and expiring units across all 8 major blood groups.',
      ),
      (
        icon: LucideIcons.truck,
        accentColor: const Color(0xFFD97706),
        tag: 'LOGISTICS',
        title: 'Regional Bank Transfers',
        desc: 'Inter-hospital logistics and cold-chain ambulance courier integration for urgent blood unit transfers.',
      ),
      (
        icon: LucideIcons.gitCompare,
        accentColor: const Color(0xFF8B5CF6),
        tag: 'SEROLOGY',
        title: 'Compatibility Matrix',
        desc: 'Interactive visual crossmatch validator calculating exact safe donor-to-recipient blood pairings.',
      ),
      (
        icon: LucideIcons.shieldCheck,
        accentColor: const Color(0xFF0F172A),
        tag: 'MULTI-ROLE',
        title: 'Secure Multi-Role Access',
        desc: 'Dedicated clinical workflows tailored for Donors, Patients, Surgeons, Blood Banks, and Network Admins.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : (isTablet ? 32 : 20),
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'BUILT FOR CLINICAL PRECISION',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Next-Generation Blood Management System',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'A comprehensive platform connecting every stakeholder in the critical blood transfusion lifecycle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),

              // Grid of 6 Pillars with 3D Hover Tilt & iOS Card styling
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: isDesktop ? 1.32 : (isTablet ? 1.38 : 1.65),
                ),
                itemBuilder: (context, index) {
                  final f = features[index];
                  final isHovered = _hoveredFeatureIndex == index;

                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredFeatureIndex = index),
                    onExit: (_) => setState(() => _hoveredFeatureIndex = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..setEntry(1, 3, isHovered ? -7.0 : 0.0)
                        ..setEntry(0, 0, isHovered ? 1.02 : 1.0)
                        ..setEntry(1, 1, isHovered ? 1.02 : 1.0),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isHovered ? f.accentColor.withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
                          width: isHovered ? 1.8 : 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isHovered ? f.accentColor.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.03),
                            blurRadius: isHovered ? 20 : 10,
                            offset: Offset(0, isHovered ? 10 : 4),
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: f.accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(f.icon, size: 22, color: f.accentColor),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: f.accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f.tag,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: f.accentColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            f.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              f.desc,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                                height: 1.42,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 4. HOW IT WORKS =================
  Widget _buildHowItWorks(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'SEAMLESS CLINICAL PIPELINE',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'How VitalPulse Works',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 36),

              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _buildStepCard(
                    number: '01',
                    title: 'Register & Request',
                    desc: 'Hospitals or patients submit blood requisitions with patient ID, blood type, and urgency level.',
                  ),
                  _buildStepCard(
                    number: '02',
                    title: 'AI Smart Match',
                    desc: 'Algorithm matches compatible donors and locks available units from nearby regional blood vaults.',
                  ),
                  _buildStepCard(
                    number: '03',
                    title: 'Cold-Chain Delivery',
                    desc: 'Emergency ambulance courier is dispatched with real-time ETA tracking and serology verification.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({required String number, required String title, required String desc}) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0284C7),
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 5. IMPACT & TESTIMONIALS =================
  Widget _buildImpactSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F9FF),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'LIFESAVING IMPACT',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0284C7),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Real Stories from the Ground',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFBAE6FD), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.quote, color: Color(0xFF0284C7), size: 24),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"During an emergency polytrauma surgery at Apollo Hospitals Jubilee Hills, VitalPulse located and dispatched 2 units of rare O- blood within 14 minutes, saving our patient’s life before surgical bypass."',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Dr. P. Venkat Reddy, MS • Chief Trauma Surgeon, Apollo Hospitals',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 6. FOOTER =================
  Widget _buildFooter(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.droplets, color: Color(0xFF0284C7), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'VitalPulse',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(LucideIcons.phoneCall, size: 14, color: Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      const Text(
                        '24/7 Helpline: 108 / 1800-425-9090',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                '© 2026 VitalPulse India • Smart Blood Donation Management System. Built with Flutter, iOS Healthcare UI & Local Memory Architecture.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalRadarGridPainter extends CustomPainter {
  final double sweepAngle;
  _VitalRadarGridPainter({required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintGrid = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric Radar Range Rings
    final maxRadius = math.min(size.width, size.height) * 0.48;
    for (int i = 1; i <= 3; i++) {
      final r = maxRadius * (i / 3.0);
      canvas.drawCircle(center, r, paintGrid);
    }

    // Cardinal Axes crosshair
    final axisPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.18)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), axisPaint);

    // Subtle sweeping radar gradient beam
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: sweepAngle - (math.pi / 4),
        endAngle: sweepAngle,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.0),
          const Color(0xFF0284C7).withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _VitalRadarGridPainter oldDelegate) =>
      oldDelegate.sweepAngle != sweepAngle;
}

class _EkgHeartbeatWavePainter extends CustomPainter {
  final double progress;
  _EkgHeartbeatWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final width = size.width;
    final baseH = size.height * 0.55;

    path.moveTo(0, baseH);

    // Draw repeating EKG heartbeat pulse waves across width
    const pulseWidth = 140.0;
    final numPulses = (width / pulseWidth).ceil() + 1;

    for (int i = 0; i < numPulses; i++) {
      final startX = i * pulseWidth;
      path.lineTo(startX + 20, baseH);
      // P wave
      path.quadraticBezierTo(startX + 30, baseH - 6, startX + 40, baseH);
      // Q dip
      path.lineTo(startX + 50, baseH + 4);
      // R spike (cardiac high pulse)
      path.lineTo(startX + 60, baseH - 26);
      // S dip
      path.lineTo(startX + 70, baseH + 10);
      // T wave (dome)
      path.quadraticBezierTo(startX + 90, baseH - 8, startX + 110, baseH);
      path.lineTo(startX + pulseWidth, baseH);
    }

    // Glowing EKG stroke
    final ekgPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawPath(path, ekgPaint);

    // Glowing Pulse Head moving across
    final headX = (progress * width) % width;
    final headPoint = Offset(headX, baseH);

    final glowPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(headPoint, 4, glowPaint);

    final dotPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(headPoint, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _EkgHeartbeatWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
