import 'blood_type.dart';

enum DonorAvailabilityStatus {
  available('Available to Donate', 'Ready to respond to blood calls and emergencies'),
  unavailable('Temporarily Unavailable', 'Paused from active broadcasts temporarily'),
  ineligible('Not Eligible Currently', 'Within post-donation rest or medical cooldown');

  final String label;
  final String description;
  const DonorAvailabilityStatus(this.label, this.description);
}

class DonorProfileModel {
  String id;
  String name;
  BloodType bloodType;
  String phone;
  String email;
  String location;
  int totalDonations;
  int totalUnitsDonated;
  int donationsThisYear;
  DateTime lastDonationDate;
  DateTime nextEligibleDate;
  bool isVerified;
  String verificationBadge;
  DonorAvailabilityStatus availability;
  String preferredLocation;
  double maxTravelDistanceKm;
  String availableDaysTimes;
  String preferredNotificationMethod;
  String temporaryRestrictionMessage;

  DonorProfileModel({
    required this.id,
    required this.name,
    required this.bloodType,
    required this.phone,
    required this.email,
    required this.location,
    required this.totalDonations,
    required this.totalUnitsDonated,
    required this.donationsThisYear,
    required this.lastDonationDate,
    required this.nextEligibleDate,
    required this.isVerified,
    required this.verificationBadge,
    required this.availability,
    required this.preferredLocation,
    required this.maxTravelDistanceKm,
    required this.availableDaysTimes,
    required this.preferredNotificationMethod,
    this.temporaryRestrictionMessage = '',
  });

  bool get isEligibleToDonate => DateTime.now().isAfter(nextEligibleDate) && availability != DonorAvailabilityStatus.ineligible;

  DonorProfileModel copyWith({
    String? id,
    String? name,
    BloodType? bloodType,
    String? phone,
    String? email,
    String? location,
    int? totalDonations,
    int? totalUnitsDonated,
    int? donationsThisYear,
    DateTime? lastDonationDate,
    DateTime? nextEligibleDate,
    bool? isVerified,
    String? verificationBadge,
    DonorAvailabilityStatus? availability,
    String? preferredLocation,
    double? maxTravelDistanceKm,
    String? availableDaysTimes,
    String? preferredNotificationMethod,
    String? temporaryRestrictionMessage,
  }) {
    return DonorProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      totalDonations: totalDonations ?? this.totalDonations,
      totalUnitsDonated: totalUnitsDonated ?? this.totalUnitsDonated,
      donationsThisYear: donationsThisYear ?? this.donationsThisYear,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      nextEligibleDate: nextEligibleDate ?? this.nextEligibleDate,
      isVerified: isVerified ?? this.isVerified,
      verificationBadge: verificationBadge ?? this.verificationBadge,
      availability: availability ?? this.availability,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      maxTravelDistanceKm: maxTravelDistanceKm ?? this.maxTravelDistanceKm,
      availableDaysTimes: availableDaysTimes ?? this.availableDaysTimes,
      preferredNotificationMethod: preferredNotificationMethod ?? this.preferredNotificationMethod,
      temporaryRestrictionMessage: temporaryRestrictionMessage ?? this.temporaryRestrictionMessage,
    );
  }
}

enum DonorRequestStatus { pending, accepted, declined, respondedLater }

class DonorEmergencyRequestItem {
  final String id;
  final BloodType requiredBloodType;
  final int unitsRequired;
  final String hospitalName;
  final String hospitalLocation;
  final double distanceKm;
  final String urgencyLevel; // 'Critical Trauma', 'Urgent OR Need'
  final DateTime requiredDateTime;
  DonorRequestStatus status;
  final String notes;
  final String hospitalPhone;

  DonorEmergencyRequestItem({
    required this.id,
    required this.requiredBloodType,
    required this.unitsRequired,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.distanceKm,
    required this.urgencyLevel,
    required this.requiredDateTime,
    this.status = DonorRequestStatus.pending,
    required this.notes,
    required this.hospitalPhone,
  });
}

class DonorSmartMatchItem {
  final String id;
  final String patientOrRequestId;
  final BloodType bloodType;
  final int matchPercentage;
  final double distanceKm;
  final String urgency;
  final String reasonForMatch;
  final String hospitalName;

  DonorSmartMatchItem({
    required this.id,
    required this.patientOrRequestId,
    required this.bloodType,
    required this.matchPercentage,
    required this.distanceKm,
    required this.urgency,
    required this.reasonForMatch,
    required this.hospitalName,
  });
}

enum DonorAppointmentStatus { upcoming, confirmed, completed, cancelled, rescheduled }

class DonorAppointmentItem {
  final String id;
  final String centerName;
  final String address;
  DateTime dateTime;
  final int availableSlots;
  DonorAppointmentStatus status;
  final String notes;

  DonorAppointmentItem({
    required this.id,
    required this.centerName,
    required this.address,
    required this.dateTime,
    required this.availableSlots,
    this.status = DonorAppointmentStatus.upcoming,
    required this.notes,
  });
}

class DonorCampItem {
  final String id;
  final String campName;
  final String organizer;
  final String date;
  final String time;
  final String location;
  final double distanceKm;
  final int availableSlots;
  final String description;
  bool isRegistered;
  bool hasReminder;

