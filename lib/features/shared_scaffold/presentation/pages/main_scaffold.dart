import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/user_provider.dart';

// Importações das Telas
import '../../../admin_painel/presentation/pages/admin_dashboard_screen.dart';
import '../../../expositor/presentation/pages/admin_aprovacao_screen.dart';
import '../../../expositor/presentation/pages/expositor_list_screen.dart';
import '../../../feira_evento/presentation/pages/feira_list_screen.dart';

import '../../../expositor/presentation/pages/expositor_home_screen.dart';
import '../../../feira_evento/presentation/pages/agenda_screen.dart';
import '../../../auth/presentation/pages/profile_loader_screen.dart';

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
        const AdminDashboardScreen(), // Aba 0: Home/Dashboard do Admin
        const FeiraListScreen(), // Aba 1: Lista de Feiras
        const ExpositorListScreen(), // Aba 2: Lista de Expositores
        const AdminAprovacaoScreen(), // Aba 3: Lista de Aprovações
      ];
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Feiras',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Feirantes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.how_to_reg_outlined),
          activeIcon: Icon(Icons.how_to_reg),
          label: 'Aprovações',
        ),
      ];
    } else {
      // Se for 'expositor' ou qualquer outro papel
      // Telas e Itens de Navegação para o EXPOSITOR
      screens = [
        // A tela 'Meus Dados' pode ser a HomeScreen, ou uma nova ProfileScreen
        const ExpositorHomeScreen(), // Aba 0: Inicio (usando a HomeScreen por enquanto)
        const AgendaScreen(), // Aba 1: Agenda
        const ProfileLoaderScreen(), // Aba 2: Meus Dados (carregando os dados do expositor)
      ];
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.house_outlined),
          activeIcon: Icon(Icons.house),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note),
          label: 'Agenda',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Meu Perfil',
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
