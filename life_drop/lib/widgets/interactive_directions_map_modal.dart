import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/patient_models.dart';

class InteractiveDirectionsMapModal extends StatefulWidget {
  final NearbyFacility facility;

  const InteractiveDirectionsMapModal({
    super.key,
    required this.facility,
  });

  static void show(BuildContext context, NearbyFacility facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InteractiveDirectionsMapModal(facility: facility),
    );
  }

  @override
  State<InteractiveDirectionsMapModal> createState() => _InteractiveDirectionsMapModalState();
}

class _InteractiveDirectionsMapModalState extends State<InteractiveDirectionsMapModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedModeIndex = 0; // 0: Car, 1: Ambulance, 2: Bike, 3: Walk
  bool _isNavigating = false;
  double _zoomLevel = 1.0;

  final List<Map<String, dynamic>> _modes = [
    {'name': 'Drive', 'icon': LucideIcons.car, 'eta': '11 min', 'dist': '3.8 km', 'traffic': 'Smooth'},
    {'name': 'Ambulance SOS', 'icon': LucideIcons.siren, 'eta': '6 min', 'dist': '3.8 km', 'traffic': 'Priority'},
    {'name': 'Two-Wheeler', 'icon': LucideIcons.bike, 'eta': '13 min', 'dist': '3.6 km', 'traffic': 'Fast'},
    {'name': 'Walk', 'icon': LucideIcons.footprints, 'eta': '38 min', 'dist': '3.2 km', 'traffic': 'Clear'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facility = widget.facility;
    final mode = _modes[_selectedModeIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: const Icon(LucideIcons.navigation, color: Color(0xFF0284C7), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '${facility.city}, ${facility.state} • ${facility.landmark}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Main Map View (Interactive Canvas)
          Expanded(
            child: Stack(
              children: [
                // Custom Vector Street Map Canvas
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _IndianCityMapPainter(
                          progress: _isNavigating ? _animController.value : 0.45,
                          facility: facility,
                          isAmbulance: _selectedModeIndex == 1,
                          zoomLevel: _zoomLevel,
                        ),
                      );
                    },
                  ),
                ),

                // Top Map HUD Bar (Live Traffic & Indian Highway Indicator)
                Positioned(
                  top: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
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
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Via Outer Ring Road • ${mode['traffic']}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      // Zoom Controls
                      Row(
                        children: [
                          _buildMapIconButton(
                            icon: LucideIcons.plus,
                            onTap: () => setState(() => _zoomLevel = (_zoomLevel + 0.15).clamp(0.8, 1.6)),
                          ),
                          const SizedBox(width: 6),
                          _buildMapIconButton(
                            icon: LucideIcons.minus,
                            onTap: () => setState(() => _zoomLevel = (_zoomLevel - 0.15).clamp(0.8, 1.6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Floating Re-Center / GPS Target
                Positioned(
                  bottom: 14,
                  right: 16,
                  child: _buildMapIconButton(
                    icon: LucideIcons.locateFixed,
                    label: 'Recenter',
                    onTap: () => setState(() => _zoomLevel = 1.0),
                  ),
                ),
              ],
            ),
          ),

          // Route Details & Step-by-Step Directions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel Mode Selector Tabs
                Row(
                  children: List.generate(_modes.length, (index) {
                    final m = _modes[index];
                    final isSel = _selectedModeIndex == index;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedModeIndex = index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          margin: EdgeInsets.only(right: index < _modes.length - 1 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF0284C7) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(m['icon'] as IconData, size: 16, color: isSel ? Colors.white : Colors.black87),
                              const SizedBox(height: 3),
                              Text(
                                m['eta'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isSel ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Metrics Bar
                Row(
                  children: [
                    _buildMetricPill(mode['dist'] as String, 'Distance', LucideIcons.mapPin),
                    const SizedBox(width: 10),
                    _buildMetricPill(mode['eta'] as String, 'Estimated Time', LucideIcons.clock),
                    const SizedBox(width: 10),
                    _buildMetricPill('Open 24/7', 'Facility Hours', LucideIcons.doorOpen),
                  ],
                ),
                const SizedBox(height: 16),

                // Step-by-Step Checkpoints
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildStepRow('1', 'Depart current location towards ${facility.city} Main Corridor', '400 m'),
                      _buildStepRow('2', 'Take Cyber Towers / Flyover towards ${facility.landmark}', '1.8 km'),
                      _buildStepRow('3', 'Turn left into ${facility.name} Emergency Blood Bank Wing', '600 m'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Action Row
                Row(
                  children: [
                    // Start GPS Navigation Simulation
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isNavigating ? const Color(0xFF059669) : const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          setState(() => _isNavigating = !_isNavigating);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.black,
                              content: Text(
                                _isNavigating
                                    ? 'GPS Simulation Active: Guiding to ${facility.name} via ${facility.city} ORR'
                                    : 'Navigation Paused',
                              ),
                            ),
                          );
                        },
                        icon: Icon(_isNavigating ? LucideIcons.pause : LucideIcons.navigation2, size: 18),
                        label: Text(
                          _isNavigating ? 'GPS Active (Simulating)' : 'Start Navigation',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Call Facility Desk
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.phoneCall, color: Color(0xFF0284C7), size: 20),
                        tooltip: 'Call ${facility.name}',
                        onPressed: () => _callFacilityDesk(context, facility),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Real Google Maps Live Directions Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(LucideIcons.map, color: Colors.white, size: 20),
                        tooltip: 'Get Real Map Directions in Google Maps',
                        onPressed: () => _openRealGoogleMaps(context, facility),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRealGoogleMaps(BuildContext context, NearbyFacility facility) async {
    final lat = facility.latitude;
    final lng = facility.longitude;
    final destination = Uri.encodeComponent('${facility.name}, ${facility.address}, ${facility.city}');
    final mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$destination';
    final uri = Uri.parse(mapsUrl);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text('Opening Google Maps Directions to: ${facility.name} ($lat, $lng)'),
          ),
        );
      }
    }
  }

  Future<void> _callFacilityDesk(BuildContext context, NearbyFacility facility) async {
    final phoneClean = facility.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$phoneClean');
    try {
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text('Calling Emergency Desk: ${facility.phone}'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black,
            content: Text('Calling Emergency Desk: ${facility.phone}'),
          ),
        );
      }
    }
  }

  Widget _buildMetricPill(String val, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: const Color(0xFF0284C7)),
                const SizedBox(width: 4),
                Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String stepNum, String text, String dist) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF0284C7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNum,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
          Text(dist, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildMapIconButton({required IconData icon, String? label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
            ],
          ],
        ),
      ),
    );
  }
}

