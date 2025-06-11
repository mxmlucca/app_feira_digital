import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _message = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _message = 'A autenticar...';
      });
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        print('Login bem-sucedido na LoginScreen: ${userCredential.user?.uid}');
        if (mounted) {
          setState(() {
            _message = '';
          });
          // Redireciona para o MainScaffold após login bem-sucedido
          // Navigator.pushReplacementNamed(context, '/main-scaffold');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main-scaffold',
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Ocorreu um erro.';
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          errorMessage = 'Email não encontrado ou inválido.';
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = 'Senha incorreta.';
        } else {
          errorMessage = e.message ?? errorMessage;
        }
        setState(() {
          _message = errorMessage;
        });
      } catch (e) {
        print('Erro inesperado: $e');
        setState(() {
          _message = 'Ocorreu um erro inesperado.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (_message == 'A autenticar...') _message = '';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // LOGO
                  Image.asset('assets/images/logoTrilhos.png', height: 150),

                  const SizedBox(height: 48.0),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Insira o seu email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Insira um email válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16.0),

                  // SENHA
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira a sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28.0),

                  // BOTÃO DE LOGIN
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              ),
                            )
                            : const Text('Entrar'),
                  ),

                  const SizedBox(height: 16.0),

                  // MENSAGEM DE ERRO
                  if (_message.isNotEmpty &&
                      !_message.contains('A autenticar...'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        _message,
                        style: theme.textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // RECUPERAR SENHA
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implementar lógica de recuperar senha
                        print('Botão Recuperar Senha pressionado');
                      },
                      child: Text(
                        'Recuperar Senha',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  // CADASTRO
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/cadastro-expositor');
                      },
                      child: Text(
                        'Cadastrar como Expositor',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
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
