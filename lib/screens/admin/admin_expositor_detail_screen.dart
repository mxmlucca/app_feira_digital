// lib/screens/admin/admin_expositor_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/expositor.dart';
import '../../services/firestore_service.dart';

class AdminExpositorDetailScreen extends StatefulWidget {
  final Expositor expositor;

  const AdminExpositorDetailScreen({super.key, required this.expositor});

  static const String routeName = '/admin/expositor-detail';

  @override
  State<AdminExpositorDetailScreen> createState() =>
      _AdminExpositorDetailScreenState();
}

class _AdminExpositorDetailScreenState
    extends State<AdminExpositorDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  Future<void> _processarAprovacao(bool aprovar) async {
    setState(() {
      _isProcessing = true;
    });

    String novoStatus;
    String acao;

    if (aprovar) {
      novoStatus = 'ativo';
      acao = 'aprovado';
    } else {
      final motivoController = TextEditingController();
      final motivo = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Reprovar Cadastro'),
              content: TextField(
                controller: motivoController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Digite o motivo da reprovação',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.of(context).pop(motivoController.text),
                  child: const Text('Confirmar Reprovação'),
                ),
              ],
            ),
      );

      if (motivo == null || motivo.trim().isEmpty) {
        setState(() => _isProcessing = false);
        return; // Admin cancelou a reprovação
      }
      novoStatus = 'reprovado';
      acao = 'reprovado';
      await _firestoreService.atualizarStatusExpositor(
        widget.expositor.id!,
        novoStatus,
        motivo: motivo,
      );
    }

    try {
      if (aprovar) {
        await _firestoreService.atualizarStatusExpositor(
          widget.expositor.id!,
          novoStatus,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Expositor $acao com sucesso!')));
        // Volta para a tela anterior (a lista de aprovações)
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao processar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análise de Cadastro')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoRow('Nome Completo', widget.expositor.nome),
          _buildInfoRow('Email', widget.expositor.email ?? 'Não informado'),
          _buildInfoRow('Contato', widget.expositor.contato),
          _buildInfoRow('Categoria', widget.expositor.tipoProdutoServico),
          _buildInfoRow(
            'Situação',
            widget.expositor.situacao ?? 'Não informado',
          ),
          _buildInfoRow('Descrição', widget.expositor.descricao),

          const Divider(height: 32),

          const Text(
            'Documento (RG/CNH)',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (widget.expositor.rgUrl != null &&
              widget.expositor.rgUrl!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                widget.expositor.rgUrl!,
                fit: BoxFit.cover,
                // Mostra um indicador de carregamento enquanto a imagem baixa
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // Mostra um ícone de erro se a imagem falhar
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                },
              ),
            )
          else
            const Text('Nenhum documento foi enviado.'),

          const SizedBox(height: 40),

          // Botões de Ação
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Reprovar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed:
                      _isProcessing ? null : () => _processarAprovacao(false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Aprovar'),
                  onPressed:
                      _isProcessing ? null : () => _processarAprovacao(true),
                ),
              ),
            ],
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
