import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Verifica o brilho do tema atual para decidir qual logo usar
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoAsset =
        isDarkMode
            ? 'assets/images/logo_dark.png'
            : 'assets/images/logo_light.png';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Logo que se adapta ao tema
              Image.asset(logoAsset, height: 400),
              const SizedBox(height: 48),

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
                onPressed: () {
                  // TODO: Chamar controller.login()
                },
                child: const Text('Entrar'),
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
                // icon: Image.asset('assets/images/google_logo.png', height: 24), // Você precisará deste asset
                label: const Text('Entrar com Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
