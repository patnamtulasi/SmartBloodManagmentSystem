import 'blood_type.dart';

enum RequestStatus { pending, matching, found, confirmed, completed, cancelled }
enum UrgencyLevel { normal, high, critical } 

class BloodRequest {
  final String id;
  final String patientId;
  final String patientName;
  final BloodType requestedType;
  final int unitsRequired;
  final String location;
  final UrgencyLevel urgency;
  final RequestStatus status;
  final DateTime requiredBy;
  final String? notes;

  BloodRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.requestedType,
    required this.unitsRequired,
    required this.location,
    this.urgency = UrgencyLevel.normal,
    this.status = RequestStatus.pending,
    required this.requiredBy,
    this.notes,
  });
}
