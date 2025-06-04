import 'package:flutter/material.dart';
import '../models/expositor.dart';
import '../services/firestore_service.dart';
import 'expositor_form_screen.dart'; // Para navegar para a edição

// Supondo que kCoresCategorias está definido globalmente ou importado
// Se não, defina-o aqui ou importe-o.
// const Map<String, Color> kCoresCategorias = { /* ... seu mapa de cores ... */ };

class ExpositorDetailScreen extends StatelessWidget {
  final Expositor expositor;

  const ExpositorDetailScreen({super.key, required this.expositor});

  // Não precisamos de routeName se sempre navegamos com MaterialPageRoute e argumentos.
  // static const String routeName = '/expositor-detail';

  Future<void> _confirmarERemoverExpositor(
    BuildContext context,
    String id,
  ) async {
    final firestoreService =
        FirestoreService(); // Instancia localmente ou passe via Provider/DI
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
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Remover'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmar && context.mounted) {
      try {
        await firestoreService.removerExpositor(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expositor removido com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a lista após remover
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
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
          name: ExpositorFormScreen.routeNameEdit, // Para consistência
          arguments: expositorParaEditar,
        ),
      ),
    ).then((foiModificado) {
      if (foiModificado == true && context.mounted) {
        // Se o formulário indicar que houve modificação, podemos atualizar esta tela
        // A forma mais simples seria recarregar os dados do expositor,
        // mas isso exigiria que esta tela fosse StatefulWidget e buscasse os dados.
        // Por agora, a lista anterior (ExpositorListScreen) já se atualiza com o Stream.
        // Se quisermos que esta tela também se atualize, precisaríamos de uma
        // gestão de estado mais avançada ou que o form retorne o objeto atualizado.
        // (context as Element).reassemble(); // Força um rebuild, mas não é ideal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dados podem ter sido atualizados. Volte à lista para ver as mudanças se necessário.',
            ),
          ),
        );
      }
    });
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink(); // Não mostra nada se o valor for nulo ou vazio
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: Theme.of(context).colorScheme.primary),
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
                const SizedBox(height: 2.0),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A cor do texto pode ser definida no tema ou aqui, para contraste com o fundo amarelo
    final Color corTextoPrincipal = Colors.black87; // Exemplo
    final Color corFundoTela = const Color(0xFFFFEB3B); // Amarelo do seu design

    return Scaffold(
      backgroundColor: corFundoTela, // Fundo amarelo da tela
      appBar: AppBar(
        title: const Text('Feirante'), // Ou expositor.nome se preferir
        // A cor e estilo da AppBar virão do ThemeData
        actions: [
          if (expositor.id !=
              null) // Só mostra o botão de remover se o expositor já existe (tem ID)
            IconButton(
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: 'Remover Expositor',
              onPressed: () {
                _confirmarERemoverExpositor(context, expositor.id!);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Secção Nome e Estande
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Fundo branco para esta secção
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      expositor.nome,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary, // Cor do nome
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    expositor.numeroEstande != null &&
                            expositor.numeroEstande!.isNotEmpty
                        ? expositor.numeroEstande!
                        : 'S/N',
                    style: TextStyle(
                      fontSize: 48, // Tamanho grande para o número do estande
                      fontWeight: FontWeight.bold,
                      color:
                          theme
                              .colorScheme
                              .secondary, // Cor de destaque para o número
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Secção "Informações do Vendedor"
            Text(
              'Informações do Vendedor',
              style: theme.textTheme.titleLarge?.copyWith(
                color: corTextoPrincipal, // Cor do título da secção
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Card(
              // Usar um Card para agrupar as informações, já estilizado pelo tema
              elevation:
                  0, // Pode remover a elevação se o fundo da tela já contrasta
              color: corFundoTela.withAlpha(
                200,
              ), // Um pouco de transparência ou cor diferente
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _buildInfoRow(
                      context,
                      Icons.category_outlined,
                      'Categoria',
                      expositor.tipoProdutoServico,
                    ),
                    _buildInfoRow(
                      context,
                      Icons.business_center_outlined,
                      'Situação',
                      expositor.situacao,
                    ),
                    _buildInfoRow(
                      context,
                      Icons.phone_outlined,
                      'Contato',
                      expositor.contato,
                    ),
                    _buildInfoRow(
                      context,
                      Icons.notes_outlined,
                      'Descrição',
                      expositor.descricao,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Botão Editar
            Center(
              child: ElevatedButton(
                // O estilo virá do tema global, mas pode ser personalizado aqui
                // style: ElevatedButton.styleFrom(backgroundColor: corDoBotaoNoFigma),
                onPressed: () {
                  _navegarParaFormularioEdicao(context, expositor);
                },
                child: const Text('Editar Informações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
