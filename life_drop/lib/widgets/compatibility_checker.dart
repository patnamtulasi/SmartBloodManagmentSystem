import 'package:flutter/material.dart';
import '../models/blood_type.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CompatibilityChecker extends StatefulWidget {
  const CompatibilityChecker({super.key});

  @override
  State<CompatibilityChecker> createState() => _CompatibilityCheckerState();
}

class _CompatibilityCheckerState extends State<CompatibilityChecker> {
  BloodType donorType = BloodType.oNeg;
  BloodType recipientType = BloodType.aPos;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isCompatible = donorType.canDonateTo(recipientType);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFFAFCFF),
              Color(0xFFF0F9FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _isHovered ? const Color(0xFF38BDF8) : const Color(0xFFBAE6FD),
            width: 1.5,
          ),
          boxShadow: [
            // Ambient diffusion shadow
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: _isHovered ? 0.14 : 0.08),
              blurRadius: _isHovered ? 28 : 18,
              offset: Offset(0, _isHovered ? 14 : 8),
              spreadRadius: _isHovered ? 2 : 0,
            ),
            // Top specular rim light for glossy 3D glass look
            const BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with 3D Embossed Icon
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF0F9FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        blurRadius: 2,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.gitBranch, color: Color(0xFF0284C7), size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Blood Compatibility Checker',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '3D SIMULATOR',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Interactive clinical transfusion match verification & antigen safety protocol',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3D Interactive Transfusion Selector Tubes
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final donorCard = _build3DTypeSelector(
                  title: 'DONOR BLOOD TYPE',
                  value: donorType,
                  accentColor: const Color(0xFFDC2626),
                  icon: LucideIcons.heartPulse,
                  onChanged: (val) {
                    if (val != null) setState(() => donorType = val);
                  },
                );

                final recipientCard = _build3DTypeSelector(
                  title: 'RECIPIENT BLOOD TYPE',
                  value: recipientType,
                  accentColor: const Color(0xFF0284C7),
                  icon: LucideIcons.userCheck,
                  onChanged: (val) {
                    if (val != null) setState(() => recipientType = val);
                  },
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      donorCard,
                      const SizedBox(height: 12),
                      _build3DTransfusionConduit(isCompatible, isVertical: true),
                      const SizedBox(height: 12),
                      recipientCard,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: donorCard),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _build3DTransfusionConduit(isCompatible, isVertical: false),
                    ),
                    Expanded(child: recipientCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 22),

            // 3D Result Capsule
            _build3DResultCapsule(isCompatible),
            const SizedBox(height: 14),

            // Clinical Advisory Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Universal donor: O- can donate red cells to all. Universal recipient: AB+ can receive red cells from all.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _build3DTypeSelector({
    required String title,
    required BloodType value,
    required Color accentColor,
    required IconData icon,
    required ValueChanged<BloodType?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accentColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<BloodType>(
                isExpanded: true,
                value: value,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(LucideIcons.chevronDown, size: 18, color: Colors.black),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                items: BloodType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            type.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Blood Group ${type.label}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DTransfusionConduit(bool isCompatible, {required bool isVertical}) {
    final color = isCompatible ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      width: isVertical ? 42 : 46,
      height: isVertical ? 42 : 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Icon(
        isVertical ? LucideIcons.arrowDown : LucideIcons.arrowRight,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _build3DResultCapsule(bool isCompatible) {
    final statusColor = isCompatible ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final lightBg = isCompatible ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final borderColor = isCompatible ? const Color(0xFFA7F3D0) : const Color(0xFFFECDD3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        border: Border.all(color: borderColor, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
          // 3D Status Sphere
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 2,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Icon(
              isCompatible ? LucideIcons.checkCheck : LucideIcons.alertTriangle,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCompatible ? 'COMPATIBLE MATCH' : 'INCOMPATIBLE BLOOD TYPE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.5,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompatible ? 'SAFE' : 'HAZARD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isCompatible
                      ? 'Blood group ${donorType.label} can safely donate red cells to a ${recipientType.label} recipient. Antigens match safely.'
                      : 'Blood group ${donorType.label} cannot be transfused into a ${recipientType.label} recipient due to antibody agglutination risk.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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
