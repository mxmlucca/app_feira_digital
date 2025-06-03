import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feira_evento.dart';
import '../services/firestore_service.dart';
import 'feira_form_screen.dart';
import 'feira_detail_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  static const String routeName = '/agenda';

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de Feiras'), centerTitle: true),
      body: StreamBuilder<List<FeiraEvento>>(
        stream: _firestoreService.getFeiraEventos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar eventos: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma feira agendada ainda.'));
          }

          final feiraEventos = snapshot.data!;

          return ListView.builder(
            itemCount: feiraEventos.length,
            itemBuilder: (context, index) {
              final evento = feiraEventos[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  title: Text(
                    evento.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(evento.data)}\n'
                    'Status: ${evento.statusToString[0].toUpperCase() + evento.statusToString.substring(1)}\n',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FeiraDetailScreen(feiraEvento: evento),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_agenda_screen',
        onPressed: () {
          Navigator.pushNamed(context, FeiraFormScreen.routeNameAdd);
        },
        tooltip: 'Adicionar Nova Feira',
        label: const Text('Feira'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
