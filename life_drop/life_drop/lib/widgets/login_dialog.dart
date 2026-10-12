import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/blood_type.dart';
import '../services/auth_service.dart';
import '../services/mock_data_service.dart';

enum AuthMode { signIn, signUp }

/// Premium iOS-inspired login & registration dialog.
/// Supports both Sign In (with demo credentials) and Sign Up (role-tailored registration).
class LoginDialog extends StatefulWidget {
  final String role;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color lightBgColor;
  final Color borderColor;

  const LoginDialog({
    super.key,
    required this.role,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.lightBgColor,
    required this.borderColor,
  });

  /// Show the login/signup modal for a specific role
  static Future<void> show(
    BuildContext context, {
    required String role,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color lightBgColor,
    required Color borderColor,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Authentication',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return LoginDialog(
          role: role,
          subtitle: subtitle,
          icon: icon,
          accentColor: accentColor,
          lightBgColor: lightBgColor,
          borderColor: borderColor,
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curvedAnim = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curvedAnim),
          child: FadeTransition(
            opacity: curvedAnim,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> with TickerProviderStateMixin {
  AuthMode _mode = AuthMode.signIn;

  // Sign In Controllers
  final _signInUsernameController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  final _signInFormKey = GlobalKey<FormState>();

  // Sign Up Controllers
  final _signUpNameController = TextEditingController();
  final _signUpUsernameController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpLocationController = TextEditingController();
  final _signUpOrgIdController = TextEditingController();
  final _signUpFormKey = GlobalKey<FormState>();

  BloodType _selectedBloodType = BloodType.oPos;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Pre-fill demo username & password for instant convenience
    final hint = AuthService.getHintForRole(widget.role);
    _signInUsernameController.text = hint.username;
    _signInPasswordController.text = hint.password;
  }

  @override
  void dispose() {
    _signInUsernameController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpUsernameController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    _signUpPhoneController.dispose();
    _signUpLocationController.dispose();
    _signUpOrgIdController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode newMode) {
    if (_mode == newMode) return;
    setState(() {
      _mode = newMode;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) {
      _shakeController.forward(from: 0.0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final mockService = Provider.of<MockDataService>(context, listen: false);
    final route = await authService.login(
      _signInUsernameController.text,
      _signInPasswordController.text,
    );

    if (!mounted) return;

    if (route != null) {
      if (authService.currentUser != null) {
        mockService.syncWithUser(authService.currentUser!);
      }
      setState(() {
        _isLoading = false;
        _successMessage = 'Welcome back! Entering ${widget.role} Dashboard...';
      });
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(route);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = authService.errorMessage ?? 'Invalid username or password.';
      });
      _shakeController.forward(from: 0.0);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) {
      _shakeController.forward(from: 0.0);
      return;
    }

    if (_signUpPasswordController.text != _signUpConfirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match. Please verify.';
      });
      _shakeController.forward(from: 0.0);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final mockService = Provider.of<MockDataService>(context, listen: false);

    final locationText = _signUpLocationController.text.trim().isNotEmpty
        ? _signUpLocationController.text.trim()
        : 'Hyderabad, Telangana';

    final route = await authService.signUp(
      username: _signUpUsernameController.text,
      password: _signUpPasswordController.text,
      fullName: _signUpNameController.text,
      role: widget.role,
      bloodType: _isDonorOrPatient ? _selectedBloodType : null,
      phone: _signUpPhoneController.text.trim().isNotEmpty ? _signUpPhoneController.text.trim() : null,
      location: locationText,
    );

    if (!mounted) return;

    if (route != null) {
      if (authService.currentUser != null) {
        mockService.syncWithUser(authService.currentUser!);
      }
      setState(() {
        _isLoading = false;
        _successMessage = 'Account created successfully! Entering ${widget.role} Dashboard...';
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(route);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = authService.errorMessage ?? 'Registration failed. Please try again.';
      });
      _shakeController.forward(from: 0.0);
    }
  }

  void _fillHintCredentials() {
    final hint = AuthService.getHintForRole(widget.role);
    _signInUsernameController.text = hint.username;
    _signInPasswordController.text = hint.password;
    setState(() => _errorMessage = null);
  }

  bool get _isDonor => widget.role.toLowerCase() == 'donor';
  bool get _isPatient => widget.role.toLowerCase() == 'patient';
  bool get _isHospital => widget.role.toLowerCase() == 'hospital';
  bool get _isBloodBank => widget.role.toLowerCase() == 'blood bank' || widget.role.toLowerCase() == 'bloodbank';
  bool get _isDonorOrPatient => _isDonor || _isPatient;
  bool get _isOrg => _isHospital || _isBloodBank;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth > 540 ? 490.0 : screenWidth * 0.92;
    final maxHeight = screenHeight * 0.90;

    return Center(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shake = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: 0.24),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient & role badge
                    _buildHeader(context),

                    // Segmented Control (Sign In / Sign Up)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: _buildSegmentedTabs(),
                    ),

                    // Messages (Error / Success)
                    if (_errorMessage != null || _successMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: _buildStatusBanner(),
                      ),

                    // Animated Switcher between Sign In & Sign Up forms
                    AnimatedCrossFade(
                      firstChild: _buildSignInForm(),
                      secondChild: _buildSignUpForm(),
                      crossFadeState: _mode == AuthMode.signIn
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 280),
                      firstCurve: Curves.easeOutCubic,
                      secondCurve: Curves.easeOutCubic,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.lightBgColor,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Animated icon badge
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + 0.05 * _pulseController.value;
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(widget.icon, size: 30, color: widget.accentColor),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            _mode == AuthMode.signIn
                ? '${widget.role} Sign In'
                : 'Create ${widget.role} Account',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _mode == AuthMode.signIn
                ? 'Welcome back! Sign in or use demo credentials below.'
                : 'Enter your details below to register and access all features.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Sign In Tab
          Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(AuthMode.signIn),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mode == AuthMode.signIn ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _mode == AuthMode.signIn
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.logIn,
                      size: 16,
                      color: _mode == AuthMode.signIn ? widget.accentColor : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign In (Old User)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _mode == AuthMode.signIn ? FontWeight.w800 : FontWeight.w600,
                        color: _mode == AuthMode.signIn ? Colors.black : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sign Up Tab
          Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(AuthMode.signUp),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mode == AuthMode.signUp ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _mode == AuthMode.signUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.userPlus,
                      size: 16,
                      color: _mode == AuthMode.signUp ? widget.accentColor : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Up (New User)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _mode == AuthMode.signUp ? FontWeight.w800 : FontWeight.w600,
                        color: _mode == AuthMode.signUp ? Colors.black : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final isError = _errorMessage != null;
    final message = isError ? _errorMessage! : _successMessage!;
    final bgColor = isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final borderColor = isError ? const Color(0xFFFECDD3) : const Color(0xFFBBF7D0);
    final textColor = isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final icon = isError ? LucideIcons.alertCircle : LucideIcons.checkCircle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    final hint = AuthService.getHintForRole(widget.role);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Demo Credentials Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.lightBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: widget.borderColor, width: 1.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 14, color: widget.accentColor),
                          const SizedBox(width: 6),
                          Text(
                            'Demo Credentials for ${widget.role}:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: widget.accentColor,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _fillHintCredentials,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: widget.borderColor),
                          ),
                          child: Text(
                            'Autofill',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: widget.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Username: ${hint.username}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Password: ${hint.password}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Username field
            _buildLabel('Username or ID'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signInUsernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: 'e.g. ${hint.username}',
                prefixIcon: LucideIcons.user,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your username' : null,
            ),

            const SizedBox(height: 14),

            // Password field
            _buildLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signInPasswordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignIn(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: 'Enter password',
                prefixIcon: LucideIcons.lock,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your password' : null,
            ),

            const SizedBox(height: 18),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignIn,
                style: _buttonStyle(),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.logIn, size: 17),
                          const SizedBox(width: 8),
                          Text(
                            'Sign In & Enter ${widget.role} Dashboard',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 14),

