import 'blood_type.dart';

enum RequestPriority { normal, urgent, emergency }

enum PatientTrackingStatus {
  pending('Pending', 'Request submitted, awaiting review'),
  searching('Searching for Donors', 'Broadcasting to compatible nearby donors'),
  donorMatched('Donor Matched', 'Compatible donors identified and alerted'),
  bloodReserved('Blood Reserved', 'Units locked at blood center'),
  fulfilled('Fulfilled', 'Transfusion ready or completed'),
  cancelled('Cancelled', 'Request was cancelled');

  final String label;
  final String description;
  const PatientTrackingStatus(this.label, this.description);
}

class PatientProfile {
  String name;
  BloodType bloodType;
  String phone;
  String email;
  String location;
  String emergencyContactName;
  String emergencyContactRelation;
  String emergencyContactPhone;

  PatientProfile({
    required this.name,
    required this.bloodType,
    required this.phone,
    required this.email,
    required this.location,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactPhone,
  });

  PatientProfile copyWith({
    String? name,
    BloodType? bloodType,
    String? phone,
    String? email,
    String? location,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
  }) {
    return PatientProfile(
      name: name ?? this.name,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }
}

class DonorMatch {
  final String id;
  final String name;
  final BloodType bloodType;
  final double distanceKm;
  final String availability; // 'Available Now', 'On Call', 'Standby'
  final String eligibility; // 'Eligible (Last donation: 4 mos)', 'Verified donor'
  final int matchPercentage;
  final String phone;
  final String city;

  DonorMatch({
    required this.id,
    required this.name,
    required this.bloodType,
    required this.distanceKm,
    required this.availability,
    required this.eligibility,
    required this.matchPercentage,
    required this.phone,
    required this.city,
  });
}

class EmergencySOSRequest {
  final String id;
  final String hospital;
  final String location;
  final BloodType bloodType;
  final int unitsRequired;
  PatientTrackingStatus status;
  final DateTime timestamp;
  final int matchedDonorsCount;
  final int nearbyBanksCount;
  final String? notes;

  EmergencySOSRequest({
    required this.id,
    required this.hospital,
    required this.location,
    required this.bloodType,
    required this.unitsRequired,
    required this.status,
    required this.timestamp,
    required this.matchedDonorsCount,
    required this.nearbyBanksCount,
    this.notes,
  });
}

class PatientBloodRequestItem {
  final String id;
  final BloodType bloodType;
  final int units;
  final String hospital;
  final DateTime requiredDateTime;
  final RequestPriority priority;
  final String? notes;
  PatientTrackingStatus status;
  final DateTime createdAt;
  final String? matchedDonorName;

  PatientBloodRequestItem({
    required this.id,
    required this.bloodType,
    required this.units,
    required this.hospital,
    required this.requiredDateTime,
    required this.priority,
    this.notes,
    required this.status,
    required this.createdAt,
    this.matchedDonorName,
  });
}

enum FacilityType { bloodBank, hospital, donationCamp }

class NearbyFacility {
  final String id;
  final String name;
  final FacilityType type;
  final String address;
  final double distanceKm;
  final String phone;
  final Map<BloodType, int> stock;
  final double rating;
  final String openHours;
  final String? eventDate; // for donation camps
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String landmark;
  final List<String> directionsSteps;

  NearbyFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.distanceKm,
    required this.phone,
    required this.stock,
    required this.rating,
    required this.openHours,
    this.eventDate,
    this.city = 'Hyderabad',
    this.state = 'Telangana',
    this.latitude = 17.4325,
    this.longitude = 78.4071,
    this.landmark = 'Near Main Hospital Road',
    this.directionsSteps = const [
      'Head towards Main Road and merge into Highway corridor',
      'Follow signs for Emergency / Blood Bank Center',
      'Arrive at Main Gate and proceed to Blood Storage Wing',
    ],
  });
}

class PatientNotification {
  final String id;
  final String type; // 'donor_matched', 'status_changed', 'blood_found', 'emergency_response', 'reminder'
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  PatientNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class PatientAppointment {
  final String id;
  final String facilityName;
  final String doctorOrDept;
  final DateTime dateTime;
  final String purpose;
  final String status; // 'Confirmed', 'Completed', 'Rescheduled'

  PatientAppointment({
    required this.id,
    required this.facilityName,
    required this.doctorOrDept,
    required this.dateTime,
    required this.purpose,
    required this.status,
  });
}

class SearchHistoryItem {
  final String id;
  final BloodType bloodType;
  final String locationQuery;
  final DateTime timestamp;
  final int foundUnits;

  SearchHistoryItem({
    required this.id,
    required this.bloodType,
    required this.locationQuery,
    required this.timestamp,
    required this.foundUnits,
  });
}

/// Represents a live Indian hospital with blood bank & emergency services.
class IndianHospital {
  final String id;
  final String name;
  final String city;
  final String state;
  final String address;
  final String phone;
  final String? website;
  final double latitude;
  final double longitude;
  final double rating;
  final int totalBeds;
  final bool hasBloodBank;
  final bool has24x7Emergency;
  final bool isNABHAccredited;
  final bool isGovernment;
  final List<String> specialities;
  final Map<BloodType, int> bloodStock;
  final String openHours;
  final String landmark;
  final String tier; // 'Tier-1', 'Tier-2', 'Tier-3'

  IndianHospital({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.address,
    required this.phone,
    this.website,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.totalBeds,
    required this.hasBloodBank,
    required this.has24x7Emergency,
    required this.isNABHAccredited,
    this.isGovernment = false,
    required this.specialities,
    required this.bloodStock,
    required this.openHours,
    this.landmark = '',
    this.tier = 'Tier-1',
  });
}
