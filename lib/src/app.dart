import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme_provider.dart';
import 'core/widgets/themed_app_backdrop.dart';
import 'core/auth/auth_controller.dart';
import 'features/auth/login_page.dart';
import 'features/guardian/guardian_home_page.dart';
import 'features/staff/staff_home_page.dart';

class BciApp extends ConsumerWidget {
  const BciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'BCI School Management',
      debugShowCheckedModeBanner: false,
      theme: theme.themeData,
      builder: (context, child) =>
          ThemedAppBackdrop(child: child ?? const SizedBox.shrink()),
      home: auth.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const LoginPage(),
        data: (user) {
          if (user == null) return const LoginPage();
          if (user.isGuardian) return const GuardianHomePage();
          if (user.isStaff) return const StaffHomePage();
          return const _UnsupportedRolePage();
        },
      ),
    );
  }
}

class _UnsupportedRolePage extends ConsumerWidget {
  const _UnsupportedRolePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('BCI School Management')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This mobile role is not enabled yet.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
