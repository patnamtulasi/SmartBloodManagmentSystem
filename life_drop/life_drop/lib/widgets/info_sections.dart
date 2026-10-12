import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InfoSections extends StatelessWidget {
  const InfoSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBenefitsSection(context),
        const SizedBox(height: 32),
        _buildFactsSection(context),
        const SizedBox(height: 32),
        _build3DImpactTestimonial(context),
      ],
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'Benefits of Blood Donation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Clinical physiology & humanitarian advantages of regular voluntary donations',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 18),
        _ThreeDBenefitCard(
          stepNumber: '01',
          title: 'Saves Multiple Lives',
          description: 'A single 450ml whole blood donation separates into red cells, platelets, and plasma—saving up to 3 patient lives in critical emergency trauma.',
          icon: LucideIcons.heartPulse,
          accentColor: const Color(0xFFDC2626),
          lightBg: const Color(0xFFFEF2F2),
        ),
        _ThreeDBenefitCard(
          stepNumber: '02',
          title: 'Promotes Cardiovascular Health',
          description: 'Regular voluntary donation regulates blood viscosity, reduces excessive iron oxidation in vessel walls, and supports long-term cardiovascular health.',
          icon: LucideIcons.activity,
          accentColor: const Color(0xFF059669),
          lightBg: const Color(0xFFECFDF5),
        ),
        _ThreeDBenefitCard(
          stepNumber: '03',
          title: 'Comprehensive Mini Physical Exam',
          description: 'Prior to each donation, clinical staff checks your hemoglobin, blood pressure, resting pulse, body temperature, and infectious markers.',
          icon: LucideIcons.stethoscope,
          accentColor: const Color(0xFF0284C7),
          lightBg: const Color(0xFFF0F9FF),
        ),
        _ThreeDBenefitCard(
          stepNumber: '04',
          title: 'Stimulates Fresh Blood Cell Production',
          description: 'After donating, your bone marrow actively produces fresh, oxygen-rich red blood cells within 24 to 48 hours, renewing hematopoietic vitality.',
          icon: LucideIcons.sparkles,
          accentColor: const Color(0xFF7C3AED),
          lightBg: const Color(0xFFF5F3FF),
        ),
        _ThreeDBenefitCard(
          stepNumber: '05',
          title: 'Elevates Psychological Wellbeing',
          description: 'Altruistic humanitarian giving significantly lowers cortisol stress markers, combats social isolation, and strengthens community health resilience.',
          icon: LucideIcons.smile,
          accentColor: const Color(0xFFD97706),
          lightBg: const Color(0xFFFFFBEB),
        ),
      ],
    );
  }

  Widget _buildFactsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFFAFAFA),
            Color(0xFFF8FAFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 2,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.lightbulb, color: Colors.black, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facts & Awareness',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Essential medical statistics and critical donation insights',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _build3DFactItem(
            'Every 2 seconds, a patient in emergency trauma or surgical intensive care requires urgent blood transfusion.',
            LucideIcons.clock,
            const Color(0xFFDC2626),
          ),
          _build3DFactItem(
            'Human blood has no synthetic alternative; it cannot be manufactured in a factory and relies solely on selfless voluntary donors.',
            LucideIcons.droplets,
            const Color(0xFF0284C7),
          ),
          _build3DFactItem(
            'O-negative red blood cells are universally compatible and critical during urgent, emergency trauma resuscitation when patient blood type is unknown.',
            LucideIcons.shieldAlert,
            const Color(0xFF059669),
          ),
          _build3DFactItem(
            'Less than 4% of eligible healthy adults donate blood annually, creating acute seasonal inventory shortages across hospital networks.',
            LucideIcons.alertCircle,
            const Color(0xFFD97706),
          ),
          _build3DFactItem(
            'A single severe vehicular trauma victim can require more than 100 units of packed red blood cells within hours.',
            LucideIcons.ambulance,
            const Color(0xFF7C3AED),
          ),
          _build3DFactItem(
            'Platelets expire in only 5 to 7 days, meaning continuous, steady voluntary donations are vital every single week.',
            LucideIcons.calendarClock,
            const Color(0xFF0891B2),
          ),
        ],
      ),
    );
  }

  Widget _build3DFactItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DImpactTestimonial(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFF0FDF4),
            Color(0xFFDCFCE7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.12),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.heartHandshake, size: 13, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'REAL CLINICAL IMPACT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(LucideIcons.star, size: 14, color: Color(0xFFF59E0B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '"VitalPulse coordinated an emergency O- negative dispatch in under 9 minutes during my daughter\'s emergency surgery. We are alive today because of this network."',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF059669),
                child: Text('SL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarah L. – Recipient Family',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                  Text(
                    'Metro General Hospital • Verified Case ID: VP-CAS-1923',
                    style: TextStyle(fontSize: 10, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreeDBenefitCard extends StatefulWidget {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color lightBg;

  const _ThreeDBenefitCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.lightBg,
  });

  @override
  State<_ThreeDBenefitCard> createState() => _ThreeDBenefitCardState();
}

class _ThreeDBenefitCardState extends State<_ThreeDBenefitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _isHovered ? widget.lightBg : const Color(0xFFFAFCFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.1),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: _isHovered ? 0.16 : 0.06),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 10 : 5),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 3,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Numbered & Icon Pedestal
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.accentColor.withValues(alpha: 0.25), width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.20),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 4,
                    right: 6,
                    child: Text(
                      widget.stepNumber,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: widget.accentColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Icon(widget.icon, color: widget.accentColor, size: 24),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                      height: 1.38,
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
}
