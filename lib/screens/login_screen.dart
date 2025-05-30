import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // static const String routeName = '/login'; // Já está no main.dart

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  String _message = '';
  bool _isLoading = false; // Para feedback de carregamento no botão

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Valida o formulário
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
        // A navegação agora é tratada pelo AuthChecker no main.dart
        // Não precisamos de setState para _message de sucesso ou Navigator.push aqui.
        // Se o login for bem-sucedido, o authStateChanges vai disparar e o AuthChecker fará a navegação.
      } on FirebaseAuthException catch (e) {
        print('Erro de Firebase Auth: ${e.code}');
        String errorMessage =
            'Ocorreu um erro. Tente novamente.'; // Mensagem padrão
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          errorMessage = 'Nenhum utilizador encontrado para esse email.';
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = 'Email ou senha incorreta.';
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
        setState(() {
          _message = errorMessage;
        });
      } catch (e) {
        print('Erro inesperado: $e');
        setState(() {
          _message = 'Ocorreu um erro inesperado. Tente novamente.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            // Limpa a mensagem "A autenticar..." se não houve erro que a substituiu
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
    // Obtém o tema para usar cores e estilos definidos globalmente
    final theme = Theme.of(context);

    return Scaffold(
      // A AppBar agora herdará o estilo do appBarTheme em main.dart
      appBar: AppBar(
        title: const Text('Login - App Feira Digital'),
        // Não precisamos de centerTitle: true se já estiver no tema
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // TODO: Adicionar um logo aqui, se desejar
                // Image.asset('assets/images/seu_logo.png', height: 100),
                // const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ), // Ícone um pouco diferente
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o seu email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                    ), // Ícone um pouco diferente
                    // Para adicionar um botão de "mostrar/esconder senha",
                    // precisaria de um StatefulWidget e uma variável de estado para controlar a visibilidade.
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  // O estilo virá do elevatedButtonTheme em main.dart
                  onPressed: _isLoading ? null : _handleLogin,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                          : const Text('Entrar'),
                ),
                const SizedBox(height: 16.0),
                if (_message.isNotEmpty &&
                    !_message.contains('A autenticar...'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color:
                            theme
                                .colorScheme
                                .error, // Usa a cor de erro do tema
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // TODO: Adicionar links para "Esqueceu a senha?" ou "Criar conta"
                // TextButton(
                //   onPressed: () { /* Navegar para criar conta */ },
                //   child: Text('Não tem uma conta? Crie uma'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
