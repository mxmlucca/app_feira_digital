// lib/screens/mapa_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../feira_evento/domain/entities/feira.dart';
import '../../../expositor/domain/entities/expositor.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/controllers/user_provider.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});
  static const String routeName = '/mapa';

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Widget _buildInfoCard(
    BuildContext context, {
    required Feira feira,
    Expositor? expositor,
  }) {
    final theme = Theme.of(context);
    final bool isExpositor = expositor != null;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feira.titulo,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'dd \'de\' MMMM \'de\' yyyy',
                    'pt_BR',
                  ).format(feira.data),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            if (isExpositor) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.storefront, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Seu Estande: ${expositor.numeroEstande ?? "Não definido"}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Acede ao UserProvider para saber se é um expositor e obter os seus dados
    final userProvider = Provider.of<UserProvider>(context);
    final expositorProfile = userProvider.expositorProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Feira Atual')),
      body: StreamBuilder<Feira?>(
        stream: _firestoreService.getFeiraAtualStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar dados da feira: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Nenhuma feira ativa no momento.'));
          }

          final feira = snapshot.data!;
          final mapaUrl = feira.mapaUrl;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Card com as informações
              _buildInfoCard(
                context,
                feira: feira,
                expositor: expositorProfile,
              ),

              // Mapa Interativo
              if (mapaUrl != null && mapaUrl.isNotEmpty)
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    mapaUrl,
                    fit: BoxFit.contain,
                    loadingBuilder:
                        (context, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                    errorBuilder:
                        (context, error, stackTrace) => const Center(
                          child: Text(
                            'Não foi possível carregar a imagem do mapa.',
                          ),
                        ),
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('A feira atual não possui um mapa disponível.'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
