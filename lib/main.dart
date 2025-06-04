/// main.dart

/// Importação de pacotes necessários
import 'package:flutter/material.dart'; // Flutter framework
import 'package:firebase_core/firebase_core.dart'; // Firebase core para inicialização
import 'firebase_options.dart'; // Configurações do Firebase geradas pelo FlutterFire CLI
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth para autenticação

/// Importação de telas e widgets
import 'screens/login_screen.dart'; // Tela de login
import 'screens/expositor_list_screen.dart'; // Tela de lista de expositores
import 'screens/expositor_form_screen.dart'; // Tela de formulário de expositores
import 'screens/mapa_screen.dart'; // Tela de mapa
import 'screens/agenda_screen.dart'; // Tela de agenda
import 'screens/feira_form_screen.dart'; // Tela de formulário de feira
import 'widgets/main_scaffold.dart'; // Scaffold principal com BottomNavigationBar

/// Função principal que inicia o aplicativo Flutter.
// - 'async' permite o uso de operações assíncronas, como inicialização de plugins.
// - 'WidgetsFlutterBinding.ensureInitialized()' garante que o binding do Flutter esteja pronto antes de executar código assíncrono ou inicializar plugins.
// - 'Firebase.initializeApp(...)' inicializa o Firebase com as configurações da plataforma atual, necessário antes de usar qualquer serviço do Firebase.
// - 'runApp(const MyApp())' inicia o aplicativo, exibindo o widget raiz (MyApp) na tela.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
      title: 'Feira Digital', // Título do aplicativo
      debugShowCheckedModeBanner:
          false, // Desativa a faixa de depuração no canto superior direito
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
            borderSide: const BorderSide(color: kCorSecundaria, width: 2.0),
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
            color: Colors.grey.shade700,
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
        ),
      ),

      /// Definição das rotas do aplicativo
      home:
          const AuthWrapper(), // Tela inicial que verifica o estado de autenticação do utilizador
      routes: {
        '/login':
            (context) =>
                const LoginScreen(), // Rota de fallback ou para navegação explícita
        MainScaffold.routeName:
            (context) =>
                const MainScaffold(), // Rota de fallback ou para navegação explícita
        ExpositorFormScreen.routeNameAdd:
            (context) => const ExpositorFormScreen(),
        FeiraFormScreen.routeNameAdd: (context) => const FeiraFormScreen(),
        ExpositorListScreen.routeName: (context) => const ExpositorListScreen(),
        AgendaScreen.routeName: (context) => const AgendaScreen(),
        MapaScreen.routeName: (context) => const MapaScreen(),
      },
    );
  }
}

/// Classe AuthWrapper que verifica o estado de autenticação do utilizador
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance
              .authStateChanges(), // Escuta as mudanças no estado de autenticação do Firebase
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        // Mostra um spinner enquanto verifica o estado de autenticação
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("AuthWrapper: Verificando estado de autenticação...");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o snapshot tem um utilizador (não nulo), o utilizador está logado
        if (snapshot.hasData && snapshot.data != null) {
          // snapshot.data pode ser User ou null
          print(
            "AuthWrapper: Utilizador ${snapshot.data!.uid} logado. Mostrando MainScaffold.",
          );
          return const MainScaffold(); // Mostra a tela principal com BottomNavBar
        } else {
          // Se não há utilizador (snapshot.data é null), mostra a tela de login
          print(
            "AuthWrapper: Nenhum utilizador logado. Mostrando LoginScreen.",
          );
          return const LoginScreen(); // Mostra a tela de login
        }
      },
    );
  }
}
