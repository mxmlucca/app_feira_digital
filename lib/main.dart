import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Gerado pelo flutterfire configure
import 'package:firebase_auth/firebase_auth.dart';

// Importações das Telas
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // Usado na navegação
import 'screens/expositor_list_screen.dart';
import 'screens/expositor_form_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/feira_form_screen.dart';
import 'screens/feira_detail_screen.dart'; // Se já criada e tiver routeName
import 'widgets/main_scaffold.dart'; // Onde está a BottomNavigationBar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Definindo algumas cores para fácil reutilização no tema
const Color kCorPrimaria = Color.fromARGB(255, 149, 188, 32);
const Color kCorSecundaria = Color.fromARGB(255, 255, 158, 1);
const Color kCorSurfice = Color.fromARGB(255, 19, 79, 130);
const Color kCorSeed = Color(0xFF134F82); // Cor base para o ColorScheme
const Color kCorErro = Colors.red; // Cor padrão para erros

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Feira Digital',
      debugShowCheckedModeBanner: false, // Remove o banner de debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kCorSeed,
          primary: kCorPrimaria,
          secondary: kCorSecundaria,
          surface: kCorSurfice, // Cor de fundo para Cards, Dialogs, etc.
          background: Colors.grey.shade100, // Cor de fundo principal da app
          error: kCorErro,
        ),
        useMaterial3: true,

        // TEMA PARA CAMPOS DE INPUT (TextFormField, TextField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Para que a fillColor seja aplicada
          fillColor: Colors.white, // Cor de preenchimento do campo
          // Borda padrão (quando não está focado e não tem erro)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          // Borda quando o campo está focado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kCorSecundaria, width: 2.0),
          ),
          // Borda quando há um erro de validação
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kCorErro, width: 1.5),
          ),
          // Borda quando está focado E há um erro
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: kCorErro, width: 2.0),
          ),
          // Espaçamento interno do campo
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
          // Estilo do label (o texto que fica acima ou dentro do campo)
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          errorStyle: const TextStyle(
            fontSize: 12.0,
          ), // Para mensagens de erro menores
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Comportamento do label
        ),

        // TEMA PARA BOTÕES ELEVADOS
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kCorPrimaria, // Cor de fundo
            foregroundColor: Colors.white, // Cor do texto e ícone
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

        // TEMA PARA APPBAR
        appBarTheme: AppBarTheme(
          backgroundColor: kCorPrimaria,
          foregroundColor: kCorSurfice, // Cor do título e ícones
          elevation: 0, // Sem sombra para um look mais flat, ou pode adicionar
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kCorSurfice,
          ),
        ),

        // TEMA PARA CARDS
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: const Color.fromARGB(255, 0, 0, 0),
              width: 4,
            ),
          ),
          margin: const EdgeInsets.only(
            top: 8.0,
            left: 8.0,
            right: 8.0,
            bottom: 0,
          ),
        ),

        // TEMA PARA FloatingActionButton
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kCorPrimaria,
          foregroundColor: Colors.white,
        ),

        // TEMA PARA BottomNavigationBar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: kCorPrimaria,
          selectedItemColor: kCorSurfice,
          unselectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          showUnselectedLabels: true, // Exibe rótulos não selecionados
        ),
      ),
      home: const AuthChecker(), // Widget que verifica o estado de autenticação
      routes: {
        '/login': (context) => const LoginScreen(),
        MainScaffold.routeName:
            (context) =>
                const MainScaffold(), // Rota para o scaffold principal com BottomBar
        // Rotas para os formulários (adicionar)
        ExpositorFormScreen.routeNameAdd:
            (context) => const ExpositorFormScreen(),
        FeiraFormScreen.routeNameAdd: (context) => const FeiraFormScreen(),

        // Rotas para as listas (geralmente são abas no MainScaffold, mas podemos ter rotas diretas se necessário)
        ExpositorListScreen.routeName: (context) => const ExpositorListScreen(),
        AgendaScreen.routeName: (context) => const AgendaScreen(),
        MapaScreen.routeName: (context) => const MapaScreen(),

        // A rota de edição para ExpositorFormScreen é tipicamente feita com Navigator.push(MaterialPageRoute(...))
        // passando o objeto, mas se quiser uma rota nomeada, pode definir aqui e extrair argumentos.
        // Ex: FeiraFormScreen.routeNameEdit: (context) => FeiraFormScreen(feiraEvento: ModalRoute.of(context)!.settings.arguments as FeiraEvento?),
      },
    );
  }
}

// Widget para verificar o estado de autenticação e NAVEGAR para a tela correta
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;

      if (user == null) {
        print("AuthChecker: Utilizador não logado. Navegando para /login.");
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        print(
          "AuthChecker: Utilizador logado (${user.uid}). Navegando para ${MainScaffold.routeName}.",
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          MainScaffold.routeName,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento enquanto o estado de autenticação é verificado
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
