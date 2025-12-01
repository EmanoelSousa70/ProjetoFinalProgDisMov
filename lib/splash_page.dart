import 'package:flutter/material.dart';
import 'dart:async';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // ANIMAÇÃO DO LOGO (fade + zoom)
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    // TEXTO DESLIZANDO PARA BAIXO (sai de trás do logo)
    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.8),  // começa acima, atrás do logo
      end: Offset(0, 3.0),     // desliza para baixo
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    // Redirecionar para a página de Login após 3.5 segundos
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // LOGO COM FADE + ZOOM
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  "assets/icons/icon_app.png",
                  width: 200,
                ),
              ),
            ),

            // TEXTO SAINDO DE TRÁS DO LOGO
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Text(
                  "Seu carro merece este cuidado!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cookie',
                    color: const Color.fromRGBO(45, 131, 187, 1)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
