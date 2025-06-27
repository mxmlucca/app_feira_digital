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

/// Definição de cores personalizadas para o tema do aplicativo
const Color kCorPrimaria = Color.fromARGB(
  255,
  171,
  10,
  78,
); // Cor primária do tema
const Color kCorSecundaria = Color.fromARGB(
  255,
  248,
  172,
  32,
); // Cor secundária do tema
const Color kCorSuperficie = Color.fromARGB(
  255,
  19,
  79,
  130,
); // Cor de superfície do tema
const Color kCorSeed = Color(0xFF134F82); // Cor semente para o esquema de cores
const Color kCorErro = Colors.red; // Cor de erro do tema
const Color kCorTextoPrimaria = Colors.white; // Cor do texto primário
const Color kCorTextoSecundaria = Colors.black; // Cor do texto secundário

/// Classe principal do aplicativo, que define o tema e as rotas.
class MyApp extends StatelessWidget {
  // Construtor da classe MyApp
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feira Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Definição das cores tema do aplicativo
        colorScheme: ColorScheme.fromSeed(
          seedColor: kCorPrimaria, // Cor semente para gerar o esquema de cores
          brightness: Brightness.light, // Define o brilho do tema como escuro
          primary: kCorPrimaria, // Cor primária do tema
          secondary: kCorSecundaria, // Cor secundária do tema
          surface: kCorSecundaria, // Cor de superfície do tema
          error: kCorErro, // Cor de erro do tema
          onPrimary: kCorTextoPrimaria, // Cor do texto sobre a cor primária
          onSecondary:
              kCorTextoSecundaria, // Cor do texto sobre a cor secundária
          onSurface: Colors.white, // Defina a cor do texto sobre superfícies
          onError:
              kCorTextoSecundaria, // Se quiser definir a cor do texto sobre erros
        ),
        useMaterial3: true, // Habilita o Material Design 3
        ///Tema da appBar do aplicativo
        appBarTheme: const AppBarTheme(
          backgroundColor: kCorPrimaria, // Cor de fundo da appBar
          iconTheme: IconThemeData(
            color: kCorTextoPrimaria, // Cor dos ícones na appBar
          ),
          foregroundColor: kCorTextoPrimaria, // Cor do texto na appBar
          elevation: 0, // Define a elevação da appBar
          centerTitle: true, // Centraliza o título da appBar
          /// Estilo do texto do título da appBar
          titleTextStyle: TextStyle(
            fontSize: 20, // Tamanho da fonte do título
            fontWeight: FontWeight.bold, // Peso da fonte do título
            color: kCorTextoPrimaria, // Cor do texto do título
            letterSpacing: 1.2, // Espaçamento entre letras do título
          ),
        ),

        /// Tema do campo de entrada de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Habilita o preenchimento do campo de entrada
          fillColor: Color.fromARGB(
            255,
            31,
            37,
            47,
          ), // Cor de preenchimento do campo de entrada
          /// Estilo do campo de entrada de texto
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ), // Cor da borda quando o campo está habilitado
          ),

          /// Estilo do campo de entrada de texto quando está focado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kCorPrimaria, width: 2.0),
          ),

          /// Estilo do campo de entrada de texto quando há erro
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kCorErro, width: 1.5),
          ),

          /// Estilo do campo de entrada de texto quando está focado e há erro
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kCorErro, width: 2.0),
          ),

          /// Estilo do campo de entrada de texto quando está desabilitado
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ), // Cor do rótulo do campo de entrada

          hintStyle: TextStyle(
            color: Colors.white,
          ), // Cor do texto de dica do campo de entrada
          errorStyle: const TextStyle(
            fontSize: 12.0,
          ), // Estilo do texto de erro do campo de entrada
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          // Icones de prefixo e sufixo
          prefixIconColor: Colors.white, // Cor do ícone de prefixo
          suffixIconColor: Colors.white, // Cor do ícone de sufixo
          // Estilo do texto digitado pelo usuário
          // Para estilizar o texto digitado, defina o style diretamente no TextField/TextFormField.
        ),

        /// Tema dos botões elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kCorPrimaria, // Cor de fundo do botão
            foregroundColor: kCorTextoPrimaria, // Cor do texto do botão
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 2,
          ),
        ),

        /// Tema dos botões de texto
        cardTheme: CardTheme(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          color: Colors.white,
        ),

        /// Tema dos botões flutuantes
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kCorPrimaria, // Cor de fundo do botão flutuante
          foregroundColor: kCorTextoPrimaria, // Cor do texto do botão flutuante
        ),

        /// Tema da barra de navegação inferior
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor:
              kCorPrimaria, // Cor de fundo da barra de navegação inferior
          selectedItemColor: kCorSecundaria, // Cor do item selecionado
          // ignore: deprecated_member_use
          unselectedItemColor: kCorTextoPrimaria.withOpacity(
            0.7,
          ), // Cor dos itens não selecionados
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ), // Estilo do texto do item selecionado
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
          ), // Estilo do texto dos itens não selecionados
          showUnselectedLabels:
              true, // Exibe rótulos para itens não selecionados
          type:
              BottomNavigationBarType
                  .fixed, // Tipo fixo da barra de navegação inferior
        ),

        /// Tema geral do aplicativo, incluindo cores e tipografia
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
          titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: kCorPrimaria,
          ),
          titleMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.grey.shade900),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.grey.shade800),
          bodySmall: TextStyle(fontSize: 12.0, color: Colors.grey.shade600),
          labelLarge: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: kCorTextoPrimaria,
          ),
          // Adiciona um estilo para mensagens de erro
          // Use este estilo em widgets de texto de erro personalizados
          // Exemplo: Text('Erro', style: Theme.of(context).textTheme.labelMedium)
          labelMedium: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: kCorErro,
          ),
        ),

        dialogTheme: DialogTheme(
          // Cor de fundo do diálogo. Usaremos um tom de azul escuro que
          // combina com o fundo dos seus campos de texto.
          backgroundColor: const Color.fromARGB(255, 40, 48, 61),

          // Bordas arredondadas para um visual mais moderno.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),

          // Estilo padrão para o título dos diálogos.
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),

          // Estilo padrão para o texto do conteúdo (o corpo) dos diálogos.
          contentTextStyle: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 16.0,
          ),
        ),
      ),
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
