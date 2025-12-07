import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _mostrarMenu = false;
  late AnimationController _controladorMenu;
  late Animation<double> _animacaoFade;

  @override
  void initState() {
    super.initState();
    _controladorMenu = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animacaoFade = CurvedAnimation(
      parent: _controladorMenu,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controladorMenu.dispose();
    super.dispose();
  }

  void _aoCompletarAnimacao() {
    setState(() {
      _mostrarMenu = true;
      _controladorMenu.forward();
    });
  }

  Widget _construirBotaoMenu({
    required IconData icone,
    required String rotulo,
    required VoidCallback aoPressionar,
    required Color cor,
  }) {
    return FadeTransition(
      opacity: _animacaoFade,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: aoPressionar,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icone, size: 40, color: cor),
                const SizedBox(height: 8),
                Text(
                  rotulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
      body: SafeArea(
        child: Center(
          child: _mostrarMenu
              ? FadeTransition(
                  opacity: _animacaoFade,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Revise Car",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cookie',
                          ),
                        ),
                        const SizedBox(height: 40),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _construirBotaoMenu(
                              icone: Icons.contacts,
                              rotulo: "Contatos",
                              cor: Colors.blue,
                              aoPressionar: () => Navigator.pushNamed(context, "/contacts"),
                            ),
                            _construirBotaoMenu(
                              icone: Icons.star,
                              rotulo: "Favoritos",
                              cor: Colors.amber,
                              aoPressionar: () => Navigator.pushNamed(context, "/contacts", arguments: {"action": "favorites"}),
                            ),
                            _construirBotaoMenu(
                              icone: Icons.map,
                              rotulo: "Mapa",
                              cor: Colors.green,
                              aoPressionar: () => Navigator.pushNamed(context, "/map"),
                            ),
                            _construirBotaoMenu(
                              icone: Icons.build,
                              rotulo: "Registrar\nManutenção",
                              cor: Colors.redAccent,
                              aoPressionar: () => Navigator.pushNamed(context, "/registrar-manutencao"),
                            ),
                            _construirBotaoMenu(
                              icone: Icons.history,
                              rotulo: "Histórico\nManutenções",
                              cor: Colors.orange,
                              aoPressionar: () => Navigator.pushNamed(context, "/manutencoes"),
                            ),
                            _construirBotaoMenu(
                              icone: Icons.logout,
                              rotulo: "Sair",
                              cor: Colors.grey,
                              aoPressionar: () {
                                Navigator.pushReplacementNamed(context, "/login");
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : _WidgetAnimacaoPneu(aoCompletar: _aoCompletarAnimacao),
        ),
      ),
    );
  }
}

class _WidgetAnimacaoPneu extends StatefulWidget {
  final VoidCallback aoCompletar;
  
  const _WidgetAnimacaoPneu({required this.aoCompletar});

  @override
  State<_WidgetAnimacaoPneu> createState() => _WidgetAnimacaoPneuState();
}

class _WidgetAnimacaoPneuState extends State<_WidgetAnimacaoPneu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controladorAnimacao;
  late Animation<double> _animacaoRotacao;

  @override
  void initState() {
    super.initState();
    _controladorAnimacao = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animacaoRotacao = Tween<double>(
      begin: 0,
      end: 4 * 3.14159, // 2 voltas completas
    ).animate(CurvedAnimation(
      parent: _controladorAnimacao,
      curve: Curves.easeInOut,
    ));

    _controladorAnimacao.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.aoCompletar();
      });
    });
  }

  @override
  void dispose() {
    _controladorAnimacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animacaoRotacao,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animacaoRotacao.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
              border: Border.all(color: Colors.grey[600]!, width: 8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[700],
                    border: Border.all(color: Colors.grey[500]!, width: 3),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

