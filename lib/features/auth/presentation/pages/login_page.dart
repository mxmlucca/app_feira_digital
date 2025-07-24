import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/login_controller.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Lembre-se de limpar os controllers para evitar memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login
  Future<void> _login() async {
    final controller = context.read<LoginController>();
    final success = await controller.login(
      _emailController.text,
      _passwordController.text,
    );

    // O 'context' pode se tornar inválido se o widget for removido
    // da árvore durante uma operação assíncrona. Esta verificação é uma boa prática.
    if (!mounted) return;

    if (success) {
      // Navega para a home do admin em caso de sucesso
      context.go('/admin/home');
    } else {
      // Mostra a mensagem de erro vinda do controller
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Ocorreu um erro.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica o brilho do tema atual para decidir qual logo usar
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoAsset =
        isDarkMode
            ? 'assets/images/logo_dark.png'
            : 'assets/images/logo_light.png';

    final loginController = context.watch<LoginController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo que se adapta ao tema
                Image.asset(logoAsset, height: 250),
                const SizedBox(height: 24),

                // 2. Campo de Email
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // 3. Campo de Senha
                TextFormField(
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Botão de Entrar (estilo vem do AppTheme)
                ElevatedButton(
                  onPressed: loginController.isLoading ? null : _login,
                  child:
                      loginController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Entrar'),
                ),
                const SizedBox(height: 16),

                // 5. Links de Texto (estilo vem do AppTheme)
                TextButton(
                  onPressed: () {
                    // TODO: Navegar para a tela de recuperar senha
                  },
                  child: const Text('Recuperar Senha'),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navegar para a tela de cadastro
                  },
                  child: const Text('Cadastrar como Expositor'),
                ),

                // 6. Placeholder para Login Social (futuro)
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('ou'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  // Estilo diferente para login social
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // TODO: Implementar login com Google
                  },
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ), // Você precisará deste asset
                  label: const Text('Entrar com Google'),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
