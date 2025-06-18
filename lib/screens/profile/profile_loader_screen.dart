import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/expositor.dart';
import '../../services/firestore_service.dart';
import '../expositores/expositor_detail_screen.dart'; // A tela que queremos mostrar no final

class ProfileLoaderScreen extends StatefulWidget {
  const ProfileLoaderScreen({super.key});

  @override
  State<ProfileLoaderScreen> createState() => _ProfileLoaderScreenState();
}

class _ProfileLoaderScreenState extends State<ProfileLoaderScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<Expositor?>? _expositorFuture;

  @override
  void initState() {
    super.initState();
    // Pega o UID do utilizador atual e inicia a busca pelos dados do expositor
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _expositorFuture = _firestoreService.getExpositorPorId(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se, por alguma razão, não houver utilizador, mostre uma mensagem de erro.
    if (_expositorFuture == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Erro: Não foi possível obter o ID do utilizador logado.',
          ),
        ),
      );
    }

    // FutureBuilder vai "ouvir" a Future e reconstruir a UI com base no seu estado.
    return FutureBuilder<Expositor?>(
      future: _expositorFuture,
      builder: (context, snapshot) {
        // Enquanto os dados estão a ser buscados
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se a busca resultou num erro
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao carregar os seus dados: ${snapshot.error}'),
            ),
          );
        }

        // Se a busca terminou, mas não encontrou dados
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Não foi possível encontrar os seus dados de expositor.',
              ),
            ),
          );
        }

        // Se tudo correu bem e temos os dados do expositor
        final expositor = snapshot.data!;
        // Retorna a tela de detalhes, passando o objeto expositor encontrado!
        return ExpositorDetailScreen(expositor: expositor);
      },
    );
  }
}
