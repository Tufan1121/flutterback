import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
//import 'screens/home_screen.dart';
import 'screens/grid_menu_screen.dart'; // Asegúrate de importar el archivo correctamente
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FlutterSecureStorage();
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  void _checkLoggedIn() async {
    String? token = await storage.read(key: 'jwtToken');
    setState(() {
      isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras isLoggedIn es null, muestra un indicador de carga
    if (isLoggedIn == null) {
      return MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    // Cuando isLoggedIn no es null, decide qué pantalla mostrar
    return MaterialApp(
      //home: isLoggedIn! ? HomeScreen() : LoginScreen(onLoginSuccess: _onLoginSuccess),
      title: 'GT', // O el título de tu aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // O cualquier tema que prefieras
      ),
    home: isLoggedIn! ? GridMenuScreen() : LoginScreen(onLoginSuccess: _onLoginSuccess),

    );
  }

  void _onLoginSuccess() {
    setState(() {
      isLoggedIn = true;
    });
  }
}


