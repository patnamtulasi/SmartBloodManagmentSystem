import 'blood_type.dart';

enum HospitalRequestPriority { normal, urgent, emergency }

enum HospitalRequestStatus {
  pending('Pending', 'Waiting for stock check or donor response'),
  inProgress('In Progress', 'Units being matched or transferred'),
  reserved('Reserved', 'Units allocated from hospital blood reserve'),
  fulfilled('Fulfilled', 'Transfusion ready or administered to patient'),
  escalated('Escalated', 'Urgent alert sent to regional blood bank network'),
  cancelled('Cancelled', 'Request closed or cancelled');

  final String label;
  final String description;
  const HospitalRequestStatus(this.label, this.description);
}

class HospitalPatientBloodRequest {
  final String id;
  final String patientRefId;
  final String patientName;
  final String departmentOrWard;
  final BloodType bloodType;
  final int unitsRequired;
  int assignedUnits;
  final HospitalRequestPriority priority;
  final DateTime requiredDateTime;
  HospitalRequestStatus status;
  final String? clinicalNotes;
  final DateTime createdAt;
  bool isEscalated;

  HospitalPatientBloodRequest({
    required this.id,
    required this.patientRefId,
    required this.patientName,
    required this.departmentOrWard,
    required this.bloodType,
    required this.unitsRequired,
    this.assignedUnits = 0,
    required this.priority,
    required this.requiredDateTime,
    this.status = HospitalRequestStatus.pending,
    this.clinicalNotes,
    required this.createdAt,
    this.isEscalated = false,
  });
}

class HospitalInventoryGroup {
  final BloodType bloodType;
  int availableUnits;
  int reservedUnits;
  int usedUnits;
  int expiringUnits; // expiring within 7 days
  final int minThreshold;

  HospitalInventoryGroup({
    required this.bloodType,
    required this.availableUnits,
    required this.reservedUnits,
    required this.usedUnits,
    required this.expiringUnits,
    required this.minThreshold,
  });

  bool get isLowStock => availableUnits <= minThreshold;
  bool get isCritical => availableUnits <= (minThreshold / 2).ceil();
}

enum TransferStatus {
  requested('Requested', 'Transfer requisition sent to blood bank'),
  dispatched('Dispatched', 'Blood bank packed and dispatched units'),
  inTransit('In Transit', 'Courier en route to hospital trauma wing'),
  delivered('Delivered', 'Units arrived at hospital blood bank receiving'),
  confirmed('Confirmed', 'Verified and integrated into active hospital stock');

  final String label;
  final String description;
  const TransferStatus(this.label, this.description);
}

class BloodBankTransferItem {
  final String id;
  final String bloodBankId;
  final String bloodBankName;
  final BloodType bloodType;
  final int units;
  TransferStatus status;
  final DateTime requestedAt;
  final int etaMinutes;
  final String transportCourier;

  BloodBankTransferItem({
    required this.id,
    required this.bloodBankId,
    required this.bloodBankName,
    required this.bloodType,
    required this.units,
    required this.status,
    required this.requestedAt,
    required this.etaMinutes,
    required this.transportCourier,
  });
}

class HospitalPatientRecord {
  final String patientRefId;
  final String name;
  final int age;
  final BloodType bloodType;
  final String ward;
  final String admissionDate;
  final bool isEmergency;
  int assignedUnits;
  final int totalRequestsCount;
  final String attendingPhysician;
  final String diagnosis;

  HospitalPatientRecord({
    required this.patientRefId,
    required this.name,
    required this.age,
    required this.bloodType,
    required this.ward,
    required this.admissionDate,
    required this.isEmergency,
    this.assignedUnits = 0,
    required this.totalRequestsCount,
    required this.attendingPhysician,
    required this.diagnosis,
  });
}

enum HospitalAppointmentStatus { upcoming, confirmed, rescheduled, completed, cancelled }

class HospitalAppointmentItem {
  final String id;
  final String patientRefId;
  final String patientName;
  final BloodType bloodType;
  final String procedureType; // 'Platelet Infusion', 'Whole Blood Transfusion', 'Pre-Op Crossmatch'
  DateTime dateTime;
  HospitalAppointmentStatus status;
  final String room;
  final String notes;

  HospitalAppointmentItem({
    required this.id,
    required this.patientRefId,
    required this.patientName,
    required this.bloodType,
    required this.procedureType,
    required this.dateTime,
    this.status = HospitalAppointmentStatus.upcoming,
    required this.room,
    required this.notes,
  });
}

class HospitalNotificationItem {
  final String id;
  final String type; // 'low_stock', 'expiring', 'donor_response', 'transfer_update', 'emergency'
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final bool isCritical;

  HospitalNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isCritical = false,
  });
}
