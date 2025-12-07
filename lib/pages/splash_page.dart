import 'package:flutter/material.dart';
import 'dart:async';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controladorAnimacao;

  late Animation<double> _fadeLogo;
  late Animation<double> _escalaLogo;

  late Animation<Offset> _deslizarTexto;
  late Animation<double> _fadeTexto;

  @override
  void initState() {
    super.initState();

    _controladorAnimacao = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    // ANIMAÇÃO DO LOGO (fade + zoom)
    _fadeLogo = CurvedAnimation(
      parent: _controladorAnimacao,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _escalaLogo = CurvedAnimation(
      parent: _controladorAnimacao,
      curve: Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    // TEXTO DESLIZANDO PARA BAIXO (sai de trás do logo)
    _deslizarTexto = Tween<Offset>(
      begin: Offset(0, 0.8),  // começa acima, atrás do logo
      end: Offset(0, 3.0),     // desliza para baixo
    ).animate(
      CurvedAnimation(
        parent: _controladorAnimacao,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeTexto = CurvedAnimation(
      parent: _controladorAnimacao,
      curve: Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controladorAnimacao.forward();

    // Redirecionar para a página de Login após 3.5 segundos
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  @override
  void dispose() {
    _controladorAnimacao.dispose();
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
              opacity: _fadeLogo,
              child: ScaleTransition(
                scale: _escalaLogo,
                child: Image.asset(
                  "assets/icons/icon_app.png",
                  width: 200,
                ),
              ),
            ),

            // TEXTO SAINDO DE TRÁS DO LOGO
            SlideTransition(
              position: _deslizarTexto,
              child: FadeTransition(
                opacity: _fadeTexto,
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

