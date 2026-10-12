import 'package:flutter/material.dart';
import '../models/blood_type.dart';
import '../models/user_model.dart';
import '../models/blood_request.dart';
import '../models/blood_bank.dart';
import '../models/patient_models.dart';
import '../models/hospital_models.dart';
import '../models/donor_models.dart';
import '../models/blood_bank_models.dart';

class MockDataService extends ChangeNotifier {
  // Current General User
  UserModel currentUser = UserModel(
    id: 'user_001',
    name: 'Pooja Sharma',
    role: UserRole.patient,
    bloodType: BloodType.oPos,
    location: 'Madhapur, Hitec City, Hyderabad, Telangana',
    donationCount: 2,
  );

  /// Synchronize logged-in or newly registered user details into the active dashboard models
  void syncWithUser(UserModel user) {
    currentUser = user;
    final cleanName = user.name.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '.');
    final generatedEmail = '$cleanName@vitalpulse.in';

    switch (user.role) {
      case UserRole.donor:
        donorProfile = donorProfile.copyWith(
          name: user.name,
          bloodType: user.bloodType ?? donorProfile.bloodType,
          phone: (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : donorProfile.phone,
          email: generatedEmail,
          location: (user.location != null && user.location!.isNotEmpty) ? user.location! : donorProfile.location,
          totalDonations: user.donationCount > 0 ? user.donationCount : donorProfile.totalDonations,
        );
        donorCertificate.donorName = user.name;
        donorCertificate.bloodGroup = '${(user.bloodType ?? donorProfile.bloodType).label} (Voluntary Lifesaver)';
        donorCertificate.centerName = (user.location != null && user.location!.isNotEmpty) ? user.location! : donorProfile.location;
        donorCertificate.unitsDonated = user.donationCount > 0 ? user.donationCount : donorProfile.totalUnitsDonated;
        break;
      case UserRole.patient:
        patientProfile = patientProfile.copyWith(
          name: user.name,
          bloodType: user.bloodType ?? patientProfile.bloodType,
          phone: (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : patientProfile.phone,
          email: generatedEmail,
          location: (user.location != null && user.location!.isNotEmpty) ? user.location! : patientProfile.location,
        );
        break;
      case UserRole.hospital:
        break;
      case UserRole.bloodBank:
        bankProfile = BankFacilityProfile(
          name: user.name,
          licenseNumber: bankProfile.licenseNumber,
          address: (user.location != null && user.location!.isNotEmpty) ? user.location! : bankProfile.address,
          phone: (user.phone != null && user.phone!.isNotEmpty) ? user.phone! : bankProfile.phone,
          emergencyHotline: bankProfile.emergencyHotline,
          email: generatedEmail,
          operatingHours: bankProfile.operatingHours,
          storageCapacity: bankProfile.storageCapacity,
          availableServices: bankProfile.availableServices,
          accreditation: bankProfile.accreditation,
        );
        break;
      case UserRole.admin:
        break;
    }
    notifyListeners();
  }

  // 1. Patient Profile
  PatientProfile patientProfile = PatientProfile(
    name: 'Pooja Sharma',
    bloodType: BloodType.oPos,
    phone: '+91 98490 23489',
    email: 'pooja.sharma@vitalpulse.in',
    location: 'Flat 402, Sai Sagar Enclave, Madhapur, Hyderabad, Telangana',
    emergencyContactName: 'Rahul Sharma',
    emergencyContactRelation: 'Spouse',
    emergencyContactPhone: '+91 98765 43210',
  );

  // 2. Active Emergency SOS
  EmergencySOSRequest? activeEmergencySOS = EmergencySOSRequest(
    id: 'SOS-9482',
    hospital: 'Apollo Hospitals & Heart Institute (Trauma Center)',
    location: 'Road No. 72, Jubilee Hills, Hyderabad, Telangana',
    bloodType: BloodType.oNeg,
    unitsRequired: 2,
    status: PatientTrackingStatus.searching,
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    matchedDonorsCount: 14,
    nearbyBanksCount: 4,
    notes: 'Emergency surgery preparation for polytrauma after Outer Ring Road accident. Verified critical.',
  );

  // 3. Patient Blood Requests
  List<PatientBloodRequestItem> patientRequests = [
    PatientBloodRequestItem(
      id: 'REQ-7821',
      bloodType: BloodType.oPos,
      units: 2,
      hospital: 'Apollo Hospitals, Jubilee Hills, Hyderabad',
      requiredDateTime: DateTime.now().add(const Duration(hours: 6)),
      priority: RequestPriority.urgent,
      notes: 'Scheduled platelet transfusion therapy for dengue thrombocytopenia.',
      status: PatientTrackingStatus.donorMatched,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchedDonorName: 'Dr. Ananya Reddy (O+)',
    ),
    PatientBloodRequestItem(
      id: 'REQ-5512',
      bloodType: BloodType.oNeg,
      units: 1,
      hospital: 'KIMS Hospitals, Minister Road, Secunderabad',
      requiredDateTime: DateTime.now().subtract(const Duration(days: 3)),
      priority: RequestPriority.normal,
      notes: 'Routine packed red cell replacement.',
      status: PatientTrackingStatus.fulfilled,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      matchedDonorName: 'Vikram Malhotra (O-)',
    ),
    PatientBloodRequestItem(
      id: 'REQ-4390',
      bloodType: BloodType.oPos,
      units: 3,
      hospital: "Nizam's Institute of Medical Sciences (NIMS), Hyderabad",
      requiredDateTime: DateTime.now().subtract(const Duration(days: 12)),
      priority: RequestPriority.emergency,
      notes: 'Emergency surgical reserve for cardiac bypass.',
      status: PatientTrackingStatus.fulfilled,
      createdAt: DateTime.now().subtract(const Duration(days: 13)),
      matchedDonorName: 'Karthik Subramanian (O-)',
    ),
  ];

  // 4. Smart Donor Matching
  List<DonorMatch> smartDonors = [
    DonorMatch(
      id: 'dnr_01',
      name: 'Vikram Malhotra',
      bloodType: BloodType.oNeg,
      distanceKm: 1.2,
      availability: 'Available Now',
      eligibility: 'Eligible - Last donated 4 months ago (Verified Gold)',
      matchPercentage: 99,
      phone: '+91 98480 12345',
      city: 'Gachibowli Financial District, Hyderabad',
    ),
    DonorMatch(
      id: 'dnr_02',
      name: 'Dr. Ananya Reddy',
      bloodType: BloodType.oPos,
      distanceKm: 2.1,
      availability: 'Available Now',
      eligibility: 'Verified Regular Donor (14 lifetime donations)',
      matchPercentage: 96,
      phone: '+91 99590 67890',
      city: 'Jubilee Hills Road No. 36, Hyderabad',
    ),
    DonorMatch(
      id: 'dnr_03',
      name: 'Karthik Subramanian',
      bloodType: BloodType.oNeg,
      distanceKm: 2.8,
      availability: 'Available Now',
      eligibility: 'Rare Blood Registry Certified - Ready to dispatch',
      matchPercentage: 95,
      phone: '+91 94401 23456',
      city: 'Kondapur Near Botanical Garden, Hyderabad',
    ),
    DonorMatch(
      id: 'dnr_04',
      name: 'Neha Iyer',
      bloodType: BloodType.oPos,
      distanceKm: 3.5,
      availability: 'On Call',
      eligibility: 'Eligible - Health check confirmed last week',
      matchPercentage: 91,
      phone: '+91 97000 54321',
      city: 'Banjara Hills Road No. 12, Hyderabad',
    ),
    DonorMatch(
      id: 'dnr_05',
      name: 'Dr. Rajesh V. Verma',
      bloodType: BloodType.oNeg,
      distanceKm: 4.2,
      availability: 'Standby',
      eligibility: 'Resident Physician & Registered Donor',
      matchPercentage: 88,
      phone: '+91 98888 11223',
      city: 'Hitec City Cyber Towers, Hyderabad',
    ),
    DonorMatch(
      id: 'dnr_06',
      name: 'Suresh Nambiar',
      bloodType: BloodType.aPos,
      distanceKm: 5.6,
      availability: 'Available Now',
      eligibility: 'Eligible Platelet & Whole Blood Donor',
      matchPercentage: 82,
      phone: '+91 93910 88776',
      city: 'Begumpet Airport Road, Secunderabad',
    ),
  ];

  // 5. Nearby Facilities (Indian Blood Banks, Hospitals, Mega Camps)
  List<NearbyFacility> nearbyFacilities = [
    NearbyFacility(
      id: 'fac_01',
      name: 'Chiranjeevi Blood Centre & Eye Bank',
      type: FacilityType.bloodBank,
      address: 'Road No 1, Jubilee Hills, Hyderabad, Telangana',
      distanceKm: 1.4,
      phone: '+91 40 2355 5005',
      city: 'Hyderabad',
      state: 'Telangana',
      landmark: 'Beside Jubilee Hills Check Post Metro Station',
      latitude: 17.4325,
      longitude: 78.4071,
      stock: {
        BloodType.oPos: 48,
        BloodType.oNeg: 12,
        BloodType.aPos: 54,
        BloodType.aNeg: 14,
        BloodType.bPos: 36,
        BloodType.bNeg: 9,
        BloodType.abPos: 24,
        BloodType.abNeg: 6,
      },
      rating: 4.9,
      openHours: 'Open 24/7 (Emergency Dispatch Ready)',
      directionsSteps: [
        'Head east from Madhapur on Hitec City Main Road (800 m)',
        'Cross Durgam Cheruvu Cable Bridge towards Jubilee Hills (1.8 km)',
        'Turn left at Road No. 36 junction onto Road No. 1 (1.1 km)',
        'Arrive at Chiranjeevi Blood Centre on your right (300 m)',
      ],
    ),
    NearbyFacility(
      id: 'fac_02',
      name: 'Apollo Hospitals Level-1 Trauma Center',
      type: FacilityType.hospital,
      address: 'Road No 72, Film Nagar, Jubilee Hills, Hyderabad',
      distanceKm: 1.8,
      phone: '+91 40 2360 7777',
      city: 'Hyderabad',
      state: 'Telangana',
      landmark: 'Opposite Film Nagar Cultural Center',
      latitude: 17.4156,
      longitude: 78.4124,
      stock: {
        BloodType.oPos: 32,
        BloodType.oNeg: 6,
        BloodType.aPos: 24,
        BloodType.bPos: 18,
      },
      rating: 4.8,
      openHours: '24/7 NABH & JCI Accredited Trauma Care',
      directionsSteps: [
        'Proceed south on Inorbit Mall Road towards Durgam Cheruvu (1.2 km)',
        'Take Outer Ring Road feeder route towards Jubilee Hills (1.5 km)',
        'Turn right at Film Nagar Gate towards Apollo Emergency Wing (600 m)',
      ],
    ),
    NearbyFacility(
      id: 'fac_03',
      name: 'Rotary Central Blood Bank & Research Institute',
      type: FacilityType.bloodBank,
      address: 'Lady Curzon Road, Shivajinagar, Bengaluru, Karnataka',
      distanceKm: 2.8,
      phone: '+91 80 2286 0033',
      city: 'Bengaluru',
      state: 'Karnataka',
      landmark: 'Near Bowring & Lady Curzon Hospital',
      latitude: 12.9833,
      longitude: 77.6000,
      stock: {
        BloodType.oPos: 35,
        BloodType.oNeg: 8,
        BloodType.aPos: 40,
        BloodType.bPos: 22,
        BloodType.abPos: 14,
      },
      rating: 4.8,
      openHours: 'Daily 7:00 AM – 11:00 PM',
      directionsSteps: [
        'Head south on MG Road towards Infantry Road (1.4 km)',
        'Turn onto Lady Curzon Road towards Bowring Hospital (800 m)',
        'Arrive at Rotary Central Blood Bank entrance (200 m)',
      ],
    ),
    NearbyFacility(
      id: 'fac_04',
      name: 'Indian Red Cross Society National Headquarters',
      type: FacilityType.bloodBank,
      address: '1 Red Cross Road, New Delhi, Delhi',
      distanceKm: 3.6,
      phone: '+91 11 2371 6441',
      city: 'New Delhi',
      state: 'Delhi NCR',
      landmark: 'Near Parliament House & Rafi Marg',
      latitude: 28.6219,
      longitude: 77.2100,
      stock: {
        BloodType.oPos: 80,
        BloodType.oNeg: 18,
        BloodType.aPos: 65,
        BloodType.bPos: 45,
        BloodType.abPos: 30,
        BloodType.abNeg: 11,
      },
      rating: 5.0,
      openHours: 'Open 24/7 (National Emergency Blood Network)',
      directionsSteps: [
        'Head south along Janpath towards Rafi Marg (1.5 km)',
        'Take roundabout exit onto Red Cross Road (800 m)',
        'Arrive at National Blood Transfusion Bank (300 m)',
      ],
    ),
    NearbyFacility(
      id: 'fac_05',
      name: 'State Blood Transfusion Council (KEM Hospital)',
      type: FacilityType.hospital,
      address: 'Acharya Donde Marg, Parel, Mumbai, Maharashtra',
      distanceKm: 2.1,
      phone: '+91 22 2410 7000',
      city: 'Mumbai',
      state: 'Maharashtra',
      landmark: 'Opposite Parel Central Railway Station',
      latitude: 19.0028,
      longitude: 72.8423,
      stock: {
        BloodType.oPos: 28,
        BloodType.oNeg: 5,
        BloodType.aPos: 30,
        BloodType.bPos: 24,
      },
      rating: 4.7,
      openHours: '24/7 Emergency & Inpatient Trauma Care',
      directionsSteps: [
        'Head south on Dr. Ambedkar Road from Dadar (1.2 km)',
        'Turn onto Acharya Donde Marg towards KEM Hospital (600 m)',
        'Enter through Main Emergency Triage & Blood Bank (200 m)',
      ],
    ),
    NearbyFacility(
      id: 'fac_06',
      name: 'Hitec City Cyber Towers Mega Blood Donation Camp',
      type: FacilityType.donationCamp,
      address: 'Cyber Gateway Concourse, Hitec City, Hyderabad',
      distanceKm: 0.9,
      phone: '+91 40 6676 2000',
      city: 'Hyderabad',
      state: 'Telangana',
      landmark: 'Main Cyber Towers Circle',
      latitude: 17.4504,
      longitude: 78.3808,
      stock: {},
      rating: 4.9,
      openHours: '9:00 AM – 6:30 PM',
      eventDate: 'Tomorrow & Friday',
      directionsSteps: [
        'Proceed along Hitec City Main Road towards Cyber Towers (600 m)',
        'Enter Cyber Gateway pedestrian concourse area (300 m)',
      ],
    ),
    NearbyFacility(
      id: 'fac_07',
      name: 'Manyata Tech Park Lifesavers Blood Camp',
      type: FacilityType.donationCamp,
      address: 'Outer Ring Road, Nagavara, Bengaluru, Karnataka',
      distanceKm: 3.8,
      phone: '+91 80 4179 0000',
      city: 'Bengaluru',
      state: 'Karnataka',
      landmark: 'Block G3 Central Amphitheatre',
      latitude: 13.0450,
      longitude: 77.6200,
      stock: {},
      rating: 4.8,
      openHours: '10:00 AM – 5:30 PM',
      eventDate: 'This Weekend (Sat - Sun)',
      directionsSteps: [
        'Take Hebbal Outer Ring Road towards Nagavara Junction (2.2 km)',
        'Take Manyata Tech Park Gate 1 entrance (800 m)',
      ],
    ),
  ];

  // 5b. Live Indian Hospital Directory
  List<IndianHospital> indianHospitals = [
    IndianHospital(
      id: 'hosp_01',
      name: 'Apollo Hospitals, Jubilee Hills',
      city: 'Hyderabad',
      state: 'Telangana',
      address: 'Road No 72, Film Nagar, Jubilee Hills, Hyderabad 500033',
      phone: '+91 40 2360 7777',
      website: 'www.apollohospitals.com',
      latitude: 17.4156,
      longitude: 78.4124,
      rating: 4.8,
      totalBeds: 550,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      specialities: ['Trauma Care', 'Cardiology', 'Oncology', 'Organ Transplant', 'Neurosurgery'],
      bloodStock: {
        BloodType.oPos: 42, BloodType.oNeg: 8, BloodType.aPos: 36,
        BloodType.aNeg: 6, BloodType.bPos: 28, BloodType.bNeg: 4,
        BloodType.abPos: 18, BloodType.abNeg: 3,
      },
      openHours: '24/7 NABH & JCI Accredited',
      landmark: 'Opposite Film Nagar Cultural Center',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_02',
      name: "Nizam's Institute of Medical Sciences (NIMS)",
      city: 'Hyderabad',
      state: 'Telangana',
      address: 'Punjagutta Main Road, Hyderabad 500082',
      phone: '+91 40 2348 9000',
      website: 'www.nims.edu.in',
      latitude: 17.4292,
      longitude: 78.4459,
      rating: 4.6,
      totalBeds: 1600,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      isGovernment: true,
      specialities: ['Cardiology', 'Nephrology', 'Neurosurgery', 'Gastroenterology', 'Burns & Plastic Surgery'],
      bloodStock: {
        BloodType.oPos: 65, BloodType.oNeg: 14, BloodType.aPos: 52,
        BloodType.aNeg: 10, BloodType.bPos: 44, BloodType.bNeg: 8,
        BloodType.abPos: 26, BloodType.abNeg: 5,
      },
      openHours: '24/7 Government Super-Speciality',
      landmark: 'Near Punjagutta X Roads',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_03',
      name: 'AIIMS New Delhi',
      city: 'New Delhi',
      state: 'Delhi NCR',
      address: 'Sri Aurobindo Marg, Ansari Nagar, New Delhi 110029',
      phone: '+91 11 2658 8500',
      website: 'www.aiims.edu',
      latitude: 28.5672,
      longitude: 77.2100,
      rating: 4.9,
      totalBeds: 2478,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      isGovernment: true,
      specialities: ['All Specialities', 'Trauma', 'Oncology', 'Cardiothoracic', 'Organ Transplant', 'Research'],
      bloodStock: {
        BloodType.oPos: 120, BloodType.oNeg: 30, BloodType.aPos: 90,
        BloodType.aNeg: 22, BloodType.bPos: 75, BloodType.bNeg: 16,
        BloodType.abPos: 45, BloodType.abNeg: 12,
      },
      openHours: '24/7 National Institute of Excellence',
      landmark: 'Near IIT Delhi & Hauz Khas',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_04',
      name: 'Tata Memorial Hospital',
      city: 'Mumbai',
      state: 'Maharashtra',
      address: 'Dr E Borges Road, Parel, Mumbai 400012',
      phone: '+91 22 2417 7000',
      website: 'www.tmc.gov.in',
      latitude: 19.0048,
      longitude: 72.8435,
      rating: 4.8,
      totalBeds: 629,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      isGovernment: true,
      specialities: ['Oncology', 'Radiation Therapy', 'Surgical Oncology', 'Bone Marrow Transplant', 'Pediatric Oncology'],
      bloodStock: {
        BloodType.oPos: 55, BloodType.oNeg: 12, BloodType.aPos: 48,
        BloodType.aNeg: 8, BloodType.bPos: 38, BloodType.bNeg: 7,
        BloodType.abPos: 22, BloodType.abNeg: 4,
      },
      openHours: '24/7 Cancer Research & Treatment',
      landmark: 'Near Parel Railway Station',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_05',
      name: 'CMC Vellore',
      city: 'Vellore',
      state: 'Tamil Nadu',
      address: 'Ida Scudder Road, Vellore 632004',
      phone: '+91 416 228 1000',
      website: 'www.cmch-vellore.edu',
      latitude: 12.9249,
      longitude: 79.1325,
      rating: 4.9,
      totalBeds: 2688,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      specialities: ['Multi-Organ Transplant', 'Haematology', 'Nephrology', 'Neurology', 'Cardiology', 'Pediatrics'],
      bloodStock: {
        BloodType.oPos: 88, BloodType.oNeg: 20, BloodType.aPos: 70,
        BloodType.aNeg: 15, BloodType.bPos: 55, BloodType.bNeg: 11,
        BloodType.abPos: 34, BloodType.abNeg: 8,
      },
      openHours: '24/7 NABH Accredited Teaching Hospital',
      landmark: 'Ida Scudder Road, Town Campus',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_06',
      name: 'Narayana Health City',
      city: 'Bengaluru',
      state: 'Karnataka',
      address: 'Bommasandra Industrial Area, Anekal Taluk, Bengaluru 560099',
      phone: '+91 80 7122 2222',
      website: 'www.narayanahealth.org',
      latitude: 12.8089,
      longitude: 77.6784,
      rating: 4.7,
      totalBeds: 3200,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      specialities: ['Cardiac Surgery', 'Pediatric Cardiac', 'Nephrology', 'Neurosurgery', 'Organ Transplant'],
      bloodStock: {
        BloodType.oPos: 72, BloodType.oNeg: 16, BloodType.aPos: 60,
        BloodType.aNeg: 12, BloodType.bPos: 48, BloodType.bNeg: 10,
        BloodType.abPos: 30, BloodType.abNeg: 6,
      },
      openHours: '24/7 Multi-Specialty Health City',
      landmark: 'Hosur Road, Bommasandra',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_07',
      name: 'PGIMER Chandigarh',
      city: 'Chandigarh',
      state: 'Chandigarh',
      address: 'Sector 12, Chandigarh 160012',
      phone: '+91 172 274 6018',
      website: 'www.pgimer.edu.in',
      latitude: 30.7636,
      longitude: 76.7747,
      rating: 4.8,
      totalBeds: 2068,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      isGovernment: true,
      specialities: ['Hepatology', 'Gastroenterology', 'Ophthalmology', 'Orthopedics', 'Trauma', 'Nephrology'],
      bloodStock: {
        BloodType.oPos: 95, BloodType.oNeg: 22, BloodType.aPos: 78,
        BloodType.aNeg: 16, BloodType.bPos: 62, BloodType.bNeg: 13,
        BloodType.abPos: 38, BloodType.abNeg: 9,
      },
      openHours: '24/7 Government Institute of National Importance',
      landmark: 'Sector 12, Near Rock Garden',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_08',
      name: 'KIMS Hospitals',
      city: 'Hyderabad',
      state: 'Telangana',
      address: '1-8-31/1, Minister Road, Secunderabad 500003',
      phone: '+91 40 4488 5000',
      website: 'www.kimshospitals.com',
      latitude: 17.4399,
      longitude: 78.4983,
      rating: 4.5,
      totalBeds: 1000,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      specialities: ['Cardiology', 'Nephrology', 'Orthopedics', 'Gastroenterology', 'Pulmonology'],
      bloodStock: {
        BloodType.oPos: 38, BloodType.oNeg: 6, BloodType.aPos: 30,
        BloodType.aNeg: 5, BloodType.bPos: 24, BloodType.bNeg: 4,
        BloodType.abPos: 16, BloodType.abNeg: 3,
      },
      openHours: '24/7 Multi-Specialty',
      landmark: 'Near Secunderabad Railway Station',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_09',
      name: 'Kokilaben Dhirubhai Ambani Hospital',
      city: 'Mumbai',
      state: 'Maharashtra',
      address: 'Rao Saheb Achutrao Patwardhan Marg, Four Bungalows, Andheri (W), Mumbai 400053',
      phone: '+91 22 3066 6666',
      website: 'www.kokilabenhospital.com',
      latitude: 19.1190,
      longitude: 72.8289,
      rating: 4.7,
      totalBeds: 750,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      specialities: ['Robotic Surgery', 'Oncology', 'Neurosciences', 'Cardiac Sciences', 'Organ Transplant'],
      bloodStock: {
        BloodType.oPos: 44, BloodType.oNeg: 9, BloodType.aPos: 38,
        BloodType.aNeg: 7, BloodType.bPos: 30, BloodType.bNeg: 5,
        BloodType.abPos: 20, BloodType.abNeg: 4,
      },
      openHours: '24/7 Super-Specialty',
      landmark: 'Four Bungalows, Andheri West',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_10',
      name: 'SSKM Hospital (IPGMER)',
      city: 'Kolkata',
      state: 'West Bengal',
      address: '244 AJC Bose Road, Kolkata 700020',
      phone: '+91 33 2223 4567',
      website: 'www.ipgmer.gov.in',
      latitude: 22.5362,
      longitude: 88.3490,
      rating: 4.4,
      totalBeds: 1775,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      isGovernment: true,
      specialities: ['General Medicine', 'Surgery', 'Pediatrics', 'Orthopedics', 'ENT', 'Ophthalmology'],
      bloodStock: {
        BloodType.oPos: 52, BloodType.oNeg: 10, BloodType.aPos: 42,
        BloodType.aNeg: 8, BloodType.bPos: 36, BloodType.bNeg: 6,
        BloodType.abPos: 22, BloodType.abNeg: 4,
      },
      openHours: '24/7 Government Teaching Hospital',
      landmark: 'Near Bhowanipore, AJC Bose Road',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_11',
      name: 'SGPGI Lucknow',
      city: 'Lucknow',
      state: 'Uttar Pradesh',
      address: 'Rae Bareli Road, Lucknow 226014',
      phone: '+91 522 266 8700',
      website: 'www.sgpgi.ac.in',
      latitude: 26.7307,
      longitude: 80.9853,
      rating: 4.6,
      totalBeds: 1500,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      isGovernment: true,
      specialities: ['Gastroenterology', 'Endocrinology', 'Immunology', 'Nephrology', 'Hepatology'],
      bloodStock: {
        BloodType.oPos: 60, BloodType.oNeg: 13, BloodType.aPos: 48,
        BloodType.aNeg: 9, BloodType.bPos: 40, BloodType.bNeg: 8,
        BloodType.abPos: 24, BloodType.abNeg: 5,
      },
      openHours: '24/7 Government Post-Graduate Institute',
      landmark: 'Rae Bareli Road, Near Munshipulia',
      tier: 'Tier-1',
    ),
    IndianHospital(
      id: 'hosp_12',
      name: 'Sterling Hospital',
      city: 'Ahmedabad',
      state: 'Gujarat',
      address: 'Off Gurukul Road, Memnagar, Ahmedabad 380052',
      phone: '+91 79 4000 1234',
      website: 'www.sterlinghospitals.com',
      latitude: 23.0425,
      longitude: 72.5336,
      rating: 4.5,
      totalBeds: 400,
      hasBloodBank: true,
      has24x7Emergency: true,
      isNABHAccredited: true,
      specialities: ['Cardiac Sciences', 'Joint Replacement', 'Urology', 'Neurology', 'Bariatric Surgery'],
      bloodStock: {
        BloodType.oPos: 32, BloodType.oNeg: 6, BloodType.aPos: 26,
        BloodType.aNeg: 4, BloodType.bPos: 20, BloodType.bNeg: 3,
        BloodType.abPos: 14, BloodType.abNeg: 2,
      },
      openHours: '24/7 Multi-Specialty',
      landmark: 'Near Gujarat University, Memnagar',
      tier: 'Tier-2',
    ),
  ];

  // 6. Notifications
  List<PatientNotification> notifications = [
    PatientNotification(
      id: 'notif_01',
      type: 'donor_matched',
      title: 'Compatible Donor Matched!',
      message: 'Vikram Malhotra (O-) accepted your emergency request #SOS-9482. Transit time ~11 min via Outer Ring Road.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      isRead: false,
    ),
    PatientNotification(
      id: 'notif_02',
      type: 'status_changed',
      title: 'Blood Units Reserved',
      message: 'Chiranjeevi Blood Centre reserved 2 units of O+ blood for Request #REQ-7821.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    PatientNotification(
      id: 'notif_03',
      type: 'blood_found',
      title: 'Fresh Stock Available Nearby',
      message: 'Apollo Hospitals Jubilee Hills received 6 fresh units of O- blood (1.8 km away).',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    PatientNotification(
      id: 'notif_04',
      type: 'emergency_response',
      title: 'Emergency SOS Broadcast Active',
      message: 'Broadcasted to 14 verified donors and 4 accredited blood centers across Hyderabad Hitec corridor.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
    ),
    PatientNotification(
      id: 'notif_05',
      type: 'reminder',
      title: 'Transfusion Appointment Reminder',
      message: 'Upcoming transfusion session at Apollo Hospitals Jubilee Hills tomorrow at 10:30 AM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
  ];

  // 7. Appointments
  List<PatientAppointment> appointments = [
    PatientAppointment(
      id: 'apt_01',
      facilityName: 'Apollo Hospitals, Jubilee Hills, Hyderabad',
      doctorOrDept: 'Hematology Department - Dr. Srinivas Rao',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      purpose: 'Platelet Infusion & Blood Count Monitoring',
      status: 'Confirmed',
    ),
    PatientAppointment(
      id: 'apt_02',
      facilityName: 'Chiranjeevi Blood Centre, Jubilee Hills',
      doctorOrDept: 'Transfusion Verification Unit #2',
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 4)),
      purpose: 'Compatibility Cross-match & Reserve Verification',
      status: 'Scheduled',
    ),
    PatientAppointment(
      id: 'apt_03',
      facilityName: "Nizam's Institute of Medical Sciences (NIMS), Hyderabad",
      doctorOrDept: 'Outpatient Hematology Clinic',
      dateTime: DateTime.now().subtract(const Duration(days: 8)),
      purpose: 'Post-transfusion Hemoglobin Evaluation',
      status: 'Completed',
    ),
  ];

  // 8. Search History
  List<SearchHistoryItem> searchHistory = [
    SearchHistoryItem(
      id: 'sh_01',
      bloodType: BloodType.oNeg,
      locationQuery: 'Hitec City, Hyderabad',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      foundUnits: 34,
    ),
    SearchHistoryItem(
      id: 'sh_02',
      bloodType: BloodType.oPos,
      locationQuery: 'Jubilee Hills Apollo Area',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      foundUnits: 72,
    ),
    SearchHistoryItem(
      id: 'sh_03',
      bloodType: BloodType.abNeg,
      locationQuery: 'Secunderabad KIMS Zone',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      foundUnits: 15,
    ),
  ];

  // 9. Notification & Privacy Settings
  bool notifySms = true;
  bool notifyPush = true;
  bool notifyEmergencySiren = true;
  bool notifyEmail = false;
  bool shareLocationForMatching = true;
  bool autoBroadcastEmergency = true;
  String selectedTheme = 'Pure White iOS (Default)';
  String selectedLanguage = 'English (India)';
  ThemeMode appThemeMode = ThemeMode.light;
  double sosRadiusKm = 15.0;

  // Legacy compatibility mock data
  List<BloodRequest> get activeRequests => [
    BloodRequest(
      id: 'req_001',
      patientId: 'pat_001',
      patientName: patientProfile.name,
      requestedType: patientProfile.bloodType,
      unitsRequired: 2,
      location: patientProfile.location,
      urgency: UrgencyLevel.critical,
      status: RequestStatus.pending,
      requiredBy: DateTime.now().add(const Duration(hours: 4)),
      notes: 'Emergency platelet requirement for dengue fever',
    )
  ];

  List<BloodBank> get bloodBanks => [
    BloodBank(
      id: 'bank_001',
      name: 'Chiranjeevi Blood Centre & Eye Bank',
      location: 'Road No 1, Jubilee Hills, Hyderabad',
      inventory: {
        BloodType.aPos: 54,
        BloodType.oPos: 48,
        BloodType.oNeg: 12,
        BloodType.bPos: 36,
        BloodType.abPos: 24,
      },
    ),
    BloodBank(
      id: 'bank_002',
      name: 'Apollo Hospitals Blood Bank',
      location: 'Road No 72, Jubilee Hills, Hyderabad',
      inventory: {
        BloodType.aPos: 38,
        BloodType.oPos: 42,
        BloodType.oNeg: 6,
        BloodType.bPos: 28,
        BloodType.abPos: 16,
      },
    ),
    BloodBank(
      id: 'bank_003',
      name: 'Rotary Central Blood Bank',
      location: 'Shivajinagar, Bengaluru, Karnataka',
      inventory: {
        BloodType.aPos: 40,
        BloodType.oPos: 35,
        BloodType.oNeg: 8,
        BloodType.bPos: 22,
        BloodType.abPos: 14,
      },
    ),
    BloodBank(
      id: 'bank_004',
      name: 'Indian Red Cross Society',
      location: '1 Red Cross Road, New Delhi',
      inventory: {
        BloodType.aPos: 65,
        BloodType.oPos: 80,
        BloodType.oNeg: 18,
        BloodType.bPos: 45,
        BloodType.abPos: 30,
        BloodType.abNeg: 11,
      },
    ),
  ];

  // ================= ACTIONS & METHODS =================

  void updatePatientProfile(PatientProfile updated) {
    patientProfile = updated;
    notifyListeners();
  }

  void triggerEmergencySOS({
    required String hospital,
    required String location,
    required BloodType bloodType,
    required int units,
    String? notes,
  }) {
    final sosId = 'SOS-${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
    activeEmergencySOS = EmergencySOSRequest(
      id: sosId,
      hospital: hospital,
      location: location,
      bloodType: bloodType,
      unitsRequired: units,
      status: PatientTrackingStatus.searching,
      timestamp: DateTime.now(),
      matchedDonorsCount: 14,
      nearbyBanksCount: 4,
      notes: notes,
    );

    // Add immediate high-priority notification
    notifications.insert(
      0,
      PatientNotification(
        id: 'notif_sos_${DateTime.now().millisecondsSinceEpoch}',
        type: 'emergency_response',
        title: 'Emergency SOS Broadcast Dispatched!',
        message: 'Alert sent to nearby donors and emergency blood centers for $units units of ${bloodType.label}. ID: $sosId',
        timestamp: DateTime.now(),
        isRead: false,
      ),
    );

    notifyListeners();
  }

  void cancelEmergencySOS() {
    if (activeEmergencySOS != null) {
      activeEmergencySOS!.status = PatientTrackingStatus.cancelled;
      notifications.insert(
        0,
        PatientNotification(
          id: 'notif_cancel_${DateTime.now().millisecondsSinceEpoch}',
          type: 'status_changed',
          title: 'Emergency SOS Cancelled',
          message: 'The SOS broadcast with ID ${activeEmergencySOS!.id} was cancelled by patient.',
          timestamp: DateTime.now(),
        ),
      );
      activeEmergencySOS = null;
      notifyListeners();
    }
  }

  void advanceSOSStatus() {
    if (activeEmergencySOS == null) return;
    switch (activeEmergencySOS!.status) {
      case PatientTrackingStatus.pending:
        activeEmergencySOS!.status = PatientTrackingStatus.searching;
        break;
      case PatientTrackingStatus.searching:
        activeEmergencySOS!.status = PatientTrackingStatus.donorMatched;
        notifications.insert(
          0,
          PatientNotification(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
            type: 'donor_matched',
            title: 'Emergency Donors Matched!',
            message: 'Donors have accepted the emergency call and are en route.',
            timestamp: DateTime.now(),
          ),
        );
        break;
      case PatientTrackingStatus.donorMatched:
        activeEmergencySOS!.status = PatientTrackingStatus.bloodReserved;
        break;
      case PatientTrackingStatus.bloodReserved:
        activeEmergencySOS!.status = PatientTrackingStatus.fulfilled;
        notifications.insert(
          0,
          PatientNotification(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
            type: 'status_changed',
            title: 'Emergency Blood Delivered & Fulfilled',
            message: 'Blood units successfully delivered to ${activeEmergencySOS!.hospital}.',
            timestamp: DateTime.now(),
          ),
        );
        break;
      case PatientTrackingStatus.fulfilled:
      case PatientTrackingStatus.cancelled:
        break;
    }
    notifyListeners();
  }

  void addPatientBloodRequest(PatientBloodRequestItem request) {
    patientRequests.insert(0, request);

    notifications.insert(
      0,
      PatientNotification(
        id: 'notif_req_${DateTime.now().millisecondsSinceEpoch}',
        type: 'status_changed',
        title: 'New Blood Request Submitted',
        message: 'Request ${request.id} for ${request.units} units of ${request.bloodType.label} is now active.',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void updateRequestStatus(String requestId, PatientTrackingStatus newStatus) {
    final index = patientRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      patientRequests[index].status = newStatus;
      notifications.insert(
        0,
        PatientNotification(
          id: 'notif_update_${DateTime.now().millisecondsSinceEpoch}',
          type: 'status_changed',
          title: 'Request ${patientRequests[index].id} Status Updated',
          message: 'Status changed to: ${newStatus.label}',
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  void markNotificationAsRead(String id) {
    final notif = notifications.firstWhere((n) => n.id == id, orElse: () => notifications.first);
    notif.isRead = true;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void addSearchHistoryItem(BloodType bloodType, String location, int count) {
    searchHistory.insert(
      0,
      SearchHistoryItem(
        id: 'sh_${DateTime.now().millisecondsSinceEpoch}',
        bloodType: bloodType,
        locationQuery: location.isEmpty ? 'Any location' : location,
        timestamp: DateTime.now(),
        foundUnits: count,
      ),
    );
    notifyListeners();
  }

  void bookAppointment({
    required String facilityName,
    required String doctorOrDept,
    required DateTime dateTime,
    required String purpose,
  }) {
    final appointment = PatientAppointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch % 10000}',
      facilityName: facilityName,
      doctorOrDept: doctorOrDept,
      dateTime: dateTime,
      purpose: purpose,
      status: 'Confirmed',
    );
    appointments.insert(0, appointment);
    notifications.insert(
      0,
      PatientNotification(
        id: 'notif_apt_${DateTime.now().millisecondsSinceEpoch}',
        type: 'reminder',
        title: 'Appointment Confirmed',
        message: 'Confirmed at $facilityName on ${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}.',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateSettings({
    bool? sms,
    bool? push,
    bool? siren,
    bool? email,
    bool? shareLoc,
    bool? autoEmergency,
    String? theme,
    String? language,
    ThemeMode? themeMode,
    double? sosRadius,
  }) {
    if (sms != null) notifySms = sms;
    if (push != null) notifyPush = push;
    if (siren != null) notifyEmergencySiren = siren;
    if (email != null) notifyEmail = email;
    if (shareLoc != null) shareLocationForMatching = shareLoc;
    if (autoEmergency != null) autoBroadcastEmergency = autoEmergency;
    if (theme != null) selectedTheme = theme;
    if (language != null) selectedLanguage = language;
    if (themeMode != null) appThemeMode = themeMode;
    if (sosRadius != null) sosRadiusKm = sosRadius;
    notifyListeners();
  }

  // ================= HOSPITAL DASHBOARD STATE & ACTIONS =================

  final String hospitalName = 'Apollo Hospitals & Level-1 Comprehensive Trauma Center';
  final String hospitalLicenseId = 'HOSP-TS-HYD-APO-8821';
  final String hospitalLocation = 'Road No. 72, Film Nagar, Jubilee Hills, Hyderabad, Telangana';
  final String hospitalTraumaLevel = 'NABH & JCI Accredited Comprehensive Level-1 Trauma Care';

  // 1. Blood Inventory (All 8 blood groups)
  final Map<BloodType, HospitalInventoryGroup> hospitalInventory = {
    BloodType.aPos: HospitalInventoryGroup(
      bloodType: BloodType.aPos,
      availableUnits: 24,
      reservedUnits: 4,
      usedUnits: 110,
      expiringUnits: 3,
      minThreshold: 15,
    ),
    BloodType.aNeg: HospitalInventoryGroup(
      bloodType: BloodType.aNeg,
      availableUnits: 7,
      reservedUnits: 2,
      usedUnits: 35,
      expiringUnits: 1,
      minThreshold: 8, // Low Stock!
    ),
    BloodType.bPos: HospitalInventoryGroup(
      bloodType: BloodType.bPos,
      availableUnits: 19,
      reservedUnits: 3,
      usedUnits: 84,
      expiringUnits: 2,
      minThreshold: 12,
    ),
    BloodType.bNeg: HospitalInventoryGroup(
      bloodType: BloodType.bNeg,
      availableUnits: 4,
      reservedUnits: 1,
      usedUnits: 28,
      expiringUnits: 0,
      minThreshold: 6, // Low Stock!
    ),
    BloodType.abPos: HospitalInventoryGroup(
      bloodType: BloodType.abPos,
      availableUnits: 12,
      reservedUnits: 2,
      usedUnits: 40,
      expiringUnits: 1,
      minThreshold: 8,
    ),
    BloodType.abNeg: HospitalInventoryGroup(
      bloodType: BloodType.abNeg,
      availableUnits: 2,
      reservedUnits: 1,
      usedUnits: 16,
      expiringUnits: 0,
      minThreshold: 5, // Critical Alert!
    ),
    BloodType.oPos: HospitalInventoryGroup(
      bloodType: BloodType.oPos,
      availableUnits: 32,
      reservedUnits: 6,
      usedUnits: 185,
      expiringUnits: 4,
      minThreshold: 20,
    ),
    BloodType.oNeg: HospitalInventoryGroup(
      bloodType: BloodType.oNeg,
      availableUnits: 3,
      reservedUnits: 2,
      usedUnits: 94,
      expiringUnits: 1,
      minThreshold: 10, // Critical Alert!
    ),
  };

  // Hospital Overview Metrics Getters
  int get hospitalTotalBloodUnits => hospitalInventory.values.fold(0, (sum, g) => sum + g.availableUnits);
  int get hospitalPendingRequestsCount => hospitalRequests.where((r) => r.status == HospitalRequestStatus.pending || r.status == HospitalRequestStatus.inProgress).length;
  int get hospitalEmergencyRequestsCount => hospitalRequests.where((r) => r.priority == HospitalRequestPriority.emergency && r.status != HospitalRequestStatus.fulfilled && r.status != HospitalRequestStatus.cancelled).length;
  int get hospitalLowStockCount => hospitalInventory.values.where((g) => g.isLowStock).length;
  int get hospitalExpiringUnitsCount => hospitalInventory.values.fold(0, (sum, g) => sum + g.expiringUnits);
  int get hospitalUpcomingAppointmentsCount => hospitalAppointments.where((a) => a.status == HospitalAppointmentStatus.upcoming || a.status == HospitalAppointmentStatus.confirmed).length;

  // 2. Patient Blood Requests Created & Managed by Hospital
  List<HospitalPatientBloodRequest> hospitalRequests = [
    HospitalPatientBloodRequest(
      id: 'HREQ-901',
      patientRefId: 'PAT-1082',
      patientName: 'Vikramaditya Rao',
      departmentOrWard: 'Trauma ICU - Bed 4',
      bloodType: BloodType.oNeg,
      unitsRequired: 3,
      assignedUnits: 1,
      priority: HospitalRequestPriority.emergency,
      requiredDateTime: DateTime.now().add(const Duration(hours: 1)),
      status: HospitalRequestStatus.inProgress,
      clinicalNotes: 'Severe polytrauma from Outer Ring Road collision near Gachibowli. Urgent O- transfusion active.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    HospitalPatientBloodRequest(
      id: 'HREQ-902',
      patientRefId: 'PAT-2931',
      patientName: 'Sunita Deshmukh',
      departmentOrWard: 'Cardiovascular Surgery - OT 3',
      bloodType: BloodType.aPos,
      unitsRequired: 2,
      assignedUnits: 2,
      priority: HospitalRequestPriority.emergency,
      requiredDateTime: DateTime.now().add(const Duration(hours: 2)),
      status: HospitalRequestStatus.reserved,
      clinicalNotes: 'Emergency coronary artery bypass graft (CABG). Units verified in hospital blood bank reserve.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
    HospitalPatientBloodRequest(
      id: 'HREQ-903',
      patientRefId: 'PAT-4419',
      patientName: 'Arjun Nair',
      departmentOrWard: 'Hematology Ward - Bed 12',
      bloodType: BloodType.bNeg,
      unitsRequired: 1,
      assignedUnits: 0,
      priority: HospitalRequestPriority.urgent,
      requiredDateTime: DateTime.now().add(const Duration(hours: 5)),
      status: HospitalRequestStatus.pending,
      clinicalNotes: 'Aplastic anemia with acute hemoglobin drop below 6.8 g/dL.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HospitalPatientBloodRequest(
      id: 'HREQ-904',
      patientRefId: 'PAT-8812',
      patientName: 'Meera Banerjee',
      departmentOrWard: 'Obstetrics & Delivery - OT 2',
      bloodType: BloodType.oPos,
      unitsRequired: 2,
      assignedUnits: 2,
      priority: HospitalRequestPriority.emergency,
      requiredDateTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: HospitalRequestStatus.fulfilled,
      clinicalNotes: 'Post-partum hemorrhage managed successfully following immediate transfusion.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    HospitalPatientBloodRequest(
      id: 'HREQ-905',
      patientRefId: 'PAT-6623',
      patientName: 'Anand Varma',
      departmentOrWard: 'Orthopedic Surgery - Ward C',
      bloodType: BloodType.abPos,
      unitsRequired: 2,
      assignedUnits: 1,
      priority: HospitalRequestPriority.normal,
      requiredDateTime: DateTime.now().add(const Duration(days: 1)),
      status: HospitalRequestStatus.inProgress,
      clinicalNotes: 'Total knee replacement elective pre-op reserve.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  // 3. Blood Bank Transfers Coordination
  List<BloodBankTransferItem> bloodBankTransfers = [
    BloodBankTransferItem(
      id: 'TRF-8101',
      bloodBankId: 'bank_001',
      bloodBankName: 'Chiranjeevi Blood Centre & Eye Bank',
      bloodType: BloodType.oNeg,
      units: 4,
      status: TransferStatus.inTransit,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      etaMinutes: 12,
      transportCourier: '108 GVK EMRI Priority Ambulance #24',
    ),
    BloodBankTransferItem(
      id: 'TRF-7940',
      bloodBankId: 'bank_004',
      bloodBankName: 'Indian Red Cross Society',
      bloodType: BloodType.bNeg,
      units: 2,
      status: TransferStatus.dispatched,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      etaMinutes: 24,
      transportCourier: 'Apollo MedSpeed Cold-Chain Van',
    ),
    BloodBankTransferItem(
      id: 'TRF-6831',
      bloodBankId: 'bank_003',
      bloodBankName: 'Rotary Central Blood Bank',
      bloodType: BloodType.aPos,
      units: 6,
      status: TransferStatus.delivered,
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
      etaMinutes: 0,
      transportCourier: 'Direct Inter-Hospital Transit',
    ),
  ];

  // 4. Hospital Patient Management Records
  List<HospitalPatientRecord> hospitalPatients = [
    HospitalPatientRecord(
      patientRefId: 'PAT-1082',
      name: 'Vikramaditya Rao',
      age: 38,
      bloodType: BloodType.oNeg,
      ward: 'Trauma ICU - Bed 4',
      admissionDate: 'Today, 06:45 AM',
      isEmergency: true,
      assignedUnits: 1,
      totalRequestsCount: 2,
      attendingPhysician: 'Dr. P. Venkat Reddy, MS (Trauma Surgeon)',
      diagnosis: 'Severe polytrauma, ruptured spleen, pelvic fracture',
    ),
    HospitalPatientRecord(
      patientRefId: 'PAT-2931',
      name: 'Sunita Deshmukh',
      age: 62,
      bloodType: BloodType.aPos,
      ward: 'Cardiovascular Surgery - OT 3',
      admissionDate: 'Yesterday, 02:15 PM',
      isEmergency: true,
      assignedUnits: 2,
      totalRequestsCount: 1,
      attendingPhysician: 'Dr. K. Srinivas Rao, MD (Cardiothoracic)',
      diagnosis: 'Triple-vessel CAD requiring emergency CABG bypass',
    ),
    HospitalPatientRecord(
      patientRefId: 'PAT-4419',
      name: 'Arjun Nair',
      age: 49,
      bloodType: BloodType.bNeg,
      ward: 'Hematology Ward - Bed 12',
      admissionDate: '3 days ago',
      isEmergency: false,
      assignedUnits: 0,
      totalRequestsCount: 3,
      attendingPhysician: 'Dr. Ananya Reddy, MD (Hematologist)',
      diagnosis: 'Aplastic anemia refractory to immunosuppressive therapy',
    ),
    HospitalPatientRecord(
      patientRefId: 'PAT-8812',
      name: 'Meera Banerjee',
      age: 29,
      bloodType: BloodType.oPos,
      ward: 'Obstetrics & Delivery - OT 2',
      admissionDate: 'Yesterday, 11:30 PM',
      isEmergency: true,
      assignedUnits: 2,
      totalRequestsCount: 1,
      attendingPhysician: 'Dr. Sarojini Devi, MD (OBGYN)',
      diagnosis: 'Post-partum hemorrhage stabilized with whole blood transfusion',
    ),
    HospitalPatientRecord(
      patientRefId: 'PAT-6623',
      name: 'Anand Varma',
      age: 54,
      bloodType: BloodType.abPos,
      ward: 'Orthopedic Surgery - Ward C',
      admissionDate: '2 days ago',
      isEmergency: false,
      assignedUnits: 1,
      totalRequestsCount: 1,
      attendingPhysician: 'Dr. M. Ramachandra, MS (Orthopedics)',
      diagnosis: 'Osteoarthritis pre-op joint reconstruction',
    ),
  ];

  // 5. Hospital Appointments Management
  List<HospitalAppointmentItem> hospitalAppointments = [
    HospitalAppointmentItem(
      id: 'HAPT-301',
      patientRefId: 'PAT-4419',
      patientName: 'Arjun Nair',
      bloodType: BloodType.bNeg,
      procedureType: 'Whole Blood Transfusion (1 Unit)',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      status: HospitalAppointmentStatus.confirmed,
      room: 'Transfusion Suite 2A',
      notes: 'Pre-medicate with anti-histamines. Monitor BP and pulse every 15 min.',
    ),
    HospitalAppointmentItem(
      id: 'HAPT-302',
      patientRefId: 'PAT-2931',
      patientName: 'Sunita Deshmukh',
      bloodType: BloodType.aPos,
      procedureType: 'Pre-Op Compatibility Crossmatch (2 Units)',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      status: HospitalAppointmentStatus.upcoming,
      room: 'Blood Bank Serology Lab',
      notes: 'Emergency crossmatch active. Cardiothoracic team notified.',
    ),
    HospitalAppointmentItem(
      id: 'HAPT-303',
      patientRefId: 'PAT-6623',
      patientName: 'Anand Varma',
      bloodType: BloodType.abPos,
      procedureType: 'Autologous Blood Collection',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      status: HospitalAppointmentStatus.upcoming,
      room: 'Apheresis Center Room 4',
      notes: 'Elective surgery pre-deposit.',
    ),
    HospitalAppointmentItem(
      id: 'HAPT-304',
      patientRefId: 'PAT-8812',
      patientName: 'Meera Banerjee',
      bloodType: BloodType.oPos,
      procedureType: 'Post-Transfusion Hemoglobin Check',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: HospitalAppointmentStatus.completed,
      room: 'Post-Op Recovery Ward Bed 3',
      notes: 'Hb stabilized at 10.6 g/dL. No adverse reaction observed.',
    ),
  ];

  // 6. Hospital Notifications Feed
  List<HospitalNotificationItem> hospitalNotifications = [
    HospitalNotificationItem(
      id: 'hnotif_01',
      type: 'emergency',
      title: 'Emergency SOS Blood Requisition Active',
      message: 'Trauma ICU Patient Robert Chen (#PAT-1082) requires 3 units of O- blood urgently.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isCritical: true,
    ),
    HospitalNotificationItem(
      id: 'hnotif_02',
      type: 'low_stock',
      title: 'Critical Low Stock Alert: O- & AB-',
      message: 'O- reserve is down to 3 units (Threshold: 10). AB- reserve has 2 units remaining.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isCritical: true,
    ),
    HospitalNotificationItem(
      id: 'hnotif_03',
      type: 'transfer_update',
      title: 'Blood Bank Transfer En Route',
      message: 'Metropolitan Blood Center dispatched 4 units of O- via MedExpress Ambulance. ETA: 14 mins.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      isCritical: false,
    ),
    HospitalNotificationItem(
      id: 'hnotif_04',
      type: 'donor_response',
      title: 'Nearby Donor Marcus Vance (O-) Accepted Alert',
      message: 'Marcus Vance confirmed response to hospital emergency call. Arriving in ~15 mins.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isCritical: false,
    ),
    HospitalNotificationItem(
      id: 'hnotif_05',
      type: 'expiring',
      title: 'Expiring Blood Units Notice',
      message: '3 units of A+ and 4 units of O+ will reach 35-day viability limit within 5 days.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isCritical: false,
    ),
  ];

  // ================= HOSPITAL ACTIONS & METHODS =================

  void createHospitalPatientRequest({
    required String patientRefId,
    required String patientName,
    required String ward,
    required BloodType bloodType,
    required int unitsRequired,
    required HospitalRequestPriority priority,
    required DateTime requiredDate,
    String? clinicalNotes,
  }) {
    final newId = 'HREQ-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
    final newReq = HospitalPatientBloodRequest(
      id: newId,
      patientRefId: patientRefId,
      patientName: patientName,
      departmentOrWard: ward,
      bloodType: bloodType,
      unitsRequired: unitsRequired,
      priority: priority,
      requiredDateTime: requiredDate,
      clinicalNotes: clinicalNotes,
      status: HospitalRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    hospitalRequests.insert(0, newReq);

    // If patient record exists, increment request count
    final pIndex = hospitalPatients.indexWhere((p) => p.patientRefId == patientRefId);
    if (pIndex == -1) {
      hospitalPatients.insert(
        0,
        HospitalPatientRecord(
          patientRefId: patientRefId,
          name: patientName,
          age: 40,
          bloodType: bloodType,
          ward: ward,
          admissionDate: 'Today',
          isEmergency: priority == HospitalRequestPriority.emergency,
          totalRequestsCount: 1,
          attendingPhysician: 'Attending Hospital Physician',
          diagnosis: clinicalNotes ?? 'Blood requirement',
        ),
      );
    }

    hospitalNotifications.insert(
      0,
      HospitalNotificationItem(
        id: 'hnotif_${DateTime.now().millisecondsSinceEpoch}',
        type: priority == HospitalRequestPriority.emergency ? 'emergency' : 'transfer_update',
        title: 'New Patient Requisition: $newId',
        message: '$patientName ($patientRefId) - $unitsRequired units of ${bloodType.label} requested for $ward.',
        timestamp: DateTime.now(),
        isCritical: priority == HospitalRequestPriority.emergency,
      ),
    );

    notifyListeners();
  }

  void reserveUnitsForHospitalRequest(String requestId, int unitsToReserve) {
    final reqIndex = hospitalRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      final req = hospitalRequests[reqIndex];
      final inventoryGroup = hospitalInventory[req.bloodType];
      if (inventoryGroup != null && inventoryGroup.availableUnits >= unitsToReserve) {
        inventoryGroup.availableUnits -= unitsToReserve;
        inventoryGroup.reservedUnits += unitsToReserve;
        req.assignedUnits += unitsToReserve;
        if (req.assignedUnits >= req.unitsRequired) {
          req.status = HospitalRequestStatus.reserved;
        } else {
          req.status = HospitalRequestStatus.inProgress;
        }

        // Also update patient record
        final pIndex = hospitalPatients.indexWhere((p) => p.patientRefId == req.patientRefId);
        if (pIndex != -1) {
          hospitalPatients[pIndex].assignedUnits = req.assignedUnits;
        }

        hospitalNotifications.insert(
          0,
          HospitalNotificationItem(
            id: 'hnotif_${DateTime.now().millisecondsSinceEpoch}',
            type: 'transfer_update',
            title: 'Units Reserved for Request $requestId',
            message: '$unitsToReserve units of ${req.bloodType.label} locked in hospital reserve for ${req.patientName}.',
            timestamp: DateTime.now(),
          ),
        );
        notifyListeners();
      }
    }
  }

  void fulfillHospitalRequest(String requestId) {
    final reqIndex = hospitalRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      final req = hospitalRequests[reqIndex];
      req.status = HospitalRequestStatus.fulfilled;
      final inventoryGroup = hospitalInventory[req.bloodType];
      if (inventoryGroup != null) {
        if (inventoryGroup.reservedUnits >= req.assignedUnits) {
          inventoryGroup.reservedUnits -= req.assignedUnits;
        }
        inventoryGroup.usedUnits += req.assignedUnits > 0 ? req.assignedUnits : req.unitsRequired;
      }

      hospitalNotifications.insert(
        0,
        HospitalNotificationItem(
          id: 'hnotif_${DateTime.now().millisecondsSinceEpoch}',
          type: 'transfer_update',
          title: 'Request $requestId Fulfilled',
          message: 'Transfusion completed for ${req.patientName} in ${req.departmentOrWard}.',
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  void escalateHospitalRequest(String requestId) {
    final reqIndex = hospitalRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      final req = hospitalRequests[reqIndex];
      req.isEscalated = true;
      req.status = HospitalRequestStatus.escalated;

      // Automatically dispatch an emergency transfer requisition to nearby central blood bank
      final transferId = 'TRF-ESC-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
      bloodBankTransfers.insert(
        0,
        BloodBankTransferItem(
          id: transferId,
          bloodBankId: 'bank_001',
          bloodBankName: 'Metropolitan Central Blood Center',
          bloodType: req.bloodType,
          units: req.unitsRequired - req.assignedUnits > 0 ? req.unitsRequired - req.assignedUnits : req.unitsRequired,
          status: TransferStatus.dispatched,
          requestedAt: DateTime.now(),
          etaMinutes: 12,
          transportCourier: 'Code Red Trauma Siren Courier #01',
        ),
      );

      hospitalNotifications.insert(
        0,
        HospitalNotificationItem(
          id: 'hnotif_esc_${DateTime.now().millisecondsSinceEpoch}',
          type: 'emergency',
          title: 'CRITICAL ESCALATION: Request $requestId',
          message: 'Escalated to regional blood reserve network. Priority courier dispatched (ID: $transferId).',
          timestamp: DateTime.now(),
          isCritical: true,
        ),
      );

      notifyListeners();
    }
  }

  void notifyCompatibleDonorsForHospital(String requestId) {
    final reqIndex = hospitalRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      final req = hospitalRequests[reqIndex];
      hospitalNotifications.insert(
        0,
        HospitalNotificationItem(
          id: 'hnotif_dnr_${DateTime.now().millisecondsSinceEpoch}',
          type: 'donor_response',
          title: 'Broadcast Dispatched to Compatible Donors',
          message: 'High-priority SMS & siren alert transmitted to 18 verified ${req.bloodType.label} donors within 8 km.',
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  void requestBloodBankTransfer({
    required String bloodBankName,
    required BloodType bloodType,
    required int units,
    required String courier,
  }) {
    final transferId = 'TRF-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
    bloodBankTransfers.insert(
      0,
      BloodBankTransferItem(
        id: transferId,
        bloodBankId: 'bank_custom',
        bloodBankName: bloodBankName,
        bloodType: bloodType,
        units: units,
        status: TransferStatus.requested,
        requestedAt: DateTime.now(),
        etaMinutes: 20,
        transportCourier: courier,
      ),
    );

    hospitalNotifications.insert(
      0,
      HospitalNotificationItem(
        id: 'hnotif_trf_${DateTime.now().millisecondsSinceEpoch}',
        type: 'transfer_update',
        title: 'Transfer Request Sent to $bloodBankName',
        message: 'Requisition $transferId for $units units of ${bloodType.label} transmitted.',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void advanceTransferStatus(String transferId) {
    final tIndex = bloodBankTransfers.indexWhere((t) => t.id == transferId);
    if (tIndex != -1) {
      final transfer = bloodBankTransfers[tIndex];
      switch (transfer.status) {
        case TransferStatus.requested:
          transfer.status = TransferStatus.dispatched;
          break;
        case TransferStatus.dispatched:
          transfer.status = TransferStatus.inTransit;
          break;
        case TransferStatus.inTransit:
          transfer.status = TransferStatus.delivered;
          break;
        case TransferStatus.delivered:
          confirmTransferDelivery(transferId);
          return;
        case TransferStatus.confirmed:
          break;
      }
      notifyListeners();
    }
  }

  void confirmTransferDelivery(String transferId) {
    final tIndex = bloodBankTransfers.indexWhere((t) => t.id == transferId);
    if (tIndex != -1) {
      final transfer = bloodBankTransfers[tIndex];
      transfer.status = TransferStatus.confirmed;

      // Add units into hospital available inventory!
      final inventoryGroup = hospitalInventory[transfer.bloodType];
      if (inventoryGroup != null) {
        inventoryGroup.availableUnits += transfer.units;
      }

      hospitalNotifications.insert(
        0,
        HospitalNotificationItem(
          id: 'hnotif_confirmed_${DateTime.now().millisecondsSinceEpoch}',
          type: 'transfer_update',
          title: 'Transfer Confirmed & Stock Integrated: $transferId',
          message: '${transfer.units} units of ${transfer.bloodType.label} from ${transfer.bloodBankName} verified and added to active inventory.',
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  void addHospitalInventoryStock({
    required BloodType bloodType,
    required int units,
    required String source,
  }) {
    final inventoryGroup = hospitalInventory[bloodType];
    if (inventoryGroup != null) {
      inventoryGroup.availableUnits += units;

      hospitalNotifications.insert(
        0,
        HospitalNotificationItem(
          id: 'hnotif_add_stock_${DateTime.now().millisecondsSinceEpoch}',
          type: 'stock_update',
          title: 'Stock Added: ${bloodType.label}',
          message: '$units units of ${bloodType.label} added to inventory from $source.',
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  void updateHospitalInventoryStock({
    required BloodType bloodType,
    int? availableUnits,
    int? reservedUnits,
    int? usedUnits,
    int? expiringUnits,
  }) {
    final inventoryGroup = hospitalInventory[bloodType];
    if (inventoryGroup != null) {
      if (availableUnits != null) inventoryGroup.availableUnits = availableUnits;
      if (reservedUnits != null) inventoryGroup.reservedUnits = reservedUnits;
      if (usedUnits != null) inventoryGroup.usedUnits = usedUnits;
      if (expiringUnits != null) inventoryGroup.expiringUnits = expiringUnits;

      hospitalNotifications.insert(
        0,
        HospitalNotificationItem(
          id: 'hnotif_update_stock_${DateTime.now().millisecondsSinceEpoch}',
          type: 'stock_update',
          title: 'Inventory Updated: ${bloodType.label}',
          message: '${bloodType.label} stock adjusted: Available ${inventoryGroup.availableUnits}, Reserved ${inventoryGroup.reservedUnits}, Used ${inventoryGroup.usedUnits}, Expiring ${inventoryGroup.expiringUnits}.',
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  void confirmHospitalAppointment(String appointmentId) {
    final index = hospitalAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      hospitalAppointments[index].status = HospitalAppointmentStatus.confirmed;
      notifyListeners();
    }
  }

  void rescheduleHospitalAppointment(String appointmentId, DateTime newDate) {
    final index = hospitalAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      hospitalAppointments[index].dateTime = newDate;
      hospitalAppointments[index].status = HospitalAppointmentStatus.rescheduled;
      notifyListeners();
    }
  }

  void cancelHospitalAppointment(String appointmentId) {
    final index = hospitalAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      hospitalAppointments[index].status = HospitalAppointmentStatus.cancelled;
      notifyListeners();
    }
  }

  void completeHospitalAppointment(String appointmentId) {
    final index = hospitalAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      hospitalAppointments[index].status = HospitalAppointmentStatus.completed;
      notifyListeners();
    }
  }

  void markHospitalNotificationRead(String id) {
    final notif = hospitalNotifications.firstWhere((n) => n.id == id, orElse: () => hospitalNotifications.first);
    notif.isRead = true;
    notifyListeners();
  }

  void markAllHospitalNotificationsRead() {
    for (var n in hospitalNotifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // ================= DONOR DASHBOARD STATE & ACTIONS =================

  // 1. Donor Profile
  DonorProfileModel donorProfile = DonorProfileModel(
    id: 'VP-IND-DNR-8942',
    name: 'Rajesh V. Kumar',
    bloodType: BloodType.oNeg,
    phone: '+91 94401 87654',
    email: 'rajesh.vkumar@vitalpulse.in',
    location: 'Kondapur, Near Botanical Garden, Hyderabad, Telangana',
    totalDonations: 8,
    totalUnitsDonated: 8,
    donationsThisYear: 3,
    lastDonationDate: DateTime.now().subtract(const Duration(days: 95)),
    nextEligibleDate: DateTime.now().subtract(const Duration(days: 5)), // Eligible now!
    isVerified: true,
    verificationBadge: 'Verified Gold Contributor',
    availability: DonorAvailabilityStatus.available,
    preferredLocation: 'Hitec City & Jubilee Hills Corridor',
    maxTravelDistanceKm: 15.0,
    availableDaysTimes: 'Weekdays after 4:30 PM & Full Weekends',
    preferredNotificationMethod: 'SMS & Push Notification',
    temporaryRestrictionMessage: 'No current medical restrictions. Donor passes pre-screening vitals.',
  );

  // 2. Emergency Blood Requests for Donor
  List<DonorEmergencyRequestItem> donorEmergencyRequests = [
    DonorEmergencyRequestItem(
      id: 'EMG-8821',
      requiredBloodType: BloodType.oNeg,
      unitsRequired: 2,
      hospitalName: 'Apollo Hospitals Level-1 Trauma Center',
      hospitalLocation: 'Road No. 72, Jubilee Hills, Hyderabad',
      distanceKm: 1.4,
      urgencyLevel: 'Critical Trauma Alert',
      requiredDateTime: DateTime.now().add(const Duration(hours: 1)),
      notes: 'Outer Ring Road accident internal hemorrhage. Immediate compatible O- red cells required.',
      hospitalPhone: '+91 40 2360 7777',
      status: DonorRequestStatus.pending,
    ),
    DonorEmergencyRequestItem(
      id: 'EMG-8822',
      requiredBloodType: BloodType.oNeg,
      unitsRequired: 1,
      hospitalName: "Nizam's Institute of Medical Sciences (NIMS)",
      hospitalLocation: 'Punjagutta Main Road, Hyderabad',
      distanceKm: 2.6,
      urgencyLevel: 'Pediatric Cardiac Need',
      requiredDateTime: DateTime.now().add(const Duration(hours: 3)),
      notes: 'Pediatric surgery scheduled standby. Urgent O- compatible units needed.',
      hospitalPhone: '+91 40 2348 9000',
      status: DonorRequestStatus.pending,
    ),
    DonorEmergencyRequestItem(
      id: 'EMG-8823',
      requiredBloodType: BloodType.oNeg,
      unitsRequired: 3,
      hospitalName: 'Chiranjeevi Blood Centre & Eye Bank',
      hospitalLocation: 'Road No 1, Jubilee Hills, Hyderabad',
      distanceKm: 2.1,
      urgencyLevel: 'Regional Stock Depletion',
      requiredDateTime: DateTime.now().add(const Duration(hours: 6)),
      notes: 'Critical reserve replenishment for weekend emergency trauma preparedness.',
      hospitalPhone: '+91 40 2355 5005',
      status: DonorRequestStatus.pending,
    ),
  ];

  // 3. Smart Donor Matching for Donor
  List<DonorSmartMatchItem> donorSmartMatches = [
    DonorSmartMatchItem(
      id: 'MATCH-101',
      patientOrRequestId: 'Req #HREQ-901 (Vikramaditya Rao)',
      bloodType: BloodType.oNeg,
      matchPercentage: 99,
      distanceKm: 1.4,
      urgency: 'Emergency Trauma',
      reasonForMatch: 'Universal O- match required for emergency surgery within 1.5 km of your location in Jubilee Hills.',
      hospitalName: 'Apollo Hospitals Level-1 Trauma Center',
    ),
    DonorSmartMatchItem(
      id: 'MATCH-102',
      patientOrRequestId: 'Patient #PAT-4419 (Arjun Nair)',
      bloodType: BloodType.bNeg,
      matchPercentage: 95,
      distanceKm: 2.6,
      urgency: 'Hematology Urgent Care',
      reasonForMatch: 'Compatible rare Rh-negative profile. Donor availability aligns with scheduled transfusion slot.',
      hospitalName: 'KIMS Hospitals, Secunderabad',
    ),
    DonorSmartMatchItem(
      id: 'MATCH-103',
      patientOrRequestId: 'Req #REQ-7821 (Platelet Standby)',
      bloodType: BloodType.oPos,
      matchPercentage: 92,
      distanceKm: 2.1,
      urgency: 'Scheduled Transfusion',
      reasonForMatch: 'Donor availability preferences match Chiranjeevi Blood Centre operating schedule.',
      hospitalName: 'Chiranjeevi Blood Centre, Jubilee Hills',
    ),
  ];

  // 4. Donation Appointment Booking
  List<DonorAppointmentItem> donorAppointments = [
    DonorAppointmentItem(
      id: 'APT-DNR-01',
      centerName: 'Chiranjeevi Blood Centre & Eye Bank',
      address: 'Road No 1, Jubilee Hills, Hyderabad',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      availableSlots: 8,
      status: DonorAppointmentStatus.confirmed,
      notes: 'Whole blood donation session. Fasting not required. Drink 500ml water prior to donation.',
    ),
    DonorAppointmentItem(
      id: 'APT-DNR-02',
      centerName: 'Apollo Hospitals Blood Bank',
      address: 'Road No 72, Jubilee Hills, Hyderabad',
      dateTime: DateTime.now().add(const Duration(days: 14, hours: 1)),
      availableSlots: 14,
      status: DonorAppointmentStatus.upcoming,
      notes: 'Platelet apheresis check & routine hemoglobin screening.',
    ),
  ];

  // 5. Donation Camps
  List<DonorCampItem> donorCamps = [
    DonorCampItem(
      id: 'CAMP-01',
      campName: 'Hitec City Cyber Towers Mega Blood Drive',
      organizer: 'Cyberabad Health Volunteers & Rotary India',
      date: 'Tomorrow & Friday',
      time: '9:00 AM – 6:30 PM',
      location: 'Cyber Gateway Concourse, Hitec City, Hyderabad',
      distanceKm: 0.9,
      availableSlots: 65,
      description: 'Annual high-capacity mobile donation camp with health checks, refreshments, and donor badges.',
      isRegistered: true,
      hasReminder: true,
    ),
    DonorCampItem(
      id: 'CAMP-02',
      campName: 'Manyata Tech Park Lifesavers Camp',
      organizer: 'Rotary Bangalore IT Corridor & Red Cross',
      date: 'Oct 4 – Oct 6',
      time: '10:00 AM – 5:30 PM',
      location: 'Block G3 Amphitheatre, Manyata Tech Park, Bengaluru',
      distanceKm: 3.4,
      availableSlots: 85,
      description: 'Corporate and youth community blood drive open to all voluntary donors.',
      isRegistered: false,
      hasReminder: false,
    ),
    DonorCampItem(
      id: 'CAMP-03',
      campName: 'BKC Corporate Blood Donation Pavilion',
      organizer: 'State Blood Transfusion Council Maharashtra',
      date: 'This Saturday',
      time: '8:30 AM – 4:30 PM',
      location: 'MMRDA Grounds, Bandra Kurla Complex, Mumbai',
      distanceKm: 2.2,
      availableSlots: 150,
      description: 'Major urban blood collection camp with on-site lipid profile and CBC screening.',
      isRegistered: false,
      hasReminder: false,
    ),
  ];

  // 6. Complete Donation History Records
  List<DonorHistoryRecord> donorHistory = [
    DonorHistoryRecord(
      id: 'DREC-08',
      donationDate: DateTime.now().subtract(const Duration(days: 95)),
      donationCenter: 'Apollo Blood Reserve & Life Center, Jubilee Hills',
      bloodType: BloodType.oNeg,
      unitsDonated: 1,
      status: 'Successful',
      appointmentRef: 'APT-9821',
      certificateId: 'CERT-IN-7729-08',
      recipientName: 'Priya Ananya Sharma',
      recipientAge: 28,
      recipientGender: 'Female',
      recipientBloodType: BloodType.oNeg,
      recipientHospital: 'Apollo Multi-Specialty Hospital, Hyderabad',
      recipientWard: 'Cardiovascular Surgery ICU (Bed 12-A)',
      doctorInCharge: 'Dr. Radhika Menon, MD (Senior Transfusion Specialist)',
      transfusionDate: DateTime.now().subtract(const Duration(days: 93)),
      transfusionStatus: 'Transfusion Completed • Patient Fully Recovered',
      impactStory: 'Your donated unit was cross-matched and transfused during an emergency cardiac surgery. The patient is in stable recovery thanks to your prompt donation.',
      recipientThankYouNote: '“Words cannot express how grateful my family and I are. Your selfless gift gave me another chance to watch my daughter grow up.” — Priya Sharma',
      receiptNumber: 'VP-RCPT-2024-99120',
      bloodBagNumber: 'VP-BAG-88219-IND',
      hemoglobin: '14.2 g/dL',
      bloodPressure: '118/78 mmHg',
      pulse: '72 bpm',
      donationType: 'Whole Blood (450 ml)',
      verifiedBy: 'National Blood Transfusion Council (NBTC) & LifeDrop Verification Registry',
    ),
    DonorHistoryRecord(
      id: 'DREC-07',
      donationDate: DateTime.now().subtract(const Duration(days: 180)),
      donationCenter: 'KIMS Hospitals Blood Bank, Secunderabad',
      bloodType: BloodType.oNeg,
      unitsDonated: 1,
      status: 'Successful',
      appointmentRef: 'APT-8114',
      certificateId: 'CERT-IN-7729-07',
      recipientName: 'Rohan K. Varma',
      recipientAge: 42,
      recipientGender: 'Male',
      recipientBloodType: BloodType.oNeg,
      recipientHospital: 'KIMS Multi-Specialty Hospital, Secunderabad',
      recipientWard: 'Trauma & Emergency Care (Bed 04)',
      doctorInCharge: 'Dr. Arvind Mehra, Senior Hematologist',
      transfusionDate: DateTime.now().subtract(const Duration(days: 178)),
      transfusionStatus: 'Transfusion Completed • Zero Complications',
      impactStory: 'Your blood unit provided critical trauma stabilization following a severe highway accident, saving the recipient from acute hypovolemic shock.',
      recipientThankYouNote: '“You are a true superhero. Thank you for stepping up when I needed it the most!” — Rohan Varma & Family',
      receiptNumber: 'VP-RCPT-2024-81142',
      bloodBagNumber: 'VP-BAG-77103-IND',
      hemoglobin: '14.0 g/dL',
      bloodPressure: '120/80 mmHg',
      pulse: '70 bpm',
      donationType: 'Whole Blood (450 ml)',
      verifiedBy: 'State Blood Transfusion Council (SBTC) & KIMS Health',
    ),
    DonorHistoryRecord(
      id: 'DREC-06',
      donationDate: DateTime.now().subtract(const Duration(days: 270)),
      donationCenter: 'Red Cross Regional Blood Center, Nampally',
      bloodType: BloodType.oNeg,
      unitsDonated: 1,
      status: 'Successful',
      appointmentRef: 'APT-6902',
      certificateId: 'CERT-IN-7729-06',
      recipientName: 'Aarohi Sen',
      recipientAge: 19,
      recipientGender: 'Female',
      recipientBloodType: BloodType.oNeg,
      recipientHospital: 'AIIMS Regional Hospital, Oncology Center',
      recipientWard: 'Hematology Day Care (Bed 09)',
      doctorInCharge: 'Dr. Suresh Varma, MD (Transfusion Medicine)',
      transfusionDate: DateTime.now().subtract(const Duration(days: 268)),
      transfusionStatus: 'Transfusion Completed • Vital Counts Restored',
      impactStory: 'Your unit was allocated to an oncology patient undergoing vital chemotherapy support, preventing severe anemia and aiding immune recovery.',
      recipientThankYouNote: '“Thank you from the bottom of my heart for giving me strength during my recovery.” — Aarohi Sen',
      receiptNumber: 'VP-RCPT-2023-69021',
      bloodBagNumber: 'VP-BAG-66014-IND',
      hemoglobin: '13.8 g/dL',
      bloodPressure: '116/76 mmHg',
      pulse: '74 bpm',
      donationType: 'Whole Blood (450 ml)',
      verifiedBy: 'Indian Red Cross Society & NBTC Registry',
    ),
    DonorHistoryRecord(
      id: 'DREC-05',
      donationDate: DateTime.now().subtract(const Duration(days: 360)),
      donationCenter: 'HITEC City Mega LifeSaver Camp',
      bloodType: BloodType.oNeg,
      unitsDonated: 1,
      status: 'Successful',
      appointmentRef: 'APT-5201',
      certificateId: 'CERT-IN-7729-05',
      recipientName: 'Kabir Mukherjee',
      recipientAge: 54,
      recipientGender: 'Male',
      recipientBloodType: BloodType.oNeg,
      recipientHospital: 'Care Hospital & Heart Institute, Banjara Hills',
      recipientWard: 'Surgical ICU Unit (Bed 17)',
      doctorInCharge: 'Dr. Neha Kapoor, Chief of Transfusion Services',
      transfusionDate: DateTime.now().subtract(const Duration(days: 358)),
      transfusionStatus: 'Transfusion Completed • Discharged in Good Health',
      impactStory: 'Your blood donation was dispatched to support major orthopedic reconstructive surgery, ensuring zero blood loss complications.',
      recipientThankYouNote: '“My recovery was possible because of generous donors like you. Bless you!” — Kabir Mukherjee',
      receiptNumber: 'VP-RCPT-2023-52019',
      bloodBagNumber: 'VP-BAG-55092-IND',
      hemoglobin: '14.5 g/dL',
      bloodPressure: '122/82 mmHg',
      pulse: '68 bpm',
      donationType: 'Whole Blood (450 ml)',
      verifiedBy: 'National Blood Transfusion Council (NBTC)',
    ),
  ];

  // 7. Donor Activity Timeline
  List<DonorTimelineItem> donorTimeline = [
    DonorTimelineItem(
      id: 'time_01',
      title: 'Eligible to Donate Again',
      description: '90-day rest period completed. You are now fully eligible for whole blood donation.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      category: 'eligibility',
    ),
    DonorTimelineItem(
      id: 'time_02',
      title: 'Registered for Times Square Blood Camp',
      description: 'Registration confirmed for mobile donation station on Broadway & 44th St.',
      timestamp: DateTime.now().subtract(const Duration(days: 12)),
      category: 'camp',
    ),
    DonorTimelineItem(
      id: 'time_03',
      title: 'Completed 8th Blood Donation',
      description: 'Donated 1 unit of O- blood at Metropolitan Central Blood Center. Certificate #CERT-NY-7729-08 issued.',
      timestamp: DateTime.now().subtract(const Duration(days: 95)),
      category: 'donation',
    ),
    DonorTimelineItem(
      id: 'time_04',
      title: 'Accepted Emergency SOS Call',
      description: 'Responded to critical O- request for Memorial Trauma ICU patient.',
      timestamp: DateTime.now().subtract(const Duration(days: 180)),
      category: 'emergency',
    ),
    DonorTimelineItem(
      id: 'time_05',
      title: 'Availability Status Updated',
      description: 'Changed availability status to "Available to Donate" with 15km max travel radius.',
      timestamp: DateTime.now().subtract(const Duration(days: 190)),
      category: 'profile',
    ),
  ];

  // 8. Donor Notifications Feed
  List<DonorNotificationItem> donorNotifications = [
    DonorNotificationItem(
      id: 'dnotif_01',
      type: 'emergency',
      title: 'Critical Emergency Blood Request Nearby!',
      message: 'Memorial General Hospital needs 2 units of O- blood immediately (1.4 km away).',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    DonorNotificationItem(
      id: 'dnotif_02',
      type: 'match',
      title: '99% Smart Match Identified',
      message: 'Your O- profile perfectly matches trauma patient requisition at Memorial Hospital.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    DonorNotificationItem(
      id: 'dnotif_03',
      type: 'eligibility',
      title: 'You Are Eligible to Donate!',
      message: 'Your 90-day donation rest period has concluded. Thank you for your continued dedication.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
    DonorNotificationItem(
      id: 'dnotif_04',
      type: 'camp',
      title: 'Upcoming Donation Camp: Times Square',
      message: 'Times Square LifeSaver Blood Drive starts tomorrow at 9:00 AM. Refreshments and certificates provided.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    DonorNotificationItem(
      id: 'dnotif_05',
      type: 'thankyou',
      title: 'Thank You from VitalPulse Community',
      message: 'Your 8 lifetime donations have supported over 20 patient treatments across the regional health network.',
      timestamp: DateTime.now().subtract(const Duration(days: 15)),
      isRead: true,
    ),
  ];

  // ================= DONOR ACTIONS & METHODS =================

  void setDonorAvailability(DonorAvailabilityStatus status) {
    donorProfile.availability = status;
    donorTimeline.insert(
      0,
      DonorTimelineItem(
        id: 'time_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Availability Status Changed',
        description: 'Status updated to "${status.label}".',
        timestamp: DateTime.now(),
        category: 'profile',
      ),
    );
    notifyListeners();
  }

  void updateDonorPreferences({
    String? preferredLoc,
    double? maxDist,
    String? daysTimes,
    String? notifMethod,
  }) {
    if (preferredLoc != null) donorProfile.preferredLocation = preferredLoc;
    if (maxDist != null) donorProfile.maxTravelDistanceKm = maxDist;
    if (daysTimes != null) donorProfile.availableDaysTimes = daysTimes;
    if (notifMethod != null) donorProfile.preferredNotificationMethod = notifMethod;
    notifyListeners();
  }

  void updateDonorProfileDetails({
    required String name,
    required String phone,
    required String email,
    required String location,
  }) {
    donorProfile.name = name;
    donorProfile.phone = phone;
    donorProfile.email = email;
    donorProfile.location = location;
    donorTimeline.insert(
      0,
      DonorTimelineItem(
        id: 'time_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Profile Details Updated',
        description: 'Contact information and home location updated.',
        timestamp: DateTime.now(),
        category: 'profile',
      ),
    );
    notifyListeners();
  }

  void acceptDonorEmergencyRequest(String id) {
    final index = donorEmergencyRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final req = donorEmergencyRequests[index];
      req.status = DonorRequestStatus.accepted;

      donorTimeline.insert(
        0,
        DonorTimelineItem(
          id: 'time_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Emergency Request Accepted: ${req.id}',
          description: 'Confirmed availability to donate ${req.unitsRequired} units of ${req.requiredBloodType.label} at ${req.hospitalName}.',
          timestamp: DateTime.now(),
          category: 'emergency',
        ),
      );

      donorNotifications.insert(
        0,
        DonorNotificationItem(
          id: 'dnotif_accepted_${DateTime.now().millisecondsSinceEpoch}',
          type: 'emergency',
          title: 'Hospital Notified of Your Response!',
          message: 'The clinical desk at ${req.hospitalName} has been alerted that you are en route. Direct line: ${req.hospitalPhone}.',
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  void declineDonorEmergencyRequest(String id) {
    final index = donorEmergencyRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      donorEmergencyRequests[index].status = DonorRequestStatus.declined;
      notifyListeners();
    }
  }

  void respondLaterDonorEmergencyRequest(String id) {
    final index = donorEmergencyRequests.indexWhere((r) => r.id == id);
    if (index != -1) {
      donorEmergencyRequests[index].status = DonorRequestStatus.respondedLater;
      notifyListeners();
    }
  }

  void bookDonorAppointment({
    required String centerName,
    required String address,
    required DateTime dateTime,
    required String notes,
  }) {
    final newApt = DonorAppointmentItem(
      id: 'APT-DNR-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}',
      centerName: centerName,
      address: address,
      dateTime: dateTime,
      availableSlots: 8,
      status: DonorAppointmentStatus.confirmed,
      notes: notes,
    );

    donorAppointments.insert(0, newApt);

    donorTimeline.insert(
      0,
      DonorTimelineItem(
        id: 'time_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Donation Appointment Booked',
        description: 'Scheduled at $centerName for ${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}.',
        timestamp: DateTime.now(),
        category: 'appointment',
      ),
    );

    donorNotifications.insert(
      0,
      DonorNotificationItem(
        id: 'dnotif_apt_${DateTime.now().millisecondsSinceEpoch}',
        type: 'reminder',
        title: 'Appointment Confirmed at $centerName',
        message: 'Your slot on ${dateTime.day}/${dateTime.month} is confirmed. Please bring your digital donor card.',
        timestamp: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  void cancelDonorAppointment(String id) {
    final index = donorAppointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      donorAppointments[index].status = DonorAppointmentStatus.cancelled;
      notifyListeners();
    }
  }

  void toggleCampRegistration(String campId) {
    final index = donorCamps.indexWhere((c) => c.id == campId);
    if (index != -1) {
      final camp = donorCamps[index];
      camp.isRegistered = !camp.isRegistered;
      donorTimeline.insert(
        0,
        DonorTimelineItem(
          id: 'time_${DateTime.now().millisecondsSinceEpoch}',
          title: camp.isRegistered ? 'Registered for ${camp.campName}' : 'Cancelled Registration for ${camp.campName}',
          description: camp.isRegistered ? 'Registration locked with volunteer check-in.' : 'Slot released for another donor.',
          timestamp: DateTime.now(),
          category: 'camp',
        ),
      );
      notifyListeners();
    }
  }

  void toggleCampReminder(String campId) {
    final index = donorCamps.indexWhere((c) => c.id == campId);
    if (index != -1) {
      donorCamps[index].hasReminder = !donorCamps[index].hasReminder;
      notifyListeners();
    }
  }

  void markDonorNotificationRead(String id) {
    final notif = donorNotifications.firstWhere((n) => n.id == id, orElse: () => donorNotifications.first);
    notif.isRead = true;
    notifyListeners();
  }

  void markAllDonorNotificationsRead() {
    for (var n in donorNotifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // ==========================================
  // DONOR CUSTOM CERTIFICATE & ACTIVENESS STATE
  // ==========================================
  DonorCertificateModel donorCertificate = DonorCertificateModel(
    certificateId: 'CERT-VP-2026-8942',
    donorName: 'Alex Mercer',
    bloodGroup: 'O Negative (Universal Donor)',
    issueDate: 'January 18, 2026',
    unitsDonated: 14,
    centerName: 'Metro Regional Blood Center, Seattle WA',
    customTitle: 'Distinguished Humanitarian Lifesaver',
    certificateTheme: 'Gold Royal',
    customPledgeMessage: 'In profound recognition of 14 voluntary blood donations, honoring the enduring human spirit that preserves critical lives.',
    signatureTitle: 'Dr. Evelyn Vance, Chief Medical Director & Transfusion Board',
    includeQrVerification: true,
    includeWatermark: true,
  );

  DonorActivenessSetting donorActiveness = DonorActivenessSetting(
    frequencyPlan: 'Standard (Every 90 Days)',
    allowEmergencySosBroadcasts: true,
    allowMatchingRadiusExpansions: true,
    customRadiusKm: 25.0,
    yearlyPledgeUnits: 4,
    preferredDonationDays: ['Saturday', 'Sunday', 'Wednesday'],
    reminderFrequency: '3 Days Before',
    personalMotto: 'Whenever a life is on the line, I will answer the call.',
  );

  void updateDonorCertificate({
    required String customTitle,
    required String certificateTheme,
    required String customPledgeMessage,
    required String signatureTitle,
    required bool includeQrVerification,
    required bool includeWatermark,
  }) {
    donorCertificate.customTitle = customTitle;
    donorCertificate.certificateTheme = certificateTheme;
    donorCertificate.customPledgeMessage = customPledgeMessage;
    donorCertificate.signatureTitle = signatureTitle;
    donorCertificate.includeQrVerification = includeQrVerification;
    donorCertificate.includeWatermark = includeWatermark;
    donorTimeline.insert(
      0,
      DonorTimelineItem(
        id: 'time_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Customized Lifesaver Certificate',
        description: 'Updated certificate theme to $certificateTheme with custom honors title.',
        timestamp: DateTime.now(),
        category: 'profile',
      ),
    );
    notifyListeners();
  }

  void updateDonorActiveness({
    String? frequencyPlan,
    bool? allowEmergencySosBroadcasts,
    bool? allowMatchingRadiusExpansions,
    double? customRadiusKm,
    int? yearlyPledgeUnits,
    List<String>? preferredDonationDays,
    String? reminderFrequency,
    String? personalMotto,
  }) {
    if (frequencyPlan != null) donorActiveness.frequencyPlan = frequencyPlan;
    if (allowEmergencySosBroadcasts != null) donorActiveness.allowEmergencySosBroadcasts = allowEmergencySosBroadcasts;
    if (allowMatchingRadiusExpansions != null) donorActiveness.allowMatchingRadiusExpansions = allowMatchingRadiusExpansions;
    if (customRadiusKm != null) donorActiveness.customRadiusKm = customRadiusKm;
    if (yearlyPledgeUnits != null) donorActiveness.yearlyPledgeUnits = yearlyPledgeUnits;
    if (preferredDonationDays != null) donorActiveness.preferredDonationDays = preferredDonationDays;
    if (reminderFrequency != null) donorActiveness.reminderFrequency = reminderFrequency;
    if (personalMotto != null) donorActiveness.personalMotto = personalMotto;
    donorTimeline.insert(
      0,
      DonorTimelineItem(
        id: 'time_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Donation Activeness Plan Configured',
        description: 'Set donation commitment to ${donorActiveness.frequencyPlan} with ${donorActiveness.yearlyPledgeUnits} units pledge.',
        timestamp: DateTime.now(),
        category: 'eligibility',
      ),
    );
    notifyListeners();
  }

  // ==========================================
  // BLOOD BANK DASHBOARD STATE & DATASETS
  // ==========================================

  BankStaffRole bankCurrentStaffRole = BankStaffRole.manager;

  BankFacilityProfile bankProfile = BankFacilityProfile(
    name: 'Metro Central Regional Blood Center',
    licenseNumber: 'FDA-CBER-984210-WA',
    address: '900 12th Avenue Medical Corridor, Seattle, WA 98122',
    phone: '+1 (206) 555-0199',
    emergencyHotline: '+1 (800) 555-BLOOD',
    email: 'operations@metrobloodcenter.org',
    operatingHours: '24/7 Transfusion Emergency Desk (Donations: 07:00 - 20:00 Daily)',
    storageCapacity: '1,500 Units Cryo Capacity (Currently 201 Units Stored)',
    availableServices: [
      'Whole Blood Collection & Fractionation',
      'Platelet Apheresis & Cryoprecipitate Storage',
      'Irradiation & Leukoreduction Lab',
      'Emergency Cold-Chain Dispatch',
      'Hospital Urgent Compatibility Cross-Match'
    ],
    accreditation: 'AABB & FDA Certified Transfusion Facility',
  );

  List<BankInventoryItem> bankInventory = [
    BankInventoryItem(
      bloodType: BloodType.aPos,
      availableUnits: 38,
      reservedUnits: 8,
      usedUnits: 142,
      expiringUnits: 3,
      collectionDate: DateTime.now().subtract(const Duration(days: 12)),
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      storageLocation: 'Cryo Vault Alpha - Tray 1',
      minimumStockThreshold: 25,
      status: BankInventoryStatus.normal,
      batchNumber: 'BATCH-AP-2026-041',
    ),
    BankInventoryItem(
      bloodType: BloodType.aNeg,
      availableUnits: 11,
      reservedUnits: 4,
      usedUnits: 58,
      expiringUnits: 1,
      collectionDate: DateTime.now().subtract(const Duration(days: 16)),
      expiryDate: DateTime.now().add(const Duration(days: 26)),
      storageLocation: 'Cryo Vault Alpha - Tray 2',
      minimumStockThreshold: 15,
      status: BankInventoryStatus.lowStock,
      batchNumber: 'BATCH-AN-2026-018',
    ),
    BankInventoryItem(
      bloodType: BloodType.bPos,
      availableUnits: 42,
      reservedUnits: 6,
      usedUnits: 115,
      expiringUnits: 4,
      collectionDate: DateTime.now().subtract(const Duration(days: 9)),
      expiryDate: DateTime.now().add(const Duration(days: 33)),
      storageLocation: 'Cryo Vault Beta - Tray 1',
      minimumStockThreshold: 20,
      status: BankInventoryStatus.normal,
      batchNumber: 'BATCH-BP-2026-052',
    ),
    BankInventoryItem(
      bloodType: BloodType.bNeg,
      availableUnits: 7,
      reservedUnits: 3,
      usedUnits: 39,
      expiringUnits: 0,
      collectionDate: DateTime.now().subtract(const Duration(days: 20)),
      expiryDate: DateTime.now().add(const Duration(days: 22)),
      storageLocation: 'Cryo Vault Beta - Tray 2',
      minimumStockThreshold: 12,
      status: BankInventoryStatus.critical,
      batchNumber: 'BATCH-BN-2026-009',
    ),
    BankInventoryItem(
      bloodType: BloodType.abPos,
      availableUnits: 19,
      reservedUnits: 3,
      usedUnits: 34,
      expiringUnits: 2,
      collectionDate: DateTime.now().subtract(const Duration(days: 14)),
      expiryDate: DateTime.now().add(const Duration(days: 28)),
      storageLocation: 'Cryo Vault Gamma - Tray 1',
      minimumStockThreshold: 10,
      status: BankInventoryStatus.normal,
      batchNumber: 'BATCH-ABP-2026-014',
    ),
    BankInventoryItem(
      bloodType: BloodType.abNeg,
      availableUnits: 4,
      reservedUnits: 1,
      usedUnits: 18,
      expiringUnits: 2,
      collectionDate: DateTime.now().subtract(const Duration(days: 39)),
      expiryDate: DateTime.now().add(const Duration(hours: 14)),
      storageLocation: 'Cryo Vault Gamma - Tray 2',
      minimumStockThreshold: 8,
      status: BankInventoryStatus.critical,
      batchNumber: 'BATCH-ABN-2026-004',
    ),
    BankInventoryItem(
      bloodType: BloodType.oPos,
      availableUnits: 66,
      reservedUnits: 16,
      usedUnits: 295,
      expiringUnits: 5,
      collectionDate: DateTime.now().subtract(const Duration(days: 8)),
      expiryDate: DateTime.now().add(const Duration(days: 34)),
      storageLocation: 'Cryo Vault Delta - Main Tier',
      minimumStockThreshold: 40,
      status: BankInventoryStatus.normal,
      batchNumber: 'BATCH-OP-2026-088',
    ),
    BankInventoryItem(
      bloodType: BloodType.oNeg,
      availableUnits: 14,
      reservedUnits: 9,
      usedUnits: 210,
      expiringUnits: 2,
      collectionDate: DateTime.now().subtract(const Duration(days: 18)),
      expiryDate: DateTime.now().add(const Duration(days: 24)),
      storageLocation: 'Cryo Vault Delta - Emergency Reserve',
      minimumStockThreshold: 30,
      status: BankInventoryStatus.lowStock,
      batchNumber: 'BATCH-ON-2026-031',
    ),
  ];

  List<BankLowStockAlert> bankLowStockAlerts = [
    BankLowStockAlert(
      id: 'LSA-01',
      bloodType: BloodType.bNeg,
      currentUnits: 7,
      requiredMinimumUnits: 12,
      priority: LowStockAlertPriority.critical,
      suggestedAction: 'Immediate SOS broadcast to 8 registered B- donors within 15km.',
    ),
    BankLowStockAlert(
      id: 'LSA-02',
      bloodType: BloodType.abNeg,
      currentUnits: 4,
      requiredMinimumUnits: 8,
      priority: LowStockAlertPriority.critical,
      suggestedAction: 'Request inter-bank transfer from Valley Regional Blood Hub.',
    ),
    BankLowStockAlert(
      id: 'LSA-03',
      bloodType: BloodType.oNeg,
      currentUnits: 14,
      requiredMinimumUnits: 30,
      priority: LowStockAlertPriority.high,
      suggestedAction: 'Initiate Universal Donor outreach campaign and mobile camp booking.',
    ),
    BankLowStockAlert(
      id: 'LSA-04',
      bloodType: BloodType.aNeg,
      currentUnits: 11,
      requiredMinimumUnits: 15,
      priority: LowStockAlertPriority.moderate,
      suggestedAction: 'Send donor eligibility reminder notifications to 22 donors in rest cooldown.',
    ),
  ];

  List<BankExpiryItem> bankExpiryItems = [
    BankExpiryItem(
      batchNumber: 'BATCH-ABN-2026-004',
      bloodType: BloodType.abNeg,
      units: 2,
      expiryDate: DateTime.now().add(const Duration(hours: 14)),
      storageLocation: 'Vault Gamma - Tray 2',
      timeframe: 'today',
    ),
    BankExpiryItem(
      batchNumber: 'BATCH-AP-2026-029',
      bloodType: BloodType.aPos,
      units: 3,
      expiryDate: DateTime.now().add(const Duration(days: 2, hours: 10)),
      storageLocation: 'Vault Alpha - Tray 1B',
      timeframe: '3_days',
    ),
    BankExpiryItem(
      bloodType: BloodType.oPos,
      batchNumber: 'BATCH-OP-2026-071',
      units: 5,
      expiryDate: DateTime.now().add(const Duration(days: 5, hours: 6)),
      storageLocation: 'Vault Delta - Row 3',
      timeframe: '7_days',
    ),
    BankExpiryItem(
      batchNumber: 'BATCH-BP-2026-019',
      bloodType: BloodType.bPos,
      units: 1,
      expiryDate: DateTime.now().subtract(const Duration(hours: 6)),
      storageLocation: 'Quarantine Discard Bin 4',
      timeframe: 'expired',
      isDiscarded: true,
      wastageReason: 'Exceeded 42-day RBC viability shelf-life without hospital requisition',
    ),
  ];

  List<BankHospitalRequest> bankHospitalRequests = [
    BankHospitalRequest(
      id: 'HREQ-8901',
      hospitalName: 'Apollo Hospitals Level-1 Trauma Center, Jubilee Hills',
      patientRefId: 'PT-9481 (Trauma ICU)',
      bloodType: BloodType.oNeg,
      unitsRequired: 4,
      unitsAssigned: 4,
      urgency: 'Critical Trauma SOS',
      requiredDateTime: DateTime.now().add(const Duration(hours: 2)),
      status: BankHospitalReqStatus.approved,
      internalNotes: 'Cross-match completed. Reserved in Cryo Delta Emergency box.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    BankHospitalRequest(
      id: 'HREQ-8902',
      hospitalName: 'Rainbow Children’s Hospital, Banjara Hills',
      patientRefId: 'PT-7712 (Pediatric Oncology)',
      bloodType: BloodType.aPos,
      unitsRequired: 2,
      unitsAssigned: 0,
      urgency: 'Urgent Scheduled',
      requiredDateTime: DateTime.now().add(const Duration(hours: 8)),
      status: BankHospitalReqStatus.underReview,
      internalNotes: 'Serology verification verified; awaiting secondary transport check.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BankHospitalRequest(
      id: 'HREQ-8903',
      hospitalName: 'KIMS Hospitals, Secunderabad',
      patientRefId: 'PT-6630 (Cardiothoracic OT)',
      bloodType: BloodType.bPos,
      unitsRequired: 3,
      unitsAssigned: 3,
      urgency: 'Scheduled Surgical',
      requiredDateTime: DateTime.now().add(const Duration(hours: 18)),
      status: BankHospitalReqStatus.fulfilled,
      internalNotes: 'Dispatched via Courier Van #4 at 09:15 AM.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    BankHospitalRequest(
      id: 'HREQ-8904',
      hospitalName: 'Yashoda Super Specialty Hospital, Somajiguda',
      patientRefId: 'PT-3329 (Orthopedic OT)',
      bloodType: BloodType.abPos,
      unitsRequired: 2,
      unitsAssigned: 0,
      urgency: 'Routine Replacement',
      requiredDateTime: DateTime.now().add(const Duration(days: 1)),
      status: BankHospitalReqStatus.pending,
      internalNotes: 'Pending stock verification against Cryo Gamma.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  List<BankTransferItem> bankTransfers = [
    BankTransferItem(
      id: 'TRF-9021',
      sourceOrg: 'Chiranjeevi Blood Centre & Eye Bank',
      destinationOrg: 'Apollo Hospitals Level-1 Trauma Center',
      bloodType: BloodType.oNeg,
      units: 4,
      requestDate: DateTime.now().subtract(const Duration(minutes: 50)),
      dispatchDate: DateTime.now().subtract(const Duration(minutes: 20)),
      expectedDeliveryDate: DateTime.now().add(const Duration(minutes: 15)),
      status: BankTransferStatus.inTransit,
      transportCarrier: '108 GVK EMRI Cold-Chain Unit #7',
      trackingId: 'TRK-IN-HYD-84920',
    ),
    BankTransferItem(
      id: 'TRF-9022',
      sourceOrg: 'Rotary Central Blood Bank Bengaluru',
      destinationOrg: 'Chiranjeevi Blood Centre Hyderabad',
      bloodType: BloodType.bNeg,
      units: 5,
      requestDate: DateTime.now().subtract(const Duration(hours: 3)),
      expectedDeliveryDate: DateTime.now().add(const Duration(hours: 4)),
      status: BankTransferStatus.prepared,
      transportCarrier: 'Inter-State Air Cargo Medical Shuttle',
      trackingId: 'TRK-IN-AIR-73911',
    ),
    BankTransferItem(
      id: 'TRF-9023',
      sourceOrg: 'Chiranjeevi Blood Centre & Eye Bank',
      destinationOrg: 'Osmania General Hospital Model Blood Bank',
      bloodType: BloodType.aPos,
      units: 6,
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      dispatchDate: DateTime.now().subtract(const Duration(hours: 22)),
      expectedDeliveryDate: DateTime.now().subtract(const Duration(hours: 20)),
      status: BankTransferStatus.delivered,
      transportCarrier: 'Government Emergency Medical Courier',
      trackingId: 'TRK-IN-TS-62840',
    ),
  ];

  List<BankDonationIntakeRecord> bankIntakeRecords = [
    BankDonationIntakeRecord(
      intakeId: 'INTK-7411',
      donorId: 'VP-IND-DNR-8942 (Rajesh V. Kumar)',
      bloodType: BloodType.oNeg,
      donationDate: DateTime.now().subtract(const Duration(hours: 4)),
      donationCenter: 'Jubilee Hills Main Center - Bay 3',
      units: 1,
      screeningStatus: 'Negative: HIV, HepB, HepC, Syphilis, NAT Non-reactive',
      processingStatus: BankIntakeStatus.stored,
      storageLocation: 'Cryo Vault Delta - Emergency Reserve',
      batchNumber: 'BATCH-ON-2026-031',
    ),
    BankDonationIntakeRecord(
      intakeId: 'INTK-7412',
      donorId: 'VP-IND-DNR-6621 (Priya Patel)',
      bloodType: BloodType.aPos,
      donationDate: DateTime.now().subtract(const Duration(hours: 7)),
      donationCenter: 'Cyber Gateway Mega Camp',
      units: 1,
      screeningStatus: 'Serology Cleared / Centrifugation Complete',
      processingStatus: BankIntakeStatus.processing,
      storageLocation: 'Processing Lab Bench 2',
      batchNumber: 'BATCH-AP-2026-041',
      campName: 'Cyber Gateway Annual Mega Drive',
    ),
    BankDonationIntakeRecord(
      intakeId: 'INTK-7413',
      donorId: 'VP-IND-DNR-5510 (Manoj Verma)',
      bloodType: BloodType.bPos,
      donationDate: DateTime.now().subtract(const Duration(hours: 9)),
      donationCenter: 'Hitec City Mobile Bus Unit #2',
      units: 1,
      screeningStatus: 'Preliminary Screening Pending (ELISA in Progress)',
      processingStatus: BankIntakeStatus.screeningPending,
      storageLocation: 'Quarantine Cold Locker Q-1',
      batchNumber: 'BATCH-BP-2026-053',
    ),
    BankDonationIntakeRecord(
      intakeId: 'INTK-7414',
      donorId: 'VP-IND-DNR-9104 (Sunita Rao)',
      bloodType: BloodType.abPos,
      donationDate: DateTime.now().subtract(const Duration(days: 1)),
      donationCenter: 'Jubilee Hills Main Center - Bay 1',
      units: 1,
      screeningStatus: 'Cleared & Component Separated (RBC + FFP)',
      processingStatus: BankIntakeStatus.stored,
      storageLocation: 'Cryo Vault Gamma - Tray 1',
      batchNumber: 'BATCH-ABP-2026-014',
    ),
  ];

  List<BankDonorRecord> bankDonorRecords = [
    BankDonorRecord(
      donorId: 'VP-IND-DNR-8942',
      bloodType: BloodType.oNeg,
      lastDonationDate: DateTime.now().subtract(const Duration(hours: 4)),
      donationCenter: 'Chiranjeevi Blood Centre',
      donationStatus: 'Approved Intake',
      eligibilityStatus: 'Cooldown Rest Active (Eligible in 89 days)',
      totalDonationsCount: 14,
      thankYouSent: true,
    ),
    BankDonorRecord(
      donorId: 'VP-IND-DNR-6621',
      bloodType: BloodType.aPos,
      lastDonationDate: DateTime.now().subtract(const Duration(hours: 7)),
      donationCenter: 'Cyber Gateway Mega Camp',
      donationStatus: 'Processing Intake',
      eligibilityStatus: 'Cooldown Rest Active',
      totalDonationsCount: 8,
      thankYouSent: false,
    ),
    BankDonorRecord(
      donorId: 'VP-IND-DNR-5510',
      bloodType: BloodType.bPos,
      lastDonationDate: DateTime.now().subtract(const Duration(hours: 9)),
      donationCenter: 'Mobile Bus Unit #2',
      donationStatus: 'Screening Pending',
      eligibilityStatus: 'Verification Pending',
      totalDonationsCount: 3,
      thankYouSent: false,
    ),
    BankDonorRecord(
      donorId: 'VP-DNR-9104',
      bloodType: BloodType.abPos,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 1)),
      donationCenter: 'Metro Central Center',
      donationStatus: 'Stored Safely',
      eligibilityStatus: 'Cooldown Rest Active',
      totalDonationsCount: 11,
      thankYouSent: true,
    ),
  ];

  List<BankAuditLogEntry> bankAuditLogs = [
    BankAuditLogEntry(
      id: 'AUD-991',
      action: 'Inventory Units Added',
      description: 'Added 4 units of O- Negative (BATCH-ON-2026-031) from intake screening.',
      staffMember: 'Marcus Thorne (Manager)',
      staffRole: 'Blood Bank Manager',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      category: 'inventory',
    ),
    BankAuditLogEntry(
      id: 'AUD-992',
      action: 'Hospital Requisition Approved',
      description: 'Approved Requisition HREQ-8901 (4 units O-) for Seattle Grace Memorial Trauma Center.',
      staffMember: 'Marcus Thorne (Manager)',
      staffRole: 'Blood Bank Manager',
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      category: 'request',
    ),
    BankAuditLogEntry(
      id: 'AUD-993',
      action: 'Emergency Transfer Dispatched',
      description: 'Dispatched 4 units O- Negative via Cold-Chain Express Unit #7 (TRF-9021).',
      staffMember: 'Elena Ortiz (Coordinator)',
      staffRole: 'Hospital Coordinator',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      category: 'transfer',
    ),
    BankAuditLogEntry(
      id: 'AUD-994',
      action: 'Intake Blood Screened',
      description: 'Cleared serology and NAT negative for donor VP-DNR-8942; moved to cryo vault.',
      staffMember: 'Dr. Aaron Patel (Intake Specialist)',
      staffRole: 'Donation Intake Staff',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      category: 'intake',
    ),
    BankAuditLogEntry(
      id: 'AUD-995',
      action: 'Low Stock Alert Broadcast',
      description: 'Triggered automated SMS broadcast to registered B- donors.',
      staffMember: 'System Automated Monitor',
      staffRole: 'Administrator Daemon',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      category: 'alert',
    ),
  ];

  // Overview Counts & Helpers
  int get bankTotalUnits => bankInventory.fold(0, (sum, i) => sum + i.totalUnits);
  int get bankAvailableUnits => bankInventory.fold(0, (sum, i) => sum + i.availableUnits);
  int get bankReservedUnits => bankInventory.fold(0, (sum, i) => sum + i.reservedUnits);
  int get bankExpiringSoonUnits => bankExpiryItems.where((e) => !e.isDiscarded && e.timeframe != 'expired').fold(0, (sum, e) => sum + e.units);
  int get bankLowStockCount => bankInventory.where((i) => i.isBelowThreshold).length;
  int get bankPendingRequestsCount => bankHospitalRequests.where((r) => r.status == BankHospitalReqStatus.pending || r.status == BankHospitalReqStatus.underReview).length;
  int get bankIncomingDonationsCount => bankIntakeRecords.where((i) => i.processingStatus != BankIntakeStatus.stored && i.processingStatus != BankIntakeStatus.rejected).length;
  int get bankTransfersInProgressCount => bankTransfers.where((t) => t.status == BankTransferStatus.inTransit || t.status == BankTransferStatus.prepared).length;

  // Inventory Management Actions
  void addBankInventoryUnits(BloodType type, int units, String batchNumber, String storage) {
    final item = bankInventory.firstWhere((i) => i.bloodType == type);
    item.availableUnits += units;
    if (item.availableUnits >= item.minimumStockThreshold && item.status == BankInventoryStatus.lowStock) {
      item.status = BankInventoryStatus.normal;
    }
    _addBankAuditLog(
      action: 'Inventory Units Added',
      description: 'Added $units units of ${type.label} (Batch $batchNumber) into $storage.',
      category: 'inventory',
    );
    notifyListeners();
  }

  void reserveBankUnits(BloodType type, int units, String reason) {
    final item = bankInventory.firstWhere((i) => i.bloodType == type);
    if (item.availableUnits >= units) {
      item.availableUnits -= units;
      item.reservedUnits += units;
      _addBankAuditLog(
        action: 'Units Reserved',
        description: 'Reserved $units units of ${type.label} for: $reason.',
        category: 'inventory',
      );
      notifyListeners();
    }
  }

  void releaseBankReservedUnits(BloodType type, int units) {
    final item = bankInventory.firstWhere((i) => i.bloodType == type);
    final count = units > item.reservedUnits ? item.reservedUnits : units;
    item.reservedUnits -= count;
    item.availableUnits += count;
    _addBankAuditLog(
      action: 'Reserved Units Released',
      description: 'Released $count units of ${type.label} back to available inventory.',
      category: 'inventory',
    );
    notifyListeners();
  }

  void markBankUnitsUsed(BloodType type, int units, String requisitionRef, {bool fromReserved = false}) {
    final item = bankInventory.firstWhere((i) => i.bloodType == type);
    int used = 0;
    if (fromReserved) {
      if (item.reservedUnits >= units) {
        used = units;
        item.reservedUnits -= units;
      } else {
        used = item.reservedUnits;
        final remainder = units - used;
        item.reservedUnits = 0;
        final fromAvail = remainder.clamp(0, item.availableUnits);
        item.availableUnits -= fromAvail;
        used += fromAvail;
      }
    } else {
      if (item.availableUnits >= units) {
        used = units;
        item.availableUnits -= units;
      } else {
        used = item.availableUnits;
        final remainder = units - used;
        item.availableUnits = 0;
        final fromRes = remainder.clamp(0, item.reservedUnits);
        item.reservedUnits -= fromRes;
        used += fromRes;
      }
    }
    item.usedUnits += used;
    if (item.availableUnits < item.minimumStockThreshold) {
      item.status = BankInventoryStatus.lowStock;
    }
    _addBankAuditLog(
      action: 'Units Marked Used',
      description: 'Marked $used units of ${type.label} as utilized for requisition $requisitionRef.',
      category: 'inventory',
    );
    notifyListeners();
  }

  void markBankUnitsExpired(BloodType type, int units, String reason) {
    final item = bankInventory.firstWhere((i) => i.bloodType == type);
    final count = units.clamp(0, item.availableUnits);
    item.availableUnits -= count;
    if (item.expiringUnits >= count) {
      item.expiringUnits -= count;
    } else {
      item.expiringUnits = 0;
    }
    if (item.availableUnits < item.minimumStockThreshold) {
      item.status = BankInventoryStatus.lowStock;
    }
    _addBankAuditLog(
      action: 'Units Marked Expired',
      description: 'Discarded $count units of ${type.label}. Reason: $reason.',
      category: 'inventory',
    );
    notifyListeners();
  }

  void adjustBankInventory(BloodType type, int newAvailable, String note) {
    final item = bankInventory.firstWhere((i) => i.bloodType == type);
    final diff = newAvailable - item.availableUnits;
    item.availableUnits = newAvailable;
    item.status = newAvailable < item.minimumStockThreshold ? BankInventoryStatus.lowStock : BankInventoryStatus.normal;
    _addBankAuditLog(
      action: 'Inventory Stock Adjusted',
      description: 'Manual adjustment on ${type.label} ($diff units change). Audit note: $note.',
      category: 'inventory',
    );
    notifyListeners();
  }

  // Low Stock Actions
  void reviewLowStockAlert(String id) {
    final alert = bankLowStockAlerts.firstWhere((a) => a.id == id);
    alert.isReviewed = true;
    _addBankAuditLog(
      action: 'Low Stock Alert Reviewed',
      description: 'Acknowledged deficit on ${alert.bloodType.label} (Current: ${alert.currentUnits} units).',
      category: 'alert',
    );
    notifyListeners();
  }

  void notifyDonorsForLowStock(
    BloodType type, {
    int donorCount = 28,
    int radiusKm = 15,
    List<String> channels = const ['Emergency SMS', 'VitalPulse App Push'],
    String? customMessage,
  }) {
    final ch = channels.join(', ');
    _addBankAuditLog(
      action: 'Donor Priority Broadcast',
      description: 'Dispatched emergency appeal for ${type.label} to $donorCount eligible donors within $radiusKm km via $ch.',
      category: 'alert',
    );
    notifyListeners();
  }

  void requestTransferForLowStock(
    BloodType type,
    int units,
    String fromBank, {
    String urgency = 'Urgent',
    String carrier = 'Cold-Chain Van Relay (Temp 2-6°C)',
    String? notes,
  }) {
    final newTransfer = BankTransferItem(
      id: 'TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      sourceOrg: fromBank,
      destinationOrg: bankProfile.name,
      bloodType: type,
      units: units,
      requestDate: DateTime.now(),
      expectedDeliveryDate: DateTime.now().add(const Duration(hours: 2)),
      status: BankTransferStatus.requested,
      transportCarrier: carrier,
      trackingId: 'TRK-IN-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    bankTransfers.insert(0, newTransfer);
    _addBankAuditLog(
      action: 'Inbound Requisition Dispatched',
      description: 'Requisition for $units units of ${type.label} sent to $fromBank ($urgency priority via $carrier). Tracking: ${newTransfer.trackingId}.',
      category: 'transfer',
    );
    notifyListeners();
  }

  // Expiry Actions
  void prioritizeExpiryBatch(String batchNumber) {
    final item = bankExpiryItems.firstWhere((e) => e.batchNumber == batchNumber);
    item.isPrioritized = true;
    _addBankAuditLog(
      action: 'Expiry Batch Prioritized',
      description: 'Tagged batch $batchNumber for immediate dispatch to upcoming surgical requisitions.',
      category: 'inventory',
    );
    notifyListeners();
  }

  void recordWastageReason(String batchNumber, String reason) {
    final item = bankExpiryItems.firstWhere((e) => e.batchNumber == batchNumber);
    item.isDiscarded = true;
    item.wastageReason = reason;
    _addBankAuditLog(
      action: 'Wastage Recorded',
      description: 'Documented batch $batchNumber discarded. Reason: $reason.',
      category: 'inventory',
    );
    notifyListeners();
  }

  // Hospital Requests Actions
  void approveBankHospitalRequest(String id, int units) {
    final req = bankHospitalRequests.firstWhere((r) => r.id == id);
    req.status = BankHospitalReqStatus.approved;
    req.unitsAssigned = units;
    reserveBankUnits(req.bloodType, units, 'Assigned to ${req.hospitalName} for ${req.patientRefId}');
    _addBankAuditLog(
      action: 'Hospital Requisition Approved',
      description: 'Approved Requisition $id for ${req.hospitalName} ($units units ${req.bloodType.label}).',
      category: 'request',
    );
    notifyListeners();
  }

  void rejectBankHospitalRequest(String id, String reason) {
    final req = bankHospitalRequests.firstWhere((r) => r.id == id);
    req.status = BankHospitalReqStatus.rejected;
    req.internalNotes = 'Rejected: $reason';
    _addBankAuditLog(
      action: 'Hospital Requisition Rejected',
      description: 'Rejected Requisition $id. Reason: $reason.',
      category: 'request',
    );
    notifyListeners();
  }

  void fulfillBankHospitalRequest(String id) {
    final req = bankHospitalRequests.firstWhere((r) => r.id == id);
    req.status = BankHospitalReqStatus.fulfilled;
    markBankUnitsUsed(req.bloodType, req.unitsAssigned, req.id);
    _addBankAuditLog(
      action: 'Hospital Requisition Fulfilled',
      description: 'Completed blood dispatch for $id to ${req.hospitalName}.',
      category: 'request',
    );
    notifyListeners();
  }

  void partiallyFulfillBankHospitalRequest(String id, int units) {
    final req = bankHospitalRequests.firstWhere((r) => r.id == id);
    req.status = BankHospitalReqStatus.partiallyFulfilled;
    req.unitsAssigned = units;
    reserveBankUnits(req.bloodType, units, 'Partial fulfillment for ${req.hospitalName}');
    _addBankAuditLog(
      action: 'Requisition Partially Fulfilled',
      description: 'Partially fulfilled $id with $units of ${req.unitsRequired} units.',
      category: 'request',
    );
    notifyListeners();
  }

  void addBankHospitalRequestInternalNote(String id, String note) {
    final req = bankHospitalRequests.firstWhere((r) => r.id == id);
    req.internalNotes = '${req.internalNotes}\n[${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}] $note'.trim();
    notifyListeners();
  }

  // Transfer Actions
  void createBankTransfer({
    required String destination,
    required BloodType type,
    required int units,
    required String carrier,
    String? sourceOrg,
    String urgency = 'Standard',
  }) {
    final src = sourceOrg ?? bankProfile.name;
    final isOutbound = src == bankProfile.name;
    final newTransfer = BankTransferItem(
      id: 'TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      sourceOrg: src,
      destinationOrg: destination,
      bloodType: type,
      units: units,
      requestDate: DateTime.now(),
      dispatchDate: DateTime.now(),
      expectedDeliveryDate: DateTime.now().add(
        urgency == 'STAT / Emergency' ? const Duration(minutes: 45) : const Duration(hours: 2),
      ),
      status: isOutbound ? BankTransferStatus.prepared : BankTransferStatus.requested,
      transportCarrier: carrier,
      trackingId: 'TRK-CC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    if (isOutbound) {
      reserveBankUnits(type, units, 'Transfer to $destination ($urgency)');
    }
    bankTransfers.insert(0, newTransfer);
    _addBankAuditLog(
      action: isOutbound ? 'Transfer Prepared' : 'Transfer Requisition Placed',
      description: 'Transfer of $units units of ${type.label} to $destination ($urgency via $carrier). Waybill: ${newTransfer.trackingId}.',
      category: 'transfer',
    );
    notifyListeners();
  }

  void updateBankTransferStatus(String id, BankTransferStatus newStatus) {
    final trf = bankTransfers.firstWhere((t) => t.id == id);
    trf.status = newStatus;
    if (newStatus == BankTransferStatus.inTransit && trf.dispatchDate == null) {
      trf.dispatchDate = DateTime.now();
    }
    if (newStatus == BankTransferStatus.delivered) {
      markBankUnitsUsed(trf.bloodType, trf.units, trf.id);
    }
    _addBankAuditLog(
      action: 'Transfer Status Updated',
      description: 'Transfer ${trf.id} status updated to ${newStatus.label}.',
      category: 'transfer',
    );
    notifyListeners();
  }

  // Intake & Donor Actions
  void addDonationIntake({
    required String donorId,
    required BloodType type,
    required int units,
    required String center,
    required String screening,
    required String batch,
    String campName = '',
  }) {
    final newIntake = BankDonationIntakeRecord(
      intakeId: 'INTK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      donorId: donorId,
      bloodType: type,
      donationDate: DateTime.now(),
      donationCenter: center,
      units: units,
      screeningStatus: screening,
      processingStatus: BankIntakeStatus.donationReceived,
      storageLocation: 'Quarantine Cold Locker Q-2',
      batchNumber: batch,
      campName: campName,
    );
    bankIntakeRecords.insert(0, newIntake);
    _addBankAuditLog(
      action: 'Donation Intake Logged',
      description: 'Logged intake of $units units from $donorId ($batch).',
      category: 'intake',
    );
    notifyListeners();
  }

  void updateIntakeStatus(String intakeId, BankIntakeStatus status, String screening) {
    final record = bankIntakeRecords.firstWhere((r) => r.intakeId == intakeId);
    record.processingStatus = status;
    record.screeningStatus = screening;
    if (status == BankIntakeStatus.stored) {
      addBankInventoryUnits(record.bloodType, record.units, record.batchNumber, 'Cryo Main Vault');
    }
    _addBankAuditLog(
      action: 'Intake Processing Updated',
      description: 'Intake $intakeId updated to ${status.label}. Screening: $screening.',
      category: 'intake',
    );
    notifyListeners();
  }

  void sendDonorThankYou(String donorId) {
    final donor = bankDonorRecords.firstWhere((d) => d.donorId == donorId, orElse: () => bankDonorRecords.first);
    donor.thankYouSent = true;
    _addBankAuditLog(
      action: 'Donor Thank-You Dispatched',
      description: 'Sent SMS and Email appreciation to $donorId for recent donation.',
      category: 'intake',
    );
    notifyListeners();
  }

  // Staff Role & Facility Profile
  void setBankStaffRole(BankStaffRole role) {
    bankCurrentStaffRole = role;
    _addBankAuditLog(
      action: 'Staff Role Switched',
      description: 'Active operator role switched to ${role.roleName}.',
      category: 'alert',
    );
    notifyListeners();
  }

  void updateBankFacilityProfile(BankFacilityProfile newProfile) {
    bankProfile = newProfile;
    _addBankAuditLog(
      action: 'Facility Profile Updated',
      description: 'Updated operating details and contact configuration.',
      category: 'alert',
    );
    notifyListeners();
  }

  void addBankAuditLog(String action, String description, [String category = 'Operations']) {
    _addBankAuditLog(action: action, description: description, category: category);
    notifyListeners();
  }

  void _addBankAuditLog({
    required String action,
    required String description,
    required String category,
  }) {
    bankAuditLogs.insert(
      0,
      BankAuditLogEntry(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        action: action,
        description: description,
        staffMember: 'Dr. Ramesh Rao (Medical Director)',
        staffRole: bankCurrentStaffRole.roleName,
        timestamp: DateTime.now(),
        category: category,
      ),
    );
  }
}


