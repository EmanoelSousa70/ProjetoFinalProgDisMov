import 'package:flutter/material.dart';
import 'package:revise_car/splash_page.dart';
import 'package:revise_car/login_page.dart';
import 'package:revise_car/register_page.dart';
import 'package:revise_car/pages/home_page.dart';
import 'package:revise_car/pages/contacts_page.dart';
import 'package:revise_car/pages/map_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revise Car',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(22, 72, 107, 1),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: const Color.fromRGBO(22, 72, 107, 1),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashPage(),
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/home": (context) => const HomePage(),
        "/contacts": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return ContactsPage(arguments: args);
        },
        "/map": (context) => const MapPage(),
      },
    );
  }
}
