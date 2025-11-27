import 'package:flutter/material.dart';
import '../../core/constants/k_sizes.dart';
import '../../core/theme/app_theme.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.light.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(KSizes.margin8x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: KSizes.margin8x),
            Text('Email', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: KSizes.margin2x),
            TextField(
              decoration: InputDecoration(hintText: 'Enter your email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: KSizes.margin8x),
            Text('Password', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: KSizes.margin2x),
            TextField(
              decoration: InputDecoration(
                hintText: 'Create a Password',
                suffixIcon: Icon(Icons.visibility_off),
              ),
              obscureText: true,
            ),
            const SizedBox(height: KSizes.margin8x),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement login logic
                    },
                    child: const Text('Log In'),
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
                // TODO: Implement Google login
              },
              icon: Image.network(
                'https://img.icons8.com/?size=100&id=17949&format=png&color=000000',
                width: 24,
                height: 24,
              ),
              label: const Text('Log In with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1042),
              ),
            ),
            const SizedBox(height: KSizes.margin2x),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Apple login
              },
              icon: Image.network(
                'https://img.icons8.com/?size=100&id=30840&format=png&color=000000',
                width: 24,
                height: 24,
              ),
              label: const Text('Log In with Apple'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1042),
              ),
            ),
            const SizedBox(height: KSizes.margin4x),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
