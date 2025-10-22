// ========== SERVICIO DE AUTENTICACIÓN CON AWS COGNITO ==========
// Este archivo contiene TODA la lógica de Amplify/Cognito
// Los demás archivos solo llaman a estas funciones simples

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';

class AuthService {
  // Singleton para tener una única instancia
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isConfigured = false;

  // ========== CONFIGURACIÓN DE AMPLIFY ==========
  /// Configura Amplify con AWS Cognito
  /// Solo se debe llamar UNA VEZ al inicio de la app
  Future<bool> configureAmplify() async {
    if (_isConfigured) return true;

    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
      
      _isConfigured = true;
      safePrint('✅ Amplify configurado correctamente');
      return true;
    } on AmplifyAlreadyConfiguredException {
      _isConfigured = true;
      safePrint('⚠️ Amplify ya estaba configurado');
      return true;
    } catch (e) {
      safePrint('❌ Error configurando Amplify: $e');
      return false;
    }
  }

  // ========== REGISTRO DE USUARIOS ==========
  /// Registra un nuevo usuario en Cognito
  /// 
  /// Parámetros:
  /// - email: Correo del usuario
  /// - password: Contraseña (mínimo 8 caracteres)
  /// 
  /// Retorna:
  /// - Map con 'success' (bool), 'message' (String), 'needsVerification' (bool)
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // Validaciones básicas
      if (email.trim().isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Por favor completa todos los campos',
          'needsVerification': false,
        };
      }

      if (password.length < 8) {
        return {
          'success': false,
          'message': 'La contraseña debe tener al menos 8 caracteres',
          'needsVerification': false,
        };
      }

      // Registrar en Cognito
      final result = await Amplify.Auth.signUp(
        username: email.trim(),
        password: password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: email.trim(),
          },
        ),
      );

      if (result.isSignUpComplete) {
        return {
          'success': true,
          'message': 'Cuenta creada exitosamente',
          'needsVerification': false,
        };
      } else {
        return {
          'success': true,
          'message': 'Cuenta creada. Verifica tu email',
          'needsVerification': true,
        };
      }
    } on AuthException catch (e) {
      String errorMsg = 'Error al crear cuenta';
      
      if (e.message.contains('User already exists')) {
        errorMsg = 'Este email ya está registrado';
      } else if (e.message.contains('Password did not conform')) {
        errorMsg = 'La contraseña no cumple los requisitos';
      } else if (e.message.contains('Invalid email')) {
        errorMsg = 'El formato del email es inválido';
      }
      
      return {
        'success': false,
        'message': errorMsg,
        'needsVerification': false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'needsVerification': false,
      };
    }
  }

  // ========== VERIFICACIÓN DE EMAIL ==========
  /// Confirma el código de verificación enviado por email
  /// 
  /// Parámetros:
  /// - email: Correo del usuario
  /// - code: Código de 6 dígitos recibido por email
  /// 
  /// Retorna:
  /// - Map con 'success' (bool) y 'message' (String)
  Future<Map<String, dynamic>> confirmSignUp({
    required String email,
    required String code,
  }) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: email.trim(),
        confirmationCode: code,
      );
      
      return {
        'success': true,
        'message': 'Email verificado correctamente',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': 'Código incorrecto o expirado',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ========== INICIO DE SESIÓN ==========
  /// Inicia sesión con email y contraseña
  /// 
  /// Parámetros:
  /// - email: Correo del usuario
  /// - password: Contraseña
  /// 
  /// Retorna:
  /// - Map con 'success' (bool) y 'message' (String)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email.trim(),
        password: password,
      );

      if (result.isSignedIn) {
        return {
          'success': true,
          'message': 'Inicio de sesión exitoso',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al iniciar sesión',
        };
      }
    } on AuthException catch (e) {
      String errorMsg = 'Error al iniciar sesión';
      
      if (e.message.contains('Incorrect username or password')) {
        errorMsg = 'Email o contraseña incorrectos';
      } else if (e.message.contains('User is not confirmed')) {
        errorMsg = 'Por favor verifica tu email primero';
      } else if (e.message.contains('User does not exist')) {
        errorMsg = 'El usuario no existe';
      }
      
      return {
        'success': false,
        'message': errorMsg,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ========== CERRAR SESIÓN ==========
  /// Cierra la sesión del usuario actual
  /// 
  /// Retorna:
  /// - Map con 'success' (bool) y 'message' (String)
  Future<Map<String, dynamic>> signOut() async {
    try {
      await Amplify.Auth.signOut();
      return {
        'success': true,
        'message': 'Sesión cerrada correctamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al cerrar sesión: ${e.toString()}',
      };
    }
  }

  // ========== OBTENER USUARIO ACTUAL ==========
  /// Obtiene el email del usuario que ha iniciado sesión
  /// 
  /// Retorna:
  /// - String con el email, o null si no hay usuario logueado
  Future<String?> getCurrentUserEmail() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      
      for (var attr in attributes) {
        if (attr.userAttributeKey == AuthUserAttributeKey.email) {
          return attr.value;
        }
      }
      return null;
    } catch (e) {
      safePrint('Error obteniendo usuario: $e');
      return null;
    }
  }

  // ========== VERIFICAR SI HAY SESIÓN ACTIVA ==========
  /// Verifica si hay un usuario con sesión activa
  /// 
  /// Retorna:
  /// - bool: true si hay sesión activa, false si no
  Future<bool> isUserSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      return false;
    }
  }
}

// ========== INSTANCIA GLOBAL ==========
// Crear una instancia global para fácil acceso
final authService = AuthService();