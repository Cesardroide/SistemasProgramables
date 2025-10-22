import 'package:flutter/material.dart';
// ========== IMPORT DEL SERVICIO DE AUTENTICACIÓN ==========
import 'package:ejemplo/auth_service.dart';
import 'package:ejemplo/app_page.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // ========== CÓDIGO ORIGINAL ==========
  final TextEditingController usuarioctrl = TextEditingController();
  final TextEditingController contrasenactrl = TextEditingController();

  // ========== VARIABLES PARA UI ==========
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: SafeArea(
        child: Column(
          children: [
            _barrasuperior(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(20.0), child: _Inicio()),
                    imagen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barrasuperior() {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.blue[500],
      padding: EdgeInsets.all(10),
      child: Text(
        "SITIO WEB LSM",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _Inicio() {
    return Container(
      width: 460,
      height: 400,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          // Mostrar mensaje de error si existe
          if (_errorMessage.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
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
          _Usuario(),
          SizedBox(height: 10),
          _Contrasena(),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Iniciar Sesion'),
          ),
        ],
      ),
    );
  }

  Widget imagen() {
    return Image.asset('assets/BIENVENIDO.jpg');
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

  // ========== FUNCIÓN DE LOGIN USANDO EL SERVICIO ==========
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Llamar al servicio de autenticación
    final result = await authService.signIn(
      email: usuarioctrl.text,
      password: contrasenactrl.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Login exitoso - navegar a la app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppPage()),
      );
    } else {
      // Mostrar error
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  void dispose() {
    usuarioctrl.dispose();
    contrasenactrl.dispose();
    super.dispose();
  }
}