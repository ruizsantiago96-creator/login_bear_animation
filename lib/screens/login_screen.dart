import 'dart:async'; // 3.1 Importar la librería para el temporizador

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Control para mostrar/ocultar contraseña
  bool _obscure = true;

  // 1.1 Crear el cerebro de la animación
  StateMachineController? _controller;

  // SMI: State Machine Input / Entrada de la máquina de estados
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  // 3.2 Variable del recorrido de la mirada
  // 3.3 Timer para detener la mirada al escribir
  Timer? _typingDebounce;

  // 2.1 Crear variables para FocusNode
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // 4.1 Controllers que manipulan lo que el usuario escribe
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 4.2 Errores para mostrarlos en la UI
  String? _emailError;
  String? _passwordError;

  // 4.3 Validadores
  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$')
        .hasMatch(password);
  }

  // 4.4 Dar acción al botón
  void _onLogin() {
    // 4.5 De lo que escribió el usuario, quitar espacios en blanco
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    // 4.6 Evaluar los errores
    final emailError = _isValidEmail(email) ? null : 'Ingresa un correo válido';
    final passwordError = _isValidPassword(password)
        ? null
        : 'Usa 8 caracteres, mayúscula, minúscula, número y símbolo';

    // 4.7 Avisar que hubo cambios
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    // 4.8 Cerrar el teclado y bajar las manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    // 4.9 Activar triggers
    if (emailError == null && passwordError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  @override
  void initState() {
    super.initState();

    // 2.2 Listeners para saber cuándo el usuario está escribiendo
    // Al enfocar el correo, baja las manos
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        _isHandsUp?.change(false);
      }
    });

    // Al enfocar la contraseña, se tapa los ojos
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _isHandsUp?.change(true);
      } else {
        _isHandsUp?.change(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width,
                  height: 240,
                  child: RiveAnimation.asset(
                    'assets/osito.riv',
                    fit: BoxFit.contain,
                    stateMachines: const ['Login Machine'],
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      // 1.2 Vincular animación
                      // 1.3 Verificar que el controlador se haya creado
                      if (_controller == null) return;
                      artboard.addController(_controller!);

                      // Agregar el controlador al escenario/tablero
                      // Vincular las entradas de la máquina de estados
                      _isChecking = _controller?.findSMI('isChecking');
                      _isHandsUp = _controller?.findSMI('isHandsUp');
                      _trigSuccess = _controller?.findSMI('trigSuccess');
                      _trigFail = _controller?.findSMI('trigFail');
                      _numLook = _controller?.findSMI('numLook');
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Campo de texto para email
                TextField(
                  // 4.10 Enlazar controller
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    // 4.11 Mostrar errores
                    hintText: 'Email',
                    errorText: _emailError,
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                    // Activa la mirada atenta
                    _isChecking?.change(true);

                    // Mueve los ojos según la cantidad de caracteres
                    final look = (value.length * 3.0).clamp(0.0, 100.0);
                    _numLook?.value = look;

                    // Vuelve a mirada neutral si deja de escribir por 2 segundos
                    _typingDebounce?.cancel();
                    _typingDebounce = Timer(const Duration(seconds: 2), () {
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Campo de texto para la contraseña
                TextField(
                  // 4.10 Enlazar controller
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    // 4.11 Mostrar errores
                    hintText: 'Contraseña',
                    errorText: _passwordError,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() => _passwordError = null);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 4.12 Texto "Olvidé mi contraseña"
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 4.13 Botón de login con validación y triggers de la animación
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _onLogin,
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(height: 10),

                // 4.14 Botón de registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes una cuenta?'),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 4.15 Liberar los controladores
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
