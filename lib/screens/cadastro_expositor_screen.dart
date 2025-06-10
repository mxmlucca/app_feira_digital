import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expositor.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';

class CadastroExpositorScreen extends StatefulWidget {
  const CadastroExpositorScreen({super.key});
  static const String routeName = '/cadastro-expositor';

  @override
  State<CadastroExpositorScreen> createState() =>
      _CadastroExpositorScreenState();
}

class _CadastroExpositorScreenState extends State<CadastroExpositorScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores para todos os campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();
  final _contatoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _numeroEstandeController = TextEditingController();
  String? _categoriaSelecionada;
  String? _situacaoSelecionada;

  bool _isSaving = false;
  bool _obscurePassword = true;

  // Listas de opções para os dropdowns
  final List<String> kCategoriasExpositor = [
    'Artesanato',
    'Alimentação',
    'Bebidas',
    'Vestuário',
    'Serviços',
    'Outros',
  ];
  final List<String> kSituacoesExpositor = [
    'Ambulante',
    'MEI',
    'Empreendedor Individual',
    'Pequena Empresa',
    'Outro',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _contatoController.dispose();
    _descricaoController.dispose();
    _numeroEstandeController.dispose();
    super.dispose();
  }

  Future<void> _handleCadastro() async {
    // Primeiro, valida o formulário. Se não for válido, retorna.
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Criar o utilizador no Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) {
        throw Exception(
          'Não foi possível criar o utilizador no Firebase Auth.',
        );
      }

      // 2. Preparar os objetos com todos os dados validados
      final novoUsuario = Usuario(
        uid: user.uid,
        email: user.email!,
        nome: _nomeController.text.trim(),
        papel: 'expositor',
      );

      final novoExpositor = Expositor(
        id: user.uid,
        email: user.email!,
        nome: _nomeController.text.trim(),
        contato: _contatoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tipoProdutoServico:
            _categoriaSelecionada!, // '!' é seguro aqui por causa do validator
        situacao:
            _situacaoSelecionada, // 'situacao' é opcional no model, pode ser nulo
        numeroEstande: _numeroEstandeController.text.trim(),
        status: 'aguardando_aprovacao', // Status inicial
      );

      // 3. Salvar os dados no Firestore
      await _firestoreService.setUsuario(novoUsuario);
      await _firestoreService.setExpositor(novoExpositor);

      if (mounted) {
        await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Cadastro Enviado!'),
                content: const Text(
                  'O seu cadastro foi enviado com sucesso e está a aguardar a aprovação de um administrador.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        if (mounted) Navigator.of(context).pop(); // Volta para a tela de login
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocorreu um erro no cadastro.';
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este email já está a ser utilizado por outra conta.';
      }
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
    } finally {
      if (mounted)
        setState(() {
          _isSaving = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Feirante')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '1. Crie o seu Acesso',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Seu melhor email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        (v == null || !v.contains('@'))
                            ? 'Email inválido'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Crie uma senha forte',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                obscureText: _obscurePassword,
                validator:
                    (v) =>
                        (v == null || v.length < 6)
                            ? 'Senha precisa de no mínimo 6 caracteres'
                            : null,
              ),
              const Divider(height: 40, thickness: 1),
              Text(
                '2. Suas Informações de Expositor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Seu nome ou nome da marca',
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contatoController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Seu contato (telefone/WhatsApp)',
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Descreva seus produtos/serviços',
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  hintText: 'Sua categoria principal',
                ),
                items:
                    kCategoriasExpositor
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _categoriaSelecionada = val),
                validator:
                    (val) => val == null ? 'Selecione uma categoria' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _situacaoSelecionada,
                decoration: const InputDecoration(
                  hintText: 'Sua situação como empreendedor',
                ),
                items:
                    kSituacoesExpositor
                        .map(
                          (sit) =>
                              DropdownMenuItem(value: sit, child: Text(sit)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _situacaoSelecionada = val),
                // Este campo é opcional, então não tem validator
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroEstandeController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Nº do Estande (se já souber)',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _handleCadastro,
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Enviar Cadastro para Aprovação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
