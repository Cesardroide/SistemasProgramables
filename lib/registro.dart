import 'package:flutter/material.dart';
// ========== IMPORT DEL SERVICIO DE AUTENTICACIÓN ==========
import 'package:ejemplo/auth_service.dart';

class Registro extends StatefulWidget {
  Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  // ========== CÓDIGO ORIGINAL ==========
  final TextEditingController usuarioctrl = TextEditingController();
  final TextEditingController contrasenactrl = TextEditingController();

  // ========== VARIABLES PARA UI ==========
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar mensaje de error si existe
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red[900]),
                  textAlign: TextAlign.center,
                ),
              ),
            // Mostrar mensaje de éxito si existe
            if (_successMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _successMessage,
                  style: TextStyle(color: Colors.green[900]),
                  textAlign: TextAlign.center,
                ),
              ),
            _Usuario(),
            SizedBox(height: 16),
            _Contrasena(),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegistro,
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text("Registrarse"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _Usuario() {
    return TextField(
      controller: usuarioctrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: "Correo",
      ),
    );
  }

  Widget _Contrasena() {
    return TextField(
      controller: contrasenactrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.remove_red_eye),
        labelText: "Contraseña",
      ),
    );
  }

  // ========== FUNCIÓN DE REGISTRO USANDO EL SERVICIO ==========
  Future<void> _handleRegistro() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    // Llamar al servicio de autenticación
    final result = await authService.signUp(
      email: usuarioctrl.text,
      password: contrasenactrl.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (result['needsVerification']) {
        // Necesita verificación - mostrar diálogo
        _showVerificationDialog();
      } else {
        // Registro completo
        setState(() {
          _successMessage = result['message'];
        });
      }
    } else {
      // Mostrar error
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  // ========== DIÁLOGO DE VERIFICACIÓN ==========
  void _showVerificationDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('✉️ Verificación de Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se ha enviado un código de verificación a tu email',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Código de 6 dígitos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _successMessage = 'Registro pendiente de verificación';
              });
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Verificar código usando el servicio
              final result = await authService.confirmSignUp(
                email: usuarioctrl.text,
                code: codeController.text,
              );
              
              if (result['success']) {
                Navigator.pop(context);
                
                setState(() {
                  _successMessage = '✅ ${result['message']}! Ahora puedes iniciar sesión';
                  usuarioctrl.clear();
                  contrasenactrl.clear();
                });
                
                // Volver al login después de 2 segundos
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pop(context);
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${result['message']}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Verificar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usuarioctrl.dispose();
    contrasenactrl.dispose();
    super.dispose();
  }
}