import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/expositor_list_screen.dart';
import '../screens/mapa_screen.dart';
import '../screens/agenda_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static const String routeName =
      '/main-scaffold'; // Mantive o seu nome de rota

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Definindo as telas diretamente aqui.
  // Se elas se tornarem StatefulWidgets e precisarem de argumentos
  // ou de serem reconstruídas de forma diferente, esta abordagem pode precisar de ajuste.
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const ExpositorListScreen(),
    const MapaScreen(),
    const AgendaScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Expositores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Agenda',
          ),
        ],
        currentIndex: _selectedIndex,
        // O estilo virá do BottomNavigationBarThemeData em main.dart
        onTap: _onItemTapped,
      ),
    );
  }
}
