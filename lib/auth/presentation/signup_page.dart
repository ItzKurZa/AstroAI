import 'package:flutter/material.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

class SignupPage extends StatefulWidget {
  static const String routeName = '/signup';

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.light.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(KSizes.margin8x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: KSizes.margin8x),
            Text('User Name', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: KSizes.margin2x),
            TextField(decoration: InputDecoration(hintText: 'Choose Username')),
            const SizedBox(height: KSizes.margin8x),
            Text('Email', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: KSizes.margin2x),
            TextField(
              decoration: InputDecoration(hintText: 'Enter your email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: KSizes.margin8x),
            Text(
              'Create a Password',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: KSizes.margin2x),
            TextField(
              decoration: InputDecoration(
                hintText: 'Create a Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: KSizes.margin8x),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement signup logic
                    },
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KSizes.margin4x),
            Row(
              children: [
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.surface),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KSizes.margin2x,
                  ),
                  child: Text(
                    'or',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.surface),
                ),
              ],
            ),
            const SizedBox(height: KSizes.margin4x),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Google signup
              },
              icon: Image.network(
                'https://img.icons8.com/?size=100&id=17949&format=png&color=000000',
                width: 24,
                height: 24,
              ),
              label: const Text('Sign Up with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1042),
              ),
            ),
            const SizedBox(height: KSizes.margin2x),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Apple signup
              },
              icon: Image.network(
                'https://img.icons8.com/?size=100&id=30840&format=png&color=000000',
                width: 24,
                height: 24,
              ),
              label: const Text('Sign Up with Apple'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1042),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