// ================= CUSTOM VECTOR INDIAN CITY STREET MAP PAINTER =================
class _IndianCityMapPainter extends CustomPainter {
  final double progress;
  final NearbyFacility facility;
  final bool isAmbulance;
  final double zoomLevel;

  _IndianCityMapPainter({
    required this.progress,
    required this.facility,
    required this.isAmbulance,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(zoomLevel, zoomLevel);

    // Map background - clean light iOS Apple Maps aesthetic
    final bgPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width / zoomLevel, size.height / zoomLevel), bgPaint);

    // Green parks and hospital zones
    final parkPaint = Paint()..color = const Color(0xFFE5F6DF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.15, size.width * 0.28, size.height * 0.22),
        const Radius.circular(16),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.50, size.width * 0.35, size.height * 0.28),
        const Radius.circular(18),
      ),
      parkPaint,
    );

    // City grid streets
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final streetBorderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    // Outer Ring Road / Express Arterials
    final arterialPath1 = Path()
      ..moveTo(0, size.height * 0.35)
      ..cubicTo(size.width * 0.35, size.height * 0.32, size.width * 0.65, size.height * 0.40, size.width, size.height * 0.30);

    final arterialPath2 = Path()
      ..moveTo(size.width * 0.30, 0)
      ..cubicTo(size.width * 0.32, size.height * 0.45, size.width * 0.55, size.height * 0.65, size.width * 0.70, size.height);

    canvas.drawPath(arterialPath1, streetBorderPaint);
    canvas.drawPath(arterialPath1, streetPaint);
    canvas.drawPath(arterialPath2, streetBorderPaint);
    canvas.drawPath(arterialPath2, streetPaint);

    // Secondary city roads
    final secondaryPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final secondaryPath1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.8)
      ..lineTo(size.width * 0.85, size.height * 0.15);
    canvas.drawPath(secondaryPath1, secondaryPaint);

    // Route Polyline (Glowing Blue / Emerald Line)
    final routePath = Path();
    final startPt = Offset(size.width * 0.18, size.height * 0.70);
    final midPt1 = Offset(size.width * 0.35, size.height * 0.55);
    final midPt2 = Offset(size.width * 0.50, size.height * 0.38);
    final endPt = Offset(size.width * 0.78, size.height * 0.28);

    routePath.moveTo(startPt.dx, startPt.dy);
    routePath.lineTo(midPt1.dx, midPt1.dy);
    routePath.lineTo(midPt2.dx, midPt2.dy);
    routePath.lineTo(endPt.dx, endPt.dy);

    // Route Outer Glow
    final routeGlowPaint = Paint()
      ..color = (isAmbulance ? const Color(0xFFDC2626) : const Color(0xFF0284C7)).withValues(alpha: 0.35)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeGlowPaint);

    // Route Core Line
    final routeLinePaint = Paint()
      ..color = isAmbulance ? const Color(0xFFDC2626) : const Color(0xFF0284C7)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeLinePaint);

    // Start Marker (User Location: Blue Pulse Ring)
    final userRingPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPt, 16, userRingPaint);

    final userCorePaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(startPt, 8, userCorePaint);
    canvas.drawCircle(startPt, 3, Paint()..color = Colors.white);

    // Destination Pin (Hospital / Blood Center)
    final destPinPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(endPt, 12, destPinPaint);
    canvas.drawCircle(endPt, 6, Paint()..color = Colors.white);
    // Cross mark in pin
    final crossPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(endPt.dx - 3, endPt.dy), Offset(endPt.dx + 3, endPt.dy), crossPaint);
    canvas.drawLine(Offset(endPt.dx, endPt.dy - 3), Offset(endPt.dx, endPt.dy + 3), crossPaint);

    // Destination Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: facility.name,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(endPt.dx - textPainter.width / 2, endPt.dy - 26));

    // Vehicle Animated Position
    final vehiclePt = _getPointAlongPath([startPt, midPt1, midPt2, endPt], progress);
    final vehicleBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vehiclePt, 10, Paint()..color = Colors.black26);
    canvas.drawCircle(vehiclePt, 8, vehicleBgPaint);
    canvas.drawCircle(
      vehiclePt,
      5,
      Paint()..color = isAmbulance ? const Color(0xFFDC2626) : const Color(0xFF059669),
    );

    canvas.restore();
  }

  Offset _getPointAlongPath(List<Offset> points, double t) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1) return points.first;
    final totalSegments = points.length - 1;
    final segmentFloat = t * totalSegments;
    final segIndex = segmentFloat.floor().clamp(0, totalSegments - 1);
    final localT = (segmentFloat - segIndex).clamp(0.0, 1.0);

    final p1 = points[segIndex];
    final p2 = points[segIndex + 1];
    return Offset(
      p1.dx + (p2.dx - p1.dx) * localT,
      p1.dy + (p2.dy - p1.dy) * localT,
    );
  }

  @override
  bool shouldRepaint(covariant _IndianCityMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isAmbulance != isAmbulance ||
        oldDelegate.zoomLevel != zoomLevel;
  }
}
