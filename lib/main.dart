import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/google_auth_config.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeGoogleSignIn();

  await Supabase.initialize(
    url: 'https://tmpkcnpmcuksbgyluoeo.supabase.co',
    publishableKey: 'sb_publishable_dSMq-R9EDh-uFn80trATYg_ovUcLr-T',
  );

  runApp(const BarberBlackApp());
}

final supabase = Supabase.instance.client;

class BarberBlackApp extends StatelessWidget {
  const BarberBlackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginView(),
    );
  }
}
