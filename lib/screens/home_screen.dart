import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Importar o Provider
import '../services/user_provider.dart'; // Importar o UserProvider
import 'admin/admin_aprovacao_screen.dart'; // Importar a nova tela

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

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
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final userProvider = Provider.of<UserProvider>(context);
    final bool isAdmin = userProvider.usuario?.papel == 'admin';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Bem-vindo(a)!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (currentUser?.email != null)
                Text(
                  'Logado como: ${currentUser!.email}',
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 24),
              const Text(
                'Esta é a sua página principal.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              // --- BOTÃO CONDICIONAL PARA ADMIN ---
              if (isAdmin)
                ElevatedButton.icon(
                  icon: const Icon(Icons.playlist_add_check_circle_outlined),
                  label: const Text('Aprovar Novos Feirantes'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AdminAprovacaoScreen.routeName,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
