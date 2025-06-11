import 'package:flutter/material.dart';
import '../../models/expositor.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class AdminAprovacaoScreen extends StatefulWidget {
  const AdminAprovacaoScreen({super.key});
  static const String routeName = '/admin/aprovacoes';

  @override
  State<AdminAprovacaoScreen> createState() => _AdminAprovacaoScreenState();
}

class _AdminAprovacaoScreenState extends State<AdminAprovacaoScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _processarAprovacao(String id, bool aprovar) async {
    String novoStatus;
    String acao;

    if (aprovar) {
      novoStatus = 'ativo';
      acao = 'aprovado';
      try {
        await _firestoreService.atualizarStatusExpositor(id, novoStatus);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao aprovar: $e')));
        return;
      }
    } else {
      // SE FOR REPROVAR, ABRE UMA CAIXA DE DIÁLOGO
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
        // Admin cancelou ou não escreveu um motivo
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reprovação cancelada.')));
        return;
      }

      novoStatus = 'reprovado';
      acao = 'reprovado';
      try {
        // Precisamos de um método no serviço que salve também o motivo
        await _firestoreService.atualizarStatusExpositor(
          id,
          novoStatus,
          motivo: motivo,
        );
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao reprovar: $e')));
        return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Expositor $acao com sucesso!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprovações Pendentes')),
      body: StreamBuilder<List<Expositor>>(
        stream: _firestoreService.getExpositoresPorStatus(
          'aguardando_aprovacao',
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cadastro pendente no momento.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final expositoresPendentes = snapshot.data!;

          return ListView.builder(
            itemCount: expositoresPendentes.length,
            itemBuilder: (context, index) {
              final expositor = expositoresPendentes[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expositor.nome,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text('Email: ${expositor.email}'),
                      Text('Contato: ${expositor.contato}'),
                      Text('Categoria: ${expositor.tipoProdutoServico}'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed:
                                () => _processarAprovacao(expositor.id!, false),
                            child: const Text(
                              'Reprovar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                () => _processarAprovacao(expositor.id!, true),
                            child: const Text('Aprovar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
