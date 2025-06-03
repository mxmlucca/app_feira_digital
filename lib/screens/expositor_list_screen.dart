import 'package:flutter/material.dart';
import '../models/expositor.dart';
import '../services/firestore_service.dart';
import 'expositor_form_screen.dart';
// Se kCoresCategorias e kCategoriasExpositor estiverem em outro ficheiro, importe-os
// import '../utils/app_constants.dart'; // Exemplo

// Supondo que kCoresCategorias está definido aqui ou importado
const Map<String, Color> kCoresCategorias = {
  'Artesanato': Colors.brown,
  'Alimentação': Colors.orange,
  'Bebidas': Colors.blue,
  'Vestuário': Colors.purple,
  'Serviços': Colors.teal,
  'Outros': Colors.grey,
};

// Supondo que kCategoriasExpositor (a lista de todas as categorias possíveis para ordenação das seções)
// está definida aqui ou importada. É importante para a ordem das seções.
// Se não tiver uma ordem específica, podemos pegar as categorias dos próprios expositores.
// Para uma ordem definida, use algo como:
final List<String> kOrdemCategorias = [
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

class _ExpositorListScreenState extends State<ExpositorListScreen> {
  // Não precisa mais do TickerProviderStateMixin se não tivermos mais TabBar aqui
  final FirestoreService _firestoreService = FirestoreService();

  // As funções _navigateToForm e _removerExpositor permanecem as mesmas
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
    );
  }

  Future<void> _removerExpositor(String id) async {
    bool confirmar =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Remoção'),
              content: const Text(
                'Tem a certeza de que deseja remover este expositor?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remover'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmar) {
      try {
        await _firestoreService.removerExpositor(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expositor removido com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao remover expositor: $e')),
          );
        }
      }
    }
  }

  // Nova função para construir o item da lista (para reutilização)
  Widget _buildExpositorItem(Expositor expositor) {
    final Color corDaCategoria =
        kCoresCategorias[expositor.tipoProdutoServico] ?? Colors.black54;

    return Card(
      // Usando o CardTheme definido globalmente ou personalizações locais
      // margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      // elevation: 2.0,
      child: InkWell(
        onTap: () {
          // TODO: Navegar para ExpositorDetailScreen(expositor: expositor)
          print('Expositor selecionado: ${expositor.nome}');
        },
        borderRadius: BorderRadius.circular(10.0), // Do CardTheme
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                child: Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: corDaCategoria,
                    foregroundColor: Colors.white,
                    child: Text(
                      expositor.numeroEstande != null &&
                              expositor.numeroEstande!.isNotEmpty
                          ? expositor.numeroEstande!
                          : 'S/N',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expositor.nome,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Categoria: ${expositor.tipoProdutoServico}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (expositor.descricao.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expositor.descricao,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_note,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Editar',
                      iconSize: 24,
                      onPressed: () {
                        _navigateToForm(expositor: expositor);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: 'Remover',
                      iconSize: 24,
                      onPressed: () {
                        if (expositor.id != null) {
                          _removerExpositor(expositor.id!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expositores da Feira'),
        // Não precisamos mais da TabBar aqui, a menos que queira manter
        // A lógica de agrupamento será feita diretamente no corpo
      ),
      body: StreamBuilder<List<Expositor>>(
        stream: _firestoreService.getExpositores(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum expositor cadastrado.'));
          }

          final todosExpositores = snapshot.data!;

          // 1. Agrupar expositores por categoria
          Map<String, List<Expositor>> expositoresPorCategoria = {};
          for (var expositor in todosExpositores) {
            // Se a categoria não existe no mapa, cria uma nova lista
            expositoresPorCategoria
                .putIfAbsent(expositor.tipoProdutoServico, () => [])
                .add(expositor);
          }

          // 2. Ordenar os expositores dentro de cada categoria pelo número do estande
          expositoresPorCategoria.forEach((categoria, listaDeExpositores) {
            listaDeExpositores.sort((a, b) {
              // Lógica de ordenação do estande:
              // - Estandes com número vêm primeiro.
              // - Entre estandes com número, ordena numericamente (se possível) ou alfabeticamente.
              // - Estandes sem número (null ou vazio) vêm por último.

              bool aTemEstande =
                  a.numeroEstande != null && a.numeroEstande!.isNotEmpty;
              bool bTemEstande =
                  b.numeroEstande != null && b.numeroEstande!.isNotEmpty;

              if (aTemEstande && !bTemEstande) return -1; // a vem primeiro
              if (!aTemEstande && bTemEstande) return 1; // b vem primeiro
              if (!aTemEstande && !bTemEstande)
                return 0; // ambos sem estande, mantém ordem (ou ordena por nome)
              // return a.nome.compareTo(b.nome); // se quiser ordenar por nome os sem estande

              // Ambos têm estande, tenta comparar numericamente se possível
              int? numA = int.tryParse(a.numeroEstande!);
              int? numB = int.tryParse(b.numeroEstande!);

              if (numA != null && numB != null) {
                return numA.compareTo(numB); // Comparação numérica
              }
              return a.numeroEstande!.compareTo(
                b.numeroEstande!,
              ); // Comparação alfabética
            });
          });

          // 3. Ordenar as categorias (usando kOrdemCategorias ou alfabeticamente)
          List<String> categoriasOrdenadas;
          if (kOrdemCategorias.isNotEmpty) {
            // Se temos uma ordem preferencial
            categoriasOrdenadas =
                kOrdemCategorias
                    .where((cat) => expositoresPorCategoria.containsKey(cat))
                    .toList();
            // Adicionar categorias que estão nos dados mas não na nossa lista de ordem (ex: "Outros")
            expositoresPorCategoria.keys
                .where((cat) => !categoriasOrdenadas.contains(cat))
                .forEach((cat) {
                  categoriasOrdenadas.add(cat);
                });
          } else {
            // Senão, ordena alfabeticamente
            categoriasOrdenadas = expositoresPorCategoria.keys.toList()..sort();
          }

          // 4. Construir a ListView agrupada
          return ListView.builder(
            itemCount: categoriasOrdenadas.length,
            itemBuilder: (context, indexCategoria) {
              String categoria = categoriasOrdenadas[indexCategoria];
              List<Expositor> listaDaCategoria =
                  expositoresPorCategoria[categoria]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      categoria,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            kCoresCategorias[categoria] ??
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // ListView aninhada para os expositores desta categoria
                  // Usamos shrinkWrap e physics para que funcione dentro de outra ListView
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listaDaCategoria.length,
                    itemBuilder: (context, indexExpositor) {
                      final expositor = listaDaCategoria[indexExpositor];
                      // Reutiliza o widget de item que criámos antes
                      return _buildExpositorItem(expositor);
                    },
                  ),
                  if (indexCategoria <
                      categoriasOrdenadas.length -
                          1) // Adiciona um divisor entre categorias
                    const Divider(
                      height: 24,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_expositor_list_screen',
        onPressed: () {
          Navigator.pushNamed(context, ExpositorFormScreen.routeNameAdd);
        },
        tooltip: 'Adicionar Expositor',
        child: const Icon(Icons.add),
      ),
    );
  }
}
