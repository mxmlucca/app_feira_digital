import 'package:flutter/material.dart';
import '../../models/expositor.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'admin_expositor_detail_screen.dart';

class AdminAprovacaoScreen extends StatefulWidget {
  const AdminAprovacaoScreen({super.key});
  static const String routeName = '/admin/aprovacoes';

  @override
  State<AdminAprovacaoScreen> createState() => _AdminAprovacaoScreenState();
}

class _AdminAprovacaoScreenState extends State<AdminAprovacaoScreen> {
  final FirestoreService _firestoreService = FirestoreService();

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
                // Torna o Card clicável
                child: InkWell(
                  onTap: () {
                    // Navega para a nova tela de detalhes, passando o expositor
                    Navigator.pushNamed(
                      context,
                      AdminExpositorDetailScreen.routeName,
                      arguments: expositor,
                    );
                  },
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ), // Raio da borda do Card
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expositor.nome,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text('Email: ${expositor.email}'),
                              Text(
                                'Categoria: ${expositor.tipoProdutoServico}',
                              ),
                            ],
                          ),
                        ),
                        // Adiciona um ícone para indicar que é navegável
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      ],
                    ),
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