            // Switch to Sign Up prompt
            Center(
              child: GestureDetector(
                onTap: () => _switchMode(AuthMode.signUp),
                child: RichText(
                  text: TextSpan(
                    text: "New here? Don't have an account? ",
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: 'Sign Up (Create Account)',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Primary Name Field (Donor Name / Patient Name / Hospital Name / Blood Bank Name)
            _buildLabel(_getPrimaryNameLabel()),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpNameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: _getPrimaryNameHint(),
                prefixIcon: _isOrg ? LucideIcons.building2 : LucideIcons.userCheck,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your ${_getPrimaryNameLabel().toLowerCase()}';
                }
                return null;
              },
            ),

            // 2. Org License / Registration Number (For Hospital & Blood Bank)
            if (_isOrg) ...[
              const SizedBox(height: 12),
              _buildLabel(_isHospital ? 'NABH / Hospital Registration ID' : 'Govt Blood Bank License Number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _signUpOrgIdController,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
                decoration: _inputDecoration(
                  hint: _isHospital ? 'e.g. NABH-APOLLO-9041' : 'e.g. LIC-RED-CROSS-4482',
                  prefixIcon: LucideIcons.badgeCheck,
                ),
              ),
            ],

            // 3. Blood Group Selector (For Donor & Patient)
            if (_isDonorOrPatient) ...[
              const SizedBox(height: 12),
              _buildLabel(_isDonor ? 'Donor Blood Group' : 'Required Patient Blood Group'),
              const SizedBox(height: 6),
              _buildBloodGroupChips(),
            ],

            const SizedBox(height: 12),

            // 4. Location / City
            _buildLabel(_isOrg ? 'Facility Address & City' : 'Your City / Location'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpLocationController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: 'e.g. Hyderabad, Telangana',
                prefixIcon: LucideIcons.mapPin,
              ),
            ),

