import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feira.dart';
import '../../services/firestore_service.dart';
import 'feira_form_screen.dart';
import 'feira_detail_screen.dart';

class FeiraListScreen extends StatefulWidget {
  const FeiraListScreen({super.key});
  static const String routeName = '/feiras-list';

  @override
  State<FeiraListScreen> createState() => _FeiraListScreenState();
}

class _FeiraListScreenState extends State<FeiraListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late int _anoSelecionado;

  @override
  void initState() {
    super.initState();
    _anoSelecionado = DateTime.now().year;
  }

  void _navigateToDetail(Feira evento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeiraDetailScreen(feiraEvento: evento),
      ),
    ).then(
      (_) => setState(() {}),
    ); // Força a reconstrução para atualizar o estado
  }

  // Widget para o card da feira ativa
  Widget _buildFeiraAtivaCard(Feira feiraAtiva, BuildContext context) {
    return Column(
      children: [
        const Text(
          'ATUAL',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 4,
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            title: Text(
              feiraAtiva.titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              DateFormat('dd \'de\' MMMM', 'pt_BR').format(feiraAtiva.data),
              style: const TextStyle(color: Colors.black54),
            ),
            onTap: () => _navigateToDetail(feiraAtiva),
          ),
        ),
      ],
    );
  }

  // Widget para os itens da lista de feiras finalizadas
  Widget _buildFeiraFinalizadaCard(Feira feira, BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        title: Text(feira.titulo, style: const TextStyle(color: Colors.black)),
        trailing: Text(
          DateFormat('dd/MM/yyyy').format(feira.data),
          style: const TextStyle(color: Colors.black54),
        ),
        onTap: () => _navigateToDetail(feira),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: StreamBuilder<List<Feira>>(
        stream: _firestoreService.getFeiraEventos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          // Separa a feira ativa das outras
          Feira? feiraAtiva;
          List<Feira> todasAsFeiras = snapshot.data ?? [];
          List<Feira> feirasFinalizadas = [];

          if (todasAsFeiras.isNotEmpty) {
            try {
              feiraAtiva = todasAsFeiras.firstWhere(
                (f) => f.status == StatusFeira.atual,
              );
            } catch (e) {
              feiraAtiva = null; // Nenhuma feira ativa encontrada
            }
            feirasFinalizadas =
                todasAsFeiras
                    .where((f) => f.status == StatusFeira.finalizada)
                    .toList();
          }

          final feirasFiltradasPorAno =
              feirasFinalizadas
                  .where((f) => f.data.year == _anoSelecionado)
                  .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Mostra o card da feira ativa
                if (feiraAtiva != null)
                  _buildFeiraAtivaCard(feiraAtiva, context),

                // Seletor de Ano
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => setState(() => _anoSelecionado--),
                      ),
                      Text(
                        _anoSelecionado.toString(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => setState(() => _anoSelecionado++),
                      ),
                    ],
                  ),
                ),

                // Lista de Feiras Finalizadas
                Expanded(
                  child:
                      feirasFiltradasPorAno.isEmpty
                          ? const Center(
                            child: Text(
                              'Nenhuma feira finalizada encontrada para este ano.',
                            ),
                          )
                          : ListView.builder(
                            itemCount: feirasFiltradasPorAno.length,
                            itemBuilder: (context, index) {
                              final evento = feirasFiltradasPorAno[index];
                              return _buildFeiraFinalizadaCard(evento, context);
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
      // O botão só aparece se NÃO houver feira ativa
      floatingActionButton: StreamBuilder<Feira?>(
        stream:
            _firestoreService.getFeiraAtualStream(), // Um novo método de stream
        builder: (context, snapshot) {
          final bool temFeiraAtiva = snapshot.hasData && snapshot.data != null;
          return temFeiraAtiva
              ? const SizedBox.shrink() // Não mostra nada se tiver feira ativa
              : FloatingActionButton.extended(
                label: const Text('Evento'),
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    FeiraFormScreen.routeNameAdd,
                  ).then((_) => setState(() {}));
                },
              );
        },
      ),
    );
  }
}
