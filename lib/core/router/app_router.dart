import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Remova as importações da feature de teste se ainda estiverem lá

// Importe a sua nova LoginPage
import '../../features/auth/presentation/pages/login_page.dart';

// Esta é a sua página inicial antiga, podemos mantê-la para referência
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Ir para Login'),
        ),
      ),
    );
  }
}

// A configuração do GoRouter, conforme definido na arquitetura [cite: 2]
final router = GoRouter(
  // ALTERADO: A rota inicial agora é '/login'
  initialLocation: '/login',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    // ADICIONADO: A definição da rota para a página de login
    GoRoute(
      path: '/login',
      builder:
          (context, state) =>
              const LoginPage(), // Aponta para a tela de login que criamos [cite: 3]
    ),
  ],
);
