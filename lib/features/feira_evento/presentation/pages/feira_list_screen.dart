import 'dart:async'; // Importe o 'async' para StreamSubscription
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/feira.dart';
import '../../../../services/firestore_service.dart';
import 'feira_form_screen.dart';
import 'feira_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/user_provider.dart';

class FeiraListScreen extends StatefulWidget {
  const FeiraListScreen({super.key});
  static const String routeName = '/feiras-list';

  @override
  State<FeiraListScreen> createState() => _FeiraListScreenState();
}

class _FeiraListScreenState extends State<FeiraListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late int _anoSelecionado;

  // --- NOSSAS NOVAS VARIÁVEIS DE ESTADO ---
  bool _isLoading = true;
  List<Feira> _todasAsFeiras = [];
  Feira? _feiraAtiva;
  StreamSubscription? _feirasSubscription;
  StreamSubscription? _feiraAtivaSubscription;
  // -----------------------------------------

  @override
  void initState() {
    super.initState();
    _anoSelecionado = DateTime.now().year;

    // Inicia a escuta dos streams
    _feiraAtivaSubscription = _firestoreService.getFeiraAtualStream().listen((
      feira,
    ) {
      if (mounted) {
        setState(() {
          _feiraAtiva = feira;
        });
      }
    });

    _feirasSubscription = _firestoreService.getFeiraEventos().listen((
      listaFeiras,
    ) {
      if (mounted) {
        setState(() {
          _todasAsFeiras = listaFeiras;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // É MUITO IMPORTANTE cancelar as inscrições para evitar vazamentos de memória
    _feirasSubscription?.cancel();
    _feiraAtivaSubscription?.cancel();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, Feira feira) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeiraDetailScreen(feiraEvento: feira),
        settings: RouteSettings(
          name: FeiraDetailScreen.routeName,
          arguments: feira,
        ),
      ),
    );
  }

  // Os métodos _buildCardFeiraAtiva e _buildCardHistorico continuam os mesmos
  Widget _buildCardFeiraAtiva(Feira feiraAtiva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ATUAL',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToDetail(context, feiraAtiva),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  Text(
                    feiraAtiva.titulo.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'dd \'de\' MMMM',
                      'pt_BR',
                    ).format(feiraAtiva.data),
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardHistorico(Feira feira) {
    final bool isFinalizada = feira.status == StatusFeira.finalizada;
    final iconData =
        isFinalizada ? Icons.check_circle_outline : Icons.schedule_outlined;
    final String statusText = isFinalizada ? 'Finalizada' : 'Agendada';

    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          iconData,
          color:
              isFinalizada
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
        ),
        title: Text(feira.titulo),
        subtitle: Text(statusText),
        trailing: Text(DateFormat('dd/MM/yy').format(feira.data)),
        onTap: () => _navigateToDetail(context, feira),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin =
        Provider.of<UserProvider>(context).usuario?.papel == 'admin';

    // A lógica de filtragem agora acontece aqui, diretamente nas listas em memória
    final List<Feira> outrasFeiras =
        _todasAsFeiras.where((f) => f.id != _feiraAtiva?.id).toList();
    final List<Feira> feirasFiltradasPorAno =
        outrasFeiras.where((f) => f.data.year == _anoSelecionado).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (_feiraAtiva != null) _buildCardFeiraAtiva(_feiraAtiva!),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => setState(() => _anoSelecionado--),
                        ),
                        Text(
                          _anoSelecionado.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () => setState(() => _anoSelecionado++),
                        ),
                      ],
                    ),
                  ),

                  if (feirasFiltradasPorAno.isEmpty && outrasFeiras.isNotEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Nenhum outro evento para este ano.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  else if (outrasFeiras.isEmpty && _feiraAtiva == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Nenhum evento cadastrado.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    // O ListView.builder é mais eficiente para listas longas
                    ListView.builder(
                      shrinkWrap: true, // Importante dentro de outro ListView
                      physics:
                          const NeverScrollableScrollPhysics(), // Desativa o scroll deste
                      itemCount: feirasFiltradasPorAno.length,
                      itemBuilder: (context, index) {
                        return _buildCardHistorico(
                          feirasFiltradasPorAno[index],
                        );
                      },
                    ),
                ],
              ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton.extended(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      FeiraFormScreen.routeNameAdd,
                    ),
                label: const Text('Evento'),
                icon: const Icon(Icons.add),
              )
              : null,
    );
  }
}
