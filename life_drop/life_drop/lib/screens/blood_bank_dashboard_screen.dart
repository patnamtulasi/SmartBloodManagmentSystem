import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/blood_type.dart';
import '../models/blood_bank_models.dart';
import '../services/mock_data_service.dart';
import '../services/file_download_service.dart';
import '../theme/app_theme.dart';

class BloodBankDashboardScreen extends StatefulWidget {
  const BloodBankDashboardScreen({super.key});

  @override
  State<BloodBankDashboardScreen> createState() => _BloodBankDashboardScreenState();
}

class _BloodBankDashboardScreenState extends State<BloodBankDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BloodType _inlineDonorType = BloodType.oNeg;
  BloodType _inlineRecipientType = BloodType.aPos;
  double _coldChainTemp = 4.0;
  bool _autoExpiryAlert = true;
  bool _nightEmergencyDispatch = true;
  bool _autoRestockSms = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ms = Provider.of<MockDataService>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.droplet, size: 14, color: Color(0xFF7C3AED)),
                  SizedBox(width: 6),
                  Text('BLOOD BANK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED), letterSpacing: 0.8)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text('Blood Bank Dashboard', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black), overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          // Staff Role Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.shield, size: 12, color: Colors.black),
                const SizedBox(width: 4),
                Text(ms.bankCurrentStaffRole.roleName.split(' ').take(2).join(' '), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(width: 4),
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
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: const [
                  Tab(icon: Icon(LucideIcons.layoutDashboard, size: 14), text: 'Overview'),
                  Tab(icon: Icon(LucideIcons.database, size: 14), text: 'Inventory'),
                  Tab(icon: Icon(LucideIcons.alertTriangle, size: 14), text: 'Alerts'),
                  Tab(icon: Icon(LucideIcons.clipboardList, size: 14), text: 'Hospital Req'),
                  Tab(icon: Icon(LucideIcons.flame, size: 14), text: 'Emergency'),
                  Tab(icon: Icon(LucideIcons.droplets, size: 14), text: 'Donations'),
                  Tab(icon: Icon(LucideIcons.truck, size: 14), text: 'Transfers'),
                  Tab(icon: Icon(LucideIcons.barChart3, size: 14), text: 'Reports'),
                  Tab(icon: Icon(LucideIcons.bell, size: 14), text: 'Notifications'),
                  Tab(icon: Icon(LucideIcons.settings, size: 14), text: 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(ms),
          _buildInventoryTab(ms),
          _buildAlertsTab(ms),
          _buildHospitalRequestsTab(ms),
          _buildEmergencyTab(ms),
          _buildDonationsTab(ms),
          _buildTransfersTab(ms),
          _buildReportsTab(ms),
          _buildNotificationsTab(ms),
          _buildSettingsTab(ms),
        ],
      ),
    );
  }

  // ========================= HELPERS =========================
  Widget _summaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 13, color: color)),
            const Spacer(),
            if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color)),
          ]),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 1),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, {IconData? icon}) {
    return Row(children: [
      if (icon != null) ...[Icon(icon, size: 18, color: Colors.black), const SizedBox(width: 8)],
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
    ]);
  }

  Color _statusColor(BankInventoryStatus s) {
    switch (s) {
      case BankInventoryStatus.normal: return const Color(0xFF059669);
      case BankInventoryStatus.lowStock: return const Color(0xFFF59E0B);
      case BankInventoryStatus.critical: return const Color(0xFFDC2626);
      case BankInventoryStatus.expiringSoon: return const Color(0xFFEA580C);
      case BankInventoryStatus.expired: return const Color(0xFF6B7280);
    }
  }

  Color _reqStatusColor(BankHospitalReqStatus s) {
    switch (s) {
      case BankHospitalReqStatus.pending: return const Color(0xFFF59E0B);
      case BankHospitalReqStatus.underReview: return const Color(0xFF0284C7);
      case BankHospitalReqStatus.approved: return const Color(0xFF059669);
      case BankHospitalReqStatus.partiallyFulfilled: return const Color(0xFFEA580C);
      case BankHospitalReqStatus.fulfilled: return const Color(0xFF10B981);
      case BankHospitalReqStatus.rejected: return const Color(0xFFDC2626);
      case BankHospitalReqStatus.cancelled: return const Color(0xFF6B7280);
    }
  }

  void _showSnack(String msg, {IconData icon = LucideIcons.checkCircle2, Color iconColor = const Color(0xFF059669)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _confirmAction(String title, String body, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16)),
        content: Text(body, style: const TextStyle(color: Color(0xFF374151))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.black))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ==================== INVENTORY ACTION MODALS ====================

  void _showAddUnitsModal(MockDataService ms, BankInventoryItem inv) {
    int unitsToAdd = 2;
    String selectedLocation = inv.storageLocation;
    String batch = inv.batchNumber;
    String intakeSource = 'Voluntary Camp Intake';
    final batchCtrl = TextEditingController(text: batch);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Add Blood Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Increase inventory stock with verified intake', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.database, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Text('Current Available: ${inv.availableUnits} units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                              const Spacer(),
                              Text('New Total: ${inv.availableUnits + unitsToAdd} units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text('Units to Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: unitsToAdd > 1 ? () => setModalState(() => unitsToAdd--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToAdd > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: unitsToAdd > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                '$unitsToAdd Units',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: () => setModalState(() => unitsToAdd++),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(LucideIcons.plus, size: 18, color: Colors.black),
                              ),
                            ),
                            const Spacer(),
                            ...[1, 5, 10].map((inc) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ActionChip(
                                label: Text('+$inc', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                onPressed: () => setModalState(() => unitsToAdd += inc),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Storage Location / Compartment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedLocation,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                              items: {
                                inv.storageLocation,
                                'Cryo Main Vault (2-6°C)',
                                'Platelet Agitator Rack B-2',
                                'Emergency Resuscitation Chiller',
                                'Quarantine Vault Alpha',
                              }.map((loc) => DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(color: Colors.black)))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedLocation = val); },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Batch Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: batchCtrl,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Intake Source', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: intakeSource,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11),
                                        items: [
                                          'Voluntary Camp Intake',
                                          'Red Cross Depot Transfer',
                                          'Post-Testing Clearance',
                                          'Apheresis Clinic Intake',
                                        ].map((src) => DropdownMenuItem(value: src, child: Text(src, style: const TextStyle(color: Colors.black)))).toList(),
                                        onChanged: (val) { if (val != null) setModalState(() => intakeSource = val); },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final finalBatch = batchCtrl.text.trim().isEmpty ? inv.batchNumber : batchCtrl.text.trim();
                              ms.addBankInventoryUnits(inv.bloodType, unitsToAdd, finalBatch, selectedLocation);
                              Navigator.pop(ctx);
                              _showSnack('Added $unitsToAdd units of ${inv.bloodType.label}. Stock updated to ${inv.availableUnits} units.');
                            },
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: Text('Confirm & Add $unitsToAdd Units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReserveUnitsModal(MockDataService ms, BankInventoryItem inv) {
    if (inv.availableUnits <= 0) {
      _showSnack('Cannot reserve: 0 units of ${inv.bloodType.label} currently available in stock.', icon: LucideIcons.alertTriangle, iconColor: const Color(0xFFDC2626));
      return;
    }

    int unitsToReserve = 1;
    String selectedReason = 'Cardiology OT Surgery Hold';
    final hospitalRefCtrl = TextEditingController(text: 'Apollo Speciality - OT 4');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Reserve Blood Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Hold units for hospital surgeries and clinical orders', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.lock, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Text('Available: ${inv.availableUnits} units · Reserved: ${inv.reservedUnits}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                              const Spacer(),
                              Text('After: ${inv.availableUnits - unitsToReserve} avail', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text('Units to Reserve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: unitsToReserve > 1 ? () => setModalState(() => unitsToReserve--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToReserve > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: unitsToReserve > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0284C7), width: 1.5),
                              ),
                              child: Text(
                                '$unitsToReserve Units',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: unitsToReserve < inv.availableUnits ? () => setModalState(() => unitsToReserve++) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToReserve < inv.availableUnits ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.plus, size: 18, color: unitsToReserve < inv.availableUnits ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const Spacer(),
                            ActionChip(
                              label: const Text('Max', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onPressed: () => setModalState(() => unitsToReserve = inv.availableUnits),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Reservation Purpose', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedReason,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                              items: [
                                'Cardiology OT Surgery Hold',
                                'Emergency Trauma Protocol (MTP)',
                                'Thalassemia Scheduled Transfusion',
                                'High-Risk Maternal Delivery OT',
                                'Elective Orthopedic Crossmatch',
                              ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.black)))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedReason = val); },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text('Requester / Hospital Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: hospitalRefCtrl,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final ref = hospitalRefCtrl.text.trim().isEmpty ? 'General Hold' : hospitalRefCtrl.text.trim();
                              ms.reserveBankUnits(inv.bloodType, unitsToReserve, '$selectedReason ($ref)');
                              Navigator.pop(ctx);
                              _showSnack('Reserved $unitsToReserve units of ${inv.bloodType.label} for $selectedReason.', icon: LucideIcons.lock, iconColor: const Color(0xFF0284C7));
                            },
                            icon: const Icon(LucideIcons.lock, size: 16),
                            label: Text('Confirm Reserve of $unitsToReserve Units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReleaseUnitsModal(MockDataService ms, BankInventoryItem inv) {
    if (inv.reservedUnits <= 0) {
      _showSnack('No units of ${inv.bloodType.label} are currently reserved.', icon: LucideIcons.info, iconColor: const Color(0xFF0284C7));
      return;
    }

    int unitsToRelease = 1;
    String releaseReason = 'Surgery Completed / Units Unused';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF059669))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Release Reserved Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Return reserved blood units back to available stock', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.unlock, size: 16, color: Color(0xFF059669)),
                              const SizedBox(width: 8),
                              Text('Reserved: ${inv.reservedUnits} units · Available: ${inv.availableUnits}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                              const Spacer(),
                              Text('New Avail: ${inv.availableUnits + unitsToRelease}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text('Units to Release', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: unitsToRelease > 1 ? () => setModalState(() => unitsToRelease--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToRelease > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: unitsToRelease > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF059669), width: 1.5),
                              ),
                              child: Text(
                                '$unitsToRelease Units',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: unitsToRelease < inv.reservedUnits ? () => setModalState(() => unitsToRelease++) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToRelease < inv.reservedUnits ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.plus, size: 18, color: unitsToRelease < inv.reservedUnits ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const Spacer(),
                            ActionChip(
                              label: const Text('All Reserved', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onPressed: () => setModalState(() => unitsToRelease = inv.reservedUnits),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Release Reason', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: releaseReason,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                              items: [
                                'Surgery Completed / Units Unused',
                                'Crossmatch Hold Expired',
                                'Patient Transferred / Discharged',
                                'Administrative Allocation Release',
                              ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.black)))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => releaseReason = val); },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ms.releaseBankReservedUnits(inv.bloodType, unitsToRelease);
                              Navigator.pop(ctx);
                              _showSnack('Released $unitsToRelease reserved units of ${inv.bloodType.label} back to available stock.');
                            },
                            icon: const Icon(LucideIcons.unlock, size: 16),
                            label: Text('Confirm Release of $unitsToRelease Units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMarkUsedModal(MockDataService ms, BankInventoryItem inv) {
    final hasReserved = inv.reservedUnits > 0;
    final hasAvailable = inv.availableUnits > 0;

    if (!hasReserved && !hasAvailable) {
      _showSnack('No blood units in stock for ${inv.bloodType.label} to mark as used.', icon: LucideIcons.alertTriangle, iconColor: const Color(0xFFDC2626));
      return;
    }

    bool fromReserved = hasReserved;
    int maxLimit = fromReserved ? inv.reservedUnits : inv.availableUnits;
    int unitsToUse = maxLimit > 0 ? 1 : 0;
    final reqRefCtrl = TextEditingController(text: 'TX-HREQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    final clinicalWardCtrl = TextEditingController(text: 'ICU Trauma Bay 2');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            maxLimit = fromReserved ? inv.reservedUnits : inv.availableUnits;
            if (unitsToUse > maxLimit) unitsToUse = maxLimit > 0 ? maxLimit : 1;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mark Units as Used', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Record clinical utilization & deduct units from bank', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Deduction Source Selector
                        const Text('Deduct From', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (hasReserved)
                              Expanded(
                                child: InkWell(
                                  onTap: () => setModalState(() {
                                    fromReserved = true;
                                    unitsToUse = 1;
                                  }),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: fromReserved ? const Color(0xFFF1F5F9) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: fromReserved ? Colors.black : const Color(0xFFE2E8F0), width: fromReserved ? 1.5 : 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(fromReserved ? LucideIcons.checkCircle2 : LucideIcons.circle, size: 14, color: fromReserved ? Colors.black : const Color(0xFF94A3B8)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text('Reserved (${inv.reservedUnits} units)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black), overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (hasReserved && hasAvailable) const SizedBox(width: 8),
                            if (hasAvailable)
                              Expanded(
                                child: InkWell(
                                  onTap: () => setModalState(() {
                                    fromReserved = false;
                                    unitsToUse = 1;
                                  }),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !fromReserved ? const Color(0xFFF1F5F9) : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: !fromReserved ? Colors.black : const Color(0xFFE2E8F0), width: !fromReserved ? 1.5 : 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(!fromReserved ? LucideIcons.checkCircle2 : LucideIcons.circle, size: 14, color: !fromReserved ? Colors.black : const Color(0xFF94A3B8)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text('Available (${inv.availableUnits} units)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black), overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Units Consumed', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: unitsToUse > 1 ? () => setModalState(() => unitsToUse--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToUse > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: unitsToUse > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                '$unitsToUse Units',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: unitsToUse < maxLimit ? () => setModalState(() => unitsToUse++) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToUse < maxLimit ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.plus, size: 18, color: unitsToUse < maxLimit ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const Spacer(),
                            ActionChip(
                              label: const Text('Max', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onPressed: () => setModalState(() => unitsToUse = maxLimit),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Requisition / Case Ref', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: reqRefCtrl,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ward / Surgery Room', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: clinicalWardCtrl,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final ref = reqRefCtrl.text.trim().isEmpty ? 'Direct Clinical Usage' : '${reqRefCtrl.text.trim()} (${clinicalWardCtrl.text.trim()})';
                              ms.markBankUnitsUsed(inv.bloodType, unitsToUse, ref, fromReserved: fromReserved);
                              Navigator.pop(ctx);
                              _showSnack('Marked $unitsToUse units of ${inv.bloodType.label} as utilized. Total used now: ${inv.usedUnits}.');
                            },
                            icon: const Icon(LucideIcons.checkSquare, size: 16),
                            label: Text('Confirm $unitsToUse Units Used', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showExpireUnitsModal(MockDataService ms, BankInventoryItem inv) {
    if (inv.availableUnits <= 0) {
      _showSnack('No units of ${inv.bloodType.label} in available stock to discard.', icon: LucideIcons.alertTriangle, iconColor: const Color(0xFFDC2626));
      return;
    }

    int unitsToExpire = inv.expiringUnits > 0 ? (inv.expiringUnits <= inv.availableUnits ? inv.expiringUnits : inv.availableUnits) : 1;
    String selectedReason = 'Exceeded 42-day RBC maximum shelf life';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Discard / Expire Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Biohazard disposal logging & stock deduction', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFDC2626)),
                              const SizedBox(width: 8),
                              Text('Available: ${inv.availableUnits} · Tagged Expiring: ${inv.expiringUnits}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                              const Spacer(),
                              Text('Remaining: ${inv.availableUnits - unitsToExpire}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text('Units to Discard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: unitsToExpire > 1 ? () => setModalState(() => unitsToExpire--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToExpire > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: unitsToExpire > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                              ),
                              child: Text(
                                '$unitsToExpire Units',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: unitsToExpire < inv.availableUnits ? () => setModalState(() => unitsToExpire++) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToExpire < inv.availableUnits ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.plus, size: 18, color: unitsToExpire < inv.availableUnits ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const Spacer(),
                            if (inv.expiringUnits > 0)
                              ActionChip(
                                label: Text('All Expiring (${inv.expiringUnits})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                                backgroundColor: const Color(0xFFFEF2F2),
                                side: const BorderSide(color: Color(0xFFFCA5A5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                onPressed: () => setModalState(() => unitsToExpire = inv.expiringUnits.clamp(1, inv.availableUnits)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Disposal Reason', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedReason,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                              items: [
                                'Exceeded 42-day RBC maximum shelf life',
                                'Cold-chain temp breach (>6°C excursion)',
                                'Visual hemolysis or clot detected',
                                'Bag puncture or seal leakage',
                                'NAT / Serological repeat-reactive test',
                              ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.black)))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedReason = val); },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ms.markBankUnitsExpired(inv.bloodType, unitsToExpire, selectedReason);
                              Navigator.pop(ctx);
                              _showSnack('Discarded $unitsToExpire units of ${inv.bloodType.label}. Remaining stock: ${inv.availableUnits}.', icon: LucideIcons.trash2, iconColor: const Color(0xFFDC2626));
                            },
                            icon: const Icon(LucideIcons.xCircle, size: 16),
                            label: Text('Confirm Discard of $unitsToExpire Units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== TRANSFER CREATION MODAL ====================

  void _showCreateTransferModal(MockDataService ms) {
    bool isOutbound = true;
    BloodType selectedType = BloodType.oPos;
    int unitsToTransfer = 2;
    String selectedCarrier = 'Cold-Chain Van #04 (Temp 2°C–6°C)';
    String urgencyLevel = 'STAT Emergency (<45 min)';
    String selectedFacility = 'Apollo Speciality Hospital (Greams Road)';
    final customDestCtrl = TextEditingController();
    final notesCtrl = TextEditingController(text: 'Urgent Surgical Deficit Transfer');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentStockItem = ms.bankInventory.firstWhere((i) => i.bloodType == selectedType);
            final availableStock = currentStockItem.availableUnits;
            final isStockWarning = isOutbound && unitsToTransfer > availableStock;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(LucideIcons.truck, size: 20, color: Color(0xFF7C3AED)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Create Blood Transfer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Dispatch cold-chain logistics or requisition partner stock', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Direction Selector
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setModalState(() {
                                    isOutbound = true;
                                    selectedFacility = 'Apollo Speciality Hospital (Greams Road)';
                                  }),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isOutbound ? Colors.black : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(LucideIcons.arrowUpRight, size: 14, color: isOutbound ? Colors.white : Colors.black),
                                          const SizedBox(width: 6),
                                          Text('Outbound Dispatch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isOutbound ? Colors.white : Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setModalState(() {
                                    isOutbound = false;
                                    selectedFacility = 'Valley Regional Blood Hub';
                                  }),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !isOutbound ? Colors.black : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(LucideIcons.arrowDownLeft, size: 14, color: !isOutbound ? Colors.white : Colors.black),
                                          const SizedBox(width: 6),
                                          Text('Inbound Requisition', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: !isOutbound ? Colors.white : Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Blood Type Selector with stock indicators
                        const Text('Blood Group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: BloodType.values.map((bt) {
                            final isSel = bt == selectedType;
                            final stock = ms.bankInventory.firstWhere((i) => i.bloodType == bt).availableUnits;
                            return InkWell(
                              onTap: () => setModalState(() => selectedType = bt),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.black : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSel ? Colors.black : const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(bt.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isSel ? Colors.white : Colors.black)),
                                    Text('$stock avail', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isSel ? Colors.white70 : const Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        // Units Stepper
                        const Text('Number of Units', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: unitsToTransfer > 1 ? () => setModalState(() => unitsToTransfer--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: unitsToTransfer > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: unitsToTransfer > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isStockWarning ? const Color(0xFFDC2626) : Colors.black, width: 1.5),
                              ),
                              child: Text(
                                '$unitsToTransfer Units',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isStockWarning ? const Color(0xFFDC2626) : Colors.black),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: () => setModalState(() => unitsToTransfer++),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(LucideIcons.plus, size: 18, color: Colors.black),
                              ),
                            ),
                            const Spacer(),
                            if (isOutbound && availableStock > 0)
                              ActionChip(
                                label: Text('Max Avail ($availableStock)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                onPressed: () => setModalState(() => unitsToTransfer = availableStock),
                              ),
                          ],
                        ),
                        if (isStockWarning)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFCA5A5))),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.alertTriangle, size: 14, color: Color(0xFFDC2626)),
                                const SizedBox(width: 6),
                                Expanded(child: Text('Requested $unitsToTransfer units exceeds available stock ($availableStock units). Stock will go to 0 and trigger low-stock alert.', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)))),
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),
                        // Destination / Origin Facility
                        Text(isOutbound ? 'Destination Facility / Hospital' : 'Supplying Blood Bank / Network', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedFacility,
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13),
                              items: (isOutbound ? [
                                'Apollo Speciality Hospital (Greams Road)',
                                'Fortis Memorial Research Institute',
                                'All India Institute of Medical Sciences (AIIMS)',
                                'City General Trauma ICU',
                                'Seattle Grace Trauma Center',
                                'Valley Regional Blood Hub',
                                'Custom Facility Name',
                              ] : [
                                'Valley Regional Blood Hub',
                                'Metropolitan Central Reserve Depot',
                                'Red Cross State Storage Depot',
                                'St. Jude Regional Blood Bank',
                                'Custom Facility Name',
                              ]).map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(color: Colors.black)))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedFacility = val); },
                            ),
                          ),
                        ),
                        if (selectedFacility == 'Custom Facility Name') ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: customDestCtrl,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Enter custom facility or center name...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        // Transport Carrier & Urgency
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Transport Carrier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedCarrier,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11),
                                        items: [
                                          'Cold-Chain Van #04 (Temp 2°C–6°C)',
                                          'VitalPulse AeroDrop Drone (STAT Relay)',
                                          'Emergency ALS Ambulance Escort',
                                          'Medical Logistics Express Van',
                                        ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.black)))).toList(),
                                        onChanged: (val) { if (val != null) setModalState(() => selectedCarrier = val); },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Urgency Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: urgencyLevel,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11),
                                        items: [
                                          'STAT Emergency (<45 min)',
                                          'Urgent Surgery (<2 hrs)',
                                          'Routine Stock Rebalance (4-6 hrs)',
                                        ].map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(color: Colors.black)))).toList(),
                                        onChanged: (val) { if (val != null) setModalState(() => urgencyLevel = val); },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text('Waybill Notes / Clinical Reason', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: notesCtrl,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final dest = selectedFacility == 'Custom Facility Name' && customDestCtrl.text.trim().isNotEmpty
                                  ? customDestCtrl.text.trim()
                                  : selectedFacility;
                              final src = isOutbound ? ms.bankProfile.name : dest;
                              final finalDest = isOutbound ? dest : ms.bankProfile.name;

                              ms.createBankTransfer(
                                destination: finalDest,
                                type: selectedType,
                                units: unitsToTransfer,
                                carrier: selectedCarrier,
                                sourceOrg: src,
                                urgency: urgencyLevel,
                              );
                              Navigator.pop(ctx);
                              _showSnack('Transfer generated successfully! Waybill created and trackable under Transfers.', icon: LucideIcons.truck, iconColor: const Color(0xFF7C3AED));
                            },
                            icon: const Icon(LucideIcons.checkCircle2, size: 16),
                            label: Text(
                              isOutbound ? 'Dispatch Outbound Transfer ($unitsToTransfer Units)' : 'Submit Inbound Requisition ($unitsToTransfer Units)',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== ALERTS ACTION MODALS ====================

  void _showNotifyDonorsModal(MockDataService ms, BankLowStockAlert alert) {
    int selectedRadius = 15;
    bool enableSms = true;
    bool enableAppPush = true;
    bool enableIvrCall = false;

    int donorCountForRadius(int r) {
      if (r == 5) return 12;
      if (r == 15) return 38;
      return 84;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final matchingDonors = donorCountForRadius(selectedRadius);
            final deficit = alert.requiredMinimumUnits - alert.currentUnits;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(alert.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Emergency Donor Appeal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Broadcast real-time mobile appeal to compatible donors', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Deficit Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertTriangle, size: 18, color: Color(0xFFDC2626)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Shortage Deficit: $deficit units needed', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                                    Text('Current Available: ${alert.currentUnits} / Minimum Safe Threshold: ${alert.requiredMinimumUnits} units', style: const TextStyle(fontSize: 11, color: Color(0xFF7F1D1D))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Radius Filter
                        const Text('Broadcast Search Radius', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [5, 15, 30].map((r) {
                            final isSel = selectedRadius == r;
                            final count = donorCountForRadius(r);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: InkWell(
                                  onTap: () => setModalState(() => selectedRadius = r),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSel ? Colors.black : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isSel ? Colors.black : const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('$r km', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isSel ? Colors.white : Colors.black)),
                                        Text('~$count donors', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: isSel ? Colors.white70 : const Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        // Communication Channels
                        const Text('Notification Dispatch Channels', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Priority Emergency SMS (Direct GSM Gateway)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                          subtitle: const Text('Delivers within 30 seconds to all registered mobile phones', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          value: enableSms,
                          activeColor: Colors.black,
                          onChanged: (v) => setModalState(() => enableSms = v ?? true),
                        ),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('VitalPulse App Push Notification (High Priority)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                          subtitle: const Text('Pops up interactive booking action directly on user smartphone', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          value: enableAppPush,
                          activeColor: Colors.black,
                          onChanged: (v) => setModalState(() => enableAppPush = v ?? true),
                        ),
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Automated IVR Urgent Voice Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black)),
                          subtitle: const Text('Voice call for critical tier donors who opted in for emergency alerts', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                          value: enableIvrCall,
                          activeColor: Colors.black,
                          onChanged: (v) => setModalState(() => enableIvrCall = v ?? false),
                        ),
                        const SizedBox(height: 14),
                        // Message Preview
                        const Text('Broadcast Message Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '🚨 URGENT DONOR APPEAL: VitalPulse Central Blood Bank requires urgent ${alert.bloodType.label} donations due to critical shortage ($deficit units needed). If you are eligible, please tap here to book a priority slot or call 1800-VITAL-PULSE. +150 Lifesaver karma points awarded upon arrival.',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.4, fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final channels = <String>[];
                              if (enableSms) channels.add('Emergency SMS');
                              if (enableAppPush) channels.add('VitalPulse App Push');
                              if (enableIvrCall) channels.add('Automated IVR');
                              if (channels.isEmpty) channels.add('VitalPulse Push Alert');

                              ms.notifyDonorsForLowStock(
                                alert.bloodType,
                                donorCount: matchingDonors,
                                radiusKm: selectedRadius,
                                channels: channels,
                              );
                              Navigator.pop(ctx);
                              _showSnack('Emergency appeal sent to $matchingDonors compatible ${alert.bloodType.label} donors in $selectedRadius km radius.', icon: LucideIcons.bell, iconColor: AppTheme.skyBlue);
                            },
                            icon: const Icon(LucideIcons.send, size: 16),
                            label: Text('Send Emergency Appeal to $matchingDonors Donors', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestTransferModal(MockDataService ms, BankLowStockAlert alert) {
    int requestedUnits = (alert.requiredMinimumUnits - alert.currentUnits).clamp(1, 20);
    String selectedBank = 'Valley Regional Blood Hub';
    String urgencyLevel = 'STAT Emergency (<45 min)';
    String selectedCarrier = 'Cold-Chain Van Relay (Active Cooling 2°C–6°C)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(alert.bloodType.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Request Inter-Bank Transfer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                                  Text('Requisition emergency stock replenishment from partner hub', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.x, color: Colors.black, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.info, size: 16, color: Color(0xFF0284C7)),
                              const SizedBox(width: 8),
                              Text('Shortage Deficit: ${alert.requiredMinimumUnits - alert.currentUnits} units needed', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                              const Spacer(),
                              Text('Priority: ${alert.priority.name.toUpperCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text('Units to Requisition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            InkWell(
                              onTap: requestedUnits > 1 ? () => setModalState(() => requestedUnits--) : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: requestedUnits > 1 ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Icon(LucideIcons.minus, size: 18, color: requestedUnits > 1 ? Colors.black : const Color(0xFF94A3B8)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Text(
                                '$requestedUnits Units',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 14),
                            InkWell(
                              onTap: () => setModalState(() => requestedUnits++),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(LucideIcons.plus, size: 18, color: Colors.black),
                              ),
                            ),
                            const Spacer(),
                            ActionChip(
                              label: Text('Deficit (${alert.requiredMinimumUnits - alert.currentUnits})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              onPressed: () => setModalState(() => requestedUnits = (alert.requiredMinimumUnits - alert.currentUnits).clamp(1, 20)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text('Supplying Regional Center', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 8),
                        ...[
                          {'name': 'Valley Regional Blood Hub', 'dist': '12 km away', 'stock': '28 units in stock', 'time': 'Est. 45 min'},
                          {'name': 'Metropolitan Central Reserve', 'dist': '18 km away', 'stock': '42 units in stock', 'time': 'Est. 1h 15m'},
                          {'name': 'Red Cross State Depot', 'dist': '26 km away', 'stock': '64 units in stock', 'time': 'Est. 1h 45m'},
                        ].map((b) {
                          final isSel = selectedBank == b['name'];
                          return InkWell(
                            onTap: () => setModalState(() => selectedBank = b['name']!),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.black.withValues(alpha: 0.04) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSel ? Colors.black : const Color(0xFFE2E8F0), width: isSel ? 1.5 : 1),
                              ),
                              child: Row(
                                children: [
                                  Icon(isSel ? LucideIcons.checkCircle2 : LucideIcons.circle, size: 18, color: isSel ? Colors.black : const Color(0xFF94A3B8)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(b['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                        Text('${b['dist']} · ${b['stock']} · ${b['time']}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Urgency', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: urgencyLevel,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11),
                                        items: [
                                          'STAT Emergency (<45 min)',
                                          'Urgent Surgery (<2 hrs)',
                                          'Standard Rebalance (Same Day)',
                                        ].map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(color: Colors.black)))).toList(),
                                        onChanged: (val) { if (val != null) setModalState(() => urgencyLevel = val); },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Logistics Carrier', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedCarrier,
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11),
                                        items: [
                                          'Cold-Chain Van Relay (Active Cooling 2°C–6°C)',
                                          'VitalPulse STAT Drone Dispatch',
                                          'Emergency Ambulance Courier',
                                        ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.black)))).toList(),
                                        onChanged: (val) { if (val != null) setModalState(() => selectedCarrier = val); },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ms.requestTransferForLowStock(
                                alert.bloodType,
                                requestedUnits,
                                selectedBank,
                                urgency: urgencyLevel,
                                carrier: selectedCarrier,
                              );
                              ms.reviewLowStockAlert(alert.id);
                              Navigator.pop(ctx);
                              _showSnack('Requisition for $requestedUnits units of ${alert.bloodType.label} sent to $selectedBank. Trackable under Transfers.', icon: LucideIcons.truck, iconColor: const Color(0xFF7C3AED));
                            },
                            icon: const Icon(LucideIcons.send, size: 16),
                            label: Text('Submit Requisition for $requestedUnits Units', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ========================= 1. OVERVIEW =========================
  Widget _buildOverviewTab(MockDataService ms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Blood Bank Overview', icon: LucideIcons.layoutDashboard),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: MediaQuery.of(context).size.width < 600 ? 2.3 : 1.95,
            children: [
              _summaryCard('Total Blood Units', '${ms.bankTotalUnits}', LucideIcons.droplets, const Color(0xFF7C3AED)),
              _summaryCard('Available Units', '${ms.bankAvailableUnits}', LucideIcons.checkCircle2, const Color(0xFF059669)),
              _summaryCard('Reserved Units', '${ms.bankReservedUnits}', LucideIcons.lock, const Color(0xFF0284C7)),
              _summaryCard('Expiring Soon', '${ms.bankExpiringSoonUnits}', LucideIcons.clock, const Color(0xFFEA580C), subtitle: 'URGENT'),
              _summaryCard('Low-Stock Groups', '${ms.bankLowStockCount}', LucideIcons.alertTriangle, const Color(0xFFDC2626), subtitle: 'ALERT'),
              _summaryCard('Pending Requests', '${ms.bankPendingRequestsCount}', LucideIcons.clipboardList, const Color(0xFFF59E0B)),
              _summaryCard('Incoming Donations', '${ms.bankIncomingDonationsCount}', LucideIcons.heart, const Color(0xFF10B981)),
              _summaryCard('Transfers Active', '${ms.bankTransfersInProgressCount}', LucideIcons.truck, const Color(0xFF0284C7)),
            ],
          ),
          const SizedBox(height: 24),
          // Quick Inventory Snapshot
          _sectionHeader('Inventory Snapshot', icon: LucideIcons.database),
          const SizedBox(height: 12),
          ...ms.bankInventory.map((inv) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _statusColor(inv.status).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: _statusColor(inv.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(inv.bloodType.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _statusColor(inv.status)))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${inv.availableUnits} avail · ${inv.reservedUnits} reserved', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                    Text('Min: ${inv.minimumStockThreshold} · ${inv.storageLocation}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor(inv.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(inv.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _statusColor(inv.status))),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          // Staff Role Selector
          _sectionHeader('Staff Role (Simulated)', icon: LucideIcons.shield),
          const SizedBox(height: 10),
          ...BankStaffRole.values.map((role) {
            final isActive = ms.bankCurrentStaffRole == role;
            return GestureDetector(
              onTap: () => ms.setBankStaffRole(role),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black.withValues(alpha: 0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isActive ? Colors.black : const Color(0xFFE2E8F0), width: isActive ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.user, size: 16, color: isActive ? Colors.black : const Color(0xFF64748B)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.roleName, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w900 : FontWeight.w600, color: Colors.black)),
                        Text(role.permissions.join(' · '), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    )),
                    if (isActive) const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF059669)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========================= 2. INVENTORY =========================
  Widget _buildInventoryTab(MockDataService ms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Blood Inventory Management', icon: LucideIcons.database),
                    const SizedBox(height: 4),
                    const Text('Manage all 8 blood group inventories', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  FileDownloadService.downloadBloodBankInventoryCsv(ms);
                  _showSnack('Blood bank inventory register downloaded as CSV!');
                },
                icon: const Icon(LucideIcons.download, size: 14),
                label: const Text('Export CSV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...ms.bankInventory.map((inv) => _buildInventoryCard(ms, inv)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(MockDataService ms, BankInventoryItem inv) {
    final sc = _statusColor(inv.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sc.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: sc.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(inv.bloodType.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: sc)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Batch: ${inv.batchNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
                Text(inv.storageLocation, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(inv.status == BankInventoryStatus.normal ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle, size: 12, color: sc),
                const SizedBox(width: 4),
                Text(inv.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: sc)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          // Stats Row
          Row(children: [
            _invStat('Available', '${inv.availableUnits}', const Color(0xFF059669)),
            _invStat('Reserved', '${inv.reservedUnits}', const Color(0xFF0284C7)),
            _invStat('Used', '${inv.usedUnits}', const Color(0xFF64748B)),
            _invStat('Expiring', '${inv.expiringUnits}', const Color(0xFFEA580C)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('Collected: ${inv.collectionDate.day}/${inv.collectionDate.month}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            const SizedBox(width: 16),
            Text('Expires: ${inv.expiryDate.day}/${inv.expiryDate.month}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            const SizedBox(width: 16),
            Text('Min Stock: ${inv.minimumStockThreshold}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
          ]),
          const SizedBox(height: 12),
          // Action Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _actionChip('Add Units', LucideIcons.plus, () => _showAddUnitsModal(ms, inv)),
              _actionChip('Reserve', LucideIcons.lock, () => _showReserveUnitsModal(ms, inv)),
              _actionChip('Release', LucideIcons.unlock, () => _showReleaseUnitsModal(ms, inv)),
              _actionChip('Mark Used', LucideIcons.checkSquare, () => _showMarkUsedModal(ms, inv)),
              _actionChip('Expire', LucideIcons.xCircle, () => _showExpireUnitsModal(ms, inv)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _invStat(String label, String value, Color color) {
    return Expanded(child: Column(children: [
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
    ]));
  }

  Widget _actionChip(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: Colors.black),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
        onPressed: onTap,
        backgroundColor: const Color(0xFFF8FAFC),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ========================= 3. ALERTS =========================
  Widget _buildAlertsTab(MockDataService ms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Low-Stock Alerts', icon: LucideIcons.alertTriangle),
          const SizedBox(height: 12),
          ...ms.bankLowStockAlerts.map((alert) {
            final pColor = alert.priority == LowStockAlertPriority.critical
                ? const Color(0xFFDC2626)
                : alert.priority == LowStockAlertPriority.high
                    ? const Color(0xFFEA580C)
                    : const Color(0xFFF59E0B);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: alert.isReviewed ? const Color(0xFFE2E8F0) : pColor.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [BoxShadow(color: pColor.withValues(alpha: 0.06), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: pColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(alert.bloodType.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: pColor)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Current: ${alert.currentUnits} / Min: ${alert.requiredMinimumUnits}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                      Text('Priority: ${alert.priority.name.toUpperCase()}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pColor)),
                    ])),
                    if (alert.isReviewed) const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF059669)),
                  ]),
                  const SizedBox(height: 10),
                  Text(alert.suggestedAction, style: const TextStyle(fontSize: 12, color: Color(0xFF374151), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _actionChip('Notify Donors', LucideIcons.bell, () => _showNotifyDonorsModal(ms, alert)),
                      _actionChip('Request Transfer', LucideIcons.truck, () => _showRequestTransferModal(ms, alert)),
                      if (!alert.isReviewed) _actionChip('Mark Reviewed', LucideIcons.checkSquare, () { ms.reviewLowStockAlert(alert.id); _showSnack('Alert marked as reviewed'); }),
                    ]),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
          _sectionHeader('Expiry & Wastage Management', icon: LucideIcons.clock),
          const SizedBox(height: 12),
          // Summary counts
          Row(children: [
            _expiryStatCard('Today', ms.bankExpiryItems.where((e) => e.timeframe == 'today').fold(0, (s, e) => s + e.units), const Color(0xFFDC2626)),
            const SizedBox(width: 8),
            _expiryStatCard('3 Days', ms.bankExpiryItems.where((e) => e.timeframe == '3_days').fold(0, (s, e) => s + e.units), const Color(0xFFEA580C)),
            const SizedBox(width: 8),
            _expiryStatCard('7 Days', ms.bankExpiryItems.where((e) => e.timeframe == '7_days').fold(0, (s, e) => s + e.units), const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            _expiryStatCard('Expired', ms.bankExpiryItems.where((e) => e.timeframe == 'expired').fold(0, (s, e) => s + e.units), const Color(0xFF6B7280)),
          ]),
          const SizedBox(height: 14),
          ...ms.bankExpiryItems.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(item.bloodType.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const SizedBox(width: 8),
                  Text('${item.units} units · ${item.batchNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const Spacer(),
                  if (item.isPrioritized) const Icon(LucideIcons.arrowUpCircle, size: 16, color: Color(0xFF059669)),
                  if (item.isDiscarded) const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFDC2626)),
                ]),
                const SizedBox(height: 4),
                Text('Location: ${item.storageLocation}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                if (item.wastageReason != null) Text('Reason: ${item.wastageReason}', style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Row(children: [
                  if (!item.isPrioritized && !item.isDiscarded) _actionChip('Prioritize', LucideIcons.arrowUp, () { ms.prioritizeExpiryBatch(item.batchNumber); _showSnack('Batch prioritized'); }),
                  if (!item.isDiscarded) _actionChip('Record Wastage', LucideIcons.trash2, () { ms.recordWastageReason(item.batchNumber, 'Exceeded shelf-life limit'); _showSnack('Wastage recorded'); }),
                ]),
              ],
            ),
          )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _expiryStatCard(String label, int units, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Text('$units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
    ));
  }

  // ========================= 4. HOSPITAL REQUESTS =========================
  Widget _buildHospitalRequestsTab(MockDataService ms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Hospital Blood Requests', icon: LucideIcons.clipboardList),
          const SizedBox(height: 14),
          ...ms.bankHospitalRequests.map((req) {
            final sc = _reqStatusColor(req.status);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sc.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [BoxShadow(color: sc.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(req.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(req.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: sc)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(req.hospitalName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
                  Text('Patient: ${req.patientRefId}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  Row(children: [
                    _infoChip(req.bloodType.label, const Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    _infoChip('${req.unitsRequired} units needed', const Color(0xFF0284C7)),
                    const SizedBox(width: 6),
                    _infoChip(req.urgency, req.urgency.contains('Critical') ? const Color(0xFFDC2626) : const Color(0xFFF59E0B)),
                  ]),
                  if (req.unitsAssigned > 0) Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Assigned: ${req.unitsAssigned}/${req.unitsRequired} units', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                  ),
                  if (req.internalNotes.isNotEmpty) Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Notes: ${req.internalNotes}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      if (req.status == BankHospitalReqStatus.pending || req.status == BankHospitalReqStatus.underReview) ...[
                        _actionChip('Approve', LucideIcons.checkCircle2, () {
                          _confirmAction('Approve Request', 'Approve ${req.id} for ${req.unitsRequired} units of ${req.bloodType.label}?', () {
                            ms.approveBankHospitalRequest(req.id, req.unitsRequired);
                            _showSnack('Request approved');
                          });
                        }),
                        _actionChip('Reject', LucideIcons.xCircle, () {
                          _confirmAction('Reject Request', 'Reject ${req.id}?', () {
                            ms.rejectBankHospitalRequest(req.id, 'Insufficient stock');
                            _showSnack('Request rejected');
                          });
                        }),
                        _actionChip('Partial', LucideIcons.sliders, () {
                          ms.partiallyFulfillBankHospitalRequest(req.id, 1);
                          _showSnack('Partially fulfilled with 1 unit');
                        }),
                      ],
                      if (req.status == BankHospitalReqStatus.approved) _actionChip('Fulfill', LucideIcons.checkSquare, () {
                        _confirmAction('Fulfill Request', 'Mark ${req.id} as fully fulfilled?', () {
                          ms.fulfillBankHospitalRequest(req.id);
                          _showSnack('Request fulfilled');
                        });
                      }),
                      _actionChip('Add Note', LucideIcons.messageSquare, () {
                        ms.addBankHospitalRequestInternalNote(req.id, 'Operator verified availability and cross-match');
                        _showSnack('Note added');
                      }),
                    ]),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }

  // ========================= 5. EMERGENCY =========================
  Widget _buildEmergencyTab(MockDataService ms) {
    final emergencyReqs = ms.bankHospitalRequests.where((r) => r.urgency.contains('Critical') || r.urgency.contains('SOS')).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(children: [
              const Icon(LucideIcons.flame, color: Color(0xFFDC2626), size: 24),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EMERGENCY REQUESTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFDC2626), letterSpacing: 0.5)),
                  Text('${emergencyReqs.length} critical request(s) require immediate action', style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 16),
          if (emergencyReqs.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              child: const Center(child: Text('No active emergency requests', style: TextStyle(fontSize: 14, color: Color(0xFF64748B)))),
            )
          else
            ...emergencyReqs.map((req) {
              final invItem = ms.bankInventory.firstWhere((i) => i.bloodType == req.bloodType);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.4), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.08), blurRadius: 16)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.flame, color: Color(0xFFDC2626), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(req.id, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black)),
                        Text(req.hospitalName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDC2626).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text(req.urgency, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      _infoChip(req.bloodType.label, const Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      _infoChip('${req.unitsRequired} units needed', const Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      _infoChip('Available: ${invItem.availableUnits}', const Color(0xFF059669)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Patient: ${req.patientRefId}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('Status: ${req.status.label}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _reqStatusColor(req.status))),
                    const SizedBox(height: 12),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      _actionChip('Reserve Units', LucideIcons.lock, () {
                        _confirmAction('Emergency Reserve', 'Reserve ${req.unitsRequired} units of ${req.bloodType.label}?', () {
                          ms.reserveBankUnits(req.bloodType, req.unitsRequired, 'Emergency ${req.id}');
                          _showSnack('Units reserved for emergency');
                        });
                      }),
                      _actionChip('Notify Hospital', LucideIcons.phone, () => _showSnack('Hospital notified (mock)')),
                      _actionChip('Contact Blood Banks', LucideIcons.building2, () => _showSnack('Nearby blood banks contacted (mock)')),
                      _actionChip('Mark Fulfilled', LucideIcons.checkCircle2, () {
                        ms.fulfillBankHospitalRequest(req.id);
                        _showSnack('Emergency request fulfilled');
                      }),
                    ]),
                  ],
                ),
              );
            }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========================= 6. DONATIONS =========================
  Widget _buildDonationsTab(MockDataService ms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Blood Collection & Intake', icon: LucideIcons.droplets),
          const SizedBox(height: 14),
          ...ms.bankIntakeRecords.map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(rec.intakeId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Text(rec.processingStatus.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black)),
                ),
              ]),
              const SizedBox(height: 6),
              Text('Donor: ${rec.donorId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
              Row(children: [
                _infoChip(rec.bloodType.label, const Color(0xFFDC2626)),
                const SizedBox(width: 6),
                _infoChip('${rec.units} unit(s)', const Color(0xFF0284C7)),
                const SizedBox(width: 6),
                if (rec.campName.isNotEmpty) _infoChip(rec.campName, const Color(0xFF059669)),
              ]),
              const SizedBox(height: 4),
              Text('Center: ${rec.donationCenter}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Text('Screening: ${rec.screeningStatus}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              Text('Storage: ${rec.storageLocation} · Batch: ${rec.batchNumber}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ]),
          )),
          const SizedBox(height: 24),
          _sectionHeader('Donor Records (Privacy-Limited)', icon: LucideIcons.user),
          const SizedBox(height: 12),
          ...ms.bankDonorRecords.map((d) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.user, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.donorId, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                Text('${d.bloodType.label} · ${d.donationCenter} · ${d.totalDonationsCount} donations', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                Text('Status: ${d.donationStatus} · ${d.eligibilityStatus}', style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
              ])),
              if (!d.thankYouSent)
                IconButton(
                  icon: const Icon(LucideIcons.heart, size: 18, color: Color(0xFFDC2626)),
                  tooltip: 'Send Thank You',
                  onPressed: () { ms.sendDonorThankYou(d.donorId); _showSnack('Thank you sent to ${d.donorId}'); },
                )
              else
                const Icon(LucideIcons.checkCircle2, size: 18, color: Color(0xFF059669)),
            ]),
          )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========================= 7. TRANSFERS =========================
  Widget _buildTransfersTab(MockDataService ms) {
    final statusColors = {
      BankTransferStatus.requested: const Color(0xFFF59E0B),
      BankTransferStatus.approved: const Color(0xFF0284C7),
      BankTransferStatus.prepared: const Color(0xFF7C3AED),
      BankTransferStatus.inTransit: const Color(0xFFEA580C),
      BankTransferStatus.delivered: const Color(0xFF059669),
      BankTransferStatus.cancelled: const Color(0xFF6B7280),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Blood Transfers', icon: LucideIcons.truck),
          const SizedBox(height: 14),
          // Create Transfer Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateTransferModal(ms),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Create New Transfer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...ms.bankTransfers.map((trf) {
            final tc = statusColors[trf.status] ?? const Color(0xFF64748B);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tc.withValues(alpha: 0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(trf.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: tc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(trf.status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tc)),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(LucideIcons.building2, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(child: Text('From: ${trf.sourceOrg}', style: const TextStyle(fontSize: 12, color: Colors.black))),
                ]),
                Row(children: [
                  const Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(child: Text('To: ${trf.destinationOrg}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black))),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _infoChip(trf.bloodType.label, const Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  _infoChip('${trf.units} units', const Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  _infoChip(trf.transportCarrier, const Color(0xFF7C3AED)),
                ]),
                const SizedBox(height: 6),
                Text('Tracking: ${trf.trackingId}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 10),
                if (trf.status != BankTransferStatus.delivered && trf.status != BankTransferStatus.cancelled)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      if (trf.status == BankTransferStatus.requested) _actionChip('Approve', LucideIcons.checkCircle2, () { ms.updateBankTransferStatus(trf.id, BankTransferStatus.approved); _showSnack('Transfer approved'); }),
                      if (trf.status == BankTransferStatus.approved) _actionChip('Dispatch', LucideIcons.truck, () { ms.updateBankTransferStatus(trf.id, BankTransferStatus.inTransit); _showSnack('Transfer dispatched'); }),
                      if (trf.status == BankTransferStatus.prepared) _actionChip('Dispatch', LucideIcons.truck, () { ms.updateBankTransferStatus(trf.id, BankTransferStatus.inTransit); _showSnack('Transfer dispatched'); }),
                      if (trf.status == BankTransferStatus.inTransit) _actionChip('Confirm Delivery', LucideIcons.checkSquare, () { ms.updateBankTransferStatus(trf.id, BankTransferStatus.delivered); _showSnack('Delivery confirmed'); }),
                      _actionChip('Cancel', LucideIcons.xCircle, () { ms.updateBankTransferStatus(trf.id, BankTransferStatus.cancelled); _showSnack('Transfer cancelled'); }),
                    ]),
                  ),
              ]),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========================= 8. REPORTS =========================
  Widget _buildReportsTab(MockDataService ms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Reports & Analytics', icon: LucideIcons.barChart3),
          const SizedBox(height: 14),
          // Inventory by Blood Group Bar Chart (mock)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventory by Blood Group', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black)),
                const SizedBox(height: 14),
                ...ms.bankInventory.map((inv) {
                  final maxUnits = ms.bankInventory.map((i) => i.availableUnits).reduce((a, b) => a > b ? a : b);
                  final ratio = maxUnits > 0 ? inv.availableUnits / maxUnits : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      SizedBox(width: 35, child: Text(inv.bloodType.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black))),
                      const SizedBox(width: 8),
                      Expanded(child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(value: ratio, minHeight: 16, backgroundColor: const Color(0xFFF1F5F9), valueColor: AlwaysStoppedAnimation<Color>(_statusColor(inv.status))),
                      )),
                      const SizedBox(width: 8),
                      SizedBox(width: 30, child: Text('${inv.availableUnits}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black))),
                    ]),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Key Metrics
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.0,
            children: [
              _reportMetric('Fulfillment Rate', '87.5%', LucideIcons.checkCircle2, const Color(0xFF059669)),
              _reportMetric('Emergency Response', '< 12 min avg', LucideIcons.flame, const Color(0xFFDC2626)),
              _reportMetric('Total Collections', '${ms.bankIntakeRecords.length} this week', LucideIcons.droplets, const Color(0xFF0284C7)),
              _reportMetric('Wastage Rate', '2.1%', LucideIcons.trash2, const Color(0xFFF59E0B)),
              _reportMetric('Active Transfers', '${ms.bankTransfersInProgressCount}', LucideIcons.truck, const Color(0xFF7C3AED)),
              _reportMetric('Most Requested', 'O Negative', LucideIcons.trendingUp, const Color(0xFFDC2626)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                FileDownloadService.downloadBloodBankReport(ms);
                _showSnack('Operational Audit Report (${ms.bankProfile.name}) downloaded & saved to your device!');
              },
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export Report (HTML / Printable)', style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _reportMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color))]),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ]),
    );
  }

  // ========================= 9. NOTIFICATIONS =========================
  Widget _buildNotificationsTab(MockDataService ms) {
    // Using audit logs as notifications proxy
    final notifs = ms.bankAuditLogs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Notifications', icon: LucideIcons.bell),
          const SizedBox(height: 14),
          ...notifs.map((n) {
            final catIcons = {
              'inventory': LucideIcons.database,
              'request': LucideIcons.clipboardList,
              'transfer': LucideIcons.truck,
              'intake': LucideIcons.droplets,
              'alert': LucideIcons.alertTriangle,
            };
            final catColors = {
              'inventory': const Color(0xFF0284C7),
              'request': const Color(0xFFF59E0B),
              'transfer': const Color(0xFF7C3AED),
              'intake': const Color(0xFF059669),
              'alert': const Color(0xFFDC2626),
            };
            final ic = catIcons[n.category] ?? LucideIcons.bell;
            final cc = catColors[n.category] ?? const Color(0xFF64748B);
            final timeAgo = DateTime.now().difference(n.timestamp);
            String timeStr;
            if (timeAgo.inMinutes < 60) {
              timeStr = '${timeAgo.inMinutes}m ago';
            } else if (timeAgo.inHours < 24) {
              timeStr = '${timeAgo.inHours}h ago';
            } else {
              timeStr = '${timeAgo.inDays}d ago';
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: cc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(ic, size: 16, color: cc),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(n.description, style: const TextStyle(fontSize: 11, color: Color(0xFF374151))),
                  const SizedBox(height: 4),
                  Text('${n.staffMember} · $timeStr', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ])),
              ]),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========================= 10. SETTINGS =========================
  Widget _buildSettingsTab(MockDataService ms) {
    final profile = ms.bankProfile;

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

    void showEditProfileModal() {
      final nameCtrl = TextEditingController(text: profile.name);
      final licCtrl = TextEditingController(text: profile.licenseNumber);
      final addrCtrl = TextEditingController(text: profile.address);
      final phoneCtrl = TextEditingController(text: profile.phone);
      final hotCtrl = TextEditingController(text: profile.emergencyHotline);
      final hrsCtrl = TextEditingController(text: profile.operatingHours);

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
                      const Text('Edit Blood Bank Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                      IconButton(icon: const Icon(LucideIcons.x, color: Colors.black), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Blood Bank Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: nameCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('License Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: licCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Facility Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: addrCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Office Phone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: phoneCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Emergency Hotline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: hotCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('Operating Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black)),
                  const SizedBox(height: 6),
                  TextField(controller: hrsCtrl, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        setState(() {
                          profile.name = nameCtrl.text.trim().isEmpty ? profile.name : nameCtrl.text.trim();
                          profile.licenseNumber = licCtrl.text.trim().isEmpty ? profile.licenseNumber : licCtrl.text.trim();
                          profile.address = addrCtrl.text.trim().isEmpty ? profile.address : addrCtrl.text.trim();
                          profile.phone = phoneCtrl.text.trim().isEmpty ? profile.phone : phoneCtrl.text.trim();
                          profile.emergencyHotline = hotCtrl.text.trim().isEmpty ? profile.emergencyHotline : hotCtrl.text.trim();
                          profile.operatingHours = hrsCtrl.text.trim().isEmpty ? profile.operatingHours : hrsCtrl.text.trim();
                        });
                        ms.addBankAuditLog('PROFILE_UPDATE', 'Updated facility credentials for ${profile.name}', 'Director / Admin');
                        Navigator.pop(ctx);
                        showFeedback('Blood Bank profile details updated successfully!');
                      },
                      child: const Text('Save Facility Details', style: TextStyle(fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('Blood Bank Profile', icon: LucideIcons.building2),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: showEditProfileModal,
                icon: const Icon(LucideIcons.pencil, size: 14),
                label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _settingCard('Name', profile.name, LucideIcons.building2, onTap: showEditProfileModal),
          _settingCard('License', profile.licenseNumber, LucideIcons.shield, onTap: showEditProfileModal),
          _settingCard('Address', profile.address, LucideIcons.mapPin, onTap: showEditProfileModal),
          _settingCard('Phone', profile.phone, LucideIcons.phone, onTap: showEditProfileModal),
          _settingCard('Emergency Hotline', profile.emergencyHotline, LucideIcons.flame, onTap: showEditProfileModal),
          _settingCard('Email', profile.email, LucideIcons.mail, onTap: showEditProfileModal),
          _settingCard('Operating Hours', profile.operatingHours, LucideIcons.clock, onTap: showEditProfileModal),
          _settingCard('Storage Capacity', profile.storageCapacity, LucideIcons.database, onTap: showEditProfileModal),
          _settingCard('Accreditation', profile.accreditation, LucideIcons.award, onTap: showEditProfileModal),

          const SizedBox(height: 24),
          _sectionHeader('Facility Automation & Cold Chain', icon: LucideIcons.snowflake),
          const SizedBox(height: 12),

          // Cold Chain Temperature Alert Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cold Storage Temperature Setpoint', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: Text('${_coldChainTemp.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Permissible WHO/NABH blood storage range: 2.0°C to 6.0°C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                Slider(
                  value: _coldChainTemp,
                  min: 1.0,
                  max: 8.0,
                  divisions: 14,
                  activeColor: Colors.black,
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (v) => setState(() => _coldChainTemp = v),
                  onChangeEnd: (v) => showFeedback('Cold chain temperature calibrated to ${v.toStringAsFixed(1)}°C'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Operational Switches
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Auto-Expiry 7-Day Alert Broadcast', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Alert connected hospitals 7 days prior to component expiration', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: _autoExpiryAlert,
                  onChanged: (v) {
                    setState(() => _autoExpiryAlert = v);
                    showFeedback(v ? '7-Day Expiry Warnings: ACTIVE' : '7-Day Expiry Warnings: PAUSED');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Night Emergency Dispatch Readiness (24/7)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Route emergency SOS requisitions automatically to on-duty staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: _nightEmergencyDispatch,
                  onChanged: (v) {
                    setState(() => _nightEmergencyDispatch = v);
                    showFeedback(v ? 'Night Emergency Dispatch: ENGAGED' : 'Night Emergency Dispatch: STANDBY');
                  },
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: Colors.black,
                  title: const Text('Automated Voluntary Donor Restock SMS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                  subtitle: const Text('Send SMS callouts when inventory falls below minimum buffer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                  value: _autoRestockSms,
                  onChanged: (v) {
                    setState(() => _autoRestockSms = v);
                    showFeedback(v ? 'Donor Restock SMS: ACTIVATED' : 'Donor Restock SMS: MUTED');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionHeader('Available Services', icon: LucideIcons.listChecks),
          const SizedBox(height: 10),
          ...profile.availableServices.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 8),
              Expanded(child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black))),
            ]),
          )),

          const SizedBox(height: 24),
          _sectionHeader('Live Compatibility Checker', icon: LucideIcons.gitBranch),
          const SizedBox(height: 10),
          _buildInlineCompatibilityChecker(),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('Audit Log & SBTC Reporting', icon: LucideIcons.fileText),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                onPressed: () {
                  FileDownloadService.downloadERaktKoshLedgerCsv(ms);
                  showFeedback('e-RaktKosh National Ledger (eRaktKosh_National_Sync_2026.csv) exported successfully!');
                },
                icon: const Icon(LucideIcons.download, size: 14),
                label: const Text('Export e-RaktKosh Ledger', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...ms.bankAuditLogs.take(5).map((log) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 4, height: 36, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(log.action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black)),
                Text(log.description, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                Text('${log.staffMember} · ${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ])),
            ]),
          )),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _settingCard(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCBD5E1))),
        child: Row(children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.3)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
          ])),
          if (onTap != null) const Icon(LucideIcons.pencil, size: 14, color: Colors.black),
        ]),
      ),
    );
  }

  Widget _buildInlineCompatibilityChecker() {
    final canDonate = _inlineDonorType.canDonateTo(_inlineRecipientType);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Donor Blood Group', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
              child: DropdownButtonHideUnderline(child: DropdownButton<BloodType>(
                isExpanded: true,
                value: _inlineDonorType,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14),
                items: BloodType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(color: Colors.black)))).toList(),
                onChanged: (v) { if (v != null) setState(() { _inlineDonorType = v; }); },
              )),
            ),
          ])),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(LucideIcons.arrowRight, size: 20, color: Colors.black)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Recipient Blood Group', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
              child: DropdownButtonHideUnderline(child: DropdownButton<BloodType>(
                isExpanded: true,
                value: _inlineRecipientType,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14),
                items: BloodType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(color: Colors.black)))).toList(),
                onChanged: (v) { if (v != null) setState(() { _inlineRecipientType = v; }); },
              )),
            ),
          ])),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: canDonate ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: canDonate ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          ),
          child: Row(children: [
            Icon(canDonate ? LucideIcons.checkCircle2 : LucideIcons.xCircle, color: canDonate ? const Color(0xFF059669) : const Color(0xFFDC2626), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(
              canDonate ? 'COMPATIBLE — ${_inlineDonorType.label} units can safely be transfused to ${_inlineRecipientType.label}' : 'INCOMPATIBLE — ${_inlineDonorType.label} cannot be given to ${_inlineRecipientType.label}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: canDonate ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            )),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('* Clinical cross-matching must be performed prior to all transfusions according to Indian SBTC & NACO guidelines.', style: TextStyle(fontSize: 10, color: Colors.black87, fontStyle: FontStyle.italic)),
      ]),
    );
  }
}
