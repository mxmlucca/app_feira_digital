// lib/screens/expositores/expositor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../feira_evento/domain/entities/feira.dart';
import '../../../feira_evento/domain/entities/registro_presenca.dart';
import '../../domain/entities/expositor.dart';
import '../../../feira_evento/domain/entities/configuracao_feira.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/controllers/user_provider.dart';
import 'package:geolocator/geolocator.dart';

class ExpositorHomeScreen extends StatefulWidget {
  const ExpositorHomeScreen({super.key});

  static const String routeName = '/expositor-home';

  @override
  State<ExpositorHomeScreen> createState() => _ExpositorHomeScreenState();
}

class _ExpositorHomeScreenState extends State<ExpositorHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isCheckingIn = false;
  bool _isChangingInterest = false;

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

  // --- MÉTODO PARA REGISTRAR O INTERESSE ---
  Future<void> _registrarInteresse(Feira feira, StatusInteresse status) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final Expositor? expositorProfile = userProvider.expositorProfile;

    if (expositorProfile == null || feira.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Não foi possível carregar seu perfil.'),
        ),
      );
      return;
    }

    setState(() => _isChangingInterest = true);
    try {
      await _firestoreService.registrarInteresseExpositor(
        feiraId: feira.id!,
        expositor: expositorProfile,
        novoStatus: status,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar interesse: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isChangingInterest = false);
      }
    }
  }

  Future<void> _handleCheckIn(Feira feiraAtiva) async {
    if (currentUser == null) return;
    setState(() => _isCheckingIn = true);

    try {
      // 1. Busca a configuração da feira (local padrão)
      final ConfiguracaoFeira? config =
          await _firestoreService.getConfiguracaoFeira();
      if (config == null)
        throw Exception('Não foi possível carregar a configuração da feira.');

      // 2. Verifica e pede permissão de localização
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permissão de localização negada permanentemente. Por favor, ative nas configurações do seu aparelho.',
        );
      }

      // 3. Obtém a posição atual do usuário
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Calcula a distância
      double distancia = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        config.latitudePadrao,
        config.longitudePadrao,
      );

      // 5. Valida e realiza o check-in
      if (distancia <= config.raioPadraoMetros) {
        await _firestoreService.realizarCheckinExpositor(
          feiraId: feiraAtiva.id!,
          expositorId: currentUser!.uid,
        );
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
      } else {
        throw Exception(
          'Você está muito longe do local da feira para fazer o check-in. Aproxime-se e tente novamente.',
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      print('Erro ao realizar check-in: $e');
    } finally {
      if (mounted) setState(() => _isCheckingIn = false);
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          StreamBuilder<Feira?>(
            stream: _firestoreService.getFeiraAtualStream(),
            builder: (context, snapshotFeiraAtiva) {
              if (snapshotFeiraAtiva.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final feiraAtiva = snapshotFeiraAtiva.data;
              if (feiraAtiva != null) {
                return _buildActiveFairCard(context, feiraAtiva);
              } else {
                return _buildNextFairWidget();
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget para o caso de não haver feira ativa, busca a próxima agendada
  Widget _buildNextFairWidget() {
    return StreamBuilder<List<Feira>>(
      stream: _firestoreService.getFeiraEventos(),
      builder: (context, snapshotTodasAsFeiras) {
        if (!snapshotTodasAsFeiras.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todasAsFeiras = snapshotTodasAsFeiras.data ?? [];

        final proximasFeiras =
            todasAsFeiras.where((feira) {
              return feira.status == StatusFeira.agendada &&
                  !feira.data.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  );
            }).toList();

        proximasFeiras.sort((a, b) => a.data.compareTo(b.data));

        if (proximasFeiras.isEmpty) {
          return _buildNoFairsCard();
        }

        final proximaFeira = proximasFeiras.first;
        return _buildNextFairCard(context, proximaFeira);
      },
    );
  }

  // Card para a Feira ATIVA (com foco no check-in)
  Widget _buildActiveFairCard(BuildContext context, Feira feira) {
    final theme = Theme.of(context);
    final meuRegistro = feira.presencaExpositores[currentUser?.uid];
    final bool checkinRealizado = meuRegistro?.checkinGps ?? false;

    return Card(
      elevation: 6,
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "A FEIRA ESTÁ ACONTECENDO!",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(feira.titulo, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 24),

            // --- LÓGICA DE EXIBIÇÃO CONDICIONAL ---
            if (checkinRealizado)
              Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check-in realizado!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (meuRegistro?.checkinTimestamp != null)
                    Text(
                      'às ${DateFormat('HH:mm').format(meuRegistro!.checkinTimestamp!.toDate())}',
                    ),
                ],
              )
            else
              ElevatedButton.icon(
                icon:
                    _isCheckingIn
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.location_on_outlined),
                label: Text(
                  _isCheckingIn ? 'VERIFICANDO...' : 'FAZER CHECK-IN',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _isCheckingIn ? null : () => _handleCheckIn(feira),
              ),
          ],
        ),
      ),
    );
  }

  // Card para a PRÓXIMA feira agendada (com foco em manifestar interesse)
  // Card para a PRÓXIMA feira agendada (AGORA COM LÓGICA)
  Widget _buildNextFairCard(BuildContext context, Feira feira) {
    final theme = Theme.of(context);
    final meuRegistro = feira.presencaExpositores[currentUser?.uid];
    final meuInteresse = meuRegistro?.interesse ?? StatusInteresse.pendente;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PRÓXIMA FEIRA",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(feira.titulo, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'EEEE, dd \'de\' MMMM \'de\' yyyy',
                'pt_BR',
              ).format(feira.data),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            _isChangingInterest
                ? const Center(child: CircularProgressIndicator())
                : _buildInterestSection(context, meuInteresse, feira),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestSection(
    BuildContext context,
    StatusInteresse meuInteresse,
    Feira feira,
  ) {
    switch (meuInteresse) {
      case StatusInteresse.pendente:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Você pretende participar?",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Sim'),
                    onPressed:
                        () => _registrarInteresse(
                          feira,
                          StatusInteresse.confirmado,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Não'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                    onPressed:
                        () => _registrarInteresse(
                          feira,
                          StatusInteresse.recusado,
                        ),
                  ),
                ),
              ],
            ),
          ],
        );
      case StatusInteresse.confirmado:
        return ListTile(
          leading: Icon(
            Icons.check_circle,
            color: Colors.green.shade700,
            size: 30,
          ),
          title: const Text(
            'Interesse confirmado!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Nos vemos na feira!'),
          dense: true,
        );
      case StatusInteresse.recusado:
        return ListTile(
          leading: Icon(Icons.cancel, color: Colors.red.shade700, size: 30),
          title: const Text(
            'Participação recusada.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Agradecemos o aviso.'),
          dense: true,
        );
    }
  }

  // Card para quando não há nenhuma feira no sistema
  Widget _buildNoFairsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600, size: 40),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma feira futura encontrada.',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Fique de olho, em breve teremos novidades!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
