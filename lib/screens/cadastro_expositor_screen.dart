import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/expositor.dart';
import '../models/usuario.dart';
import '../services/firestore_service.dart';
import '../services/user_provider.dart';
// Certifique-se de que o caminho e o nome do arquivo estão corretos e que o arquivo contém a classe UserProvider.

class CadastroExpositorScreen extends StatefulWidget {
  final Expositor? expositorParaCorrecao;

  const CadastroExpositorScreen({super.key, this.expositorParaCorrecao});

  static const String routeName = '/cadastro-expositor';

  @override
  State<CadastroExpositorScreen> createState() =>
      _CadastroExpositorScreenState();
}

class _CadastroExpositorScreenState extends State<CadastroExpositorScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();
  final _contatoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _numeroEstandeController = TextEditingController();
  File? _rgImageFile;
  final ImagePicker _picker = ImagePicker();
  String? _categoriaSelecionada;
  String? _situacaoSelecionada;
  bool _isSaving = false;
  bool _obscurePassword = true;

  late bool _isModoCorrecao;

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
  void initState() {
    super.initState();
    _isModoCorrecao = widget.expositorParaCorrecao != null;

    if (_isModoCorrecao) {
      final e = widget.expositorParaCorrecao!;
      _emailController.text = e.email ?? '';
      _nomeController.text = e.nome;
      _contatoController.text = e.contato;
      _descricaoController.text = e.descricao;
      _numeroEstandeController.text = e.numeroEstande ?? '';
      _categoriaSelecionada =
          kCategoriasExpositor.contains(e.tipoProdutoServico)
              ? e.tipoProdutoServico
              : null;
      _situacaoSelecionada =
          kSituacoesExpositor.contains(e.situacao) ? e.situacao : null;
    }
  }

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
      User? user;

      if (!_isModoCorrecao) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        user = userCredential.user;
      } else {
        user = FirebaseAuth.instance.currentUser;
      }

      if (user == null) throw Exception('Erro de autenticação.');
      final storageRef = FirebaseStorage.instance.ref();
      final rgPath = 'rg/${user.uid}.jpg';
      final rgRef = storageRef.child(rgPath);

      await rgRef.putFile(_rgImageFile!);
      final rgUrl = await rgRef.getDownloadURL();

      final usuarioParaSalvar = Usuario(
        uid: user.uid,
        email: user.email!,
        nome: _nomeController.text.trim(),
        papel: 'expositor',
      );

      final expositorParaSalvar = Expositor(
        id: user.uid,
        email: user.email!,
        nome: _nomeController.text.trim(),
        contato: _contatoController.text.trim(),
        descricao: _descricaoController.text.trim(),
        tipoProdutoServico: _categoriaSelecionada!,
        situacao: _situacaoSelecionada,
        numeroEstande: _numeroEstandeController.text.trim(),
        status: 'aguardando_aprovacao',
        motivoReprovacao: null,
        rgUrl: rgUrl,
      );

      await _firestoreService.setUsuario(usuarioParaSalvar);
      await _firestoreService.setExpositor(expositorParaSalvar);

      if (mounted) {
        await showDialog(
          context: context,
          // Impede que o usuário feche o diálogo clicando fora dele
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Cadastro Enviado!'),
                content: const Text(
                  'O seu cadastro foi enviado com sucesso e será analisado por um administrador.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 1. Fecha o diálogo
                      Navigator.of(ctx).pop();

                      // 2. Notifica o Provider para se atualizar.
                      // O listen: false é crucial aqui porque estamos dentro de um callback.
                      Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).refreshUserData();

                      // 3. Remove a tela de cadastro da pilha de navegação.
                      // O AuthWrapper, que agora está visível e foi notificado,
                      // tratará de mostrar a tela correta.
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocorreu um erro no cadastro.';
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      }
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este email já está a ser utilizado.';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickRgImage() async {
    try {
      final XFile? rgImg = await _picker.pickImage(source: ImageSource.gallery);

      if (rgImg != null) {
        setState(() {
          _rgImageFile = File(rgImg.path);
        });
      }
    } catch (e) {
      // Handle or log the error as needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isModoCorrecao ? 'Corrigir Cadastro' : 'Cadastro de Feirante',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('1. Crie o seu Acesso', style: theme.textTheme.titleLarge),

              const SizedBox(height: 12),

              // EMAIL
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                enabled: !_isModoCorrecao,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  fillColor:
                      !_isModoCorrecao
                          ? Color.fromARGB(255, 31, 37, 47)
                          : Colors.grey.shade300,
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        (v == null || !v.contains('@'))
                            ? 'Email inválido'
                            : null,
              ),

              const SizedBox(height: 16),

              // SENHA
              if (!_isModoCorrecao)
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Senha',
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

              // NOME
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Nome',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              // CONTATO
              TextFormField(
                controller: _contatoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Seu contato (telefone/WhatsApp)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              // DESCRIÇÃO
              TextFormField(
                controller: _descricaoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Descreva seus produtos/serviços',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),

              const SizedBox(height: 16),

              // CATEGORIA
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                hint: const Text(
                  'Sua categoria principal',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                items:
                    kCategoriasExpositor
                        .map(
                          (categoria) => DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _categoriaSelecionada = val),
                validator:
                    (val) => val == null ? 'Selecione uma categoria' : null,
              ),

              const SizedBox(height: 16),

              // SITUAÇÃO
              DropdownButtonFormField<String>(
                value: _situacaoSelecionada,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.info)),
                hint: const Text(
                  'Sua situação como empreendedor',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                items:
                    kSituacoesExpositor
                        .map(
                          (situacao) => DropdownMenuItem(
                            value: situacao,
                            child: Text(situacao),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _situacaoSelecionada = val),
              ),

              const SizedBox(height: 16),

              // RG
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:
                    _rgImageFile != null
                        ? Image.file(_rgImageFile!, fit: BoxFit.cover)
                        : const Center(
                          child: Text('Nenhuma imagem selecionada.'),
                        ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Selecionar Foto do RG'),
                onPressed: _pickRgImage,
              ),

              // NÚMERO DO ESTANDE
              // TextFormField(
              //   controller: _numeroEstandeController,
              //   decoration: const InputDecoration(
              //     hintText: 'Nº do Estande (se já souber)',
              //   ),
              // ),
              const SizedBox(height: 32),

              // BOTÃO DE ENVIO
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
                        : Text(
                          _isModoCorrecao
                              ? 'Reenviar Cadastro'
                              : 'Enviar para Aprovação',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
