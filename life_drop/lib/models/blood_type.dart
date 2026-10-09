enum BloodType {
  aPos('A+'), aNeg('A-'), bPos('B+'), bNeg('B-'),
  abPos('AB+'), abNeg('AB-'), oPos('O+'), oNeg('O-');

  final String label;
  const BloodType(this.label);

  // Simplified mock compatibility logic for prototype
  bool canDonateTo(BloodType recipient) {
    if (this == oNeg) return true; // Universal donor
    if (recipient == abPos) return true; // Universal recipient
    if (this == recipient) return true;
    return false;
  }
}
