import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/astrology_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/freeastrology_firebase_sync.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/data_preloader_service.dart';
import '../../../../core/services/astrology_sync_on_login.dart';
import '../../../../core/firebase/firestore_seeder.dart';
import '../../../../core/widgets/app_background.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/auth/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _loginUsingEmail = false;

  String _countryLabel = 'VN';
  String _dialCode = '+84';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _loginUsingEmail ? 'Email is required' : 'Phone number is required';
    }
    if (_loginUsingEmail) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Please enter a valid email';
      }
    } else {
      final digitsOnly = value.replaceAll(RegExp(r'\\s+|-'), '');
      if (digitsOnly.length < 9) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _showLoginCountryPicker() async {
    final options = [
      {'label': 'Vietnam', 'code': 'VN', 'dial': '+84'},
      {'label': 'United States', 'code': 'US', 'dial': '+1'},
      {'label': 'United Kingdom', 'code': 'UK', 'dial': '+44'},
      {'label': 'Japan', 'code': 'JP', 'dial': '+81'},
      {'label': 'South Korea', 'code': 'KR', 'dial': '+82'},
      {'label': 'China', 'code': 'CN', 'dial': '+86'},
      {'label': 'Thailand', 'code': 'TH', 'dial': '+66'},
      {'label': 'Singapore', 'code': 'SG', 'dial': '+65'},
      {'label': 'Malaysia', 'code': 'MY', 'dial': '+60'},
      {'label': 'Australia', 'code': 'AU', 'dial': '+61'},
      {'label': 'Canada', 'code': 'CA', 'dial': '+1'},
    ];

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return SafeArea(
          child: SizedBox(
            height: height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Choose country',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return ListTile(
                        title: Text(option['label']!),
                        subtitle: Text(option['code']!),
                        trailing: Text(option['dial']!),
                        onTap: () => Navigator.of(context).pop(option),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _countryLabel = result['code']!;
        _dialCode = result['dial']!;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService.instance;
      UserCredential? userCredential;

      if (_loginUsingEmail) {
        // Email/Password login - validate with Firebase
        userCredential = await authService.loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Phone number login - validate with Firestore
        // Note: Phone login requires password for now
        // In production, implement phone auth with OTP
        // Normalize phone number (remove spaces, ensure proper format)
        final phoneInput = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
        final phoneNumber = '$_dialCode$phoneInput';
        print('📱 Login attempt with phone: $phoneNumber');
        
        // For phone login, we need password
        // Check if password field exists (you may need to add it to UI)
        final password = _passwordController.text;
        if (password.isEmpty) {
          throw Exception('Password is required for phone login');
        }
        
        userCredential = await authService.loginWithPhone(
          phoneNumber: phoneNumber,
          password: password,
        );
      }

      if (userCredential.user != null) {
        final userId = userCredential.user!.uid;
        
        // Sync astrology data for this user (ensures each user has their own data)
        try {
          final syncService = AstrologySyncOnLogin.instance;
          await syncService.syncAfterLogin();
        } catch (e) {
          print('⚠️ Error syncing astrology data on login: $e');
          // Continue even if sync fails
        }
        
        // Preload all data in background (non-blocking)
        // This includes user profile, home content, etc.
        DataPreloaderService.instance.preloadAllData(userId).catchError((e) {
          print('⚠️ Error preloading data: $e');
        });

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/app');
        }
      } else {
        throw Exception('Login failed: No user returned');
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleLoginMethod() {
    if (mounted) {
      setState(() {
        _loginUsingEmail = !_loginUsingEmail;
        _emailController.clear();
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      // Sign in with Google
      final authService = AuthService.instance;
      final userCredential = await authService.signInWithGoogle();
      
      if (userCredential.user == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to sign in with Google';
            _isLoading = false;
          });
        }
        return;
      }

      final userId = userCredential.user!.uid;
      
      // Sync astrology data for this user
      try {
        final syncService = AstrologySyncOnLogin.instance;
        await syncService.syncAfterLogin();
      } catch (e) {
        print('⚠️ Error syncing astrology data on login: $e');
        // Continue even if sync fails
      }
      
      // Preload all data in background (non-blocking)
      DataPreloaderService.instance.preloadAllData(userId).catchError((e) {
        print('⚠️ Error preloading data: $e');
      });

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/app');
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign-in failed. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0D42),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Form(
            key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                _TopBar(
                  onBack: () {
                    // If we can pop, pop. Otherwise, navigate to onboarding
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/onboarding');
                    }
                  },
              ),
              const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                _FieldHeader(
                  label: _loginUsingEmail ? 'Email Address' : 'Phone Number',
                  actionLabel: _loginUsingEmail
                      ? 'Login using Phone'
                      : 'Login using Email',
                  onActionTap: _toggleLoginMethod,
                ),
              const SizedBox(height: 8),
                if (_loginUsingEmail)
                  _LoginTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    hintText: 'you@example.com',
                    validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                    showLabel: false,
                  )
                else
                  _LoginPhoneField(
                    countryLabel: _countryLabel,
                    dialCode: _dialCode,
                    controller: _phoneController,
                    validator: _validateEmail,
                    onCountryTap: _showLoginCountryPicker,
                    showLabel: false,
              ),
                const SizedBox(height: 20),
                _FieldHeader(
                  label: 'Create a Password',
                  actionLabel: null,
                  onActionTap: null,
                ),
              const SizedBox(height: 8),
                _LoginTextField(
                  label: 'Create a Password',
                  controller: _passwordController,
                  hintText: '••••••••',
                  validator: _validatePassword,
                  obscureText: _obscurePassword,
                  showLabel: false,
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Image.asset(
                      _obscurePassword
                          ? 'assets/images/app/icons/Eye-off.png'
                          : 'assets/images/app/icons/Eye.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
              ),
              const SizedBox(height: 24),
              _SocialButton(
                iconData: Icons.g_mobiledata,
                label: 'Log In with Google',
                onTap: _isLoading ? null : _handleGoogleSignIn,
              ),
                const SizedBox(height: 12),
              const _SocialButton(
                iconData: Icons.apple,
                label: 'Log In with Apple',
              ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ArrowButton(
                    onTap: _isLoading ? null : _handleLogin,
                    loading: _isLoading,
                    ),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}

class SignUpFlowPage extends StatefulWidget {
  static const routeName = '/auth/signup-flow';

  const SignUpFlowPage({super.key});

  @override
  State<SignUpFlowPage> createState() => _SignUpFlowPageState();
}

class _SignUpFlowPageState extends State<SignUpFlowPage> {
  final PageController _controller = PageController();
  int _currentStep = 0;

  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _birthTimeController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _passwordController;
  late final TextEditingController _usernameController;

  String _selectedCountryCode = 'VN';
  String _dialCode = '+84';
  bool _obscurePassword = true;
  // _isLoading is used in _completeSignUp() method (lines 460, 466, 633, 647)
  // ignore: unused_field
  bool _isLoading = false;

  static const int _stepCount = 4;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();
    _birthTimeController = TextEditingController();
    _birthPlaceController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthPlaceController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String? _validationError;

  bool _validateCurrentStep() {
    setState(() => _validationError = null);
    
    switch (_currentStep) {
      case 0: // Phone number
        if (_phoneController.text.trim().isEmpty) {
          setState(() => _validationError = 'Please enter your phone number');
          return false;
        }
        if (_phoneController.text.trim().length < 9) {
          setState(() => _validationError = 'Please enter a valid phone number');
          return false;
        }
        break;
      case 1: // Username
        if (_usernameController.text.trim().isEmpty) {
          setState(() => _validationError = 'Please enter a username');
          return false;
        }
        if (_usernameController.text.trim().length < 3) {
          setState(() => _validationError = 'Username must be at least 3 characters');
          return false;
        }
        final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
        if (!usernameRegex.hasMatch(_usernameController.text.trim())) {
          setState(() => _validationError = 'Username can only contain letters, numbers and underscores');
          return false;
        }
        break;
      case 2: // Password
        if (_passwordController.text.isEmpty) {
          setState(() => _validationError = 'Please enter a password');
          return false;
        }
        if (_passwordController.text.length < 6) {
          setState(() => _validationError = 'Password must be at least 6 characters');
          return false;
        }
        break;
      case 3: // Birth details
        if (_birthDateController.text.isEmpty) {
          setState(() => _validationError = 'Please select your birth date');
          return false;
        }
        if (_birthPlaceController.text.trim().isEmpty) {
          setState(() => _validationError = 'Please enter your birth place');
          return false;
        }
        break;
    }
    return true;
  }

  void _handleNext() {
    FocusScope.of(context).unfocus();
    
    if (!_validateCurrentStep()) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationError ?? 'Please fill in all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_currentStep == _stepCount - 1) {
      _completeSignUp();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeSignUp() async {
    try {
      // Show loading
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
        _validationError = null;
      });
      
      // Validate all fields
      if (!_validateCurrentStep()) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_validationError ?? 'Please fill in all required fields'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      // Get all form data
      final phoneNumber = '$_dialCode${_phoneController.text.trim()}';
      final password = _passwordController.text;
      final birthDateStr = _birthDateController.text.trim();
      final birthTimeStr = _birthTimeController.text.trim();
      final birthPlaceStr = _birthPlaceController.text.trim();
      final usernameStr = _usernameController.text.trim();
      
      // Validate password
      if (password.isEmpty) {
        throw Exception('Password is required');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }
      
      // Get latitude/longitude from birth place first (needed for signup)
      double latitude = 0.0;
      double longitude = 0.0;
      if (birthPlaceStr.isNotEmpty) {
        try {
          final locationService = LocationService();
          final locations = await locationService.searchAddress(birthPlaceStr);
          if (locations.isNotEmpty) {
            latitude = locations.first['latitude'] as double;
            longitude = locations.first['longitude'] as double;
          }
        } catch (e) {
          print('Error getting location coordinates: $e');
        }
      }
      
      // Parse birth date
      DateTime? birthDate;
      try {
        if (birthDateStr.contains('/')) {
          final parts = birthDateStr.split('/');
          if (parts.length == 3) {
            birthDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } else if (birthDateStr.contains('-')) {
          birthDate = DateTime.parse(birthDateStr);
        }
      } catch (e) {
        throw Exception('Invalid birth date format');
      }
      
      if (birthDate == null) {
        throw Exception('Birth date is required');
      }
      
      // Create user account with AuthService (validates against Firebase)
      final authService = AuthService.instance;
      final userCredential = await authService.signUpWithPhone(
        phoneNumber: phoneNumber,
        password: password,
        displayName: usernameStr.isNotEmpty ? usernameStr : 'User',
        birthDate: birthDateStr,
        birthTime: birthTimeStr,
        birthPlace: birthPlaceStr,
        latitude: latitude,
        longitude: longitude,
      );
      
      final userId = userCredential.user?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Failed to create user account');
      }

      // Calculate astrological signs
      final astrologyService = AstrologyService.instance;
      String sunSign = 'Unknown';
      String moonSign = 'Unknown';
      String ascendantSign = 'Unknown';

      try {
        sunSign = await astrologyService.getSunSign(birthDate);
        moonSign = await astrologyService.getMoonSign(
          birthDate,
          birthTimeStr,
          latitude: latitude,
          longitude: longitude,
        );
        ascendantSign = await astrologyService.getAscendant(
          birthDate,
          birthTimeStr,
          latitude,
          longitude,
        );
      } catch (e) {
        // Use fallback methods
        sunSign = astrologyService.getSunSignFromDate(birthDate);
        moonSign = astrologyService.getMoonSignFromDate(birthDate, birthTimeStr);
        ascendantSign = astrologyService.getAscendantFromTime(
          birthDate,
          birthTimeStr,
          latitude,
        );
      }

      // Update user profile in Firestore with astrological signs
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).update({
        'sunSign': sunSign,
        'moonSign': moonSign,
        'ascendantSign': ascendantSign,
        'planType': 'Free',
        'avatarUrl': 'assets/images/app/logo.png',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize user preferences
      await firestore.doc('user_preferences/$userId').set({
        'profileTab': 'Chart',
        'horoscopeEnabled': true,
        'notificationsSkipped': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Sync astrology data from FreeAstrologyAPI to Firebase
      if (latitude != 0.0 && longitude != 0.0) {
        try {
          final syncService = FreeAstrologyFirebaseSync.instance;
          await syncService.syncAllUserAstrologyData(
            userId: userId,
            birthDate: birthDate,
            birthTime: birthTimeStr,
            latitude: latitude,
            longitude: longitude,
            sunSign: sunSign,
          );
        } catch (e) {
          print('Error syncing astrology data: $e');
          // Continue even if sync fails
        }
      }

      // Initialize user-specific content (notification prefs, chat thread)
      final seeder = FirestoreSeeder(firestore);
      await seeder.ensureUserContent(userId);

      // Preload all data in background (non-blocking)
      DataPreloaderService.instance.preloadAllData(userId).catchError((e) {
        print('⚠️ Error preloading data: $e');
      });

      // Navigate to app
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/app');
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        print('❌ Signup error: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('❌ Unexpected signup error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create account: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showCountryPicker() async {
    final options = [
      {'label': 'Vietnam', 'code': 'VN', 'dial': '+84'},
      {'label': 'United States', 'code': 'US', 'dial': '+1'},
      {'label': 'United Kingdom', 'code': 'UK', 'dial': '+44'},
      {'label': 'Japan', 'code': 'JP', 'dial': '+81'},
      {'label': 'South Korea', 'code': 'KR', 'dial': '+82'},
      {'label': 'China', 'code': 'CN', 'dial': '+86'},
      {'label': 'Thailand', 'code': 'TH', 'dial': '+66'},
      {'label': 'Singapore', 'code': 'SG', 'dial': '+65'},
      {'label': 'Malaysia', 'code': 'MY', 'dial': '+60'},
      {'label': 'Australia', 'code': 'AU', 'dial': '+61'},
      {'label': 'Canada', 'code': 'CA', 'dial': '+1'},
    ];
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return SafeArea(
          child: SizedBox(
            height: height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text('Choose country',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return ListTile(
                        title: Text(option['label']!),
                        subtitle: Text(option['code']!),
                        trailing: Text(option['dial']!),
                        onTap: () => Navigator.of(context).pop(option),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCountryCode = result['code']!;
        _dialCode = result['dial']!;
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
    );
    if (picked == null) return;
    final formatted =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    setState(() {
      _birthDateController.text = formatted;
    });
  }

  Future<void> _pickBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final minute = picked.minute.toString().padLeft(2, '0');
    final suffix = picked.period == DayPeriod.am ? 'AM' : 'PM';
    final formatted = '${hour.toString().padLeft(2, '0')}:$minute $suffix';
    setState(() {
      _birthTimeController.text = formatted;
    });
  }

  void _setBirthTimeValue(String value) {
    setState(() {
      _birthTimeController.text = value;
    });
  }

  Future<void> _showLocationSearch() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LocationSearchSheet(service: _locationService);
      },
    );
    if (result != null && mounted) {
      setState(() {
        _birthPlaceController.text = result['display_name'] ?? '';
      });
    }
  }

  void _handleBack() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _PhoneNumberStep(
        countryCode: _selectedCountryCode,
        dialCode: _dialCode,
        controller: _phoneController,
        onCountryTap: _showCountryPicker,
        onBack: _handleBack,
      ),
      _UsernameStep(
        controller: _usernameController,
        onBack: _handleBack,
      ),
      _PasswordStep(
        controller: _passwordController,
        obscureText: _obscurePassword,
        onToggleVisibility: () =>
            setState(() => _obscurePassword = !_obscurePassword),
        onBack: _handleBack,
      ),
      _BirthDetailsStep(
        birthDateController: _birthDateController,
        birthTimeController: _birthTimeController,
        birthPlaceController: _birthPlaceController,
        onPickBirthDate: _pickBirthDate,
        onPickBirthTime: _pickBirthTime,
        onUnknownTime: () => _setBirthTimeValue('Unknown'),
        onPickPlace: _showLocationSearch,
        onBack: _handleBack,
      ),
    ];

    return Scaffold(
      body: AppBackground(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: pages,
              ),
              Positioned(
                right: 24,
                bottom: 84,
                child: _NextArrowButton(onTap: _handleNext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.showLabel = true,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (showLabel) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class _LoginPhoneField extends StatelessWidget {
  const _LoginPhoneField({
    required this.countryLabel,
    required this.dialCode,
    required this.controller,
    required this.validator,
    required this.onCountryTap,
    this.showLabel = true,
  });

  final String countryLabel;
  final String dialCode;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final VoidCallback onCountryTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFF614B9F);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            'Phone Number',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (showLabel) const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCountryTap,
                behavior: HitTestBehavior.translucent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dialCode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Image.asset(
                      'assets/images/app/icons/Normal Down.png',
                      height: 14,
                      width: 14,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  validator: validator,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '921 345 - 67 - 89',
                    hintStyle: theme.textTheme.titleMedium?.copyWith(
                      color: accentColor.withValues(alpha: 0.9),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  cursorColor: accentColor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Log In',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _FieldHeader extends StatelessWidget {
  const _FieldHeader({
    required this.label,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.onTap, required this.loading});

  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
          ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
    );
  }
}

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({
    required this.countryLabel,
    required this.dialCode,
    required this.controller,
    required this.onCountryTap,
  });

  final String countryLabel;
  final String dialCode;
  final TextEditingController controller;
  final VoidCallback onCountryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFF614B9F);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onCountryTap,
                behavior: HitTestBehavior.translucent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dialCode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Image.asset(
                      'assets/images/app/icons/Normal Down.png',
                      height: 14,
                      width: 14,
                      color: accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Theme(
                  data: theme.copyWith(
                    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    cursorColor: accentColor,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: accentColor,
                    ),
                    decoration: InputDecoration(
                      hintText: '921 345 - 67 - 89',
                      hintStyle: theme.textTheme.titleMedium
                          ?.copyWith(color: accentColor.withValues(alpha: 0.9)),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'We use this to confirm your login, find your friends, and make sure no one poses as you. If you need to reset your password we can verify you by this number. Carrier rates may apply.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneNumberStep extends StatelessWidget {
  const _PhoneNumberStep({
    required this.countryCode,
    required this.dialCode,
    required this.controller,
    required this.onCountryTap,
    required this.onBack,
  });

  final String countryCode;
  final String dialCode;
  final TextEditingController controller;
  final VoidCallback onCountryTap;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: 'Phone Number', onBack: onBack),
          const SizedBox(height: 24),
          Text(
            'Enter your phone number, please',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We use this to confirm your login, find your friends, and ensure no one poses as you.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _PhoneNumberField(
            countryLabel: countryCode,
            dialCode: dialCode,
            controller: controller,
            onCountryTap: onCountryTap,
          ),
        ],
      ),
    );
  }
}

class _BirthDetailsStep extends StatelessWidget {
  const _BirthDetailsStep({
    required this.birthDateController,
    required this.birthTimeController,
    required this.birthPlaceController,
    required this.onPickBirthDate,
    required this.onPickBirthTime,
    required this.onUnknownTime,
    required this.onPickPlace,
    required this.onBack,
  });

  final TextEditingController birthDateController;
  final TextEditingController birthTimeController;
  final TextEditingController birthPlaceController;
  final VoidCallback onPickBirthDate;
  final VoidCallback onPickBirthTime;
  final VoidCallback onUnknownTime;
  final VoidCallback onPickPlace;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: 'Sign Up', onBack: onBack),
          const SizedBox(height: 24),
          _FieldLabel(text: 'Birth Date'),
          _UnderlinePickerRow(
            value: birthDateController.text.isEmpty
                ? 'DD - MM - YYYY'
                : birthDateController.text,
            iconAsset: 'assets/images/app/icons/Calendar.png',
            onTap: onPickBirthDate,
          ),
          const SizedBox(height: 8),
          const _LockInfoText(text: 'None of your friends can see this.'),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Birth Time', style: theme.textTheme.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: onUnknownTime,
                child: Text(
                  'I don’t know what time I was born',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          _UnderlinePickerRow(
            value: birthTimeController.text.isEmpty
                ? 'HH:MM AM/PM'
                : birthTimeController.text,
            iconAsset: 'assets/images/app/icons/Clock.png',
            onTap: onPickBirthTime,
          ),
          const SizedBox(height: 24),
          _FieldLabel(text: 'Birth Place'),
          _UnderlineEditableField(
            controller: birthPlaceController,
            hint: 'City + State/Region',
            iconAsset: 'assets/images/app/icons/Location-marker.png',
            onTap: onPickPlace,
          ),
        ],
      ),
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.onBack,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: 'Password', onBack: onBack),
          const SizedBox(height: 24),
          Text('Create a Password', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _UnderlineTextField(
            controller: controller,
            hint: '••••••',
            obscureText: obscureText,
            suffix: IconButton(
              onPressed: onToggleVisibility,
              icon: Image.asset(
                obscureText
                    ? 'assets/images/app/icons/Eye-off.png'
                    : 'assets/images/app/icons/Eye.png',
                height: 24,
                width: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Passwords must be at least 6 characters long',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _UsernameStep extends StatelessWidget {
  const _UsernameStep({
    required this.controller,
    required this.onBack,
  });

  final TextEditingController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(title: 'User Name', onBack: onBack),
          const SizedBox(height: 24),
          Text('Choose User Name', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _UnderlineTextField(
            controller: controller,
            hint: 'User_Name_2000',
          ),
          const SizedBox(height: 8),
          Text(
            'Letters, numbers and underscores only',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: Image.asset(
            'assets/images/app/icons/Normal Left.png',
            height: 24,
            width: 24,
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _UnderlinePickerRow extends StatelessWidget {
  const _UnderlinePickerRow({
    required this.value,
    required this.iconAsset,
    required this.onTap,
  });

  final String value;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                Image.asset(iconAsset, height: 24, width: 24),
              ],
            ),
          ),
        ),
        const Divider(color: AppColors.borderStrong, thickness: 1),
      ],
    );
  }
}

class _UnderlineEditableField extends StatelessWidget {
  const _UnderlineEditableField({
    required this.controller,
    required this.hint,
    this.iconAsset,
    this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final String? iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: onTap != null,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (iconAsset != null)
                Image.asset(iconAsset!, height: 24, width: 24),
            ],
          ),
        ),
        const Divider(color: AppColors.borderStrong, thickness: 1),
      ],
    );
  }
}

class _UnderlineTextField extends StatelessWidget {
  const _UnderlineTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (suffix != null) suffix!,
          ],
        ),
        const Divider(color: AppColors.borderStrong, thickness: 1),
      ],
    );
  }
}

