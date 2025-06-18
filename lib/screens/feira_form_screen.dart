import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/feira.dart';
import '../services/firestore_service.dart';

class FeiraFormScreen extends StatefulWidget {
  final Feira? feiraEvento;

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
  StatusFeira _statusSelecionado = StatusFeira.atual;
  File? _mapaSelecionado;
  String? _mapaUrlExistente;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

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
    _statusSelecionado = widget.feiraEvento?.status ?? StatusFeira.atual;
    _mapaUrlExistente = widget.feiraEvento?.mapaUrl;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      helpText: 'SELECIONE A DATA DA FEIRA',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
              surface: colorScheme.secondary,
              background: colorScheme.secondary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (dataEscolhida != null && dataEscolhida != _dataSelecionada) {
      setState(() {
        _dataSelecionada = dataEscolhida;
      });
    }
  }

  Future<void> _selecionarMapa() async {
    final XFile? imagemEscolhida = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (imagemEscolhida != null) {
      setState(() {
        _mapaSelecionado = File(imagemEscolhida.path);
      });
    }
  }

  Future<void> _salvarFeira() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma data para a feira.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? mapaUrl = _mapaUrlExistente;

      // Se uma nova imagem de mapa foi selecionada, faz o upload
      if (_mapaSelecionado != null) {
        final feiraId =
            widget.feiraEvento?.id ?? _firestoreService.getNewFeiraId();
        final storageRef = FirebaseStorage.instance.ref();
        final caminhoMapa = 'mapas_feiras/$feiraId.jpg';
        final mapaRef = storageRef.child(caminhoMapa);

        await mapaRef.putFile(_mapaSelecionado!);
        mapaUrl = await mapaRef.getDownloadURL();
      }

      final feiraParaSalvar = Feira(
        id: widget.feiraEvento?.id,
        titulo: _tituloController.text.trim(),
        data: _dataSelecionada!,
        anotacoes: _anotacoesController.text.trim(),
        status: _statusSelecionado,
        mapaUrl: mapaUrl, // Passa a URL nova ou a existente
        presencaExpositores: widget.feiraEvento?.presencaExpositores ?? {},
      );

      if (widget.feiraEvento == null) {
        await _firestoreService.adicionarFeiraEvento(feiraParaSalvar);
      } else {
        await _firestoreService.atualizarFeiraEvento(feiraParaSalvar);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feira salva com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar feira: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Helper para converter o enum para uma string legível
  String _statusParaStringLegivel(StatusFeira status) {
    return status.toString().split('.').last[0].toUpperCase() +
        status.toString().split('.').last.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    // O tema é herdado automaticamente, não precisamos de 'final theme = Theme.of(context);'
    // a menos que queiramos sobrescrever algo muito específico.

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.feiraEvento == null ? 'Adicionar Nova Feira' : 'Editar Feira',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Título da Feira
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  hintText:
                      'Título da Feira (Ex: Feira de Maio)', // Usando hintText
                  prefixIcon: Icon(Icons.festival_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Seletor de Data Estilizado
              InkWell(
                onTap: () => _selecionarData(context),
                borderRadius: BorderRadius.circular(
                  8.0,
                ), // Para o efeito de clique
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Data da Feira',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _dataSelecionada == null
                        ? 'Toque para selecionar a data'
                        : DateFormat(
                          'EEEE, dd \'de\' MMMM \'de\' yyyy',
                          'pt_BR',
                        ).format(_dataSelecionada!),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Anotações
              TextFormField(
                controller: _anotacoesController,
                decoration: const InputDecoration(
                  hintText: 'Anotações sobre a Feira (Opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // Seletor de Mapa
              const Text("Mapa da Feira"),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _mapaSelecionado != null
                        ? Image.file(_mapaSelecionado!, fit: BoxFit.cover)
                        : (_mapaUrlExistente != null
                            ? Image.network(
                              _mapaUrlExistente!,
                              fit: BoxFit.cover,
                            )
                            : const Center(
                              child: Text('Nenhum mapa selecionado.'),
                            )),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Selecionar Imagem do Mapa'),
                onPressed: _selecionarMapa,
              ),

              const SizedBox(height: 20),

              // Seletor de Status (Atualizado)
              DropdownButtonFormField<StatusFeira>(
                decoration: const InputDecoration(
                  labelText: 'Status da Feira',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                value: _statusSelecionado,
                items:
                    StatusFeira.values.map((status) {
                      return DropdownMenuItem<StatusFeira>(
                        value: status,
                        child: Text(_statusParaStringLegivel(status)),
                      );
                    }).toList(),
                onChanged:
                    (novoValor) =>
                        setState(() => _statusSelecionado = novoValor!),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _salvarFeira,
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar Feira'),
              ),

              // Botão Salvar
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
