import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/feira.dart';
import '../../models/expositor.dart'; // Importar o model Expositor
import '../../services/firestore_service.dart';
import 'feira_form_screen.dart';
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';

// Mapa de cores para categorias (pode mover para um ficheiro de constantes)
const Map<String, Color> kCoresCategorias = {
  'Artesanato': Colors.brown, // Ajustado para exemplo, use as suas cores
  'Alimentação': Colors.orange,
  'Bebidas': Colors.blue,
  'Vestuário': Colors.purple,
  'Serviços': Colors.teal,
  'Outros': Colors.grey,
};

class FeiraDetailScreen extends StatefulWidget {
  final Feira feiraEvento;

  const FeiraDetailScreen({super.key, required this.feiraEvento});

  static const String routeName = '/feira-detalhe';

  @override
  State<FeiraDetailScreen> createState() => _FeiraDetailScreenState();
}

class _FeiraDetailScreenState extends State<FeiraDetailScreen> {
  late StatusFeira _statusAtualDaFeira;
  late StatusFeira _statusSelecionadoParaEdicao;
  late FirestoreService _firestoreService;
  bool _isSavingStatus = false;

  Map<String, bool?> _presencasEditaveis = {};
  bool _isLoadingExpositores = true;
  List<Expositor> _todosExpositores = [];

  @override
  void initState() {
    super.initState();
    _statusAtualDaFeira = widget.feiraEvento.status;
    _statusSelecionadoParaEdicao = widget.feiraEvento.status;
    _firestoreService = FirestoreService();
    _presencasEditaveis = Map<String, bool?>.from(
      widget.feiraEvento.presencaExpositores ?? {},
    );

    if (_statusAtualDaFeira != StatusFeira.finalizada) {
      _carregarTodosExpositores();
    } else if (widget.feiraEvento.presencaExpositores != null &&
        widget.feiraEvento.presencaExpositores!.isNotEmpty) {
      _carregarExpositoresDaListaDePresenca();
    } else {
      _isLoadingExpositores = false;
    }
  }

