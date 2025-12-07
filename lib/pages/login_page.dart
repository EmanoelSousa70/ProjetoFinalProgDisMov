import 'package:flutter/material.dart';
import 'package:revise_car/widgets/auth_widgets.dart';
import 'package:revise_car/database/database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _ajudanteBanco = DatabaseHelper.instance;
  bool _senhaOculta = true;
  bool _carregando = false;

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _processarLogin() async {
    if (_chaveFormulario.currentState!.validate()) {
      setState(() => _carregando = true);
      
      final usuario = await _ajudanteBanco.fazerLogin(
        _controladorEmail.text.trim(),
        _controladorSenha.text,
      );

      setState(() => _carregando = false);

      if (usuario != null) {
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
              key: _chaveFormulario,
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
                    controller: _controladorEmail,
                    label: "Email",
                    hint: "Digite seu email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return "Por favor, digite seu email";
                      }
                      if (!valor.contains("@")) {
                        return "Por favor, digite um email válido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: _controladorSenha,
                    label: "Senha",
                    hint: "Digite sua senha",
                    icon: Icons.lock,
                    obscureText: _senhaOculta,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaOculta ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _senhaOculta = !_senhaOculta),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return "Por favor, digite sua senha";
                      }
                      if (valor.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : AuthButton(text: "Entrar", onPressed: _processarLogin),
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

