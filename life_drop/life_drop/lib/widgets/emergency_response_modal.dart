import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Real-time Emergency Response Modal that appears when user taps the "Respond"
/// button on the Emergency SOS banner. Shows a live status progression with
/// countdown, confirmation, matching, and success states.
class EmergencyResponseModal extends StatefulWidget {
  final String hospital;
  final String bloodType;
  final String unitsNeeded;
  final String distance;

  const EmergencyResponseModal({
    super.key,
    required this.hospital,
    required this.bloodType,
    required this.unitsNeeded,
    required this.distance,
  });

  /// Show the emergency response modal
  static Future<void> show(
    BuildContext context, {
    required String hospital,
    required String bloodType,
    required String unitsNeeded,
    required String distance,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Emergency Response',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return EmergencyResponseModal(
          hospital: hospital,
          bloodType: bloodType,
          unitsNeeded: unitsNeeded,
          distance: distance,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curvedAnim = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(curvedAnim),
          child: FadeTransition(opacity: curvedAnim, child: child),
        );
      },
    );
  }

  @override
  State<EmergencyResponseModal> createState() => _EmergencyResponseModalState();
}

enum _ResponsePhase {
  confirm,      // Initial: "Confirm your response"
  connecting,   // Connecting to the hospital
  matching,     // Finding match & route
  dispatched,   // Confirmed & dispatched
  success,      // Complete
}

class _EmergencyResponseModalState extends State<EmergencyResponseModal>
    with TickerProviderStateMixin {
  _ResponsePhase _phase = _ResponsePhase.confirm;
  Timer? _phaseTimer;
  int _countdown = 5;
  Timer? _countdownTimer;

  late AnimationController _pulseController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startResponse() {
    setState(() => _phase = _ResponsePhase.connecting);
    _progressController.forward(from: 0.0);

    // Phase 1: Connecting (2s)
    _phaseTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _phase = _ResponsePhase.matching);
      _progressController.forward(from: 0.0);

      // Phase 2: Matching (2.5s)
      _phaseTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        setState(() => _phase = _ResponsePhase.dispatched);
        _progressController.forward(from: 0.0);

        // Phase 3: Dispatched → Success (2s)
        _phaseTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _phase = _ResponsePhase.success;
            _countdown = 5;
          });

          // Auto-close countdown
          _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            setState(() => _countdown--);
            if (_countdown <= 0) {
              timer.cancel();
              Navigator.of(context).pop();
            }
          });
        });
      });
    });
  }

  void _cancelResponse() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 500 ? 420.0 : screenWidth * 0.92;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isActive = _phase != _ResponsePhase.confirm;
    final isSuccess = _phase == _ResponsePhase.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSuccess
              ? [const Color(0xFFECFDF5), Colors.white]
              : [const Color(0xFFFEF2F2), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Live pulse beacon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = isActive
                  ? 1.0 + 0.10 * math.sin(_pulseController.value * 2 * math.pi)
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSuccess
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFECDD3),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSuccess
                            ? const Color(0xFF059669).withValues(alpha: 0.30)
                            : const Color(0xFFDC2626).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSuccess ? LucideIcons.checkCircle : LucideIcons.heartPulse,
                    color: isSuccess
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            isSuccess
                ? 'Response Confirmed!'
                : _phase == _ResponsePhase.confirm
                    ? 'Emergency Blood Response'
                    : 'Processing Your Response...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isSuccess ? const Color(0xFF059669) : Colors.black,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSuccess
                ? 'Thank you for saving a life 🩸'
                : 'Respond to this emergency blood request',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Request details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildDetailRow(LucideIcons.building2, 'Hospital', widget.hospital),
                const SizedBox(height: 10),
                _buildDetailRow(LucideIcons.droplet, 'Blood Type', widget.bloodType),
                const SizedBox(height: 10),
                _buildDetailRow(LucideIcons.beaker, 'Units Required', widget.unitsNeeded),
                const SizedBox(height: 10),
                _buildDetailRow(LucideIcons.mapPin, 'Distance', widget.distance),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Phase status tracker
          if (_phase != _ResponsePhase.confirm) ...[
            _buildStatusTracker(),
            const SizedBox(height: 16),
          ],

          // Success countdown
          if (_phase == _ResponsePhase.success) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.clock, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    'Closing in $_countdown seconds...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF0284C7)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTracker() {
    final steps = [
      (label: 'Connecting', icon: LucideIcons.wifi, phase: _ResponsePhase.connecting),
      (label: 'Matching', icon: LucideIcons.search, phase: _ResponsePhase.matching),
      (label: 'Dispatched', icon: LucideIcons.truck, phase: _ResponsePhase.dispatched),
      (label: 'Confirmed', icon: LucideIcons.checkCircle, phase: _ResponsePhase.success),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStepRow(
              label: steps[i].label,
              icon: steps[i].icon,
              isActive: _phase.index >= steps[i].phase.index,
              isCurrent: _phase == steps[i].phase,
            ),
            if (i < steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  width: 2,
                  height: 16,
                  color: _phase.index > steps[i].phase.index
                      ? const Color(0xFF059669)
                      : const Color(0xFFE2E8F0),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
              width: isCurrent ? 2 : 1.2,
            ),
          ),
          child: isCurrent
              ? const Padding(
                  padding: EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF059669),
                  ),
                )
              : Icon(
                  isActive ? LucideIcons.check : icon,
                  size: 14,
                  color: isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
          ),
        ),
        const Spacer(),
        if (isActive && !isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF059669),
              ),
            ),
          ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Processing...',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD97706),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Column(
        children: [
          if (_phase == _ResponsePhase.confirm) ...[
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _startResponse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.heartPulse, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Confirm Response — I Will Donate',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: _cancelResponse,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: const Text(
                  'Not Now',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ] else if (_phase == _ResponsePhase.success) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.checkCircle, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Done — Close',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Processing state — show cancel only
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: _cancelResponse,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.x, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Cancel Response',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
