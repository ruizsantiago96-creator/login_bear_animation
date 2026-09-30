import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importar libreria para temporizador

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Control para mostrar/ocultar contraseña
  bool _obscure = true;

//1.1 Crear el cerebro de la animacion
StateMachineController? _controller;
//SMI: State Machine Input / Entrada de la maquina de estados
SMIBool? _isChecking;
SMIBool? _isHandsUp;
SMITrigger? _trigSuccess;
SMITrigger? _trigFail;
//3.2 variable de recorrido de la mirada
SMINumber? _numLook;

//3.3 Timer para detener la mirada al escribir
Timer? _typingDebounce;



//2.1 Crear variables para FocusNode
final _emailFocus = FocusNode();
final _passwordFocus = FocusNode();

//2.2  listeners (0yentes/chismosos)
@override
void initState() {
  super.initState();
  _emailFocus.addListener(() {
    //verificar que no sea nulo 
    if (_isHandsUp != null ) {
      //Manos abajo al ver email
      _isHandsUp!.change(false);
    }
  });
  _passwordFocus.addListener(() {
    //Manos arriba al ver password
    if (_isHandsUp != null) {
      _isHandsUp!.change(true);
      //3.4 mirada neutral al escribir
      _numLook?.value = 50.0;
    }
  });
}

  @override
  Widget build(BuildContext context) {
    //para obtener el tamaño de la pantalla
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'osito.riv',
                  stateMachines: ['Login Machine'],
                  //1.2 Vincular animacion
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine'
                    );

                    //1.3 Verificar que inicio bien
                    if (_controller == null) return;
                    //Agrega el controlador al escenario/tablero
                    artboard.addController(_controller!);
                    //Vinculamos variables
                    _isChecking = _controller?.findSMI('isChecking');
                    _isHandsUp = _controller?.findSMI('isHandsUp');
                    _trigSuccess = _controller?.findSMI('trigSuccess');
                    _trigFail = _controller?.findSMI('trigFail');
                    //3.5 Vincular numlook 
                    _numLook = _controller?.findSMI('numLook');
                  },
                ),
              ),
              //para separar espacios
              SizedBox(height:10),
              //Campo de texto para email
              TextField(
                focusNode: _emailFocus,
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    //No tapes los ojos al ver email
                    //_isHandsUp!.change(false);
                  }
                  //Si isChecking es nulo
                  if (_isChecking == null) return;
                  //Activar el modo chismoso
                  _isChecking!.change(true);
                },
                //Para mostrar el tipo de teclado
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              //Campo de texto para contraseña
                TextField(
                  //2.3 asignar el focusNode al TextField
                  focusNode: _passwordFocus,
                  obscureText: _obscure,
                  onChanged: (value) {
                  if (_isChecking != null) {
                    //No tapes los ojos al ver email
                   // _isChecking!.change(false);
                  }
                  //Si isChecking es nulo
                  if (_isHandsUp == null) return;
                  //Activar el modo chismoso
                  _isHandsUp!.change(true);
                  //3.6 implementar  numLook al escribir
                  //ajuste de limites del 0 al 100
                  // 80 es la medida calibracion
                  final look = (value.length * 80.0 * 100.00).clamp(0.0, 100.0);
                  // Clamp para limitar el valor entre 0 y 100
                  _numLook?.value = look;


                  //3.7 debounce: si vuelve a teclear, reinicia el contador 
                  //cancelar el temporizador si ya existe
                  _typingDebounce?.cancel();
                  //crea un nuevo timer
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    //3Si se cierra la pantalla, quita contador 
                    if (!mounted) return;
                    //Mirada neutra
                    _isChecking?.change(false);
                  });
                },
                //Para mostrar el teclado
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    //if operador ternario
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: (){
                      //Refrescar el icono
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                    ),
                  border: OutlineInputBorder(
                    //para redondear los bordes
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    //2.4 Liberar memoria de los focusNode
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel(); //3.9 eliminar el timer
    super.dispose();
}
}