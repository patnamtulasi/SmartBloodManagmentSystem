import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/donor_models.dart';
import '../theme/app_theme.dart';
import '../services/file_download_service.dart';

/// Premium iOS-inspired Digital Donation & Recipient Allocation Receipt Modal.
/// Displays official proof of donation, donor vital stats, verified medical allocation,
/// recipient profile, transfusion verification, and NBTC certification.
class DonorDonationReceiptModal extends StatefulWidget {
  final DonorHistoryRecord record;
  final DonorProfileModel donor;

  const DonorDonationReceiptModal({
    super.key,
    required this.record,
    required this.donor,
  });

  static Future<void> show(
    BuildContext context, {
    required DonorHistoryRecord record,
    required DonorProfileModel donor,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Donation Receipt',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return DonorDonationReceiptModal(
          record: record,
          donor: donor,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  @override
  State<DonorDonationReceiptModal> createState() => _DonorDonationReceiptModalState();
}

class _DonorDonationReceiptModalState extends State<DonorDonationReceiptModal> {
  bool _isDownloading = false;

  void _handleDownloadPdf() {
    setState(() => _isDownloading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      FileDownloadService.downloadDonationReceipt(widget.record, widget.donor);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(LucideIcons.fileCheck, color: Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Official Receipt #${widget.record.receiptNumber} downloaded & saved to your device!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  void _handlePrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(LucideIcons.printer, color: Color(0xFF38BDF8), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Printing Official Donation & Recipient Receipt #${widget.record.receiptNumber}...',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Row(
          children: [
            Icon(LucideIcons.share2, color: Color(0xFF38BDF8), size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Verified Life-Saver Impact link copied to clipboard!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final rec = widget.record;
    final donor = widget.donor;

    final qrVerificationUrl =
        'https://vitalpulse.org/verify/receipt?id=${rec.receiptNumber}&donor=${Uri.encodeComponent(donor.name)}&recipient=${Uri.encodeComponent(rec.recipientName)}&blood=${rec.bloodType.label}&status=VERIFIED';

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isCompact ? screenWidth * 0.95 : 620,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
                        ),
                        child: const Icon(LucideIcons.fileText, color: Color(0xFF38BDF8), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'OFFICIAL DONATION RECEIPT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '• VERIFIED',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Receipt: ${rec.receiptNumber} • Bag ID: ${rec.bloodBagNumber}',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white70, size: 20),
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verified Life Saved Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFA7F3D0), width: 1.4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.heartPulse, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Transfusion Verified • 1 Life Saved',
                                      style: TextStyle(
                                        color: Color(0xFF065F46),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Your ${rec.unitsDonated} unit of ${rec.bloodType.label} was successfully allocated & transfused to save a critical patient.',
                                      style: const TextStyle(
                                        color: Color(0xFF047857),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section A: Donor Donation Summary
                        _buildSectionHeader(
                          icon: LucideIcons.userCheck,
                          title: '1. DONOR CONTRIBUTION SUMMARY',
                          badge: 'DONOR ID: ${donor.id}',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('Donor Name', donor.name, isBold: true),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow('Blood Group Donated', '${rec.bloodType.label} (${rec.bloodType.name})', highlightColor: AppTheme.primaryRed),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow('Donation Center', rec.donationCenter),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow(
                                'Donation Date',
                                '${rec.donationDate.day} ${_monthName(rec.donationDate.month)} ${rec.donationDate.year}',
                              ),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow('Units & Volume', '${rec.unitsDonated} Unit • ${rec.donationType}'),
                              const Divider(height: 14, color: Color(0xFFE2E8F0)),
                              _buildInfoRow(
                                'Donor Health Vitals',
                                'Hb: ${rec.hemoglobin}  •  BP: ${rec.bloodPressure}  •  Pulse: ${rec.pulse}',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Perforated Divider Visual
                        _buildPerforatedDivider(),

                        const SizedBox(height: 20),

                        // Section B: Recipient & Transfusion Details (Crucial Requirement)
                        _buildSectionHeader(
                          icon: LucideIcons.heartHandshake,
                          title: '2. RECIPIENT & TRANSFUSION ALLOCATION',
                          badge: 'CONFIDENTIAL MEDICAL RECORD',
                          badgeColor: const Color(0xFF0284C7),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFBAE6FD), width: 1.4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0284C7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(LucideIcons.user, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rec.recipientName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Age: ${rec.recipientAge} yrs  •  Gender: ${rec.recipientGender}  •  Match: ${rec.recipientBloodType.label}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.checkCheck, size: 13, color: Color(0xFF15803D)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Matched',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),
                              const Divider(height: 1, color: Color(0xFFBAE6FD)),
                              const SizedBox(height: 12),

                              _buildInfoRow('Hospital Facility', rec.recipientHospital, isBold: true),
                              const SizedBox(height: 8),
                              _buildInfoRow('Ward & Department', rec.recipientWard),
                              const SizedBox(height: 8),
                              _buildInfoRow('Supervising Specialist', rec.doctorInCharge),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Transfusion Timestamp',
                                '${rec.transfusionDate.day} ${_monthName(rec.transfusionDate.month)} ${rec.transfusionDate.year} • 14:30 IST',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow('Status Outcome', rec.transfusionStatus, highlightColor: const Color(0xFF059669)),

                              const SizedBox(height: 14),

                              // Heartwarming Thank You Story Box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF93C5FD)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(LucideIcons.quote, size: 14, color: Color(0xFF0284C7)),
                                        SizedBox(width: 6),
                                        Text(
                                          'Recipient & Family Impact Note',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF0284C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      rec.recipientThankYouNote,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section C: Verification, Official Seal & QR Code
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              // Scan QR code
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: QrImageView(
                                  data: qrVerificationUrl,
                                  version: QrVersions.auto,
                                  size: 76,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Official NBTC Digital Verification',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      rec.verifiedBy,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Cert Ref: ${rec.certificateId}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'monospace',
                                          color: Color(0xFF334155),
                                        ),
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

                // Bottom Action Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                  ),
                  child: Row(
                    children: [
                      // Print button
                      IconButton(
                        icon: const Icon(LucideIcons.printer, color: Colors.black),
                        tooltip: 'Print Receipt',
                        onPressed: _handlePrint,
                      ),
                      // Share button
                      IconButton(
                        icon: const Icon(LucideIcons.share2, color: Colors.black),
                        tooltip: 'Share Impact Certificate',
                        onPressed: _handleShare,
                      ),
                      const SizedBox(width: 8),
                      // Download PDF Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _handleDownloadPdf,
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.download, size: 16, color: Colors.white),
                          label: Text(
                            _isDownloading ? 'Generating PDF...' : 'Download PDF Receipt',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String badge,
    Color badgeColor = const Color(0xFF475569),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF0284C7)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: highlightColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerforatedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
