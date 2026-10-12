import 'blood_type.dart';

enum UserRole { donor, patient, hospital, bloodBank, admin }

class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final BloodType? bloodType;
  final String? location;
  final String? phone;
  final int donationCount;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.bloodType,
    this.location,
    this.phone,
    this.donationCount = 0,
  });
}
