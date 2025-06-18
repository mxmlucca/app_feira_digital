import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/feira.dart';
import '../../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';
import 'feira_form_screen.dart';
import '../mapa/mapa_viewer_screen.dart';

class FeiraDetailScreen extends StatefulWidget {
  final Feira feiraEvento;

  const FeiraDetailScreen({super.key, required this.feiraEvento});

  static const String routeName = '/feira-detalhe';

  @override
  State<FeiraDetailScreen> createState() => _FeiraDetailScreenState();
}

class _FeiraDetailScreenState extends State<FeiraDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isAdmin = userProvider.usuario?.papel == 'admin';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feiraEvento.titulo),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar Feira',
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    FeiraFormScreen.routeNameEdit,
                    arguments: widget.feiraEvento,
                  ),
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover Feira',
              onPressed: _confirmarERemoverFeira,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card Principal com Título e Data
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.feiraEvento.titulo,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'EEEE, dd \'de\' MMMM \'de\' yyyy',
                          'pt_BR',
                        ).format(widget.feiraEvento.data),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (widget.feiraEvento.anotacoes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Descrição/Anotações', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              widget.feiraEvento.anotacoes,
              style: theme.textTheme.bodyLarge,
            ),
          ],

          if (widget.feiraEvento.mapaUrl != null &&
              widget.feiraEvento.mapaUrl!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Mapa da Feira', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            InkWell(
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    MapaViewerScreen.routeName,
                    arguments: widget.feiraEvento.mapaUrl!,
                  ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.feiraEvento.mapaUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.download_outlined),
              label: const Text('Baixar Imagem do Mapa'),
              onPressed: () async {
                final url = Uri.parse(widget.feiraEvento.mapaUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],

          if (isAdmin) ...[
            const Divider(height: 40),
            // Lógica de Admin (Ativar/Finalizar Feira)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como Finalizada'),

                // ----- ALTERAÇÃO AQUI -----
                onPressed: () async {
                  // Primeiro, verificamos se a feira que estamos tentando finalizar
                  // é de fato a feira ativa no momento.
                  final feiraAtiva = await _firestoreService.getFeiraAtual();
                  if (feiraAtiva?.id != widget.feiraEvento.id) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Esta não é a feira ativa. Apenas o status dela será alterado para "finalizada".',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                    // Se não for a ativa, apenas mudamos o status dela
                    final feiraAtualizada = Feira(
                      id: widget.feiraEvento.id,
                      data: widget.feiraEvento.data,
                      titulo: widget.feiraEvento.titulo,
                      status: StatusFeira.finalizada,
                      anotacoes: widget.feiraEvento.anotacoes,
                      mapaUrl: widget.feiraEvento.mapaUrl,
                      presencaExpositores:
                          widget.feiraEvento.presencaExpositores,
                    );
                    await _firestoreService.atualizarFeiraEvento(
                      feiraAtualizada,
                    );
                  } else {
                    // Se for a feira ativa, usamos nosso novo método
                    await _firestoreService.finalizarFeiraAtiva(
                      widget.feiraEvento.id!,
                    );
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feira marcada como finalizada.'),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],

          // ESPAÇO RESERVADO PARA LISTA DE PRESENÇA
          const Divider(height: 40),
          // TODO: Futuramente, a lista de presença será inserida aqui.
          // Por enquanto, pode ser um Text.
          const Center(child: Text('Funcionalidade de presença em breve...')),
        ],
      ),
    );
  }
}
