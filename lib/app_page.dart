import 'package:flutter/material.dart';
// ========== IMPORT DEL SERVICIO DE AUTENTICACIÓN ==========
import 'package:ejemplo/auth_service.dart';
import 'package:ejemplo/principal.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  String _userEmail = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // ========== OBTENER INFO DEL USUARIO USANDO EL SERVICIO ==========
  Future<void> _getUserInfo() async {
    final email = await authService.getCurrentUserEmail();
    if (email != null) {
      setState(() {
        _userEmail = email;
      });
    }
  }

  // ========== CERRAR SESIÓN USANDO EL SERVICIO ==========
  Future<void> _signOut() async {
    final result = await authService.signOut();
    
    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Principal()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SITIO WEB LSM"),
        backgroundColor: Colors.blue[500],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar del usuario
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[600],
                child: Text(
                  _userEmail.isNotEmpty ? _userEmail[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Título de bienvenida
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 10),
              
              // Email del usuario
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Has iniciado sesión correctamente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              
              // Botón de cerrar sesión
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: Icon(Icons.logout),
                label: Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}