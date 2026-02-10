import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_taskhub/auth/login_screen.dart';
import 'package:mini_taskhub/dashboard/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://gbvcyuljnmbdxdhodfwq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdidmN5dWxqbm1iZHhkaG9kZndxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2MjkzNzgsImV4cCI6MjA4NjIwNTM3OH0.F3dFCYrrn-xjpsfEVD0F-kI5OhFN1ngj_smICEMY-pw',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini TaskHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}