import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/blood_type.dart';
import '../models/patient_models.dart';
import '../services/mock_data_service.dart';
import '../widgets/interactive_directions_map_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  BloodType? _selectedBloodType;
  String _selectedCity = 'All Cities';
  bool _isMapView = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _indianCities = [
    'All Cities',
    'Hyderabad',
    'Bengaluru',
    'New Delhi',
    'Mumbai',
    'Chennai',
    'Kolkata',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockService = Provider.of<MockDataService>(context);

    // Filter nearby facilities based on blood type, city, and search query
    final facilities = mockService.nearbyFacilities.where((fac) {
      if (_selectedCity != 'All Cities' && fac.city.toLowerCase() != _selectedCity.toLowerCase()) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        final match = fac.name.toLowerCase().contains(q) ||
            fac.address.toLowerCase().contains(q) ||
            fac.landmark.toLowerCase().contains(q) ||
            fac.city.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_selectedBloodType == null) return true;
      return fac.stock.containsKey(_selectedBloodType) && fac.stock[_selectedBloodType]! > 0;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Find Blood & Centers',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.4),
        ),
        actions: [
          // View Mode Switcher
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggleButton(icon: LucideIcons.list, isSelected: !_isMapView, onTap: () => setState(() => _isMapView = false)),
                _buildViewToggleButton(icon: LucideIcons.map, isSelected: _isMapView, onTap: () => setState(() => _isMapView = true)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input with Indian Cities Placeholder
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Search hospital, blood center, or landmark...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 16, color: Colors.black54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // City Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _indianCities.map((city) {
                      final isSel = _selectedCity == city;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCity = city),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? Colors.black : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel ? Colors.black : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSel) ...[
                                  const Icon(LucideIcons.mapPin, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isSel ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Blood Group Selection Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: BloodType.values.map((type) {
                      final isSelected = _selectedBloodType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(type.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedBloodType = selected ? type : null);
                          },
                          selectedColor: const Color(0xFFDC2626),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Main Content View (List vs Interactive Map)
          Expanded(
            child: _isMapView
                ? _buildInteractiveMapView(context, facilities)
                : _buildFacilityListView(context, facilities),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
      ),
    );
  }

  // ================= LIST VIEW =================
  Widget _buildFacilityListView(BuildContext context, List<NearbyFacility> facilities) {
    if (facilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(LucideIcons.mapPinOff, size: 36, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 14),
            const Text(
              'No matching blood centers found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing city or selected blood group filter',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final fac = facilities[index];
        final units = _selectedBloodType != null
            ? (fac.stock[_selectedBloodType] ?? 0)
            : fac.stock.values.fold(0, (sum, val) => sum + val);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Type Badge & Stock Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: fac.type == FacilityType.bloodBank
                          ? const Color(0xFFF5F3FF)
                          : (fac.type == FacilityType.hospital ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      fac.type == FacilityType.bloodBank
                          ? LucideIcons.droplet
                          : (fac.type == FacilityType.hospital ? LucideIcons.building2 : LucideIcons.tent),
                      color: fac.type == FacilityType.bloodBank
                          ? const Color(0xFF7C3AED)
                          : (fac.type == FacilityType.hospital ? const Color(0xFFE11D48) : const Color(0xFF059669)),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fac.name,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fac.landmark} • ${fac.city}, ${fac.state}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (fac.stock.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '$units Units',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0284C7)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Address & Contact Details
              Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fac.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${fac.distanceKm} km away',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(fac.openHours, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(LucideIcons.star, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text('${fac.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  // Directions Map Button (Calls our new effective InteractiveDirectionsMapModal)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => InteractiveDirectionsMapModal.show(context, fac),
                      icon: const Icon(LucideIcons.navigation, size: 16, color: Color(0xFF0284C7)),
                      label: const Text('Directions & Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Request Blood Button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () => _showBloodRequestDialog(context, fac),
                      icon: const Icon(LucideIcons.heartHandshake, size: 16),
                      label: const Text('Request Blood', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
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

  // ================= INTERACTIVE MAP VIEW =================
  Widget _buildInteractiveMapView(BuildContext context, List<NearbyFacility> facilities) {
    return Stack(
      children: [
        // Simulated Indian City Map Background
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFF1F5F9),
          child: CustomPaint(
            painter: _CityOverviewMapPainter(facilities: facilities),
          ),
        ),

        // Floating City Center Indicator
        Positioned(
          top: 14,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                const Icon(LucideIcons.mapPin, size: 16, color: Color(0xFFDC2626)),
                const SizedBox(width: 6),
                Text(
                  'Showing ${_selectedCity == 'All Cities' ? 'All Active Regional Centers' : _selectedCity}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
        ),

        // Horizontal Facility Slider at Bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: facilities.length,
            itemBuilder: (context, index) {
              final fac = facilities[index];
              return Container(
                width: 290,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fac.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${fac.distanceKm} km',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${fac.landmark}, ${fac.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => InteractiveDirectionsMapModal.show(context, fac),
                            icon: const Icon(LucideIcons.navigation, size: 14),
                            label: const Text('Get Directions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          ),
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
    );
  }

  void _showBloodRequestDialog(BuildContext context, NearbyFacility facility) {
    BloodType reqType = _selectedBloodType ?? BloodType.oPos;
    int units = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.droplets, color: Color(0xFFDC2626), size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Request Blood', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Requisition target: ${facility.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 14),
              const Text('Select Blood Group', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BloodType>(
                    isExpanded: true,
                    value: reqType,
                    items: BloodType.values
                        .map((t) => DropdownMenuItem(value: t, child: Text('Group ${t.label}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => reqType = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Units Required:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.minusCircle, size: 22, color: Color(0xFF64748B)),
                        onPressed: units > 1 ? () => setDialogState(() => units--) : null,
                      ),
                      Text('$units', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                      IconButton(
                        icon: const Icon(LucideIcons.plusCircle, size: 22, color: Color(0xFFDC2626)),
                        onPressed: () => setDialogState(() => units++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.black,
                    content: Text('Blood request for $units unit(s) of ${reqType.label} sent to ${facility.name}. Priority cross-match active.'),
                  ),
                );
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CITY OVERVIEW MAP PAINTER =================
class _CityOverviewMapPainter extends CustomPainter {
  final List<NearbyFacility> facilities;

  _CityOverviewMapPainter({required this.facilities});

  @override
  void paint(Canvas canvas, Size size) {
    // Background streets & river / lake
    final waterPaint = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.20, size.width * 0.30, size.height * 0.25),
        const Radius.circular(30),
      ),
      waterPaint,
    );

    // Highways
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
    final roadBorder = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(size.width * 0.4, size.height * 0.35, size.width * 0.6, size.height * 0.55, size.width, size.height * 0.40);
    canvas.drawPath(path, roadBorder);
    canvas.drawPath(path, roadPaint);

    final crossPath = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height);
    canvas.drawPath(crossPath, roadBorder);
    canvas.drawPath(crossPath, roadPaint);

    // Draw Facility Pins on Map
    for (int i = 0; i < facilities.length; i++) {
      final fac = facilities[i];
      final px = size.width * (0.20 + (i % 4) * 0.22);
      final py = size.height * (0.25 + (i ~/ 4) * 0.35);

      final pinPaint = Paint()
        ..color = fac.type == FacilityType.bloodBank
            ? const Color(0xFF7C3AED)
            : (fac.type == FacilityType.hospital ? const Color(0xFFDC2626) : const Color(0xFF059669));

      canvas.drawCircle(Offset(px, py), 14, pinPaint);
      canvas.drawCircle(Offset(px, py), 6, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _CityOverviewMapPainter oldDelegate) => false;
}
