import 'package:flutter/material.dart';
import '../models/expositor.dart';
import '../services/firestore_service.dart'; // Precisaremos do nosso serviço

// Em lib/screens/expositor_form_screen.dart (ou num ficheiro de constantes)
const List<String> kCategoriasExpositor = [
  'Artesanato',
  'Alimentação',
  'Bebidas',
  'Vestuário',
  'Serviços',
  'Outros',
];

const List<String> kSituacoesExpositor = [
  'Ambulante',
  'MEI',
  'Empreendedor Individual',
  'Pequena Empresa',
  'Outro',
];

class ExpositorFormScreen extends StatefulWidget {
  // Opcional: Se estiver a editar, receberemos o expositor existente
  final Expositor? expositor;

  const ExpositorFormScreen({super.key, this.expositor});

  static const String routeNameAdd = '/add-expositor';
  static const String routeNameEdit = '/edit-expositor';

  @override
  State<ExpositorFormScreen> createState() => _ExpositorFormScreenState();
}

class _ExpositorFormScreenState extends State<ExpositorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Controladores para os campos de texto
  late TextEditingController _nomeController;
  late TextEditingController _contatoController;
  late TextEditingController _descricaoController;
  late TextEditingController _tipoProdutoServicoController;
  late TextEditingController _numeroEstandeController;
  // Para os Dropdowns, vamos guardar o valor selecionado numa String
  String? _categoriaSelecionada;
  String? _situacaoSelecionada;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do expositor (se estiver a editar)
    _nomeController = TextEditingController(text: widget.expositor?.nome ?? '');
    _contatoController = TextEditingController(
      text: widget.expositor?.contato ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.expositor?.descricao ?? '',
    );
    _tipoProdutoServicoController = TextEditingController(
      text: widget.expositor?.tipoProdutoServico ?? '',
    );

    _numeroEstandeController = TextEditingController(
      text: widget.expositor?.numeroEstande ?? '',
    );

    // Se estiver a editar e o expositor tiver uma categoria/situação, pré-selecione-a
    if (widget.expositor != null) {
      _categoriaSelecionada =
          kCategoriasExpositor.contains(widget.expositor!.tipoProdutoServico)
              ? widget.expositor!.tipoProdutoServico
              : null;
      _situacaoSelecionada =
          kSituacoesExpositor.contains(widget.expositor!.situacao)
              ? widget.expositor!.situacao
              : null;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _contatoController.dispose();
    _descricaoController.dispose();
    _tipoProdutoServicoController.dispose();
    _numeroEstandeController.dispose();
    super.dispose();
  }

  Future<void> _salvarExpositor() async {
    if (_formKey.currentState!.validate()) {
      // Valida o formulário
      setState(() {
        _isSaving = true;
      });

      try {
        // Dentro de _salvarExpositor()
        Expositor expositorParaSalvar = Expositor(
          id: widget.expositor?.id,
          nome: _nomeController.text.trim(),
          contato: _contatoController.text.trim(),
          descricao: _descricaoController.text.trim(),
          tipoProdutoServico:
              _categoriaSelecionada ??
              _tipoProdutoServicoController.text
                  .trim(), // Usa o dropdown ou o campo de texto antigo
          numeroEstande:
              _numeroEstandeController.text.trim().isEmpty
                  ? null
                  : _numeroEstandeController.text
                      .trim(), // Permite nulo se vazio
          situacao: _situacaoSelecionada,
        );

        if (widget.expositor == null) {
          // Adicionar novo expositor
          await _firestoreService.adicionarExpositor(expositorParaSalvar);
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expositor adicionado com sucesso!'),
              ),
            );
        } else {
          // Atualizar expositor existente
          await _firestoreService.atualizarExpositor(expositorParaSalvar);
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expositor atualizado com sucesso!'),
              ),
            );
        }

        if (mounted)
          Navigator.of(context).pop(); // Volta para a tela anterior após salvar
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar expositor: $e')),
          );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expositor == null ? 'Adicionar Expositor' : 'Editar Expositor',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Expositor',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contatoController,
                decoration: const InputDecoration(
                  labelText: 'Contato (Telefone, Email, etc.)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o contato';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição Curta'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoria (Tipo de Produto/Serviço)',
                  border: OutlineInputBorder(),
                ),
                value: _categoriaSelecionada,
                hint: const Text('Selecione uma categoria'),
                items:
                    kCategoriasExpositor.map((String categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                onChanged: (String? novoValor) {
                  setState(() {
                    _categoriaSelecionada = novoValor;
                  });
                },
                validator:
                    (value) => value == null ? 'Selecione uma categoria' : null,
              ),

              // CAMPO NÚMERO DO ESTANDE
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroEstandeController,
                decoration: const InputDecoration(
                  labelText: 'Número do Estande (Opcional)',
                ),
                keyboardType:
                    TextInputType.text, // Pode ser número ou texto como "Palco"
              ),

              // CAMPO SITUAÇÃO DO EXPOSITOR - Usando Dropdown
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Situação do Expositor',
                  border: OutlineInputBorder(),
                ),
                value: _situacaoSelecionada,
                hint: const Text('Selecione a situação'),
                items:
                    kSituacoesExpositor.map((String situacao) {
                      return DropdownMenuItem<String>(
                        value: situacao,
                        child: Text(situacao),
                      );
                    }).toList(),
                onChanged: (String? novoValor) {
                  setState(() {
                    _situacaoSelecionada = novoValor;
                  });
                },
                validator:
                    (value) => value == null ? 'Selecione a situação' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    _isSaving
                        ? null
                        : _salvarExpositor, // Desativa o botão enquanto salva
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Salvar Expositor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
