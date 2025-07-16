// lib/screens/feiras/agenda_screen.dart
import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  static const String routeName = '/agenda';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de Feiras')),
      body: const Center(
        child: Text(
          'Agenda de Feiras do Expositor (Em construção)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
