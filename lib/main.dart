import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/crear_oficio_screen.dart';
import 'screens/lista_oficios_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficios App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),

      // 🌐 Localización para que showDatePicker funcione bien
      locale: const Locale('es'), // Idioma por defecto: español
      supportedLocales: const [
        Locale('es'), // Puedes agregar más idiomas aquí si necesitas
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/crearOficio') {
          final usuario = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CrearOficioScreen(usuario: usuario),
          );
        } else if (settings.name == '/listaOficios') {
          final usuario = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ListaOficiosScreen(usuario: usuario),
          );
        }
        return null;
      },
    );
  }
}
