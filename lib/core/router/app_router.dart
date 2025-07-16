// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Importe o UserProvider e as telas necessárias
import '../../features/auth/presentation/controllers/user_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/cadastro_expositor_page.dart';
import '../../features/auth/presentation/pages/aguardando_aprovacao_page.dart';
import '../../features/auth/presentation/pages/cadastro_reprovado_page.dart';
import '../../features/shared/presentation/pages/main_scaffold_page.dart';
import '../../features/shared/presentation/pages/not_found_page.dart';
import '../../features/expositor/presentation/pages/expositor_list_page.dart';
import '../../features/expositor/presentation/pages/expositor_detail_page.dart';
import '../../features/expositor/domain/entities/expositor.dart';
import '../../features/agenda/presentation/pages/agenda_page.dart';
import '../../features/mapa/presentation/pages/mapa_page.dart';

/// A classe de configuração do roteador para a aplicação.
/// Usa o GoRouter para uma navegação declarativa, segura e baseada em URL.
class AppRouter {
  final UserProvider userProvider;

  AppRouter({required this.userProvider});

  /// Configuração do GoRouter
  late final GoRouter router = GoRouter(
    // 'refreshListenable' é a chave para a reatividade.
    // Ele faz com que o GoRouter reavalie a rota do utilizador sempre
    // que o UserProvider notificar uma mudança (ex: após login/logout).
    refreshListenable: userProvider,

    // Rota inicial da aplicação
    initialLocation: '/login',

    // Builder para a página de erro (404 Not Found)
    errorBuilder: (context, state) => const NotFoundPage(),

    routes: <RouteBase>[
      // Rota principal que contém a navegação com abas (BottomNavigationBar).
      // Usamos um ShellRoute para que a BottomNav seja partilhada entre as telas filhas.
      // O MainScaffoldPage é a "concha" (shell).
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffoldPage(child: child);
        },
        routes: [
          // As rotas dentro do ShellRoute são as abas
          GoRoute(
            path: '/home', // Rota para a home (Admin/Expositor)
            name: 'home',
            builder:
                (context, state) =>
                    const HomePage(), // Supondo uma HomePage genérica
          ),
          GoRoute(
            path: '/expositores',
            name: 'expositores',
            builder: (context, state) => const ExpositorListPage(),
            routes: [
              // Sub-rota para os detalhes de um expositor
              GoRoute(
                path: 'detalhe/:id', // Usa um parâmetro de ID na URL
                name: 'expositor-detalhe',
                builder: (context, state) {
                  // O objeto 'Expositor' é passado através do parâmetro 'extra'
                  final expositor = state.extra as Expositor?;
                  if (expositor != null) {
                    return ExpositorDetailPage(expositor: expositor);
                  }
                  // Se o objeto não for passado, idealmente buscaríamos pelo ID
                  return const NotFoundPage();
                },
              ),
            ],
          ),
          GoRoute(
            path: '/agenda',
            name: 'agenda',
            builder: (context, state) => const AgendaPage(),
          ),
          GoRoute(
            path: '/mapa',
            name: 'mapa',
            builder: (context, state) => const MapaPage(),
          ),
        ],
      ),

      // Rotas que são mostradas FORA do MainScaffold (tela cheia, sem BottomNav)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/cadastro-expositor',
        name: 'cadastro-expositor',
        builder: (context, state) => const CadastroExpositorPage(),
      ),
      GoRoute(
        path: '/aguardando-aprovacao',
        name: 'aguardando-aprovacao',
        builder: (context, state) => const AguardandoAprovacaoPage(),
      ),
      GoRoute(
        path: '/cadastro-reprovado',
        name: 'cadastro-reprovado',
        builder: (context, state) {
          final expositor = state.extra as Expositor?;
          return CadastroReprovadoPage(expositorReprovado: expositor);
        },
      ),
    ],

    // Lógica de Redirecionamento (O nosso novo e melhorado "AuthWrapper")
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = userProvider.isLoggedIn;
      final bool isLoading = userProvider.isLoading;

      final String? userRole = userProvider.usuario?.papel;
      final String? userStatus = userProvider.expositorProfile?.status;

      final String loginLocation = state.namedLocation('login');
      final bool isGoingToLogin = state.matchedLocation == loginLocation;

      // Se estiver a carregar os dados do utilizador, não redireciona ainda
      if (isLoading) return null;

      // Se o utilizador NÃO está logado...
      if (!isLoggedIn) {
        // ...e não está a tentar ir para a página de login ou cadastro, redireciona-o para /login.
        return isGoingToLogin ||
                state.matchedLocation ==
                    state.namedLocation('cadastro-expositor')
            ? null
            : loginLocation;
      }

      // Se o utilizador ESTÁ logado...
      // Se for um expositor aguardando aprovação, força-o para a tela de espera.
      if (userRole == 'expositor' && userStatus == 'aguardando_aprovacao') {
        return state.matchedLocation ==
                state.namedLocation('aguardando-aprovacao')
            ? null
            : state.namedLocation('aguardando-aprovacao');
      }
      // Se for um expositor reprovado, força-o para a tela de reprovação.
      if (userRole == 'expositor' && userStatus == 'reprovado') {
        // Precisamos de passar o objeto 'expositor' para esta rota
        // Esta lógica de redirect não suporta passar 'extra' diretamente,
        // o que é uma limitação. Uma abordagem seria o provider guardar o objeto
        // e a tela de reprovação buscá-lo do provider.
        return state.matchedLocation ==
                state.namedLocation('cadastro-reprovado')
            ? null
            : state.namedLocation('cadastro-reprovado');
      }

      // Se está logado e tenta aceder à tela de login, redireciona para a home.
      if (isGoingToLogin && userRole == 'admin') {
        return '/expositores'; // Home do Admin
      }
      if (isGoingToLogin && userRole == 'expositor' && userStatus == 'ativo') {
        return '/home'; // Home do Expositor
      }

      // Se nenhuma regra se aplicar, permite a navegação.
      return null;
    },
  );
}
