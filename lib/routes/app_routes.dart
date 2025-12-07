import 'package:flutter/material.dart';
import 'package:revise_car/pages/splash_page.dart';
import 'package:revise_car/pages/login_page.dart';
import 'package:revise_car/pages/register_page.dart';
import 'package:revise_car/pages/home_page.dart';
import 'package:revise_car/pages/contacts_page.dart';
import 'package:revise_car/pages/map_page.dart';
import 'package:revise_car/pages/registrar_manutencao_page.dart';
import 'package:revise_car/pages/lista_manutencoes_page.dart';

class AppRoutes {
  // Nomes das rotas
  static const String splash = "/splash";
  static const String login = "/login";
  static const String register = "/register";
  static const String home = "/home";
  static const String contacts = "/contacts";
  static const String map = "/map";
  static const String registrarManutencao = "/registrar-manutencao";
  static const String manutencoes = "/manutencoes";

  // Rota inicial
  static const String initialRoute = splash;

  // Mapa de rotas
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      home: (context) => const HomePage(),
      contacts: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return ContactsPage(arguments: args);
      },
      map: (context) => const MapPage(),
      registrarManutencao: (context) => RegistrarManutencaoPage(),
      manutencoes: (context) => ListaManutencoesPage(),
    };
  }
}

