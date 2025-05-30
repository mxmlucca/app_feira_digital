import 'package:flutter/material.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  static const String routeName = '/mapa';

  @override
  Widget build(BuildContext context) {
    const String nomeImagemMapa = 'layout.png';

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa da Feira'), centerTitle: true),
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(20.0),
        child: Center(
          child: Image.asset(
            'images/$nomeImagemMapa',
            fit: BoxFit.contain,
            errorBuilder: (
              BuildContext context,
              Object exception,
              StackTrace? stackTrace,
            ) {
              return const Center(
                child: Text(
                  'Não foi possível carregar o mapa. Verifique o caminho do asset.',
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
