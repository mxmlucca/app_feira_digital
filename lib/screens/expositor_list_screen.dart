import 'package:flutter/material.dart';
import 'dart:async'; // Para o Debouncer da pesquisa
import '../models/expositor.dart';
import '../services/firestore_service.dart';
import 'expositor_form_screen.dart';
import 'expositor_detail_screen.dart'; // Importa a tela de detalhes
import '../widgets/expositor_list_item.dart'; // Nosso widget de item de lista

// Supondo que kCoresCategorias e kOrdemCategorias (ou kCategoriasExpositor)
// estão definidas aqui ou importadas de um ficheiro de constantes.
// const Map<String, Color> kCoresCategorias = { /* ... seu mapa de cores ... */ };
// final List<String> kOrdemCategorias = [ /* ... sua ordem de categorias ... */ ];
// Se kCategoriasExpositor é a lista que inclui "Outros" e é usada para os filtros:
// final List<String> kFiltrosCategorias = ['Todos', ...kCategoriasExpositor];

// Exemplo (coloque as suas definições reais)
const Map<String, Color> kCoresCategorias = {
  'Artesanato': Colors.brown,
  'Alimentação': Colors.orange,
  'Bebidas': Colors.blue,
  'Vestuário': Colors.purple,
  'Serviços': Colors.teal,
  'Outros': Colors.grey,
};
// Usaremos esta lista para as abas, incluindo "Todos"
final List<String> kAbasCategorias = [
  'Todos',
  'Alimentação',
  'Bebidas',
  'Artesanato',
  'Vestuário',
  'Serviços',
  'Outros',
];

class ExpositorListScreen extends StatefulWidget {
  const ExpositorListScreen({super.key});
  static const String routeName = '/expositores-list';

  @override
  State<ExpositorListScreen> createState() => _ExpositorListScreenState();
}

