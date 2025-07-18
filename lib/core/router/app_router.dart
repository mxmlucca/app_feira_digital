import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Importe o provider

// Importe as dependências da feature de teste
import '../../features/test_flow/presentation/controllers/test_page_controller.dart';
import '../../features/test_flow/presentation/pages/test_page.dart';
import '../di/service_locator.dart';

// Adicione um botão na sua HomePage para navegar para a tela de teste
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Feira Digital App'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/test'), // Ação de navegação
              child: const Text('Test Architecture Flow'),
            ),
          ],
        ),
      ),
    );
  }
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    // Nova rota para a página de teste
    GoRoute(
      path: '/test',
      builder: (context, state) {
        // Usamos o ChangeNotifierProvider para injetar o controller na árvore de widgets [cite: 71]
        return ChangeNotifierProvider(
          create: (_) => getIt<TestPageController>(),
          child: const TestPage(),
        );
      },
    ),
  ],
  redirect: (context, state) {
    return null;
  },
);
