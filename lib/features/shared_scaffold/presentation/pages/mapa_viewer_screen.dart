// lib/screens/mapa_viewer_screen.dart

import 'package:flutter/material.dart';

class MapaViewerScreen extends StatelessWidget {
  final String mapaUrl;

  const MapaViewerScreen({super.key, required this.mapaUrl});

  static const String routeName = '/mapa-viewer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador de Mapa'),
        backgroundColor: Colors.black, // Fundo escuro para imersão
      ),
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            mapaUrl,
            fit: BoxFit.contain,
            loadingBuilder:
                (context, child, progress) =>
                    progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
            errorBuilder:
                (context, error, stackTrace) => const Center(
                  child: Text(
                    'Não foi possível carregar o mapa.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