  Future<void> _carregarTodosExpositores() async {
    setState(() {
      _isLoadingExpositores = true;
    });
    try {
      final expositoresStream = _firestoreService.getExpositores();
      final listaExpositores = await expositoresStream.first;
      listaExpositores.sort((a, b) {
        int compCategoria = a.tipoProdutoServico.compareTo(
          b.tipoProdutoServico,
        );
        if (compCategoria != 0) return compCategoria;
        return a.nome.compareTo(b.nome);
      });
      setState(() {
        _todosExpositores = listaExpositores;
        for (var expositor in _todosExpositores) {
          if (expositor.id != null &&
              !_presencasEditaveis.containsKey(expositor.id!)) {
            _presencasEditaveis[expositor.id!] =
                false; // Inicia como Ausente por padrão
          }
        }
        _isLoadingExpositores = false;
      });
    } catch (e) {
      print("Erro ao carregar expositores: $e");
      if (mounted) {
        setState(() {
          _isLoadingExpositores = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar lista de expositores: $e')),
        );
      }
    }
  }

  Future<void> _carregarExpositoresDaListaDePresenca() async {
    if (widget.feiraEvento.presencaExpositores == null ||
        widget.feiraEvento.presencaExpositores!.isEmpty) {
      setState(() {
        _isLoadingExpositores = false;
      });
      return;
    }
    setState(() {
      _isLoadingExpositores = true;
    });
    List<Expositor> expositoresNaLista = [];
    for (String expositorId in widget.feiraEvento.presencaExpositores!.keys) {
      Expositor? expositor = await _firestoreService.getExpositorPorId(
        expositorId,
      );
      if (expositor != null) {
        expositoresNaLista.add(expositor);
      }
    }
    expositoresNaLista.sort((a, b) {
      int compCategoria = a.tipoProdutoServico.compareTo(b.tipoProdutoServico);
      if (compCategoria != 0) return compCategoria;
      return a.nome.compareTo(b.nome);
    });
    setState(() {
      _todosExpositores = expositoresNaLista;
      _isLoadingExpositores = false;
    });
  }

  String _statusParaStringLegivel(StatusFeira status) {
    String name = status.toString().split('.').last;
    if (name.isEmpty) return '';
    String result = name[0].toUpperCase();
    for (int i = 1; i < name.length; i++) {
      if (name[i] == name[i].toUpperCase() && name[i - 1] != ' ') {
        result += ' ';
      }
      result += name[i];
    }
    return result;
  }

  Future<void> _salvarNovoStatus() async {
    if (_statusSelecionadoParaEdicao == widget.feiraEvento.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma alteração de status para salvar.'),
        ),
      );
      return;
    }
    setState(() {
      _isSavingStatus = true;
    });
    try {
      Feira feiraAtualizada = Feira(
        id: widget.feiraEvento.id,
        titulo: widget.feiraEvento.titulo,
        data: widget.feiraEvento.data,
        anotacoes: widget.feiraEvento.anotacoes,
        status: _statusSelecionadoParaEdicao,
        presencaExpositores: widget.feiraEvento.presencaExpositores,
      );
      await _firestoreService.atualizarFeiraEvento(feiraAtualizada);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status da feira atualizado com sucesso!'),
          ),
        );
        setState(() {
          _statusAtualDaFeira = _statusSelecionadoParaEdicao;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar status: $e')));
    } finally {
      if (mounted)
        setState(() {
          _isSavingStatus = false;
        });
    }
  }

  Future<void> _salvarPresencas() async {
    setState(() {
      _isSavingStatus = true;
    });
    try {
      Feira feiraComPresencasAtualizadas = Feira(
        id: widget.feiraEvento.id,
        titulo: widget.feiraEvento.titulo,
        data: widget.feiraEvento.data,
        anotacoes: widget.feiraEvento.anotacoes,
        status: _statusAtualDaFeira,
        presencaExpositores: _presencasEditaveis,
      );
      await _firestoreService.atualizarFeiraEvento(
        feiraComPresencasAtualizadas,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista de presença atualizada com sucesso!'),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar presenças: $e')));
    } finally {
      if (mounted)
        setState(() {
          _isSavingStatus = false;
        });
    }
  }

  Widget _buildListaPresenca() {
    if (_isLoadingExpositores) {
      return const Center(child: CircularProgressIndicator());
    }

    bool podeEditarPresenca = (_statusAtualDaFeira == StatusFeira.atual);

    if (_todosExpositores.isEmpty) {
      if (podeEditarPresenca) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nenhum expositor cadastrado no sistema para marcar presença.',
            textAlign: TextAlign.center,
          ),
        );
      } else if (_statusAtualDaFeira == StatusFeira.finalizada &&
          (widget.feiraEvento.presencaExpositores == null ||
              widget.feiraEvento.presencaExpositores!.isEmpty)) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Nenhuma presença registada para esta feira finalizada.',
            textAlign: TextAlign.center,
          ),
        );
      } else if (_statusAtualDaFeira == StatusFeira.finalizada) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Expositores da lista de presença não encontrados ou lista vazia.',
            textAlign: TextAlign.center,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _todosExpositores.length,
          itemBuilder: (context, index) {
            final expositor = _todosExpositores[index];
            bool? presencaAtual;
            if (podeEditarPresenca) {
              presencaAtual =
                  _presencasEditaveis[expositor.id] ??
                  false; // Assume 'false' (ausente) se nulo para modo de edição
            } else {
              presencaAtual =
                  widget.feiraEvento.presencaExpositores?[expositor.id];
            }

            final Color corDaCategoria =
                kCoresCategorias[expositor.tipoProdutoServico] ?? Colors.grey;
            Color corPresente =
                (presencaAtual == true) ? Colors.green.shade700 : Colors.grey;
            Color corAusente =
                (presencaAtual == false) ? Colors.red.shade700 : Colors.grey;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: CircleAvatar(
                          radius: 24, // Um pouco menor
                          backgroundColor: corDaCategoria,
                          foregroundColor: Colors.white,
                          child: Text(
                            expositor.numeroEstande != null &&
                                    expositor.numeroEstande!.isNotEmpty
                                ? expositor.numeroEstande!
                                : 'S/N',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expositor.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Categoria: ${expositor.tipoProdutoServico}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (expositor.situacao != null &&
                              expositor.situacao!.isNotEmpty)
                            Text(
                              'Situação: ${expositor.situacao}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Botões de Presença ou Status de Presença
                    if (podeEditarPresenca)
                      SizedBox(
                        width: 100, // Ajuste conforme necessário
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.check_circle_outline,
                                color: corPresente,
                                size: 28,
                              ),
                              tooltip: 'Marcar como Presente',
                              onPressed: () {
                                setState(() {
                                  _presencasEditaveis[expositor.id!] = true;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.highlight_off_outlined,
                                color: corAusente,
                                size: 28,
                              ),
                              tooltip: 'Marcar como Ausente',
                              onPressed: () {
                                setState(() {
                                  _presencasEditaveis[expositor.id!] = false;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    else // Feira Realizada ou Cancelada - Apenas visualização
                      SizedBox(
                        width: 100, // Largura similar para alinhamento
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              presencaAtual == true
                                  ? Icons.check_circle
                                  : presencaAtual == false
                                  ? Icons.cancel
                                  : Icons.help_outline,
                              color:
                                  presencaAtual == true
                                      ? Colors.green.shade700
                                      : presencaAtual == false
                                      ? Colors.red.shade700
                                      : Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(width: 8), // Espaço para o texto
                            Expanded(
                              // Para o texto não quebrar mal
                              child: Text(
                                presencaAtual == true
                                    ? "Presente"
                                    : presencaAtual == false
                                    ? "Ausente"
                                    : "N/D",
                                style: TextStyle(
                                  color:
                                      presencaAtual == true
                                          ? Colors.green.shade700
                                          : presencaAtual == false
                                          ? Colors.red.shade700
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (podeEditarPresenca) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_outlined),
            label: const Text('Salvar Lista de Presença'),
            onPressed: _isSavingStatus ? null : _salvarPresencas,
          ),
          if (_isSavingStatus) ...[
            const SizedBox(height: 10),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool podeEditarPresencaAgora = (_statusAtualDaFeira == StatusFeira.atual);

    // Lógica de carregamento inicial ou quando o status da feira muda
    // Esta lógica pode precisar de refinamento para evitar chamadas desnecessárias
    if (podeEditarPresencaAgora &&
        _todosExpositores.isEmpty &&
        !_isLoadingExpositores) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _carregarTodosExpositores(),
      );
    } else if (_statusAtualDaFeira == StatusFeira.finalizada &&
        _todosExpositores.isEmpty &&
        !_isLoadingExpositores) {
      if (widget.feiraEvento.presencaExpositores != null &&
          widget.feiraEvento.presencaExpositores!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _carregarExpositoresDaListaDePresenca(),
        );
      }
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isAdmin = userProvider.usuario?.papel == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feiraEvento.titulo),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Dados da Feira',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          FeiraFormScreen(feiraEvento: widget.feiraEvento),
                ),
              ).then((foiModificado) {
                if (foiModificado == true) {
                  // Para atualizar os dados da feira nesta tela após edição,
                  // a FeiraFormScreen precisaria retornar o objeto atualizado,
                  // ou esta tela precisaria ouvir um stream específico para este FeiraEvento.
                  // Uma solução simples é forçar um rebuild, mas não ideal.
                  // Por agora, o status é atualizado localmente, outros dados não.
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.feiraEvento.titulo,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18.0,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Data: ${DateFormat('dd/MM/yyyy, HH:mm').format(widget.feiraEvento.data)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18.0, color: Colors.grey),
                const SizedBox(width: 8.0),
                Text(
                  'Status Atual: ${_statusParaStringLegivel(_statusAtualDaFeira)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (widget.feiraEvento.anotacoes.isNotEmpty) ...[
              Text(
                'Anotações:',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                widget.feiraEvento.anotacoes,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24.0),
            ],

            const Divider(height: 32.0),

            // // Status
            // Text(
            //   'Alterar Status da Feira:',
            //   style: Theme.of(
            //     context,
            //   ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8.0),
            // DropdownButtonFormField<StatusFeira>(
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     contentPadding: EdgeInsets.symmetric(
            //       horizontal: 12.0,
            //       vertical: 8.0,
            //     ),
            //   ),
            //   value: _statusSelecionadoParaEdicao,
            //   items:
            //       StatusFeira.values.map((StatusFeira status) {
            //         return DropdownMenuItem<StatusFeira>(
            //           value: status,
            //           child: Text(_statusParaStringLegivel(status)),
            //         );
            //       }).toList(),
            //   onChanged: (StatusFeira? novoValor) {
            //     if (novoValor != null) {
            //       setState(() {
            //         _statusSelecionadoParaEdicao = novoValor;
            //       });
            //     }
            //   },
            // ),
            // const SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: _isSavingStatus ? null : _salvarNovoStatus,
            //   child:
            //       _isSavingStatus
            //           ? const SizedBox(
            //             height: 20,
            //             width: 20,
            //             child: CircularProgressIndicator(
            //               strokeWidth: 2,
            //               color: Colors.white,
            //             ),
            //           )
            //           : const Text('Salvar Novo Status'),
            // ),
            const Divider(height: 32.0),

            // Ativar Feira
            if (isAdmin) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Tornar Esta Feira Ativa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed: () async {
                    try {
                      await _firestoreService.setFeiraAtiva(
                        widget.feiraEvento.id!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Feira definida como ativa com sucesso!',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao definir feira ativa: $e'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],

            const Divider(height: 32.0),

            Text(
              'Lista de Presença',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildListaPresenca(),
          ],
        ),
      ),
    );
  }
}