class _ExpositorListScreenState extends State<ExpositorListScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  TabController? _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  Timer? _debounce; // Para o debounce da pesquisa

  // Lista de todos os expositores vinda do Firestore
  List<Expositor> _todosExpositoresFirestore = [];
  // Lista de expositores a ser exibida (após filtros e pesquisa)
  List<Expositor> _expositoresFiltradosParaExibicao = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: kAbasCategorias.length, vsync: this);
    _tabController!.addListener(_handleTabSelection); // Ouve mudanças de aba
    _searchController.addListener(
      _onSearchChanged,
    ); // Ouve mudanças na pesquisa

    // Carrega os expositores iniciais
    _carregarEFiltrarExpositores();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      // A aba está a mudar, então precisamos de refiltrar
      _filtrarExpositores();
    } else if (_tabController != null &&
        !_tabController!.indexIsChanging &&
        mounted) {
      // A aba foi selecionada (não apenas durante o swipe)
      _filtrarExpositores();
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Verifica se o widget ainda está na árvore
        setState(() {
          _searchTerm = _searchController.text.toLowerCase().trim();
          _filtrarExpositores();
        });
      }
    });
  }

  void _carregarEFiltrarExpositores() {
    // Ouve o stream de todos os expositores
    _firestoreService.getExpositores().listen((listaDoFirestore) {
      if (mounted) {
        setState(() {
          _todosExpositoresFirestore = listaDoFirestore;
          _filtrarExpositores(); // Aplica os filtros e pesquisa atuais
        });
      }
    });
  }

  void _filtrarExpositores() {
    List<Expositor> listaAtual = List.from(
      _todosExpositoresFirestore,
    ); // Começa com todos

    // 1. Filtrar por Categoria (da aba selecionada)
    final String categoriaSelecionada =
        kAbasCategorias[_tabController?.index ?? 0];
    if (categoriaSelecionada != 'Todos') {
      listaAtual =
          listaAtual
              .where((ex) => ex.tipoProdutoServico == categoriaSelecionada)
              .toList();
    }

    // 2. Filtrar por Termo de Pesquisa
    if (_searchTerm.isNotEmpty) {
      listaAtual =
          listaAtual.where((ex) {
            return ex.nome.toLowerCase().contains(_searchTerm) ||
                ex.descricao.toLowerCase().contains(_searchTerm) ||
                ex.tipoProdutoServico.toLowerCase().contains(_searchTerm) ||
                (ex.numeroEstande?.toLowerCase().contains(_searchTerm) ??
                    false);
          }).toList();
    }

    // 3. Ordenar
    listaAtual.sort((a, b) {
      bool aTemEstande = a.numeroEstande != null && a.numeroEstande!.isNotEmpty;
      bool bTemEstande = b.numeroEstande != null && b.numeroEstande!.isNotEmpty;

      if (aTemEstande && !bTemEstande) return -1;
      if (!aTemEstande && bTemEstande) return 1;
      if (aTemEstande && bTemEstande) {
        int? numA = int.tryParse(a.numeroEstande!);
        int? numB = int.tryParse(b.numeroEstande!);
        if (numA != null && numB != null) {
          if (numA != numB) return numA.compareTo(numB);
        } else {
          int compEstande = a.numeroEstande!.toLowerCase().compareTo(
            b.numeroEstande!.toLowerCase(),
          );
          if (compEstande != 0) return compEstande;
        }
      }
      // Se estandes são iguais ou ambos não têm, ordena por nome
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });

    setState(() {
      _expositoresFiltradosParaExibicao = listaAtual;
    });
  }

  void _navigateToForm({Expositor? expositor}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpositorFormScreen(expositor: expositor),
        settings: RouteSettings(
          name: ExpositorFormScreen.routeNameEdit,
          arguments: expositor,
        ),
      ),
    ).then((_) {
      // Quando volta do formulário, pode ser que a lista precise ser atualizada
      // _carregarEFiltrarExpositores(); // O Stream já faz isso, mas um setState pode forçar
      // Se o stream não pegar mudanças imediatas (o que não deve acontecer),
      // um setState aqui pode ajudar a refazer a filtragem com os dados mais recentes.
      _filtrarExpositores(); // Para garantir que a lista reflete adições/edições
    });
  }

  void _navigateToDetail(Expositor expositor) {
    print('Navegando para detalhes do expositor: ${expositor.nome}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpositorDetailScreen(expositor: expositor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Para usar no estilo da AppBar
    // Cores do seu Figma
    final Color corFundoPesquisaCategorias =
        Colors.white; // Ou a cor cinza clara do seu figma
    final Color corTextoCategorias =
        Colors.black87; // Ou a cor dos textos de categoria
    final Color corIconePesquisa = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feirantes'), // Ou 'Expositores'
        // A cor e o estilo vêm do ThemeData
      ),
      body: Column(
        children: [
          // BARRA DE PESQUISA
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou estande',
                prefixIcon: Icon(Icons.search, color: corIconePesquisa),
                filled: true,
                fillColor: corFundoPesquisaCategorias,
                // Usando o tema global, mas pode personalizar se quiser uma borda diferente
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ), // Borda bem arredondada como no Figma
                  borderSide:
                      BorderSide
                          .none, // Sem borda visível se o fundo já contrasta
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          // ABAS DE CATEGORIA
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor:
                theme.colorScheme.primary, // Cor do texto da aba selecionada
            unselectedLabelColor: corTextoCategorias,
            indicatorColor:
                theme.colorScheme.primary, // Cor do indicador da aba
            indicatorWeight: 3.0,
            tabs:
                kAbasCategorias.map((String categoria) {
                  return Tab(text: categoria);
                }).toList(),
          ),
          // LISTA DE EXPOSITORES
          Expanded(
            child:
                _expositoresFiltradosParaExibicao.isEmpty &&
                        _searchTerm.isNotEmpty
                    ? Center(
                      child: Text(
                        'Nenhum expositor encontrado para "${_searchController.text}".',
                      ),
                    )
                    : _expositoresFiltradosParaExibicao.isEmpty &&
                        kAbasCategorias[_tabController?.index ?? 0] != 'Todos'
                    ? Center(
                      child: Text(
                        'Nenhum expositor na categoria "${kAbasCategorias[_tabController?.index ?? 0]}".',
                      ),
                    )
                    : _expositoresFiltradosParaExibicao.isEmpty
                    ? const Center(
                      child: Text('Nenhum expositor cadastrado ainda.'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                      ), // Espaço acima da lista
                      itemCount: _expositoresFiltradosParaExibicao.length,
                      itemBuilder: (context, index) {
                        final expositor =
                            _expositoresFiltradosParaExibicao[index];
                        return ExpositorListItem(
                          // Usando o widget customizado
                          expositor: expositor,
                          onTap:
                              () => _navigateToDetail(
                                expositor,
                              ), // Ação ao clicar no card
                          // Os botões de onEdit e onDelete foram removidos do item
                          // A edição/remoção pode estar na tela de detalhes ou por um gesto (swipe)
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expositor_list_screen', // Mantém a heroTag única
        onPressed: () => _navigateToForm(), // Navega para adicionar novo
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Feirante'), // "+ Feirante"
        tooltip: 'Adicionar Novo Feirante',
        // O estilo vem do tema global
      ),
    );
  }
}
