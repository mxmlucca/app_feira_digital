/// main.dart

/// Importação de pacotes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/user_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

/// Models
import '../models/expositor.dart';
import '../models/feira.dart';

/// Importação de telas e widgets
import 'screens/login_screen.dart';
import 'screens/expositores/expositor_form_screen.dart';
import 'screens/expositores/expositor_detail_screen.dart';
import 'screens/admin/admin_expositor_detail_screen.dart';
import 'screens/feiras/feira_form_screen.dart';
import 'screens/cadastro/cadastro_expositor_screen.dart';
import 'screens/cadastro/cadastro_aprovacao_screen.dart';
import 'screens/cadastro/cadastro_reprovado_screen.dart';
import 'screens/mapa/mapa_viewer_screen.dart';
import 'screens/admin/admin_aprovacao_screen.dart';
import 'widgets/main_scaffold.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/expositores/expositor_home_screen.dart';
import 'screens/feiras/agenda_screen.dart';

import 'core/theme/app_theme.dart';

/// Função principal que inicia o aplicativo Flutter.
// - 'async' permite o uso de operações assíncronas, como inicialização de plugins.
// - 'WidgetsFlutterBinding.ensureInitialized()' garante que o binding do Flutter esteja pronto antes de executar código assíncrono ou inicializar plugins.
// - 'Firebase.initializeApp(...)' inicializa o Firebase com as configurações da plataforma atual, necessário antes de usar qualquer serviço do Firebase.
// - 'runApp(const MyApp())' inicia o aplicativo, exibindo o widget raiz (MyApp) na tela.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      webProvider: ReCaptchaV3Provider(
        '6LdnsmorAAAAALGjF_-ofHO9gmXG2GtbARvd0tFH',
      ),
    );

    print("Firebase e AppCheck inicializados.");
  } else {
    print("Firebase já inicializado.");
  }

  runApp(
    // Envolve a aplicação com o provider
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

/// Classe principal do aplicativo, que define o tema e as rotas.
class MyApp extends StatelessWidget {
  // Construtor da classe MyApp
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feira Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        print('Rota solicitada: ${settings.name}');

        // Rotas Publicas
        if (settings.name == LoginScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
        if (settings.name == CadastroExpositorScreen.routeName) {
          return MaterialPageRoute(
            builder: (context) => const CadastroExpositorScreen(),
          );
        }

        // --- VERIFICAÇÃO DE AUTENTICAÇÃO ---
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }

        // Rotas Protegidas
        switch (settings.name) {
          // Rotas de Cadastro
          case CadastroReprovadoScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => CadastroReprovadoScreen(),
            );

          // Main
          case MainScaffold.routeName:
            return MaterialPageRoute(
              builder: (context) => const MainScaffold(),
            );

          // Expositor
          case ExpositorHomeScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const ExpositorHomeScreen(),
            );

          case ExpositorFormScreen.routeNameAdd:
            return MaterialPageRoute(
              builder: (context) => const ExpositorFormScreen(),
            );

          case ExpositorFormScreen.routeNameEdit:
            final expositor = settings.arguments as Expositor?;
            return MaterialPageRoute(
              builder: (context) => ExpositorFormScreen(expositor: expositor),
            );

          case ExpositorDetailScreen.routeName:
            final expositor = settings.arguments as Expositor;
            return MaterialPageRoute(
              builder: (context) => ExpositorDetailScreen(expositor: expositor),
            );

          // Feira
          case FeiraFormScreen.routeNameAdd:
            return MaterialPageRoute(
              builder: (context) => const FeiraFormScreen(),
            );

          case FeiraFormScreen.routeNameEdit:
            final feiraEvento = settings.arguments as Feira?;
            return MaterialPageRoute(
              builder: (context) => FeiraFormScreen(feiraEvento: feiraEvento),
            );

          case AgendaScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const AgendaScreen(),
            );

          // Mapa
          case MapaViewerScreen.routeName:
            final mapaUrl = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => MapaViewerScreen(mapaUrl: mapaUrl),
            );

          // Admin
          case AdminDashboardScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            );

          case AdminAprovacaoScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const AdminAprovacaoScreen(),
            );

          case AdminExpositorDetailScreen.routeName:
            final expositor = settings.arguments as Expositor;
            return MaterialPageRoute(
              builder:
                  (context) => AdminExpositorDetailScreen(expositor: expositor),
            );
        }
      },
    );
  }
}

/// Classe AuthWrapper que verifica o estado de autenticação do utilizador
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      // Usando Consumer como na última vez
      // Alternativa para o builder do Consumer no AuthWrapper
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.usuario == null) {
          return const LoginScreen();
        }

        // Se o papel for admin, é simples.
        if (userProvider.usuario!.papel == 'admin') {
          return const MainScaffold();
        }
        if (userProvider.usuario!.papel == 'expositor') {
          if (userProvider.expositorProfile == null) {
            print(
              "AuthWrapper: Aguardando perfil do expositor ser carregado...",
            );
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final statusExpositor = userProvider.expositorProfile!.status;
          print("AuthWrapper: Expositor logado com status: $statusExpositor");

          if (statusExpositor == 'ativo') {
            return const MainScaffold();
          } else if (statusExpositor == 'reprovado') {
            return CadastroReprovadoScreen(
              expositorReprovado: userProvider.expositorProfile,
            );
          } else {
            return const AguardandoAprovacaoScreen();
          }
        }
        return const LoginScreen();
      },
    );
  }
}
