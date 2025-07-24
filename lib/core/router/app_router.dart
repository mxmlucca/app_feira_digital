import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/admin_home_page.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';

// Esta é a sua página inicial antiga, podemos mantê-la para referência
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => context.go('/login'),
//           child: const Text('Ir para Login'),
//         ),
//       ),
//     );
//   }
// }

final router = GoRouter(
  initialLocation: '/login',

  routes: [
    GoRoute(
      path: '/login',
      builder:
          (context, state) => ChangeNotifierProvider(
            create: (_) => getIt<LoginController>(),
            child: const LoginPage(),
          ),
    ),
    GoRoute(
      path: '/admin/home',
      builder: (context, state) => const AdminHomePage(),
    ),
  ],
);
