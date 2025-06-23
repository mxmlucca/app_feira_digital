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

  String? _idFeiraAtiva;
  bool _isLoading = true;

  late Feira _feiraAtual;

  @override
  void initState() {
    super.initState();
    _feiraAtual = widget.feiraEvento;
    _carregarFeiraAtiva();
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
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
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
                    Text(
                      'Descrição/Anotações',
                      style: theme.textTheme.titleLarge,
                    ),
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
                    Container(
                      height:
                          300, // Damos um pouco mais de altura para facilitar a interação
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        // ClipRRect para manter as bordas arredondadas
                        borderRadius: BorderRadius.circular(11),
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            _feiraAtual.mapaUrl!,
                            fit: BoxFit.contain,
                          ),
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
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ],

                  if (isAdmin) ...[
                    // const Divider(height: 40),

                    // --- LÓGICA DE VISIBILIDADE DOS BOTÕES ---

                    // 1. Botão para ATIVAR: só aparece se a feira for 'agendada'
                    if (widget.feiraEvento.status == StatusFeira.agendada &&
                        !isFeiraAtiva)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          label: const Text('Tornar Esta Feira Ativa'),
                          onPressed: _tornarFeiraAtiva,
                        ),
                      ),

                    // 2. Botão para FINALIZAR: só aparece se a feira for a ATIVA
                    if (isFeiraAtiva)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          label: const Text('Marcar como Finalizada'),
                          onPressed: _finalizarFeira,
                        ),
                      ),
                  ],

                  // ESPAÇO RESERVADO PARA LISTA DE PRESENÇA
                  const Divider(height: 40),
                  // TODO: Futuramente, a lista de presença será inserida aqui.
                  // Por enquanto, pode ser um Text.
                  const Center(
                    child: Text('Funcionalidade de presença em breve...'),
                  ),
                ],
              ),
    );
  }
}
