import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AguardandoAprovacaoScreen extends StatelessWidget {
  const AguardandoAprovacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro em Análise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // Ao sair, o AuthWrapper vai automaticamente redirecionar para o Login
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Cadastro Recebido!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'As suas informações foram enviadas e estão a ser analisadas por um administrador. Por favor, aguarde a aprovação para aceder à aplicação.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
