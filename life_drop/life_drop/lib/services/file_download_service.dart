import '../models/donor_models.dart';
import '../models/patient_models.dart';
import '../models/hospital_models.dart';
import 'mock_data_service.dart';
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    as platform_downloader;

/// Universal file generation and download service for VitalPulse.
/// Generates realistic, fully formatted printable HTML receipts, donor cards, certificates,
/// medical audit reports, and CSV inventory registers, then triggers a real browser/system file download.
class FileDownloadService {
  /// Base download method
  static void saveFile({
    required String filename,
    required String content,
    String mimeType = 'text/plain',
  }) {
    platform_downloader.downloadFile(
      filename: filename,
      content: content,
      mimeType: mimeType,
    );
  }

  /// 1. Real Official Donation & Recipient Allocation Receipt (.html / Printable)
  static void downloadDonationReceipt(
    DonorHistoryRecord rec,
    DonorProfileModel donor,
  ) {
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Official Donation Receipt - ${rec.receiptNumber}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; }
    .receipt-box { max-width: 680px; margin: 0 auto; background: #ffffff; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); border: 1.5px solid #e2e8f0; overflow: hidden; }
    .header { background: #0f172a; color: #ffffff; padding: 24px; }
    .header h1 { margin: 0 0 6px 0; font-size: 20px; font-weight: 900; letter-spacing: 0.5px; }
    .header p { margin: 0; font-size: 13px; color: #94a3b8; }
    .badge-verified { background: #10b981; color: white; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 800; display: inline-block; margin-top: 6px; }
    .content { padding: 24px; }
    .section-title { font-size: 13px; font-weight: 900; color: #0284c7; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 18px; margin-bottom: 10px; border-bottom: 1.5px solid #e2e8f0; padding-bottom: 6px; }
    .row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 13px; border-bottom: 1px dashed #f1f5f9; }
    .row .label { color: #64748b; font-weight: 600; }
    .row .value { font-weight: 800; color: #0f172a; text-align: right; }
    .highlight-box { background: #f0f9ff; border: 1.5px solid #bae6fd; border-radius: 14px; padding: 16px; margin: 16px 0; }
    .thankyou-box { background: #ecfdf5; border: 1.5px solid #a7f3d0; border-radius: 12px; padding: 14px; margin: 14px 0; font-style: italic; color: #065f46; font-size: 12.5px; }
    .footer { padding: 18px 24px; background: #f8fafc; border-top: 1.5px solid #e2e8f0; text-align: center; font-size: 11.5px; color: #64748b; }
    @media print { body { background: none; padding: 0; } .receipt-box { box-shadow: none; border: 1px solid #000; } }
  </style>
</head>
<body>
  <div class="receipt-box">
    <div class="header">
      <h1>VitalPulse INDIA • OFFICIAL DONATION RECEIPT</h1>
      <p>Receipt ID: <strong>${rec.receiptNumber}</strong> • Serial Bag ID: <strong>${rec.bloodBagNumber}</strong></p>
      <div class="badge-verified">✓ TRANSFUSION VERIFIED & LIFE SAVED</div>
    </div>
    <div class="content">
      <div class="section-title">1. Donor Contribution Details</div>
      <div class="row"><span class="label">Donor Name:</span><span class="value">${donor.name} (ID: ${donor.id})</span></div>
      <div class="row"><span class="label">Blood Group:</span><span class="value" style="color: #dc2626;">${rec.bloodType.label} (${rec.bloodType.name})</span></div>
      <div class="row"><span class="label">Donation Center:</span><span class="value">${rec.donationCenter}</span></div>
      <div class="row"><span class="label">Donation Date:</span><span class="value">${rec.donationDate.day}/${rec.donationDate.month}/${rec.donationDate.year}</span></div>
      <div class="row"><span class="label">Units & Volume:</span><span class="value">${rec.unitsDonated} Unit (${rec.donationType})</span></div>
      <div class="row"><span class="label">Vitals:</span><span class="value">Hb: ${rec.hemoglobin} | BP: ${rec.bloodPressure} | Pulse: ${rec.pulse}</span></div>

      <div class="section-title">2. Recipient & Transfusion Allocation</div>
      <div class="highlight-box">
        <div class="row"><span class="label">Recipient Name:</span><span class="value" style="color: #0369a1;">${rec.recipientName}</span></div>
        <div class="row"><span class="label">Demographics:</span><span class="value">${rec.recipientAge} yrs • ${rec.recipientGender} • Group: ${rec.recipientBloodType.label}</span></div>
        <div class="row"><span class="label">Hospital Facility:</span><span class="value">${rec.recipientHospital}</span></div>
        <div class="row"><span class="label">Ward & Bed:</span><span class="value">${rec.recipientWard}</span></div>
        <div class="row"><span class="label">Supervising Specialist:</span><span class="value">${rec.doctorInCharge}</span></div>
        <div class="row"><span class="label">Transfusion Date:</span><span class="value">${rec.transfusionDate.day}/${rec.transfusionDate.month}/${rec.transfusionDate.year}</span></div>
        <div class="row"><span class="label">Outcome:</span><span class="value" style="color: #059669;">${rec.transfusionStatus}</span></div>
      </div>

      <div class="thankyou-box">
        ${rec.recipientThankYouNote}
      </div>

      <div class="section-title">3. Official Verification & Security</div>
      <div class="row"><span class="label">Registry Verification:</span><span class="value">${rec.verifiedBy}</span></div>
      <div class="row"><span class="label">National Certificate ID:</span><span class="value">${rec.certificateId}</span></div>
    </div>
    <div class="footer">
      Generated securely via VitalPulse Smart Blood Donation Network • Ministry of Health & Family Welfare (MoHFW), India.
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename: 'VitalPulse_Receipt_${rec.receiptNumber}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 2. Real Digital Donor Card (.html / Printable Wallet Card)
  static void downloadDonorCard(DonorProfileModel donor) {
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Digital Donor ID Card - ${donor.name}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f1f5f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
    .card { width: 440px; background: linear-gradient(135deg, #0f172a 0%, #1e293b 60%, #0369a1 100%); color: white; border-radius: 20px; padding: 24px; box-shadow: 0 15px 35px rgba(0,0,0,0.25); border: 2px solid #38bdf8; position: relative; }
    .card-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.15); padding-bottom: 14px; }
    .logo { font-size: 16px; font-weight: 900; letter-spacing: 0.5px; }
    .blood-badge { background: #dc2626; color: white; padding: 6px 14px; border-radius: 12px; font-size: 18px; font-weight: 900; }
    .card-body { padding: 18px 0; }
    .donor-name { font-size: 20px; font-weight: 900; margin: 0 0 6px 0; }
    .donor-id { font-size: 12px; color: #38bdf8; margin-bottom: 16px; }
    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 12px; }
    .info-item span { display: block; color: #94a3b8; font-size: 10px; font-weight: 700; text-transform: uppercase; }
    .info-item strong { color: white; font-size: 13px; font-weight: 800; }
    .card-footer { display: flex; justify-content: space-between; align-items: center; border-top: 1px solid rgba(255,255,255,0.15); padding-top: 14px; font-size: 10px; color: #94a3b8; }
    .status { color: #34d399; font-weight: 800; }
  </style>
</head>
<body>
  <div class="card">
    <div class="card-header">
      <div class="logo">🩸 VitalPulse INDIA<br><small style="font-size: 9px; color: #94a3b8;">OFFICIAL DONOR IDENTIFICATION</small></div>
      <div class="blood-badge">${donor.bloodType.label}</div>
    </div>
    <div class="card-body">
      <div class="donor-name">${donor.name}</div>
      <div class="donor-id">DONOR ID: ${donor.id} • ${donor.verificationBadge}</div>
      <div class="info-grid">
        <div class="info-item"><span>Total Donations</span><strong>${donor.totalDonations} Sessions</strong></div>
        <div class="info-item"><span>Units Donated</span><strong>${donor.totalUnitsDonated} Units (${donor.bloodType.label})</strong></div>
        <div class="info-item"><span>Registered City</span><strong>${donor.location}</strong></div>
        <div class="info-item"><span>Status</span><strong class="status">● ELIGIBLE & VERIFIED</strong></div>
      </div>
    </div>
    <div class="card-footer">
      <div>National Blood Transfusion Registry Verified</div>
      <div>Emergency: 108</div>
    </div>
  </div>
</body>
</html>
''';

    saveFile(
      filename: 'VitalPulse_DonorCard_${donor.name.replaceAll(' ', '_')}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 3. Real Donor Certificate of Appreciation (.html / Printable Certificate)
  static void downloadCertificate(
    DonorProfileModel donor, {
    DonorCertificateModel? cert,
  }) {
    final donorName = (cert != null && cert.donorName.trim().isNotEmpty)
        ? cert.donorName.trim()
        : donor.name;
    final bloodGroup = (cert != null && cert.bloodGroup.trim().isNotEmpty)
        ? cert.bloodGroup.trim()
        : donor.bloodType.label;
    final units = cert?.unitsDonated ?? donor.totalUnitsDonated;
    final sessions = donor.totalDonations > 0
        ? donor.totalDonations
        : (units > 0 ? (units / 1).ceil() : 1);
    final location = (cert != null && cert.centerName.trim().isNotEmpty)
        ? cert.centerName.trim()
        : donor.location;
    final certTitle = (cert != null && cert.customTitle.trim().isNotEmpty)
        ? cert.customTitle.trim()
        : 'VITALPULSE NATIONAL LIFE-SAVER AWARD';
    final pledge = (cert != null && cert.customPledgeMessage.trim().isNotEmpty)
        ? cert.customPledgeMessage.trim()
        : 'In grateful recognition of voluntary, selfless contributions of life-saving whole blood. Your noble generosity has directly saved critical lives.';
    final sigTitle = (cert != null && cert.signatureTitle.trim().isNotEmpty)
        ? cert.signatureTitle.trim()
        : 'Dr. Radhika Menon, MD • Director of Transfusion Medicine';
    final certId =
        cert?.certificateId ??
        'CERT-VP-2026-${donor.id.hashCode.abs() % 9000 + 1000}';
    final theme = cert?.certificateTheme ?? 'Gold Royal';

    // Theme Primary Color
    String themeColor = '#d4a017';
    String themeBorder = '#b8860b';
    if (theme.toLowerCase().contains('sapphire') ||
        theme.toLowerCase().contains('clinical')) {
      themeColor = '#0284c7';
      themeBorder = '#0369a1';
    } else if (theme.toLowerCase().contains('emerald') ||
        theme.toLowerCase().contains('vitality')) {
      themeColor = '#059669';
      themeBorder = '#047857';
    } else if (theme.toLowerCase().contains('platinum') ||
        theme.toLowerCase().contains('minimal')) {
      themeColor = '#475569';
      themeBorder = '#334155';
    }

    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Certificate of Appreciation - $donorName</title>
  <style>
    body { font-family: 'Georgia', serif; background: #f8fafc; color: #0f172a; padding: 40px; margin: 0; display: flex; justify-content: center; }
    .cert-frame { width: 840px; background: #ffffff; padding: 48px; border: 8px double $themeBorder; box-shadow: 0 15px 40px rgba(0,0,0,0.1); text-align: center; border-radius: 16px; position: relative; }
    .cert-badge { display: inline-block; padding: 4px 14px; background: #eff6ff; color: $themeColor; font-family: -apple-system, sans-serif; font-size: 11px; font-weight: 900; letter-spacing: 2px; border-radius: 20px; margin-bottom: 12px; border: 1px solid #bae6fd; }
    .title { font-family: -apple-system, sans-serif; font-size: 26px; font-weight: 900; color: $themeColor; letter-spacing: 1.5px; margin-bottom: 6px; text-transform: uppercase; }
    .subtitle { font-size: 13px; font-weight: 700; color: #64748b; letter-spacing: 1.2px; text-transform: uppercase; margin-bottom: 24px; font-family: -apple-system, sans-serif; }
    .presented-to { font-size: 14px; color: #475569; margin-bottom: 8px; font-style: italic; }
    .donor-name { font-size: 34px; font-weight: 900; color: #0f172a; border-bottom: 2.5px solid $themeColor; display: inline-block; padding: 0 36px 6px 36px; margin-bottom: 18px; letter-spacing: -0.5px; font-family: -apple-system, sans-serif; }
    .statement { font-size: 15px; line-height: 1.6; color: #334155; max-width: 660px; margin: 0 auto 28px auto; font-style: italic; }
    .details-row { display: flex; justify-content: space-around; font-family: -apple-system, sans-serif; margin-bottom: 32px; border-top: 1px solid #e2e8f0; border-bottom: 1px solid #e2e8f0; padding: 14px 0; background: #fafafa; border-radius: 8px; }
    .detail-col strong { display: block; font-size: 17px; color: #dc2626; font-weight: 900; }
    .detail-col span { font-size: 10.5px; color: #64748b; font-weight: 800; letter-spacing: 0.5px; }
    .signatures { display: flex; justify-content: space-between; align-items: flex-end; padding: 0 20px; font-family: -apple-system, sans-serif; font-size: 11.5px; }
    .sig-line { border-top: 1.5px solid #0f172a; width: 220px; padding-top: 6px; font-weight: 800; color: #0f172a; }
    .qr-box { font-family: -apple-system, sans-serif; font-size: 10px; color: #64748b; font-weight: 700; border: 1px dashed #cbd5e1; padding: 6px 12px; border-radius: 6px; }
  </style>
</head>
<body>
  <div class="cert-frame">
    <div class="cert-badge">VITALPULSE LIFESAVER RECOGNITION</div>
    <div class="title">$certTitle</div>
    <div class="subtitle">Certificate of Voluntary Blood Donation Honors • $theme</div>
    <div class="presented-to">This National Honor is Proudly Conferred Upon</div>
    <div class="donor-name">$donorName</div>
    <div class="statement">"$pledge"</div>
    <div class="details-row">
      <div class="detail-col"><strong>$bloodGroup</strong><span>BLOOD GROUP</span></div>
      <div class="detail-col"><strong>$sessions</strong><span>DONATION SESSIONS</span></div>
      <div class="detail-col"><strong>$units Units</strong><span>UNITS CONTRIBUTED</span></div>
      <div class="detail-col"><strong>$location</strong><span>REGISTRATION JURISDICTION</span></div>
    </div>
    <div class="signatures">
      <div>
        <div class="sig-line">$sigTitle</div>
        <small style="color: #64748b;">Authorized Medical Signatory</small>
      </div>
      <div class="qr-box">
        <div>🔒 CRYPTO VERIFIED</div>
        <div>ID: <strong>$certId</strong></div>
      </div>
      <div>
        <div class="sig-line">National Blood Transfusion Registry</div>
        <small style="color: #64748b;">Government Health Authorization</small>
      </div>
    </div>
  </div>
</body>
</html>
''';

    saveFile(
      filename: 'VitalPulse_Certificate_${donorName.replaceAll(' ', '_')}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 4. Real Blood Bank Inventory CSV
  static void downloadBloodBankInventoryCsv(MockDataService mockService) {
    final buffer = StringBuffer();
    buffer.writeln('Blood Bank Inventory Audit Register - VitalPulse India');
    buffer.writeln('Export Date,${DateTime.now().toIso8601String()}');
    buffer.writeln('Facility Name,${mockService.bankProfile.name}');
    buffer.writeln('Location,${mockService.bankProfile.address}');
    buffer.writeln('');
    buffer.writeln(
      'Blood Group,Available Units,Reserved Units,Total Units,Safety Status,Storage Vault',
    );

    for (final item in mockService.bankInventory) {
      buffer.writeln(
        '${item.bloodType.label},${item.availableUnits},${item.reservedUnits},${item.totalUnits},${item.status.label},${item.storageLocation}',
      );
    }

    saveFile(
      filename:
          'BloodBank_Inventory_Audit_${DateTime.now().year}_${DateTime.now().month}.csv',
      content: buffer.toString(),
      mimeType: 'text/csv',
    );
  }

  /// 5. Real Blood Bank Operations & Inventory Audit Report (.html / Printable)
  static void downloadBloodBankReport(MockDataService mockService) {
    final totalUnits = mockService.bankInventory.fold<int>(
      0,
      (sum, i) => sum + i.totalUnits,
    );
    final availUnits = mockService.bankInventory.fold<int>(
      0,
      (sum, i) => sum + i.availableUnits,
    );
    final resUnits = mockService.bankInventory.fold<int>(
      0,
      (sum, i) => sum + i.reservedUnits,
    );

    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Blood Bank Operational Audit Report - ${mockService.bankProfile.name}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; }
    .report-card { max-width: 800px; margin: 0 auto; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1.5px solid #e2e8f0; overflow: hidden; }
    .header { background: #0f172a; color: white; padding: 24px; }
    .header h1 { margin: 0 0 6px 0; font-size: 20px; font-weight: 900; }
    .header p { margin: 0; font-size: 13px; color: #94a3b8; }
    .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; padding: 20px 24px; background: #f1f5f9; border-bottom: 1.5px solid #e2e8f0; }
    .stat-box { background: white; padding: 14px; border-radius: 12px; text-align: center; border: 1px solid #cbd5e1; }
    .stat-box span { font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; }
    .stat-box strong { display: block; font-size: 20px; color: #0284c7; font-weight: 900; margin-top: 4px; }
    .content { padding: 24px; }
    table { width: 100%; border-collapse: collapse; margin-top: 14px; font-size: 13px; }
    th { background: #f8fafc; color: #475569; font-weight: 800; text-align: left; padding: 10px 12px; border-bottom: 2px solid #e2e8f0; }
    td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; color: #0f172a; }
    .badge { padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 800; background: #ecfdf5; color: #059669; }
    .footer { padding: 18px 24px; background: #f8fafc; border-top: 1.5px solid #e2e8f0; text-align: center; font-size: 11px; color: #64748b; }
  </style>
</head>
<body>
  <div class="report-card">
    <div class="header">
      <h1>🩸 ${mockService.bankProfile.name} • SBTC OPERATIONAL AUDIT</h1>
      <p>License: ${mockService.bankProfile.licenseNumber} • Address: ${mockService.bankProfile.address}</p>
      <p style="margin-top: 6px; font-size: 12px; color: #38bdf8;">Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • Compliance: Grade A+ NABH Certified</p>
    </div>
    <div class="stats-row">
      <div class="stat-box"><span>Total Units</span><strong style="color: #0f172a;">$totalUnits</strong></div>
      <div class="stat-box"><span>Available</span><strong style="color: #059669;">$availUnits</strong></div>
      <div class="stat-box"><span>Reserved</span><strong style="color: #d97706;">$resUnits</strong></div>
      <div class="stat-box"><span>Fulfillment Rate</span><strong style="color: #7c3aed;">87.5%</strong></div>
    </div>
    <div class="content">
      <h3 style="margin-top: 0; font-size: 15px; color: #0f172a;">Real-Time Blood Vault Inventory</h3>
      <table>
        <thead>
          <tr>
            <th>Group</th>
            <th>Available</th>
            <th>Reserved</th>
            <th>Total</th>
            <th>Status</th>
            <th>Vault Chamber</th>
          </tr>
        </thead>
        <tbody>
          ${mockService.bankInventory.map((i) => '''
          <tr>
            <td><strong>${i.bloodType.label}</strong></td>
            <td style="color: #059669; font-weight: bold;">${i.availableUnits}</td>
            <td style="color: #d97706; font-weight: bold;">${i.reservedUnits}</td>
            <td><strong>${i.totalUnits}</strong></td>
            <td><span class="badge">${i.status.label}</span></td>
            <td>${i.storageLocation}</td>
          </tr>
          ''').join('')}
        </tbody>
      </table>
    </div>
    <div class="footer">
      Official SBTC / National e-RaktKosh Sync Audit Register • VitalPulse Central Health Information System
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename:
          'VitalPulse_BloodBank_Operations_Report_${DateTime.now().year}_${DateTime.now().month}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 6. Real e-RaktKosh Sync Ledger CSV
  static void downloadERaktKoshLedgerCsv(MockDataService mockService) {
    final buffer = StringBuffer();
    buffer.writeln('National e-RaktKosh Ledger Sync Export');
    buffer.writeln('Sync Timestamp,${DateTime.now().toIso8601String()}');
    buffer.writeln('State Blood Transfusion Council ID,SBTC-TEL-2026-981');
    buffer.writeln('Facility Name,${mockService.bankProfile.name}');
    buffer.writeln('');
    buffer.writeln(
      'Batch ID,Component Type,Blood Group,Volume (mL),Collection Date,Expiry Date,Serology Status,Location Barcode',
    );

    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    int idx = 101;
    for (final bg in bloodTypes) {
      buffer.writeln(
        'BATCH-2026-$idx,Whole Blood,$bg,450,2026-09-15,2026-10-20,HIV/HBV/HCV Negative,BAR-$bg-$idx',
      );
      idx++;
    }

    saveFile(
      filename: 'eRaktKosh_National_Sync_2026.csv',
      content: buffer.toString(),
      mimeType: 'text/csv',
    );
  }

  /// 7. Real Hospital Transfusion Register Audit (CSV)
  static void downloadHospitalTransfusionAuditCsv(MockDataService mockService) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Hospital Monthly Transfusion Audit & Surgery Allocation Register',
    );
    buffer.writeln('Facility,Apollo Multi-Specialty Hospital Jubilee Hills');
    buffer.writeln('Reporting Period,September 2026');
    buffer.writeln('NABH Compliance,Accredited Grade A');
    buffer.writeln('');
    buffer.writeln(
      'Requisition ID,Patient Name,Blood Group,Units Transfused,Department,Attending Surgeon,Cross-Match Status,Transfusion Timestamp',
    );

    buffer.writeln(
      'REQ-9012,Priya Sharma,O-,1,Cardiovascular ICU,Dr. Radhika Menon,COMPATIBLE 100%,2026-09-28 14:30',
    );
    buffer.writeln(
      'REQ-8891,Rohan Varma,O-,1,Emergency Trauma,Dr. Arvind Mehra,COMPATIBLE 100%,2026-09-24 11:15',
    );
    buffer.writeln(
      'REQ-8734,Aarohi Sen,O-,1,Oncology Day Care,Dr. Suresh Varma,COMPATIBLE 100%,2026-09-20 16:45',
    );
    buffer.writeln(
      'REQ-8512,Kabir Mukherjee,O-,1,Orthopedic Surgery,Dr. Neha Kapoor,COMPATIBLE 100%,2026-09-16 09:20',
    );
    buffer.writeln(
      'REQ-8420,Ananya Iyer,A+,2,General Surgery,Dr. Vikram Seth,COMPATIBLE 100%,2026-09-12 18:00',
    );

    saveFile(
      filename: 'Hospital_Monthly_Transfusion_Audit_Sep2026.csv',
      content: buffer.toString(),
      mimeType: 'text/csv',
    );
  }

  /// 8. Real Patient Transfusion Medical Record File (CSV + HTML Printable)
  static void downloadPatientTransfusionRecords(
    MockDataService mockService, [
    PatientProfile? patient,
  ]) {
    final p = patient ?? mockService.patientProfile;
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Patient Transfusion Medical Audit - ${p.name}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; }
    .audit-card { max-width: 720px; margin: 0 auto; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1.5px solid #e2e8f0; overflow: hidden; }
    .header { background: #0f172a; color: white; padding: 24px; }
    .header h1 { margin: 0 0 6px 0; font-size: 20px; font-weight: 900; }
    .header p { margin: 0; font-size: 13px; color: #94a3b8; }
    .patient-strip { background: #f0f9ff; border-bottom: 1.5px solid #bae6fd; padding: 16px 24px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; font-size: 13px; }
    .patient-strip div span { display: block; font-size: 10.5px; color: #0284c7; font-weight: 700; text-transform: uppercase; }
    .patient-strip div strong { color: #0f172a; font-weight: 800; font-size: 14px; }
    .content { padding: 24px; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 13px; }
    th { background: #f8fafc; color: #475569; font-weight: 800; text-align: left; padding: 10px 12px; border-bottom: 2px solid #e2e8f0; }
    td { padding: 12px 12px; border-bottom: 1px solid #f1f5f9; color: #0f172a; }
    .badge { padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 800; background: #ecfdf5; color: #059669; }
    .footer { padding: 18px 24px; background: #f8fafc; border-top: 1.5px solid #e2e8f0; text-align: center; font-size: 11px; color: #64748b; }
  </style>
</head>
<body>
  <div class="audit-card">
    <div class="header">
      <h1>🏥 VitalPulse • PATIENT TRANSFUSION CLINICAL AUDIT</h1>
      <p>Encrypted National Health Authority (NABH) Clinical Record</p>
      <p style="margin-top: 6px; font-size: 12px; color: #38bdf8;">Export Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • Confidential Medical Document</p>
    </div>
    <div class="patient-strip">
      <div><span>Patient Name</span><strong>${p.name}</strong></div>
      <div><span>Blood Group</span><strong style="color: #dc2626;">${p.bloodType.label}</strong></div>
      <div><span>Patient ID</span><strong>PAT-2026-981</strong></div>
      <div><span>Emergency Contact</span><strong>${p.emergencyContactName} (${p.emergencyContactPhone})</strong></div>
      <div><span>City / Jurisdiction</span><strong>${p.location}</strong></div>
      <div><span>Verification</span><strong style="color: #059669;">● NABH Verified</strong></div>
    </div>
    <div class="content">
      <h3 style="margin-top: 0; font-size: 15px; color: #0f172a;">Transfusion History & Cross-Match Ledger</h3>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Hospital Facility</th>
            <th>Units & Group</th>
            <th>Supervising Doctor</th>
            <th>Clinical Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>28 Sep 2026</strong></td>
            <td>Apollo Multi-Specialty Jubilee Hills</td>
            <td>1 Unit (${p.bloodType.label})</td>
            <td>Dr. Radhika Menon</td>
            <td><span class="badge">Successful 100%</span></td>
          </tr>
          <tr>
            <td><strong>14 Jun 2026</strong></td>
            <td>KIMS Hospital Secunderabad</td>
            <td>1 Unit (${p.bloodType.label})</td>
            <td>Dr. Arvind Mehra</td>
            <td><span class="badge">Successful 100%</span></td>
          </tr>
          <tr>
            <td><strong>05 Jan 2026</strong></td>
            <td>Yashoda Hospitals Somajiguda</td>
            <td>2 Units (${p.bloodType.label})</td>
            <td>Dr. Suresh Varma</td>
            <td><span class="badge">Successful 100%</span></td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="footer">
      Certified by National Blood Transfusion Council (NBTC) • Direct Emergency Desk: 108 / 1800-11-2478
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename:
          'VitalPulse_Transfusion_Audit_${p.name.replaceAll(' ', '_')}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 9. Real Patient Requisition Slip (.html / Printable)
  static void downloadPatientRequisitionSlip(
    PatientBloodRequestItem req,
    PatientProfile patient,
  ) {
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Official Blood Requisition Slip - ${req.id}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; display: flex; justify-content: center; }
    .slip { width: 680px; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1.5px solid #e2e8f0; overflow: hidden; }
    .header { background: #0f172a; color: white; padding: 24px; }
    .header h1 { margin: 0 0 4px 0; font-size: 19px; font-weight: 900; }
    .header p { margin: 0; font-size: 12.5px; color: #94a3b8; }
    .content { padding: 24px; }
    .section-title { font-size: 12px; font-weight: 900; color: #0284c7; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 16px; margin-bottom: 8px; border-bottom: 1.5px solid #e2e8f0; padding-bottom: 4px; }
    .row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 13px; border-bottom: 1px dashed #f1f5f9; }
    .row .label { color: #64748b; font-weight: 600; }
    .row .value { font-weight: 800; color: #0f172a; text-align: right; }
    .highlight { background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 12px; padding: 14px; margin: 14px 0; }
    .footer { padding: 16px 24px; background: #f8fafc; border-top: 1.5px solid #e2e8f0; text-align: center; font-size: 11px; color: #64748b; }
  </style>
</head>
<body>
  <div class="slip">
    <div class="header">
      <h1>🩸 VitalPulse • OFFICIAL BLOOD REQUISITION SLIP</h1>
      <p>Requisition ID: <strong>${req.id}</strong> • Priority: <strong>${req.priority.name.toUpperCase()}</strong></p>
    </div>
    <div class="content">
      <div class="section-title">1. Patient Details</div>
      <div class="row"><span class="label">Patient Name:</span><span class="value">${patient.name}</span></div>
      <div class="row"><span class="label">Required Blood Group:</span><span class="value" style="color: #dc2626; font-size: 15px;">${req.bloodType.label} (${req.bloodType.name})</span></div>
      <div class="row"><span class="label">Units Demanded:</span><span class="value">${req.units} Units (${req.units * 450} mL)</span></div>
      <div class="row"><span class="label">Required By:</span><span class="value">${req.requiredDateTime.day}/${req.requiredDateTime.month}/${req.requiredDateTime.year} ${req.requiredDateTime.hour}:${req.requiredDateTime.minute.toString().padLeft(2, '0')}</span></div>

      <div class="section-title">2. Destination & Clinical Center</div>
      <div class="row"><span class="label">Hospital / Center:</span><span class="value">${req.hospital}</span></div>
      <div class="row"><span class="label">Department / Ward:</span><span class="value">Cardiothoracic Surgery & ICU</span></div>
      <div class="row"><span class="label">Prescribing Physician:</span><span class="value">Dr. Radhika Menon, MD (Transfusion Desk)</span></div>
      <div class="row"><span class="label">Clinical Notes:</span><span class="value">${req.notes ?? 'Standard Emergency Transfusion Order'}</span></div>

      <div class="section-title">3. Matching & Allocation Status</div>
      <div class="highlight">
        <div class="row"><span class="label">Current Status:</span><span class="value" style="color: #dc2626;">${req.status.label.toUpperCase()}</span></div>
        <div class="row"><span class="label">Matched Donor:</span><span class="value">${req.matchedDonorName ?? 'Active AI Proximity Matching in Progress'}</span></div>
      </div>
    </div>
    <div class="footer">
      Authorized VitalPulse Medical Order • Verify on Emergency Desk: 108 / 1800-11-2478
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename: 'VitalPulse_BloodRequisition_${req.id}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 10. Real Emergency SOS Incident Report (.html / Printable)
  static void downloadSOSIncidentReport(
    EmergencySOSRequest sos,
    PatientProfile patient,
  ) {
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Trauma Code Alpha Incident Report - ${sos.id}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; display: flex; justify-content: center; }
    .incident-card { width: 720px; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 2px solid #ef4444; overflow: hidden; }
    .header { background: #991b1b; color: white; padding: 24px; }
    .header h1 { margin: 0 0 4px 0; font-size: 20px; font-weight: 900; }
    .header p { margin: 0; font-size: 13px; color: #fecaca; }
    .badge-sos { background: white; color: #991b1b; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 900; display: inline-block; margin-top: 6px; }
    .content { padding: 24px; }
    .section-title { font-size: 12px; font-weight: 900; color: #dc2626; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 16px; margin-bottom: 8px; border-bottom: 1.5px solid #fee2e2; padding-bottom: 4px; }
    .row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 13px; border-bottom: 1px dashed #f1f5f9; }
    .row .label { color: #64748b; font-weight: 600; }
    .row .value { font-weight: 800; color: #0f172a; text-align: right; }
    .footer { padding: 16px 24px; background: #fef2f2; border-top: 1.5px solid #fee2e2; text-align: center; font-size: 11px; color: #991b1b; font-weight: 700; }
  </style>
</head>
<body>
  <div class="incident-card">
    <div class="header">
      <h1>🚨 VITALPULSE MASSIVE TRANSFUSION PROTOCOL (MTP) REPORT</h1>
      <p>Incident Broadcast ID: <strong>${sos.id}</strong> • Trauma Code: <strong>PRIORITY ALPHA</strong></p>
      <div class="badge-sos">LIVE EMERGENCY DISPATCH LOG</div>
    </div>
    <div class="content">
      <div class="section-title">1. Patient & Medical Triage</div>
      <div class="row"><span class="label">Patient Name:</span><span class="value">${patient.name} (ID: PAT-2026-981)</span></div>
      <div class="row"><span class="label">Required Blood Group:</span><span class="value" style="color: #dc2626; font-size: 15px;">${sos.bloodType.label}</span></div>
      <div class="row"><span class="label">Units Required:</span><span class="value">${sos.unitsRequired} Units (${sos.unitsRequired * 450} mL)</span></div>
      <div class="row"><span class="label">Facility & Ward:</span><span class="value">${sos.hospital} • ${sos.location}</span></div>
      <div class="row"><span class="label">Emergency Contact:</span><span class="value">${patient.emergencyContactName} (${patient.emergencyContactPhone})</span></div>

      <div class="section-title">2. Dispatch Telemetry & Radar</div>
      <div class="row"><span class="label">Compatible Donors Alerted:</span><span class="value" style="color: #0284c7;">${sos.matchedDonorsCount} Donors in 10 km Radius</span></div>
      <div class="row"><span class="label">Blood Centers Notified:</span><span class="value" style="color: #059669;">${sos.nearbyBanksCount} Verified Facilities</span></div>
      <div class="row"><span class="label">Current Status:</span><span class="value" style="color: #dc2626;">${sos.status.label.toUpperCase()}</span></div>
      <div class="row"><span class="label">Green Corridor Clearance:</span><span class="value">ACTIVE (Traffic Police Route Clearance Authorized)</span></div>
    </div>
    <div class="footer">
      Generated automatically by VitalPulse Smart Emergency Network • Integrated with 108 Emergency Dispatch
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename: 'VitalPulse_EmergencySOS_Incident_${sos.id}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 11. Real Hospital Blood Inventory CSV
  static void downloadHospitalInventoryCsv(MockDataService mockService) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Hospital Blood Inventory Audit Ledger - VitalPulse Clinical Grid',
    );
    buffer.writeln('Hospital,${mockService.hospitalName}');
    buffer.writeln('License ID,${mockService.hospitalLicenseId}');
    buffer.writeln('Location,${mockService.hospitalLocation}');
    buffer.writeln('Export Timestamp,${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln(
      'Blood Group,Available Units,Reserved Units,Used Units (30D),Expiring (7D),Total Active,Status',
    );

    mockService.hospitalInventory.forEach((type, group) {
      final total = group.availableUnits + group.reservedUnits;
      final status = group.isCritical
          ? 'CRITICAL DEFICIT'
          : (group.isLowStock ? 'LOW STOCK' : 'ADEQUATE');
      buffer.writeln(
        '${type.label},${group.availableUnits},${group.reservedUnits},${group.usedUnits},${group.expiringUnits},$total,$status',
      );
    });

    saveFile(
      filename:
          'Hospital_Blood_Inventory_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}.csv',
      content: buffer.toString(),
      mimeType: 'text/csv',
    );
  }

  /// 12. Real Hospital Patient Requisitions CSV
  static void downloadHospitalPatientRequisitionsCsv(
    MockDataService mockService,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Hospital Inpatient Blood Requisition Register');
    buffer.writeln('Facility,${mockService.hospitalName}');
    buffer.writeln('Export Date,${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln(
      'Requisition ID,Patient Ref,Patient Name,Ward/Department,Blood Group,Units Required,Units Assigned,Priority,Required Date,Status,Clinical Directives',
    );

    for (final req in mockService.hospitalRequests) {
      final reqDate =
          '${req.requiredDateTime.day}/${req.requiredDateTime.month}/${req.requiredDateTime.year}';
      buffer.writeln(
        '${req.id},${req.patientRefId},"${req.patientName}","${req.departmentOrWard}",${req.bloodType.label},${req.unitsRequired},${req.assignedUnits},${req.priority.name.toUpperCase()},$reqDate,${req.status.label},"${req.clinicalNotes ?? ''}"',
      );
    }

    saveFile(
      filename:
          'Hospital_Patient_Requisitions_${DateTime.now().year}_${DateTime.now().month}.csv',
      content: buffer.toString(),
      mimeType: 'text/csv',
    );
  }

  /// 13. Real Hospital Clinical Performance & Transfusion Audit Report (.html / Printable)
  static void downloadHospitalClinicalReport(MockDataService mockService) {
    int totalAvail = 0;
    int totalRes = 0;
    int totalUsed = 0;
    mockService.hospitalInventory.forEach((_, g) {
      totalAvail += g.availableUnits;
      totalRes += g.reservedUnits;
      totalUsed += g.usedUnits;
    });

    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>VitalPulse Hospital Clinical Transfusion Report - ${mockService.hospitalName}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; }
    .report-card { max-width: 840px; margin: 0 auto; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1.5px solid #e2e8f0; overflow: hidden; }
    .header { background: #0f172a; color: white; padding: 26px; }
    .header h1 { margin: 0 0 6px 0; font-size: 20px; font-weight: 900; }
    .header p { margin: 0; font-size: 13px; color: #94a3b8; }
    .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; padding: 20px 26px; background: #f1f5f9; border-bottom: 1.5px solid #e2e8f0; }
    .kpi { background: white; padding: 14px; border-radius: 12px; text-align: center; border: 1px solid #cbd5e1; }
    .kpi span { font-size: 10.5px; color: #64748b; font-weight: 700; text-transform: uppercase; }
    .kpi strong { display: block; font-size: 20px; color: #0284c7; font-weight: 900; margin-top: 4px; }
    .content { padding: 26px; }
    table { width: 100%; border-collapse: collapse; margin-top: 14px; font-size: 13px; }
    th { background: #f8fafc; color: #475569; font-weight: 800; text-align: left; padding: 10px 12px; border-bottom: 2px solid #e2e8f0; }
    td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; color: #0f172a; }
    .badge { padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 800; }
    .badge-success { background: #ecfdf5; color: #059669; }
    .badge-danger { background: #fef2f2; color: #dc2626; }
    .badge-warning { background: #fffbeb; color: #d97706; }
    .footer { padding: 18px 26px; background: #f8fafc; border-top: 1.5px solid #e2e8f0; text-align: center; font-size: 11px; color: #64748b; }
  </style>
</head>
<body>
  <div class="report-card">
    <div class="header">
      <h1>🏥 ${mockService.hospitalName} • CLINICAL TRANSFUSION AUDIT</h1>
      <p>NABH Accredited • License: ${mockService.hospitalLicenseId} • ${mockService.hospitalLocation}</p>
      <p style="margin-top: 6px; font-size: 12px; color: #38bdf8;">Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • Integrated with State Blood Transfusion Council</p>
    </div>
    <div class="kpi-grid">
      <div class="kpi"><span>Available Units</span><strong style="color: #059669;">$totalAvail</strong></div>
      <div class="kpi"><span>Reserved Units</span><strong style="color: #d97706;">$totalRes</strong></div>
      <div class="kpi"><span>Units Administered</span><strong style="color: #0f172a;">$totalUsed</strong></div>
      <div class="kpi"><span>Fulfillment Rate</span><strong style="color: #7c3aed;">96.8%</strong></div>
    </div>
    <div class="content">
      <h3 style="margin-top: 0; font-size: 15px; color: #0f172a;">Blood Inventory Status by Group</h3>
      <table>
        <thead>
          <tr>
            <th>Blood Group</th>
            <th>Available</th>
            <th>Reserved</th>
            <th>Used (30D)</th>
            <th>Expiring (7D)</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          ${mockService.hospitalInventory.entries.map((e) => '''
          <tr>
            <td><strong>${e.key.label}</strong></td>
            <td style="color: #059669; font-weight: bold;">${e.value.availableUnits}</td>
            <td style="color: #d97706; font-weight: bold;">${e.value.reservedUnits}</td>
            <td>${e.value.usedUnits}</td>
            <td style="color: #dc2626;">${e.value.expiringUnits}</td>
            <td>
              <span class="badge ${e.value.isCritical ? 'badge-danger' : (e.value.isLowStock ? 'badge-warning' : 'badge-success')}">
                ${e.value.isCritical ? 'CRITICAL' : (e.value.isLowStock ? 'LOW' : 'OPTIMAL')}
              </span>
            </td>
          </tr>
          ''').join('')}
        </tbody>
      </table>

      <h3 style="margin-top: 24px; font-size: 15px; color: #0f172a;">Recent Inpatient Requisitions</h3>
      <table>
        <thead>
          <tr>
            <th>Requisition ID</th>
            <th>Patient Name</th>
            <th>Ward</th>
            <th>Group</th>
            <th>Units</th>
            <th>Priority</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          ${mockService.hospitalRequests.take(6).map((r) => '''
          <tr>
            <td><strong>${r.id}</strong></td>
            <td>${r.patientName} (${r.patientRefId})</td>
            <td>${r.departmentOrWard}</td>
            <td style="color: #dc2626; font-weight: bold;">${r.bloodType.label}</td>
            <td>${r.assignedUnits} / ${r.unitsRequired}</td>
            <td><strong>${r.priority.name.toUpperCase()}</strong></td>
            <td><span class="badge badge-success">${r.status.label}</span></td>
          </tr>
          ''').join('')}
        </tbody>
      </table>
    </div>
    <div class="footer">
      Official NABH Hospital Blood Transfusion Safety Audit • VitalPulse Central Health Information Grid
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename:
          'Hospital_Clinical_Transfusion_Report_${DateTime.now().year}_${DateTime.now().month}.html',
      content: html,
      mimeType: 'text/html',
    );
  }

  /// 14. Real Hospital Patient Requisition Slip (.html / Printable)
  static void downloadHospitalRequisitionSlip(
    HospitalPatientBloodRequest req,
    MockDataService mockService,
  ) {
    final html =
        '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Hospital Blood Requisition Voucher - ${req.id}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f8fafc; color: #0f172a; margin: 0; padding: 30px; display: flex; justify-content: center; }
    .voucher { width: 680px; background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.06); border: 1.5px solid #e2e8f0; overflow: hidden; }
    .header { background: #0f172a; color: white; padding: 24px; }
    .header h1 { margin: 0 0 4px 0; font-size: 19px; font-weight: 900; }
    .header p { margin: 0; font-size: 12.5px; color: #94a3b8; }
    .content { padding: 24px; }
    .section-title { font-size: 12px; font-weight: 900; color: #0284c7; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 16px; margin-bottom: 8px; border-bottom: 1.5px solid #e2e8f0; padding-bottom: 4px; }
    .row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 13px; border-bottom: 1px dashed #f1f5f9; }
    .row .label { color: #64748b; font-weight: 600; }
    .row .value { font-weight: 800; color: #0f172a; text-align: right; }
    .highlight { background: #f0f9ff; border: 1.5px solid #bae6fd; border-radius: 12px; padding: 14px; margin: 14px 0; }
    .footer { padding: 16px 24px; background: #f8fafc; border-top: 1.5px solid #e2e8f0; text-align: center; font-size: 11px; color: #64748b; }
  </style>
</head>
<body>
  <div class="voucher">
    <div class="header">
      <h1>🏥 ${mockService.hospitalName} • BLOOD REQUISITION VOUCHER</h1>
      <p>Requisition ID: <strong>${req.id}</strong> • Priority: <strong>${req.priority.name.toUpperCase()}</strong></p>
    </div>
    <div class="content">
      <div class="section-title">1. Patient Information</div>
      <div class="row"><span class="label">Patient Name:</span><span class="value">${req.patientName}</span></div>
      <div class="row"><span class="label">Patient Ref / IP No:</span><span class="value">${req.patientRefId}</span></div>
      <div class="row"><span class="label">Ward / Operating Room:</span><span class="value">${req.departmentOrWard}</span></div>
      <div class="row"><span class="label">Required Blood Group:</span><span class="value" style="color: #dc2626; font-size: 15px;">${req.bloodType.label} (${req.bloodType.name})</span></div>
      <div class="row"><span class="label">Units Required:</span><span class="value">${req.unitsRequired} Units (${req.unitsRequired * 450} mL)</span></div>
      <div class="row"><span class="label">Units Allocated:</span><span class="value" style="color: #059669;">${req.assignedUnits} Units</span></div>
      <div class="row"><span class="label">Required By:</span><span class="value">${req.requiredDateTime.day}/${req.requiredDateTime.month}/${req.requiredDateTime.year} ${req.requiredDateTime.hour}:${req.requiredDateTime.minute.toString().padLeft(2, '0')}</span></div>

      <div class="section-title">2. Clinical Directives & Surgeon Orders</div>
      <div class="highlight">
        <div class="row"><span class="label">Status:</span><span class="value" style="color: #0284c7;">${req.status.label.toUpperCase()}</span></div>
        <div class="row"><span class="label">Clinical Directives:</span><span class="value">${req.clinicalNotes ?? 'Routine Pre-Op Transfusion Crossmatch Order'}</span></div>
      </div>
    </div>
    <div class="footer">
      NABH Verified Hospital Clinical Order • Emergency Dispatch Desk: 108 / 1800-11-2478
    </div>
  </div>
  <script>window.onload = function() { window.focus(); };</script>
</body>
</html>
''';

    saveFile(
      filename: 'Hospital_Blood_Requisition_${req.id}.html',
      content: html,
      mimeType: 'text/html',
    );
  }
}
