import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'BarberBlack',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}