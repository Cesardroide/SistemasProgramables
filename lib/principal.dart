import 'package:flutter/material.dart';
import 'package:ejemplo/login.dart';
import 'package:ejemplo/registro.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: login, child: Text('LOGIN')),
            ElevatedButton(onPressed: registro, child: Text('REGISTRO')),
          ],
        ),
      ],
    );
  }

  void login() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  void registro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Registro()),
    );
  }
}
