import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar o Provider
import '../services/user_provider.dart'; // Importar o nosso UserProvider

// Importações das Telas
import '../screens/home_screen.dart';
import '../screens/expositor_list_screen.dart';
import '../screens/mapa_screen.dart';
import '../screens/feira_list_screen.dart';
import '../screens/profile/profile_loader_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  static const String routeName = '/main-scaffold';

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o UserProvider para aceder ao papel do utilizador
    final userProvider = Provider.of<UserProvider>(context);
    // Obtém o papel, com um padrão de 'expositor' caso ainda seja nulo (enquanto carrega)
    final String userRole = userProvider.usuario?.papel ?? 'expositor';

    // --- CONSTRUÇÃO DINÂMICA DA NAVEGAÇÃO ---

    List<Widget> screens = [];
    List<BottomNavigationBarItem> navItems = [];

    if (userRole == 'admin') {
      // Telas e Itens de Navegação para o ADMIN
      screens = [
        const HomeScreen(), // Aba 0: Home/Dashboard do Admin
        const ExpositorListScreen(), // Aba 1: Lista de Expositores
        const MapaScreen(), // Aba 2: Mapa
        const AgendaScreen(), // Aba 3: Agenda de Feiras
      ];
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Admin Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Expositores',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event),
          label: 'Agenda',
        ),
      ];
    } else {
      // Se for 'expositor' ou qualquer outro papel
      // Telas e Itens de Navegação para o EXPOSITOR
      screens = [
        // A tela 'Meus Dados' pode ser a HomeScreen, ou uma nova ProfileScreen
        const HomeScreen(), // Aba 0: Meus Dados (usando a HomeScreen por enquanto)
        const MapaScreen(), // Aba 1: Mapa
        const ProfileLoaderScreen(), // Aba 2: Meus Dados (carregando os dados do expositor)
      ];
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.house),
          activeIcon: Icon(Icons.house_outlined),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          activeIcon: Icon(Icons.person_outline),
          label: 'Meus Dados',
        ),
      ];
    }

    // Garante que o índice selecionado não está fora dos limites se o número de abas mudar
    // (ex: ao fazer logout de admin e login como expositor, ou vice-versa, se isso fosse possível sem reiniciar)
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens, // Usa a lista de telas dinâmica
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems, // Usa a lista de itens dinâmica
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // O estilo (cores, etc.) já vem do BottomNavigationBarThemeData no seu main.dart
      ),
    );
  }
}
