import 'package:flutter/material.dart';
import 'package:revise_car/widgets/auth_widgets.dart';
import 'package:revise_car/database/database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = await _dbHelper.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email ou senha incorretos!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AuthLogo(),
                  const SizedBox(height: 32),
                  const Text(
                    "Bem-vindo",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cookie',
                      shadows: AuthStyles.textShadowTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Faça login para continuar",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      shadows: AuthStyles.textShadowSubtitle,
                    ),
                  ),
                  const SizedBox(height: 48),
                  AuthTextField(
                    controller: _emailController,
                    label: "Email",
                    hint: "Digite seu email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, digite seu email";
                      }
                      if (!value.contains("@")) {
                        return "Por favor, digite um email válido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: _passwordController,
                    label: "Senha",
                    hint: "Digite sua senha",
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, digite sua senha";
                      }
                      if (value.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AuthButton(text: "Entrar", onPressed: _handleLogin),
                  const SizedBox(height: 24),
                  AuthLink(
                    text: "Não tem uma conta? Cadastre-se",
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

