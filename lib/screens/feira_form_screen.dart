import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import '../models/feira_evento.dart';
import '../services/firestore_service.dart';

class FeiraFormScreen extends StatefulWidget {
  final FeiraEvento? feiraEvento;

  const FeiraFormScreen({super.key, this.feiraEvento});

  static const String routeNameAdd = '/add-feira';
  static const String routeNameEdit = '/edit-feira';

  @override
  State<FeiraFormScreen> createState() => _FeiraFormScreenState();
}

class _FeiraFormScreenState extends State<FeiraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _tituloController;
  late TextEditingController _anotacoesController;
  DateTime? _dataSelecionada;
  StatusFeira _statusSelecionado = StatusFeira.planejada;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.feiraEvento?.titulo ?? '',
    );
    _anotacoesController = TextEditingController(
      text: widget.feiraEvento?.anotacoes ?? '',
    );
    _dataSelecionada = widget.feiraEvento?.data;
    _statusSelecionado = widget.feiraEvento?.status ?? StatusFeira.planejada;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: 'Selecione a data da feira',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (dataEscolhida != null && dataEscolhida != _dataSelecionada) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  Future<void> _salvarFeira() async {
    if (_formKey.currentState!.validate()) {
      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione uma data para a feira.'),
          ),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final feiraParaSalvar = FeiraEvento(
          id: widget.feiraEvento?.id,
          titulo: _tituloController.text.trim(),
          data: _dataSelecionada!,
          anotacoes: _anotacoesController.text.trim(),
          status: _statusSelecionado,
          presencaExpositores: widget.feiraEvento?.presencaExpositores ?? {},
        );

        if (widget.feiraEvento == null) {
          await _firestoreService.adicionarFeiraEvento(feiraParaSalvar);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feira adicionada com sucesso!')),
            );
          }
        } else {
          await _firestoreService.atualizarFeiraEvento(feiraParaSalvar);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feira atualizada com sucesso!')),
            );
          }
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao salvar feira: $e')));
        }
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
          widget.feiraEvento == null ? 'Adicionar Nova Feira' : 'Editar Feira',
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
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Feira (Ex: Feira de Maio)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dataSelecionada == null
                          ? 'Nenhuma data selecionada'
                          : 'Data da Feira: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selecionarData(context),
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _anotacoesController,
                decoration: const InputDecoration(
                  labelText: 'Anotações sobre a Feira (Opcional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<StatusFeira>(
                decoration: const InputDecoration(
                  labelText: 'Status da Feira',
                  border: OutlineInputBorder(),
                ),
                value: _statusSelecionado,
                items:
                    StatusFeira.values.map((StatusFeira status) {
                      return DropdownMenuItem<StatusFeira>(
                        value: status,
                        child: Text(
                          status.toString().split('.').last[0].toUpperCase() +
                              status.toString().split('.').last.substring(1),
                        ),
                      );
                    }).toList(),
                onChanged: (StatusFeira? novoValor) {
                  if (novoValor != null) {
                    setState(() {
                      _statusSelecionado = novoValor;
                    });
                  }
                },
                validator:
                    (value) => value == null ? 'Selecione um status' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _salvarFeira,
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
                        : const Text('Salvar Feira'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
