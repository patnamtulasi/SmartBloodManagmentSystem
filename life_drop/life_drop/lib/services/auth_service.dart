import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/blood_type.dart';

/// Mock user credential for authentication
class MockCredential {
  final String username;
  final String password;
  final UserModel user;
  final String dashboardRoute;

  const MockCredential({
    required this.username,
    required this.password,
    required this.user,
    required this.dashboardRoute,
  });
}

/// Authentication service with mock credentials for each role.
/// Supports both Sign In and Sign Up (with in-memory registration).
class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// In-memory list of registered users initialized with default demo accounts.
  /// Persisted across instances throughout the app lifetime.
  static final List<MockCredential> _credentials = [
    // Donor credentials
    MockCredential(
      username: 'donor',
      password: 'donor123',
      user: UserModel(
        id: 'donor_001',
        name: 'Vikram Malhotra',
        role: UserRole.donor,
        bloodType: BloodType.oNeg,
        location: 'Gachibowli, Hyderabad',
        phone: '+91 98480 12345',
        donationCount: 12,
      ),
      dashboardRoute: '/donor-dashboard',
    ),
    MockCredential(
      username: 'donor2',
      password: 'donor123',
      user: UserModel(
        id: 'donor_002',
        name: 'Ananya Reddy',
        role: UserRole.donor,
        bloodType: BloodType.aPos,
        location: 'Banjara Hills, Hyderabad',
        phone: '+91 98765 67890',
        donationCount: 8,
      ),
      dashboardRoute: '/donor-dashboard',
    ),
    // Patient credentials
    MockCredential(
      username: 'patient',
      password: 'patient123',
      user: UserModel(
        id: 'patient_001',
        name: 'Pooja Sharma',
        role: UserRole.patient,
        bloodType: BloodType.oPos,
        location: 'Madhapur, Hyderabad',
        phone: '+91 98490 23489',
        donationCount: 2,
      ),
      dashboardRoute: '/patient-dashboard',
    ),
    MockCredential(
      username: 'patient2',
      password: 'patient123',
      user: UserModel(
        id: 'patient_002',
        name: 'Rahul Kumar',
        role: UserRole.patient,
        bloodType: BloodType.bPos,
        location: 'Kukatpally, Hyderabad',
        phone: '+91 99123 45678',
        donationCount: 0,
      ),
      dashboardRoute: '/patient-dashboard',
    ),
    // Hospital credentials
    MockCredential(
      username: 'hospital',
      password: 'hospital123',
      user: UserModel(
        id: 'hospital_001',
        name: 'Apollo Hospitals Admin',
        role: UserRole.hospital,
        location: 'Jubilee Hills, Hyderabad',
        phone: '+91 40 2360 7777',
      ),
      dashboardRoute: '/hospital-dashboard',
    ),
    MockCredential(
      username: 'hospital2',
      password: 'hospital123',
      user: UserModel(
        id: 'hospital_002',
        name: 'KIMS Admin',
        role: UserRole.hospital,
        location: 'Secunderabad, Hyderabad',
        phone: '+91 40 4488 5000',
      ),
      dashboardRoute: '/hospital-dashboard',
    ),
    // Blood Bank credentials
    MockCredential(
      username: 'bloodbank',
      password: 'bloodbank123',
      user: UserModel(
        id: 'bb_001',
        name: 'Chiranjeevi Blood Bank',
        role: UserRole.bloodBank,
        location: 'Jubilee Hills, Hyderabad',
        phone: '+91 40 2354 1111',
      ),
      dashboardRoute: '/blood-bank-dashboard',
    ),
    MockCredential(
      username: 'bloodbank2',
      password: 'bloodbank123',
      user: UserModel(
        id: 'bb_002',
        name: 'Red Cross Blood Centre',
        role: UserRole.bloodBank,
        location: 'Nampally, Hyderabad',
        phone: '+91 40 2320 4455',
      ),
      dashboardRoute: '/blood-bank-dashboard',
    ),
    // Admin credentials
    MockCredential(
      username: 'admin',
      password: 'admin123',
      user: UserModel(
        id: 'admin_001',
        name: 'VitalPulse Admin',
        role: UserRole.admin,
        location: 'Hyderabad, India',
      ),
      dashboardRoute: '/donor-dashboard',
    ),
  ];

  /// Check if a username is already taken
  bool isUsernameTaken(String username) {
    final trimmed = username.trim().toLowerCase();
    return _credentials.any((c) => c.username == trimmed);
  }

  /// Resolve UserRole enum and dashboard route from role string
  static ({UserRole userRole, String route}) resolveRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'donor':
        return (userRole: UserRole.donor, route: '/donor-dashboard');
      case 'patient':
        return (userRole: UserRole.patient, route: '/patient-dashboard');
      case 'hospital':
        return (userRole: UserRole.hospital, route: '/hospital-dashboard');
      case 'blood bank':
      case 'bloodbank':
        return (userRole: UserRole.bloodBank, route: '/blood-bank-dashboard');
      case 'admin':
        return (userRole: UserRole.admin, route: '/donor-dashboard');
      default:
        return (userRole: UserRole.donor, route: '/donor-dashboard');
    }
  }

  /// Attempt login with username and password.
  /// Returns the dashboard route on success, null on failure.
  Future<String?> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final trimmedUser = username.trim().toLowerCase();
    final trimmedPass = password.trim();

    final match = _credentials.cast<MockCredential?>().firstWhere(
      (c) => c!.username == trimmedUser && c.password == trimmedPass,
      orElse: () => null,
    );

    if (match != null) {
      _currentUser = match.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return match.dashboardRoute;
    } else {
      _isLoading = false;
      _errorMessage = 'Invalid username or password. Please try again.';
      notifyListeners();
      return null;
    }
  }

  /// Register a new user and log them in immediately.
  /// Returns the dashboard route on success, null on failure.
  Future<String?> signUp({
    required String username,
    required String password,
    required String fullName,
    required String role,
    BloodType? bloodType,
    String? phone,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final trimmedUser = username.trim().toLowerCase();
    final trimmedPass = password.trim();
    final trimmedName = fullName.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty || trimmedName.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Please fill in all required fields.';
      notifyListeners();
      return null;
    }

    if (trimmedUser.length < 3) {
      _isLoading = false;
      _errorMessage = 'Username must be at least 3 characters long.';
      notifyListeners();
      return null;
    }

    if (trimmedPass.length < 4) {
      _isLoading = false;
      _errorMessage = 'Password must be at least 4 characters long.';
      notifyListeners();
      return null;
    }

    if (isUsernameTaken(trimmedUser)) {
      _isLoading = false;
      _errorMessage = 'Username "$trimmedUser" is already taken. Please choose another or sign in.';
      notifyListeners();
      return null;
    }

    final roleInfo = resolveRole(role);
    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = UserModel(
      id: newId,
      name: trimmedName,
      role: roleInfo.userRole,
      bloodType: bloodType ?? (roleInfo.userRole == UserRole.donor ? BloodType.oPos : null),
      location: (location != null && location.trim().isNotEmpty) ? location.trim() : 'Hyderabad, Telangana',
      phone: (phone != null && phone.trim().isNotEmpty) ? phone.trim() : '+91 90000 00000',
      donationCount: 0,
    );

    final newCredential = MockCredential(
      username: trimmedUser,
      password: trimmedPass,
      user: newUser,
      dashboardRoute: roleInfo.route,
    );

    _credentials.add(newCredential);
    _currentUser = newUser;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    return roleInfo.route;
  }

  /// Logout the current user
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get the hint credentials for a specific role
  static ({String username, String password}) getHintForRole(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return (username: 'donor', password: 'donor123');
      case 'patient':
        return (username: 'patient', password: 'patient123');
      case 'hospital':
        return (username: 'hospital', password: 'hospital123');
      case 'blood bank':
      case 'bloodbank':
        return (username: 'bloodbank', password: 'bloodbank123');
      case 'admin':
        return (username: 'admin', password: 'admin123');
      default:
        return (username: '', password: '');
    }
  }
}
