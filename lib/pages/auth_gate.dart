import 'package:flutter/material.dart';
import 'package:odifarm/main.dart';
import 'package:odifarm/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Session? _session;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Wait for Supabase to restore session
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      setState(() {
        _session = session;
        _isLoading = false;
      });
    });

    // Initially get the current session
    final currentSession = Supabase.instance.client.auth.currentSession;
    setState(() {
      _session = currentSession;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_session == null) {
      return const Login(); // Show login instead of SignUp by default
    } else {
      return const HomeShell();
    }
  }
}
