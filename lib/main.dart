import 'package:flutter/material.dart';
import 'package:ejemplo/principal.dart';
// ========== IMPORT DEL SERVICIO DE AUTENTICACIÓN ==========
import 'package:ejemplo/auth_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  // ========== CONFIGURAR AMPLIFY USANDO EL SERVICIO ==========
  Future<void> _configureAmplify() async {
    final success = await authService.configureAmplify();
    setState(() {
      _amplifyConfigured = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _amplifyConfigured
          ? Scaffold(body: Principal())
          : Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}