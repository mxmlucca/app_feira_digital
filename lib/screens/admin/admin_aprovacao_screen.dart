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
    final novoStatus = aprovar ? 'ativo' : 'reprovado';
    final acao = aprovar ? 'aprovado' : 'reprovado';
    try {
      await _firestoreService.atualizarStatusExpositor(id, novoStatus);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Expositor $acao com sucesso!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar aprovação: $e')),
        );
      }
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
