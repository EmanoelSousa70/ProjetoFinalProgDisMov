import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _showMenu = false;
  late AnimationController _menuController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _onAnimationComplete() {
    setState(() {
      _showMenu = true;
      _menuController.forward();
    });
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
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
          child: _showMenu
              ? FadeTransition(
                  opacity: _fadeAnimation,
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
                            _buildMenuButton(
                              icon: Icons.contacts,
                              label: "Contatos",
                              color: Colors.blue,
                              onTap: () => Navigator.pushNamed(context, "/contacts"),
                            ),
                            _buildMenuButton(
                              icon: Icons.star,
                              label: "Favoritos",
                              color: Colors.amber,
                              onTap: () => Navigator.pushNamed(context, "/contacts", arguments: {"action": "favorites"}),
                            ),
                            _buildMenuButton(
                              icon: Icons.map,
                              label: "Mapa",
                              color: Colors.green,
                              onTap: () => Navigator.pushNamed(context, "/map"),
                            ),
                            _buildMenuButton(
                              icon: Icons.logout,
                              label: "Sair",
                              color: Colors.grey,
                              onTap: () {
                                Navigator.pushReplacementNamed(context, "/login");
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : _TireAnimationWidget(onComplete: _onAnimationComplete),
        ),
      ),
    );
  }
}

class _TireAnimationWidget extends StatefulWidget {
  final VoidCallback onComplete;
  
  const _TireAnimationWidget({required this.onComplete});

  @override
  State<_TireAnimationWidget> createState() => _TireAnimationWidgetState();
}

class _TireAnimationWidgetState extends State<_TireAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 4 * 3.14159, // 2 voltas completas
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
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

