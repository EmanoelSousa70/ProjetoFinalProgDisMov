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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Verificar se email já existe
      final existingUser = await _dbHelper.getUserByEmail(_emailController.text.trim());
      
      if (existingUser != null) {
        setState(() => _isLoading = false);
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
      final user = User(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _dbHelper.insertUser(user);
      
      setState(() => _isLoading = false);

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
              key: _formKey,
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
                    controller: _nameController,
                    label: "Nome",
                    hint: "Digite seu nome completo",
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, digite seu nome";
                      }
                      if (value.length < 3) {
                        return "O nome deve ter pelo menos 3 caracteres";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                      : AuthButton(text: "Cadastrar", onPressed: _handleRegister),
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

