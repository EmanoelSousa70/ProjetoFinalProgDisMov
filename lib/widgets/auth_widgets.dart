import 'package:flutter/material.dart';

// Constantes de estilo
class AuthStyles {
  static const textShadowTitle = [
    Shadow(offset: Offset(0, 2), blurRadius: 6, color: Colors.black54),
    Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black38),
  ];
  
  static const textShadowSubtitle = [
    Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black54),
    Shadow(offset: Offset(0, 0.5), blurRadius: 2, color: Colors.black38),
  ];
  
  static const textShadowLink = [
    Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black54),
    Shadow(offset: Offset(0, 0.5), blurRadius: 1.5, color: Colors.black38),
  ];
  
  static const fieldDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  static const fieldPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const fieldStyle = TextStyle(fontSize: 16);
}

// Widget de background com overlay
class AuthBackground extends StatelessWidget {
  final Widget child;
  
  const AuthBackground({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/img_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

// Logo circular
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        "assets/icons/icon2_app.png",
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }
}

// Campo de texto estilizado
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AuthStyles.fieldDecoration,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AuthStyles.fieldStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AuthStyles.fieldStyle,
          hintText: hint,
          hintStyle: AuthStyles.fieldStyle,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          contentPadding: AuthStyles.fieldPadding,
        ),
        validator: validator,
      ),
    );
  }
}

// Botão estilizado
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(100, 149, 237, 1), // Azul claro (cornflower blue)
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// Link de navegação
class AuthLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const AuthLink({
    super.key,
    required this.text,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          shadows: AuthStyles.textShadowLink,
        ),
      ),
    );
  }
}

