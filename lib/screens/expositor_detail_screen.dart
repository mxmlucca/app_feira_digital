import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expositor.dart';
import '../models/feira_evento.dart';
import '../services/firestore_service.dart';
import 'expositor_form_screen.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';

class ExpositorDetailScreen extends StatefulWidget {
  final Expositor expositor;

  const ExpositorDetailScreen({super.key, required this.expositor});

  static const String routeName = '/expositores-detail';

  @override
  State<ExpositorDetailScreen> createState() => _ExpositorDetailScreenState();
}

class _ExpositorDetailScreenState extends State<ExpositorDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late int _anoSelecionado;

  @override
  void initState() {
    super.initState();
    _anoSelecionado = DateTime.now().year;
  }

  Future<void> _confirmarERemoverExpositor(
    BuildContext context,
    String id,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    bool confirmar =
        await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Confirmar Remoção'),
              content: const Text(
                'Tem a certeza de que deseja remover este expositor? Esta ação não pode ser desfeita.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => navigator.pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => navigator.pop(true),
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
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Expositor removido com sucesso!')),
        );
        navigator.pop(); // Volta para a lista após remover
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erro ao remover expositor: $e')),
        );
      }
    }
  }

  void _navegarParaFormularioEdicao(
    BuildContext context,
    Expositor expositorParaEditar,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExpositorFormScreen(expositor: expositorParaEditar),
        settings: RouteSettings(
          name: ExpositorFormScreen.routeNameEdit,
          arguments: expositorParaEditar,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // Padding vertical reduzido
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.0, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(FeiraEvento feira) {
    final bool? presente = feira.presencaExpositores?[widget.expositor.id];
    Color corIcone = Colors.grey;
    IconData icone = Icons.schedule;

    if (presente == true) {
      corIcone = Colors.green.shade700;
      icone = Icons.check_circle;
    } else if (presente == false) {
      corIcone = Colors.red.shade700;
      icone = Icons.cancel;
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(4.0), // Padding interno reduzido
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd/MM').format(feira.data),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ), // Fonte menor
            const SizedBox(height: 4.0),
            Icon(icone, color: corIcone, size: 28), // Ícone um pouco menor
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color corFundoTela = theme.colorScheme.secondary;
    final Color corTextoPrincipal = theme.colorScheme.primary;
    final Color corBotao = theme.colorScheme.primary;

    // Verifica se o usuário é um administrador
    final userProvider = Provider.of<UserProvider>(context);
    final bool isAdmin = userProvider.usuario?.papel == 'admin';

    return Scaffold(
      backgroundColor: corFundoTela,
      appBar: AppBar(
        title: const Text('Feirante'),
        actions: [
          if (widget.expositor.id != null && isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: 'Remover Expositor',
              onPressed:
                  () => _confirmarERemoverExpositor(
                    context,
                    widget.expositor.id!,
                  ),
            ),
        ],
      ),
      // MUDANÇA: Usando ListView em vez de SingleChildScrollView + Column
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: <Widget>[
          // --- Secção Nome e Estande ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.expositor.nome,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.expositor.numeroEstande ?? 'S/N',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary.withOpacity(
                      0.9,
                    ), // Cor de destaque
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // --- Secção Informações do Vendedor ---
          Text(
            'Informações do Vendedor',
            style: theme.textTheme.titleLarge?.copyWith(
              color: corTextoPrincipal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Card(
            color: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildInfoRow(
                    context,
                    Icons.category_outlined,
                    'Categoria',
                    widget.expositor.tipoProdutoServico,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.business_center_outlined,
                    'Situação',
                    widget.expositor.situacao,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.phone_outlined,
                    'Contato',
                    widget.expositor.contato,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.notes_outlined,
                    'Descrição',
                    widget.expositor.descricao,
                  ),
                  // Adicione esta secção para mostrar a imagem
                  const SizedBox(height: 24.0),
                  Text('Documento Enviado', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8.0),
                  if (widget.expositor.rgUrl != null &&
                      widget.expositor.rgUrl!.isNotEmpty)
                    Image.network(widget.expositor.rgUrl!)
                  else
                    const Text('Nenhum documento encontrado.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32.0),

          if (isAdmin) ...[
            // --- Botão Editar ---
            // MUDANÇA: Envolvido em SizedBox para garantir a largura total e padding
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
              ), // Adiciona margem lateral
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // O estilo (cores, etc) virá do tema global, mas podemos definir o tamanho
                  style: theme.elevatedButtonTheme.style,
                  onPressed:
                      () => _navegarParaFormularioEdicao(
                        context,
                        widget.expositor,
                      ),
                  child: const Text('Editar Informações'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32.0),

          // --- Secção Histórico de Presença ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => setState(() => _anoSelecionado--),
              ),
              Text(
                _anoSelecionado.toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: corTextoPrincipal,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => setState(() => _anoSelecionado++),
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: corBotao,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: StreamBuilder<List<FeiraEvento>>(
              stream: _firestoreService.getFeiraEventos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.hasError)
                  return Center(
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return const Center(
                    child: Text(
                      'Nenhuma feira encontrada.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );

                final feirasDoAno =
                    snapshot.data!
                        .where((feira) => feira.data.year == _anoSelecionado)
                        .toList();

                if (feirasDoAno.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhuma feira encontrada para $_anoSelecionado.',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: feirasDoAno.length,
                  itemBuilder: (context, index) {
                    return _buildGridItem(feirasDoAno[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
