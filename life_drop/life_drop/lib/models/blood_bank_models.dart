import 'blood_type.dart';

enum BankInventoryStatus {
  normal('Normal', 'Sufficient stock above safety threshold'),
  lowStock('Low Stock', 'Below minimum safety threshold'),
  critical('Critical', 'Severe deficit requiring urgent restocking'),
  expiringSoon('Expiring Soon', 'Units approaching expiry within 72 hours'),
  expired('Expired', 'Units surpassed viability limit');

  final String label;
  final String description;
  const BankInventoryStatus(this.label, this.description);
}

class BankInventoryItem {
  final BloodType bloodType;
  int availableUnits;
  int reservedUnits;
  int usedUnits;
  int expiringUnits;
  DateTime collectionDate;
  DateTime expiryDate;
  String storageLocation; // e.g. "Cryo Vault Alpha - Tray 4"
  int minimumStockThreshold;
  BankInventoryStatus status;
  String batchNumber;

  BankInventoryItem({
    required this.bloodType,
    required this.availableUnits,
    required this.reservedUnits,
    required this.usedUnits,
    required this.expiringUnits,
    required this.collectionDate,
    required this.expiryDate,
    required this.storageLocation,
    required this.minimumStockThreshold,
    required this.status,
    required this.batchNumber,
  });

  int get totalUnits => availableUnits + reservedUnits;
  bool get isBelowThreshold => availableUnits < minimumStockThreshold;
}

enum LowStockAlertPriority { critical, high, moderate }

class BankLowStockAlert {
  final String id;
  final BloodType bloodType;
  final int currentUnits;
  final int requiredMinimumUnits;
  final LowStockAlertPriority priority;
  final String suggestedAction;
  bool isReviewed;

  BankLowStockAlert({
    required this.id,
    required this.bloodType,
    required this.currentUnits,
    required this.requiredMinimumUnits,
    required this.priority,
    required this.suggestedAction,
    this.isReviewed = false,
  });
}

class BankExpiryItem {
  final String batchNumber;
  final BloodType bloodType;
  final int units;
  final DateTime expiryDate;
  final String storageLocation;
  final String timeframe; // 'today', '3_days', '7_days', 'expired'
  bool isPrioritized;
  bool isDiscarded;
  String? wastageReason;

  BankExpiryItem({
    required this.batchNumber,
    required this.bloodType,
    required this.units,
    required this.expiryDate,
    required this.storageLocation,
    required this.timeframe,
    this.isPrioritized = false,
    this.isDiscarded = false,
    this.wastageReason,
  });
}

enum BankHospitalReqStatus {
  pending('Pending'),
  underReview('Under Review'),
  approved('Approved'),
  partiallyFulfilled('Partially Fulfilled'),
  fulfilled('Fulfilled'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String label;
  const BankHospitalReqStatus(this.label);
}

class BankHospitalRequest {
  final String id;
  final String hospitalName;
  final String patientRefId;
  final BloodType bloodType;
  final int unitsRequired;
  int unitsAssigned;
  final String urgency; // 'Critical Trauma', 'Urgent Surgery', 'Standard Scheduled'
  final DateTime requiredDateTime;
  BankHospitalReqStatus status;
  String internalNotes;
  final DateTime createdAt;

  BankHospitalRequest({
    required this.id,
    required this.hospitalName,
    required this.patientRefId,
    required this.bloodType,
    required this.unitsRequired,
    this.unitsAssigned = 0,
    required this.urgency,
    required this.requiredDateTime,
    this.status = BankHospitalReqStatus.pending,
    this.internalNotes = '',
    required this.createdAt,
  });
}

enum BankTransferStatus {
  requested('Requested'),
  approved('Approved'),
  prepared('Prepared'),
  inTransit('In Transit'),
  delivered('Delivered'),
  cancelled('Cancelled');

  final String label;
  const BankTransferStatus(this.label);
}

class BankTransferItem {
  final String id;
  final String sourceOrg;
  final String destinationOrg;
  final BloodType bloodType;
  final int units;
  final DateTime requestDate;
  DateTime? dispatchDate;
  DateTime expectedDeliveryDate;
  BankTransferStatus status;
  String transportCarrier;
  String trackingId;

