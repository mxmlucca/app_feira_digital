// lib/screens/admin/admin_dashboard_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/expositor.dart';
import '../../models/feira.dart';
import '../../services/firestore_service.dart';
import '../feiras/feira_detail_screen.dart';
import '../feiras/feira_form_screen.dart';
import 'admin_aprovacao_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Instância do nosso serviço para buscar dados
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao fazer logout: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Feira - Página Principal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
      // Usamos um ListView para o caso de o conteúdo não caber em telas menores
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCardFeiraAtiva(),
          const SizedBox(height: 16),
          _buildCardAprovacoes(),
          const SizedBox(height: 16),
          _buildCardAcessoRapido(),
        ],
      ),
    );
  }

  /// Constrói o Card que mostra informações sobre a feira ativa
  Widget _buildCardFeiraAtiva() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // StreamBuilder ouve as mudanças na feira ativa em tempo real
        child: StreamBuilder<Feira?>(
          stream: _firestoreService.getFeiraAtualStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final feiraAtiva = snapshot.data;

            if (feiraAtiva == null) {
              return const Center(
                child: Text(
                  'Nenhuma feira ativa no momento.',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              );
            }

            // Conteúdo do card quando há uma feira ativa
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FEIRA ATIVA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feiraAtiva.titulo,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Gerenciar Feira'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                FeiraDetailScreen(feiraEvento: feiraAtiva),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Constrói o Card que mostra o número de aprovações pendentes
  Widget _buildCardAprovacoes() {
    return Card(
      elevation: 4,
      // StreamBuilder ouve a lista de expositores aguardando aprovação
      child: StreamBuilder<List<Expositor>>(
        stream: _firestoreService.getExpositoresPorStatus(
          'aguardando_aprovacao',
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Carregando aprovações...'),
            );
          }
          final int totalPendente = snapshot.data!.length;

          return ListTile(
            leading: Icon(
              Icons.playlist_add_check_circle_outlined,
              color:
                  totalPendente > 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              size: 40,
            ),
            title: Text(
              '$totalPendente Cadastros Pendentes',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text('Toque para analisar os novos cadastros'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, AdminAprovacaoScreen.routeName);
            },
          );
        },
      ),
    );
  }

  /// Constrói o Card com botões para ações rápidas
  Widget _buildCardAcessoRapido() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acesso Rápido',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Usamos um Wrap para que os botões se ajustem em telas menores
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Nova Feira'),
                  onPressed: () {
                    Navigator.pushNamed(context, FeiraFormScreen.routeNameAdd);
                  },
                ),
                // Adicione outros botões de atalho aqui se desejar
                // Ex:
                // ElevatedButton.icon(
                //   icon: const Icon(Icons.person_add_alt_1_outlined),
                //   label: const Text('Novo Feirante'),
                //   onPressed: () {
                //     Navigator.pushNamed(context, ExpositorFormScreen.routeNameAdd);
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