  DonorCampItem({
    required this.id,
    required this.campName,
    required this.organizer,
    required this.date,
    required this.time,
    required this.location,
    required this.distanceKm,
    required this.availableSlots,
    required this.description,
    this.isRegistered = false,
    this.hasReminder = false,
  });
}

class DonorHistoryRecord {
  final String id;
  final DateTime donationDate;
  final String donationCenter;
  final BloodType bloodType;
  final int unitsDonated;
  final String status; // 'Successful', 'Deferred'
  final String appointmentRef;
  final String certificateId;
  final String recipientName;
  final int recipientAge;
  final String recipientGender;
  final BloodType recipientBloodType;
  final String recipientHospital;
  final String recipientWard;
  final String doctorInCharge;
  final DateTime transfusionDate;
  final String transfusionStatus;
  final String impactStory;
  final String recipientThankYouNote;
  final String receiptNumber;
  final String bloodBagNumber;
  final String hemoglobin;
  final String bloodPressure;
  final String pulse;
  final String donationType;
  final String verifiedBy;

  DonorHistoryRecord({
    required this.id,
    required this.donationDate,
    required this.donationCenter,
    required this.bloodType,
    required this.unitsDonated,
    required this.status,
    required this.appointmentRef,
    required this.certificateId,
    this.recipientName = 'Aarav Sharma',
    this.recipientAge = 32,
    this.recipientGender = 'Male',
    BloodType? recipientBloodType,
    this.recipientHospital = 'Apollo Multi-Specialty Hospital, Jubilee Hills',
    this.recipientWard = 'Emergency & Trauma ICU (Bed #08)',
    this.doctorInCharge = 'Dr. Radhika Menon, MD (Transfusion Medicine)',
    DateTime? transfusionDate,
    this.transfusionStatus = 'Transfusion Verified & Completed',
    this.impactStory = 'Your 1 unit of whole blood was matched and successfully transfused during emergency cardiac surgery, helping save a critical life.',
    this.recipientThankYouNote = 'Words cannot express my family’s gratitude. Your selfless donation gave me a second chance at life!',
    this.receiptNumber = 'VP-RCPT-2024-99120',
    this.bloodBagNumber = 'VP-BAG-88219-IND',
    this.hemoglobin = '14.2 g/dL',
    this.bloodPressure = '120/80 mmHg',
    this.pulse = '72 bpm',
    this.donationType = 'Whole Blood (450 ml)',
    this.verifiedBy = 'National Blood Transfusion Council (NBTC) & LifeDrop Verification Registry',
  })  : recipientBloodType = recipientBloodType ?? bloodType,
        transfusionDate = transfusionDate ?? donationDate.add(const Duration(days: 2));
}

class DonorTimelineItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category; // 'donation', 'appointment', 'emergency', 'profile', 'camp', 'eligibility'

  DonorTimelineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
  });
}

class DonorNotificationItem {
  final String id;
  final String type; // 'emergency', 'match', 'reminder', 'eligibility', 'camp', 'thankyou', 'system'
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  DonorNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class DonorCertificateModel {
  String certificateId;
  String donorName;
  String bloodGroup;
  String issueDate;
  int unitsDonated;
  String centerName;
  String customTitle;
  String certificateTheme; // 'Gold Royal', 'Sapphire Clinical', 'Emerald Vitality', 'Platinum Minimal'
  String customPledgeMessage;
  String signatureTitle;
  bool includeQrVerification;
  bool includeWatermark;

  DonorCertificateModel({
    required this.certificateId,
    required this.donorName,
    required this.bloodGroup,
    required this.issueDate,
    required this.unitsDonated,
    required this.centerName,
    this.customTitle = 'Certificate of Humanitarian Lifesaver',
    this.certificateTheme = 'Gold Royal',
    this.customPledgeMessage = 'In profound recognition of selfless blood donation, bestowing the precious gift of life.',
    this.signatureTitle = 'Chief Medical Director, Regional Transfusion Council',
    this.includeQrVerification = true,
    this.includeWatermark = true,
  });
}

class DonorActivenessSetting {
  String frequencyPlan; // 'Standard (Every 90 Days)', 'High-Impact (Every 60 Days)', 'Bi-Annual Hero (Twice a year)', 'On-Demand Emergency Only', 'Weekend Warrior'
  bool allowEmergencySosBroadcasts;
  bool allowMatchingRadiusExpansions;
  double customRadiusKm;
  int yearlyPledgeUnits;
  List<String> preferredDonationDays;
  String reminderFrequency;
  String personalMotto;

  DonorActivenessSetting({
    this.frequencyPlan = 'Standard (Every 90 Days)',
    this.allowEmergencySosBroadcasts = true,
    this.allowMatchingRadiusExpansions = true,
    this.customRadiusKm = 25.0,
    this.yearlyPledgeUnits = 4,
    this.preferredDonationDays = const ['Saturday', 'Sunday', 'Wednesday'],
    this.reminderFrequency = '3 Days Before',
    this.personalMotto = 'Ready whenever a life is on the line.',
  });
}

