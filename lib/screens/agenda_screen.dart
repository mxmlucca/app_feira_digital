import 'package:flutter/material.dart';
import '../models/feira_evento.dart';
import '../services/firestore_service.dart';
import 'feira_form_screen.dart';
import 'feira_detail_screen.dart';
import '../widgets/feira_list_item.dart'; // <--- ADICIONE ESTA IMPORTAÇÃO

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  static const String routeName = '/agenda';

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToDetail(FeiraEvento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeiraDetailScreen(feiraEvento: evento),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Feiras'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.add_circle_outline),
          //   tooltip: 'Adicionar Nova Feira',
          //   onPressed: () {
          //     Navigator.pushNamed(context, FeiraFormScreen.routeNameAdd);
          //   },
          // ),
        ],
      ),
      body: StreamBuilder<List<FeiraEvento>>(
        stream: _firestoreService.getFeiraEventos(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Erro: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text('Nenhuma feira agendada.'));

          final feiraEventos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0), // Padding geral para a lista
            itemCount: feiraEventos.length,
            itemBuilder: (context, index) {
              final evento = feiraEventos[index];
              // AGORA USAMOS O NOSSO WIDGET CUSTOMIZADO
              return FeiraListItem(
                feiraEvento: evento,
                onTap: () {
                  _navigateToDetail(evento);
                },
              );
            },
          );
        },
      ),
      // Removi o FAB daqui porque adicionei o botão de adicionar na AppBar
      // para um design mais limpo e consistente com a ExpositorListScreen.
      // Se preferir o FAB, pode descomentar aqui e remover o IconButton da AppBar.
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_agenda_screen', // Lembre-se da heroTag única
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