            const SizedBox(height: 12),

            // 5. Contact Phone
            _buildLabel(_isHospital ? 'Emergency Trauma Hotline' : (_isBloodBank ? 'Blood Bank Desk Phone' : 'Contact Phone Number')),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpPhoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: '+91 98765 43210',
                prefixIcon: LucideIcons.phone,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a contact number';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // 6. Username
            _buildLabel('Choose Login Username'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpUsernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: 'e.g. my_${widget.role.toLowerCase().replaceAll(' ', '_')}',
                prefixIcon: LucideIcons.atSign,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please choose a username';
                if (v.trim().length < 3) return 'Username must be at least 3 characters';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // 7. Password
            _buildLabel('Create Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpPasswordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: 'Minimum 4 characters',
                prefixIcon: LucideIcons.lock,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a password';
                if (v.trim().length < 4) return 'Password must be at least 4 characters';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // 8. Confirm Password
            _buildLabel('Confirm Password'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signUpConfirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignUp(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
              decoration: _inputDecoration(
                hint: 'Re-enter your password',
                prefixIcon: LucideIcons.shieldCheck,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  child: Icon(
                    _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please confirm your password';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Sign Up Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: _buttonStyle(),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.userPlus, size: 17),
                          const SizedBox(width: 8),
                          Text(
                            'Sign Up & Enter ${widget.role} Dashboard',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 14),

            // Switch to Sign In prompt
            Center(
              child: GestureDetector(
                onTap: () => _switchMode(AuthMode.signIn),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: 'Sign In (Old User)',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPrimaryNameLabel() {
    if (_isDonor) return 'Donor Full Name';
    if (_isPatient) return 'Patient / Recipient Name';
    if (_isHospital) return 'Hospital / Medical Facility Name';
    if (_isBloodBank) return 'Blood Bank / Center Name';
    return 'Full Name';
  }

  String _getPrimaryNameHint() {
    if (_isDonor) return 'e.g. Vikram Malhotra';
    if (_isPatient) return 'e.g. Pooja Sharma';
    if (_isHospital) return 'e.g. Apollo Multi-Specialty Hospital';
    if (_isBloodBank) return 'e.g. Chiranjeevi Blood Centre';
    return 'e.g. John Doe';
  }

  Widget _buildBloodGroupChips() {
    final bloodGroups = [
      BloodType.aPos,
      BloodType.aNeg,
      BloodType.bPos,
      BloodType.bNeg,
      BloodType.oPos,
      BloodType.oNeg,
      BloodType.abPos,
      BloodType.abNeg,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: bloodGroups.map((type) {
        final isSelected = _selectedBloodType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedBloodType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? widget.accentColor : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? widget.accentColor : const Color(0xFFCBD5E1),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              type.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      prefixIcon: Icon(prefixIcon, size: 17, color: widget.accentColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: widget.accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: widget.accentColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: widget.accentColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
    );
  }
}
