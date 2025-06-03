import 'package:flutter/material.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  static const String routeName = '/mapa';

  @override
  Widget build(BuildContext context) {
    const String nomeImagemMapa =
        'layout.png'; // Certifique-se que este é o nome correto do seu asset

    // Cores baseadas na sua imagem de referência
    // Estas cores podem vir do seu ThemeData se as padronizou lá
    final Color corDeFundoDaTela =
        Theme.of(context).colorScheme.secondary; // Amarelo, p. ex.
    final Color corDaMoldura =
        Theme.of(
          context,
        ).colorScheme.primary; // Magenta/Rosa escuro para a moldura/botão

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa da Feira'),
        // A cor da AppBar virá do appBarTheme no main.dart
      ),
      // Cor de fundo da tela (fora do "quadro")
      backgroundColor: corDeFundoDaTela,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Um padding geral para a tela
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Estica os filhos horizontalmente
          children: <Widget>[
            // O "Quadro" do Mapa
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(
                  8.0,
                ), // Espaçamento interno da moldura
                decoration: BoxDecoration(
                  color:
                      Colors
                          .white, // Cor de fundo do "quadro" onde a imagem fica
                  border: Border.all(
                    color: corDaMoldura, // Cor da borda da moldura
                    width: 4.0, // Largura da borda
                  ),
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ), // Bordas arredondadas para o quadro
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Posição da sombra
                    ),
                  ],
                ),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(
                    8.0,
                  ), // Margem para zoom dentro do quadro
                  child: Center(
                    child: Image.asset(
                      'assets/images/$nomeImagemMapa', // Certifique-se que este caminho está correto
                      fit: BoxFit.contain,
                      errorBuilder: (
                        BuildContext context,
                        Object exception,
                        StackTrace? stackTrace,
                      ) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Mapa não carregado.',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Verifique o caminho em assets/images/',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0), // Espaço entre o mapa e o botão
            // Botão "Atualizar Imagem"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    corDaMoldura, // Usando a cor da "moldura" para o botão
                foregroundColor:
                    Theme.of(
                      context,
                    ).colorScheme.onPrimary, // Cor do texto no botão
                // O padding e textStyle podem vir do tema global ou ser definidos aqui
                // padding: const EdgeInsets.symmetric(vertical: 16.0),
                // textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // Lógica futura para upload de imagem
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Funcionalidade de atualizar mapa a ser implementada!',
                    ),
                  ),
                );
                print('Botão Atualizar Imagem pressionado');
              },
              child: const Text('Atualizar Imagem'),
            ),
          ],
        ),
      ),
    );
  }
}