class _LockInfoText extends StatelessWidget {
  const _LockInfoText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _NextArrowButton extends StatelessWidget {
  const _NextArrowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderStrong, width: 1.4),
          color: AppColors.surfacePrimary.withValues(alpha: 0.6),
        ),
        child: const Icon(Icons.arrow_forward, color: AppColors.primary),
      ),
    );
  }
}

class _LocationSearchSheet extends StatefulWidget {
  const _LocationSearchSheet({required this.service});

  final LocationService service;

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final TextEditingController _queryController = TextEditingController();
  List<Map<String, dynamic>> _results = const [];
  bool _isLoading = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    if (query.length < 2) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await widget.service.searchAddress(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Search Birth Place', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _queryController,
            autofocus: true,
            keyboardType: TextInputType.streetAddress,
            decoration: const InputDecoration(
              hintText: 'City + State/Region',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _runSearch,
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            )
          else if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Start typing to search places',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _results[index];
                  return ListTile(
                    title: Text(item['display_name']?.toString() ?? ''),
                    onTap: () {
                      // Convert to Map<String, String> for compatibility
                      final result = <String, String>{
                        'display_name': item['display_name']?.toString() ?? '',
                        'lat': item['lat']?.toString() ?? '',
                        'lng': item['lng']?.toString() ?? '',
                        'latitude': item['latitude']?.toString() ?? '',
                        'longitude': item['longitude']?.toString() ?? '',
                      };
                      Navigator.of(context).pop(result);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    this.iconData,
    this.onTap,
  });

  final IconData? iconData;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconData != null) ...[
              Icon(iconData, color: Colors.white, size: 24),
              const SizedBox(width: 12),
            ],
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}