  BankTransferItem({
    required this.id,
    required this.sourceOrg,
    required this.destinationOrg,
    required this.bloodType,
    required this.units,
    required this.requestDate,
    this.dispatchDate,
    required this.expectedDeliveryDate,
    this.status = BankTransferStatus.requested,
    this.transportCarrier = 'Cold-Chain Express Logistics',
    required this.trackingId,
  });
}

enum BankIntakeStatus {
  donationReceived('Donation Received'),
  screeningPending('Screening Pending'),
  approvedForProcessing('Approved for Processing'),
  processing('Processing'),
  stored('Stored in Cryo Vault'),
  rejected('Rejected / Screen Reactive'),
  expired('Expired');

  final String label;
  const BankIntakeStatus(this.label);
}

class BankDonationIntakeRecord {
  final String intakeId;
  final String donorId;
  final BloodType bloodType;
  final DateTime donationDate;
  final String donationCenter;
  final int units;
  String screeningStatus; // 'Negative (HIV, HepB, HepC, Syphilis)', 'Pending Serology', 'Inconclusive'
  BankIntakeStatus processingStatus;
  String storageLocation;
  String batchNumber;
  final String campName;

  BankDonationIntakeRecord({
    required this.intakeId,
    required this.donorId,
    required this.bloodType,
    required this.donationDate,
    required this.donationCenter,
    required this.units,
    required this.screeningStatus,
    required this.processingStatus,
    required this.storageLocation,
    required this.batchNumber,
    this.campName = '',
  });
}

class BankDonorRecord {
  final String donorId;
  final BloodType bloodType;
  final DateTime lastDonationDate;
  final String donationCenter;
  final String donationStatus; // 'Approved', 'Screening Cleared', 'Active Donor'
  final String eligibilityStatus; // 'Eligible', 'Cooldown Period', 'Deferred'
  final int totalDonationsCount;
  bool thankYouSent;

  BankDonorRecord({
    required this.donorId,
    required this.bloodType,
    required this.lastDonationDate,
    required this.donationCenter,
    required this.donationStatus,
    required this.eligibilityStatus,
    required this.totalDonationsCount,
    this.thankYouSent = false,
  });
}

enum BankStaffRole {
  manager('Blood Bank Manager', ['View Inventory', 'Edit Inventory', 'Approve Requests', 'Manage Transfers', 'View Reports', 'Manage Staff']),
  inventoryStaff('Inventory Specialist', ['View Inventory', 'Edit Inventory', 'View Reports']),
  intakeStaff('Donation Intake Specialist', ['View Inventory', 'Record Intake', 'Screening Updates']),
  coordinator('Hospital Liaison Coordinator', ['View Inventory', 'Approve Requests', 'Manage Transfers']),
  administrator('System Administrator', ['View Inventory', 'Edit Inventory', 'Approve Requests', 'Manage Transfers', 'View Reports', 'Manage Staff', 'System Configuration']);

  final String roleName;
  final List<String> permissions;
  const BankStaffRole(this.roleName, this.permissions);
}

class BankAuditLogEntry {
  final String id;
  final String action; // e.g. "Inventory Added", "Units Reserved", "Request Approved", etc.
  final String description;
  final String staffMember;
  final String staffRole;
  final DateTime timestamp;
  final String category; // 'inventory', 'request', 'transfer', 'intake', 'alert'

  BankAuditLogEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.staffMember,
    required this.staffRole,
    required this.timestamp,
    required this.category,
  });
}

class BankFacilityProfile {
  String name;
  String licenseNumber;
  String address;
  String phone;
  String emergencyHotline;
  String email;
  String operatingHours;
  String storageCapacity;
  List<String> availableServices;
  String accreditation;

  BankFacilityProfile({
    required this.name,
    required this.licenseNumber,
    required this.address,
    required this.phone,
    required this.emergencyHotline,
    required this.email,
    required this.operatingHours,
    required this.storageCapacity,
    required this.availableServices,
    required this.accreditation,
  });
}
