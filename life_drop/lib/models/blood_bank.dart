import 'blood_type.dart';

class BloodBank {
  final String id;
  final String name;
  final String location;
  final Map<BloodType, int> inventory;

  BloodBank({
    required this.id,
    required this.name,
    required this.location,
    required this.inventory,
  });
}
