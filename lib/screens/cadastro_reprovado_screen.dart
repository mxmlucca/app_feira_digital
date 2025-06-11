import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/expositor.dart'; // Importar o modelo Expositor
import 'cadastro_expositor_screen.dart'; // Importar a tela de cadastro

class CadastroReprovadoScreen extends StatelessWidget {
  final Expositor? expositorReprovado; // Recebe o perfil completo do expositor

  static const String routeName = '/cadastro-reprovado';

  const CadastroReprovadoScreen({super.key, this.expositorReprovado});

  // Função para abrir o WhatsApp
  void _abrirWhatsApp() async {
    const numero = '5512912345678'; // SUBSTITUA PELO NÚMERO DE CONTATO DA FEIRA
    final url = Uri.parse(
      "https://wa.me/$numero?text=Olá, gostaria de falar sobre o meu cadastro reprovado.",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Não foi possível abrir o WhatsApp.');
    }
  }

  // Função para abrir o cliente de email
  void _abrirEmail() async {
    const email = 'contato@feiradigital.com'; // SUBSTITUA PELO EMAIL DE CONTATO
    const assunto = 'Dúvida sobre cadastro reprovado';
    final url = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(assunto)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Não foi possível abrir o cliente de email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega o motivo da reprovação do objeto expositor
    final motivo = expositorReprovado?.motivoReprovacao;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro Reprovado'),
        automaticallyImplyLeading: false, // Remove o botão de voltar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // O AuthWrapper tratará do redirecionamento para a tela de Login
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              const Text(
                'Cadastro Não Aprovado',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Infelizmente, não foi possível aprovar o seu cadastro no momento.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (motivo != null && motivo.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Motivo da Reprovação:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  motivo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              // --- NOVO BOTÃO PARA CORRIGIR CADASTRO ---
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Corrigir e Reenviar Cadastro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: () {
                  if (expositorReprovado != null) {
                    // Navega para a tela de cadastro, passando os dados existentes
                    // para pré-preenchimento
                    Navigator.pushReplacement(
                      // Usa pushReplacement para sair desta tela
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CadastroExpositorScreen(
                              expositorParaCorrecao: expositorReprovado,
                            ),
                      ),
                    );
                  } else {
                    // Fallback caso os dados do expositor não tenham sido carregados
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Não foi possível carregar os dados para edição. Tente fazer login novamente.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Se tiver dúvidas, entre em contato conosco:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _abrirWhatsApp,
                    icon: const Icon(Icons.message),
                    label: const Text('WhatsApp'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: _abrirEmail,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
