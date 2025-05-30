import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expositor.dart';
import '../services/firestore_service.dart';
import 'expositor_form_screen.dart';

const Map<String, Color> kCoresCategorias = {
  'Artesanato': Colors.blue,
  'Alimentação': Colors.yellow,
  'Bebidas': Colors.orange,
  'Vestuário': Colors.purple,
  'Serviços': Colors.teal,
  'Outros': Colors.grey,
};

class ExpositorListScreen extends StatefulWidget {
  const ExpositorListScreen({super.key});

  static const String routeName = '/expositores-list';

  @override
  State<ExpositorListScreen> createState() => _ExpositorListScreenState();
}

class _ExpositorListScreenState extends State<ExpositorListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateToForm({Expositor? expositor}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpositorFormScreen(expositor: expositor),
        // Definimos um nome para a rota de edição para consistência,
        // embora MaterialPageRoute não use 'settings.name' diretamente para match de rota
        settings: RouteSettings(
          name: ExpositorFormScreen.routeNameEdit,
          arguments: expositor, // Podemos passar argumentos assim também
        ),
      ),
    );
  }

  Future<void> _removerExpositor(String id) async {
    // Adicionar uma caixa de diálogo de confirmação
    bool confirmar =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Remoção'),
              content: const Text(
                'Tem a certeza de que deseja remover este expositor?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Cancela
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Confirma
                  child: const Text('Remover'),
                ),
              ],
            );
          },
        ) ??
        false; // Se o diálogo for dispensado, assume 'false'

    if (confirmar) {
      try {
        await _firestoreService.removerExpositor(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expositor removido com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao remover expositor: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Expositores'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Expositor>>(
        stream: _firestoreService.getExpositores(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar expositores: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum expositor cadastrado ainda.'),
            );
          }

          final expositores = snapshot.data!;

          return ListView.builder(
            itemCount: expositores.length,
            itemBuilder: (context, index) {
              final expositor = expositores[index];
              final Color corDaCategoria =
                  kCoresCategorias[expositor.tipoProdutoServico] ??
                  Colors.black54;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coluna 1: ID (ou número do estande)
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: CircleAvatar(
                            backgroundColor: corDaCategoria,
                            foregroundColor: Colors.white,
                            child: Text(
                              expositor.numeroEstande != null &&
                                      expositor.numeroEstande!.isNotEmpty
                                  ? expositor.numeroEstande!
                                  : 'X', // Mostra 'X' se não houver número de estande
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Coluna 2: Nome e Categoria
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expositor.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Categoria: ${expositor.tipoProdutoServico}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              // Adicionar Situação aqui também, se relevante para visualização rápida
                              if (expositor.situacao != null &&
                                  expositor.situacao!.isNotEmpty)
                                Text(
                                  'Situação: ${expositor.situacao}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Coluna 3: Descrição e Contato (removido para simplificar a lista, ideal para tela de detalhes)
                      // Pode voltar a adicionar se quiser, mas a lista pode ficar muito carregada.
                      // Por agora, focaremos em Nome, Categoria, Estande e Situação.

                      // Coluna 4: Botões (Movido para o final do Row para ocupar o espaço restante)
                      SizedBox(
                        width: 80, // Ajuste a largura conforme necessário
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .end, // Alinha os botões à direita
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                color: Colors.blue.shade700,
                              ),
                              tooltip: 'Editar',
                              onPressed: () {
                                _navigateToForm(expositor: expositor);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                              ),
                              tooltip: 'Remover',
                              onPressed: () {
                                if (expositor.id != null) {
                                  _removerExpositor(expositor.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, ExpositorFormScreen.routeNameAdd);
        },
        icon: const Icon(Icons.add),
        label: const Text('Expositor'), // Ou '+ Expositor'
        tooltip: 'Adicionar Novo Expositor',
      ),
    );
  }
}
