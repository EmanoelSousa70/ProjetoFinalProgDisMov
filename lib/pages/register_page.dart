import 'package:flutter/material.dart';
import 'package:revise_car/widgets/auth_widgets.dart';
import 'package:revise_car/database/database_helper.dart';
import 'package:revise_car/models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorNome = TextEditingController();
  final _controladorEmail = TextEditingController();
  final _controladorSenha = TextEditingController();
  final _ajudanteBanco = DatabaseHelper.instance;
  bool _senhaOculta = true;
  bool _carregando = false;

  @override
  void dispose() {
    _controladorNome.dispose();
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _processarCadastro() async {
    if (_chaveFormulario.currentState!.validate()) {
      setState(() => _carregando = true);

      // Verificar se email já existe
      final usuarioExistente = await _ajudanteBanco.obterUsuarioPorEmail(_controladorEmail.text.trim());
      
      if (usuarioExistente != null) {
        setState(() => _carregando = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Este email já está cadastrado!"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Criar novo usuário
      final usuario = User(
        name: _controladorNome.text.trim(),
        email: _controladorEmail.text.trim(),
        password: _controladorSenha.text,
      );

      await _ajudanteBanco.inserirUsuario(usuario);
      
      setState(() => _carregando = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cadastro realizado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
                    "Criar Conta",
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
                    "Preencha os dados para se cadastrar",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      shadows: AuthStyles.textShadowSubtitle,
                    ),
                  ),
                  const SizedBox(height: 48),
                  AuthTextField(
                    controller: _controladorNome,
                    label: "Nome",
                    hint: "Digite seu nome completo",
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return "Por favor, digite seu nome";
                      }
                      if (valor.length < 3) {
                        return "O nome deve ter pelo menos 3 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                      : AuthButton(text: "Cadastrar", onPressed: _processarCadastro),
                  const SizedBox(height: 24),
                  AuthLink(
                    text: "Já tem uma conta? Faça login",
                    onPressed: () => Navigator.pop(context),
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

