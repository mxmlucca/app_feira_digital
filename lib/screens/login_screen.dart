// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Mantemos o Future para o FutureBuilder
  Future<void>? _precacheFuture;

  // Controladores e chaves do formulário
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variáveis de estado da UI
  String _message = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A mágica acontece aqui!
    // didChangeDependencies é chamado DEPOIS de initState e tem um context válido.
    // Verificamos se o future ainda não foi inicializado para rodar apenas uma vez.
    if (_precacheFuture == null) {
      setState(() {
        _precacheFuture = precacheImage(
          const AssetImage('assets/images/logoTrilhos.png'),
          context,
        );
      });
    }
  }

  // Seus métodos _handleLogin e _handlePasswordReset continuam os mesmos.
  // Cole-os aqui.
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
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).refreshUserData();
          // A pausa pode não ser mais necessária, mas vamos manter por segurança
          // contra a race condition do backend do Firebase.
          await Future.delayed(const Duration(milliseconds: 250));
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
        if (mounted) {
          setState(() {
            _message = errorMessage;
          });
        }
      } catch (e) {
        print('Erro inesperado: $e');
        if (mounted) {
          setState(() {
            _message = 'Ocorreu um erro inesperado.';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    final _resetEmailController = TextEditingController();
    final _dialogFormKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isSending = false;
            String? dialogMessage;

            return AlertDialog(
              title: const Text('Recuperar Senha'),
              content: Form(
                key: _dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Insira seu e-mail para receber um link de recuperação.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Seu e-mail'),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Por favor, insira um e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    if (dialogMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        dialogMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      isSending
                          ? null
                          : () async {
                            if (_dialogFormKey.currentState?.validate() ??
                                false) {
                              setDialogState(() => isSending = true);
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                      email: _resetEmailController.text.trim(),
                                    );
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Link de recuperação enviado! Verifique seu e-mail.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } on FirebaseAuthException catch (e) {
                                setDialogState(() {
                                  if (e.code == 'user-not-found') {
                                    dialogMessage = 'E-mail não encontrado.';
                                  } else {
                                    dialogMessage =
                                        'Ocorreu um erro. Tente novamente.';
                                  }
                                  isSending = false;
                                });
                              }
                            }
                          },
                  child:
                      isSending
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // A construção do Widget continua a mesma
  @override
  Widget build(BuildContext context) {
    // Se o _precacheFuture for nulo (antes da primeira chamada a didChangeDependencies),
    // mostramos o loading. Isso evita um flash de tela.
    if (_precacheFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: FutureBuilder(
        future: _precacheFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar recursos.'));
          }

          return SafeArea(
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
                      Image.asset('assets/images/logoTrilhos.png', height: 150),
                      const SizedBox(height: 70.0),
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
                      if (_message.isNotEmpty &&
                          !_message.contains('A autenticar...'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Text(
                            _message,
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: _isLoading ? null : _handlePasswordReset,
                          child: Text(
                            'Recuperar Senha',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/cadastro-expositor');
                          },
                          child: Text(
                            'Cadastrar como Expositor',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
