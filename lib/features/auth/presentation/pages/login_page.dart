import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../onboarding/presentation/widgets/onboarding_primitives.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/auth/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Image.asset(
                  'assets/images/app/icons/Normal Left.png',
                  height: 28,
                  width: 28,
                ),
              ),
              const SizedBox(height: 24),
              Text('Log In', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Enter the email and password you used to create your Advisor account.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              _SectionLabel(text: 'Email'),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Enter your email'),
              ),
              const SizedBox(height: 24),
              _SectionLabel(text: 'Password'),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Create a Password',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      'assets/images/app/icons/Eye-off.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Log In'),
              ),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 24),
              const _SocialButton(
                iconData: Icons.g_mobiledata,
                label: 'Log In with Google',
              ),
              const SizedBox(height: 16),
              const _SocialButton(
                iconData: Icons.apple,
                label: 'Log In with Apple',
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(SignUpFlowPage.routeName);
                    },
                    child: Text(
                      'Sign up',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const HomeIndicatorBar(),
            ],
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

  void _handleNext() {
    FocusScope.of(context).unfocus();
    if (_currentStep == _stepCount - 1) {
      Navigator.of(context).pushReplacementNamed('/app');
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
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
              const Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: HomeIndicatorBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
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
    const dividerColor = Color(0xFFBCA8F4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: dividerColor.withOpacity(0.9),
                width: 1,
              ),
            ),
          ),
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
                          ?.copyWith(color: accentColor.withOpacity(0.9)),
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
          color: AppColors.surfacePrimary.withOpacity(0.6),
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
  List<Map<String, String>> _results = const [];
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
                    title: Text(item['display_name'] ?? ''),
                    onTap: () => Navigator.of(context).pop(item),
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
  const _SocialButton({required this.label, this.iconData});

  final IconData? iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {},
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: Colors.white24),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Container(height: 1, color: Colors.white24),
        ),
      ],
    );
  }
}

