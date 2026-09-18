import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const new({super.key});

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
                  },
                ),
              ),
              //para separar espacios
              SizedBox(height:10),
              //Campo de texto para email
              TextField(
                onChanged: (value) {
                  if (_isHandsUp != null) {
                    //No tapes los ojos al ver email
                    _isHandsUp!.change(false);
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
                  obscureText: _obscure,
                  onChanged: (value) {
                  if (_isChecking != null) {
                    //No tapes los ojos al ver email
                    _isChecking!.change(false);
                  }
                  //Si isChecking es nulo
                  if (_isHandsUp == null) return;
                  //Activar el modo chismoso
                  _isHandsUp!.change(true);
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
}