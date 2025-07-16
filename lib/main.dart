/// main.dart

/// Importação de pacotes
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/controllers/user_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:go_router/go_router.dart';

/// Importação de telas e widgets
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

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
    final userProvider = context.watch<UserProvider>();

    final GoRouter router = AppRouter(userProvider: userProvider).router;

    return MaterialApp.router(
      title: 'Feira Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
