import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feira.dart';
import '../../models/expositor.dart';
import '../../models/registro_presenca.dart';
import '../../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';
import 'feira_form_screen.dart';

class FeiraDetailScreen extends StatefulWidget {
  final Feira feiraEvento;

  const FeiraDetailScreen({super.key, required this.feiraEvento});

  static const String routeName = '/feira-detalhe';

  @override
  State<FeiraDetailScreen> createState() => _FeiraDetailScreenState();
}

class _FeiraDetailScreenState extends State<FeiraDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final FirestoreService _firestoreService = FirestoreService();

  String? _idFeiraAtiva;
  bool _isLoading = true;

  late Feira _feiraAtual;

  List<Expositor> _todosExpositores = [];
  List<Expositor> _expositoresFiltrados = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _feiraAtual = widget.feiraEvento;
    _carregarDadosIniciais();

    _searchController.addListener(() {
      _filtrarExpositores(_searchController.text);
    });
  }

  @override
  void dispose() {
    // 4. Lembre-se de dar dispose no controller
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosIniciais() async {
    setState(() => _isLoading = true);
    final feiraAtiva = await _firestoreService.getFeiraAtual();
    final expositores =
        await _firestoreService
            .getExpositores()
            .first; // Pega a primeira emissão da lista

    if (mounted) {
      List<Expositor> expositoresAtivos =
          expositores.where((e) => e.status == 'ativo').toList();
      // --- ORDENAÇÃO POR ESTANDE ---
      expositoresAtivos.sort((a, b) {
        int? numA = int.tryParse(a.numeroEstande ?? '');
        int? numB = int.tryParse(b.numeroEstande ?? '');
        if (numA != null && numB != null) return numA.compareTo(numB);
        return (a.numeroEstande ?? '').compareTo(b.numeroEstande ?? '');
      });
      setState(() {
        _idFeiraAtiva = feiraAtiva?.id;
        _todosExpositores =
            expositores.where((e) => e.status == 'ativo').toList();
        _expositoresFiltrados = _todosExpositores;
        _isLoading = false;
      });
    }
  }

  void _filtrarExpositores(String query) {
    if (query.isEmpty) {
      _expositoresFiltrados = _todosExpositores;
    } else {
      _expositoresFiltrados =
          _todosExpositores.where((expositor) {
            return expositor.nome.toLowerCase().contains(query.toLowerCase());
          }).toList();
    }
    setState(() {});
  }

  Future<void> _confirmarPresenca(
    String expositorId,
    StatusPresenca status,
  ) async {
    await _firestoreService.confirmarPresencaFinal(
      feiraId: _feiraAtual.id!,
      expositorId: expositorId,
      statusFinal: status,
    );
    // Atualiza o estado local para refletir a mudança imediatamente
    setState(() {
      _feiraAtual.presencaExpositores[expositorId] = RegistroPresenca(
        nomeExpositor:
            _feiraAtual.presencaExpositores[expositorId]?.nomeExpositor ?? '',
        categoria:
            _feiraAtual.presencaExpositores[expositorId]?.categoria ?? '',
        presencaFinal: status,
        // Mantém outros dados se existirem
        interesse:
            _feiraAtual.presencaExpositores[expositorId]?.interesse ??
            StatusInteresse.pendente,
        checkinGps:
            _feiraAtual.presencaExpositores[expositorId]?.checkinGps ?? false,
      );
    });
  }

  Future<void> _carregarFeiraAtiva() async {
    final feiraAtiva = await _firestoreService.getFeiraAtual();
    if (mounted) {
      setState(() {
        _idFeiraAtiva = feiraAtiva?.id;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmarERemoverFeira() async {
    final bool confirmar =
        await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Confirmar Remoção'),
                content: const Text(
                  'Tem certeza que deseja remover esta feira? Esta ação é irreversível.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Remover',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmar) {
      try {
        await _firestoreService.removerFeiraEvento(widget.feiraEvento.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feira removida com sucesso!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao remover: $e')));
        }
      }
    }
  }

  Future<void> _tornarFeiraAtiva() async {
    bool prosseguir = true;
    if (_idFeiraAtiva != null && _idFeiraAtiva != widget.feiraEvento.id) {
      prosseguir =
          await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Substituir Feira Ativa?'),
                  content: const Text(
                    'Já existe uma feira ativa. Deseja tornar esta a nova feira ativa? A anterior será marcada como agendada.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Substituir'),
                    ),
                  ],
                ),
          ) ??
          false;
    }

    if (prosseguir && mounted) {
      await _firestoreService.setFeiraAtiva(widget.feiraEvento.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feira definida como ativa!')),
      );
      Navigator.of(context).pop();
    }
  }

  // --- MÉTODO PARA O BOTÃO DE FINALIZAR ---
  Future<void> _finalizarFeira() async {
    // A lógica complexa não é mais necessária aqui, pois o botão só aparece
    // se esta for a feira ativa.
    await _firestoreService.finalizarFeiraAtiva(widget.feiraEvento.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feira marcada como finalizada.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _recarregarDadosDaFeira() async {
    final feiraAtualizada = await _firestoreService.getFeiraEventoPorId(
      _feiraAtual.id!,
    );
    if (feiraAtualizada != null && mounted) {
      setState(() {
        _feiraAtual = feiraAtualizada;
      });
    }
  }

  Future<void> _navegarParaEdicao() async {
    // `await` espera a tela de edição fechar
    final foiModificado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FeiraFormScreen(feiraEvento: _feiraAtual),
      ),
    );

    // Se a tela de edição retornou 'true', recarregue os dados
    if (foiModificado == true) {
      _recarregarDadosDaFeira();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isAdmin = userProvider.usuario?.papel == 'admin';
    final theme = Theme.of(context);

    final bool isFeiraAtiva = widget.feiraEvento.id == _idFeiraAtiva;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feiraEvento.titulo),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Feira',
              onPressed: _navegarParaEdicao,
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover Feira',
              onPressed: _confirmarERemoverFeira,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Visão Geral'),
            Tab(icon: Icon(Icons.playlist_add_check), text: 'Presenças'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Estatísticas'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  // Cada "filho" é o conteúdo de uma aba
                  _buildTabVisaoGeral(context),
                  _buildTabGestaoPresenca(context),
                  _buildTabEstatisticas(context),
                ],
              ),
    );
  }

  // --- WIDGETS PARA CADA ABA ---

  /// Constrói o conteúdo da aba "Visão Geral"
  Widget _buildTabVisaoGeral(BuildContext context) {
    // Este widget conterá os detalhes da feira e os botões de ação principais.
    // Reutilizamos a lógica que já tínhamos.
    final bool isAdmin =
        Provider.of<UserProvider>(context, listen: false).usuario?.papel ==
        'admin';
    final theme = Theme.of(context);
    final bool isFeiraAtiva = _feiraAtual.id == _idFeiraAtiva;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Aqui entram os cards de informação, mapa interativo, etc.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detalhes da Feira', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy').format(_feiraAtual.data)}',
                ),
                if (_feiraAtual.anotacoes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Anotações: ${_feiraAtual.anotacoes}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lógica dos botões de ação que já tínhamos
        if (isAdmin) ...[
          if (_feiraAtual.status == StatusFeira.agendada && !isFeiraAtiva)
            ElevatedButton.icon(
              icon: const Icon(Icons.star_outline),
              label: const Text('Tornar Esta Feira Ativa'),
              onPressed: _tornarFeiraAtiva,
            ),

          if (isFeiraAtiva)
            OutlinedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como Finalizada'),
              onPressed: _finalizarFeira,
            ),
        ],
      ],
    );
  }

  Widget _buildTabGestaoPresenca(BuildContext context) {
    final Map<String, List<Expositor>> expositoresPorCategoria = {};
    for (var expositor in _expositoresFiltrados) {
      (expositoresPorCategoria[expositor.tipoProdutoServico] ??= []).add(
        expositor,
      );
    }

    final categoriasOrdenadas = expositoresPorCategoria.keys.toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar Feirante por nome...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categoriasOrdenadas.length,
            itemBuilder: (context, index) {
              final categoria = categoriasOrdenadas[index];
              final expositoresDaCategoria =
                  expositoresPorCategoria[categoria]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header da Categoria
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      categoria.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // Lista de expositores daquela categoria
                  ...expositoresDaCategoria.map((expositor) {
                    final registro =
                        _feiraAtual.presencaExpositores[expositor.id];
                    return _buildExpositorPresenceCard(expositor, registro);
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Card individual para cada expositor na lista de gestão
  Widget _buildExpositorPresenceCard(
    Expositor expositor,
    RegistroPresenca? registro,
  ) {
    final theme = Theme.of(context);
    final statusInteresse = registro?.interesse ?? StatusInteresse.pendente;
    final checkinGps = registro?.checkinGps ?? false;
    final presencaFinal = registro?.presencaFinal ?? StatusPresenca.pendente;

    Color cardColor = Colors.white;
    if (presencaFinal == StatusPresenca.presente)
      cardColor = Colors.green.shade50;
    else if (presencaFinal == StatusPresenca.ausente)
      cardColor = Colors.red.shade50;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                // Círculo com o número do estande
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    expositor.numeroEstande ?? 'S/N',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    expositor.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  'Interesse',
                  statusInteresse.name,
                  statusInteresse != StatusInteresse.pendente,
                ),
                _buildStatusChip(
                  'Check-in GPS',
                  checkinGps ? 'Realizado' : 'Não',
                  checkinGps,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (presencaFinal == StatusPresenca.pendente)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Presente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed:
                          () => _confirmarPresenca(
                            expositor.id!,
                            StatusPresenca.presente,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Ausente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed:
                          () => _confirmarPresenca(
                            expositor.id!,
                            StatusPresenca.ausente,
                          ),
                    ),
                  ),
                ],
              )
            else
              // --- SEÇÃO COM O BOTÃO DE REFAZER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Presença Final: ${presencaFinal.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          presencaFinal == StatusPresenca.presente
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botão para resetar o status para 'pendente'
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.grey),
                    tooltip: 'Editar Presença',
                    onPressed:
                        () => _confirmarPresenca(
                          expositor.id!,
                          StatusPresenca.pendente,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Chip de status auxiliar
  Widget _buildStatusChip(String label, String value, bool isActive) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Chip(
          label: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor:
              isActive ? Colors.blue.shade100 : Colors.grey.shade200,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Constrói o conteúdo da aba "Estatísticas"
  Widget _buildTabEstatisticas(BuildContext context) {
    // Onde nosso dashboard de estatísticas será construído.
    // Por enquanto, um placeholder.
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Aqui ficará o dashboard com as estatísticas da feira. (Em construção)',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
